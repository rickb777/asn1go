// header
%{
package asn1go

import (
    "math"
)
%}
////////////////////////////
//  declarations section
//

// extra SymType fields
%union{
    name         string
    numberRepr   string

    Number       Number
    Real         Real
    TagDefault int
    ExtensionDefault bool
    ModuleIdentifier ModuleIdentifier
    DefinitiveObjIdComponent DefinitiveObjIdComponent
    DefinitiveObjIdComponentList []DefinitiveObjIdComponent
    DefinitiveIdentifier DefinitiveIdentifier
    Type Type
    ObjectIdElement ObjectIdElement
    DefinedValue DefinedValue
    ObjectIdentifierValue ObjectIdentifierValue
    Value Value
    Assignment Assignment
    AssignmentList AssignmentList
    ModuleBody ModuleBody
    ValueReference ValueReference
    TypeReference TypeReference
    Constraint Constraint
    ConstraintSpec ConstraintSpec
    ElementSetSpec ElementSetSpec
    Unions Unions
    Intersections Intersections
    IntersectionElements IntersectionElements
    Exclusions Exclusions
    Elements Elements
    SubtypeConstraint SubtypeConstraint
    RangeEndpoint RangeEndpoint
    NamedType NamedType
    ComponentType ComponentType
    ComponentTypeLists ComponentTypeLists
    ComponentTypeList ComponentTypeList
    SequenceType SequenceType
    Tag Tag
    Class int
    SequenceOfType SequenceOfType
    NamedBitList []NamedBit
    NamedBit NamedBit
    Imports []SymbolsFromModule
    SymbolsFromModule SymbolsFromModule
    SymbolList []Symbol
    Symbol Symbol
    GlobalModuleReference GlobalModuleReference
    AlternativeTypeList []NamedType
    ChoiceType ChoiceType
    ExtensionAdditionAlternative ChoiceExtension
    ExtensionAdditionAlternativesList []ChoiceExtension
    ExtensionAdditions []ExtensionAddition
    NamedNumberList []NamedNumber
    NamedNumber NamedNumber
    EnumeratedType EnumeratedType
    Enumeration []EnumerationItem
    EnumerationItem EnumerationItem
}

%token WHITESPACE
%token NEWLINE
%token <name> TYPEORMODULEREFERENCE
%token <name> VALUEIDENTIFIER
%token <Number> NUMBER
%token <bstring> BSTRING          // TODO not implemented in lexer
%token <bstring> XMLBSTRING       // TODO not implemented in lexer
%token <hstring> HSTRING          // TODO not implemented in lexer
%token <hstring> XMLHSTRING       // TODO not implemented in lexer
%token <cstring> CSTRING          // TODO not implemented in lexer
%token <cstring> XMLCSTRING       // TODO not implemented in lexer
%token ASSIGNMENT
%token RANGE_SEPARATOR
%token ELLIPSIS
%token LEFT_VERSION_BRACKETS
%token RIGHT_VERSION_BRACKETS
%token XML_END_TAG_START    // TODO not implemented in lexer
%token XML_SINGLE_START_END // TODO not implemented in lexer
%token XML_BOOLEAN_TRUE     // TODO not implemented in lexer
%token XML_BOOLEAN_FALSE    // TODO not implemented in lexer
%token XMLASN1TYPENAME      // TODO not implemented in lexer

%token EXPONENT // differs from spec, for REAL values to work

// single-symbol tokens used in pairs
%token OPEN_CURLY  // "{"
%token CLOSE_CURLY  // "}"
%token OPEN_ROUND  // "("
%token CLOSE_ROUND  // ")"
%token OPEN_SQUARE  // "["
%token CLOSE_SQUARE  // "]"

// single-symbol tokens
%token LESS  // "<"
%token GREATER  // ">"
%token COMMA  // ","
%token DOT  // "."
%token MINUS  // "-" (HYPEN-MINUS)
%token COLON  // ":"
%token EQUALS  // "="
%token QUOTATION_MARK  // """ (QUOTATION MARK)
%token APOSTROPHE  // "'" (APOSTROPHE)
%token SPACE  // " " (SPACE)  // TODO won't be parsed probably
%token SEMICOLON  // ";"
%token AT  // "@"
%token PIPE  // "|"
%token EXCLAMATION  // "!"
%token CARET  // "^"

