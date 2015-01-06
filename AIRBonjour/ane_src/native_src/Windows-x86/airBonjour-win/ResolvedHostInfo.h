//
//  ResolvedHostInfo.h
//  airBonjour
//
//  Created by Victor Andritoiu on 29/03/12.
//  Copyright (c) 2012 OpenTekhnia. All rights reserved.
//

#ifndef airBonjour_ResolvedHostInfo_h
#define airBonjour_ResolvedHostInfo_h

#include <string>

#include "Poco/Net/IPAddress.h"

struct ResolvedHostInfo {
    Poco::Net::IPAddress address;
    std::string host;
    Poco::Int32 networkInterface;
    Poco::UInt32 ttl;
};

#endif
