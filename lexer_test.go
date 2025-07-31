package asn1go

import (
	"bufio"
	"strings"
	"testing"
)

func lexForString(str string) *ASN1Lexer {
	reader := bufio.NewReader(strings.NewReader(str))
	return &ASN1Lexer{bufReader: reader}
}

func testLexemType(t *testing.T, input string, expectedType int) {
	noGetter := func(*yySymType) string { return "" }
	testLexem(t, noGetter, input, expectedType, "")
}

func testLexem(t *testing.T, getter func(*yySymType) string, input string, expectedType int, output string) {
	str := input
	lex := lexForString(str)
	symType := &yySymType{}
	gotType := lex.Lex(symType)
	if lex.err != nil {
		t.Errorf("At %s: Expected nil error, got %v", input, lex.err)
	}
	if gotType != expectedType {
		t.Errorf("At %s: Expected %v token, got %v", input, expectedType, gotType)
	}
	expectedName := output
	if getter(symType) != expectedName {
		t.Errorf("At %s: Expected lexem '%v' to be read, got '%v'", input, expectedName, getter(symType))
	}
}

func testNumber(t *testing.T, input string, expectedValue Number) {
	str := input
	lex := lexForString(str)
	symType := &yySymType{}
	gotType := lex.Lex(symType)
	if lex.err != nil {
		t.Errorf("Expected nil error, got %v", lex.err)
	}
	expectedType := NUMBER
	if gotType != expectedType {
		t.Errorf("Expected %v token, got %v", expectedType, gotType)
	}
	if symType.Number != expectedValue {
		t.Errorf("Expected lexem '%v' to be read, got '%v'", expectedValue, symType.Number)
	}
}

func testError(t *testing.T, input string, expectedErr string) {
	str := input
	lex := lexForString(str)
	symType := &yySymType{}
	lex.Lex(symType)
	if lex.err == nil || lex.err.Error() != expectedErr {
		t.Errorf("Expected '%v' error, got '%v'", expectedErr, lex.err)
	}
}

func utr(t *yySymType) string {
	return t.name
}

func ui(t *yySymType) string {
	return t.name
}

func TestTypeReference(t *testing.T) {
	testLexem(t, utr, "MyTypeReference", TYPEORMODULEREFERENCE, "MyTypeReference")
	testLexem(t, utr, "My-Type-Reference", TYPEORMODULEREFERENCE, "My-Type-Reference")
	testError(t, "My--Type-Reference", "line 1: token can not contain two hyphens in a row, got My--")
	testError(t, "MyTypeReference-", "line 1: token can not end on hyphen, got MyTypeReference-")
}

func TestIdentifier(t *testing.T) {
	testLexem(t, ui, "myIdentifier", VALUEIDENTIFIER, "myIdentifier")
	testLexem(t, ui, "my-Identifier", VALUEIDENTIFIER, "my-Identifier")
	testError(t, "my--Identifier", "line 1: token can not contain two hyphens in a row, got my--")
	testError(t, "myIdentifier-", "line 1: token can not end on hyphen, got myIdentifier-")
}

func TestSpacing(t *testing.T) {
	testLexem(t, ui, "   myIdentifier   ", VALUEIDENTIFIER, "myIdentifier")
}

func TestNoSpacing(t *testing.T) {
	lex := lexForString("myIdentifier(")
	symType := &yySymType{}
	if r := lex.Lex(symType); r != VALUEIDENTIFIER {
		t.Errorf("Expected identifier (%v), got %v", VALUEIDENTIFIER, r)
	}
	if lex.err != nil {
		t.Errorf("Got error: %v", lex.err)
	}
	if symType.name != "myIdentifier" {
		t.Errorf("Expected myIdentifier, got '%v'", symType.name)
	}
	if r := lex.Lex(symType); r != OPEN_ROUND {
		t.Errorf("Expected OPEN_ROUND (%v), got %v", OPEN_ROUND, r)
	}
}

func TestComments(t *testing.T) {
	testLexem(t, ui, "myIdentifier --thisisacomment", VALUEIDENTIFIER, "myIdentifier")

	testLexem(t, ui, `
	-- this is one comment
	-- this is second comment
	myIdentifier -- this is another comment
	-- this is trailing comment
	`, VALUEIDENTIFIER, "myIdentifier")

	testLexem(t, ui, "--comment1-- -- c-o-mm-ent2 -- myIdentifier --comment3-- ", VALUEIDENTIFIER, "myIdentifier")

	testLexem(t, ui, `
	/*
	this is a comment
	*/

	/* this is another comment */

	/*
	this
	/* is nested comment */
	*/

	myIdentifier
	`, VALUEIDENTIFIER, "myIdentifier")
}

func TestNumber(t *testing.T) {
	testNumber(t, "0", Number(0))
	testNumber(t, "1", Number(1))
	testNumber(t, "123", Number(123))
	testNumber(t, "12345", Number(12345))
}

func TestAssignment(t *testing.T) {
	testLexemType(t, "::=", ASSIGNMENT)
}

func TestRangeSeparator(t *testing.T) {
	testLexemType(t, "..", RANGE_SEPARATOR)
}

