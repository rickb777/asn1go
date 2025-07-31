// Binary asn1go generates go code from ASN.1 definitions.
package main

import (
	"flag"
	"fmt"
	"github.com/chemikadze/asn1go"
	"os"
)

var usage = `
Generates a Go file representing the ASN.1 input, which should be an ASN.1 module file.

If output is omitted, it writes Go code to stdout. 
If input is omitted as well, it reads the ASN.1 module from stdin.`

type flagsType struct {
	inputName      string
	outputName     string
	packageName    string
	defaultIntRepr string
}

func failWithError(format string, args ...any) {
	fmt.Fprintf(os.Stderr, format, args...)
	fmt.Fprintln(os.Stderr)
	os.Exit(1)
}

func parseFlags() (res flagsType) {
	flag.Usage = func() {
		o := flag.CommandLine.Output()
		fmt.Fprintf(o, "Usage:\n  %s [options] [input] [output]\n\n", os.Args[0])
		flag.PrintDefaults()
		fmt.Fprintln(o, usage)
	}
	flag.StringVar(&res.packageName, "package", "", "package name for generated code")
	flag.StringVar(&res.defaultIntRepr, "default-integer-repr", "int64", "Go type for integer types (int64 | big.Int)")
	flag.Parse()

	switch flag.NArg() {
	case 0:
	case 1:
		res.inputName = flag.Arg(0)
	case 2:
		res.inputName = flag.Arg(0)
		res.outputName = flag.Arg(1)
	default:
		flag.Usage()
		//failWithError(usage)
	}

	return res
}

func openFiles(inputName, outputName string) (input, output *os.File) {
	var err error
	input = os.Stdin
	output = os.Stdout

	if len(inputName) != 0 {
		input, err = os.Open(inputName)
		if err != nil {
			failWithError("Can't open %s for reading: %v", inputName, err)
		}
	}

	if len(outputName) != 0 {
		output, err = os.OpenFile(outputName, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
		if err != nil {
			failWithError("File %v can not be written: %v", inputName, err)
		}
	}

	return input, output
}

func main() {
	flags := parseFlags()

	input, output := openFiles(flags.inputName, flags.outputName)
	defer output.Close()
	defer input.Close()

	module, err := asn1go.ParseStream(input)
	if err != nil {
		failWithError("%v", err)
		return
	}

	params := asn1go.GenParams{
		Package:     flags.packageName,
		IntegerRepr: asn1go.IntegerRepr(flags.defaultIntRepr),
	}
	err = asn1go.NewCodeGenerator(params).Generate(*module, output)
	if err != nil {
		failWithError("%v", err)
	}
}
