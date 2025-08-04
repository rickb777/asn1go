default: bin/asn1go bin/ws2bin
.PHONY: default

bin/asn1go: y.go generate test style
	mkdir -p bin
	go build -o $@ ./cmd/asn1go

bin/ws2bin: y.go generate test style
	mkdir -p bin
	go build -o $@ ./cmd/ws2bin

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
	rm -rf bin
	find . -name '*_generated.go' -exec rm '{}' \;
.PHONY: clean

test: generate
	go test ./...
.PHONY: test