// reserved words
%token ABSENT
%token ABSTRACT_SYNTAX
%token ALL
%token APPLICATION
%token AUTOMATIC
%token BEGIN
%token BIT
%token BMPString
%token BOOLEAN
%token BY
%token CHARACTER
%token CHOICE
%token CLASS
%token COMPONENT
%token COMPONENTS
%token CONSTRAINED
%token CONTAINING
%token DEFAULT
%token DEFINITIONS
%token EMBEDDED
%token ENCODED
%token END
%token ENUMERATED
%token EXCEPT
%token EXPLICIT
%token EXPORTS
%token EXTENSIBILITY
%token EXTERNAL
%token FALSE
%token FROM
%token GeneralString
%token GeneralizedTime
%token GraphicString
%token IA5String
%token IDENTIFIER
%token IMPLICIT
%token IMPLIED
%token IMPORTS
%token INCLUDES
%token INSTANCE
%token INTEGER
%token INTERSECTION
%token ISO646String
%token MAX
%token MIN
%token MINUS_INFINITY
%token NULL
%token NumericString
%token OBJECT
%token OCTET
%token OF
%token OPTIONAL
%token ObjectDescriptor
%token PATTERN
%token PDV
%token PLUS_INFINITY
%token PRESENT
%token PRIVATE
%token PrintableString
%token REAL
%token RELATIVE_OID
%token SEQUENCE
%token SET
%token SIZE
%token STRING
%token SYNTAX
%token T61String
%token TAGS
%token TRUE
%token TYPE_IDENTIFIER
%token TeletexString
%token UNION
%token UNIQUE
%token UNIVERSAL
%token UTCTime
%token UTF8String
%token UniversalString
%token VideotexString
%token VisibleString
%token WITH
// X.208-specific
%token ANY
%token DEFINED
// When adding new reserved words, make sure to update lexer.go.

%type <Real> realnumber
%type <Number> SignedExponent

%type <name> modulereference
%type <TypeReference> typereference
%type <name> identifier
%type <ExtensionDefault> ExtensionDefault
%type <TagDefault> TagDefault
%type <ModuleIdentifier> ModuleIdentifier
%type <DefinitiveObjIdComponent> DefinitiveObjIdComponent
%type <Number> DefinitiveNumberForm
%type <DefinitiveObjIdComponentList> DefinitiveObjIdComponentList
%type <DefinitiveObjIdComponent> DefinitiveNameAndNumberForm
%type <DefinitiveIdentifier> DefinitiveIdentifier
%type <name> NameForm
%type <DefinedValue> DefinedValue
%type <Type> ObjectIdentifierType
%type <Type> IntegerType
%type <Type> BooleanType
%type <Type> BuiltinType
%type <Type> Type
%type <Type> NullType
%type <Type> EnumeratedType
%type <Type> AnyType
%type <NamedType> NamedType
%type <ObjectIdElement> NumberForm
%type <ObjectIdElement> NameAndNumberForm
%type <ObjectIdElement> ObjIdComponents
%type <ObjectIdentifierValue> ObjIdComponentsList
%type <ObjectIdentifierValue> ObjectIdentifierValue
%type <Value> BuiltinValue
%type <Value> Value
%type <Value> IntegerValue
%type <Type> RealType
%type <Value> RealValue
%type <Type> BooleanType
%type <Value> BooleanValue
%type <Value> NumericRealValue SpecialRealValue
%type <Number> SignedNumber
%type <Number> number
%type <Assignment> Assignment
%type <Assignment> ValueAssignment
%type <Assignment> TypeAssignment
%type <AssignmentList> AssignmentList
%type <ModuleBody> ModuleBody
%type <ValueReference> valuereference
%type <Type> ConstrainedType
%type <Type> TypeWithConstraint
%type <Constraint> Constraint
%type <ConstraintSpec> ConstraintSpec
%type <SubtypeConstraint> SubtypeConstraint
%type <SubtypeConstraint> ElementSetSpecs
%type <SubtypeConstraint> RootElementSetSpec
%type <ElementSetSpec> AdditionalElementSetSpec
%type <ElementSetSpec> ElementSetSpec
%type <Unions> Unions
%type <Unions> UElems
%type <Intersections> Intersections
%type <Intersections> IElems
%type <IntersectionElements> IntersectionElements
%type <Exclusions> Exclusions
%type <Elements> Elements
%type <Elements> Elems
%type <Elements> SingleValue
%type <Elements> ValueRange
%type <Elements> SubtypeElements
%type <Elements> TypeConstraint
%type <Elements> InnerTypeConstraints
%type <Elements> SizeConstraint
%type <RangeEndpoint> LowerEndpoint UpperEndpoint
%type <Value> LowerEndValue UpperEndValue
%type <Type> CharacterStringType RestrictedCharacterStringType UnrestrictedCharacterStringType
%type <Type> DefinedType ReferencedType
%type <Type> SequenceType
%type <Type> SequenceOfType
%type <Type> SetType
%type <Type> SetOfType
%type <ComponentType> ComponentType
%type <ComponentTypeList> ComponentTypeList
%type <ComponentTypeList> RootComponentTypeList
%type <ComponentTypeLists> ComponentTypeLists
%type <Type> TaggedType
%type <Tag> Tag
%type <Value> ClassNumber
%type <Class> Class
%type <Type> UsefulType
%type <Type> OctetStringType
%type <Type> BitStringType
%type <NamedBitList> NamedBitList
%type <NamedBit> NamedBit
%type <Imports> Imports
%type <Imports> SymbolsImported
%type <Imports> SymbolsFromModuleList
%type <SymbolsFromModule> SymbolsFromModule
%type <SymbolList> SymbolList
%type <Symbol> Symbol
%type <Symbol> Reference  // quite questionable
%type <Value> AssignedIdentifier
%type <GlobalModuleReference> GlobalModuleReference
%type <Type> ChoiceType
%type <ChoiceType> AlternativeTypeLists
%type <AlternativeTypeList> AlternativeTypeList RootAlternativeTypeList
%type <NamedType> NamedType
%type <ExtensionAdditionAlternative> ExtensionAdditionAlternative
%type <ExtensionAdditionAlternativesList> ExtensionAdditionAlternatives
%type <ExtensionAdditionAlternativesList> ExtensionAdditionAlternativesList
%type <ExtensionAdditions> ExtensionAdditions
%type <ExtensionAdditions> ExtensionAdditionList
%type <ExtensionAdditions> ExtensionAddition
%type <NamedNumber> NamedNumber
%type <NamedNumberList> NamedNumberList
%type <EnumeratedType> Enumerations
%type <Enumeration> Enumeration RootEnumeration AdditionalEnumeration
%type <EnumerationItem> EnumerationItem

