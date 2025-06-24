import copy
from abc import abstractmethod, ABC

from ...core.or_extractor import OrExtractor
from ....src.core.aoa import InequalityPredicate
from ....src.core.cs2 import Cs2
from ....src.core.db_restorer import DbRestorer
from ....src.core.equi_join import U2EquiJoin
from ....src.core.filter import Filter
from ....src.core.view_minimizer import ViewMinimizer
from ....src.pipeline.abstract.generic_pipeline import GenericPipeLine
from ....src.util.constants import FILTER, INEQUALITY, DONE, RUNNING, START, EQUALITY, DB_MINIMIZATION, \
    SAMPLING, RESTORE_DB, ERROR
from ....src.util.error_handling import UnmasqueError


def get_eq_filters(arithmetics):
    return [pred for pred in arithmetics if pred[2] in ['equal', '=']]


class DisjunctionPipeLine(GenericPipeLine, ABC):

    def __init__(self, connectionHelper, name):
        GenericPipeLine.__init__(self, connectionHelper, name)
        self.aoa = None
        self.equi_join = None
        self.filter_extractor = None
        self.db_restorer = None
        self.global_min_instance_dict = None
        self.key_lists = None

    def _mutation_pipeline(self, core_relations, query, time_profile, restore_details=None):
        self.update_state(RESTORE_DB + START)
        self.db_restorer = DbRestorer(self.connectionHelper, core_relations)
        self.db_restorer.set_data_schema()
        self.db_restorer.set_all_sizes(self.all_sizes)
        # for tab in core_relations:
        #    self.db_restorer.last_restored_size[tab] = self.all_sizes[tab]
        self.update_state(RESTORE_DB + RUNNING)
        check = self.db_restorer.doJob(restore_details)
        self.update_state(RESTORE_DB + DONE)
        time_profile.update_for_db_restore(self.db_restorer.local_elapsed_time, self.db_restorer.app_calls)
        if not check or not self.db_restorer.done:
            self.info[RESTORE_DB] = None
            self.logger.info("DB restore failed!")
            return False, time_profile
        self.info[RESTORE_DB] = {'size': self.db_restorer.last_restored_size}

        """
        Correlated Sampling
        """
        self.update_state(SAMPLING + START)
        cs2 = Cs2(self.connectionHelper, self.all_sizes, core_relations, self.key_lists, perc_based_cutoff=True)
        self.update_state(SAMPLING + RUNNING)
        check = cs2.doJob(query)
        self.update_state(SAMPLING + DONE)
        time_profile.update_for_cs2(cs2.local_elapsed_time, cs2.app_calls)
        if not check or not cs2.done:
            self.info[SAMPLING] = None
            self.logger.info("Sampling failed!")
        if not self.connectionHelper.config.use_cs2:
            self.info[SAMPLING] = SAMPLING + "DISABLED"
            self.logger.info("Sampling is disabled!")
        else:
            self.info[SAMPLING] = {'sample': cs2.sample, 'size': cs2.sizes}

        """
            View based Database Minimization
            """
        self.update_state(DB_MINIMIZATION + START)
        vm = ViewMinimizer(self.connectionHelper, core_relations, self.db_restorer.last_restored_size, cs2.passed)
        self.update_state(DB_MINIMIZATION + RUNNING)
        try:
            check = vm.doJob(query)
            self.update_state(DB_MINIMIZATION + DONE)
            time_profile.update_for_view_minimization(vm.local_elapsed_time, vm.app_calls)
        except UnmasqueError as e:
            e.report_to_logger(self.logger)

        if not check or not vm.done:
            # self.error = "Cannot do database minimization"
            self.logger.error(self.error)
            self.update_state(ERROR)
            self.info[DB_MINIMIZATION] = None
            return False, time_profile

        self.db_restorer.update_last_restored_size(vm.all_sizes)
        self.info[DB_MINIMIZATION] = vm.global_min_instance_dict
        self.global_min_instance_dict = copy.deepcopy(vm.global_min_instance_dict)

        '''
        Constant Filter Extraction
        '''
        self.update_state(FILTER + START)
        self.filter_extractor = Filter(self.connectionHelper, core_relations, self.global_min_instance_dict)
        self.update_state(FILTER + RUNNING)
        check = self.filter_extractor.doJob(query)
        self.update_state(FILTER + DONE)
        time_profile.update_for_where_clause(self.filter_extractor.local_elapsed_time,
                                             self.filter_extractor.app_calls)
        if not self.filter_extractor.done:
            self.update_state(ERROR)
            self.info[FILTER] = None
            self.error = check if check else self.error_string
            self.logger.error(self.error)
            return False, time_profile
        if not check:
            self.info[FILTER] = None
            self.logger.info("No filter found")
        self.info[FILTER] = self.filter_extractor.filter_predicates

        '''
        Equality Relations (Equi-join + Constant Equality filters) Extraction
        '''
        self.update_state(EQUALITY + START)
        self.update_state(EQUALITY + RUNNING)
        self.equi_join = U2EquiJoin(self.connectionHelper, core_relations, self.filter_extractor.filter_predicates,
                                    self.filter_extractor, self.global_min_instance_dict)
        check = self.equi_join.doJob(query)
        self.update_state(EQUALITY + DONE)
        time_profile.update_for_where_clause(self.equi_join.local_elapsed_time, self.equi_join.app_calls)
        if not self.equi_join.done:
            self.update_state(ERROR)
            self.info[EQUALITY] = None
            self.error = check if check else self.error_string
            self.logger.error(self.error)
            return False, time_profile
        if not check:
            self.info[EQUALITY] = None
            self.logger.info("No Equality predicate found")
        combined_eq_predicates = self.equi_join.algebraic_eq_predicates + self.equi_join.arithmetic_eq_predicates
        self.info[EQUALITY] = combined_eq_predicates

        '''
        AOA Extraction
        '''
        self.update_state(INEQUALITY + START)
        self.aoa = InequalityPredicate(self.connectionHelper, core_relations, self.equi_join.pending_predicates,
                                       self.equi_join.arithmetic_eq_predicates,
                                       self.equi_join.algebraic_eq_predicates, self.filter_extractor,
                                       self.global_min_instance_dict)
        self.update_state(INEQUALITY + RUNNING)
        check = self.aoa.doJob(query)
        self.update_state(INEQUALITY + DONE)
        time_profile.update_for_where_clause(self.aoa.local_elapsed_time, self.aoa.app_calls)
        self.info[INEQUALITY] = self.aoa.aoa_predicates + self.aoa.aoa_less_thans + self.aoa.arithmetic_ineq_predicates
        if not check:
            self.info[INEQUALITY] = None
            self.logger.info("Cannot find inequality Predicates.")
        if not self.aoa.done:
            self.info[INEQUALITY] = None
            self.error = check if check else self.error_string
            self.logger.error(self.error)
            self.update_state(ERROR)
            return False, time_profile
        return True, time_profile

    def __get_predicates_in_action(self):
        return self.aoa.arithmetic_filters

    @abstractmethod
    def process(self, query: str):
        raise NotImplementedError("Trouble!")

    @abstractmethod
    def doJob(self, query, qe=None):
        raise NotImplementedError("Trouble!")

    @abstractmethod
    def verify_correctness(self, query, result):
        raise NotImplementedError("Trouble!")

    def _extract_disjunction(self, init_predicates, core_relations, query, time_profile):  # for once
        # Initialize a list to store the final disjunction (OR-ed) predicates
        self.or_predicates = []

        # Create a deep copy of the initial predicates to work with (avoids mutating the input)
        curr_eq_predicates = copy.deepcopy(init_predicates)

        # Start with a list of one predicate group (can be extended during loop execution)
        all_eq_predicates = [curr_eq_predicates]

        # Create a list of indices corresponding to each initial predicate
        ids = list(range(len(curr_eq_predicates)))

        # Check if OR detection is enabled in the configuration
        if self.connectionHelper.config.detect_or:
            try:
                # Run the loop that attempts to extract disjunctions (modifies all_eq_predicates)
                time_profile = self.__run_extraction_loop(
                    all_eq_predicates, core_relations, ids, query, time_profile
                )
            except Exception as e:
                # If an error occurs during disjunction extraction, update internal state and log it
                self.update_state(ERROR)
                self.logger.error("Error in disjunction loop. ", str(e))
                return False, time_profile

        # Transpose the list of lists to group corresponding predicates across all disjunction paths
        self.or_predicates = list(zip(*all_eq_predicates))

        # Return success status and the updated time profile
        return True, time_profile

    def __run_extraction_loop(self, all_eq_predicates, core_relations, ids, query, time_profile):

        or_extractor = OrExtractor(self.connectionHelper, core_relations,
                                   self.global_min_instance_dict, all_eq_predicates)
        # Iterate through each predicate index
        for i in ids:
            # Collect the i-th predicate from each group in all_eq_predicates
            in_candidates = [copy.deepcopy(em[i]) for em in all_eq_predicates]
            self.logger.debug("Checking OR predicate of ", in_candidates)

            """
                New Disjunction Extraction Logic Goes here!!
            """

            or_extractor.doJob(query)

            all_eq_predicates.extend(or_extractor.filter_predicates)

        # Return the updated time profile after the loop finishes
        return time_profile

    @abstractmethod
    def extract(self, query):
        pass
