#include <Windows.h>
#include "FlashRuntimeExtensions.h"


extern "C"
{
	__declspec(dllexport) void DMXExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
	__declspec(dllexport) void DMXExtFinalizer(void* extData);

}