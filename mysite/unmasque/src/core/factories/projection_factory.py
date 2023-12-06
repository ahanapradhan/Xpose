from mysite.unmasque.refactored.projection import Projection
from mysite.unmasque.src.core.multiple_projections import ManyProjection


def prep_i_elem(tup, i, n):
    entry = []
    for x in range(i):
        entry.append([])
    entry.append([tup])
    for x in range(n - i - 1):
        entry.append([])
    return entry


def find_common_items2(input_list):
    total_len = len(input_list)
    if total_len <= 1:
        return input_list
    val_dict = {}
    for i in range(total_len):
        elm_i = input_list[i]
        for tup in elm_i:
            if tup[2] == '=' or tup[2] == 'equal':
                if tup[3] not in val_dict.keys():
                    val_dict[tup[3]] = prep_i_elem(tup, i, total_len)
                else:
                    elem_i_list = val_dict[tup[3]]
                    if len(elem_i_list) <= i:
                        elem_i_list.append([tup])
                    else:
                        val_dict[tup[3]][i].append(tup)

    key_to_remove = []
    for key in val_dict.keys():
        val = val_dict[key]
        for item in val:
            if not item and key not in key_to_remove:
                key_to_remove.append(key)
    print(key_to_remove)

    for key in key_to_remove:
        del val_dict[key]

    return val_dict


def find_common_items(lists):
    common_items = set(lists[0])
    print("common_items: ", common_items)

    for lst in lists[1:]:
        print("lst: ", lst)
        common_items.intersection_update(set(lst))
        print("common_items: ", common_items)

    return list(common_items)


class ProjectionFactory:
    def __init__(self, connectionHelper, subquery_data, global_join_graph,
                 core_relations,
                 d_min_instance_dict):
        self.connectionHelper = connectionHelper
        self.global_join_graph = global_join_graph
        self.core_relations = core_relations
        self.d_min_instance_dict = d_min_instance_dict
        self.subquery_data = subquery_data

    def find_attribs_to_check(self):
        predicates = []
        for subquery in self.subquery_data:
            predicates.append(frozenset(subquery.filter.filter_predicates))
        common_filters = find_common_items2(predicates)
        print(common_filters)
        return common_filters

    def doCreateJob(self):
        attribs_to_check = self.find_attribs_to_check()

        is_intersection = (len(self.subquery_data) > 1)

        if is_intersection:
            global_all_attribs, global_attrib_types, global_key_attributes = self.form_other_params()
            pj_ob = ManyProjection(self.connectionHelper,
                                   global_all_attribs, global_attrib_types, global_key_attributes,
                                   self.core_relations, self.global_join_graph,
                                   self.subquery_data, self.d_min_instance_dict,
                                   attribs_to_check)
        else:
            subquery = self.subquery_data[0]
            global_all_attribs = subquery.equi_join.global_all_attribs
            global_attrib_types = subquery.equi_join.global_attrib_types
            global_key_attributes = subquery.equi_join.global_key_attributes
            global_filter_predicates = subquery.filter.filter_predicates
            pj_ob = Projection(self.connectionHelper, global_attrib_types, self.core_relations,
                               global_filter_predicates, self.global_join_graph,
                               global_all_attribs, self.d_min_instance_dict,
                               global_key_attributes)

        return pj_ob

    def form_other_params(self):
        _global_all_attribs = set()
        _global_attrib_types = set()
        _global_key_attributes = set()

        for subquery in self.subquery_data:
            for attrib in subquery.equi_join.global_all_attribs:
                _global_all_attribs.add(frozenset(attrib))

            for attrib in subquery.equi_join.global_attrib_types:
                _global_attrib_types.add(attrib)

            for attrib in subquery.equi_join.global_key_attributes:
                _global_key_attributes.add(attrib)

        global_all_attribs = list(_global_all_attribs)
        global_attrib_types = list(_global_attrib_types)
        global_key_attributes = list(_global_key_attributes)

        return global_all_attribs, global_attrib_types, global_key_attributes
