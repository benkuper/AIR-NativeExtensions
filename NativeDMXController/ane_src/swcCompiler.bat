call acompc -source-path as3_src -include-classes benkuper.nativeExtensions.NativeDMXController -swf-version=14 -output NativeDMXController.swc

unzip -o NativeDMXController.swc -x catalog.xml

call adt -package -target ane NativeDMXController.ane extension-descriptor.xml -swc NativeDMXController.swc -platform Windows-x86 -C native_src\Windows-x86\DMXExtension\Debug DMXExtension.dll -C ./ library.swf

del library.swf
del NativeDMXController.swc

echo "ANE Created"
pause