package ;

class GameEntity {
	
	public var x(default,null): Float;
	public var y(default,null): Float;
	public var vx(default,null): Float;
	public var vy(default,null): Float;
	public var angle(default,null): Float;
	
	public var sin(default,null): Float;
	public var cos(default,null): Float;
	
	public var vertices(default,null): Array<Array<Float>>;
	public var transformedVertices(default,null): Array<Array<Float>>;
	
	public var aabbTop(default,null): Float;
	public var aabbLeft(default,null): Float;
	public var aabbRight(default,null): Float;
	public var aabbBottom(default,null): Float;
	
	public var firing: Bool;
	public var cooldown: Float;
	public var rotatingCCW: Bool;
	public var rotatingCW: Bool;
	public var throttling: Bool; 
	public var lifespan: Float;
	public var ghost: Float;

	public var type: GameEntityType;
	public var gameState: GameState;

	public static function makeAsteroidVertices( size: Float ) {
		var nvertices = 6 + Std.random(6);
		var vertices = [];
		var dangle = 2*Const.PI / nvertices;
		var angle = 0.0;
		for ( i in 0...nvertices ) {
			var r = 0.33 * size + 0.67 * size * Math.random();
			vertices.push( r * Math.cos( angle ));
			vertices.push( r * Math.sin( angle ));
			angle -= dangle;
		}
		vertices.push( vertices[0] );
		vertices.push( vertices[1] );
		return MinSat.triangulateInplace(vertices);
	}

	public static function makeVertices( type: GameEntityType ) return switch( type ) {
		case PlayerShip: MinSat.triangulateInplace([15.0,0.0, -15.0,-6.0, -12.0,0.0, -15.0,6.0, 15.0,0.0]);
		case PlayerBullet: [[1.0,0.0, -1.0,1.0, -1.0,-1.0]];
		case BigAsteroid: makeAsteroidVertices(30.0);
		case MediumAsteroid: makeAsteroidVertices(15.0);
		case SmallAsteroid: makeAsteroidVertices(7.0);
		case AlienShip: [];
		case AlienBullet:	[[1.0,0.0, -1.0,1.0, -1.0,-1.0]];
	}

	public function setX( v: Float ) {
		if ( v != this.x ) {
			this.x = v;
			updateTransform();
		}
	}	

	public function setY( v: Float ) {
		if ( v != this.y ) {
			this.y = v;
			updateTransform();
		}
	}	

	public function setPos( px: Float, py: Float ) {
		if ( px != this.x || py != this.y ) {
			this.x = px;
			this.y = py;
			updateTransform();
		}
	}

	public inline function setVx( v: Float ) {
		this.vx = v;
	}

	public inline function setVy( v: Float ) {
		this.vy = v;
	}

	public inline function setVelocity( nvx: Float, nvy: Float ) {
		this.vx = nvx;
		this.vy = nvy;
	}

	public function setAngle( v: Float ) { 
		if ( v != this.angle ) {
			this.angle = v; 
			updateAngle();
			updateTransform();
		}
		return v; 
	}

	inline function updateAngle() {
		if ( angle == 0.0 ) {
			cos = 1.0;
			sin = 0.0;
		} else {
			cos = Math.cos( angle );
			sin = Math.sin( angle );
		}
	}

	public inline function addX( dx: Float ) setX( this.x + dx );
	public inline function addY( dy: Float ) setY( this.y + dy );
	public inline function addPos( dx: Float, dy: Float ) setPos( this.x + dx, this.y + dy );
	public inline function addVx( dvx: Float ) setVx( this.vx + dvx );
	public inline function addVy( dvy: Float ) setVy( this.vy + dvy );
	public inline function addVelocity( dvx: Float, dvy: Float ) setVelocity( this.vx + dvx, this.vy + dvy );
	public inline function addAngle( dangle: Float ) setAngle( this.angle + dangle );

	static inline function fmin( a: Float, b: Float ) return a < b ? a : b;

	static inline function fmax( a: Float, b: Float ) return a > b ? a : b;

	inline function updateTransform() {
		for ( i in 0...vertices.length ) {
			var vert = vertices[i];
			var j = 0;	
			while ( j < vert.length ) {
				if ( sin != 1.0 || cos != 0.0 ) {
					var px = vert[j];
					var py = vert[j+1];
					transformedVertices[i][j] = x + px * cos - py * sin;
					transformedVertices[i][j+1] = y + px * sin + py * cos;
				} else {
					transformedVertices[i][j] = vert[j] + x;
					transformedVertices[i][j+1] = vert[j+1] + y;
				}
				j += 2;
			}
		}
		updateAABB();
	}

