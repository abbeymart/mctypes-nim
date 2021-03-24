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

    PermissionType* = object
        ok*: bool
        accessInfo*: CheckAccessType

    RoleFuncType* = proc (it1: string; it2: RoleServiceType): bool
    
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
        fieldSubQuery*: QueryParam ## for WHERE IN (SELECT field from fieldColl)
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

    ## functionType => MIN(min), MAX, SUM, AVE, COUNT, CUSTOM/USER defined
    ## fieldItems=> specify fields/parameters to match the arguments for the functionType.
    ## The fieldType must match the argument types expected by the functionType, 
    ## otherwise the only the first function-matching field will be used, as applicable
    QueryFunction* = object
        functionType*: string
        fieldItems*: seq[FieldItem]
        
    QueryParam* = object
        tableName*: string    ## default: "" => will use tableName instead
        fieldItems*: seq[FieldItem]   ## @[] => SELECT * (all fields)
        whereParams*: seq[WhereParam]

    QueryTop* = object         
        topValue*: int
        topUnit*: string ## number or percentage (# or %)
    
    CaseCondition* = object
        fieldItems*: seq[FieldItem]
        resultMessage*: string
        resultField*: string  ## for ORDER BY options

    CaseQueryParam* = object
        conditions*: seq[CaseCondition]
        defaultField*: string   ## for ORDER BY options
        defaultMessage*: string 
        orderBy*: bool
        asField*: string

    SelectFromParam* = object
        tableName*: string
        fieldItems*: seq[FieldItem]

    InsertIntoParam* = object
        tableName*: string
        fieldItems*: seq[FieldItem]

    GroupParam* = object
        fieldName*: string
        fieldOrder*: int

    OrderParam* = object
        tableName*: string
        fieldName*: string
        queryFunction*: QueryFunction
        fieldOrder*: string ## "ASC" ("asc") | "DESC" ("desc")
        functionOrder*: string

    # for aggregate query condition
    HavingParam* = object
        tableName: string
        queryFunction*: QueryFunction
        queryOp*: string
        queryOpValue*: string ## value will be cast to fieldType in queryFunction
        orderType*: string ## "ASC" ("asc") | "DESC" ("desc")
        # subQueryParams*: SubQueryParam # for ANY, ALL, EXISTS...

    SubQueryParam* = object
        whereType*: string   ## EXISTS, ANY, ALL
        whereField*: string  ## for ANY / ALL | Must match the fieldName in queryParam
        whereOp*: string     ## e.g. "=" for ANY / ALL
        queryParams*: QueryParam
        queryWhereParams*: WhereParam

    ## combined/joined query (read) param-type
    JoinSelectField* =  object
        tableName*: string
        collFields*: seq[FieldItem]
    
    JoinField* = object
        tableName*: string
        joinField*: string

    JoinQueryParam* = object
        selectFromColl*: string ## default to tableName
        selectFields*: seq[JoinSelectField]
        joinType*: string ## INNER (JOIN), OUTER (LEFT, RIGHT & FULL), SELF...
        joinFields*: seq[JoinField] ## [{tableName: "abc", joinField: "field1" },]
    
    SelectIntoParam* = object
        selectFields*: seq[FieldItem] ## @[] => SELECT *
        intoColl*: string          ## new table/collection
        fromColl*: string          ## old/external table/collection
        fromFilename*: string      ## IN external DB file, e.g. backup.mdb
        whereParam*: seq[WhereParam]
        joinParam*: JoinQueryParam ## for copying from more than one table/collection

    UnionQueryParam* = object
        selectQueryParams*: seq[QueryParam]
        whereParams*: seq[WhereParam]
        orderParams*: seq[OrderParam]

    TaskRecordType* = object
        taskRec*: seq[QueryParam]

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

    ValueParamsType* = Table[string, FieldValueTypes | DataTypes]    ## fieldName: fieldValue, must match fieldType (re: validate) in model definition
    
    ValueToDataType* = Table[string, DataTypes]

    ActionParamsType* = seq[ValueParamsType]  ## documents for create or update task/operation

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
    
    ## SELECT CASE... query condition(s)
    ## 
    CaseFieldType* = object
        fieldTable*: string
        fieldName*: string
        fieldType*: DataTypes   ## "int", "string", "bool", "boolean", "float",...
        fieldOrder*: int
        fieldOp*: OperatorTypes    ## GT/gt/>, EQ/==, GTE/>=, LT/<, LTE/<=, NEQ(<>/!=), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
        fieldValue*: string  ## for insert/update | start value for range/BETWEEN/NOTBETWEEN and pattern for LIKE operators
        fieldValueEnd*: string   ## end value for range/BETWEEN/NOTBETWEEN operator
        fieldValues*: seq[string] ## values for IN/NOTIN operator
        fieldSubQuery*: QueryParamType ## for WHERE IN (SELECT field from fieldTable)
        fieldPostOp*: OperatorTypes ## EXISTS, ANY or ALL e.g. WHERE fieldName <fieldOp> <fieldPostOp> <anyAllQueryParams>
        groupOp*: string     ## e.g. AND | OR...
        fieldAlias*: string ## for SELECT/Read query
        show*: bool     ## includes or excludes from the SELECT query fields
        fieldFunction*: ProcedureTypes

    CaseConditionType* = object
        fields*: seq[CaseFieldType]
        resultMessage*: string
        resultField*: string  ## for ORDER BY options

    ## For SELECT CASE... query
    CaseQueryType* = object
        conditions*: seq[CaseConditionType]
        defaultField*: string   ## for ORDER BY options
        defaultMessage*: string 
        orderBy*: bool
        asField*: string

    SelectFromFieldType* = object
        fieldTable*: string
        fieldName*: string
        fieldType*: DataTypes   ## "int", "string", "bool", "boolean", "float",...
        fieldOrder*: int
        fieldOp*: OperatorTypes    ## GT/gt/>, EQ/==, GTE/>=, LT/<, LTE/<=, NEQ(<>/!=), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
        fieldValue*: string  ## for insert/update | start value for range/BETWEEN/NOTBETWEEN and pattern for LIKE operators
        fieldValueEnd*: string   ## end value for range/BETWEEN/NOTBETWEEN operator
        fieldValues*: seq[string] ## values for IN/NOTIN operator
        fieldSubQuery*: QueryParamType ## for WHERE IN (SELECT field from fieldTable)
        fieldPostOp*: OperatorTypes ## EXISTS, ANY or ALL e.g. WHERE fieldName <fieldOp> <fieldPostOp> <anyAllQueryParams>
        groupOp*: string     ## e.g. AND | OR...
        fieldAlias*: string ## for SELECT/Read query
        show*: bool     ## includes or excludes from the SELECT query fields
        fieldFunction*: ProcedureTypes

    SelectFromType* = object
        tableName*: string
        fields*: seq[SelectFromFieldType]

    InsertIntoFieldType* = object
        fieldTable*: string
        fieldName*: string
        fieldType*: DataTypes   ## "int", "string", "bool", "boolean", "float",...
        fieldOrder*: int
        fieldOp*: OperatorTypes    ## GT/gt/>, EQ/==, GTE/>=, LT/<, LTE/<=, NEQ(<>/!=), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
        fieldValue*: string  ## for insert/update | start value for range/BETWEEN/NOTBETWEEN and pattern for LIKE operators
        fieldValueEnd*: string   ## end value for range/BETWEEN/NOTBETWEEN operator
        fieldValues*: seq[string] ## values for IN/NOTIN operator
        fieldSubQuery*: QueryParamType ## for WHERE IN (SELECT field from fieldTable)
        fieldPostOp*: OperatorTypes ## EXISTS, ANY or ALL e.g. WHERE fieldName <fieldOp> <fieldPostOp> <anyAllQueryParams>
        groupOp*: string     ## e.g. AND | OR...
        fieldAlias*: string ## for SELECT/Read query
        show*: bool     ## includes or excludes from the SELECT query fields
        fieldFunction*: ProcedureTypes

    InsertIntoType* = object
        tableName*: string
        fields*: seq[InsertIntoFieldType]

    GroupType* = object
        fields*: seq[string]
        fieldFunction*: seq[ProcedureTypes]
        fieldOrder*: int

    OrderType* = object
        tableName*: string
        fieldName*: string
        queryProc*: ProcedureTypes
        fieldOrder*: OrderTypes ## "ASC" ("asc") | "DESC" ("desc")
        functionOrder*: OrderTypes

    # for aggregate query condition
    HavingType* = object
        tableName: string
        queryProc*: ProcedureTypes
        queryOp*: OperatorTypes
        queryOpValue*: string ## value will be cast to fieldType in queryProc
        orderType*: OrderTypes ## "ASC" ("asc") | "DESC" ("desc")
        # subQueryParams*: SubQueryParam # for ANY, ALL, EXISTS...

    SubQueryType* = object
        whereType*: string   ## EXISTS, ANY, ALL
        whereField*: string  ## for ANY / ALL | Must match the fieldName in QueryParamType
        whereOp*: OperatorTypes     ## e.g. "=" for ANY / ALL
        queryParams*: QueryParamType
        queryWhereParams*: WhereParamType

    ## combined/joined query (read) param-type
    ## 
    JoinSelectFieldItemType* = object
        fieldTable*: string
        fieldName*: string
        fieldType*: DataTypes   ## "int", "string", "bool", "boolean", "float",...
        fieldOrder*: int
        fieldOp*: OperatorTypes    ## GT/gt/>, EQ/==, GTE/>=, LT/<, LTE/<=, NEQ(<>/!=), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
        fieldValue*: string  ## for insert/update | start value for range/BETWEEN/NOTBETWEEN and pattern for LIKE operators
        fieldValueEnd*: string   ## end value for range/BETWEEN/NOTBETWEEN operator
        fieldValues*: seq[string] ## values for IN/NOTIN operator
        fieldSubQuery*: QueryParamType ## for WHERE IN (SELECT field from fieldTable)
        fieldPostOp*: OperatorTypes ## EXISTS, ANY or ALL e.g. WHERE fieldName <fieldOp> <fieldPostOp> <anyAllQueryParams>
        groupOp*: string     ## e.g. AND | OR...
        fieldAlias*: string ## for SELECT/Read query
        show*: bool     ## includes or excludes from the SELECT query fields
        fieldFunction*: ProcedureTypes
    
    JoinSelectFieldType* =  object
        tableName*: string
        tableFields*: seq[JoinSelectFieldItemType]
    
    JoinFieldType* = object
        tableName*: string
        joinField*: string

    JoinQueryType* = object
        selectFromTable*: string ## default to tableName
        selectFields*: seq[JoinSelectFieldType]
        joinType*: string ## INNER (JOIN), OUTER (LEFT, RIGHT & FULL), SELF...
        joinFields*: seq[JoinFieldType] ## [{tableName: "abc", joinField: "field1" },]
    
    SelectIntoFieldType* = object
        fieldTable*: string
        fieldName*: string
        fieldType*: DataTypes   ## "int", "string", "bool", "boolean", "float",...
        fieldOrder*: int
        fieldOp*: OperatorTypes    ## GT/gt/>, EQ/==, GTE/>=, LT/<, LTE/<=, NEQ(<>/!=), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
        fieldValue*: string  ## for insert/update | start value for range/BETWEEN/NOTBETWEEN and pattern for LIKE operators
        fieldValueEnd*: string   ## end value for range/BETWEEN/NOTBETWEEN operator
        fieldValues*: seq[string] ## values for IN/NOTIN operator
        fieldSubQuery*: QueryParamType ## for WHERE IN (SELECT field from fieldTable)
        fieldPostOp*: OperatorTypes ## EXISTS, ANY or ALL e.g. WHERE fieldName <fieldOp> <fieldPostOp> <anyAllQueryParams>
        groupOp*: string     ## e.g. AND | OR...
        fieldAlias*: string ## for SELECT/Read query
        show*: bool     ## includes or excludes from the SELECT query fields
        fieldFunction*: ProcedureTypes

    SelectIntoType* = object
        selectFields*: seq[SelectIntoFieldType] ## @[] => SELECT *
        intoTable*: string          ## new table/collection
        fromTable*: string          ## old/external table/collection
        fromFilename*: string      ## IN external DB file, e.g. backup.mdb
        WhereParamType*: seq[WhereParamType]
        joinParam*: JoinQueryType ## for copying from more than one table/collection

    UnionQueryType* = object
        selectQueryParams*: seq[QueryParamType]
        where*: seq[WhereParamType]
        orderParams*: seq[OrderType]

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