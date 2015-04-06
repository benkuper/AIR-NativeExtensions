package 
{
	import benkuper.nativeExtensions.ExtendedMouse;
	import benkuper.util.Shortcutter;

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.ui.Keyboard;

/**
	 * ...
	 * @author Ben Kuper
	 */
	public class MainMac extends Sprite
	{
		
		private var testSprite:Sprite;
		private var mouseIsDown:Boolean;

		public function MainMac():void
		{
			
			testSprite = new Sprite();
			addChild(testSprite);
			testSprite.graphics.beginFill(0xff0000);
			testSprite.graphics.drawRect(0, 0, 100, 100);
			testSprite.graphics.endFill();
			testSprite.x = 50;
			testSprite.y = 70;

            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);

            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP,mouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMove);
        }

        private function mouseDown(event:MouseEvent):void {
            mouseIsDown = true;
            trace("mouse down, cursor",mouseX,mouseY);
        }

        private function mouseUp(event:MouseEvent):void {
            mouseIsDown = false;

        }

        private function mouseMove(event:MouseEvent):void {
            if(mouseIsDown)
            {
                trace("mouse x/y",mouseX,mouseY);
                ExtendedMouse.setCursorStagePos(100,100);

            }
		}

        private function execMove(tx:int, ty:int):void
        {
            var process:NativeProcess = new NativeProcess();
            var infos:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            infos.executable = File.desktopDirectory.resolvePath("moveM");
            infos.arguments = new Vector.<String>();
            infos.arguments.push("-x","100","-y","100");
            process.start(infos);
            trace("process start");
        }

		public function clear():void
		{
			graphics.clear();
		}

		public function setRandomStage():void
		{
			ExtendedMouse.setCursorStagePos(Math.random() * stage.stageWidth, Math.random() * stage.stageHeight);
            graphics.beginFill(0x5500ff);
			graphics.drawCircle(mouseX, mouseY, 5);
			graphics.endFill();
		}

		public function setRandomScreen():void
		{
			ExtendedMouse.setCursorScreenPos(Math.random() * stage.stageWidth, Math.random() * stage.stageHeight);
		    trace(stage.mouseX,stage.mouseY);
		}
		

		public function setPosOnSprite(rPos:Number):void
		{
			ExtendedMouse.setCursorRelativePos(rPos * testSprite.width, rPos * testSprite.height, testSprite);
			
			graphics.beginFill(0xff00ff);
			graphics.drawCircle(mouseX, mouseY, 5);
			graphics.endFill();

		}

    private function keyDown(e:KeyboardEvent):void {
        switch(e.keyCode)
        {
            case Keyboard.C: clear(); break;
            case Keyboard.R: setRandomStage(); break;
            case Keyboard.S: setRandomScreen(); break;
            case Keyboard.A: setPosOnSprite(0); break;
            case Keyboard.Z: setPosOnSprite(1); break;
            case Keyboard.E: execMove(100,100);
        }
    }
}
	
}