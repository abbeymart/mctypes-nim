#
#              mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#             mConnect Asset Management Solution Types/Models
#

## mConnect Asset Management Solution types / model definitions:
## Database | ValueType etc...
## 
##

# types
import json, times
import central

# Define types
type
    Feature* = object
        isAdmin*: bool
        defaultGroup*: string
        defaultLanguage*: string
        dob*: DateTime
    
    Product* = object
        firstName*: string
        middleName*: string
        lastName*: string
        feature*: seq[Feature]
        lang*: string
        desc*: string
        isActive*: bool
        props: JsonNode
        actionTracker: ActionTracker
