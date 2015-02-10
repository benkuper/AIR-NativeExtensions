package benkuper.util 
{
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class IPUtil 
	{
		
		public function IPUtil() 
		{
			
		}
		
		public static function getLocalIP(getBroadcast:Boolean =false):String
		{
			if (!NetworkInfo.isSupported)
			{
				trace("NetworkInfo not supported !");
				return "127.0.0.1";
			}
			
			var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			var targetAdd:InterfaceAddress;
			for each(var inf:NetworkInterface in interfaces)
			{
				for each (var add:InterfaceAddress in inf.addresses)
				{
					if (add.address.match(/192.168.[01]/) !=  null) targetAdd = add; //192.168.[0-1] gets priority
					else if (add.address.slice(0, 7) == "192.168") targetAdd = add; //then 192.168.*
					else if (add.address.split(".")[0] == "10") targetAdd = add; //then 10.* (e.g. Android hotspot)
					else if (add.address.match(/2.0./) != null) targetAdd = add; //then 2.0.* (e.g. artnet nodes)
				}
			}
			
			if (targetAdd == null)
			{
				trace("no local addresses found !");
				return "127.0.0.1";
			}else
			{
				return getBroadcast?targetAdd.broadcast:targetAdd.address;
			}
		}
		
		public static function getAffinity(ip1:String,ip2:String):Number
		{
			var ip1Split:Array = ip1.split(".");
			var ip2Split:Array = ip2.split(".");
			var result:Number = 0;
			for (var i:int = 0; i < 4; i++)
			{
				if (ip1Split[i] == ip2Split[i]) result += .25;
			}
			
			return result;
		}
		
		public static function getLocalIPOfInterface(sourceIP:String):String
		{
			var sourceSplit:Array = sourceIP.split(".");
			
			var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			for each(var inf:NetworkInterface in interfaces)
			{
				for each (var add:InterfaceAddress in inf.addresses)
				{
					var addSplit:Array = add.address.split(".");
					if (addSplit[0] == sourceSplit[0]) return add.address;
					//else if (add.address.slice(0, 7) == "192.168") return add.address;
				}
			}
			
			trace("no local addresses found for "+sourceIP+" !");
			return "127.0.0.1";
		}
	}

}