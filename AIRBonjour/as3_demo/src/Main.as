package
{
import benkuper.nativeExtensions.airBonjour.Bonjour;
import benkuper.nativeExtensions.airBonjour.data.*;
import benkuper.nativeExtensions.airBonjour.events.*;
import flash.net.InterfaceAddress;
import flash.net.NetworkInterface;

import benkuper.util.IPUtil;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.net.NetworkInfo;
import flash.ui.Keyboard;

	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class Main extends Sprite
	{
		public var serviceHandle:int;

		public function Main():void
		{
			
			Bonjour.init();
            serviceHandle = Bonjour.registerService("AIR Demo OSC 1", "_osc._udp", 7000);
			
			
			Bonjour.instance.addEventListener(BonjourEvent.DNSSD_SERVICE_FOUND, onServiceFound);
			Bonjour.instance.addEventListener(BonjourEvent.DNSSD_SERVICE_RESOLVED, onServiceResolved);
			Bonjour.instance.addEventListener(BonjourEvent.DNSSD_SERVICE_REMOVED, onServiceRemoved);
			Bonjour.instance.addEventListener(BonjourEvent.DNSSD_HOST_RESOLVED, onHostResolved);
			
			Bonjour.instance.addEventListener(BonjourEvent.DNSSD_ERROR, onBonjourError);
			
			Bonjour.browse('_ledcontrol._udp','');
			
			//trace("browse");
			//bonjour.browse('_apple-midi._udp', '');
			
			/*
			var p:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			for (var i:int = 0; i < p.length; i++)
			{
				trace(p[i].displayName);
				for each(var a:InterfaceAddress in p[i].addresses)
				{
					trace(a.broadcast);
				}
			}
			*/
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		private function onBonjourError(e:BonjourEvent):void
		{
			trace("Bonjour error");
		}
		
		private function onHostResolved(e:BonjourEvent):void 
		{
			var hostInfo:ResolvedHostInfo = e.info as ResolvedHostInfo;
			//trace("Host resolved :" + hostInfo.address + "/" + hostInfo.host + ":" + hostInfo.ttl);
			var affinity:Number = IPUtil.getAffinity(IPUtil.getLocalIP(), hostInfo.address);
			//trace(affinity);
			
			trace("Host resolved");
			trace(Bonjour.currentServices);
		}
		
		private function onServiceRemoved(e:BonjourEvent):void 
		{
			var service:Service = e.info as Service;
			trace("Service removed", service.name);
			trace(Bonjour.currentServices);
		}
		
		private function onServiceFound(e:BonjourEvent):void 
		{
			var service:Service = e.info as Service;
			trace("Service found", service.name+"(" + service.fullName+")");
		}
		
		protected function onServiceResolved(e:BonjourEvent):void
		{
			var service:Service = e.info as Service;
			trace("Service resolved", service.name+"("+service.fullName+") => "+ service.host+", "+service.address+":"+service.port);
            trace(Bonjour.currentServices.length,"services total");
		}

        private function keyDown(event:KeyboardEvent):void {
            switch(event.keyCode)
            {

                case Keyboard.R:
                    serviceHandle = Bonjour.registerService("AIR Demo OSC 2", "_osc._udp", 2);
                    break;

                case Keyboard.U:
                    Bonjour.unregisterService(serviceHandle);
                    break;
            }
        }
    }

}