//
// end declarations
////////////////////////////

%%

////////////////////////////
// grammar/rules section
//

// Code inside the grammar actions may refer to the variable yylex,
// which holds the yyLexer passed to yyParse.

ModuleDefinition :
    ModuleIdentifier
    DEFINITIONS
    TagDefault
    ExtensionDefault
    ASSIGNMENT
    BEGIN
    ModuleBody
    END
    { yylex.(*ASN1Lexer).result = &ModuleDefinition{ModuleIdentifier: $1, TagDefault: $3, ExtensibilityImplied: $4, ModuleBody: $7} }
;

typereference: TYPEORMODULEREFERENCE  { $$ = TypeReference($1) }
;

modulereference: TYPEORMODULEREFERENCE;

valuereference: VALUEIDENTIFIER  {  $$ = ValueReference($1)  }
;

number : NUMBER
;

identifier: VALUEIDENTIFIER;

ModuleIdentifier :
                   modulereference
                   DefinitiveIdentifier
                   { $$ = ModuleIdentifier{Reference: $1, DefinitiveIdentifier: $2} }
;

DefinitiveIdentifier : OPEN_CURLY DefinitiveObjIdComponentList CLOSE_CURLY { $$ = DefinitiveIdentifier($2) }
                     | /*empty*/ { $$ = DefinitiveIdentifier(make([]DefinitiveObjIdComponent, 0)) }
;

DefinitiveObjIdComponentList :  DefinitiveObjIdComponent  { $$ = append(make([]DefinitiveObjIdComponent, 0), $1) }
                             | DefinitiveObjIdComponent DefinitiveObjIdComponentList  { $$ = append(append(make([]DefinitiveObjIdComponent, 0), $1), $2...) }
;

DefinitiveObjIdComponent : NameForm  { $$ = DefinitiveObjIdComponent{Name: $1} }
                         | DefinitiveNumberForm  { $$ = DefinitiveObjIdComponent{Id: $1.IntValue()} }
                         | DefinitiveNameAndNumberForm  { $$ = $1 }
;

DefinitiveNumberForm : NUMBER  { $$ = $1 }
;

DefinitiveNameAndNumberForm : identifier OPEN_ROUND DefinitiveNumberForm CLOSE_ROUND
                                { $$ = DefinitiveObjIdComponent{Name: $1, Id: $3.IntValue()}  }
;

TagDefault : EXPLICIT TAGS   { $$ = TAGS_EXPLICIT }
           | IMPLICIT TAGS   { $$ = TAGS_IMPLICIT }
           | AUTOMATIC TAGS  { $$ = TAGS_AUTOMATIC }
           | /*empty*/       { $$ = TAGS_EXPLICIT }
;

ExtensionDefault : EXTENSIBILITY IMPLIED { $$ = true }
                 | /*empty*/             { $$ = false }
;

ModuleBody : Exports Imports AssignmentList  { $$ = ModuleBody{Imports: $2, AssignmentList: $3} }
           | /*empty*/  { $$ = ModuleBody{} }
;


Exports : EXPORTS SymbolsExported SEMICOLON
        | EXPORTS ALL SEMICOLON
        | /*empty*/
;

SymbolsExported : SymbolList
                | /*empty*/
;

Imports : IMPORTS SymbolsImported SEMICOLON  { $$ = $2 }
        | /*empty*/  { $$ = make([]SymbolsFromModule, 0) }
;