func TestEllipsis(t *testing.T) {
	testLexemType(t, "...", ELLIPSIS)
}

func TestLeftVersionBrackets(t *testing.T) {
	testLexemType(t, "[[", LEFT_VERSION_BRACKETS)
}

func TestRightVersionBrackets(t *testing.T) {
	testLexemType(t, "]]", RIGHT_VERSION_BRACKETS)
}

func TestPeekRunes(t *testing.T) {
	lexer := lexForString("aХc￥eЙ")
	if v := lexer.peekRunes(1); v != "a" {
		t.Errorf("Expected 'a' got %s", v)
	}
	if v := lexer.peekRunes(2); v != "aХ" {
		t.Errorf("Expected 'aХ' got %s", v)
	}
	if v := lexer.peekRunes(3); v != "aХc" {
		t.Errorf("Expected 'aХc' got %s", v)
	}
	if v := lexer.peekRunes(4); v != "aХc￥" {
		t.Errorf("Expected 'aХc￥' got %s", v)
	}

	lexer = lexForString("abc")
	lexer.readRune()
	lexer.readRune()
	if v := lexer.peekRunes(2); v != "c" {
		t.Errorf("Expected 'c' got '%s' (len=%v)", v, len(v))
	}
}

func TestSingleSymbolTokens(t *testing.T) {
	testLexemType(t, "{", OPEN_CURLY)
	testLexemType(t, "}", CLOSE_CURLY)
	testLexemType(t, "<", LESS)
	testLexemType(t, ">", GREATER)
	testLexemType(t, ",", COMMA)
	testLexemType(t, ".", DOT)
	testLexemType(t, "(", OPEN_ROUND)
	testLexemType(t, ")", CLOSE_ROUND)
	testLexemType(t, "[", OPEN_SQUARE)
	testLexemType(t, "]", CLOSE_SQUARE)
	testLexemType(t, "-", MINUS)
	testLexemType(t, ":", COLON)
	testLexemType(t, "=", EQUALS)
	testLexemType(t, "\"", QUOTATION_MARK)
	testLexemType(t, "'", APOSTROPHE)
	//testLexemType(t, " ", SPACE)  // TODO
	testLexemType(t, ";", SEMICOLON)
	testLexemType(t, "@", AT)
	testLexemType(t, "|", PIPE)
	testLexemType(t, "!", EXCLAMATION)
	testLexemType(t, "^", CARET)
}

func TestReservedWords(t *testing.T) {
	testLexemType(t, "ABSENT", ABSENT)
	testLexemType(t, "ENCODED", ENCODED)
	testLexemType(t, "INTEGER", INTEGER)
	testLexemType(t, "RELATIVE-OID", RELATIVE_OID)
	testLexemType(t, "ABSTRACT-SYNTAX", ABSTRACT_SYNTAX)
	testLexemType(t, "END", END)
	testLexemType(t, "INTERSECTION", INTERSECTION)
	testLexemType(t, "SEQUENCE", SEQUENCE)
	testLexemType(t, "ALL", ALL)
	testLexemType(t, "ENUMERATED", ENUMERATED)
	testLexemType(t, "ISO646String", ISO646String)
	testLexemType(t, "SET", SET)
	testLexemType(t, "APPLICATION", APPLICATION)
	testLexemType(t, "EXCEPT", EXCEPT)
	testLexemType(t, "MAX", MAX)
	testLexemType(t, "SIZE", SIZE)
	testLexemType(t, "AUTOMATIC", AUTOMATIC)
	testLexemType(t, "EXPLICIT", EXPLICIT)
	testLexemType(t, "MIN", MIN)
	testLexemType(t, "STRING", STRING)
	testLexemType(t, "BEGIN", BEGIN)
	testLexemType(t, "EXPORTS", EXPORTS)
	testLexemType(t, "MINUS-INFINITY", MINUS_INFINITY)
	testLexemType(t, "SYNTAX", SYNTAX)
	testLexemType(t, "BIT", BIT)
	testLexemType(t, "EXTENSIBILITY", EXTENSIBILITY)
	testLexemType(t, "NULL", NULL)
	testLexemType(t, "T61String", T61String)
	testLexemType(t, "BMPString", BMPString)
	testLexemType(t, "EXTERNAL", EXTERNAL)
	testLexemType(t, "NumericString", NumericString)
	testLexemType(t, "TAGS", TAGS)
	testLexemType(t, "BOOLEAN", BOOLEAN)
	testLexemType(t, "FALSE", FALSE)
	testLexemType(t, "OBJECT", OBJECT)
	testLexemType(t, "TeletexString", TeletexString)
	testLexemType(t, "BY", BY)
	testLexemType(t, "FROM", FROM)
	testLexemType(t, "ObjectDescriptor", ObjectDescriptor)
	testLexemType(t, "TRUE", TRUE)
	testLexemType(t, "CHARACTER", CHARACTER)
	testLexemType(t, "GeneralizedTime", GeneralizedTime)
	testLexemType(t, "OCTET", OCTET)
	testLexemType(t, "TYPE-IDENTIFIER", TYPE_IDENTIFIER)
	testLexemType(t, "CHOICE", CHOICE)
	testLexemType(t, "GeneralString", GeneralString)
	testLexemType(t, "OF", OF)
	testLexemType(t, "UNION", UNION)
	testLexemType(t, "CLASS", CLASS)
	testLexemType(t, "GraphicString", GraphicString)
	testLexemType(t, "OPTIONAL", OPTIONAL)
	testLexemType(t, "UNIQUE", UNIQUE)
	testLexemType(t, "COMPONENT", COMPONENT)
	testLexemType(t, "IA5String", IA5String)
	testLexemType(t, "PATTERN", PATTERN)
	testLexemType(t, "UNIVERSAL", UNIVERSAL)
	testLexemType(t, "COMPONENTS", COMPONENTS)
	testLexemType(t, "IDENTIFIER", IDENTIFIER)
	testLexemType(t, "PDV", PDV)
	testLexemType(t, "UniversalString", UniversalString)
	testLexemType(t, "CONSTRAINED", CONSTRAINED)
	testLexemType(t, "IMPLICIT", IMPLICIT)
	testLexemType(t, "PLUS-INFINITY", PLUS_INFINITY)
	testLexemType(t, "UTCTime", UTCTime)
	testLexemType(t, "CONTAINING", CONTAINING)
	testLexemType(t, "IMPLIED", IMPLIED)
	testLexemType(t, "PRESENT", PRESENT)
	testLexemType(t, "UTF8String", UTF8String)
	testLexemType(t, "DEFAULT", DEFAULT)
	testLexemType(t, "IMPORTS", IMPORTS)
	testLexemType(t, "PrintableString", PrintableString)
	testLexemType(t, "VideotexString", VideotexString)
	testLexemType(t, "DEFINITIONS", DEFINITIONS)
	testLexemType(t, "INCLUDES", INCLUDES)
	testLexemType(t, "PRIVATE", PRIVATE)
	testLexemType(t, "VisibleString", VisibleString)
	testLexemType(t, "EMBEDDED", EMBEDDED)
	testLexemType(t, "INSTANCE", INSTANCE)
	testLexemType(t, "REAL", REAL)
	testLexemType(t, "WITH", WITH)
}

