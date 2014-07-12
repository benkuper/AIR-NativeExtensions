package benkuper.nativeExtensions
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class SpoutReceiver extends Sprite
	{
		
		public var textureName:String;
		
		public var textureWidth:int;
		public var textureHeight:int;
		
		protected var bitmap:Bitmap;
		public var bitmapData:BitmapData;
		
		
		
		public function SpoutReceiver(textureName:String,w:int,h:int):void
		{
			setInfos(textureName, w, h);
			
			trace("New SpoutReceiver !", textureName, textureWidth, textureHeight);
			
			bitmap = new Bitmap();
			addChild(bitmap);
		}
		
		public function setInfos(textureName:String, w:int, h:int):void
		{
			this.textureName = textureName;
			setSize(w, h);
		}
		
		
		
		public function update():void
		{
			bitmap.bitmapData = bitmapData;
		}
		
		public function setSize(w:int, h:int):void
		{
			textureWidth = w;
			textureHeight = h;
			bitmapData = new BitmapData(textureWidth, textureHeight, true, 0xffff00ff);
			trace("SpoutReceiver set Size :", textureWidth, textureHeight);
		}
		
		override public function toString():String
		{
			return "[SpoutReceiver, textureName = " + textureName+", dimensions = " + textureWidth + "*" + textureHeight + "]";
		}
	}
}