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
/**
 * as3Bonjour native library provides the capability to get current declared
 * Bonjour services.
 * It uses Poco C++ Remoting library, which is commercial, but based on Poco C++ 
 * open source framework.
 * 
 * @author V. Andritoiu
 * @version 1.0.0
 */ 
package org.opentekhnia.as3Bonjour
{
	import benkuper.util.IPUtil;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	import org.opentekhnia.as3Bonjour.data.ResolvedHostInfo;
	import org.opentekhnia.as3Bonjour.data.Service;
	import org.opentekhnia.as3Bonjour.events.BonjourEvent;
	
	/**
	 * Dispatched when the a new Bonjour service has been found for on going 
	 * browsings.
	 *
	 * @eventType org.opentekhnia.as3Bonjour.events.BonjourEvent
	 */
	[Event(name="serviceFound", type="org.opentekhnia.as3Bonjour.events.BonjourEvent")]
	
	/**
	 * Dispatched when the a Bonjour service has been resolved for on going 
	 * browsings.
	 *
	 * @eventType org.opentekhnia.as3Bonjour.events.BonjourEvent
	 */
	[Event(name="serviceResolved", type="org.opentekhnia.as3Bonjour.events.BonjourEvent")]
	
	/**
	 * Dispatched when the a Bonjour service has been removed for on going 
	 * browsings.
	 *
	 * @eventType org.opentekhnia.as3Bonjour.events.BonjourEvent
	 */
	[Event(name="serviceRemoved", type="org.opentekhnia.as3Bonjour.events.BonjourEvent")]
	
	/**
	 * Dispatched when the a host has been resolved for found services.
	 *
	 * @eventType org.opentekhnia.as3Bonjour.events.BonjourEvent
	 */
	[Event(name="hostResolved", type="org.opentekhnia.as3Bonjour.events.BonjourEvent")]
	
	/**
	 * Dispatched when an error occured for current browsings.
	 *
	 * @eventType org.opentekhnia.as3Bonjour.events.BonjourEvent
	 */
	[Event(name="error", type="org.opentekhnia.as3Bonjour.events.BonjourEvent")]
	
	
	/**
	 * This class implements Bonjour Air native API following AS3 "standards" for 
	 * native extension implementation.
	 */
	public class Bonjour extends EventDispatcher {
		// ---------------------------------------------------------------------
		// Properties
		// ---------------------------------------------------------------------
		/**
		 * @private
		 * Checks if class has been already instatiated.
		 */
		private static var _isInstantiated: Boolean = false;
		
		/** 
		 * @private
		 * extension context 
		 */
		private static var _context: ExtensionContext;
		// AS DOC
		// private var _context: Object;
		
		/**
		 * @private
		 * Already checked that is supported
		 */
		private static var _supportCheckDone: Boolean = false;
		
		
		/**
		 * @private
		 * Current info on the fact that extension is supported
		 */
		private static var supported: Boolean;
		
		
		//Ben
		static public var instance:Bonjour;
		
		
		static public var currentServices:Vector.<Service>;
		// ---------------------------------------------------------------------
		// Methods (public)
		// ---------------------------------------------------------------------
		/**
		 * Initializes Bonjour object. Bonjour is a singleton, then constructor 
		 * throws an exception is already instatiated.
		 * 
		 * @param target target for teh inherited event dispatcher
		 * 
		 */
		public function Bonjour(target: IEventDispatcher = null) {
			if (!_isInstantiated) {
				
				currentServices = new Vector.<Service>();
				
				_context = ExtensionContext.createExtensionContext("org.opentekhnia.as3Bonjour", "");
				trace(ExtensionContext.getExtensionDirectory("org.opentekhnia.as3Bonjour").nativePath);
				_context.call("initDNSSD");
				_context.addEventListener(StatusEvent.STATUS, onStatus);
				_isInstantiated = true;
				NativeApplication.nativeApplication.addEventListener(Event.EXITING, appExiting);
				super(target);
			} else {
				throw new Error("Bonjour is already instatiated.");
			}
		}
		
		private function appExiting(e:Event):void 
		{
			dispose();
		}
		
		
		public static function init():void
		{
			if (instance != null) return;
			instance = new Bonjour();
		}
		
		/**
		 * On status event handler 
		 * @param event status event that comes from teh extension
		 */
		public function onStatus(event: StatusEvent): void {
			var service: Service;
			
			if (event.level == BonjourEvent.NE_DNSSD_SERVICE_EVENT) {
				switch (event.code) {
					case BonjourEvent.DNSSD_SERVICE_FOUND: {
						service = getFoundService();
						break;
					}
					case BonjourEvent.DNSSD_SERVICE_RESOLVED: {
						service = getResolvedService();
						addService(service);
						break;
					}
					case BonjourEvent.DNSSD_SERVICE_REMOVED: {
						service = getRemovedService();
						removeService(service);
						break;
					}
					case BonjourEvent.DNSSD_ERROR: {
						
					}
				}
				
				dispatchEvent(new BonjourEvent(event.code, service));
				
			} else if (event.level == BonjourEvent.NE_DNSSD_HOST_EVENT)  {
				var resolvedHostInfo: ResolvedHostInfo;
				
				switch (event.code) {
					case BonjourEvent.DNSSD_HOST_RESOLVED: {
						resolvedHostInfo = getResolvedHost();
						updateServiceWithHost(resolvedHostInfo);
						break;
					}
					case BonjourEvent.DNSSD_ERROR: {
						
					}
				}
				
				dispatchEvent(new BonjourEvent(event.code, resolvedHostInfo));
			}
		}
		
		private function addService(service:Service):void 
		{
			if (getServiceByName(service.name) != null) return;
			currentServices.push(service);
		}
		
		private function getServiceByName(serviceName:String):Service 
		{
			for each(var s:Service in currentServices)
			{
				if (s.name == serviceName) return s;
			}
			
			return null;
		}
		
		private function removeService(service:Service):void 
		{
			var s:Service = getServiceByName(service.name);
			if (s == null) return;
			currentServices.splice(currentServices.indexOf(s), 1);
		}
		
		
		private function updateServiceWithHost(h:ResolvedHostInfo):void
		{
			var mainIP:String = IPUtil.getLocalIP();
			for each(var s:Service in currentServices)
			{
				if (s.address == null) s.address = h.address;
				else
				{
					var a1:Number = IPUtil.getAffinity(mainIP, s.address);
					var a2:Number = IPUtil.getAffinity(mainIP, h.address);
					if (a2 > a1) s.address = h.address;
				}
			}
		}
		
		/**
		 * Disposes the extension object and cleans up
		 */
		public function dispose(): void {
			_context.call("stopDNSSD");
			_context.dispose();	
		}

		
		/** 
		 * Starts browsing for a given service.
		 * 
		 * Extracted from Poco C++ doc 
	 	 * Copyright © 2012, Applied Informatics Software Engineering GmbH (and Contributors)
		 * 
		 * Browse for a service type on a specific network interface, given by its index in 
		 * networkInterface. An interface with index 0 can be specified to search on all 
		 * interfaces.
		 * Results will be reported asynchronously via the serviceFound, serviceRemoved and 
		 * serviceError events.
		 * The regType is used as handle for stop command as parameter.
		 * 
		 * Note: It is possible to enumerate all service types registered on the local network 
		 * by browsing for the special regType "_services._dns-sd._udp". Available service types 
		 * will be reported with the Service object's name containing the service type 
		 * (e.g., "_ftp") and the Service's type containing the protocol and domain 
		 * (e.g., "_tcp.local.").
		 * 
		 * More info from Poco C++ doc: 
		 * 		@see http://www.appinf.com/docs/poco/Poco.DNSSD.DNSSDBrowser.html
		 * 
		 * @param regType	regType specifies the service type and protocol, separated by a dot
		 *  				(e.g., "_ftp._tcp"). The transport protocol must be either "_tcp" or
		 * 					"_udp". Optionally, a single subtype may be specified to perform 
		 * 					filtered browsing: e.g. browsing for "_primarytype._tcp,_subtype" 
		 * 					will discover only those instances of "_primarytype._tcp" that were 
		 * 					registered specifying "_subtype" in their list of registered subtypes.
		 * @param domain	domain specifies the domain on which to browse for services. If an 
		 * 					empty string is specified, the default domain(s) will be browsed.
		 * @param 
		 */
		public static function browse(regType: String, domain: String, networkInterface: uint = 0): Boolean {
			return _context.call("browse", regType, domain, networkInterface) as Boolean;
		}
		
		
		/** 
		 * Stops browsing for a given service. Uses the regType as handle at AS3 level.
		 * @param regType	regType specifies the service type and protocol
		 */
		public function stop(regType: String): Boolean {
			return _context.call("stop", regType) as Boolean;
		}
		
		
		/**
		 * Checks if the extension is supported
		 */
		public static function isSupported(): Boolean {
			var result: Boolean;
			
			if (_supportCheckDone) {
				return supported;
			} else {
				var tmpExtCtx: ExtensionContext = ExtensionContext.createExtensionContext("org.opentekhnia.as3Bonjour", "");
				result = tmpExtCtx.call("isSupported") as Boolean;
				tmpExtCtx.dispose();	
			}
			return result;
		}
		

		/** 
		 * Get service object for the last service found
		 * 
		 * @return Service object
		 */
		protected function getFoundService(): Service {
			return _context.call("getFoundService") as Service;
		}
		
		
		/** 
		 * Get service object for the last service resolved
		 * 
		 * @return Service object
		 */
		protected function getResolvedService(): Service {
			return _context.call("getResolvedService") as Service;
		}
		
		
		/** 
		 * Get service object for the last service removed
		 * 
		 * @return Service object
		 */
		protected function getRemovedService(): Service {
			return _context.call("getRemovedService") as Service;
		}		
		
		
		/** 
		 * Get resolved host info object for the last host resolved
		 * 
		 * @return Service object
		 */
		protected function getResolvedHost(): ResolvedHostInfo {
			return _context.call("getResolvedHost") as ResolvedHostInfo;
		}
		
		
		public static function registerService(name:String, type:String, port:int):int
		{
			return _context.call("registerService",name,type,port) as int;
		}
		
		public static function unregisterService(servicePtr:int):Boolean
		{
			return _context.call("unregisterService",servicePtr) as Boolean;
		}
		
		
		
	}
}