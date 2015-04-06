//#include <Cocoa/Cocoa.h>
//#include <Foundation/Foundation.h>
#include <ApplicationServices/ApplicationServices.h>

#define EXPORT __attribute__((visibility("default")))

#ifndef HelloANE_H_
#define HelloANE_H_
#include "FlashRuntimeExtensions.h" // should be included via the framework, but it's not picking up
EXPORT
void MouseExtInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);

EXPORT
void MouseExtFinalizer(void* extData);

#endif /* HelloANE_H_ */
