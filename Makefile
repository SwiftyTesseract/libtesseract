# Beware, this Makefile is a hot-mess hodgpodge that has accumulated cruft
# and changes and additions over the last couple of years and
# probably makes zero sense at first (and probably second and third) glance.
# You will see references to "fat" libaries that haven't been renamed after
# this was adapted to only build single architecture binaries.
# Many dragons lie beyond this comment block
PNG_VERSION     := 1.6.36
PNG_NAME        := libpng-$(PNG_VERSION)
JPEG_SRC_NAME   := jpegsrc.v9c
# folder name after the JPEG_SRC_NAME archive has been unpacked
JPEG_DIR_NAME   := jpeg-9c
TIFF_NAME       := tiff-4.0.10

TESSERACT_VERSION ?= 4.1.0
TESSERACT_NAME    := tesseract-$(TESSERACT_VERSION)
LEPTONICA_VERSION ?= 1.78.0
LEPTON_NAME       := leptonica-$(LEPTONICA_VERSION)


SRC_DIR = $(shell pwd)
TESSERACT_SRC = $(SRC_DIR)/$(TESSERACT_NAME)
LEPTON_SRC = $(SRC_DIR)/$(LEPTON_NAME)
PNG_SRC   = $(SRC_DIR)/$(PNG_NAME)
JPEG_SRC = $(SRC_DIR)/$(JPEG_DIR_NAME)
TIFF_SRC = $(SRC_DIR)/$(TIFF_NAME)

libtessfiles = libtesseract.a
libleptfiles = liblept.a
libpngfiles = libpng.a
libjpegfiles = libjpeg.a
libtifffiles = libtiff.a

libpngconfig  = $(PNG_SRC)/configure
libjpegconfig = $(JPEG_SRC)/configure
libtiffconfig = $(TIFF_SRC)/configure
libtessautogen = $(TESSERACT_SRC)/autogen.sh
libtessconfig = $(TESSERACT_SRC)/configure
libleptautogen = $(LEPTON_SRC)/autogen.sh
libleptconfig = $(LEPTON_SRC)/configure

XCODE_DEVELOPER_PATH="`xcode-select -p`"
XCODE_DEVELOPER_PATH_BIN=$(XCODE_DEVELOPER_PATH)/usr/bin
TARGET_CXX="$(XCODE_DEVELOPER_PATH_BIN)/g++"
TARGET_CXX_FOR_BUILD="$(XCODE_DEVELOPER_PATH_BIN)/g++"
TARGET_CC="$(XCODE_DEVELOPER_PATH_BIN)/gcc"

# platform specific config
ifeq ($(platform), ios)
	PLATFORM_PREFIX=ios
	sdk = $(shell xcrun --sdk iphoneos --show-sdk-path)
	platform_version_min = iphoneos-version-min="11.0"
	arch = arm64
	arch_name = arm-apple-darwin64
	host = $(arch_name)
	ARCHS ?= $(arch)
else ifeq ($(platform), simulator)
	PLATFORM_PREFIX=simulator
	sdk = $(shell xcrun --sdk iphonesimulator --show-sdk-path)
	platform_version_min = ios-simulator-version-min="11.0"
	arch = x86_64
	arch_name = x86_64-apple-darwin
	host = $(arch_name)
	ARCHS ?= $(arch)
else ifeq ($(platform), catalyst)
	PLATFORM_PREFIX=catalyst
	sdk = $(shell xcrun --sdk macosx --show-sdk-path)
	platform_version_min = iphoneos-version-min="13.0"
	arch = x86_64
	arch_name = x86_64-apple-ios13.0-macabi
	host = x86_64-apple-darwin
	ARCHS ?= $(arch)
else ifeq ($(platform), macos)
	PLATFORM_PREFIX=macos
	sdk = $(shell xcrun --sdk macosx --show-sdk-path)
	platform_version_min = macosx-version-min="10.13"
	arch = x86_64
	arch_name = x86_64-apple-darwin
	host = $(arch_name)
	ARCHS ?= $(arch)
endif

INCLUDE_DIR   = $(shell pwd)/$(PLATFORM_PREFIX)/include
LEPT_INC_DIR  = $(INCLUDE_DIR)
TESS_INC_DIR  = $(INCLUDE_DIR)
IMAGE_LIB_DIR = $(INCLUDE_DIR)
IMAGE_INC_DIR = $(INCLUDE_DIR)
LIB_FAT_DIR   = $(INCLUDE_DIR)

libpngfolder  = $(PNG_SRC)/$(arch)/
libjpegfolder = $(JPEG_SRC)/$(arch)/
libtifffolder = $(TIFF_SRC)/$(arch)/
libleptfolder = $(LEPTON_SRC)/$(PLATFORM_PREFIX)/$(arch)/
libtessfolder = $(TESSERACT_SRC)/$(PLATFORM_PREFIX)/$(arch)/

