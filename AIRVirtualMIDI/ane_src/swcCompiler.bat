call %FLEX_SDK_PATH%/bin/acompc -source-path as3_src -include-classes benkuper.nativeExtensions.VirtualMIDI -swf-version=14 -output VirtualMIDI.swc

unzip -o VirtualMIDI.swc -x catalog.xml

call %FLEX_SDK_PATH%/bin/adt -package -target ane VirtualMIDI.ane extension-descriptor.xml -swc VirtualMIDI.swc -platform Windows-x86 -C native_src\Windows-x86 AIRVirtualMIDI.dll -C ./ library.swf

del library.swf
del VirtualMIDI.swc

echo "ok"
#pause