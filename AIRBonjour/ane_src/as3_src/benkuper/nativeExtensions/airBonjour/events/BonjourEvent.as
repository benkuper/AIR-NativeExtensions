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
package benkuper.nativeExtensions.airBonjour.events
{
	import flash.events.Event;

	/**
	 * Defines Bonjour specific event. Allows to push Service objects to AS3 
	 * Bonjour client.
	 */
	public class BonjourEvent extends Event {
		// ---------------------------------------------------------------------
		// Constants
		// ---------------------------------------------------------------------
		public static const NE_DNSSD_SERVICE_EVENT: String = "serviceEvent";
		public static const NE_DNSSD_HOST_EVENT: String = "hostEvent";
		
		public static const DNSSD_SERVICE_FOUND: String = "serviceFound";
		public static const DNSSD_SERVICE_RESOLVED: String = "serviceResolved";
		public static const DNSSD_SERVICE_REMOVED: String = "serviceRemoved";
		public static const DNSSD_HOST_RESOLVED: String = "hostResolved";
		
		public static const DNSSD_ERROR: String = "error";
		
		// ---------------------------------------------------------------------
		// Properties
		// ---------------------------------------------------------------------
		/** 
		 * Service or resolved host info
		 */
		public var info: Object;
		
		// ---------------------------------------------------------------------
		// Methods
		// ---------------------------------------------------------------------
		/** 
		 * Event constructor
		 * @param type			event type
		 * @param service		service info to be pushed to listener
		 * @param bubbles 	
		 * @param cancelable
		 */
		public function BonjourEvent(type: String, info: Object, bubbles: Boolean=false, cancelable: Boolean=false) {
			this.info = info;
			super(type, bubbles, cancelable);
		}
	}
}