SymbolsImported : SymbolsFromModuleList  { $$ = $1 }
                | /*empty*/  { $$ = make([]SymbolsFromModule, 0) }
;

SymbolsFromModuleList : SymbolsFromModule  { $$ = append(make([]SymbolsFromModule, 0), $1) }
                      | SymbolsFromModuleList SymbolsFromModule  { $$ = append($1, $2) }
;

SymbolsFromModule : SymbolList FROM GlobalModuleReference  { $$ = SymbolsFromModule{$1, $3} }
;

GlobalModuleReference : modulereference AssignedIdentifier  { $$ = GlobalModuleReference{$1, $2} }
;

AssignedIdentifier : ObjectIdentifierValue  { $$ = $1 }
                   | DefinedValue  { $$ = $1 }
                   | /*empty*/  { $$ = nil }
;

SymbolList : Symbol  { $$ = append(make([]Symbol, 0), $1) }
           | SymbolList COMMA Symbol  { $$ = append($1, $3) }
;

Symbol : Reference
//       | ParameterizedReference
;

Reference : typereference  { $$ = TypeReference($1) }
          | modulereference  { $$ = ModuleReference($1) }
          | valuereference   { $$ = ValueReference($1) }
//          | objectclassreference
//          | objectreference
//          | objectsetreference
;

AssignmentList : Assignment  { $$ = AssignmentList{$1} }
               | AssignmentList Assignment  { $$ = append($1, $2) }
;

Assignment : TypeAssignment
           | ValueAssignment
//           | XMLValueAssignment
//           | ValueSetTypeAssignment
//           | ObjectClassAssignment
//           | ObjectAssignment
//           | ObjectSetAssignment
//           | ParameterizedAssignment
;

// 13.1

DefinedType : // ExternalTypeReference
            /*|*/ typereference  { $$ = $1 }
//            | ParameterizedType
//            | ParameterizedValueSetType
;

// 13.3

DefinedValue :
   modulereference DOT valuereference  { $$ = DefinedValue{ModuleReference($1), $3} }
   | valuereference  { $$ = DefinedValue{ValueName: $1} }
// | ParameterizedValue
;

// 13.6

// Not used, defined inline in DefinedValue to simplicy and avoid yacc conflicts.
// ExternalValueReference ::=
//    modulereference
//    "."
//    valuereference


// 15.1

TypeAssignment : typereference ASSIGNMENT Type  { $$ = TypeAssignment{$1, $3} }
;

ValueAssignment : valuereference Type ASSIGNMENT Value  { $$ = ValueAssignment{$1, $2, $4} }
;

// 16.1

Type : BuiltinType
     | ReferencedType
     | ConstrainedType
;

// 16.2

BuiltinType : BitStringType
            | BooleanType
            | CharacterStringType
            | ChoiceType
//            | EmbeddedPDVType
            | EnumeratedType
//            | ExternalType
//            | InstanceOfType
            | IntegerType
            | NullType
//            | ObjectClassFieldType
            | ObjectIdentifierType
            | OctetStringType
            | RealType
//            | RelativeOIDType
            | SequenceType
            | SequenceOfType
            | SetType
            | SetOfType
// modification - taken from X.208
            | AnyType
            | TaggedType
;

// 16.3

ReferencedType : DefinedType
               | UsefulType
//               | SelectionType
//               | TypeFromObject
//               | ValueSetFromObjects
;

// 16.5

NamedType : identifier Type  { $$ = NamedType{Identifier: Identifier($1), Type: $2} }
;

// 16.7

Value : BuiltinValue
//      | ReferencedValue
//      | ObjectClassFieldValue
;

// 16.8

// TODO
BuiltinValue : // BitStringValue
             /*|*/ BooleanValue
//             | CharacterStringValue
//             | ChoiceValue
//             | EmbeddedPDVValue
//             | EnumeratedValue
//             | ExternalValue
//             | InstanceOfValue
               | IntegerValue
//             | NullValue
               | ObjectIdentifierValue  { $$ = $1 }
//             | OctetStringValue
               | RealValue
//             | RelativeOIDValue
//             | SequenceValue
//             | SequenceOfValue
//             | SetValue
//             | SetOfValue
//             | TaggedValue
;

// 17.3

BooleanType : BOOLEAN  { $$ = BooleanType{} }
;

BooleanValue : TRUE  { $$ = Boolean(true) }
             | FALSE  { $$ = Boolean(false) }
;

// 18.1

IntegerType : INTEGER  { $$ = IntegerType{} }
            | INTEGER OPEN_CURLY NamedNumberList CLOSE_CURLY  { $$ = IntegerType{$3} }
;

NamedNumberList : NamedNumber  { $$ = []NamedNumber{$1} }
                | NamedNumberList COMMA NamedNumber  { $$ = append($1, $3) }
;

