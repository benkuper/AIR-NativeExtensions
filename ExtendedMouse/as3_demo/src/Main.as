package 
{
	import benkuper.nativeExtensions.ExtendedMouse;
	import benkuper.util.Shortcutter;
	import flash.display.Sprite;
import flash.events.MouseEvent;

/**
	 * ...
	 * @author Ben Kuper
	 */
	public class Main extends Sprite 
	{
		
		private var testSprite:Sprite;
	    private var mouseIsDown:Boolean;

		public function Main():void 
		{
			Shortcutter.init(stage);
			Shortcutter.add(this);
			
			testSprite = new Sprite();
			addChild(testSprite);
			testSprite.graphics.beginFill(0xff0000);
			testSprite.graphics.drawRect(0, 0, 100, 100);
			testSprite.graphics.endFill();
			testSprite.x = 200;
			testSprite.y = 300;


        }

		[Shortcut(key='c')]
		public function clear():void
		{
			graphics.clear();
		}
		
		[Shortcut(key='r')]
		public function setRandomStage():void
		{
			ExtendedMouse.setCursorStagePos(Math.random() * stage.stageWidth, Math.random() * stage.stageHeight);
			graphics.beginFill(0x5500ff);
			graphics.drawCircle(mouseX, mouseY, 5);
			graphics.endFill();
		}
		
		[Shortcut(key='s')]
		public function setRandomScreen():void
		{
			ExtendedMouse.setCursorScreenPos(Math.random() * stage.stageWidth, Math.random() * stage.stageHeight);
		
		}
		
		
		[Shortcut(key = 'a', params="0")]
		[Shortcut(key = 'z', params="1")]
		public function setPosOnSprite(rPos:Number):void
		{
			ExtendedMouse.setCursorRelativePos(rPos * testSprite.width, rPos * testSprite.height, testSprite);
			
			graphics.beginFill(0xff00ff);
			graphics.drawCircle(mouseX, mouseY, 5);
			graphics.endFill();

		}


}
	
}