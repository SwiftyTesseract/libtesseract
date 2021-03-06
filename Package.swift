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
      url: "https://github.com/SwiftyTesseract/libtesseract/releases/download/0.2.0-rc1/libtesseract-0.2.0-rc1.xcframework.zip",
      checksum: "55493bc274a63dec0de006918da0ab4d1707cc3221389a580d46738c46dc922f"
    )
  ]
)