	inline function updateAABB() {
		var vert = transformedVertices[0];
		
		var minx = fmin( vert[0], vert[2] );
		var maxx = fmax( vert[0], vert[2] );
		var miny = fmin( vert[1], vert[3] );
		var maxy = fmax( vert[1], vert[3] );
		var j = 4;		
		while ( j < vert.length ) {
			minx = fmin( minx, vert[j] );
			maxx = fmax( maxx, vert[j] );
			miny = fmin( miny, vert[j+1] );
			maxy = fmax( maxy, vert[j+1] );
			j += 2;
		}

		for ( i in 1...transformedVertices.length ) {
			vert = transformedVertices[i];
			j = 0;		
			while ( j < vert.length ) {
				minx = fmin( minx, vert[j] );
				maxx = fmax( maxx, vert[j] );
				miny = fmin( miny, vert[j+1] );
				maxy = fmax( maxy, vert[j+1] );
				j += 2;
			}
		}
		
		aabbLeft = minx;
		aabbTop = miny;
		aabbRight = maxx;
		aabbBottom = maxy;
	}

	public function new( gameState: GameState, type: GameEntityType, x: Float, y: Float, vx: Float = 0.0, vy: Float = 0.0, angle: Float = 0.0, ?vertices: Array<Array<Float>> ) {
		this.gameState = gameState;
		this.type = type;
		this.x = x;
		this.y = y;
		this.vx = vx;
		this.vy = vy;
		this.angle = angle;
		
		updateAngle();

		this.vertices = (vertices == null) ? makeVertices( type ) : vertices;
		this.transformedVertices = [];
		for ( v in this.vertices ) {
			this.transformedVertices.push( v.copy());
		}
	
		updateTransform();	
		
		this.firing = false;
		this.rotatingCW = false;
		this.rotatingCCW = false;
		this.throttling = false;
		this.ghost = 0.0;
		this.cooldown = 0.0;
		this.lifespan = switch( type ) {
			case PlayerBullet: Const.playerBulletLifeSpan;
			case AlienBullet: Const.alienBulletLifeSpan;
			case _: -1.0;
		}
	}

	public function update( dt: Float ) {
		x += vx*dt; 
		y += vy*dt;

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

		if ( ghost > 0 ) {
			ghost -= dt;
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
				updateAngle();
			}

			if ( rotatingCCW && !rotatingCW ) {
				angle -= dt*Const.playerAngularVelocity;
				updateAngle();
			}

			if ( throttling ) {
				addVelocity( Const.playerLinearAcceleration * cos, Const.playerLinearAcceleration * sin );
			}	
		}

		updateTransform();

		if ( firing && cooldown <= 0.0 ) switch( type ) {
			case PlayerShip: 
				var e = gameState.create( PlayerBullet, x, y, Const.playerBulletVelocity, angle );
				e.addVelocity( vx, vy );
				cooldown = Const.playerCooldown;

			case AlienShip: 
				var player = gameState.playerShip;
				if ( player != null ) {
					var newAngle = Math.atan2( player.x - x, player.y - y );
					var e = gameState.create( AlienBullet, x, y, Const.alienBulletVelocity, newAngle );
					e.addVelocity( vx, vy );
					cooldown = Const.alienCooldown;
				}

			case _:
		}
	}

	public function split( newType: GameEntityType, velocity: Float ) {
		gameState.destroy( this );
		var newAngle = 2 * Const.PI * Math.random();
		gameState.create( newType, x, y, velocity, newAngle, vertices.slice( 0, Std.int(vertices.length/2)));
		gameState.create( newType, x, y, velocity, newAngle + Const.PI, vertices.slice( Std.int(vertices.length/2)));
	}

	public function collidedWith( entity: GameEntity ) {
		switch ( type ) {
			case PlayerShip | PlayerBullet: switch( entity.type ) {
				case BigAsteroid | MediumAsteroid | SmallAsteroid | AlienShip | AlienBullet: gameState.destroy( this );
				case _:
			}
			case BigAsteroid: switch( entity.type ) {
				case PlayerShip | PlayerBullet: split( MediumAsteroid, Const.mediumAsteroidVelocity );
				case _:
			}
			case MediumAsteroid: switch( entity.type ) {
				case PlayerShip | PlayerBullet: split( SmallAsteroid, Const.smallAsteroidVelocity );
				case _:
			}
			case SmallAsteroid | AlienShip | AlienBullet: switch( entity.type ) {
				case PlayerShip | PlayerBullet: gameState.destroy( this );
				case _:
			}
		}
	}
}