NamedNumber : identifier OPEN_ROUND SignedNumber CLOSE_ROUND  { $$ = NamedNumber{Identifier($1), $3} }
          | identifier OPEN_ROUND DefinedValue CLOSE_ROUND  { $$ = NamedNumber{Identifier($1), $3} }
;

SignedNumber : NUMBER  { $$ = $1 }
             | MINUS NUMBER  { $$ = $2.UnaryMinus() }
;

// 18.9

IntegerValue : SignedNumber  { $$ = $1 }
             | identifier  { $$ = IdentifiedIntegerValue{Name: $1} }
;

// 19.1

EnumeratedType : ENUMERATED OPEN_CURLY Enumerations CLOSE_CURLY  { $$ = $3 }
;

Enumerations : RootEnumeration  { $$ = EnumeratedType{RootEnumeration: $1} }
             | RootEnumeration COMMA ELLIPSIS ExceptionSpec  { $$ = EnumeratedType{RootEnumeration: $1} }
             | RootEnumeration COMMA ELLIPSIS ExceptionSpec COMMA AdditionalEnumeration  { $$ = EnumeratedType{RootEnumeration: $1, AdditionalEnumeration: $6} }

RootEnumeration : Enumeration
;

AdditionalEnumeration : Enumeration
;

Enumeration : EnumerationItem  { $$ = []EnumerationItem{$1} }
            | EnumerationItem COMMA Enumeration  { $$ = append([]EnumerationItem{$1}, $3...) }
;

EnumerationItem : NamedNumber  { $$ = $1 }
                | identifier  { $$ = Identifier($1) }
;

// 20.1

RealType : REAL  { $$ = RealType{} }
;

// 20.6

RealValue : NumericRealValue
          | SpecialRealValue
;

NumericRealValue : realnumber  { $$ = $1 }
                 | MINUS realnumber  { $$ = $2.UnaryMinus() }
//                 | SequenceValue     // Value of the associated sequence type
;

SpecialRealValue : PLUS_INFINITY  { $$ = Real(math.Inf(1)) }
                 | MINUS_INFINITY  { $$ = Real(math.Inf(-1)) }
;

// TODO this seem to be not strict enough (spaces can sneak in into composite value)
realnumber : NUMBER  { $$ = parseRealNumber($1, 0, 0) }
           | NUMBER DOT NUMBER  { $$ = parseRealNumber($1, $3, 0) }
           | NUMBER DOT NUMBER EXPONENT SignedExponent  { $$ = parseRealNumber($1, $3, $5) }
           | NUMBER EXPONENT SignedExponent  { $$ = parseRealNumber($1, 0, $3) }
;

SignedExponent : NUMBER
               | MINUS NUMBER  { $$ = Number(-int($2)) }
;

// 21.1

BitStringType : BIT STRING  { $$ = BitStringType{} }
              | BIT STRING OPEN_CURLY NamedBitList CLOSE_CURLY  { $$ = BitStringType{NamedBits: $4} }
;

NamedBitList : NamedBit  { $$ = append(make([]NamedBit, 0), $1) }
             | NamedBitList COMMA NamedBit  { $$ = append($1, $3) }
;

NamedBit : identifier OPEN_ROUND number CLOSE_ROUND  { $$ = NamedBit{Name: Identifier($1), Index: $3} }
         | identifier OPEN_ROUND DefinedValue CLOSE_ROUND  { $$ = NamedBit{Name: Identifier($1), Index: $3} }
;

// 22.1

OctetStringType : OCTET STRING  { $$ = OctetStringType{} }
;

// 23.1

NullType : NULL  { $$ = NullType{} }
;

// 24.1

SequenceType : SEQUENCE OPEN_CURLY CLOSE_CURLY  { $$ = SequenceType{} }
             | SEQUENCE OPEN_CURLY ExtensionAndException OptionalExtensionMarker CLOSE_CURLY  { $$ = SequenceType{} }
             | SEQUENCE OPEN_CURLY ComponentTypeLists CLOSE_CURLY  { $$ = SequenceType{Components: append($3.Components, $3.TrailingComponents...), ExtensionAdditions: $3.ExtensionAdditions} }
;

ExtensionAndException : ELLIPSIS
                      | ELLIPSIS ExceptionSpec
;

OptionalExtensionMarker : COMMA ELLIPSIS | /*empty*/
;

// TODO Extensions are not fully supported, extension information will be ignored.
// Edited from the doc - ComponentTypeList used directly instead of RootComponentTypeList to avoid ambiguity around COMMA.
ComponentTypeLists : ComponentTypeList  { $$ = ComponentTypeLists{Components: $1} }
                   | ComponentTypeList COMMA ExtensionAndException ExtensionAdditions OptionalExtensionMarker  { $$ = ComponentTypeLists{Components: $1, ExtensionAdditions: $4} }
                   | ComponentTypeList COMMA ExtensionAndException ExtensionAdditions ExtensionEndMarker COMMA ComponentTypeList  { $$ = ComponentTypeLists{Components: $1, ExtensionAdditions: $4, TrailingComponents: $7} }
