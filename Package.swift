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
      url: "https://github.com/SwiftyTesseract/libtesseract/releases/download/0.2.0-rc/libtesseract-0.2.0-rc.xcframework.zip",
      checksum: "117f165a83b4149ab454a39decaa692de17f67aa200b858f16623e681bf637db"
    )
  ]
)

