package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;

	public class Ribbons extends Sprite
	{
		private var ribbonAmount:int = 5;
		private var ribbonParticleAmount:int = 20;
		private var randomness:Number = .2;
		private var ribbonManager:RibbonManager;
		
		public function Ribbons()
		{
			this.filters = [new GlowFilter(0xff0000,1,50,50,1,2)];
  			ribbonManager = new RibbonManager(this, ribbonAmount, ribbonParticleAmount, randomness, "rothko_01.jpg");    // field, rothko_01-02, absImp_01-03 picasso_01
  			ribbonManager.setRadiusMax(8);			// default = 8
  			ribbonManager.setRadiusDivide(10);		// default = 10
  			ribbonManager.setGravity(.03);			// default = .03
  			ribbonManager.setFriction(1.1);			// default = 1.1
  			ribbonManager.setMaxDistance(40);		// default = 40
  			ribbonManager.setDrag(2);				// default = 2
			ribbonManager.setDragFlare(.008);		// default = .008
			
			addEventListener(Event.ENTER_FRAME, draw);
		}
		
		public function draw(e:Event):void
		{
			ribbonManager.update(mouseX, mouseY);
		}
	}
}
