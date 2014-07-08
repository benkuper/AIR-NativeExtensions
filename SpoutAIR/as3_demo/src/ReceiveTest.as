package  
{
	import benkuper.nativeExtensions.Spout;
	import benkuper.nativeExtensions.SpoutEvent;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class ReceiveTest extends Sprite 
	{
		private var spout:Spout;
		
		private var rName:String;
		private var rBM:Bitmap;
		
		public function ReceiveTest() 
		{
			super();
			
			spout = new Spout();
			spout.addEventListener(SpoutEvent.SHARING_STARTED, sharingStarted);
			spout.addEventListener(SpoutEvent.SHARING_STOPPED, sharingStopped);
			spout.startReceiving();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			
			stage.addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			if (rBM != null) spout.updateReceiveTexture(rName, rBM);
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			switch(e.keyCode)
			{
				case Keyboard.SPACE:
					if (rName != null && rName != "") 
					{
						rBM = spout.receiveTexture(rName);
						if(rBM != null) addChild(rBM);
					}
					break;
			}
		}
		
		
		
		private function sharingStarted(e:SpoutEvent):void 
		{
			trace("Sharing started !", e.sharingName);
			rName = e.sharingName;
			//spout.receiveTexture(e.sharingName);
		}
		
		private function sharingStopped(e:SpoutEvent):void 
		{
			trace("Sharing stopped !", e.sharingName);
		}
		
	}

}