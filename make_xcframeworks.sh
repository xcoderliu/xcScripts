#!/bin/sh -e

REVEAL_XCFRAMEWORK_IN_FINDER=true
PROJECT_DIR=$(pwd)
PROJECT_NAME="product"
FREAMEWORK_NAME="${PROJECT_NAME}"
FREAMEWORK_OUTPUT_DIR="${PROJECT_DIR}/Distribution"
ARCHIVE_PATH_IOS_DEVICE="./Build/ios_device.xcarchive"
ARCHIVE_PATH_IOS_SIMULATOR="./Build/ios_simulator.xcarchive"
COMPILER_FLAGS="WARNING_CFLAGS='-Wno-everything' WARNING_LDFLAGS='-w' -UseModernBuildSystem=1"
# ARCHIVE_PATH_MACOS="./build/macos.xcarchive"

#准备环境变量
BUILD_BIN=$XCODE_PATH$compileEnv
if [[ "${BUILD_BIN}" = "" ]]; then
    BUILD_BIN=xcodebuild
fi

#获取SDK编译版本
BUILD_SDK_VERSION=$(${BUILD_BIN} -showsdks | grep iphoneos | sort -r | head -n 1 | grep -o '.\{4\}$')
if [[ ${BUILD_SDK_VERSION} = "" ]]; then
    echo "Error: No iPhone SDK ..."
    exit 1
fi
BUILD_SDK_IPHONEOS="iphoneos${BUILD_SDK_VERSION}"
BUILD_SDK_IPHONESIMULATOR="iphonesimulator${BUILD_SDK_VERSION}"

function archiveOnePlatform {
	echo "▸ Starts archiving the scheme: ${1} for destination: ${2};\n▸ Archive path: ${3}"

	xcodebuild ${COMPILER_FLAGS} archive \
		-scheme "${1}" \
		-destination "${2}" \
		-archivePath "${3}" \
        -configuration Release \
		VALID_ARCHS="${4}" \
		SKIP_INSTALL=NO \
        -sdk ${5} -quiet \
        ENABLE_BITCODE=NO \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty

	# sudo gem install -n /usr/local/bin xcpretty
	# xcpretty makes xcode compile information much more readable.
}

function archiveAllPlatforms {

	# https://www.mokacoding.com/blog/xcodebuild-destination-options/

	# Platform				Destination
	# iOS					generic/platform=iOS
	# iOS Simulator			generic/platform=iOS Simulator
	# iPadOS				generic/platform=iPadOS
	# iPadOS Simulator		generic/platform=iPadOS Simulator
	# macOS					generic/platform=macOS
	# tvOS					generic/platform=tvOS
	# watchOS				generic/platform=watchOS
	# watchOS Simulator		generic/platform=watchOS Simulator
	# carPlayOS				generic/platform=carPlayOS
	# carPlayOS Simulator	generic/platform=carPlayOS Simulator

	SCHEME=${1}

	archiveOnePlatform $SCHEME "generic/platform=iOS Simulator" ${ARCHIVE_PATH_IOS_SIMULATOR} "x86_64" ${BUILD_SDK_IPHONESIMULATOR}
  	archiveOnePlatform $SCHEME "generic/platform=iOS" ${ARCHIVE_PATH_IOS_DEVICE} "armv7 arm64" ${BUILD_SDK_IPHONEOS}
  	# archiveOnePlatform $SCHEME "generic/platform=macOS" ${ARCHIVE_PATH_MACOS}
}

function makeXCFramework {

	FRAMEWORK_RELATIVE_PATH="Products/Library/Frameworks"
	OUTPUT_DIR="${FREAMEWORK_OUTPUT_DIR}/StaticFramework"

	mkdir -p "${OUTPUT_DIR}"

	xcodebuild -create-xcframework \
		-framework "${ARCHIVE_PATH_IOS_DEVICE}/${FRAMEWORK_RELATIVE_PATH}/${FREAMEWORK_NAME}.framework" \
		-framework "${ARCHIVE_PATH_IOS_SIMULATOR}/${FRAMEWORK_RELATIVE_PATH}/${FREAMEWORK_NAME}.framework" \
		-output "${OUTPUT_DIR}/${FREAMEWORK_NAME}.xcframework"
}

echo "#####################"
echo "▸ Cleaning XCFramework output dir: ${FREAMEWORK_OUTPUT_DIR}"
rm -rf $FREAMEWORK_OUTPUT_DIR

#### Make XCFramework

echo "▸ Archive framework: ${FREAMEWORK_NAME}"
archiveAllPlatforms $FREAMEWORK_NAME

echo "▸ Make framework: ${FREAMEWORK_NAME}.xcframework"
makeXCFramework

# Clean Build
rm -rf "./Build"

if [ ${REVEAL_XCFRAMEWORK_IN_FINDER} = true ]; then
    open "${FREAMEWORK_OUTPUT_DIR}/"
fi

