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
	 * Defines a simple name-value pair.
	 */
	public class NameValue {
		// ---------------------------------------------------------------------
		// Properties (public)
		// ---------------------------------------------------------------------
		/** Name (= key) */
		public var name: String;
		
		/** Value */
		public var value: String;
		
		// ---------------------------------------------------------------------
		// Methods
		// ---------------------------------------------------------------------
		/**
		 * To string method (for debug purposes)
		 */
		public function toString(): String {
			return "(" + name + ", " + value + ")"; 
		}
	}
}