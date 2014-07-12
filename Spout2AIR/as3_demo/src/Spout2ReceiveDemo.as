package  
{
	import benkuper.nativeExtensions.Spout;
	import benkuper.nativeExtensions.SpoutReceiver;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class Spout2ReceiveDemo extends Sprite 
	{
		//spout stuff
		private var spout:Spout;
		private var sendName:String = "AIR Sender";
		private var receiver:SpoutReceiver;
		
		//drawing sprite
		private var s:Sprite;
		private var bd:BitmapData;
		private var bm:Bitmap;
		
		
		
		public function Spout2ReceiveDemo() 
		{
			super();
			
			
			spout = new Spout();
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			bm = new Bitmap();
			
			stage.nativeWindow.x = 800;
			
			graphics.beginFill(0x00ffff);
			graphics.drawCircle(300, 300, 200);
			graphics.endFill();
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			switch(e.keyCode)
			{
				case Keyboard.SPACE: 
					spout.extContext.call("showPanel");
					break;
			}
		}
		
		private function enterFrame(e:Event):void 
		{
			if (receiver == null)
			{
				receiver = spout.createReceiver("test");
				trace("receiver Found ? ", receiver);
				if(receiver != null) addChild(receiver);
			}else
			{
				spout.receiveTexture(receiver);
			}
			
		}
		
	}

}