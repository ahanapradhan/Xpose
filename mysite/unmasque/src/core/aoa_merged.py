import copy
from datetime import date
from typing import Union

from psycopg2._psycopg import Decimal

from mysite.unmasque.refactored.abstract.MutationPipeLineBase import MutationPipeLineBase
from mysite.unmasque.refactored.filter import Filter, get_constants_for
from mysite.unmasque.refactored.util.common_queries import update_tab_attrib_with_value
from mysite.unmasque.refactored.util.utils import get_min_and_max_val, get_format, get_val_plus_delta
from mysite.unmasque.src.core.QueryStringGenerator import handle_range_preds
from mysite.unmasque.src.core.dataclass.generation_pipeline_package import PackageForGenPipeline
from mysite.unmasque.src.util.ConnectionHelper import ConnectionHelper
from mysite.unmasque.src.util.aoa_utils import add_pred_for, get_min, get_max, get_attrib, get_tab, get_UB, get_LB, \
    get_delta, \
    merge_equivalent_paritions, get_all_two_combs, get_val_bound_for_chain, get_min_max_for_chain_bounds, \
    optimize_edge_set, create_adjacency_map_from_aoa_predicates, find_all_chains, \
    add_concrete_bounds_as_edge2, is_same_tab_attrib, get_op, get_all_two_combs2


def remove_item_from_list(item, item_list):
    try:
        item_list.remove(item)
    except ValueError:
        pass


def find_le_attribs_from_edge_set(attrib: tuple[str, str], edge_set: list) -> list:
    prev_lb_attrib = map(lambda x: x[0]
    if is_same_tab_attrib(x[1], attrib) and isinstance(x[0], tuple)
    else None, edge_set)
    prev_lb_list = list(filter(lambda lb: lb is not None, prev_lb_attrib))
    return prev_lb_list


def find_ge_attribs_from_edge_set(attrib: tuple[str, str], edge_set: list) -> list:
    prev_ub_attrib = map(lambda x: x[1]
    if is_same_tab_attrib(x[0], attrib) and isinstance(x[1], tuple)
    else None, edge_set)
    prev_ub_list = list(filter(lambda ub: ub is not None, prev_ub_attrib))
    return prev_ub_list


def add_item_to_list(item, item_list):
    if item not in item_list:
        item_list.append(item)


def remove_absorbed_Bs(E, absorbed_LBs, absorbed_UBs, col_sink, col_src):
    if col_src in absorbed_UBs.keys():
        remove_item_from_list((col_src, absorbed_UBs[col_src]), E)
    if col_sink in absorbed_LBs:
        remove_item_from_list((absorbed_LBs[col_sink], col_sink), E)


def get_all_indices(item, item_list):
    idx = []
    for i in range(len(item_list)):
        if item_list[i] == item:
            idx.append(i)
    return idx


def get_all_elements(item_list, idx_list):
    items = []
    for idx in idx_list:
        items.append(item_list[idx])
    return items


def find_transitive_concrete_upperBs(E, to_remove):
    if not len(E):
        return
    ls, us = zip(*E)
    us_dict = {}
    for u in us:
        if isinstance(u, tuple):
            continue
        if u not in us_dict.keys():
            us_dict[u] = 1
        else:
            us_dict[u] += 1
    for u in us_dict.keys():
        if us_dict[u] > 1:
            idx = get_all_indices(u, us)
            ls_elms = get_all_elements(ls, idx)
            pairs = get_all_two_combs2(ls_elms)
            for pair in pairs:
                lesser, greater = pair[0], pair[1]
                if (lesser, greater) in E:
                    to_remove.append((lesser, u))


def find_transitive_concrete_lowerBs(E, to_remove):
    if not len(E):
        return
    ls, us = zip(*E)
    ls_dict = {}
    for lm in ls:
        if isinstance(lm, tuple):
            continue
        if lm not in ls_dict.keys():
            ls_dict[lm] = 1
        else:
            ls_dict[lm] += 1
    for lm in ls_dict.keys():
        if ls_dict[lm] > 1:
            idx = get_all_indices(ls_dict[lm], ls)
            us_elms = get_all_elements(us, idx)
            pairs = get_all_two_combs2(us_elms)
            for pair in pairs:
                lesser, greater = pair[0], pair[1]
                if (lesser, greater) in E:
                    to_remove.append((ls_dict[lm], greater))


