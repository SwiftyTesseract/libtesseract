#!/bin/sh

build() {
  make platform=$1
  cp -r $1/include/*.h include
  cp -r $1/include/*.a .

  libtool -static -o combined.a libjpeg.a liblept.a libpng.a libtiff.a libtesseract.a
}
