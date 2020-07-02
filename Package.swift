// swift-tools-version:5.3

let package = Package(
  name: "Tesseract",
  platforms: [
    .macOS(.v10_13), .iOS(.v11)
  ],
  products: [
    .library(
      name: "Tesseract",
      targets: ["Tesseract"]
    )
  ],
  targets: [
    .binaryTarget(
      name: "Tesseract",
      path: "build/libtesseract.xcframework"
    )
  ]
)