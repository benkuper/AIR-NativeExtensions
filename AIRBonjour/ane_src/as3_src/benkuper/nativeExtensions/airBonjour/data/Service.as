// --------------------------------------------------------------------------------
// 
// Copyright (c) 2012 OpenTekhnia <support@opentekhnia.com>
// 
// This file is part of as3Bonjour.
//	
// as3Bonjour is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//	
// as3Bonjour is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with as3Bonjour.  If not, see <http://www.gnu.org/licenses/>
// 
// --------------------------------------------------------------------------------
package benkuper.nativeExtensions.airBonjour.data
{
	/** 
	 * Defines service class used for providing service informations from native 
	 * extension to AS3.
	 * 
	 * Service holds information for a registered or resolved service.
	 * 
	 * Extracted from Poco C++ doc 
	 * Copyright © 2012, Applied Informatics Software Engineering GmbH (and Contributors)
	 * 
	 * See Poco C++ doc for more info:
	 * 		@see http://www.appinf.com/docs/poco/Poco.DNSSD.Service.html
	 */
	public class Service {
		// ---------------------------------------------------------------------
		// Properties (public)
		// ---------------------------------------------------------------------
		/** The domain the service is registered on. */
		public var domain: String;
		
		/** 
		 * Returns the full name of the service. The format of the full name is 
		 * "servicename.protocol.domain.". This name is escaped following 
		 * standard DNS rules. The full name will be empty for an unresolved service.
		 */
		public var fullName: String;
		
		/** 
		 * Returns the host name of the host providing the service.
		 * Will be empty for an unresolved service.
		 */
		public var host: String;
		
		/** The name of the service.*/
		public var name: String;
		
		/** 
		 * The id of the interface on which the remote service is running, or zero 
		 * if the service is available on all interfaces. 
		 */
		public var networkInterface: int;
		
		/** 
		 * Returns the port number on which the service is available.
		 * Will be 0 for an unresolved service.
		 */
		public var port: uint;
		
		/** 
		 * Returns the contents of the TXT record associated with the service.
		 * Will be empty for an unresolved service. Is a name-vaue collection.
		 */
		public var properties: Array; 
		
		/** 
		 * The registration type of the service, consisting of service type and network 
		 * protocol (delimited by a dot, as in "_ftp._tcp"), and an optional subtype 
		 * (e.g., "_primarytype._tcp,_subtype"). The protocol is always either "_tcp" 
		 * or "_udp".
		 */
		public var type: String;
		
		
		public var address:String;
		
		/**
		 * Bonjour tree data helper: children getter
		 */
		public function get children(): Array {
			return properties;
		}

		// ---------------------------------------------------------------------
		// Methods
		// ---------------------------------------------------------------------
		/**
		 * To string method (for debug purposes)
		 */
		public function toString(): String {
			var result: String = "Service {\n";
			result += "\tname= " + name + "\n";
			result += "\tdomain= " + domain + "\n";
			result += "\tfullName= " + fullName + "\n";
			result += "\thost= " + host + "\n";
			result += "\taddress= " + address + "\n";
			result += "\ttype= " + type + "\n";
			result += "\tnetworkInterface= " + networkInterface.toString() + "\n";
			result += "\tproperties {\n";
			
			for each (var nv: NameValue in properties) {
				result += "\t\t" + nv.toString() + "\n";
			}
			result += "\t}\n}";
			
			return result;
		}
		
		
		/**
		 * Gets property's value by name
		 */
		public function getPropertyValue(name: String, defaultValue: String = ""): String {
			for each (var nv: NameValue in properties) {
				if (nv.name == name) return nv.value;
			}
			
			return defaultValue;
		}
	}
}