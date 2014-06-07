package
{
	public class RibbonParticle
	{
		
		public var px:Number, py:Number;                                       	// x and y position of particle (this is the bexier point)
		public var xSpeed:Number = 0;												// speed of the x position
		public var ySpeed:Number = 0;					                           	// speed of the y position
		public var cx1:Number, cy1:Number, cx2:Number, cy2:Number;					// the avarage x and y positions between px and py and the points of the surrounding Particles
		public var leftPX:Number, leftPY:Number, rightPX:Number, rightPY:Number;	// the x and y points of that determine the thickness of this segment
		public var lpx:Number, lpy:Number, rpx:Number, rpy:Number;					// the x and y points of the outer bezier points
		public var lcx1:Number, lcy1:Number, lcx2:Number, lcy2:Number;				// the avarage x and y positions between leftPX and leftPX and the left points of the surrounding Particles
		public var rcx1:Number, rcy1:Number, rcx2:Number, rcy2:Number;				// the avarage x and y positions between rightPX and rightPX and the right points of the surrounding Particles
		public var radius:Number;													// thickness of current particle
		public var randomness:Number;
		public var ribbon:Ribbon;
		public var HALF_PI:Number = Math.PI/2;
		
		public function RibbonParticle(randomness:Number, ribbon:Ribbon)
		{
			this.randomness = randomness;
			this.ribbon = ribbon;
		}
		
		public function calculateParticles(pMinus1:RibbonParticle, pPlus1:RibbonParticle, particleMax:int, i:int):void
		{
			var div:Number = 2;
			cx1 = (pMinus1.px + px) / div;
			cy1 = (pMinus1.py + py) / div;
			cx2 = (pPlus1.px + px) / div;
			cy2 = (pPlus1.py + py) / div;

			// calculate radians (direction of next point)
			var dx:Number = cx2 - cx1;
			var dy:Number = cy2 - cy1;

			var pRadians:Number = Math.atan2(dy, dx);

			var distance:Number = Math.sqrt(dx*dx + dy*dy);

			if (distance > ribbon.maxDistance) 
			{
				var oldX:Number = px;
				var oldY:Number = py;
				px = px + ((ribbon.maxDistance/ribbon.drag) * Math.cos(pRadians));
				py = py + ((ribbon.maxDistance/ribbon.drag) * Math.sin(pRadians));
				xSpeed += (px - oldX) * ribbon.dragFlare;
				ySpeed += (py - oldY) * ribbon.dragFlare;
			}

			ySpeed += ribbon.gravity;
			xSpeed *= ribbon.friction;
			ySpeed *= ribbon.friction;
			px += xSpeed + (Math.random()*.3);
			py += ySpeed + (Math.random()*.3);

			var randX:Number = ((randomness / 2) - (Math.random()*randomness)) * distance;
			var randY:Number = ((randomness / 2) - (Math.random()*randomness)) * distance;
			px += randX;
			py += randY;

			//float radius = distance / 2;
			//if (radius > radiusMax) radius = ribbon.radiusMax;
			
			if (i > particleMax / 2) 
			{
			  radius = distance / ribbon.radiusDivide;
			} 
			else 
			{
			  radius = pPlus1.radius * .9;
			}

			if (radius > ribbon.radiusMax) radius = ribbon.radiusMax;
			if (i == particleMax - 2 || i == 1) 
			{
			  if (radius > 1) radius = 1;
			}
			// calculate the positions of the particles relating to thickness
			leftPX = px + Math.cos(pRadians + (HALF_PI * 3)) * radius;
			leftPY = py + Math.sin(pRadians + (HALF_PI * 3)) * radius;
			rightPX = px + Math.cos(pRadians + HALF_PI) * radius;
			rightPY = py + Math.sin(pRadians + HALF_PI) * radius;

			// left and right points of current particle
			lpx = (pMinus1.lpx + lpx) / div;
			lpy = (pMinus1.lpy + lpy) / div;
			rpx = (pPlus1.rpx + rpx) / div;
			rpy = (pPlus1.rpy + rpy) / div;
			
			// left and right points of previous particle
			lcx1 = (pMinus1.leftPX + leftPX) / div;
			lcy1 = (pMinus1.leftPY + leftPY) / div;
			rcx1 = (pMinus1.rightPX + rightPX) / div;
			rcy1 = (pMinus1.rightPY + rightPY) / div;
			
			// left and right points of next particle
			lcx2 = (pPlus1.leftPX + leftPX) / div;
			lcy2 = (pPlus1.leftPY + leftPY) / div;
			rcx2 = (pPlus1.rightPX + rightPX) / div;
			rcy2 = (pPlus1.rightPY + rightPY) / div;
		}

	}
}