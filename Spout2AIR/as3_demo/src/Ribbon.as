package
{
	import flash.display.Sprite;
	
	public class Ribbon
	{
		
		private var ribbonAmount:int;
		private var randomness:Number;
		private var ribbonParticleAmount:int;		// length of the Particle Array (max number of points)
		private var particlesAssigned:int = 0;		// current amount of particles currently in the Particle array                                
		public var radiusMax:Number = 8;			// maximum width of ribbon
		public var radiusDivide:Number = 10;		// distance between current and next point / this = radius for first half of the ribbon
		public var gravity:Number = .03;			// gravity applied to each particle
		public var friction:Number = 1.1;			// friction applied to the gravity of each particle
		public var maxDistance:Number = 40;			// if the distance between particles is larger than this the drag comes into effect
		public var drag:Number = 2;					// if distance goes above maxDistance - the points begin to grag. high numbers = less drag
		public var dragFlare:Number = .008;			// degree to which the drag makes the ribbon flare out
		private var particles:Array;				// particle array
		private var ribbonColor:Number;
		private var drawTarget:Sprite;
		
		public function Ribbon(container:Sprite, ribbonParticleAmount:int, ribbonColor:Number, randomness:Number)
		{
			drawTarget = new Sprite();
			drawTarget.blendMode = "add";
			container.addChild(drawTarget);
			
			this.ribbonParticleAmount = ribbonParticleAmount;
			this.ribbonColor = ribbonColor;
			this.randomness = randomness;
			init();
		}
  
		private function init():void
		{
			particles = new Array(ribbonParticleAmount);
		}
		
		public function update(randX:Number, randY:Number):void
		{
			addParticle(randX, randY);
			drawCurve();
		}
		
		private function addParticle(randX:Number, randY:Number):void
		{
			if(particlesAssigned == ribbonParticleAmount)
			{
				for (var i:int = 1; i < ribbonParticleAmount; i++)
				{
					particles[i-1] = particles[i];
				}
				particles[ribbonParticleAmount - 1] = new RibbonParticle(randomness, this);
				particles[ribbonParticleAmount - 1].px = randX;
				particles[ribbonParticleAmount - 1].py = randY;
				return;
			}
			else
			{
				particles[particlesAssigned] = new RibbonParticle(randomness, this);
				particles[particlesAssigned].px = randX;
				particles[particlesAssigned].py = randY;
				particlesAssigned++;
			}
			if (particlesAssigned > ribbonParticleAmount) particlesAssigned++;
		}

		private function drawCurve():void
		{
			drawTarget.graphics.clear();
			drawTarget.graphics.beginFill(ribbonColor, 1);
			var i:int;
			var p:RibbonParticle;
			for (i = 1; i < particlesAssigned - 1; i++)
			{
				p = particles[i] as RibbonParticle;
				p.calculateParticles(particles[i-1], particles[i+1], ribbonParticleAmount, i);
			}
			
			
			for (i = particlesAssigned - 3; i > 0; i--)
			{
				p = particles[i];
				var pm1:RibbonParticle = particles[i-1];
				if (i < particlesAssigned-3) 
				{
					drawTarget.graphics.moveTo(p.lcx2, p.lcy2);
					drawTarget.graphics.curveTo(p.leftPX, p.leftPY,pm1.lcx2, pm1.lcy2);
					drawTarget.graphics.lineTo(pm1.rcx2, pm1.rcy2);
					drawTarget.graphics.curveTo(p.rightPX, p.rightPY,p.rcx2, p.rcy2);
					drawTarget.graphics.lineTo(p.lcx2, p.lcy2);
				}
			}
		}

	}
}