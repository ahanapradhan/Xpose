
import signal
import sys
import unittest

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


if __name__ == '__main__':
    unittest.main()