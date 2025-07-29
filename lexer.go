package asn1go

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"strconv"
	"unicode"
	"unicode/utf8"
)

var (
	reservedWords = map[string]int{
		"ABSENT":           ABSENT,
		"ABSTRACT-SYNTAX":  ABSTRACT_SYNTAX,
		"ALL":              ALL,
		"ANY":              ANY,
		"APPLICATION":      APPLICATION,
		"AUTOMATIC":        AUTOMATIC,
		"BEGIN":            BEGIN,
		"BIT":              BIT,
		"BMPString":        BMPString,
		"BOOLEAN":          BOOLEAN,
		"BY":               BY,
		"CHARACTER":        CHARACTER,
		"CHOICE":           CHOICE,
		"CLASS":            CLASS,
		"COMPONENT":        COMPONENT,
		"COMPONENTS":       COMPONENTS,
		"CONSTRAINED":      CONSTRAINED,
		"CONTAINING":       CONTAINING,
		"DEFAULT":          DEFAULT,
		"DEFINED":          DEFINED,
		"DEFINITIONS":      DEFINITIONS,
		"EMBEDDED":         EMBEDDED,
		"ENCODED":          ENCODED,
		"END":              END,
		"ENUMERATED":       ENUMERATED,
		"EXCEPT":           EXCEPT,
		"EXPLICIT":         EXPLICIT,
		"EXPORTS":          EXPORTS,
		"EXTENSIBILITY":    EXTENSIBILITY,
		"EXTERNAL":         EXTERNAL,
		"FALSE":            FALSE,
		"FROM":             FROM,
		"GeneralString":    GeneralString,
		"GeneralizedTime":  GeneralizedTime,
		"GraphicString":    GraphicString,
		"IA5String":        IA5String,
		"IDENTIFIER":       IDENTIFIER,
		"IMPLICIT":         IMPLICIT,
		"IMPLIED":          IMPLIED,
		"IMPORTS":          IMPORTS,
		"INCLUDES":         INCLUDES,
		"INSTANCE":         INSTANCE,
		"INTEGER":          INTEGER,
		"INTERSECTION":     INTERSECTION,
		"ISO646String":     ISO646String,
		"MAX":              MAX,
		"MIN":              MIN,
		"MINUS-INFINITY":   MINUS_INFINITY,
		"NULL":             NULL,
		"NumericString":    NumericString,
		"OBJECT":           OBJECT,
		"OCTET":            OCTET,
		"OF":               OF,
		"OPTIONAL":         OPTIONAL,
		"ObjectDescriptor": ObjectDescriptor,
		"PATTERN":          PATTERN,
		"PDV":              PDV,
		"PLUS-INFINITY":    PLUS_INFINITY,
		"PRESENT":          PRESENT,
		"PRIVATE":          PRIVATE,
		"PrintableString":  PrintableString,
		"REAL":             REAL,
		"RELATIVE-OID":     RELATIVE_OID,
		"SEQUENCE":         SEQUENCE,
		"SET":              SET,
		"SIZE":             SIZE,
		"STRING":           STRING,
		"SYNTAX":           SYNTAX,
		"T61String":        T61String,
		"TAGS":             TAGS,
		"TRUE":             TRUE,
		"TYPE-IDENTIFIER":  TYPE_IDENTIFIER,
		"TeletexString":    TeletexString,
		"UNION":            UNION,
		"UNIQUE":           UNIQUE,
		"UNIVERSAL":        UNIVERSAL,
		"UTCTime":          UTCTime,
		"UTF8String":       UTF8String,
		"UniversalString":  UniversalString,
		"VideotexString":   VideotexString,
		"VisibleString":    VisibleString,
		"WITH":             WITH,
	}
)

// ASN1Lexer is an ASN.1 lexer that is producing lexemes for the generated goyacc parser.
type ASN1Lexer struct {
	bufReader *bufio.Reader
	// err is used to store lexer or parser error.
	err error
	// result is where parsing result will be written by the parser.
	result        *ModuleDefinition
	lastWasNumber bool

	// lineNo is 0-indexed line number used for error reporting.
	lineNo int
}

