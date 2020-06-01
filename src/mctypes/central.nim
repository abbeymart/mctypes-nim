#
#              mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#             mConnect Shared Services/Solution Types/Models
#

## mConnect shared types and constructors for all mConnect solutions:
## Database | ValueType etc...
## 
##

# types
import json, tables, times

# Define types
type
    Profile* = object
        isAdmin*: bool
        defaultGroup*: string
        defaultLanguage*: string
        dob*: DateTime

    User* = object
        firstName*: string
        middleName*: string
        lastName*: string
        profile*: Profile
        lang*: string
        desc*: string
        isActive*: bool

    ActionTracker* = object
        createdDate*: DateTime
        createdBy*: User
        updatedDate*: DateTime
        updatedBy*: User
        deletedDate*: DateTime
        deletedBy*: User

    AccessKey* = object
        uid*: string
        loginName*: string
        userId*: string
        token*: string
        expire*: Time
        actionTracker*: ActionTracker

    Address* = object
        uid*: string
        streetNumber*: uint
        streetName*: string
        streetType*: string
        streetDirection*: string
        city*: string
        state*: string
        country*: string
        phone*: string
        ownerId*: string
        contactId*: string
        category*: string
        latitude*: int
        longitude*: int
        lang*: string
        desc*: string
        isActive*: bool
        actionTracker*: ActionTracker

    Audit* = object
        uid*: string
        collName*: string
        collValues*: JsonNode
        collNewValues*: JsonNode
        logDate*: DateTime
        logBy*: User

    Bookmark* = object
        uid*: string
        firstName*: string
        middleName*: string
        lastName*: string
        profile*: Profile

    Category* = object
        uid*: string
        collName*: string
        collValues*: JsonNode
        collNewValues*: JsonNode
        logDate*: DateTime
        logBy*: User
    