class AlgebraicPredicate1(MutationPipeLineBase):
    SUPPORTED_DATATYPES = ['int', 'date', 'numeric']

    def __init__(self, connectionHelper: ConnectionHelper, core_relations: list[str], global_min_instance_dict: dict):
        super().__init__(connectionHelper, core_relations, global_min_instance_dict, "AlgebraicPredicate")
        self.filter_extractor = Filter(self.connectionHelper, core_relations, global_min_instance_dict)

        self.get_datatype = self.filter_extractor.get_datatype  # method

        self.pipeline_delivery = None

        self.aoa_predicates = []
        self.arithmetic_eq_predicates = []
        self.algebraic_eq_predicates = []
        self.arithmetic_ineq_predicates = []
        self.aoa_less_thans = []
        self.global_min_instance_dict_bkp = copy.deepcopy(global_min_instance_dict)

        self.where_clause = ""

        self.join_graph = []
        self.filter_predicates = []

        self.constants_dict = {}

    def doActualJob(self, args):
        self.filter_extractor.mock = self.mock
        self.filter_extractor.mutate_dmin_with_val = self.mutate_dmin_with_val

        query = self.extract_params_from_args(args)
        self.init_constants()
        check = self.filter_extractor.doJob(query)
        if not check:
            return False
        self.filter_extractor.logger.debug("Filters: ", self.filter_extractor.filter_predicates)
        partition_eq_dict, ineqaoa_preds = self.algo2_preprocessing()

        self.algo3_find_eq_joinGraph(query, partition_eq_dict, ineqaoa_preds)

        edge_set_dict = self.algo4_create_edgeSet_E(ineqaoa_preds)
        print("edge_set_dict:", edge_set_dict)

        for datatype in edge_set_dict.keys():
            E, L = self.algo7_find_aoa(edge_set_dict, datatype, query)
            print("E: ", E)
            print("L: ", L)
            self.aoa_predicates.extend(E)
            self.aoa_less_thans.extend(L)

        self.cleanup_predicates()
        self.generate_where_clause()
        self.post_process_for_generation_pipeline()
        return True

    def cleanup_predicates(self):
        self.optimize_edge_set(self.aoa_predicates)
        self.remove_redundant_concrete_bounds(self.aoa_predicates, self.aoa_less_thans)
        # self.remove_absorbed_arithmetic_eqs()

    def optimize_edge_set(self, edge_set):
        to_remove = []
        for aoa in edge_set:
            if not isinstance(aoa[0], tuple) and isinstance(aoa[1], tuple):
                check_eq_tuple = (aoa[1][0], aoa[1][1], "=", aoa[0], aoa[0])
                if check_eq_tuple in self.arithmetic_eq_predicates:
                    to_remove.append(aoa)
            elif isinstance(aoa[0], tuple) and not isinstance(aoa[1], tuple):
                check_eq_tuple = (aoa[0][0], aoa[0][1], "=", aoa[1], aoa[1])
                if check_eq_tuple in self.arithmetic_eq_predicates:
                    to_remove.append(aoa)

        eq_set = set()
        for aoa in edge_set:
            if not isinstance(aoa[0], tuple) and isinstance(aoa[1], tuple) and (aoa[1], aoa[0]) in edge_set:
                to_remove.append(aoa)
                to_remove.append((aoa[1], aoa[0]))
                eq_set.add((aoa[1][0], aoa[1][1], "=", aoa[0], aoa[0]))

        for t_r in to_remove:
            remove_item_from_list(t_r, edge_set)
        for e in eq_set:
            add_item_to_list(e, self.arithmetic_eq_predicates)

    def algo7_find_aoa(self, edge_set_dict: dict, datatype: str, query: str) -> tuple[list, list]:
        edge_set = edge_set_dict[datatype]
        # self.optimize_edge_set(edge_set)
        E, L, absorbed_UBs, absorbed_LBs = edge_set, [], {}, {}
        directed_paths = find_all_chains(create_adjacency_map_from_aoa_predicates(E))
        for path in directed_paths:
            for i in range(len(path)):
                col_src = path[i]
                col_sink = path[i + 1] if i + 1 < len(path) else None
                if col_sink is not None:
                    self.absorb_variable_LBs(E, L, absorbed_LBs, datatype, col_src, col_sink, query)
                    self.absorb_variable_UBs(E, L, absorbed_UBs, col_sink, col_src, datatype, query)
                    remove_absorbed_Bs(E, absorbed_LBs, absorbed_UBs, col_sink, col_src)
                self.extract_dormant_LBs(E, absorbed_LBs, col_src, datatype, query, L)
            self.remove_redundant_concrete_bounds(E, L)

        self.revert_mutation_on_filter_global_min_instance_dict()
        self.extract_dormant_UBs(E, absorbed_UBs, datatype, directed_paths, query, L)
        self.remove_redundant_concrete_bounds(E, L)
        self.revert_mutation_on_filter_global_min_instance_dict()

        self.optimize_arithmetic_eqs(absorbed_LBs, absorbed_UBs)
        return E, L

    def optimize_arithmetic_eqs(self, absorbed_LBs, absorbed_UBs):
        to_remove = []
        for eq in self.arithmetic_eq_predicates:
            tab, attrib, val = get_tab(eq), get_attrib(eq), eq[-1]
            if (tab, attrib) in absorbed_LBs and absorbed_LBs[(tab, attrib)] == val \
                    and (tab, attrib) in absorbed_UBs and absorbed_UBs[(tab, attrib)] == val:
                to_remove.append(eq)
        for t_r in to_remove:
            self.arithmetic_eq_predicates.remove(t_r)

    def remove_redundant_concrete_bounds(self, E, L):
        to_remove = []
        find_transitive_concrete_upperBs(E, to_remove)
        find_transitive_concrete_lowerBs(E, to_remove)

        for aoa in E:
            if not isinstance(aoa[0], tuple):
                if aoa[0] == self.what_is_possible_min_val(E, L, aoa[1], self.get_datatype(aoa[1])):
                    to_remove.append(aoa)
                if aoa[0] == get_min(self.constants_dict[self.get_datatype(aoa[1])]):
                    to_remove.append(aoa)
            if not isinstance(aoa[1], tuple):
                if aoa[1] == self.what_is_possible_max_val(E, L, aoa[0], self.get_datatype(aoa[0])):
                    to_remove.append(aoa)
                if aoa[1] == get_max(self.constants_dict[self.get_datatype(aoa[0])]):
                    to_remove.append(aoa)
        for t_r in to_remove:
            remove_item_from_list(t_r, E)

    def find_concrete_lb_from_edge_set(self, attrib, edge_set, datatype):
        prev_lb = None
        prev_lb_attrib = map(lambda x: x[0]
        if is_same_tab_attrib(x[1], attrib) and not isinstance(x[0], tuple)
        else None, edge_set)
        prev_lb_list = list(filter(lambda lb: lb is not None, prev_lb_attrib))
        if len(prev_lb_list):
            prev_lb = prev_lb_list[0]  # only one concrete lb possible
        if prev_lb is None:
            col_ps = find_le_attribs_from_edge_set(attrib, edge_set)
            for col_p in col_ps:
                prev_lb = self.get_dmin_val(get_attrib(col_p), get_tab(col_p))
        if prev_lb is None:
            prev_lb = get_min(self.constants_dict[datatype])
        return prev_lb

    def find_concrete_ub_from_edge_set(self, attrib, edge_set, datatype):
        prev_ub = None
        prev_ub_attrib = map(lambda x: x[1]
        if is_same_tab_attrib(x[0], attrib) and not isinstance(x[1], tuple)
        else None, edge_set)
        prev_ub_list = list(filter(lambda ub: ub is not None, prev_ub_attrib))
        if len(prev_ub_list):
            prev_ub = prev_ub_list[0]  # only one concrete ub possible
        if prev_ub is None:
            col_ps = find_ge_attribs_from_edge_set(attrib, edge_set)
            for col_p in col_ps:
                prev_ub = self.get_dmin_val(get_attrib(col_p), get_tab(col_p))
        if prev_ub is None:
            prev_ub = get_max(self.constants_dict[datatype])
        return prev_ub

    def absorb_variable_UBs(self, E, L, absorbed_UBs, col_sink, col_src, datatype, query):
        prev_ub = self.find_concrete_ub_from_edge_set(col_src, E, datatype)
        col_sink_lb = self.find_concrete_lb_from_edge_set(col_sink, E, datatype)
        val, dmin_val = self.mutate_attrib_with_Bound_val(col_sink, datatype, col_sink_lb, False)
        # self.global_min_instance_dict = copy.deepcopy(self.filter_extractor.global_min_instance_dict)
        new_ub_fe = self.do_bound_check_again(col_src, datatype, query)
        new_ub = get_UB(new_ub_fe[0]) if len(new_ub_fe) else get_max(self.constants_dict[datatype])
        if prev_ub != new_ub:
            absorbed_UBs[col_src] = prev_ub
            if new_ub < val:
                remove_item_from_list((col_src, col_sink), E)
                add_item_to_list((col_src, col_sink), L)
        else:
            remove_item_from_list((col_src, col_sink), E)
        self.mutate_dmin_with_val(datatype, col_sink, dmin_val)

    def absorb_variable_LBs(self, E, L, absorbed_LBs, datatype, col_src, col_sink, query) -> None:
        prev_lb = self.find_concrete_lb_from_edge_set(col_sink, E, datatype)
        col_src_ub = self.find_concrete_ub_from_edge_set(col_src, E, datatype)
        val, dmin_val = self.mutate_attrib_with_Bound_val(col_src, datatype, col_src_ub, True)
        # self.filter_extractor.global_min_instance_dict = copy.deepcopy(self.global_min_instance_dict)
        new_lb_fe = self.do_bound_check_again(col_sink, datatype, query)
        new_lb = get_LB(new_lb_fe[0]) if len(new_lb_fe) else get_min(self.constants_dict[datatype])
        if prev_lb != new_lb:
            absorbed_LBs[col_sink] = prev_lb
            if new_lb > val:
                remove_item_from_list((col_src, col_sink), E)
                add_item_to_list((col_src, col_sink), L)
        else:
            remove_item_from_list((col_src, col_sink), E)
        mutation_lb_fe = self.do_bound_check_again(col_src, datatype, query)
        mutation_lb = get_LB(mutation_lb_fe[0]) if len(mutation_lb_fe) else get_min(self.constants_dict[datatype])
        self.mutate_dmin_with_val(datatype, col_src, mutation_lb)

        new_edges = [(col_src, get_UB(mutation_lb_fe[0]))]
        col_sink_fe = self.do_bound_check_again(col_sink, datatype, query)
        col_sink_lb = get_LB(col_sink_fe[0]) if len(col_sink_fe) else get_min(self.constants_dict[datatype])
        col_sink_ub = get_UB(col_sink_fe[0]) if len(col_sink_fe) else get_max(self.constants_dict[datatype])
        new_edges.extend([(col_sink_lb, col_sink), (col_sink, col_sink_ub)])
        to_remove = []
        for edge in E:
            if isinstance(edge[0], tuple) and not isinstance(edge[1], tuple):
                if edge[0] in [col_src, col_sink]:
                    to_remove.append(edge)
            if not isinstance(edge[0], tuple) and isinstance(edge[1], tuple):
                if edge[1] == col_sink:
                    to_remove.append(edge)
        for t_r in to_remove:
            remove_item_from_list(t_r, E)
        E.extend(new_edges)

    def extract_dormant_LBs(self, E, absorbed_LBs, col_src, datatype, query, L):
        lb_dot = self.mutate_with_boundary_value(absorbed_LBs, E, datatype, query, col_src, False)
        min_val = self.what_is_possible_min_val(E, L, col_src, datatype)
        if lb_dot != min_val:
            add_item_to_list((lb_dot, col_src), E)

    def what_is_possible_min_val(self, E, L, col_src, datatype):
        min_val = None
        col_prev_list = find_le_attribs_from_edge_set(col_src, E)
        if len(col_prev_list):
            col_prev = col_prev_list[0]
            # min_val = self.get_dmin_val(get_attrib(col_prev), get_tab(col_prev))
            min_val = self.what_is_possible_min_val(E, L, col_prev, datatype)
        else:
            col_prev_list = find_le_attribs_from_edge_set(col_src, L)
            if len(col_prev_list):
                col_prev = col_prev_list[0]
                # dmin_col_prev = self.get_dmin_val(get_attrib(col_prev), get_tab(col_prev))
                dmin_col_prev = self.what_is_possible_min_val(E, L, col_prev, datatype)
                min_val = get_val_plus_delta(datatype, dmin_col_prev, 1 * get_delta(self.constants_dict[datatype]))
        if min_val is None:
            min_val = get_min(self.constants_dict[datatype])
        return min_val

    def what_is_possible_max_val(self, E, L, col_src, datatype):
        max_val = None
        col_next_list = find_ge_attribs_from_edge_set(col_src, E)
        if len(col_next_list):
            col_next = col_next_list[0]
            # max_val = self.get_dmin_val(get_attrib(col_next), get_tab(col_next))
            max_val = self.what_is_possible_max_val(E, L, col_next, datatype)
        else:
            col_next_list = find_ge_attribs_from_edge_set(col_src, L)
            if len(col_next_list):
                col_next = col_next_list[0]
                dmin_col_next = self.what_is_possible_max_val(E, L, col_next, datatype)  # self.get_dmin_val(
                # get_attrib(col_next), get_tab(col_next))
                max_val = get_val_plus_delta(datatype, dmin_col_next, -1 * get_delta(self.constants_dict[datatype]))
        if max_val is None:
            max_val = get_max(self.constants_dict[datatype])
        return max_val

    def extract_dormant_UBs(self, E, absorbed_UBs, datatype, directed_paths, query, L):
        for path in directed_paths:
            for i in reversed(range(len(path))):
                col_i = path[i]
                ub_dot = self.mutate_with_boundary_value(absorbed_UBs, E, datatype, query, col_i, True)
                max_val = self.what_is_possible_max_val(E, L, col_i, datatype)
                if ub_dot != max_val:
                    add_item_to_list((col_i, ub_dot), E)

    def algo4_create_edgeSet_E(self, ineqaoa_preds: list) -> dict:
        filtered_dict = self.isolate_ineq_aoa_preds_per_datatype(ineqaoa_preds)
        edge_set_dict = {}
        for datatype in filtered_dict:
            edge_set = []
            ineq_group = filtered_dict[datatype]
            self.create_dashed_edges(ineq_group, edge_set)
            optimize_edge_set(edge_set)
            add_concrete_bounds_as_edge2(ineq_group, edge_set)
            edge_set_dict[datatype] = edge_set
        return edge_set_dict

    def init_constants(self) -> None:
        for datatype in self.SUPPORTED_DATATYPES:
            i_min, i_max = get_min_and_max_val(datatype)
            delta, _ = get_constants_for(datatype)
            self.constants_dict[datatype] = (i_min, i_max, delta)

    def post_process_for_generation_pipeline(self) -> None:
        self.global_min_instance_dict = copy.deepcopy(self.global_min_instance_dict_bkp)
        self.restore_d_min_from_dict()
        self.pipeline_delivery = PackageForGenPipeline(self.core_relations,
                                                       self.filter_extractor.global_all_attribs,
                                                       self.filter_extractor.global_attrib_types,
                                                       self.filter_predicates,
                                                       self.aoa_predicates,
                                                       self.join_graph,
                                                       self.aoa_less_thans,
                                                       self.global_min_instance_dict,
                                                       self.get_dmin_val,
                                                       self.get_datatype)
        self.pipeline_delivery.doJob()

    def generate_where_clause(self) -> None:
        predicates = []
        for eq_join in self.algebraic_eq_predicates:
            join_edge = list(item[1] for item in eq_join if len(item) == 2)
            join_edge.sort()
            for i in range(0, len(join_edge) - 1):
                join_e = f"{join_edge[i]} = {join_edge[i + 1]}"
                predicates.append(join_e)
                self.join_graph.append([join_edge[i], join_edge[i + 1]])
        for a_eq in self.arithmetic_eq_predicates:
            datatype = self.get_datatype((get_tab(a_eq), get_attrib(a_eq)))
            pred = f"{get_attrib(a_eq)} = {get_format(datatype, get_LB(a_eq))}"
            predicates.append(pred)
            self.filter_predicates.append(a_eq)
        for a_ineq in self.arithmetic_ineq_predicates:
            datatype = self.get_datatype((get_tab(a_ineq), get_attrib(a_ineq)))
            pred_op = get_attrib(a_ineq) + " "
            if datatype == 'str':
                pred_op += f"LIKE {get_format(datatype, a_ineq[3])}"
            else:
                pred_op = handle_range_preds(datatype, a_ineq, pred_op)
            predicates.append(pred_op)
            self.filter_predicates.append(a_ineq)
        for aoa in self.aoa_predicates:
            pred = []
            add_pred_for(aoa[0], pred)
            add_pred_for(aoa[1], pred)
            predicates.append(" <= ".join(pred))
        for aoa in self.aoa_less_thans:
            pred = []
            add_pred_for(aoa[0], pred)
            add_pred_for(aoa[1], pred)
            predicates.append(" < ".join(pred))

        self.where_clause = "\n and ".join(predicates)

    def get_equi_join_group(self, tab_attrib: tuple[str, str]) -> list[tuple[str, str]]:
        for eq in self.algebraic_eq_predicates:
            if tab_attrib in eq:
                return eq
        return [tab_attrib]

    def mutate_with_boundary_value(self, a_Bs, edge_set, datatype, query, tab_attrib, is_UB) -> Union[
        int, Decimal, date]:
        filter_attribs = []
        joined_tab_attrib = self.get_equi_join_group(tab_attrib)

        min_val, max_val = get_min_max_for_chain_bounds(get_min(self.constants_dict[datatype]),
                                                        get_max(self.constants_dict[datatype]),
                                                        tab_attrib, a_Bs, is_UB)
        prep = self.filter_extractor.prepare_attrib_set_for_bulk_mutation(joined_tab_attrib)
        self.filter_extractor.handle_filter_for_nonTextTypes(prep, datatype, filter_attribs, max_val, min_val,
                                                             query)
        val = get_val_bound_for_chain(get_min(self.constants_dict[datatype]),
                                      get_max(self.constants_dict[datatype]),
                                      filter_attribs, is_UB)

        if val is None:
            for key in joined_tab_attrib:
                val = self.find_concrete_ub_from_edge_set(key, edge_set, datatype) if is_UB \
                    else self.find_concrete_lb_from_edge_set(key, edge_set, datatype)

        for key in joined_tab_attrib:
            tab, attrib = get_tab(key), get_attrib(key)
            self.mutate_dmin_with_val(self.get_datatype((tab, attrib)), (tab, attrib), val)
        return val

    def mutate_filter_global_min_instance_dict(self, tab: str, attrib: str, val) -> None:
        g_min_dict = self.filter_extractor.global_min_instance_dict
        data = g_min_dict[tab]
        idx = data[0].index(attrib)
        new_data = []
        for i in range(0, len(data[1])):
            if idx == i:
                new_data.append(val)
            else:
                new_data.append(data[1][i])
        data[1] = tuple(new_data)

    def revert_mutation_on_filter_global_min_instance_dict(self) -> None:
        self.filter_extractor.global_min_instance_dict = copy.deepcopy(self.global_min_instance_dict)

    def restore_d_min_from_dict(self) -> None:
        for tab in self.core_relations:
            values = self.global_min_instance_dict[tab]
            attribs, vals = values[0], values[1]
            for i in range(len(attribs)):
                attrib, val = attribs[i], vals[i]
                self.mutate_dmin_with_val(self.get_datatype((tab, attrib)), (tab, attrib), val)

    def do_bound_check_again(self, tab_attrib: tuple[str, str], datatype: str, query: str) -> list:
        filter_attribs = []
        d_plus_value = copy.deepcopy(self.filter_extractor.global_d_plus_value)
        attrib_max_length = copy.deepcopy(self.filter_extractor.global_attrib_max_length)
        joined_attribs = self.get_equi_join_group(tab_attrib)
        candidates = []
        for attrib in joined_attribs:
            if len(attrib) == 5:
                continue
            one_attrib = (get_tab(attrib), get_attrib(attrib), attrib_max_length, d_plus_value)
            candidates.append(one_attrib)
        self.filter_extractor.extract_filter_on_attrib_set(filter_attribs, query, candidates, datatype)
        return filter_attribs

    def is_dmin_val_leq_LB(self, myself, other) -> bool:
        val = self.get_dmin_val(get_attrib(myself), get_tab(myself))
        satisfied = self.do_numeric_drama(get_LB(other), get_UB(myself), get_attrib(myself), get_tab(myself), val)
        return satisfied

    def do_numeric_drama(self, other_LB, my_UB, attrib, tab, my_val) -> bool:
        datatype = self.get_datatype((tab, attrib))
        satisfied = my_val <= other_LB  # <= _oB
        # all the following DRAMA is to handle "numeric" datatype
        if datatype == 'numeric':
            bck_diff_1 = float(my_val) - other_LB
            # bck_diff_2 = _B - _oB
            alt_sat = True
            if not satisfied:
                if bck_diff_1 > 0:
                    alt_sat = alt_sat & (abs(bck_diff_1) <= get_delta(self.constants_dict[datatype]))
                # if bck_diff_2 > 0:
                #    alt_sat = alt_sat & (abs(bck_diff_2) <= delta)
            return alt_sat or satisfied
        return satisfied

    def create_dashed_edges(self, ineq_group, edge_set) -> None:
        seq = get_all_two_combs(ineq_group)
        for e in seq:
            one, two = e[0], e[1]
            self.create_dashed_edge_from_oneTotwo(edge_set, one, two)
            self.create_dashed_edge_from_oneTotwo(edge_set, two, one)

    def create_dashed_edge_from_oneTotwo(self, edge_set, one, two) -> None:
        tab_attrib = (get_tab(one), get_attrib(one))
        next_tab_attrib = (get_tab(two), get_attrib(two))
        check = self.is_dmin_val_leq_LB(two, one)
        if check:
            edge_set.append(tuple([next_tab_attrib, tab_attrib]))

    def isolate_ineq_aoa_preds_per_datatype(self,
                                            ineqaoa_preds: list[tuple[str, str, str,
                                            Union[int, date, Decimal],
                                            Union[int, date, Decimal]]]) -> dict:
        datatype_dict = {}
        for a_eq in self.arithmetic_eq_predicates:
            datatype = self.get_datatype((get_tab(a_eq), get_attrib(a_eq)))
            if datatype != 'str':
                new_tup = (get_tab(a_eq), get_attrib(a_eq), 'range', get_LB(a_eq), get_UB(a_eq))
                ineqaoa_preds.append(new_tup)
                # self.new_tups.append(new_tup)
                # to-do
                # : later have to remove from arithmetic if ineq absorbs them

        for pred in ineqaoa_preds:
            tab_attrib = (pred[0], pred[1])
            datatype = self.get_datatype(tab_attrib)
            if datatype in datatype_dict.keys():
                datatype_dict[datatype].append(pred)
            else:
                datatype_dict[datatype] = [pred]
        filtered_dict = {key: value for key, value in datatype_dict.items() if key != 'str' and len(value) > 1}
        for key in datatype_dict:
            if len(datatype_dict[key]) == 1:
                self.arithmetic_ineq_predicates.extend(datatype_dict[key])
        return filtered_dict

    def algo3_find_eq_joinGraph(self, query: str, partition_eq_dict: dict, ineqaoa_preds: list) -> None:
        # self.logger.debug(partition_eq_dict)
        while partition_eq_dict:
            check_again_dict = {}
            for key in partition_eq_dict.keys():
                equi_join_group = partition_eq_dict[key]
                if len(equi_join_group) <= 3:
                    self.handle_unit_eq_group(equi_join_group, query)
                else:
                    done = self.handle_higher_eq_groups(equi_join_group, query)
                    remaining_group = [eq for eq in equi_join_group if eq not in done]
                    check_again_dict[key] = remaining_group
            partition_eq_dict = check_again_dict
        # self.logger.debug(self.algebraic_eq_predicates)
        for eq_join in self.algebraic_eq_predicates:
            for pred in eq_join:
                if len(pred) == 5:
                    ineqaoa_preds.append(pred)

    def handle_unit_eq_group(self, equi_join_group, query) -> bool:
        filter_attribs = []
        datatype = self.get_datatype(equi_join_group[0])
        prepared_attrib_list = self.filter_extractor.prepare_attrib_set_for_bulk_mutation(equi_join_group)
        self.filter_extractor.extract_filter_on_attrib_set(filter_attribs, query, prepared_attrib_list,
                                                           datatype)
        if len(filter_attribs) > 0:
            if get_op(filter_attribs[0]) in ['=', 'equal']:
                return False
            equi_join_group.extend(filter_attribs)
        self.algebraic_eq_predicates.append(equi_join_group)
        return True

    def algo2_preprocessing(self) -> tuple[dict, list]:
        eq_groups_dict = {}
        ineq_filter_predicates = []
        for pred in self.filter_extractor.filter_predicates:
            if get_op(pred) in ['=', 'equal']:
                dict_key = pred[3]
                if dict_key in eq_groups_dict:
                    eq_groups_dict[dict_key].append((pred[0], pred[1]))
                else:
                    eq_groups_dict[dict_key] = [(pred[0], pred[1])]
            else:
                ineq_filter_predicates.append(pred)

        for key in eq_groups_dict.keys():
            if len(eq_groups_dict[key]) == 1:
                op = 'equal' if isinstance(key, str) else '='
                self.arithmetic_eq_predicates.append((get_tab(eq_groups_dict[key][0]),
                                                      get_attrib(eq_groups_dict[key][0]), op, key, key))
        eqJoin_group_dict = {key: value for key, value in eq_groups_dict.items() if len(value) > 1}
        return eqJoin_group_dict, ineq_filter_predicates

    def handle_higher_eq_groups(self, equi_join_group, query):
        seq = list(range(len(equi_join_group)))
        t_all_paritions = merge_equivalent_paritions(seq)
        done = None
        for part in t_all_paritions:
            check_part = min(part, key=len)
            attrib_list = []
            for i in check_part:
                attrib_list.append(equi_join_group[i])
            check = self.handle_unit_eq_group(attrib_list, query)
            if check:
                done = attrib_list
                break
        return done

    def mutate_attrib_with_Bound_val(self, tab_attrib: tuple[str, str],
                                     datatype: str,
                                     val: any, with_UB: bool) \
            -> tuple[Union[int, Decimal, date], Union[int, Decimal, date]]:
        dmin_val = self.get_dmin_val(get_attrib(tab_attrib), get_tab(tab_attrib))
        factor = -1 if with_UB else 1
        if dmin_val == val:
            val = get_val_plus_delta(datatype, val, factor * get_delta(self.constants_dict[datatype]))
        joined_tab_attribs = self.get_equi_join_group(tab_attrib)
        for t_a in joined_tab_attribs:
            self.mutate_dmin_with_val(datatype, t_a, val)
        return val, dmin_val

    def mutate_dmin_with_val(self, datatype, t_a, val):
        self.connectionHelper.execute_sql([update_tab_attrib_with_value(get_attrib(t_a),
                                                                        get_tab(t_a),
                                                                        get_format(datatype, val))])
        self.mutate_filter_global_min_instance_dict(get_tab(t_a),
                                                    get_attrib(t_a), val)
        self.filter_extractor.global_d_plus_value[get_attrib(t_a)] = val

    def remove_absorbed_arithmetic_eqs(self):
        to_remove = []
        for eq in self.arithmetic_eq_predicates:
            tab, attrib = eq[0], eq[1]
            val = eq[-1]
            for aoa in self.aoa_predicates:
                if aoa[0] == tab and aoa[1] == attrib and aoa[-1] == val:
                    to_remove.append(aoa)
        for t_r in to_remove:
            self.aoa_predicates.remove(t_r)
