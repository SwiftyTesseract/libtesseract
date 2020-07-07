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
      checksum: "7ce14651282cd77532c6ec3e3b5c01fb86da63c17c44e8ced057cc8a6c78d467"
    )
  ]
)