libpngmakefile  = $(addprefix $(libpngfolder), Makefile)
libjpegmakefile = $(addprefix $(libjpegfolder), Makefile)
libtiffmakefile = $(addprefix $(libtifffolder), Makefile)
libleptmakefile = $(addprefix $(libleptfolder), Makefile)
libtessmakefile = $(addprefix $(libtessfolder), Makefile)

install_liblept = $(LIB_FAT_DIR)/$(libleptfiles)
install_libtess = $(LIB_FAT_DIR)/$(libtessfiles)
install_libpngfat  = $(LIB_FAT_DIR)/$(libpngfiles)
install_libjpegfat = $(LIB_FAT_DIR)/$(libjpegfiles)
install_libtifffat = $(LIB_FAT_DIR)/$(libtifffiles)

libtess    = $(addprefix $(libtessfolder)lib/, $(libtessfiles))
liblept    = $(addprefix $(libleptfolder)lib/, $(libleptfiles))
libpng     = $(addprefix $(libpngfolder)lib/, $(libpngfiles))
libjpeg    = $(addprefix $(libjpegfolder)lib/, $(libjpegfiles))
libtiff    = $(addprefix $(libtifffolder)lib/, $(libtifffiles))

dependant_libs = $(install_libpngfat) $(install_libjpegfat) $(install_libtifffat) $(install_liblept) $(install_libtess)

common_cflags = -arch $(arch) -pipe -no-cpp-precomp -isysroot $$SDKROOT -m$(platform_version_min) -O2

ifneq (,$(filter $(platform),ios simulator catalyst macos))
.PHONY : all
all : $(dependant_libs)
else
.PHONY : all
all :
	$(MAKE) platform=ios
	$(MAKE) platform=simulator
	$(MAKE) platform=catalyst
	$(MAKE) platform=macos
endif

#######################
# Build libtiff and all of its dependencies
#######################

