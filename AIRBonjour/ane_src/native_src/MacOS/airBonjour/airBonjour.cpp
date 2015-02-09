//
//  airBonjour.cpp
//  airBonjour
//
//  Created by Victor Andritoiu on 28/03/12.
//  Copyright (c) 2012 OpenTekhnia. All rights reserved.
//


#include "airBonjour.h"
#include "ResolvedHostInfo.h"

#include <sstream>
#include <map>
#include <list>

#include "Poco/Net/SocketAddress.h"
#include "Poco/FileChannel.h"
#include "Poco/ConsoleChannel.h"
#include "Poco/FormattingChannel.h"
#include "Poco/PatternFormatter.h"
#include "Poco/Logger.h"
#include "Poco/AutoPtr.h"
#include "Poco/Format.h"
#include "Poco/Path.h"
#include "Poco/Delegate.h"
#include "Poco/DNSSD/DNSSDException.h"
#include "Poco/DNSSD/Service.h"
#include "Poco/Net/NameValueCollection.h"

#if POCO_OS == POCO_OS_LINUX && !defined(POCO_DNSSD_USE_BONJOUR)
#include "Poco/DNSSD/Avahi/Avahi.h"
#else
#include "Poco/DNSSD/Bonjour/Bonjour.h"
#endif

using namespace std;

// --------------------------------------------------------------------------------------
// Macros zone
// --------------------------------------------------------------------------------------

#define FRESTRING(s) reinterpret_cast<const uint8_t*>(s)
#define FROMFRESTRING(s) reinterpret_cast<char*>(s)

#define LINFO(msg) Poco::Logger::get("airBonjour").information(msg)
#define LDEBUG(msg) Poco::Logger::get("airBonjour").debug(msg)
#define LERROR(msg) Poco::Logger::get("airBonjour").error(msg)

#define CHECKRES(r, msg) if (r != FRE_OK) { Poco::Logger::get("airBonjour").error(msg + toString<int>(r)); }

