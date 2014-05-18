#include <Windows.h>
#include "FlashRuntimeExtensions.h"


extern "C"
{
	__declspec(dllexport) void BaseExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
	__declspec(dllexport) void BaseExtFinalizer(void* extData);

}