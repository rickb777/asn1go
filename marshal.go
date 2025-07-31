package asn1go

import (
	"encoding/asn1"
	"os"
)

// MarshalToFile writes the ASN.1 encoding of val to the file specified by path.
func MarshalToFile(val any, path string, mode os.FileMode) error {
	data, err := asn1.Marshal(val)
	if err != nil {
		return err
	}
	err = os.WriteFile(path, data, mode)
	if err != nil {
		return err
	}
	return nil
}
