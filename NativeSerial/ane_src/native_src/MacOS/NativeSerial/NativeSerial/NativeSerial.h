//#include <Cocoa/Cocoa.h>
//#include <Foundation/Foundation.h>
#include <ApplicationServices/ApplicationServices.h>

#define EXPORT __attribute__((visibility("default")))

#ifndef NativeSerial_H_
#define NativeSerial_H_
#include "FlashRuntimeExtensions.h" // should be included via the framework, but it's not picking up
EXPORT
void NativeSerialExtInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);

EXPORT
void NativeSerialExtFinalizer(void* extData);

#endif /* NativeSerial_H_ */
