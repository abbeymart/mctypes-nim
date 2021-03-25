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
import db_postgres, json, tables, times, json
import mcdb

# Define types
type 
    DataTypes* = enum
        STRING = "string",
        VARCHAR = "varchar",
        TEXT = "text",
        UUID = "uuid",
        NUMBER = "number",
        POSITIVE = "positive",
        INTEGER = "integer",
        DECIMAL = "decimal",
        FLOAT = "float",
        BIG_FLOAT = "big_float",
        BIG_INT = "big_int",
        ARRAY = "array",
        ARRAY_OF_STRING = "array_of_string",
        ARRAY_OF_NUMBER = "array_of_number",
        ARRAY_OF_BOOLEAN = "array_of_boolean",
        ARRAY_OF_OBJECT = "array_of_object",
        BOOLEAN = "boolean",
        DATETIME = "datetime",
        DATE = "date",
        TIME = "time",
        TIMESTAMP = "timestamp",
        TIMESTAMPZ = "timestampz",
        POSTAL_CODE = "postal_code",
        EMAIL = "email",
        URL = "url",
        PORT = "port",
        IP_ADDRESS = "ip_address",
        JWT = "jwt",
        LAT_LONG = "lat_long",
        ISO2 = "iso2",
        ISO3 = "iso3",
        MAC_ADDRESS = "mac_address",
        MIME = "mime",
        CREDIT_CARD = "credit_card",
        CURRENCY = "currency",
        IMEI = "imei",
        INT = "int",
        BOOL ="bool",
        JSON = "json",
        OBJECT = "object",     ## key-value pairs
        ENUM = "enum",       ## Enumerations
        SET = "set",           ## Unique values set
        SEQ ="seq",
        TABLE = "table",      ## Table/Map/Dictionary
        MCDB = "mcdb",       ## Database connection handle
        MODEL_RECORD = "model_record",   ## Model record definition
        MODEL_VALUE = "model_value",   ## Model value definition
  
    OperatorTypes* = enum
        EQ = "eq",
        GT = "gt",
        LT = "lt",
        GTE = "gte",
        LTE = "lte",
        NEQ = "neq",
        TRUE = "true",
        FALSE = "false",
        INCLUDES = "includes",
        NOT_INCLUDES = "not_includes",
        STARTS_WITH = "starts_with",
        ENDS_WITH = "ends_with",
        NOT_STARTS_WITH = "not_starts_with",
        NOT_ENDS_WITH = "not_ends_with",
        IN = "in",
        NOT_IN = "not_in",
        BETWEEN = "between",
        NOT_BETWEEN = "not_between",
        EXCLUDES = "excludes",
        LIKE = "like",
        NOT_LIKE = "notlike",
        ILIKE = "ilike",
        NOT_ILIKE = "not_ilike",
        REGEX = "regex",
        NOT_REGEX = "not_regex",
        IREGEX = "iregex",
        NOT_IREGEX = "not_iregex",
        ANY = "any",
        ALL = "all",

    RelationTypes* = enum
        AND = "and",
        OR = "or",

    uuId* = string

    ValueType* = int | string | float | bool | Positive | Natural | JsonNode | Time | BiggestInt | BiggestFloat | Table | seq | SqlQuery | Database
 
    AuditStampType* = object
        isActive: bool
        createdBy: string
        createdAt: DateTime
        updatedBy: string
        updatedAt: DateTime
    
    UserInfoType* = object
        userId:    string
        firstName: string
        lastName:  string 
        language:  string 
        loginName: string 
        token:     string
        expire:    uint
        group :    string
        email:     string

    ProcType* = proc(): DataTypes    ## will automatically receive record value for the model

    ProcedureTypes* = enum
        PROC,              ## proc(): T
        VALIDATEPROC,      ## proc(val: T): bool
        DEFAULTPROC,       ## proc(): T
        SETPROC,           ## proc(val: T)
        GETPROC,           ## proc(key: string): T
        UNARYPROC,         ## proc(val: T): T
        BIPROC,            ## proc(valA, valB: T): T
        PREDICATEPROC,     ## proc(val: T): bool
        BIPREDICATEPROC,   ## proc(valA, valB: T): bool
        SUPPLYPROC,        ## proc(): T
        BISUPPLYPROC,      ## proc(): (T, T)
        CONSUMERPROC,      ## proc(val: T): void
        BICONSUMERPROC,    ## proc(valA, valB: T): void
        COMPARATORPROC,    ## proc(valA, valB: T): int
        MODELPROC,         ## proc(): Model  | to define new data model
    
    # functional procedure types
    IPredicateType* = proc(val: int): bool {.closure.} # {.closure.} is default to proc type
    StringPredicateType* = proc(val: string): bool {.closure.} 
    PredicateType*[T] = proc(val: T): bool {.closure.} 
    BinaryPredicateType*[T, U] = proc(val1: T, val2: U ): bool {.closure.} 
    UnaryOperatorType*[T] = proc(val: T): T {.closure.} 
    BinaryOperatorType*[T] = proc(val1, val2: T): T {.closure.} 
    FunctionType*[T, R] = proc(val: T): R {.closure.} 
    BiFunctionType*[T, U, R] = proc(val1: T, val2: U): R {.closure.} 
    ConsumerType*[T] = proc(val: T) {.closure.} 
    BiConsumerType*[T, U] = proc(val1: T, val2: U) {.closure.} 
    SupplierType*[R] = proc(): R {.closure.} 
    ComparatorType*[T] = proc(val1: T, val2: T): int {.closure.} 

    GetValueProcedureType*[T]= proc(): T ## return a value of type T
    SetValueProcedureType*[T]= proc(val: T): T ## receive val-object as parameter
    DefaultValueProcedureType*[T, R] = proc(val: T): R ## may/optionally receive val-object as parameter
    ValidateProcedureType*[T] = proc(val: T): bool  ## may/optionally receive val-object as parameter
    ValidateProcedureResponseType*[T] = proc(val: T): ValidateResponseType  ## receive val-object as parameter
    ComputedProcedureType*[T,R] = proc(val: T): R  ## receive val-object as parameter

    ValidateProceduresType* = Table[string, ValidateProcedureResponseType[DataTypes]]

    ComputedProceduresType* = Table[string, ComputedProcedureType[DataTypes, DataTypes]]

    MessageObject* = Table[string, string]

    ValidateResponseType* = object
        ok: bool
        errors: MessageObject

    OkayResponseType* = object
        ok*: bool
