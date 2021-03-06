import subprocess
import argparse
import textwrap

def write_package_swift(version):
    libtesseract_zip = f"libtesseract-{version}.xcframework.zip"
    download_url = f"https://github.com/SwiftyTesseract/libtesseract/releases/download/{version}/{libtesseract_zip}"
    checksum_result = subprocess.run(["swift", "package", "compute-checksum", libtesseract_zip], stdout=subprocess.PIPE)
    checksum = checksum_result.stdout.decode("utf-8").strip("\n")

    with open("Package.swift", "w") as package_swift:
        package = f"""\
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
              url: "{download_url}",
              checksum: "{checksum}"
            )
          ]
        )

        """
        package_swift.write(textwrap.dedent(package))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Update libtesseract Package.swift")
    parser.add_argument("--version", required=True, help="The version to update Package.swift for")
    args = parser.parse_args()
    write_package_swift(args.version)