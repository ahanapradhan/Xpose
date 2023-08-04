import unittest

from mysite.unmasque.refactored.ConnectionHelper import ConnectionHelper
from mysite.unmasque.src.core import UnionPipeLine
from mysite.unmasque.test import queries


class MyTestCase(unittest.TestCase):
    conn = ConnectionHelper("tpch", "postgres", "postgres", "5432", "localhost")

    def test_nonUnion_query(self):
        key = 'tpch_query1'
        query = queries.queries_dict[key]
        u_Q = UnionPipeLine.extract(self.conn, query)
        self.assertTrue(u_Q is not None)
        print(u_Q)

    def test_nonUnion_queries(self):
        Q_keys = queries.queries_dict.keys()
        f = open("UnionPipeLineTest_results.txt.txt", "w")
        q_no = 1
        for q_key in Q_keys:
            query = queries.queries_dict[q_key]
            u_Q = UnionPipeLine.extract(self.conn, query)
            self.assertTrue(u_Q is not None)
            print(u_Q)
            f.write("\n" + str(q_no) + ":")
            f.write("\tHidden Query:\n")
            f.write(query)
            f.write("\n*** Extracted Query:\n")
            f.write(u_Q)
            f.write("\n---------------------------------------\n")
            q_no += 1
        f.close()

    def test_unionQ(self):
        query = "(select l_partkey as key from lineitem, part where l_partkey = p_partkey and l_extendedprice <= 905) " \
                "union all " \
                "(select l_orderkey as key from lineitem, orders where l_orderkey = o_orderkey and o_totalprice <= " \
                "905) " \
                "union all " \
                "(select o_orderkey as key from customer, orders where c_custkey = o_custkey and o_totalprice <= 890);"
        u_Q = UnionPipeLine.extract(self.conn, query)
        self.assertTrue(u_Q is not None)
        print(u_Q)
        f = open("check.txt",'w')
        f.write(query + "\n\n")
        f.write(u_Q)
        f.close()


if __name__ == '__main__':
    unittest.main()