$(install_libtifffat) : $(libtiff)
	mkdir -p $(@D)
	cp $(realpath $(addsuffix lib/$(@F), $(libtifffolder)) ) $@
	mkdir -p $(IMAGE_INC_DIR)
	cp -rvf $(firstword $(libtifffolder))include/*.h $(IMAGE_INC_DIR)

$(libtiff) :  $(libtiffmakefile)
	cd $(abspath $(@D)/..) ; \
	$(MAKE) -sj8 && $(MAKE) install

$(TIFF_SRC)/%/Makefile : $(libtiffconfig)
	export SDKROOT="$(sdk)" ; \
	export CFLAGS="$(common_cflags) -fembed-bitcode" ; \
	export CPPFLAGS=$$CFLAGS ; \
	export CXXFLAGS="$$CFLAGS -Wno-deprecated-register"; \
	export LDFLAGS="-L$$SDKROOT/usr/lib/" ; \
	mkdir -p $(@D) ; \
	cd $(@D) ; \
	../configure CXX="$(TARGET_CXX) --target=$(arch_name)" CC="$(TARGET_CC) --target=$(arch_name)" --host=$(host) --enable-fast-install --enable-shared=no --prefix=`pwd` --without-x --with-jpeg-include-dir=$(abspath $(@D)/../../$(JPEG_DIR_NAME)/$(arch)/include) --with-jpeg-lib-dir=$(abspath $(@D)/../../$(JPEG_DIR_NAME)/$(arch)/lib)


$(install_libpngfat) : $(libpng)
	mkdir -p $(@D)
	cp $(realpath $(addsuffix lib/$(@F), $(libpngfolder)) ) $@
	mkdir -p $(IMAGE_INC_DIR)/libpng
	cp -rvf $(firstword $(libpngfolder))include/*.h $(IMAGE_INC_DIR)

$(libpng) : $(libpngmakefile)
	cd $(abspath $(@D)/..) ; \
	$(MAKE) -sj8 && $(MAKE) install

$(PNG_SRC)/%/Makefile : $(libpngconfig)
	export SDKROOT="$(sdk)" ; \
	export CFLAGS="$(common_cflags) -fembed-bitcode" ; \
	export CPPFLAGS=$$CFLAGS ; \
	export CXXFLAGS="$$CFLAGS -Wno-deprecated-register"; \
	export LDFLAGS="-L$$SDKROOT/usr/lib/" ; \
	mkdir -p $(@D) ; \
	cd $(@D) ; \
	../configure CXX="$(TARGET_CXX) --target=$(arch_name)" CC="$(TARGET_CC) --target=$(arch_name)" --host=$(host) --enable-shared=no --prefix=`pwd`

$(install_libjpegfat) : $(libjpeg)
	mkdir -p $(@D)
	cp $(realpath $(addsuffix lib/$(@F), $(libjpegfolder)) ) $@
	mkdir -p $(IMAGE_INC_DIR)/libjpeg
	cp -rvf $(firstword $(libjpegfolder))include/*.h $(IMAGE_INC_DIR)

$(libjpeg) : $(libjpegmakefile)
	cd $(abspath $(@D)/..) ; \
	$(MAKE) -sj8 && $(MAKE) install

$(JPEG_SRC)/%/Makefile : $(libjpegconfig)
	export SDKROOT="$(sdk)" ; \
	export CFLAGS="$(common_cflags) -fembed-bitcode" ; \
	export CPPFLAGS=$$CFLAGS ; \
	export CXXFLAGS="$$CFLAGS -Wno-deprecated-register"; \
	export LDFLAGS="-L$$SDKROOT/usr/lib/" ; \
	mkdir -p $(@D) ; \
	cd $(@D) ; \
	../configure CXX="$(TARGET_CXX) --target=$(arch_name)" CC="$(TARGET_CC) --target=$(arch_name)" --host=$(host) --enable-shared=no --prefix=`pwd`

#######################
# TESSERACT-OCR
#######################
$(install_libtess) : $(libtess)
	mkdir -p $(LIB_FAT_DIR)
	cp $(realpath $(addsuffix lib/$(@F), $(libtessfolder)) ) $@
	mkdir -p $(TESS_INC_DIR)
	cp -rvf $(firstword $(libtessfolder))include/tesseract/** $(TESS_INC_DIR)

$(libtess) : $(libtessmakefile)
	cd $(abspath $(@D)/..) && $(MAKE) -sj8 && $(MAKE) install

$(TESSERACT_SRC)/$(PLATFORM_PREFIX)/%/Makefile : $(libtessconfig) $(install_liblept)
	export LIBS="-lz -lpng -ljpeg -ltiff" ; \
	export SDKROOT="$(sdk)" ; \
	export CFLAGS="-I$(TESSERACT_SRC)/$(PLATFORM_PREFIX)/$(arch_name)/ $(common_cflags) -fembed-bitcode" ; \
	export CPPFLAGS=$$CFLAGS ; \
	export CXXFLAGS="-I$(TESSERACT_SRC)/$(PLATFORM_PREFIX)/$*/ $(common_cflags) -Wno-deprecated-register"; \
	export LDFLAGS="-L$$SDKROOT/usr/lib/ -L$(LIB_FAT_DIR) -L$(LEPTON_SRC)/$(PLATFORM_PREFIX)/$*/src/.libs" ; \
	export LIBLEPT_HEADERSDIR=$(TESSERACT_SRC)/$(PLATFORM_PREFIX)/$*/ ; \
	export PKG_CONFIG_PATH=$(LEPTON_SRC)/$(PLATFORM_PREFIX)/$*/ ; \
	export CXX="$(TARGET_CXX) --target=$(arch_name)" ; \
	export CXX_FOR_BUILD="$(TARGET_CXX_FOR_BUILD) --target=$(arch_name)" ; \
	export CC="$(TARGET_CC) --target=$(arch_name)" ; \
	mkdir -p $(@D) ; \
	cd $(@D) ; \
	ln -s $(LEPTON_SRC)/src/ leptonica ; \
	../../configure CXX="$(TARGET_CXX) --target=$(arch_name)" CC="$(TARGET_CC) --target=$(arch_name)" --host=$(host) --prefix=`pwd` --enable-shared=no --disable-graphics

$(libtessconfig) : $(libtessautogen)
	cd $(@D) && ./autogen.sh 2> /dev/null

