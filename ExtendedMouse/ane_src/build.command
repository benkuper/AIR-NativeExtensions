#!/bin/bash

# set for debug
# set -xv

TARGET=ExtendedMouse

rm -f $TARGET.ane

FLEX_SDK=/Users/benkuper/Documents/Dev/SDKs/AIRSDK_Compiler
ADT=$FLEX_SDK/bin/adt
ACOMPC=$FLEX_SDK/bin/acompc

BUILDFOLDER=ane_build

FRAMEWORKPATH=native_src/MacOS-x86/ExtendedMouse/build/Products/Debug/$TARGET.framework
SWCTARGET=$BUILDFOLDER/$TARGET.swc

echo $FLEX_SDK
echo $ADT

rm -rf $BUILDFOLDER
mkdir -p $BUILDFOLDER


$ACOMPC -source-path as3_src -include-classes benkuper.nativeExtensions.ExtendedMouse -swf-version=14 -output $SWCTARGET

cp -r $FRAMEWORKPATH $BUILDFOLDER

unzip -o -q $SWCTARGET library.swf
mv library.swf $BUILDFOLDER

"$ADT" -package \
	-target ane $TARGET.ane extension-descriptor.xml \
	-swc $SWCTARGET  \
	-platform MacOS-x86 \
	-C $BUILDFOLDER .
#	library.swf libIOSMightyLib.a
#	-platformoptions platformoptions.xml


if [ -f ./$TARGET.ane ];
then
    echo "SUCCESS"
	rm -rf build
else
    echo "FAILED"
fi

