#
#              mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#             mConnect Trading Solution Types/Models
#

## mConnect Trading Solution types / model definitions
##  
##

import json, tables, times

# Define types
type
    Order* = object
        uid*: string
        firstName*: string
        middleName*: string
        lastName*: string

    Cart* = object
        uid*: string
        collName*: string
        collValues*: JsonNode
        collNewValues*: JsonNode
        logDate*: DateTime
        logBy*: string
        products*: Table[string, JsonNode]
