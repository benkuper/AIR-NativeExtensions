 package 
{
	import benkuper.nativeExtensions.Spout;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display3D.*;
	import flash.display3D.textures.Texture;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	 
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class Main extends Sprite 
	{
		private var spout:Spout;
		
		//[Embed(source = "texture.jpg")]
		//private var TextureBM:Class;
		//private var bm:Bitmap;
		private var bd:BitmapData;
		private var ribbonAmount:int = 5;
		private var ribbonParticleAmount:int = 20;
		private var randomness:Number = .2;
		private var ribbonManager:RibbonManager;
		private var s:Sprite;
		
		public function Main()
		{
			s = new Sprite();
			addChild(s);
			s.filters = [new GlowFilter(0xff0000,1,50,50,2,2)];
  			ribbonManager = new RibbonManager(s, ribbonAmount, ribbonParticleAmount, randomness, "rothko_01.jpg");    // field, rothko_01-02, absImp_01-03 picasso_01
  			ribbonManager.setRadiusMax(8);			// default = 8
  			ribbonManager.setRadiusDivide(10);		// default = 10
  			ribbonManager.setGravity(.03);			// default = .03
  			ribbonManager.setFriction(1.1);			// default = 1.1
  			ribbonManager.setMaxDistance(40);		// default = 40
  			ribbonManager.setDrag(2);				// default = 2
			ribbonManager.setDragFlare(.008);		// default = .008
			
			spout = new Spout();
			bd = new BitmapData(stage.stageWidth,stage.stageHeight);
			//bd.draw(this);
			//var bm:Bitmap = new Bitmap(bd);
			//bm.x = 100;
			//bm.y = 100;
			////addChild(bm);
			spout.createSender("As3Test", bd.width,bd.height );
			
			
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			//s.graphics.clear();
			//s.graphics.beginFill(0xff0000);
			//s.graphics.drawCircle(mouseX, mouseY, 20);
			//s.graphics.endFill();
			
			ribbonManager.update(mouseX, mouseY);
			
			bd.fillRect(new Rectangle(0, 0, bd.width, bd.height), 0);
			bd.draw(this);
			spout.updateSender("As3Test", bd);
			
		}
	}
	
}