func TestRangeSynax(t *testing.T) {
	lexer := lexForString("INTEGER (-2147483648..2147483647)")

	sym := &yySymType{}
	if l := lexer.Lex(sym); l != INTEGER {
		t.Fatalf("Expected lexem INTEGER (%v) got %v", INTEGER, l)
	}

	if l := lexer.Lex(sym); l != OPEN_ROUND {
		t.Fatalf("Expected lexem OPEN_ROUND (%v) got %v", OPEN_ROUND, l)
	}

	if l := lexer.Lex(sym); l != MINUS {
		t.Fatalf("Expected lexem MINUS (%v) got %v", MINUS, l)
	}

	if l := lexer.Lex(sym); l != NUMBER {
		t.Fatalf("Expected lexem NUMBER (%v) got %v", NUMBER, l)
	}
	if sym.Number != Number(2147483648) {
		t.Errorf("Expected number value 2147483648 got %v", sym.Number)
	}

	if l := lexer.Lex(sym); l != RANGE_SEPARATOR {
		t.Fatalf("Expected lexem RANGE_SEPARATOR (%v) got %v", RANGE_SEPARATOR, l)
	}

	if l := lexer.Lex(sym); l != NUMBER {
		t.Fatalf("Expected lexem NUMBER (%v) got %v", NUMBER, l)
	}
	if sym.Number != Number(2147483647) {
		t.Errorf("Expected number value 2147483648 got %v", sym.Number)
	}

	if l := lexer.Lex(sym); l != CLOSE_ROUND {
		t.Fatalf("Expected lexem CLOSE_ROUND (%v) got %v", CLOSE_ROUND, l)
	}
}

type lexemListTest struct {
	input  string
	lexems []int
}

var realSyntaxTests = []lexemListTest{
	{"-1.2e5", []int{
		MINUS,
		NUMBER,
		DOT,
		NUMBER,
		EXPONENT,
		NUMBER,
		0,
	}},
	{"-1.2 e5", []int{
		MINUS,
		NUMBER,
		DOT,
		NUMBER,
		VALUEIDENTIFIER,
		0,
	}},
}

func TestRealSyntax(t *testing.T) {
	for _, test := range realSyntaxTests {
		lexer := lexForString(test.input)
		sym := &yySymType{}
		for _, expectedLexem := range test.lexems {
			if l := lexer.Lex(sym); l != expectedLexem {
				if lexer.err != nil {
					t.Fatalf("Input: %v\nErr should be nil, got: %v", test.input, lexer.err.Error())
				}
				t.Errorf("Input: %v\nExpected lexem %v got %v", test.input, tokName(expectedLexem), tokName(l))
			}
		}
	}

}

func tokName(tok int) string {
	if tok >= yyPrivate {
		return yyToknames[tok-yyPrivate+1]
	} else {
		return yyTokname(tok)
	}
}
