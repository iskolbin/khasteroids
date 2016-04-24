package ;

class GameEntity {
	
	public var x: Float;
	public var y: Float;
	public var vx: Float;
	public var vy: Float;
	public var sin: Float;
	public var cos: Float;
	public var angle(default,set): Float;
	public var vertices: Array<Float>;
	public var rotatedVertices: Array<Float>;
	public var firing: Bool;
	public var cooldown: Float;
	public var rotatingCCW: Bool;
	public var rotatingCW: Bool;
	public var throttling: Bool; 
	public var lifespan: Float;

	public var type: GameEntityType;
	public var gameState: GameState;

	public static function makeAsteroidVertices( size: Float ) {
		return [-size,-size, size,-size, size,size, -size,size, -size,-size];
	}

	public static function makeVertices( type: GameEntityType ) return switch( type ) {
		case PlayerShip: [5.0,0.0, -5.0,2.0, -4.0,0.0, -4.0,-2.0, 5.0,0.0];
		case PlayerBullet: [1.0,0.0, -1.0,1.0, -1.0,-1.0];
		case BigAsteroid: makeAsteroidVertices(20.0);
		case MediumAsteroid: makeAsteroidVertices(12.0);
		case SmallAsteroid: makeAsteroidVertices(7.0);
		case AlienShip: [];
		case AlienBullet:	[1.0,0.0, -1.0,1.0, -1.0,-1.0];
	}

	function set_angle( v: Float ) { 
		if ( v != this.angle ) {
			this.angle = v; 
			updateAngle(); 
		}
		return v; 
	}

	function updateAngle() {
		cos = Math.cos( angle );
		sin = Math.sin( angle );
		var j = 0;
		while ( j < vertices.length ) {
			var px = vertices[j];
			var py = vertices[j+1];
			rotatedVertices[j] = cos * px - sin * py;
			rotatedVertices[j+1] = sin * px + cos * py;
			j += 2;
		}		
	}

	public function new( gameState: GameState, type: GameEntityType, x: Float, y: Float, vx: Float, vy: Float, angle: Float ) {
		this.gameState = gameState;
		this.type = type;
		this.x = x;
		this.y = y;
		this.vx = vx;
		this.vy = vy;
		this.vertices = makeVertices( type );
		this.firing = false;
		this.rotatingCW = false;
		this.rotatingCCW = false;
		this.throttling = false;
		this.rotatedVertices = [];
		this.angle = angle;	
		this.cooldown = 0.0;
		this.lifespan = switch( type ) {
			case PlayerBullet: Const.playerBulletLifeSpan;
			case AlienBullet: Const.alienBulletLifeSpan;
			case _: -1.0;
		}
	}

	public function update( dt: Float ) {
		x += vx * dt;
		y += vy * dt;

		if ( x > Const.sceneHalfWidth ) 
			x = -Const.sceneHalfWidth;
		else if ( x < -Const.sceneHalfWidth ) 
			x = Const.sceneHalfWidth;


		if ( y > Const.sceneHalfHeight ) 
			y = -Const.sceneHalfHeight;
		else if ( y < -Const.sceneHalfHeight ) 
			y = Const.sceneHalfHeight;

		if ( cooldown > 0 ) {
			cooldown -= dt;
		}

		if ( lifespan > 0 ) {
			lifespan -= dt;
			if ( lifespan <= 0 ) {
				gameState.destroy( this );
				return ;
			}
		}

		if ( type == PlayerShip ) {
			if ( rotatingCW && !rotatingCCW ) {
				angle += dt*Const.playerAngularVelocity;
			}

			if ( rotatingCCW && !rotatingCW ) {
				angle -= dt*Const.playerAngularVelocity;
			}

			if ( throttling ) {
				vx += Const.playerLinearAcceleration * cos;
				vy += Const.playerLinearAcceleration * sin;
			}	
		}

		if ( firing && cooldown <= 0.0 ) switch( type ) {
			case PlayerShip: 
				gameState.create( PlayerBullet, x, y, Const.playerBulletVelocity, angle );
				cooldown = Const.playerCooldown;

			case AlienShip: 
				var player = gameState.playerShip;
				if ( player != null ) {
					var newAngle = Math.atan2( player.x - x, player.y - y );
					gameState.create( AlienBullet, x, y, Const.alienBulletVelocity, newAngle );
					cooldown = Const.alienCooldown;
				}

			case _:
		}
	}

	public function split( newType: GameEntityType, number: Int, velocity: Float ) {
		gameState.destroy( this );
		for ( i in 0...number ) {
			var newAngle = 2 * Const.PI * Math.random();
			gameState.create( newType, x, y, velocity, newAngle );
		}
	}

	public function collidedWith( entity: GameEntity ) {
		switch ( type ) {
			case PlayerShip | PlayerBullet: switch( entity.type ) {
				case BigAsteroid | MediumAsteroid | SmallAsteroid | AlienShip | AlienBullet: gameState.destroy( this );
				case _:
			}
			case BigAsteroid: switch( entity.type ) {
				case PlayerShip | PlayerBullet: split( MediumAsteroid, Const.bigAsteroidPieces, Const.mediumAsteroidVelocity );
				case _:
			}
			case MediumAsteroid: switch( entity.type ) {
				case PlayerShip | PlayerBullet: split( SmallAsteroid, Const.mediumAsteroidPieces, Const.smallAsteroidVelocity );
				case _:
			}
			case SmallAsteroid | AlienShip | AlienBullet: switch( entity.type ) {
				case PlayerShip | PlayerBullet: gameState.destroy( this );
				case _:
			}
		}
	}
}
