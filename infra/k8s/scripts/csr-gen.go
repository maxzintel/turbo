package main

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/asn1"
	"encoding/pem"
	"os"
)

func main() {
	name := os.Args[1]
	user := os.Args[2]

	key, err := rsa.GenerateKey(rand.Reader, 1024)
	if err != nil {
		panic(err)
	}
	keyDer := x509.MarshalPKCS1PrivateKey(key)
	keyBlock := pem.Block{
		Type:  "RSA PRIVATE KEY",
		Bytes: keyDer,
	}
	keyFile, err := os.Create(name + "-key.pem")
	if err != nil {
		panic(err)
	}
	pem.Encode(keyFile, &keyBlock)
	keyFile.Close()
	commonName := user
	// The below strings you will likely want to customize and change per user/cert you generate.
	emailAddress := "maxz@hey.com"

	org := "brainbard.io"
	orgUnit := "Devs"
	city := "Greenville"
	state := "SC"
	country := "US"

	subject := pkix.Name{
		CommonName:         commonName,
		Country:            []string{country},
		Locality:           []string{city},
		Organization:       []string{org},
		OrganizationalUnit: []string{orgUnit},
		Province:           []string{state},
	}
	asn1, err := asn1.Marshal(subject.ToRDNSequence())
	if err != nil {
		panic(err)
	}
	csr := x509.CertificateRequest{
		RawSubject:         asn1,
		EmailAddresses:     []string{emailAddress},
		SignatureAlgorithm: x509.SHA256WithRSA,
	}

	bytes, err := x509.CreateCertificateRequest(rand.Reader, &csr, key)
	if err != nil {
		panic(err)
	}

	csrFile, err := os.Create(name + ".csr")
	if err != nil {
		panic(err)
	}

	pem.Encode(csrFile, &pem.Block{Type: "CERTIFICATE REQUEST", Bytes: bytes})
	csrFile.Close()
}
