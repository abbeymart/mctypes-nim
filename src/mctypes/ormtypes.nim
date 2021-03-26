import tables
import mcdb
import sharedtypes

type
    FieldValueTypes* = string | int | bool | object | seq[string] | seq[int] | seq[bool] | seq[object]    

    RecordValueType* = Table[string, FieldValueTypes]    ## fieldName: fieldValue, must match fieldType (re: validate) in model definition
    
    ValueToDataType* = Table[string, DataTypes]

    FieldDescType* = object
        fieldType*: DataTypes
        fieldLength*: uint
        fieldPattern*: string # regex-pattern: "![0-9]" => excluding digit 0 to 9 | "![_, -, \, /, *, |, ]" => exclude the charaters
        allowNull*: bool
        unique*: bool
        indexable*: bool
        primaryKey*: bool
        minValue*: float
        maxValue*: float
        setValue*: SetProcType # transform fieldValue prior to insert/update | result/return type (DataTypes) must match the fieldType or cast string-result to fieldType
        defaultValue*: DefaultProcType  # result/return type (DataTypes) must match the fieldType
        validate*: ValidateProcType # result/return type (DataTypes) must match the fieldValue# validate field-value (pattern/format), returns a bool (valid=true/invalid=false)
        validateMessage: string
        
    RecordDescType* = Table[string, DataTypes | FieldDescType]
    
    RelationActionTypes* = enum
        RESTRICT = "restrict",       ## must remove target-record(s), prior to removing source-record
        CASCADE = "cascade",        ## default for ONUPDATE | update foreignKey value or delete foreignKey record/value
        NO_ACTION = "no_action",      ## leave the foreignKey value, as-is
        SET_DEFAULT = "set_default",    ## set foreignKey to specified default value
        SET_NULL = "set_null", ## set foreignKey to       ## default for ONDELETE | allow/set foreignKey to be null

    RelationTypeTypes* = enum
        ONE_TO_ONE = "one_to_one",
        ONE_TO_MANY = "one_to_many",
        MANY_TO_ONE = "many_to_one",
        MANY_TO_MANY = "many_to_many",

    ## Model/table relationship, from source-to-target
    ## 
    ModelRelationType* = ref object
        sourceModel*: ModelType
        sourceTable*: string
        targetModel*: ModelType
        targetTable*: string
        relationType*: RelationTypeTypes   # one-to-one, one-to-many, many-to-one, many-to-many  
        sourceField*: string
        targetField*: string    ## default: primary key/"id" field, it could be another unique key
        foreignField*: string   ## default: sourceModel<sourceField>, e.g. userId
        relationField*: string  ## relation-targetField, for many-to-many
        relationTable*: string  ## optional tableName for many-to-many | default: sourceTable_targetTable
        onDelete*: RelationActionTypes
        onUpdate*: RelationActionTypes

    ModelOptionsType* = object
        timeStamp*: bool        ## auto-add: createdAt and updatedAt | default: true
        actorStamp*: bool       ## auto-add: createdBy and updatedBy | default: true
        activeStamp*: bool      ## auto-add isActive, if not already set | default: true
        docValueDesc*: Table[string, DataTypes | FieldDescType]
        docValue*: Table[string, string] 
    
    ## Model definition / description
    ## 
    ModelType* = ref object
        appDb*: Database        ## Db handle
        modelName*: string
        tableName*: string
        recordDesc*: RecordDescType
        timeStamp*: bool           ## auto-add: createdAt and updatedAt | default: true
        actorStamp*: bool           ## auto-add: createdBy and updatedBy | default: true
        activeStamp*: bool          ## record active status, isActive (true | false) | default: true
        relations*: seq[ModelRelationType]
        computedProcedures*: ComputedProceduresType     ## model-level functions, e.g fullName(a, b: T): T
        validateProcedures*: ValidateProceduresType
        # computedFields*: seq[ComputedFieldType]
        # methods*: seq[ProcedureType]  ## model-level procs, e.g fullName(a, b: T): T
        alterSyncTable*: bool   ## create / alter table and sync existing data, if there was a change to the table structure | default: true       
                                ## if alterTable: false, it will create/re-create the table, with no data sync
