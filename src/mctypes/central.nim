#
#              mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#             mConnect Shared Services/Solution Types/Models
#

## mConnect shared types for all mConnect solutions:
## Database | ValueType etc...
## 
##

# types
import db_postgres, json, tables

# Define types
type
    Profile* = object
        isAdmin*: bool

    User* = object
        firstName*: string
        middleName*: string
        lastName*: string
        profile*: Profile

    AccessKey* = object
        firstName*: string
        middleName*: string
        lastName*: string
        profile*: Profile

    Audit* = object
        firstName*: string
        middleName*: string
        lastName*: string
        profile*: Profile

    Bookmark* = object
        firstName*: string
        middleName*: string
        lastName*: string
        profile*: Profile
