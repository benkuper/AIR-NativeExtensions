call acompc -source-path as3_src -include-classes benkuper.nativeExtensions.BaseExtension -swf-version=14 -output BaseExtension.swc

unzip -o BaseExtension.swc -x catalog.xml

call adt -package -target ane BaseExtension.ane extension-descriptor.xml -swc BaseExtension.swc -platform Windows-x86 -C native_src\Windows-x86\BaseExtension\Debug BaseExtension.dll -C ./ library.swf

del library.swf
del BaseExtension.swc

echo "ok"
pause