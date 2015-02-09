#include <Windows.h>
#include "FlashRuntimeExtensions.h"


extern "C"
{
	__declspec(dllexport) void VirtualMIDIExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
	__declspec(dllexport) void VirtualMIDIExtFinalizer(void* extData);

}