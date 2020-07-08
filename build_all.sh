#!/bin/sh
set -e
source build.sh

make distclean
rm -rf include/*.h *.a
build ios

rm -rf build/

xcodebuild -project libtesseract.xcodeproj \
  -scheme 'libtesseract iOS' \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -configuration 'Release' \
  SYMROOT=$(pwd)/build \
  -derivedDataPath ./DerivedData \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  build

rm include/*.h *.a

build simulator

xcodebuild -project libtesseract.xcodeproj \
  -scheme 'libtesseract iOS' \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -configuration 'Release' \
  SYMROOT=$(pwd)/build \
  -derivedDataPath ./DerivedData \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  build

rm include/*.h combined.a

make distclean
build catalyst

# There is an issue with the macro expansion for fract1 on macOS that causes the xcframework to not be useable
sed -ie 's/.*fract1.*//' include/allheaders.h

xcodebuild -project libtesseract.xcodeproj \
  -scheme 'libtesseract iOS' \
  -sdk macosx \
  -destination 'platform=macOS,variant=Mac Catalyst' \
  -configuration 'Release' \
  SYMROOT=$(pwd)/build \
  -derivedDataPath ./DerivedData \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  build

rm include/*.h combined.a

make distclean
build macos

# There is an issue with the macro expansion for fract1 on macOS that causes the xcframework to not be useable
sed -ie 's/.*fract1.*//' include/allheaders.h

xcodebuild -project libtesseract.xcodeproj \
  -scheme 'libtesseract macOS' \
  -sdk macosx \
  -destination 'platform=OS X,arch=x86_64' \
  -configuration 'Release' \
  SYMROOT=$(pwd)/build \
  -derivedDataPath ./DerivedData \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  build

xcodebuild -create-xcframework \
  -framework 'build/Release-iphoneos/libtesseract.framework' \
  -framework 'build/Release-iphonesimulator/libtesseract.framework' \
  -framework 'build/Release-maccatalyst/libtesseract.framework' \
  -framework 'build/Release/libtesseract.framework' \
  -output 'build/libtesseract.xcframework'
