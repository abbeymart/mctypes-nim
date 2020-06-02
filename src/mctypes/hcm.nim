#
#              mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#             mConnect Human Capital Management Solution Types/Models
#

## mConnect Human Capital Management Solution types / model definitions:
## Database | ValueType etc...
## 
##

# types
import json, times
import central

# Define types
type
    NextOfKin* = object
        isAdmin*: bool
        defaultGroup*: string
        defaultLanguage*: string
        dob*: DateTime
    
    Person* = object
        firstName*: string
        middleName*: string
        lastName*: string
        nextOfKin*: seq[NextOfKin]
        lang*: string
        desc*: string
        isActive*: bool
        actionTracker: ActionTracker

    Department* = object
        createdDate*: DateTime
        createdBy*: User
        updatedDate*: DateTime
        updatedBy*: User
        deletedDate*: DateTime
        deletedBy*: User
