call acompc -source-path as3_src -include-classes benkuper.nativeExtensions.NativeSerial -swf-version=14 -output NativeSerial.swc

unzip -o NativeSerial.swc -x catalog.xml

call adt -package -target ane NativeSerial.ane extension-descriptor.xml -swc NativeSerial.swc -platform Windows-x86 -C native_src\Windows-x86\NativeSerialExtension\Debug NativeSerialExtension.dll -C ./ library.swf

del library.swf
del NativeSerial.swc

echo "ok"
pause