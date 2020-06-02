#
#              mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#             Supply Chain Management (SCM) Types
#

## mConnect Supply Chain Management Solution types / model definitions
##  
##

import json, tables, times
import central

# Define types
type
    Warehouse* = object
        uid*: string
        firstName*: string
        middleName*: string
        lastName*: string

    Storage* = object
        uid*: string
        collName*: string
        collValues*: JsonNode
        collNewValues*: JsonNode
        logDate*: DateTime
        logBy*: string
        store: Warehouse
        products*: Table[string, JsonNode]
        actionTracker: ActionTracker