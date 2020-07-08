// swift-tools-version:5.3

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
      url: "https://dl.bintray.com/steven0351/tesseract/libtesseract-0.1.0.xcframework.zip",
      checksum: "f732c6e1bbdbbdec87201841a4654d4d22e055e960ec618d48f5ec8141331af7"
    )
  ]
)

