import copy
import csv
import os.path
import pathlib

from .ScaleDown import ScaleDown
from ...src.core.abstract.ExtractorBase import Base


class Initiator(Base):

    def extract_params_from_args(self, args):
        return args

    def __init__(self, connectionHelper):
        super().__init__(connectionHelper, "Initiator")
        # Ensure base_path is correctly set in the configuration
        base_path = connectionHelper.config.base_path
        if base_path is None:
            raise ValueError("base_path in configuration cannot be None")
        # Convert base_path to a Path object if it's not already one
        self.resource_path = pathlib.Path(base_path) if not isinstance(base_path, pathlib.Path) else base_path
        self.pkfk_file_path = (self.resource_path / connectionHelper.config.pkfk).resolve()
        self.schema = connectionHelper.config.schema
        self.global_key_lists = [[]]
        self.global_pk_dict = {}
        self.error = None
        self.downer = None

    def reset(self):
        self.global_key_lists = [[]]
        self.global_pk_dict = {}
        self.all_relations = []
        self.error = None

    def verify_support_files(self):
        check_pkfk = os.path.isfile(self.pkfk_file_path)
        if not check_pkfk:
            self.logger.error("Unmasque Error: \n Support File Not Accessible. ")
        return check_pkfk

    def __scale_down(self, args=None):
        self.downer = ScaleDown(self.connectionHelper, self.all_sizes, self.all_relations, self.global_key_lists)
        try:
            check = self.downer.doJob(args)
            self.all_sizes = copy.deepcopy(self.downer.sizes)
            if not check:
                self.logger.error("Scale down did not succeed! Try with larger retry factor..")
                return False
            return True
        except Exception as e:
            self.logger.error("Some error while Cs2 to scale down!!")
            return False

    def doActualJob(self, args=None):
        self.reset()
        check = self.verify_support_files()
        self.logger.info("support files verified..")
        if not check:
            return False
        all_pkfk = self.get_all_pkfk()
        self.__make_pkfk_complete_graph(all_pkfk)
        self.__do_refinement()
        self.logger.info("loaded pk-fk..", all_pkfk)
        self._create_working_schema()
        self.logger.info(f"Working schema set to {self.connectionHelper.config.schema}")
        if not self.connectionHelper.config.use_cs2 and not self.connectionHelper.config.scale_down:
            self.take_backup()
        self.__get_rows_in_tables()
        check = self.__scale_down(args)
        return check

    def __get_rows_in_tables(self):
        if not self.connectionHelper.config.table_sizes_dict.keys():
            self.get_all_sizes()
        else:
            self.all_sizes = self.connectionHelper.config.table_sizes_dict.copy()
            # for key, value in self.connectionHelper.config.table_sizes_dict:
            #     self.all_sizes[key] = value
        self.logger.debug(self.all_sizes)

    def __do_refinement(self):
        self.global_key_lists = [list(filter(lambda val: val[0] in self.all_relations, elt)) for elt in
                                 self.global_key_lists if elt and len(elt) > 1]

    def __make_pkfk_complete_graph(self, all_pkfk):
        all_relations = []
        temp = []
        for row in all_pkfk:
            if len(row) < 6:
                continue
            all_relations.append(row[0])
            if row[2].upper() == 'Y':
                self.global_pk_dict[row[0]] = self.global_pk_dict.get(row[0], '') + ("," if row[0] in temp else '') + \
                                              row[1]
                temp.append(row[0])
            found_flag = False
            for elt in self.global_key_lists:
                if (row[0], row[1]) in elt or (row[4], row[5]) in elt:
                    if (row[0], row[1]) not in elt and row[1]:
                        elt.append((row[0], row[1]))
                    if (row[4], row[5]) not in elt and row[4]:
                        elt.append((row[4], row[5]))
                    found_flag = True
                    break
            if found_flag:
                continue
            if row[0] and row[4]:
                self.global_key_lists.append([(row[0], row[1]), (row[4], row[5])])
            elif row[0]:
                self.global_key_lists.append([(row[0], row[1])])
        self.set_all_relations(list(set(all_relations)))
        self.all_relations.sort()
        self.logger.debug("all relations: ", self.all_relations)

    def get_all_pkfk(self):
        with open(self.pkfk_file_path, 'rt') as f:
            data = csv.reader(f)
            all_pkfk = list(data)[1:]
        return all_pkfk
