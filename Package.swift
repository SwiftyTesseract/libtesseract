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
      checksum: "f7b4220cdda15b386e59fd2ee2a87c0fbd951c72c55301a0443f0fcdd8bc699e"
    )
  ]
)

