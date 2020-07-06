package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"text/template"
)

type swiftPackage struct {
	Url      string
	Checksum string
}

type bintrayVersion struct {
	Name        string `json:"name"`
	Description string `json:"desc"`
	Tag         string `json:"vcs_tag"`
}

func makeBintrayVersion(version string) bintrayVersion {
	return bintrayVersion{version, version, version}
}

func main() {
	binaryPath := flag.String("path", "", "The path to the binary to upload")
	version := flag.String("version", "", "The version to create if it doesn't exist")
	bintrayKey := flag.String("bintray-key", "", "API key for bintray")
	shouldPublish := flag.Bool("publish", false, "Publish the specified version. No file upload will be performed and should have been uploaded earlier in the CI/CD pipeline")

	flag.Parse()

	if !*shouldPublish {
		zippedPath := fmt.Sprintf("libtesseract-%s.xcframework.zip", *version)
		shellOut("zip", "-r", zippedPath, *binaryPath)

		createBintrayVersion(*version, *bintrayKey)
		uploadArtifact(zippedPath, *version, *bintrayKey)

		writePackageFile(zippedPath)
	} else {
		publish(*version, *bintrayKey)
	}
}

func shellOut(command string, args ...string) string {
	cmd := exec.Command(command, args...)
	stdout, err := cmd.Output()

	if err != nil {
		panic(err)
	}

	return string(stdout)
}

type publishBody struct {
	PublishTimeoutSeconds int `json:"publish_wait_for_secs"`
}

func publish(version string, bintrayKey string) {
	// Specify -1 to wait until publishing has completed
	data, _ := json.Marshal(publishBody{-1}
	publishURL := fmt.Sprintf("https://api.bintray.com/content/steven0351/tesseract/tesseract/%s/publish", version)

	req, _ := http.NewRequest(http.MethodPost, publishURL, bytes.NewBuffer(data))
	req.SetBasicAuth("steven0351", bintrayKey)
	req.Header.Set("Content-Type", "application/json")
	res, err := http.DefaultClient.Do(req)

	fmt.Println(res)
	if err != nil {
		panic(err)
	}
}

func createBintrayVersion(version string, bintrayKey string) {
	data, _ := json.Marshal(makeBintrayVersion(version))

	// We don't really care if a version exists or not. There would be more overhead in checking if the version exists
	// and then making a request than just attempting to create the version and not caring if it fails.
	req, _ := http.NewRequest(http.MethodPost, "https://api.bintray.com/packages/steven0351/tesseract/tesseract/versions", bytes.NewBuffer(data))
	req.SetBasicAuth("steven0351", bintrayKey)
	req.Header.Set("Content-Type", "application/json")
	res, err := http.DefaultClient.Do(req)

	fmt.Println(res)

	if err != nil {
		panic(err)
	}
}

func uploadArtifact(path string, version string, bintrayKey string) {
	bintrayUploadURL := fmt.Sprintf("https://api.bintray.com/content/steven0351/tesseract/tesseract/%s/%s", version, path)
	fmt.Printf("Uploading to %s", bintrayUploadURL)
	fmt.Println()

	file, _ := os.Open(path)
	req, _ := http.NewRequest(http.MethodPut, bintrayUploadURL, file)
	req.SetBasicAuth("steven0351", bintrayKey)

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		fmt.Println(res)
		panic(err)
	}

	if res.StatusCode < 200 || res.StatusCode > 299 {
		panic("Non-successful return from upload")
	}

	fmt.Println(res)
}

func writePackageFile(artifactPath string) {
	bintrayDownloadURL := fmt.Sprintf("https://dl.bintray.com/steven0351/tesseract/%s", artifactPath)
	swiftPackageChecksum := strings.TrimSpace(shellOut("swift", "package", "compute-checksum", artifactPath))

	pkg := swiftPackage{bintrayDownloadURL, swiftPackageChecksum}

	templ, err := template.New("template").Parse(packageSwift)
	if err != nil {
		panic(err)
	}

	// Silently fail if the file doesn't exist
	os.Remove("../Package.swift")
	file, err := os.Create("../Package.swift")
	defer file.Close()

	if err != nil {
		panic(err)
	}

	err = templ.Execute(file, pkg)
	if err != nil {
		panic(err)
	}
}

const packageSwift = `// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "libtesseract",
  products: [
    .library(
      name: "libtesseract",
      targets: ["libtesseract"]
    ),
  ],
  dependencies: [],
  targets: [
    .binaryTarget(
      name: "libtesseract",
      url: "{{ .Url }}",
      checksum: "{{ .Checksum }}"
    )
  ]
)

`