#define ADD_PROPERTY_STR_TO_OBJ(freobj, name, stdstr, errmsg) \
FREObject name; \
res = FRENewObjectFromUTF8((stdstr).length(), FRESTRING((stdstr).c_str()), &(name)); \
if (res != FRE_OK) Poco::Logger::get("airBonjour").error(std::string(errmsg) + " [creation] with code: " + toString<int>(res)); \
res = FRESetObjectProperty(freobj, FRESTRING(#name), name, NULL); \
if (res != FRE_OK) Poco::Logger::get("airBonjour").error(std::string(errmsg) + " [set] with code: " + toString<int>(res));

#define ADD_PROPERTY_INT_TO_OBJ(freobj, name, param, errmsg) \
FREObject name; \
res = FRENewObjectFromInt32(param, &(name)); \
if (res != FRE_OK) Poco::Logger::get("airBonjour").error(std::string(errmsg) + " [creation] with code: " + toString<int>(res)); \
res = FRESetObjectProperty(freobj, FRESTRING(#name), name, NULL); \
if (res != FRE_OK) Poco::Logger::get("airBonjour").error(std::string(errmsg) + " [set] with code: " + toString<int>(res));

#define ADD_PROPERTY_UINT_TO_OBJ(freobj, name, param, errmsg) \
FREObject name; \
res = FRENewObjectFromUint32(param, &(name)); \
if (res != FRE_OK) Poco::Logger::get("airBonjour").error(std::string(errmsg) + " [creation] with code: " + toString<int>(res)); \
res = FRESetObjectProperty(freobj, FRESTRING(#name), name, NULL); \
if (res != FRE_OK) Poco::Logger::get("airBonjour").error(std::string(errmsg) + " [set] with code: " + toString<int>(res));

#define CREATE_AS3_ARRAY(name, length, errmsg) \
FREObject properties; \
res = FRENewObject(FRESTRING("Array"), 0, NULL, &properties, NULL); \
if (res != FRE_OK) Poco::Logger::get("airBonjour").error(std::string(errmsg) + " [creation] with code: " + toString<int>(res)); \
res = FRESetArrayLength(name, length); \
if (res != FRE_OK) Poco::Logger::get("airBonjour").error(std::string(errmsg) + " [set length] with code: " + toString<int>(res));

// --------------------------------------------------------------------------------------
// Globals
// --------------------------------------------------------------------------------------

FREContext as3Ctx;

Poco::DNSSD::DNSSDResponder* dnssdResponder;
std::map<std::string, Poco::DNSSD::BrowseHandle> browseHandles;

std::list<Poco::DNSSD::Service> *lastFoundServices;
std::list<Poco::DNSSD::Service> *lastResolvedServices;
std::list<Poco::DNSSD::Service> *lastRemovedServices;
std::list<ResolvedHostInfo> *lastHostResolutions;

// --------------------------------------------------------------------------------------
// Utils
// --------------------------------------------------------------------------------------

template<typename T>
std::string toString(T value) {
    std::string result;
    
	std::ostringstream oss;
	oss << value;
	result = oss.str();
    
	return result;
}

// --------------------------------------------------------------------------------------
// Methods
// --------------------------------------------------------------------------------------

// isSupported()
//
//
FREObject isSupported(FREContext ctx,
                      void *functionData,
                      uint32_t argc,
                      FREObject argv[]) {
    
    FREObject retObj;
    
    FRENewObjectFromBool(1, &retObj);
    return retObj;
}


vector<Poco::DNSSD::ServiceHandle> handles;

// initDNSSD()
// initializes the DNSSD extension
//
FREObject initDNSSD(FREContext ctx,
                    void *functionData,
                    uint32_t argc,
                    FREObject argv[]) {
    
    // initialize DNSSD
    Poco::DNSSD::initializeDNSSD();
    
    LDEBUG("Initializing... ");
    
    lastFoundServices = new std::list<Poco::DNSSD::Service>();
    lastResolvedServices = new std::list<Poco::DNSSD::Service>();
    lastRemovedServices = new std::list<Poco::DNSSD::Service>();
    lastHostResolutions = new std::list<ResolvedHostInfo>();
    
    
    
    dnssdResponder = new Poco::DNSSD::DNSSDResponder();
    dnssdResponder->browser().hostResolveError += Poco::delegate(&onHostResolveError);
    dnssdResponder->browser().resolveError     += Poco::delegate(&onError);
    dnssdResponder->browser().browseError      += Poco::delegate(&onError);
    dnssdResponder->browser().serviceResolved  += Poco::delegate(&onServiceResolved);
    dnssdResponder->browser().serviceFound     += Poco::delegate(&onServiceFound);
    dnssdResponder->browser().serviceRemoved   += Poco::delegate(&onServiceRemoved);
    dnssdResponder->browser().hostResolved     += Poco::delegate(&onHostResolved);
    dnssdResponder->start();
    
    LDEBUG("DNSSD responder started");
    
    return NULL;
}



// stopDNSSD()
// stops the DNSSD extension
//
FREObject stopDNSSD(FREContext ctx,
                    void *functionData,
                    uint32_t argc,
                    FREObject argv[]) {
    
    LDEBUG("Unbinding DSNSD handlers... ");
    
    std::map<std::string, Poco::DNSSD::BrowseHandle>::iterator it;
    
    for (it = browseHandles.begin(); it != browseHandles.end(); ++it) {
        dnssdResponder->browser().cancel(it->second);
    }
    
    dnssdResponder->stop();
    
    LDEBUG("DNSSD responder stopped");
    
    dnssdResponder->browser().resolveError     -= Poco::delegate(&onError);
    dnssdResponder->browser().browseError      -= Poco::delegate(&onError);
    dnssdResponder->browser().hostResolveError -= Poco::delegate(&onHostResolveError);
    dnssdResponder->browser().serviceResolved  -= Poco::delegate(&onServiceResolved);
    dnssdResponder->browser().serviceFound     -= Poco::delegate(&onServiceFound);
    dnssdResponder->browser().serviceRemoved   -= Poco::delegate(&onServiceRemoved);
    
    LDEBUG("Deleting DSNSD handlers... ");
    
    delete lastHostResolutions;
    delete lastFoundServices;
    delete lastResolvedServices;
    delete lastRemovedServices;
    
    return NULL;
}

// start browsing for service
//
//
FREObject browse(FREContext ctx,
                 void *functionData,
                 uint32_t argc,
                 FREObject argv[]) {
    
    uint32_t length = 0;
    
    uint8_t *regType = 0;
    FREResult res = FREGetObjectAsUTF8(argv[0], &length, (const uint8_t **) &regType );
    CHECKRES(res, "Failure getting the 'regType' for the service with code: ");
    
    uint8_t *domain = 0;
    res = FREGetObjectAsUTF8(argv[1], &length, (const uint8_t **) &domain );
    CHECKRES(res, "Failure getting the 'domain' for the service with code: ");
    
    uint32_t networkInterfaces = 0;
    res = FREGetObjectAsUint32(argv[2], &networkInterfaces);
    CHECKRES(res, "Failure getting the 'networkInterfaces' for the service with code: ");
    
    FREObject retObj;
    res = FRENewObjectFromBool(1, &retObj);
    CHECKRES(res, "Failure creating return value for browse with code: ");
    
    try {
        Poco::DNSSD::BrowseHandle browseHandle = dnssdResponder->browser().browse(std::string(FROMFRESTRING(regType)), std::string(FROMFRESTRING(domain)), 0, networkInterfaces);
        browseHandles[FROMFRESTRING(regType)] = browseHandle;
		LDEBUG("Browse started for: " + std::string(FROMFRESTRING(regType)));
    } catch (...) {
        res = FRENewObjectFromBool(0, &retObj);
        CHECKRES(res, "Failure creating return value for browse with code: ");
    }
    
    return retObj;
}


// stop browsing for service
//
//
FREObject stop(FREContext ctx,
               void *functionData,
               uint32_t argc,
               FREObject argv[]) {
    
    uint32_t length = 0;
    
    uint8_t *name = 0;
    FREResult res = FREGetObjectAsUTF8(argv[0], &length, (const uint8_t **) &name );
    CHECKRES(res, "Failure getting the 'name' for the browse handle with code: ");
    
    FREObject retObj;
    res = FRENewObjectFromBool(1, &retObj);
    CHECKRES(res, "Failure creating return value for browse stop with code: ");
    
    try {
        dnssdResponder->browser().cancel(browseHandles[FROMFRESTRING(name)]);
    } catch (...) {
        res = FRENewObjectFromBool(0, &retObj);
        CHECKRES(res, "Failure creating return value for browse stop with code: ");
        
    }
    
    return retObj;
}


FREObject registerService(FREContext ctx,
                          void *functionData,
                          uint32_t argc,
                          FREObject argv[]) {
    
    uint32_t length = 0;
    uint8_t *name = 0;
    FREResult res1 = FREGetObjectAsUTF8(argv[0], &length, (const uint8_t **) &name );
    CHECKRES(res1, "Failure getting the 'name' for the browse handle with code: ");
    
	uint32_t length2 = 0;
    uint8_t *type = 0;
    FREResult res2 = FREGetObjectAsUTF8(argv[1], &length2, (const uint8_t **) &type );
    CHECKRES(res2, "Failure getting the 'name' for the browse handle with code: ");
    
    uint32_t port = 0;
	FREResult res3 = FREGetObjectAsUint32(argv[2], &port );
    CHECKRES(res3, "Failure getting the 'name' for the browse handle with code: ");
    
    
    FREObject retObj;
    FREResult res = FRENewObjectFromInt32(1, &retObj);
    CHECKRES(res, "Failure creating return value for browse stop with code: ");
    
    try {
		Poco::DNSSD::Service myService(0,std::string(FROMFRESTRING(name)),std::string(FROMFRESTRING(name)), std::string(FROMFRESTRING(type)),std::string(""), std::string(""),port);
        
		Poco::DNSSD::ServiceHandle myServiceHandle = dnssdResponder->registerService(myService);
        dnssdResponder->browser().cancel(browseHandles[FROMFRESTRING(name)]);
        
        handles.push_back(myServiceHandle);
        int handleIndex  =handles.size()-1;
        res = FRENewObjectFromInt32(handleIndex,&retObj);
    } catch (...) {
        res = FRENewObjectFromInt32(-1, &retObj);
        CHECKRES(res, "Failure creating return value for browse stop with code: ");
        
    }
    
    return retObj;
}


FREObject unregisterService(FREContext ctx,
                            void *functionData,
                            uint32_t argc,
                            FREObject argv[]) {
    
    int handleIndex = 0;
	FREGetObjectAsInt32(argv[0],&handleIndex);
    
	printf("Service pointer = %i\n",handleIndex);
	FREObject retObj;
    FREResult res = FRENewObjectFromBool(false, &retObj);
    CHECKRES(res, "Failure creating return value for browse stop with code: ");
    
	if(handleIndex < 0 || handleIndex >= handles.size())
	{
		printf("Handle index %i is not valid.\n",handleIndex);
		return retObj;
	}
    
	Poco::DNSSD::ServiceHandle handle = handles[handleIndex];
    
    try {
		dnssdResponder->unregisterService(handle);
		res = FRENewObjectFromInt32(true, &retObj);
    } catch (...) {
        
        CHECKRES(res, "Failure creating return value for browse stop with code: ");
    }
    
    return retObj;
}


// contextInitializer()
//
// The context initializer is called when the runtime creates the extension context instance.
void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                        uint32_t* numFunctions, const FRENamedFunction** functionsToSet) {
    
    as3Ctx = ctx;
    
    *numFunctions = 11;
    
    FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction) * (*numFunctions));
    
    func[0].name = (const uint8_t*) "isSupported";
    func[0].functionData = NULL;
    func[0].function = &isSupported;
    
    func[1].name = (const uint8_t*) "browse";
    func[1].functionData = NULL;
    func[1].function = &browse;
    
    func[2].name = (const uint8_t*) "getFoundService";
    func[2].functionData = NULL;
    func[2].function = &getFoundService;
    
    func[3].name = (const uint8_t*) "getResolvedService";
    func[3].functionData = NULL;
    func[3].function = &getResolvedService;
    
    func[4].name = (const uint8_t*) "getRemovedService";
    func[4].functionData = NULL;
    func[4].function = &getRemovedService;
    
    func[5].name = (const uint8_t*) "stop";
    func[5].functionData = NULL;
    func[5].function = &stop;
    
    func[6].name = (const uint8_t*) "getResolvedHost";
    func[6].functionData = NULL;
    func[6].function = &getResolvedHost;
    
    func[7].name = (const uint8_t*) "initDNSSD";
    func[7].functionData = NULL;
    func[7].function = &initDNSSD;
    
    func[8].name = (const uint8_t*) "stopDNSSD";
    func[8].functionData = NULL;
    func[8].function = &stopDNSSD;
    
	func[9].name = (const uint8_t*) "registerService";
    func[9].functionData = NULL;
    func[9].function = &registerService;
    
	func[10].name = (const uint8_t*) "unregisterService";
    func[10].functionData = NULL;
    func[10].function = &unregisterService;
    
    *functionsToSet = func;
    
    LDEBUG("Context set");
}



// contextFinalizer()
//
// The context finalizer is called when the extension's ActionScript code
// calls the ExtensionContext instance's dispose() method.
// If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls
// contextFinalizer().

void contextFinalizer(FREContext ctx) {
    LDEBUG("Unloading and cleaning...");
    
    return;
}


// initNativeExtension()
//
// The extension initializer is called the first time the ActionScript side of the extension
// calls ExtensionContext.createExtensionContext() for any context.

void initNativeExtension(void** extDataToSet, FREContextInitializer* ctxInitializerToSet,
                         FREContextFinalizer* ctxFinalizerToSet) {
    
    *ctxInitializerToSet = &contextInitializer;
    *ctxFinalizerToSet = &contextFinalizer;
    
    Poco::AutoPtr<Poco::ConsoleChannel> pCons(new Poco::ConsoleChannel);
    
    // only when FileChannel used -------------------------
    //
	// Poco::AutoPtr<Poco::FileChannel> pCons(new Poco::FileChannel);
    // Poco::Path current(Poco::Path::home());
    // Poco::Path logfile("airBonjour.log");
    // current.append(logfile);
    // pCons->setProperty("path", current.toString());
    // ----------------------------------------------------
    
    Poco::AutoPtr<Poco::PatternFormatter> pPF(new Poco::PatternFormatter);
    pPF->setProperty("pattern", "%Y-%m-%d %H:%M:%S,%i - %s - %p - %t");
    Poco::AutoPtr<Poco::FormattingChannel> pFC(new Poco::FormattingChannel(pPF, pCons));
    
    Poco::Logger::root().setChannel(pFC);
    Poco::Logger::get("airBonjour").setLevel("debug");
    
    LDEBUG("Native extension init done.");
    
}


// done()
//
// The extension finalizer is called when the runtime unloads the extension. However, it is not always called.
void doneNativeExtension(void* extData) {
    
    return;
}


// onHostResolved
//
//
void onHostResolved(const void* sender, const Poco::DNSSD::DNSSDBrowser::ResolveHostEventArgs& args) {
    ResolvedHostInfo resolvedHost;
    
    resolvedHost.host = args.host;
    resolvedHost.networkInterface = args.networkInterface;
    resolvedHost.address = args.address;
    resolvedHost.ttl = args.ttl;
    
    lastHostResolutions->push_back(resolvedHost);
    
    FREResult res = FREDispatchStatusEventAsync(as3Ctx, FRESTRING("hostResolved"), FRESTRING("hostEvent"));
    CHECKRES(res, "Event dispatch failure with code: ");
}


// get last resolved host
//
//
FREObject getResolvedHost(FREContext ctx,
                          void *functionData,
                          uint32_t argc,
                          FREObject argv[]) {
    
    ResolvedHostInfo resolvedHost = lastHostResolutions->front();
    lastHostResolutions->pop_front();
    
    FREObject as3resolvedHost;
    FREResult res = FRENewObject(FRESTRING("org.opentekhnia.as3Bonjour.data.ResolvedHostInfo"), 0, NULL, &as3resolvedHost, NULL);
    CHECKRES(res, "Failed when creating ResolvedHostInfo object with code: ");
    
    ADD_PROPERTY_INT_TO_OBJ(as3resolvedHost, networkInterface, resolvedHost.networkInterface, "Failed when creating ResolvedHostInfo object's 'networkInterface'")
    ADD_PROPERTY_STR_TO_OBJ(as3resolvedHost, address, resolvedHost.address.toString(), "Failed when creating ResolvedHostInfo object's 'address'")
    ADD_PROPERTY_STR_TO_OBJ(as3resolvedHost, host, resolvedHost.host, "Failed when creating ResolvedHostInfo object's 'host'")
    ADD_PROPERTY_UINT_TO_OBJ(as3resolvedHost, ttl, resolvedHost.ttl, "Failed when creating ResolvedHostInfo object's 'ttl'")
    
    return as3resolvedHost;
}


// onServiceFound
//
//
void onServiceFound(const void* sender, const Poco::DNSSD::DNSSDBrowser::ServiceEventArgs& args) {
    lastFoundServices->push_back(args.service);
    
    FREResult res = FREDispatchStatusEventAsync(as3Ctx, FRESTRING("serviceFound"), FRESTRING("serviceEvent"));
    CHECKRES(res, "Event dispatch failure with code: ");
    
	LDEBUG("Found service: " + args.service.name());
    
    reinterpret_cast<Poco::DNSSD::DNSSDBrowser*>(const_cast<void*>(sender))->resolve(args.service);
}


// get last found service
//
//
FREObject getFoundService(FREContext ctx,
                          void *functionData,
                          uint32_t argc,
                          FREObject argv[]) {
    
    Poco::DNSSD::Service service = lastFoundServices->front();
    lastFoundServices->pop_front();
    
    FREObject as3service;
    FREResult res = FRENewObject(FRESTRING("org.opentekhnia.as3Bonjour.data.Service"), 0, NULL, &as3service, NULL);
    CHECKRES(res, "Failed when creating Service object with code: ");
    
    ADD_PROPERTY_STR_TO_OBJ(as3service, domain, service.domain(), "Failed when creating Service object's 'domain'")
    ADD_PROPERTY_STR_TO_OBJ(as3service, fullName, service.fullName(), "Failed when creating Service object's 'fullName'")
    ADD_PROPERTY_STR_TO_OBJ(as3service, host, service.host(), "Failed when creating Service object's 'host'")
    ADD_PROPERTY_STR_TO_OBJ(as3service, name, service.name(), "Failed when creating Service object's 'name'")
    ADD_PROPERTY_STR_TO_OBJ(as3service, type, service.type(), "Failed when creating Service object's 'type'")
    ADD_PROPERTY_INT_TO_OBJ(as3service, networkInterface, service.networkInterface(), "Failed when creating Service object's 'networkInterface'")
    ADD_PROPERTY_UINT_TO_OBJ(as3service, port, service.port(), "Failed when creating Service object's 'port'")
    
    CREATE_AS3_ARRAY(properties, service.properties().size(), "Failed when creating Service object's 'properties'")
    
    Poco::Net::NameValueCollection::ConstIterator it;
    unsigned int index = 0;
    for (it = service.properties().begin(); it != service.properties().end(); ++it) {
        
        FREObject item;
        res = FRENewObject(FRESTRING("org.opentekhnia.as3Bonjour.data.NameValue"), 0, NULL, &item, NULL);
        CHECKRES(res, "Failed when creating NameValue object with code: ");
        
        FREObject key;
        res = FRENewObjectFromUTF8(it->first.length(), FRESTRING(it->first.c_str()), &key);
        CHECKRES(res, "Failed when creating NameValue object's 'key' with code: ");
        res = FRESetObjectProperty(item, FRESTRING("key"), key, NULL);
        CHECKRES(res, "Failed when setting NameValue object's 'key' with code: ");
        
        FREObject value;
        res = FRENewObjectFromUTF8(it->second.length(), FRESTRING(it->second.c_str()), &value);
        CHECKRES(res, "Failed when creating NameValue object's 'value' with code: ");
        res = FRESetObjectProperty(item, FRESTRING("value"), value, NULL);
        CHECKRES(res, "Failed when setting NameValue object's 'value' with code: ");
        
        res = FRESetArrayElementAt(properties, index, item);
        CHECKRES(res, "Failed when setting Propeties array element with code: ");
    }
    
    res = FRESetObjectProperty(as3service, FRESTRING("properties"), properties, NULL);
    CHECKRES(res, "Failed when setting Service object's property 'propeties' with code: ");
    
    return as3service;
}

// onServiceResolved
//
//
void onServiceResolved(const void* sender, const Poco::DNSSD::DNSSDBrowser::ServiceEventArgs& args) {
    std::string serviceResolvedName = args.service.name();
    
    lastResolvedServices->push_back(args.service);
    
    FREResult res = FREDispatchStatusEventAsync(as3Ctx, FRESTRING("serviceResolved"), FRESTRING("serviceEvent"));
    CHECKRES(res, "Event dispatch failure with code: ");
    
	LDEBUG("Resolved service: " + serviceResolvedName);
    
    reinterpret_cast<Poco::DNSSD::DNSSDBrowser*>(const_cast<void*>(sender))->resolveHost(args.service.host());
}


// get last resolved service
//
//
FREObject getResolvedService(FREContext ctx,
                             void *functionData,
                             uint32_t argc,
                             FREObject argv[]) {
    
    Poco::DNSSD::Service service = lastResolvedServices->front();
    lastResolvedServices->pop_front();
    
    FREObject as3service;
    FREResult res = FRENewObject(FRESTRING("org.opentekhnia.as3Bonjour.data.Service"), 0, NULL, &as3service, NULL);
    CHECKRES(res, "Failed when creating Service object with code: ");
    
    ADD_PROPERTY_STR_TO_OBJ(as3service, domain, service.domain(), "Failed when creating Service object's 'domain'")
    ADD_PROPERTY_STR_TO_OBJ(as3service, fullName, service.fullName(), "Failed when creating Service object's 'fullName'")
    ADD_PROPERTY_STR_TO_OBJ(as3service, host, service.host(), "Failed when creating Service object's 'host'")
    ADD_PROPERTY_STR_TO_OBJ(as3service, name, service.name(), "Failed when creating Service object's 'name'")
    ADD_PROPERTY_STR_TO_OBJ(as3service, type, service.type(), "Failed when creating Service object's 'type'")
    ADD_PROPERTY_INT_TO_OBJ(as3service, networkInterface, service.networkInterface(), "Failed when creating Service object's 'networkInterface'")
    ADD_PROPERTY_UINT_TO_OBJ(as3service, port, service.port(), "Failed when creating Service object's 'port'")
    
    CREATE_AS3_ARRAY(properties, service.properties().size(), "Failed when creating Service object's 'properties'")
    
    Poco::Net::NameValueCollection::ConstIterator it;
    unsigned int index = 0;
    for (it = service.properties().begin(); it != service.properties().end(); ++it) {
        
        FREObject item;
        res = FRENewObject(FRESTRING("org.opentekhnia.as3Bonjour.data.NameValue"), 0, NULL, &item, NULL);
        CHECKRES(res, "Failed when creating NameValue object with code: ");
        
        FREObject key;
        res = FRENewObjectFromUTF8(it->first.length(), FRESTRING(it->first.c_str()), &key);
        CHECKRES(res, "Failed when creating NameValue object's 'key' with code: ");
        res = FRESetObjectProperty(item, FRESTRING("name"), key, NULL);
        CHECKRES(res, "Failed when setting NameValue object's 'key' with code: ");
        
        FREObject value;
        res = FRENewObjectFromUTF8(it->second.length(), FRESTRING(it->second.c_str()), &value);
        CHECKRES(res, "Failed when creating NameValue object's 'value' with code: ");
        res = FRESetObjectProperty(item, FRESTRING("value"), value, NULL);
        CHECKRES(res, "Failed when setting NameValue object's 'value' with code: ");
        
        res = FRESetArrayElementAt(properties, index, item);
        CHECKRES(res, "Failed when setting Propeties array element with code: ");
        
        index++;
    }
    
    res = FRESetObjectProperty(as3service, FRESTRING("properties"), properties, NULL);
    CHECKRES(res, "Failed when setting Service object's property 'propeties' with code: ");
    
    return as3service;
}


// onServiceRemoved
//
//
void onServiceRemoved(const void* sender, const Poco::DNSSD::DNSSDBrowser::ServiceEventArgs& args) {
    std::string serviceRemovedName = args.service.name();
    
    lastRemovedServices->push_back(args.service);
    
    FREResult res = FREDispatchStatusEventAsync(as3Ctx, FRESTRING("serviceRemoved"), FRESTRING("serviceEvent"));
    CHECKRES(res, "Event dispatch failure with code: ");
    
    LDEBUG("Removed service: " + serviceRemovedName);
}


// get last removed service
//
//
FREObject getRemovedService(FREContext ctx,
                            void *functionData,
                            uint32_t argc,
                            FREObject argv[]) {
    
    Poco::DNSSD::Service service = lastRemovedServices->front();
    lastRemovedServices->pop_front();
    
    FREObject as3service;
    FREResult res = FRENewObject(FRESTRING("org.opentekhnia.as3Bonjour.data.Service"), 0, NULL, &as3service, NULL);
    CHECKRES(res, "Failed when creating Service object with code: ");
    
    ADD_PROPERTY_STR_TO_OBJ(as3service, domain, service.domain(), "Failed when creating Service object's 'domain'")
    ADD_PROPERTY_STR_TO_OBJ(as3service, fullName, service.fullName(), "Failed when creating Service object's 'fullName'")
    ADD_PROPERTY_STR_TO_OBJ(as3service, host, service.host(), "Failed when creating Service object's 'host'")
    ADD_PROPERTY_STR_TO_OBJ(as3service, name, service.name(), "Failed when creating Service object's 'name'")
    ADD_PROPERTY_STR_TO_OBJ(as3service, type, service.type(), "Failed when creating Service object's 'type'")
    ADD_PROPERTY_INT_TO_OBJ(as3service, networkInterface, service.networkInterface(), "Failed when creating Service object's 'networkInterface'")
    ADD_PROPERTY_UINT_TO_OBJ(as3service, port, service.port(), "Failed when creating Service object's 'port'")
    
    CREATE_AS3_ARRAY(properties, service.properties().size(), "Failed when creating Service object's 'properties'")
    
    Poco::Net::NameValueCollection::ConstIterator it;
    unsigned int index = 0;
    for (it = service.properties().begin(); it != service.properties().end(); ++it) {
        
        FREObject item;
        res = FRENewObject(FRESTRING("org.opentekhnia.as3Bonjour.data.NameValue"), 0, NULL, &item, NULL);
        CHECKRES(res, "Failed when creating NameValue object with code: ");
        
        FREObject key;
        res = FRENewObjectFromUTF8(it->first.length(), FRESTRING(it->first.c_str()), &key);
        CHECKRES(res, "Failed when creating NameValue object's 'key' with code: ");
        res = FRESetObjectProperty(item, FRESTRING("key"), key, NULL);
        CHECKRES(res, "Failed when setting NameValue object's 'key' with code: ");
        
        FREObject value;
        res = FRENewObjectFromUTF8(it->second.length(), FRESTRING(it->second.c_str()), &value);
        CHECKRES(res, "Failed when creating NameValue object's 'value' with code: ");
        res = FRESetObjectProperty(item, FRESTRING("value"), value, NULL);
        CHECKRES(res, "Failed when setting NameValue object's 'value' with code: ");
        
        res = FRESetArrayElementAt(properties, index, item);
        CHECKRES(res, "Failed when setting Propeties array element with code: ");
    }
    
    res = FRESetObjectProperty(as3service, FRESTRING("properties"), properties, NULL);
    CHECKRES(res, "Failed when setting Service object's property 'propeties' with code: ");
    
    return as3service;
}

// onHostResolvedError
//
//
void onHostResolveError(const void* sender, const Poco::DNSSD::DNSSDBrowser::ErrorEventArgs& args) {
    FREResult res = FREDispatchStatusEventAsync(as3Ctx, FRESTRING("error"), FRESTRING("hostEvent"));
    CHECKRES(res, "Event dispatch failure with code: ");
    
    LERROR(args.error.message()+" (" + toString<int>(args.error.code()) + ")");
}


// onError
//
//
void onError(const void* sender, const Poco::DNSSD::DNSSDBrowser::ErrorEventArgs& args) {
    FREResult res = FREDispatchStatusEventAsync(as3Ctx, FRESTRING("error"), FRESTRING("serviceEvent"));
    CHECKRES(res, "Event dispatch failure with code: ");
    
    LERROR(args.error.message()+" (" + toString<int>(args.error.code()) + ")");
}