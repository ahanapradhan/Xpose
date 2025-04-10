
import signal
import sys
import unittest

from sympy import nsimplify, collect, Symbol, ImmutableDenseNDimArray

from ...src.util.ConnectionFactory import ConnectionHelperFactory


def signal_handler(signum, frame):
    print('You pressed Ctrl+C!')
    sys.exit(0)


class BaseTestCase(unittest.TestCase):
    conn = ConnectionHelperFactory().createConnectionHelper()
    sigconn = ConnectionHelperFactory().createConnectionHelper()

    def __init__(self, *args, **kwargs):
        print('BasicTest.__init__')
        super(BaseTestCase, self).__init__(*args, **kwargs)

    def setUp(self):
        signal.signal(signal.SIGTERM, signal_handler)
        signal.signal(signal.SIGINT, signal_handler)
        #self.sanitizer.doJob()

    def test_sympy(self):
        i_current_price = Symbol('i_current_price')
        final_res = ImmutableDenseNDimArray([1.0 * i_current_price])
        local_symbol_list = [i_current_price]
        print("final_res: ", final_res)
        print("local_symbol_list: ", local_symbol_list)
        res_expr = final_res.applyfunc(lambda expr: nsimplify(collect(expr, local_symbol_list)))
        #res_expr = nsimplify(collect(final_res, local_symbol_list))
        print(res_expr)

        attribs = ['i_current_price']
        c = 0
        for attrib in attribs:
            c = res_expr.count(attrib)
            print(c)
        self.assertTrue(c)


if __name__ == '__main__':
    unittest.main()