// Lex implements yyLexer.
// It is reading runes from the bufReader, stores some state in lval if needed, and returns token type.
// If syntax error was detected, it saves it in err, and returns -1, which is understood by goyacc as end of input.
func (lex *ASN1Lexer) Lex(lval *yySymType) int {
	lastWasNumber := lex.lastWasNumber
	lex.lastWasNumber = false
	for {
		r, _, err := lex.readRune()
		if err == io.EOF {
			return 0
		}
		if err != nil {
			lex.Error(fmt.Sprintf("Failed to read: %v", err.Error()))
			return -1
		}

		// fast forward cases
		if isWhitespace(r) {
			lastWasNumber = false
			continue
		} else if r == '-' && lex.peekRune() == '-' {
			lex.skipLineComment()
			lastWasNumber = false
			continue
		} else if r == '/' && lex.peekRune() == '*' {
			lex.skipBlockComment()
			lastWasNumber = false
			continue
		}

		// parse lexeme
		if unicode.IsLetter(r) {
			if lastWasNumber && (r == 'e' || r == 'E') {
				return EXPONENT
			}
			lex.unreadRune()
			content, err := lex.consumeWord()
			if err != nil {
				lex.Error(err.Error())
				return -1
			}
			if unicode.IsUpper(r) {
				code, exists := reservedWords[content]
				if exists {
					return code
				} else {
					lval.name = content
					return TYPEORMODULEREFERENCE
				}
			} else {
				lval.name = content
				return VALUEIDENTIFIER
			}
		} else if unicode.IsDigit(r) {
			lex.unreadRune()
			lex.lastWasNumber = true
			return lex.consumeNumber(lval)
		} else if r == ':' && lex.peekRunes(2) == ":=" {
			lex.discard(2)
			return ASSIGNMENT
		} else if r == '.' && lex.peekRunes(2) == ".." {
			lex.discard(2)
			return ELLIPSIS
		} else if r == '.' && lex.peekRune() == '.' {
			lex.discard(1)
			return RANGE_SEPARATOR
		} else if r == '[' && lex.peekRune() == '[' {
			lex.discard(1)
			return LEFT_VERSION_BRACKETS
		} else if r == ']' && lex.peekRune() == ']' {
			lex.discard(1)
			return RIGHT_VERSION_BRACKETS
		} else {
			return lex.consumeSingleSymbol(r)
		}
	}
}

func (lex *ASN1Lexer) consumeSingleSymbol(r rune) int {
	switch r {
	case '{':
		return OPEN_CURLY
	case '}':
		return CLOSE_CURLY
	case '<':
		return LESS
	case '>':
		return GREATER
	case ',':
		return COMMA
	case '.':
		return DOT
	case '(':
		return OPEN_ROUND
	case ')':
		return CLOSE_ROUND
	case '[':
		return OPEN_SQUARE
	case ']':
		return CLOSE_SQUARE
	case '-':
		return MINUS
	case ':':
		return COLON
	case '=':
		return EQUALS
	case '"':
		return QUOTATION_MARK
	case '\'':
		return APOSTROPHE
	case ' ': // TODO at which context it can be parsed?
		return SPACE
	case ';':
		return SEMICOLON
	case '@':
		return AT
	case '|':
		return PIPE
	case '!':
		return EXCLAMATION
	case '^':
		return CARET
	default:
		lex.Error(fmt.Sprintf("Unexpected character: %c", r))
		return -1
	}
}

func (lex *ASN1Lexer) unreadRune() error {
	r := lex.bufReader.UnreadRune()
	// TODO(nsokolov): against guidelines, remove panic
	if r != nil {
		panic(r.Error())
	}
	if isNewline(lex.peekRune()) {
		lex.lineNo -= 1
	}
	return r
}

func (lex *ASN1Lexer) readRune() (rune, int, error) {
	r, n, err := lex.bufReader.ReadRune()
	if isNewline(r) {
		lex.lineNo += 1
	}
	return r, n, err
}

func (lex *ASN1Lexer) peekRune() rune {
	r, _ := lex.peekRuneE()
	return r
}

func (lex *ASN1Lexer) discard(n int) {
	lex.bufReader.Discard(n)
}

func (lex *ASN1Lexer) peekRunes(n int) string {
	acc := bytes.NewBufferString("")
	pos := 0
	for n > 0 {
		for l := 1; l <= utf8.UTFMax; l++ {
			buf, err := lex.bufReader.Peek(pos + l)
			slice := buf[pos : pos+l]
			if pos+l <= len(buf) && utf8.FullRune(slice) {
				r, size := utf8.DecodeRune(slice)
				acc.WriteRune(r)
				pos += size
				n -= 1
				break
			}
			if err == io.EOF { // TODO if it is not a full rune, will swallow the error
				return acc.String()
			}
		}
	}
	return acc.String()
}

