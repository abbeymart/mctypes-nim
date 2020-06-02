#
#              mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#             mConnect Shared Types
#

## mConnect shared types for all mConnect solutions:
## Database | ValueType etc...
## 
##

# types
import db_postgres, json, tables

# Define types
type
    Database = ref object
        db: DbConn

    ValueType* = int | string | float | bool | Positive | Natural | JsonNode | BiggestInt | BiggestFloat | Table | seq | SqlQuery | Database
 