//                   | ExtensionAndException ExtensionAdditions ExtensionEndMarker "," RootComponentTypeList
//                   | ExtensionAndException ExtensionAdditions OptionalExtensionMarker
;

// Unused, as it generates ambiguity around COMMA in ComponentTypeLists
RootComponentTypeList : ComponentTypeList
;

ExtensionEndMarker : COMMA ELLIPSIS
;

ExtensionAdditions : COMMA ExtensionAdditionList  { $$ = $2 }
                   | /*empty*/  { $$ = nil }
;

ExtensionAdditionList : ExtensionAddition  { $$ = append([]ExtensionAddition{}, $1...) }
                      | ExtensionAdditionList COMMA ExtensionAddition  { $$ = append($1, $3...) }
;

ExtensionAddition : ComponentType  { $$ = []ExtensionAddition{$1} }
                  | ExtensionAdditionGroup  { $$ = nil }

ExtensionAdditionGroup : LEFT_VERSION_BRACKETS VersionNumber ComponentTypeList RIGHT_VERSION_BRACKETS
;

VersionNumber : /*empty*/
              | NUMBER COLON
;

ComponentTypeList : ComponentType  { $$ = append(make(ComponentTypeList, 0), $1) }
                  | ComponentTypeList COMMA ComponentType  { $$ = append($1, $3) }
;

ComponentType : NamedType  { $$ = NamedComponentType{NamedType: $1} }
              | NamedType OPTIONAL  { $$ = NamedComponentType{NamedType: $1, IsOptional: true} }
              | NamedType DEFAULT Value  { $$ = NamedComponentType{NamedType: $1, Default: &$3} }
              | COMPONENTS OF Type  { $$ = ComponentsOfComponentType{Type: $3} }
;

// 26.1

SetType :  SET OPEN_CURLY CLOSE_CURLY  { $$ = SetType{} }
        |  SET OPEN_CURLY ExtensionAndException OptionalExtensionMarker CLOSE_CURLY  { $$ = SetType{} }
        |  SET OPEN_CURLY ComponentTypeLists CLOSE_CURLY  { $$ = SetType{Components: append($3.Components, $3.TrailingComponents...), ExtensionAdditions: $3.ExtensionAdditions} }


// 27.1

SetOfType : SET OF Type  { $$ = SetOfType{$3} }
          | SET OF NamedType  { $$ = SetOfType{$3} }

// 27.1 from x.208

AnyType : ANY  { $$ = AnyType{} }
        | ANY DEFINED BY identifier  { $$ = AnyType{Identifier($4)} }

// 28.1


ChoiceType : CHOICE OPEN_CURLY AlternativeTypeLists CLOSE_CURLY  { $$ = $3 }
;

AlternativeTypeLists : AlternativeTypeList COMMA ExtensionAndException ExtensionAdditionAlternatives OptionalExtensionMarker { $$ = ChoiceType{$1,$4} }
                     | AlternativeTypeList  { $$ = ChoiceType{AlternativeTypeList: $1} }
                     | ExtensionAndException ExtensionAdditionAlternatives OptionalExtensionMarker { $$ = ChoiceType{nil, $2} }
;

// defined in grammar, but screws up ExtensionAndException parsing
RootAlternativeTypeList : AlternativeTypeList
;

ExtensionAdditionAlternatives : COMMA ExtensionAdditionAlternativesList { $$ = $2 }
                              | /*empty*/ { $$ = make([]ChoiceExtension, 0) }
;

ExtensionAdditionAlternativesList : ExtensionAdditionAlternative  { $$ = append(make([]ChoiceExtension, 0), $1) }
                                  | ExtensionAdditionAlternativesList COMMA ExtensionAdditionAlternative  { $$ = append($1, $3) }
;

ExtensionAdditionAlternative : /*ExtensionAdditionAlternativesGroup
                             | */NamedType  { $$ = $1 }
;

// TODO
ExtensionAdditionAlternativesGroup : LEFT_VERSION_BRACKETS VersionNumber AlternativeTypeList RIGHT_VERSION_BRACKETS
;

AlternativeTypeList : NamedType  { $$ = append(make([]NamedType, 0), $1) }
                    | AlternativeTypeList COMMA NamedType  { $$ = append($1, $3) }
;

// 30.1

TaggedType : Tag Type  { $$ = TaggedType{Tag: $1, Type: $2} }
           | Tag IMPLICIT Type  { $$ = TaggedType{Tag: $1, Type: $3, TagType: TAGS_IMPLICIT, HasTagType: true} }
           | Tag EXPLICIT Type  { $$ = TaggedType{Tag: $1, Type: $3, TagType: TAGS_EXPLICIT, HasTagType: true} }
