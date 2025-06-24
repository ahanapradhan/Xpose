import copy
from typing import List

from mysite.unmasque.src.core.abstract.abstractConnection import AbstractConnectionHelper
from mysite.unmasque.src.core.filter import Filter


class OrExtractor(Filter):
    def __init__(self, connectionHelper: AbstractConnectionHelper,
                 core_relations: List[str],
                 global_min_instance_dict: dict,
                 init_predicates):
        super().__init__(connectionHelper, core_relations, global_min_instance_dict)
        # initially extracted predicates, in list form
        self.filter_predicates = copy.deepcopy(init_predicates)

    def doActualJob(self, args=None):
        """
        Write core logic of OR extraction
        Q_H is available from args
        """
        return self.filter_predicates  # update self.filter_predicate with the new predicates
