default: y.go generate
.PHONY: default

y.go: asn1.y tool
	goyacc asn1.y

tool:
	go install tool
.PHONY: tool

generate:
	go generate -v ./...
.PHONY: generate

style: vet fmt
.PHONY: style

vet:
	go vet ./...
.PHONY: vet

fmt:
	gofmt -w -s ./
.PHONY: fmt

deps:
	go get golang.org/x/tools/cmd/goyacc
.PHONY: deps

yacc: y.go
.PHONY: yacc

clean:
	rm -f y.go
	find . -name '*_generated.go' -exec rm '{}' \;
.PHONY: clean

test: default
	go test -v ./...
.PHONY: test