#                   mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#       See the file "LICENSE.md", included in this
#    distribution, for details a bout the copyright / license.
# 
#                   CRUD Package Types

## CRUD types | centralised and exported types for all CRUD operations
## 
import db_postgres, tables, json
import mcdb, mctranslog
import sharedtypes

# Define crud types
type
    TaskTypes* = enum
        SAVE = "save",
        CREATE = "create",
        INSERT = "insert",
        UPDATE = "update",
        READ   = "read",
        GET = "get",
        DELETE = "delete",
        REMOVE = "remove",
        LOGIN = "login",
        LOGOUT = "logout",
        OTHER = "other",
        INSERT_INTO = "insert_into",
        SELECT_FROM = "select_from",
        CASE = "case",
        UNION = "union",
        JOIN = "join",
        INNER_JOIN = "inner_join",
        OUTER_LEFT_JOIN = "outer_left_join",
        OUTER_RIGHT_JOIN = "outer_right_join",
        OUTER_FULL_JOIN = "outer_full_join",
        SELF_JOIN = "self_join",
        SUB = "sub",
        SELECT = "select",
        SELECT_TOP = "select_top",
        SELECT_TABLE_FIELD = "select_table_field",
        SELECT_COLLECTION_DOC = "select_collection_doc",
        SELECT_ONE_TO_ONE = "select_one_to_one",      ## LAZY SELECT: select sourceTable, then getTargetTable() related record{target: {}}
        SELECT_ONE_TO_MANY = "select_one_to_many",     ## LAZY SELECT: select sourceTable, then getTargetTable() related records ..., targets: [{}, {}]
        SELECT_MANY_TO_MANY = "select_many_to_many",    ## LAZY SELECT: select source/targetTable, then getTarget(Source)Table() related records
        SELECT_INCLUDE_ONE_TO_ONE = "select_include_one_to_one",  ## EAGER SELECT: select sourceTable and getTargetTable related record {..., target: {}}
        SELECT_INCLUDE_ONE_TO_MANY = "select_include_one_to_many", ## EAGER SELECT: select sourceTable and getTargetTable related records { , []}
        SELECT_INCLUDE_MANY_TO_MANY = "select_include_many_to_many", ## EAGER SELECT: select sourceTable and getTargetTable related record {{}}        

    RoleServiceType* = object
        serviceId*: string
        roleId*: string
        serviceCategory* : string
        canRead*  : bool
        canCreate*: bool
        canUpdate*: bool
        canDelete*: bool
        tableAccessPermitted: bool
    
    CheckAccessType* = object
        userId*: string
        group*: string
        groups*: seq[string]
        isActive*: bool
        isAdmin*: bool
        roleServices*: seq[RoleServiceType]
        tableId*: string

    CheckAccessParamsType* = object 
        accessDb*: Database
        userInfo*: UserInfoType
        tableName*: string
        recordIds*: seq[string]
        accessTable*: string
        userTable*: string
        roleTable*: string
        serviceTable*: string
        userProfileTable*: string

    PermissionType* = object
        ok*: bool
        accessInfo*: CheckAccessType

    RoleFuncType* = proc (it1: string; it2: RoleServiceType): bool
    SortParamType* = Table[string, int] # 1 for "asc", -1 for "desc"
    ProjectParamType* = Table[string, bool | int] # 1/true => include | 0/false => exclude
    # ExistParamType* = Table[string, ValueType]
    ExistParamsType* = seq[JsonNode]
    
    CurrentRecordType* = object
        currentRec*: seq[Row]

    # fieldValue(s) are string type for params parsing convenience,
    # fieldValue(s) will be cast by supported fieldType(s), else will through ValueError exception
    # fieldOp: GT, EQ, GTE, LT, LTE, NEQ(<>), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
    # groupOp/groupLinkOp: AND | OR
    # groupCat: user-defined, e.g. "age-policy", "demo-group"
    # groupOrder: user-defined e.g. 1, 2...
    FieldItem* = object
        fieldColl*: string
        fieldName*: string
        fieldType*: string   ## "int", "string", "bool", "boolean", "float",...
        fieldOrder*: string
        fieldOp*: string    ## GT/gt/>, EQ/==, GTE/>=, LT/<, LTE/<=, NEQ(<>/!=), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
        fieldValue*: string  ## for insert/update | start value for range/BETWEEN/NOTBETWEEN and pattern for LIKE operators
        fieldValueEnd*: string   ## end value for range/BETWEEN/NOTBETWEEN operator
        fieldValues*: seq[string] ## values for IN/NOTIN operator
        fieldSubQuery*: QueryParamType ## for WHERE IN (SELECT field from fieldColl)
        fieldPostOp*: string ## EXISTS, ANY or ALL e.g. WHERE fieldName <fieldOp> <fieldPostOp> <anyAllQueryParams>
        groupOp*: string     ## e.g. AND | OR...
        fieldAlias*: string ## for SELECT/Read query
        show*: bool     ## includes or excludes from the SELECT query fields
        fieldFunction*: string ## COUNT, MIN, MAX... for select/read-query...

    WhereParam* = object
        groupCat*: string
        groupLinkOp*: string
        groupOrder*: int
        groupItems*: seq[FieldItem]

    SubQueryParam* = object
        whereType*: string   ## EXISTS, ANY, ALL
        whereField*: string  ## for ANY / ALL | Must match the fieldName in queryParam
        whereOp*: string     ## e.g. "=" for ANY / ALL
        queryParams*: QueryParamType
        queryWhereParams*: WhereParam

    TaskRecordType* = object
        taskRec*: seq[QueryParamType]

    QueryWhereTypes* = enum
        ID,
        PARAMS,
        QUERY,
        SUBQUERY,

    OrderTypes* = enum
        ASC,
        DESC,

    # CreatedByType* = uuId | DataTypes
    # # UpdatedByType* = uuId | DataTypes
    # # CreatedAtType* = DateTime | DataTypes
    # # UpdatedAtType* = DateTime | DataTypes

    # TODO: review / simplify definition
    ProcedureType* = object
        procDesc: ProcType          # return string to be cast into procReturnType
        procParams*: seq[string]    # proc params/fieldNames, to be injected into procName, used to get the fieldValue
        procReturnType*: DataTypes  # proc return type

    ComputedFieldType* = object
        fieldName*: string
        fieldType*: DataTypes
        fieldMethod*: ProcType

    FieldValueTypes* = string | int | bool | object | seq[string] | seq[int] | seq[bool] | seq[object]    

    ValueParamsType* = Table[string, FieldValueTypes]    ## fieldName: fieldValue, must match fieldType (re: validate) in model definition
    
    ValueToDataType* = Table[string, DataTypes]

    ActionParamsType* = seq[JsonNode]  ## documents for create or update task/operation

    QueryParamsType* = Table[string, DataTypes]

    ActionParamTaskType* = object
        createItems*: ActionParamsType
        updateItems*: ActionParamsType
        recordIds*: seq[string]

    SaveFieldType* = object
        fieldName*: string
        fieldValue*: string     ## must match the field DataTypes
        fieldOrder*: Positive
        fieldType*: DataTypes
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX... for select/read-query...

    CreateFieldType* = Table[string, string] ## key = fieldName, value = fieldValue | must match model definition

    UpdateFieldType* = object
        fieldName*: string
        fieldValue*: string
        fieldOrder*: int
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX... for select/read-query...

    ReadFieldType* = object
        tableName*: string
        fieldName*: string
        fieldOrder*: int
        fieldAlias*: string
        show*: bool     ## includes or excludes from the SELECT query fields
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX... for select/read-query...

    DeleteFieldType* = object
        fieldName*: string
        fieldSubQuery*: QueryParamType
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX... for select/read-query...

    FieldSubQueryType* = object
        tableName*: string    ## default: "" => will use instance tableName instead
        fields*: seq[ReadFieldType]   ## @[] => SELECT * (all fields)
        where*: seq[WhereParamType]

    GroupFunctionType* = object
        fields*: seq[string]
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX, custom... for select/read-query...

    WhereFieldType* = object
        fieldTable*: string
        fieldType*: DataTypes
        fieldName*: string
        fieldOrder*: int
        fieldOp*: OperatorTypes    ## GT/gt/>, EQ/==, GTE/>=, LT/<, LTE/<=, NEQ(<>/!=), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
        fieldValue*: string  ## for insert/update | start value for range/BETWEEN/NOTBETWEEN and pattern for LIKE operators
        fieldValueEnd*: string   ## end value for range/BETWEEN/NOTBETWEEN operator
        fieldValues*: seq[string] ## values for IN/NOTIN operator
        fieldSubQuery*: QueryParamType ## for WHERE IN (SELECT field from fieldTable)
        fieldPostOp*: OperatorTypes ## EXISTS, ANY or ALL e.g. WHERE fieldName <fieldOp> <fieldPostOp> <anyAllQueryParams>
        groupOp*: string     ## e.g. AND | OR...
        fieldProc*: ProcedureTypes ## COUNT, MIN, MAX... for select/read-query...
        fieldProcFields*: seq[string] ## parameters for the fieldProc

    WhereParamType* = object
        groupCat*: string       # group (items) categorization
        groupLinkOp*: string        # group relationship to the next group (AND, OR)
        groupOrder*: int        # group order, the last group groupLinkOp should be "" or will be ignored
        groupItems*: seq[WhereFieldType] # group items to be composed by category

    SaveParamType* = object
        tableName*: string
        fields*: seq[SaveFieldType]
        where*: seq[WhereParamType]
   
    QueryParamType* = object        # same as QueryReadParamType
        tableName*: string    ## default: "" => will use instance tableName instead
        fields*: seq[ReadFieldType]   ## @[] => SELECT * (all fields)
        where*: seq[WhereParamType] ## whereParams or docId(s)  will be required for delete task

    QueryReadParamType* = object
        tableName*: string
        fields*: seq[ReadFieldType]
        where*: seq[WhereParamType]

    QuerySaveParamType* = object
        tableName*: string
        fields*: seq[SaveFieldType]
        where*: seq[WhereParamType]

    QueryUpdateParamType* = object
        tableName*: string
        fields*: seq[UpdateFieldType]
        where*: seq[WhereParamType]

    QueryDeleteParamType* = object
        tableName*: string
        fields*: seq[DeleteFieldType]
        where*: seq[WhereParamType]

    ## For SELECT TOP... query
    QueryTopType* = object         
        topValue*: int    
        topUnit*: string ## number or percentage (# or %)
    
    
    CurrentRecord* = object
        currentRec*: seq[Row]
    
    TaskRecord* = object
        taskRec*: seq[QueryParamType]
        recCount*: int 

    # Exception types
    SaveError* = object of CatchableError
    CreateError* = object of CatchableError
    UpdateError* = object of CatchableError
    DeleteError* = object of CatchableError
    ReadError* = object of CatchableError
    AuthError* = object of CatchableError
    ConnectError* = object of CatchableError
    SelectQueryError* = object of CatchableError
    WhereQueryError* = object of CatchableError
    CreateQueryError* = object of CatchableError
    UpdateQueryError* = object of CatchableError
    DeleteQueryError* = object of CatchableError

    ## CrudParamsType is the struct type for receiving, composing and passing CRUD inputs 
    CrudParamsType* = ref object
        appDb*: Database
        userInfo*: UserInfoType
        ## tableName: table/collection to insert, update, read or delete record(s).
        tableName*: string 
        ## actionParams: @[{tableName: "abc", fieldNames: @["field1", "field2"]},], for create & update.
        ## Field names and corresponding values of record(s) to insert/create or update.
        ## Field-values will be validated based on data model definition.
        ## ValueError exception will be raised for invalid value/data type 
        ##
        actionParams*: seq[SaveParamType]
        existParams*: ExistParamsType
        queryParams*: WhereParamType
        recordIds*: seq[string]  ## for update, delete and read tasks
        projectParams*: ProjectParamType
        sortParams*: SortParamType
        token*: string
        skip*: int
        limit*: int
        taskName*: string
        defaultLimit*: int
        createTableFields*:  seq[string]
        updateTableFields*:  seq[string]
        getTableFields*:     seq[string]

        checkAccess*: bool
        transLog*: LogParam
        isRecExist*: bool
        isAuthorized*: bool
        currentRecords*: seq[Row]
        roleServices*: seq[RoleServiceType]
        recExistMessage*: string
        unAuthMessage*: string

    CrudOptionsType* = ref object
        skip*: Positive
        limit*: Positive
        parentTables*: seq[string]
        childTables*: seq[string]
        recursiveDelete*: bool
        checkAccess*: bool
        accessDb*: Database
        auditDb*: Database
        serviceDb*: Database
        auditTable*: string
        serviceTable*: string
        userTable*: string
        roleTable*: string
        accessTable*: string
        verifyTable*: string
        userProfileTable*: string
        maxQueryLimit: Positive
        logAll: bool
        logCreate: bool
        logUpdate: bool
        logRead: bool
        logDelete: bool
        logLogin: bool
        logLogout: bool
        unAuthorizedMessage: string
        recExistMessage: string
        cacheExpire: Positive
        # modelOptions: ModelOptionsType
        loginTimeout: Positive
        usernameExistsMessage: string
        emailExistsMessage: string
        msgFrom: string

    CrudType* = ref object
        params*: CrudParamsType
        options*: CrudOptionsType
        currentRecords*: string
        transLog*:       LogParam
        hashKey*:        string # Unique for exactly the same query

    CreateQueryResponseType* = object
        createQuery*: string
        fieldNames*:  seq[string]
        fieldValues*:  seq[seq[JsonNode]]

    UpdateQueryResponseType* = object
        updateQuery*: string
        whereQuery*:  string
        fieldValues*:  seq[JsonNode]   

    WhereQueryResponseType* = object
        whereQuery*:  string
        fieldValues*:  seq[JsonNode] 

    DeleteQueryResponseType* = object
        deleteQuery*: string
        whereQuery*:  string
        fieldValues*:  seq[JsonNode]    

    SelectQueryResponseType* = object
        selectQuery*: string
        whereQuery*:  string
        fieldValues*:  seq[JsonNode]   
    
    SaveParamsType* = object
        userInfo*: UserInfoType
        queryParams*: QueryParamType
        recordIds*: seq[string]

    SaveCrudParamsType* = ref object
        params*:         CrudParamsType
        options*:        CrudOptionsType
        createTableFields*:  seq[string]
        updateTableFields*:  seq[string]
        getTableFields*:     seq[string]
        auditLog*:           bool

    DeleteCrudParamsType* = ref object
        params*:         CrudParamsType
        options*:        CrudOptionsType
        getTableFields*:     seq[string]
        auditLog*:           bool

    GetCrudParamsType* = ref object
        params*:         CrudParamsType
        options*:        CrudOptionsType
        createTableFields*:  seq[string]
        updateTableFields*:  seq[string]
        getTableFields*:     seq[string]
        auditLog*:           bool

    CrudResultType* = object 
        queryParams*: WhereParamType
        recordIds*: seq[string]
        recordCount*: uint
        tableRecords*: seq[JsonNode]

    LogRecordsType* = object 
        queryParams*: WhereParamType
        recordIds*: seq[string]
        tableFields*: seq[string]
        tableRecords*: seq[JsonNode]