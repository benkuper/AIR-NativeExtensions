#!/bin/bash

# set for debug
# set -xv

TARGET=NativeSerial

rm -f $TARGET.ane

FLEX_SDK=/Users/benkuper/Documents/Dev/SDKs/AIRSDK_Compiler
ADT=$FLEX_SDK/bin/adt
ACOMPC=$FLEX_SDK/bin/acompc

BUILDFOLDER=ane_build

FRAMEWORKPATH=native_src/MacOS/NativeSerial/build/Products/Debug/$TARGET.framework
SWCTARGET=$BUILDFOLDER/$TARGET.swc

echo $FLEX_SDK
echo $ADT

rm -rf $BUILDFOLDER
mkdir -p $BUILDFOLDER

cd /Users/benkuper/Documents/Dev/AIR-NativeExtensions/NativeSerial/ane_src
$ACOMPC -source-path as3_src -include-classes benkuper.nativeExtensions.NativeSerial -swf-version=14 -output $SWCTARGET

cp -r $FRAMEWORKPATH $BUILDFOLDER

unzip -o -q $SWCTARGET library.swf
mv library.swf $BUILDFOLDER

"$ADT" -package \
	-target ane $TARGET.ane extension-descriptor.xml \
	-swc $SWCTARGET  \
	-platform MacOS-x86 \
	-C $BUILDFOLDER . \
    -platform Windows-x86 \
    -C $BUILDFOLDER library.swf \
    -C native_src/Windows-x86 NativeSerialExtension.dll
#	library.swf libIOSMightyLib.a
#	-platformoptions platformoptions.xml



echo "SUCCESS"
rm -rf $BUILDFOLDER