;

Tag : OPEN_SQUARE Class ClassNumber CLOSE_SQUARE  { $$ = Tag{Class: $2, ClassNumber: $3} }
;

ClassNumber : number  { $$ = $1 }
            | DefinedValue  { $$ = $1 }
;

Class : UNIVERSAL  { $$ = CLASS_UNIVERSAL }
      | APPLICATION  { $$ = CLASS_APPLICATION }
      | PRIVATE    { $$ = CLASS_PRIVATE }
      | /*empty*/  { $$ = CLASS_CONTEXT_SPECIFIC }
;

// 25.1

SequenceOfType : SEQUENCE OF Type  { $$ = SequenceOfType{$3} }
               | SEQUENCE OF NamedType  { $$ = SequenceOfType{$3} }
;

// 31.1

ObjectIdentifierType : OBJECT IDENTIFIER  { $$ = ObjectIdentifierType{} }
;

// 31.3

ObjectIdentifierValue : OPEN_CURLY ObjIdComponentsList CLOSE_CURLY  { $$ = $2 }
                      | OPEN_CURLY DefinedValue ObjIdComponentsList CLOSE_CURLY  { $$ = append(ObjectIdentifierValue{ObjectIdElement{Reference: &$2}}, $3...) }
;

ObjIdComponentsList :  ObjIdComponents  { $$ = ObjectIdentifierValue{$1}  }
                    | ObjIdComponents ObjIdComponentsList  { $$ = append(ObjectIdentifierValue{$1}, $2...)  }
;

ObjIdComponents : NameForm  { $$ = ObjectIdElement{Name: $1} }
                | NumberForm
                | NameAndNumberForm
                | DefinedValue  { cpy := $1; $$ = ObjectIdElement{Reference: &cpy} }
;

NumberForm : NUMBER   { $$ = ObjectIdElement{ID: $1.IntValue()} }
           | DefinedValue  { cpy := $1; $$ = ObjectIdElement{Reference: &cpy} }
;

NameAndNumberForm : identifier OPEN_ROUND NumberForm CLOSE_ROUND
    { $$ = ObjectIdElement{Name: $1, ID: $3.ID , Reference: $3.Reference} }
;

NameForm : identifier
;

// 36.1

CharacterStringType : RestrictedCharacterStringType
                    | UnrestrictedCharacterStringType
;

RestrictedCharacterStringType    : BMPString  { $$ = RestrictedStringType{LexType: BMPString} }
                                 | GeneralString  { $$ = RestrictedStringType{LexType: GeneralString} }
                                 | GraphicString  { $$ = RestrictedStringType{LexType: GraphicString} }
                                 | IA5String  { $$ = RestrictedStringType{LexType: IA5String} }
                                 | ISO646String  { $$ = RestrictedStringType{LexType: ISO646String} }
                                 | NumericString  { $$ = RestrictedStringType{LexType: NumericString} }
                                 | PrintableString  { $$ = RestrictedStringType{LexType: PrintableString} }
                                 | TeletexString  { $$ = RestrictedStringType{LexType: TeletexString} }
                                 | T61String  { $$ = RestrictedStringType{LexType: T61String} }
                                 | UniversalString  { $$ = RestrictedStringType{LexType: UniversalString} }
                                 | UTF8String  { $$ = RestrictedStringType{LexType: UTF8String} }
                                 | VideotexString  { $$ = RestrictedStringType{LexType: VideotexString} }
                                 | VisibleString  { $$ = RestrictedStringType{LexType: VisibleString} }
;

// 40.1

UnrestrictedCharacterStringType : CHARACTER STRING  { $$ = CharacterStringType{} }
;

// 41.1

UsefulType : GeneralizedTime  { $$ = TypeReference("GeneralizedTime") }
           | UTCTime  { $$ = TypeReference("UTCTime") }
;

// 45.1

ConstrainedType : Type Constraint  { $$ = ConstraintedType{$1, $2} }
                | TypeWithConstraint
;

// 45.5

TypeWithConstraint : SET Constraint OF Type  { $$ = ConstraintedType{SetOfType{$4}, $2} }
                   | SET SizeConstraint OF Type  { $$ = ConstraintedType{SetOfType{$4}, SingleElementConstraint($2)} }
                   | SEQUENCE Constraint OF Type  { $$ = ConstraintedType{SequenceOfType{$4}, $2} }
                   | SEQUENCE SizeConstraint OF Type  { $$ = ConstraintedType{SequenceOfType{$4}, SingleElementConstraint($2)} }
                   | SET Constraint OF NamedType  { $$ = ConstraintedType{SetOfType{$4}, $2} }
                   | SET SizeConstraint OF NamedType  { $$ = ConstraintedType{SetOfType{$4}, SingleElementConstraint($2)} }
                   | SEQUENCE Constraint OF NamedType  { $$ = ConstraintedType{SequenceOfType{$4}, $2} }
                   | SEQUENCE SizeConstraint OF NamedType  { $$ = ConstraintedType{SequenceOfType{$4}, SingleElementConstraint($2)} }
