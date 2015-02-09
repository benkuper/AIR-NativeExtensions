//
//  airBonjour.h
//  airBonjour
//
//  Created by Victor Andritoiu on 28/03/12.
//  Copyright (c) 2012 OpenTekhnia. All rights reserved.
//

#ifndef _WIN32
#define AS3BONJOUR_API __attribute__((visibility("default")))
#else
#ifdef AS3BONJOUR_EXPORTS
#define AS3BONJOUR_API __declspec(dllexport)
#else
#define AS3BONJOUR_API __declspec(dllimport)
#endif
#endif

#include "FlashRuntimeExtensions.h"

#include "Poco/DNSSD/DNSSDResponder.h"
#include "Poco/DNSSD/DNSSDBrowser.h"

extern "C" {
	void AS3BONJOUR_API initNativeExtension(void** extDataToSet, FREContextInitializer* ctxInitializerToSet,
                                            FREContextFinalizer* ctxFinalizerToSet);
    
	void AS3BONJOUR_API doneNativeExtension(void* extData);
    
	void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                            uint32_t* numFunctions, const FRENamedFunction** functionsToSet);
    
	void contextFinalizer(FREContext ctx);
    
    FREObject initDNSSD(FREContext ctx,
                        void *functionData,
                        uint32_t argc,
                        FREObject argv[]);
    
    FREObject stopDNSSD(FREContext ctx,
                        void *functionData,
                        uint32_t argc,
                        FREObject argv[]);
    
	FREObject isSupported(FREContext ctx,
						  void *functionData,
						  uint32_t argc,
						  FREObject argv[]);
    
    FREObject browse(FREContext ctx,
                     void *functionData,
                     uint32_t argc,
                     FREObject argv[]);
    
    FREObject stop(FREContext ctx,
                   void *functionData,
                   uint32_t argc,
                   FREObject argv[]);
    
    FREObject getResolvedHost(FREContext ctx,
                              void *functionData,
                              uint32_t argc,
                              FREObject argv[]);
    
    FREObject getFoundService(FREContext ctx,
                              void *functionData,
                              uint32_t argc,
                              FREObject argv[]);
    
    FREObject getResolvedService(FREContext ctx,
                                 void *functionData,
                                 uint32_t argc,
                                 FREObject argv[]);
    
    FREObject getRemovedService(FREContext ctx,
                                void *functionData,
                                uint32_t argc,
                                FREObject argv[]);
    
	FREObject registerService(FREContext ctx,
                              void *functionData,
                              uint32_t argc,
                              FREObject argv[]);
    
	FREObject unregisterService(FREContext ctx,
                                void *functionData,
                                uint32_t argc,
                                FREObject argv[]);
    
    void onHostResolved(const void* sender, const Poco::DNSSD::DNSSDBrowser::ResolveHostEventArgs& args);
    
	void onServiceFound(const void* sender, const Poco::DNSSD::DNSSDBrowser::ServiceEventArgs& args);
    
    void onServiceRemoved(const void* sender, const Poco::DNSSD::DNSSDBrowser::ServiceEventArgs& args);
    
    void onServiceResolved(const void* sender, const Poco::DNSSD::DNSSDBrowser::ServiceEventArgs& args);
    
    void onError(const void* sender, const Poco::DNSSD::DNSSDBrowser::ErrorEventArgs& args);
    
    void onHostResolveError(const void* sender, const Poco::DNSSD::DNSSDBrowser::ErrorEventArgs& args);
}
