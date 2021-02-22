#!/usr/bin/env python
from lib.core.enums import PRIORITY

__priority__ = PRIORITY.NORMAL

def dependencies():
    pass

def tamper(payload, **kwargs):
    """
    Insert FILL after every character

    >>> tamper('INSERT')
    'IfillNfillSfillEfillRfillTfill
    """

    retVal = str()

    FILL='ZEROFILL'

    if payload:
        for i in xrange(len(payload)):
            retVal += payload[i]+FILL
    # Uncomment to debug
    # print(payload)
    # print(retVal)
    return retVal