func (lex *ASN1Lexer) peekRuneE() (rune, error) {
	r, _, err := lex.bufReader.ReadRune()
	if err == nil {
		lex.bufReader.UnreadRune()
	}
	return r, err
}

func (lex *ASN1Lexer) skipLineComment() {
	lastIsHyphen := false
	for {
		r, _, err := lex.readRune()
		if isNewline(r) || err == io.EOF {
			return
		} else if r == '-' {
			if lastIsHyphen {
				return
			}
			lastIsHyphen = true
		} else {
			lastIsHyphen = false
		}
	}
}

func (lex *ASN1Lexer) skipBlockComment() {
	lastIsOpeningSlash := false
	lastIsClosingStar := false
	for {
		r, _, err := lex.readRune()
		if err == io.EOF {
			return
		}
		if r == '/' {
			if lastIsClosingStar {
				return
			} else {
				lastIsOpeningSlash = true
				continue
			}
		} else if r == '*' {
			if lastIsOpeningSlash {
				lex.skipBlockComment()
			} else {
				lastIsClosingStar = true
				continue
			}
		}
		lastIsClosingStar = false
		lastIsOpeningSlash = false
	}
}

func (lex *ASN1Lexer) consumeWord() (string, error) {
	r, _, _ := lex.bufReader.ReadRune()
	acc := bytes.NewBufferString("")
	acc.WriteRune(r)
	lastR := r
	for {
		r, _, err := lex.readRune()
		if err == io.EOF || isWhitespace(r) || !isIdentifierChar(r) {
			label := acc.String()
			if label[len(label)-1] == '-' {
				return "", fmt.Errorf("token can not end on hyphen, got %v", label)
			}
			if err == nil {
				lex.unreadRune()
			}
			return label, nil
		}
		if err != nil {
			return "", fmt.Errorf("failed to read: %v", err.Error())
		}
		if !isIdentifierChar(r) {
			acc.WriteRune(r)
			return "", fmt.Errorf("expected valid identifier char, got '%c' while reading '%v'", r, acc.String())
		}
		acc.WriteRune(r)
		if lastR == '-' && r == '-' {
			return "", fmt.Errorf("token can not contain two hyphens in a row, got %v", acc.String())
		}
		lastR = r
	}
}

func (lex *ASN1Lexer) consumeNumber(lval *yySymType) int {
	r, _, err := lex.bufReader.ReadRune()
	if err != nil {
		lex.Error(err.Error())
		return -1
	}
	acc := bytes.NewBufferString("")
	acc.WriteRune(r)
	for {
		r, _, err := lex.readRune()
		if err == io.EOF || !unicode.IsDigit(r) {
			if err == nil && !unicode.IsDigit(r) {
				lex.unreadRune()
			}
			repr := acc.String()
			i, err := strconv.Atoi(repr)
			if err != nil {
				lex.Error(fmt.Sprintf("Failed to parse number: %v", err.Error()))
				return -1
			}
			lval.numberRepr = repr
			lval.Number = Number(i)
			return NUMBER
		}
		if err != nil {
			lex.Error(fmt.Sprintf("Failed to read: %v", err.Error()))
			return -1
		}
		acc.WriteRune(r)
	}
}

// Error implements yyLexer, and is used by the parser to communicate errors.
func (lex *ASN1Lexer) Error(e string) {
	lex.err = fmt.Errorf("line %v: %v", lex.lineNo+1, e)
}

// isWhitespace returns true if the rune r is whitespace.
// TODO should this use [unicode.IsSpace] ?
func isWhitespace(r rune) bool {
	switch x := int(r); x {
	//HORIZONTAL TABULATION (9)
	case 9:
		return true
	//LINE FEED (10)
	case 10:
		return true
	//VERTICAL TABULATION (11)
	case 11:
		return true
	//FORM FEED (12)
	case 12:
		return true
	//CARRIAGE RETURN (13)
	case 13:
		return true
	//SPACE (32)
	case 32:
		return true
	default:
		return false
	}
}

func isNewline(r rune) bool {
	switch x := int(r); x {
	//LINE FEED (10)
	case 10:
		return true
	//VERTICAL TABULATION (11)
	case 11:
		return true
	//FORM FEED (12)
	case 12:
		return true
	//CARRIAGE RETURN (13)
	case 13:
		return true
	default:
		return false
	}
}

func isIdentifierChar(r rune) bool {
	return unicode.IsLetter(r) || unicode.IsDigit(r) || r == '-'
}
