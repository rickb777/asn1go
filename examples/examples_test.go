package examples

import (
	"bytes"
	"github.com/chemikadze/asn1go"
	"os"
	"testing"
)

func testExampleParsing(t *testing.T, filename string) *asn1go.ModuleDefinition {
	content, err := os.ReadFile(filename)
	if err != nil {
		t.Errorf("Failed to read file: %s", err.Error())
	}
	str := string(content)
	def, err := asn1go.ParseString(str)
	if err != nil {
		t.Fatalf("Failed to parse %v\n\nExpected nil error, got: %v", filename, err.Error())
	}
	return def
}

func testGeneration(t *testing.T, def *asn1go.ModuleDefinition) {
	params := asn1go.GenParams{
		Package: "testname",
	}
	gen := asn1go.NewCodeGenerator(params)
	output := &bytes.Buffer{}
	err := gen.Generate(*def, output)
	if err != nil {
		t.Fatalf("Failed to generate: %v", err)
	}
}

func TestParseKerberos(t *testing.T) {
	defs := testExampleParsing(t, "rfc4120.asn1")
	t.Run("generation", func(t *testing.T) {
		testGeneration(t, defs)
	})
}

func TestParseSNMP(t *testing.T) {
	defs := testExampleParsing(t, "rfc1157.asn1")
	t.Run("generation", func(t *testing.T) {
		t.Skip("Missing type references")
		testGeneration(t, defs)
	})
}

func TestParseSNMPSMI(t *testing.T) {
	defs := testExampleParsing(t, "rfc1155.asn1")
	t.Run("generation", func(t *testing.T) {
		testGeneration(t, defs)
	})
}

func TestParseX509(t *testing.T) {
	defs := testExampleParsing(t, "rfc5280.asn1")
	t.Run("generation", func(t *testing.T) {
		testGeneration(t, defs)
	})
}

func TestParseLDAP(t *testing.T) {
	defs := testExampleParsing(t, "rfc4511.asn1")
	t.Run("generation", func(t *testing.T) {
		t.Skip("Missing named types and NULL")
		testGeneration(t, defs)
	})
}
