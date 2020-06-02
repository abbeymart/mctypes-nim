#
#              mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#             mConnect Financial Management Solution Types/Models
#

## mConnect Financial Management Solution types / model definitions:
## Database | ValueType etc...
## 
##

# types
import json, times
import central

# Define types
type
    Account* = object
        isAdmin*: bool
        defaultGroup*: string
        defaultLanguage*: string
        dob*: DateTime
    
    GeneralLedger* = object
        firstName*: string
        middleName*: string
        lastName*: string
        account*: seq[Account]
        lang*: string
        desc*: string
        isActive*: bool
        actionTracker: ActionTracker

    Expense* = object
        createdDate*: DateTime
        createdBy*: User
        updatedDate*: DateTime
        updatedBy*: User
        deletedDate*: DateTime
        deletedBy*: User