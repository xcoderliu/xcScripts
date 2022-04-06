if  [ ! -n "$2" ] ;then
    echo "useage: sh fatlib2xcframework.sh fatlibPath headerPath"
fi
FATLIB=$1
HEADERS=$2

ARCHS=`lipo -archs ${FATLIB}`
FILENAME=$(basename -- ${FATLIB})
EXT="${FATLIB##*.}"
FILENAME="${FILENAME%.*}"
LIBNAME="${FILENAME}"
if  [ -n "$3" ] ;then
    LIBNAME=$3
fi
IPHONE_OS_ARCHS=('arm64' 'armv7')
IPHONE_SIMULATOR_ARCHS=('x86_64' 'i386')

for ARCH in ${ARCHS}
do
    lipo -thin ${ARCH} ${FATLIB} -o "${FILENAME}_${ARCH}.${EXT}"
done

IPHONE_OS_ARCH_EXIST=()
for ARCH in ${IPHONE_OS_ARCHS[@]}
do
if [[ "${ARCHS[@]}" =~ "${ARCH}" ]]; then
    IPHONE_OS_ARCH_EXIST[${#IPHONE_OS_ARCH_EXIST[@]}]=${ARCH}
fi
done

LIPO_MERGE_IPHONE_OS_COMMAND="lipo -create"

for ARCH in ${IPHONE_OS_ARCH_EXIST[@]}
do
    echo "合并真机架构 ${ARCH}"
    LIPO_MERGE_IPHONE_OS_COMMAND="${LIPO_MERGE_IPHONE_OS_COMMAND} ${FILENAME}_${ARCH}.${EXT}"
done

LIPO_MERGE_IPHONE_OS_COMMAND="${LIPO_MERGE_IPHONE_OS_COMMAND} -o ${FILENAME}_iphoneos.${EXT}"

`${LIPO_MERGE_IPHONE_OS_COMMAND}`

IPHONE_SIMULATOR_ARCH_EXIST=()
for ARCH in ${IPHONE_SIMULATOR_ARCHS[@]}
do
if [[ "${ARCHS[@]}" =~ "${ARCH}" ]]; then
    IPHONE_SIMULATOR_ARCH_EXIST[${#IPHONE_SIMULATOR_ARCH_EXIST[@]}]=${ARCH}
fi
done

LIPO_MERGE_IPHONE_SIMULATOR_COMMAND="lipo -create"

for ARCH in ${IPHONE_SIMULATOR_ARCH_EXIST[@]}
do
    echo "合并虚拟机架构 ${ARCH}"
    LIPO_MERGE_IPHONE_SIMULATOR_COMMAND="${LIPO_MERGE_IPHONE_SIMULATOR_COMMAND} ${FILENAME}_${ARCH}.${EXT}"
done

LIPO_MERGE_IPHONE_SIMULATOR_COMMAND="${LIPO_MERGE_IPHONE_SIMULATOR_COMMAND} -o ${FILENAME}_iphone_simulator.${EXT}"

`${LIPO_MERGE_IPHONE_SIMULATOR_COMMAND}`

for ARCH in ${ARCHS}
do
    rm -rf "${FILENAME}_${ARCH}.${EXT}"
done

XCCOMMAND="xcodebuild -create-xcframework -library ${FILENAME}_iphoneos.${EXT} -headers ${HEADERS} -library ${FILENAME}_iphone_simulator.${EXT} -headers ${HEADERS} -output ${LIBNAME}.xcframework"

eval ${XCCOMMAND}

rm -rf "${FILENAME}_iphoneos.${EXT}"
rm -rf "${FILENAME}_iphone_simulator.${EXT}"

