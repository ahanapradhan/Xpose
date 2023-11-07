import copy

from mysite.unmasque.refactored.equi_join import EquiJoin
from mysite.unmasque.refactored.util.common_queries import alter_table_rename_to, get_tabname_2, drop_view
from mysite.unmasque.src.core.QueryStringGenerator import generate_join_string


class MultipleEquiJoin(EquiJoin):

    def __init__(self, connectionHelper,
                 global_key_lists,
                 core_relations,
                 global_min_instance_dict):
        super().__init__(connectionHelper,
                         global_key_lists,
                         core_relations,
                         global_min_instance_dict)
        self.global_all_join_graphs = []
        self.intersection = False
        self.intersection_flag = False
        self.working = True
        self.tab_tuple_sig_dict = {}

    def is_intersection_present(self):
        if not self.intersection_flag:
            self.intersection = any(len(value) > 2 for value in self.global_min_instance_dict.values())
            self.intersection_flag = True
        return self.intersection

    def get_join_graph(self, query):
        super().get_join_graph(query)
        if self.is_intersection_present():
            self.get_multiple_join_graphs()
            return self.global_all_join_graphs
        else:
            return self.global_join_graph

    def get_multiple_join_graphs(self):
        self.restore_d_min_from_dict_data()
        self.init_join_graph_dict()
        self.get_matching_tuples()

        if self.working:
            return

    def do_traversal(self):
        for key_tab in self.tab_tuple_sig_dict.keys():
            te = self.tab_tuple_sig_dict[key_tab]

    def get_matching_tuples(self):
        for edge in self.global_join_graph:
            where_op = generate_join_string([edge])
            tabs = []
            ctids = []
            for e in edge:
                tab = self.find_tabname_for_given_attrib(e)
                tabs.append(tab)
                ctid = f"{tab}.ctid"
                ctids.append(ctid)
            from_op = ", ".join(tabs)
            select_op = ", ".join(ctids)
            ctid_query = f"select {select_op} from {from_op} where {where_op};"
            result_ctids, _ = self.connectionHelper.execute_sql_fetchall(ctid_query)
            result = result_ctids[0]
            for i in range(len(tabs) - 1):
                self.tab_tuple_sig_dict[tabs[i]][result[i]] = (edge[i], tabs[i + 1], result[i + 1], edge[i + 1])
            for i in range(len(tabs) - 1, 0, -1):
                self.tab_tuple_sig_dict[tabs[i]][result[i]] = (edge[i], tabs[i - 1], result[i - 1], edge[i - 1])

    def init_join_graph_dict(self):
        for key_tab in self.global_min_instance_dict:
            self.tab_tuple_sig_dict[key_tab] = {}  # each table entry is a dict
