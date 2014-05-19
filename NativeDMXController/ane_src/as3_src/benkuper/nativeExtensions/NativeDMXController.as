package benkuper.nativeExtensions
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExtensionContext;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class  NativeDMXController extends EventDispatcher
	{
		private var _devices:Vector.<DMXDevice>;		
		private var extContext:ExtensionContext;
		
		public var autoSearch:Boolean;
		private var listTimer:Timer;
		
		
		public function NativeDMXController(autoSearch:Boolean = true):void
		{
			this.autoSearch = autoSearch;
			
			_devices = new Vector.<DMXDevice>();
			
			extContext = ExtensionContext.createExtensionContext("benkuper.nativeExtensions.NativeDMXController", "dmx");
			
			var initResult:Boolean = extContext.call("init") as Boolean;
			
			listTimer = new Timer(1000);
			listTimer.addEventListener(TimerEvent.TIMER, listTimerTick);
			listTimer.start();
		}
		
		private function listTimerTick(e:TimerEvent):void 
		{
			if(autoSearch) updateDeviceList();
		}
		
		
		
		public function updateDeviceList() : Vector.<DMXDevice>
		{
			var dd:DMXDevice;
			var d:DMXDevice;
			
			//update devices and merge with existing ones
			var detectedDevices:Vector.<DMXDevice> = extContext.call("listDevices") as Vector.<DMXDevice>;
			
			//Connection detection
			for each(dd in detectedDevices)
			{
				var alreadyConnected:Boolean = false;
				for each(d in devices)
				{
					if (d.serial == dd.serial)
					{
						alreadyConnected = true;
						break;
					}
				}
				if (!alreadyConnected) addDevice(dd);
			}
			
			//Deconnection detection
			for each(d in devices)
			{
				var stillConnected:Boolean = false;
				for each(dd in detectedDevices)
				{
					if (d.serial == dd.serial)
					{
						stillConnected = true;
						break;
					}
				}
				
				if (!stillConnected) removeDevice(d);
			}
			
			return devices;
		}
		
		
		
		private function addDevice(device:DMXDevice):void 
		{
			trace("[NativeDMXController] Add device :",device);
			devices.push(device);
			
			dispatchEvent(new DMXEvent(DMXEvent.DEVICE_CONNECTED,device));
		}
		
		private function removeDevice(device:DMXDevice):void 
		{
			trace("[NativeDMXController] Remove device :", device);
			devices.splice(devices.indexOf(device), 1);
			device.clean();
			
			dispatchEvent(new DMXEvent(DMXEvent.DEVICE_DISCONNECTED, device));
			
		}
		
		public function openDevice (deviceIndex:int) : DMXDevice
		{
			if (devices.length == 0) return null;
			
			var result:Boolean = devices[0].open();
			if (result) return devices[0];
			
			return null;
		}
		
		
		
		
		public function dispose () : void
		{
			for each(var d:DMXDevice in devices)
			{
				if (d.opened) d.close();
			}
			
			listTimer.reset();
			listTimer.removeEventListener(TimerEvent.TIMER, listTimerTick);
			
		}
		
		
		//Getter / Setter
		
		public function get devices():Vector.<DMXDevice> 
		{
			return _devices;
		}
		
	}
	
} 