#######################
# LEPTONICA
#######################
$(install_liblept) : $(liblept)
	mkdir -p $(LIB_FAT_DIR)
	cp $(realpath $(addsuffix lib/$(@F), $(libleptfolder)) ) $@
	mkdir -p $(LEPT_INC_DIR)
	cp -rvf $(firstword $(libleptfolder))include/leptonica/** $(LEPT_INC_DIR)

$(liblept) : $(libleptmakefile)
	cd $(abspath $(@D)/..) ; \
	$(MAKE) -sj8 && $(MAKE) install

$(LEPTON_SRC)/$(PLATFORM_PREFIX)/%/Makefile : $(install_libtifffat) $(install_libpngfat) $(install_libjpegfat) $(libleptconfig)
	export LIBS="-lz -lpng -ljpeg -ltiff" ; \
	export SDKROOT="$(sdk)" ; \
	export CFLAGS="-I$(INCLUDE_DIR) $(common_cflags) -fembed-bitcode" ; \
	export CPPFLAGS=$$CFLAGS ; \
	export CXXFLAGS="-I$(INCLUDE_DIR) $(common_cflags) -Wno-deprecated-register"; \
	export LDFLAGS="-L$$SDKROOT/usr/lib/ -L$(LIB_FAT_DIR)" ; \
	export PKG_CONFIG_PATH=$(PNG_SRC)/$(arch)/:$(JPEG_SRC)/$(arch)/:$(TIFF_SRC)/$(arch)/ ; \
	export CXX="$(TARGET_CXX) --target=$(arch_name)" ; \
	export CXX_FOR_BUILD="$(TARGET_CXX_FOR_BUILD) --target=$(arch_name)" ; \
	export CC="$(TARGET_CC) --target=$(arch_name)" ; \
	mkdir -p $(@D) ; \
	cd $(@D) ; \
	../../configure CXX="$(TARGET_CXX) --target=$(arch_name)" CC="$(TARGET_CC) --target=$(arch_name)" --host=$(host) --prefix=`pwd` --enable-shared=no --disable-programs --with-zlib --with-libpng --with-jpeg --with-libtiff --without-giflib --without-libwebp --without-libwebpmux

$(libleptconfig) : $(libleptautogen)
	cd $(@D) && ./autogen.sh 2> /dev/null

#######################
# Download dependencies
#######################
$(libtiffconfig) :
	curl http://download.osgeo.org/libtiff/$(TIFF_NAME).tar.gz | tar -xpf-

$(libjpegconfig) :
	curl http://www.ijg.org/files/$(JPEG_SRC_NAME).tar.gz | tar -xpf-

$(libpngconfig) :
	curl -L https://downloads.sourceforge.net/project/libpng/libpng16/$(PNG_VERSION)/$(PNG_NAME).tar.gz | tar -xpf-

$(libtessautogen) :
	curl -LO https://github.com/tesseract-ocr/tesseract/archive/$(TESSERACT_VERSION).zip && unzip -a $(TESSERACT_VERSION).zip

$(libleptautogen) :
	curl http://leptonica.org/source/$(LEPTON_NAME).tar.gz | tar -xpf- ; \


#######################
# Clean
#######################
.PHONY : clean
clean : cleanpng cleantiff cleanjpeg cleanlept cleantess

.PHONY : distclean
distclean : distcleanimages distcleanlept distcleantess

.PHONY : mostlyclean
mostlyclean : mostlycleanpng mostlycleantiff mostlycleanjpeg mostlycleanlept mostlycleantess

.PHONY : cleanpng
cleanpng :
	for folder in $(realpath $(libpngfolder) ); do \
		cd $$folder; \
		$(MAKE) clean; \
	done

.PHONY : cleanjpeg
cleanjpeg :
	for folder in $(realpath $(libjpegfolder) ); do \
		cd $$folder; \
		$(MAKE) clean; \
	done

.PHONY : cleantiff
cleantiff :
	for folder in $(realpath $(libtifffolder) ); do \
		cd $$folder; \
		$(MAKE) clean; \
	done

.PHONY : cleanlept
cleanlept :
	for folder in $(realpath $(libleptfolder) ); do \
		cd $$folder; \
		$(MAKE) clean; \
	done ;

.PHONY : cleantess
cleantess :
	for folder in $(realpath $(libtessfolder) ); do \
		cd $$folder; \
		$(MAKE) clean; \
	done ;

.PHONY : mostlycleanlept
mostlycleanlept :
	for folder in $(realpath $(libleptfolder) ); do \
		cd $$folder; \
		$(MAKE) mostlyclean; \
	done ;

.PHONY : mostlycleantess
mostlycleantess :
	for folder in $(realpath $(libtessfolder) ); do \
		cd $$folder; \
		$(MAKE) mostlyclean; \
	done ;

.PHONY : mostlycleanpng
mostlycleanpng :
	for folder in $(realpath $(libpngfolder) ); do \
		cd $$folder; \
		$(MAKE) mostlyclean; \
	done

.PHONY : mostlycleantiff
mostlycleantiff :
	for folder in $(realpath $(libtifffolder) ); do \
		cd $$folder; \
		$(MAKE) mostlyclean; \
	done

.PHONY : mostlycleanjpeg
mostlycleanjpeg :
	for folder in $(realpath $(libjpegfolder) ); do \
		cd $$folder; \
		$(MAKE) mostlyclean; \
	done

.PHONY : distcleanimages
distcleanimages :
	-rm -rf $(shell pwd)/*/include
	-rm -rf $(PNG_SRC)
	-rm -rf $(JPEG_SRC)
	-rm -rf $(TIFF_SRC)

PHONY : distcleanlept
distcleanlept :
	-rm -rf $(LEPT_INC_DIR)/leptonica
	-rm -rf $(install_liblept)
	-rm -rf $(LEPTON_SRC)

.PHONY : distcleantess
distcleantess :
	-rm -rf $(TESS_INC_DIR)/tesseract
	-rm -rf $(install_libtess)
	-rm -rf $(TESSERACT_SRC)

.PHONY : FORCE
FORCE :
