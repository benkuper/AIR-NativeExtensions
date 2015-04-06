#!/bin/bash

# set for debug
# set -xv

TARGET=airBonjour

rm -f $TARGET.ane

FLEX_SDK=/Users/benkuper/Documents/Dev/SDKs/AIRSDK_Compiler
ADT=$FLEX_SDK/bin/adt
ACOMPC=$FLEX_SDK/bin/acompc

BUILDFOLDER=ane_build

FRAMEWORKPATH=native_src/MacOS/Build/Products/Debug/$TARGET.framework
SWCTARGET=$BUILDFOLDER/$TARGET.swc

echo $FLEX_SDK
echo $ADT

rm -rf $BUILDFOLDER
mkdir -p $BUILDFOLDER

cd /Users/benkuper/Documents/Dev/AIR-NativeExtensions/AIRBonjour/ane_src

$ACOMPC -source-path as3_src -include-classes org.opentekhnia.as3Bonjour.Bonjour -swf-version=14 -output $SWCTARGET

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
    -C native_src/Windows-x86 airBonjour-win.dll \
#	library.swf libIOSMightyLib.a
#	-platformoptions platformoptions.xml


if [ -f ./$TARGET.ane ];
then
    echo "SUCCESS"
	rm -rf build
else
    echo "FAILED"
fi