;

// 45.6

Constraint : OPEN_ROUND ConstraintSpec ExceptionSpec CLOSE_ROUND  { $$ = Constraint{ConstraintSpec: $2} }
;

ConstraintSpec : SubtypeConstraint  { $$ = $1 }
//               | GeneralConstraint
;

SubtypeConstraint : ElementSetSpecs
;

// 46.1

ElementSetSpecs : RootElementSetSpec
                | RootElementSetSpec COMMA ELLIPSIS  { $$ = $1 }
                | RootElementSetSpec COMMA ELLIPSIS COMMA AdditionalElementSetSpec  { $$ = append($1, $5) }
;

RootElementSetSpec : ElementSetSpec  { $$ = SubtypeConstraint{$1} }
;

AdditionalElementSetSpec : ElementSetSpec
;

ElementSetSpec : Unions  { $$ = $1 }
               | ALL Exclusions  { $$ = $2 }
;

Unions : Intersections  { $$ = Unions{$1} }
       | UElems UnionMark Intersections    { $$ = append($1, $3) }
;

UElems : Unions
;

Intersections : IntersectionElements { $$ = Intersections{$1} }
              | IElems IntersectionMark IntersectionElements  { $$ = append($1, $3)  }
;

IElems : Intersections
;

IntersectionElements : Elements  { $$ = IntersectionElements{Elements: $1} }
                     | Elems Exclusions  { $$ = IntersectionElements{Elements: $1, Exclusions: $2} }
;

Elems : Elements
;

Exclusions : EXCEPT Elements  { $$ = Exclusions{$2} }
;

UnionMark : PIPE | UNION
;

IntersectionMark : CARET | INTERSECTION
;

Elements : SubtypeElements { $$ = $1 }
//         | ObjectSetElements
         | OPEN_ROUND ElementSetSpec CLOSE_ROUND  { $$ = $2 }
;

SubtypeElements : SingleValue
//                | ContainedSubtype
                | ValueRange
//                | PermittedAlphabet
                | SizeConstraint
                | TypeConstraint
                | InnerTypeConstraints
//                | PatternConstraint
;

// 47.2

SingleValue : Value  { $$ = SingleValue{$1} }
;

// 47.4

ValueRange : LowerEndpoint RANGE_SEPARATOR UpperEndpoint  { $$ = ValueRange{$1, $3} }
;

LowerEndpoint : LowerEndValue  { $$ = RangeEndpoint{Value: $1} }
              | LowerEndValue LESS   { $$ = RangeEndpoint{Value: $1, IsOpen: true} }
;

UpperEndpoint : UpperEndValue  { $$ = RangeEndpoint{Value: $1} }
              | LESS UpperEndValue   { $$ = RangeEndpoint{Value: $2, IsOpen: true} }
;

LowerEndValue : Value
              | MIN  { $$ = nil }
;

UpperEndValue : Value
              | MAX  { $$ = nil }
;

// 47.5

SizeConstraint : SIZE Constraint  { $$ = SizeConstraint{$2} }
;

// 47.6.1

TypeConstraint : Type  { $$ = TypeConstraint{$1} }
;

// 47.8.1

InnerTypeConstraints :  WITH COMPONENT SingleTypeConstraint  { $$ = InnerTypeConstraint{} }
                     | WITH COMPONENTS MultipleTypeConstraints  { $$ = InnerTypeConstraint{} }
;

SingleTypeConstraint : Constraint
;

MultipleTypeConstraints : FullSpecification
                        | PartialSpecification
;

FullSpecification : OPEN_CURLY TypeConstraints CLOSE_CURLY
;

PartialSpecification : OPEN_CURLY ELLIPSIS COMMA TypeConstraints CLOSE_CURLY
;

TypeConstraints :  NamedConstraint
                | NamedConstraint COMMA TypeConstraints

NamedConstraint : identifier ComponentConstraint
;

ComponentConstraint : ValueConstraint PresenceConstraint
;

ValueConstraint : Constraint | /*empty*/
;

PresenceConstraint : PRESENT | ABSENT | OPTIONAL | /*empty*/
;

// 49.4

ExceptionSpec : EXCLAMATION ExceptionIdentification
              | /* empty */
;

ExceptionIdentification : SignedNumber
                        | DefinedValue
                        | Type COLON Value
;

///// X.681

// 12.10

// ObjectSetElements ::=
//  Object
//  | DefinedObjectSet
//  | ObjectSetFromObjects
//  | ParameterizedObjectSet

//
// end grammar
////////////////////////////

%%