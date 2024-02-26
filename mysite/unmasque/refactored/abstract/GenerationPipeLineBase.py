import ast
import copy
from datetime import date
from typing import Union

from .MutationPipeLineBase import MutationPipeLineBase
from ..util.common_queries import insert_into_tab_attribs_format, update_tab_attrib_with_value, \
    update_tab_attrib_with_quoted_value
from ...refactored.util.utils import get_escape_string, get_dummy_val_for, get_format, get_char, get_unused_dummy_val
from ...src.core.dataclass.generation_pipeline_package import PackageForGenPipeline
from ...src.util.ConnectionHelper import ConnectionHelper

NUMBER_TYPES = ['int', 'integer', 'numeric', 'float']


class GenerationPipeLineBase(MutationPipeLineBase):

    def __init__(self, connectionHelper: ConnectionHelper, name: str, delivery: PackageForGenPipeline):
        super().__init__(connectionHelper, delivery.core_relations, delivery.global_min_instance_dict, name)
        self.global_all_attribs = delivery.global_all_attribs
        self.global_attrib_types = delivery.global_attrib_types
        self.global_join_graph = delivery.global_join_graph
        self.global_filter_predicates = delivery.global_filter_predicates
        self.filter_attrib_dict = delivery.filter_attrib_dict
        self.attrib_types_dict = delivery.attrib_types_dict
        self.joined_attribs = delivery.joined_attribs

        self.get_datatype = delivery.get_datatype  # method

    def extract_params_from_args(self, args):
        return args[0]

    def doActualJob(self, args) -> bool:
        query = self.extract_params_from_args(args)
        self.do_init()
        check = self.doExtractJob(query)
        return check

    def restore_d_min_from_dict(self) -> None:
        for tab in self.core_relations:
            values = self.global_min_instance_dict[tab]
            attribs, vals = values[0], values[1]
            for i in range(len(attribs)):
                attrib, val = attribs[i], vals[i]
                self.update_with_val(attrib, tab, val)

    def do_init(self) -> None:
        self.restore_d_min_from_dict()
        self.see_d_min()

    def get_s_val_for_textType(self, attrib_inner, tabname_inner) -> str:
        filtered_val = self.filter_attrib_dict[(tabname_inner, attrib_inner)]
        if isinstance(filtered_val, tuple):
            filtered_val = filtered_val[0]
        return filtered_val

    def insert_attrib_vals_into_table(self, att_order, attrib_list_inner, insert_rows, tabname_inner) -> None:
        esc_string = get_escape_string(attrib_list_inner)
        insert_query = insert_into_tab_attribs_format(att_order, esc_string, tabname_inner)
        self.connectionHelper.execute_sql_with_params(insert_query, insert_rows)

    def update_attrib_in_table(self, attrib, value, tabname) -> None:
        update_query = update_tab_attrib_with_value(attrib, tabname, value)
        self.connectionHelper.execute_sql([update_query])

    def doExtractJob(self, query: str) -> bool:
        return True

    def get_other_attribs_in_eqJoin_grp(self, attrib: str) -> list:
        other_attribs = []
        for join_edge in self.global_join_graph:
            if attrib in join_edge:
                other_attribs = copy.deepcopy(join_edge)
                other_attribs.remove(attrib)
                break
        return other_attribs

    def update_attribs_bulk(self, join_tabnames, other_attribs, val) -> None:
        for other_attrib in other_attribs:
            join_tabname = self.find_tabname_for_given_attrib(other_attrib)
            join_tabnames.append(join_tabname)
            self.update_with_val(other_attrib, join_tabname, val)

    def update_attrib_to_see_impact(self, attrib: str, tabname: str) \
            -> tuple[Union[int, float, date, str], Union[int, float, date, str]]:
        prev = self.connectionHelper.execute_sql_fetchone_0(f"SELECT {attrib} FROM {tabname};")
        val = self.get_different_s_val(attrib, tabname, prev)
        self.logger.debug("update ", tabname, attrib, "with value ", val, " prev", prev)
        self.update_with_val(attrib, tabname, val)
        return val, prev

    def update_with_val(self, attrib: str, tabname: str, val) -> None:
        datatype = self.get_datatype((tabname, attrib))
        if datatype == 'date' or datatype in NUMBER_TYPES:
            update_q = update_tab_attrib_with_value(attrib, tabname, get_format(datatype, val))
        else:
            update_q = update_tab_attrib_with_quoted_value(tabname, attrib, val)
        self.connectionHelper.execute_sql([update_q])

    def get_s_val(self, attrib: str, tabname: str) -> Union[int, float, date, str]:
        datatype = self.get_datatype((tabname, attrib))
        if datatype == 'date':
            if (tabname, attrib) in self.filter_attrib_dict.keys():
                val = min(self.filter_attrib_dict[(tabname, attrib)][0],
                          self.filter_attrib_dict[(tabname, attrib)][1])
            else:
                val = get_dummy_val_for(datatype)
            val = ast.literal_eval(get_format(datatype, val))

        elif datatype in NUMBER_TYPES:
            # check for filter (#MORE PRECISION CAN BE ADDED FOR NUMERIC#)
            if (tabname, attrib) in self.filter_attrib_dict.keys():
                val = min(self.filter_attrib_dict[(tabname, attrib)][0],
                          self.filter_attrib_dict[(tabname, attrib)][1])
            else:
                val = get_dummy_val_for(datatype)
        else:
            if (tabname, attrib) in self.filter_attrib_dict.keys():
                val = self.get_s_val_for_textType(attrib, tabname)
                self.logger.debug(val)
                val = val.replace('%', '')
            else:
                val = get_char(get_dummy_val_for('char'))
        return val

    def get_different_val_for_dmin(self, attrib: str, tabname: str, prev) -> Union[int, float, date, str]:
        if prev == self.filter_attrib_dict[(tabname, attrib)][0]:
            val = self.filter_attrib_dict[(tabname, attrib)][1]
        elif prev == self.filter_attrib_dict[(tabname, attrib)][1]:
            val = self.filter_attrib_dict[(tabname, attrib)][0]
        else:
            val = min(self.filter_attrib_dict[(tabname, attrib)][0],
                      self.filter_attrib_dict[(tabname, attrib)][1])
        return val

    def get_different_s_val(self, attrib: str, tabname: str, prev) -> Union[int, float, date, str]:
        datatype = self.get_datatype((tabname, attrib))
        if datatype == 'date':
            if (tabname, attrib) in self.filter_attrib_dict.keys():
                val = self.get_different_val_for_dmin(attrib, tabname, prev)
            else:
                val = get_unused_dummy_val(datatype, [prev])
            val = ast.literal_eval(get_format(datatype, val))

        elif datatype in NUMBER_TYPES:
            # check for filter (#MORE PRECISION CAN BE ADDED FOR NUMERIC#)
            if (tabname, attrib) in self.filter_attrib_dict.keys():
                val = self.get_different_val_for_dmin(attrib, tabname, prev)
            else:
                val = get_unused_dummy_val(datatype, [prev])
        else:
            if (tabname, attrib) in self.filter_attrib_dict.keys():
                val = self.get_s_val_for_textType(attrib, tabname)
                self.logger.debug(val)
                val = val.replace('%', '')
            else:
                val = get_char(get_unused_dummy_val('char', [prev]))
        return val

    def find_tabname_for_given_attrib(self, find_attrib) -> str:
        for entry in self.global_attrib_types:
            tabname = entry[0]
            attrib = entry[1]
            if attrib == find_attrib:
                return tabname
