
#define EXPORT __attribute__((visibility("default")))

#ifndef NativeMIDI_H_
#define NativeMIDI_H_

#include "FlashRuntimeExtensions.h"

#ifdef __cplusplus
extern "C"
{
#endif
	EXPORT void NativeMIDIExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
	EXPORT void NativeMIDIExtFinalizer(void* extData);

#ifdef __cplusplus
}
#endif

#endif