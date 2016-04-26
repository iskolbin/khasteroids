package ;

class GameState {
	public var type: GameStateType;
	public var entities: Array<GameEntity>;
	public var deleteList: Array<GameEntity>;
	public var playerShip: GameEntity;

	public var level: Int;
	public var lives: Int;
	public var score: Int;
	public var goalEnemiesCount: Int;
	public var debug: Bool;

	public var left: Float;
	public var right: Float;
	public var top: Float;
	public var bottom: Float;

	public var playerRespawn: Float;

	public function new() {
		this.type = GameOver;
		this.entities = [];
		this.deleteList = [];
		this.debug = true;
		updateBounds( Const.sceneHalfWidth, Const.sceneHalfHeight );
	}

	public function create( etype: GameEntityType, x: Float, y: Float, velocity: Float, angle: Float, ?vertices: Array<Array<Float>> ) {
		var e = new GameEntity( this, etype, x, y, velocity*Math.cos(angle), velocity*Math.sin(angle), angle, vertices );
		if ( etype == PlayerShip ) {
			playerShip = e;
		}
		entities.push( e );

		return e;
	}

	public function destroy( e: GameEntity ) {
		var index = entities.indexOf( e );
		if ( index >= 0 ) {
			deleteList.push( e );
			
			switch ( e.type ) {
				case PlayerShip: 
					lives--; 
					playerShip = null;
					checkLives();
				case AlienShip: score += 300;
				case BigAsteroid: score += 100;
				case MediumAsteroid: score += 200;
				case SmallAsteroid: score += 200;
				case _:
			}

			if ( goalEnemiesCount <= 0 ) {
				level++;
				initLevel( level );
			}
		}
	}

	function createAsteroids( n: Int ) {
		for ( i in 0...n ) {
			create( BigAsteroid, Math.random()*(right-left) + left, Math.random()*(bottom-top) + top, Const.bigAsteroidVelocity, Math.random()*2*Math.PI ); 
			goalEnemiesCount += 6; 
		}
	}

	function initLevel( gameLevel: Int ) {
		switch ( gameLevel ) {
			case 0: createAsteroids( 4 );
			case 1: createAsteroids( 6 );
			case 2: createAsteroids( 8 );
		}
	}

	function checkLives() {
		if ( lives <= 0 ) {
			if ( type == Playing ) {
				type = GameOver;
			}
		} else {
			playerRespawn = Const.playerRespawnTime;
		}
	}

	public static inline function aabbAABB( left1: Float, top1: Float, right1: Float, bottom1: Float, left2: Float, top2: Float, right2: Float, bottom2: Float ) {	
		return left1 < right2 && left2 < right1 && top1 < bottom2 && top2 < bottom1;
	}

	inline function broadPhaseCollision( e: GameEntity, o: GameEntity )
		return e.ghost <= 0 && o.ghost <= 0 && aabbAABB( e.aabbLeft, e.aabbTop, e.aabbRight, e.aabbBottom, o.aabbLeft, o.aabbTop, o.aabbRight, o.aabbBottom );

	inline function checkCollisions() {
		for ( i in 0...entities.length ) {
			var e = entities[i];
			for ( j in i + 1...entities.length ) {
				var o = entities[j];
				if ( broadPhaseCollision( e, o )){
					if( MinSat.testComposites( e.transformedVertices, o.transformedVertices )) {
						e.collidedWith( o );
						o.collidedWith( e );
					}
				}
			}
		}	
	}

	inline function checkPlayerAlive( dt: Float ) {
		if ( playerShip == null ) {
			if ( playerRespawn > 0 ) {
				playerRespawn -= dt;
			} else {
				var e = create( PlayerShip, 0, 0, 0, 0 );
				e.ghost = Const.playerInvunerabilityTime;
			}
		}
	}

	inline function destroyEntities() {
		while ( deleteList.length > 0  ) {
			var e = deleteList.pop();
			entities.splice( entities.indexOf(e), 1 );
		}
	}

	inline function updateEntities( dt: Float ) {
		for ( e in entities ) {
			e.update( dt );
		}
	}

	public function update( dt: Float ) {
		switch ( type ) {
			case Playing:
				updateEntities(dt);
				checkCollisions();
				checkPlayerAlive(dt);	
				destroyEntities();
			case _:
		}

	}

	@:extern inline function drawPolygon( context: RenderContext, vertices: Array<Float>, dx: Float, dy: Float ) {
		var x1 = vertices[0] + dx;
		var y1 = vertices[1] + dy;
		var j = 2;
		while ( j < vertices.length ) {
			var x2 = vertices[j] + dx;
			var y2 = vertices[j+1] + dy;
			j += 2;
			context.drawLine( x1, y1, x2, y2 );
			x1 = x2;
			y1 = y2;
		}
	}

	@:extern inline function drawRectangle( context: RenderContext, aabbLeft: Float, aabbTop: Float, aabbRight: Float, aabbBottom: Float ) {
		context.drawLine( aabbLeft, aabbTop, aabbRight, aabbTop );
		context.drawLine( aabbRight, aabbTop, aabbRight, aabbBottom );
		context.drawLine( aabbRight, aabbBottom, aabbLeft, aabbBottom );
		context.drawLine( aabbLeft, aabbBottom, aabbLeft, aabbTop );
	}

	public function render( context: RenderContext ) {
		var hw = Const.sceneHalfWidth;
	 	var hh = Const.sceneHalfHeight;	
		switch ( type ) {
			case Playing: 
				for ( e in entities ) {
					for ( v in e.transformedVertices ) {
						drawPolygon( context, v, hw, hh );
					}
				}
				if ( debug ) {
					context.color = 0xffff0000;
					for ( e in entities ) {
						drawRectangle( context, e.aabbLeft+hw, e.aabbTop+hh, e.aabbRight+hw, e.aabbBottom+hh );
					}
					context.color = 0xffffffff;
				}
			case _:
		}
	}

	public function updateBounds( hw: Float, hh: Float ) {
		top = -hh;
		bottom = hh;
		left = -hw;
		right = hw;
	}

	public function input( event: GameInput ) {
		switch ( type ) {
			case GameOver: switch ( event ) {
				case StartGame:
					lives = Const.playerStartLives;
					level = 0;
					score = 0;
					var e = create( PlayerShip, 0, 0, 0, Const.PI/2 ); 
					e.ghost = Const.playerInvunerabilityTime;
					initLevel( 0 );
					type = Playing;
				case _:
			}
	
			case Playing: if ( playerShip != null ) switch( event ) {
				case ToggleFire: playerShip.firing = true;
				case ToggleRotateCW: playerShip.rotatingCW = true;
				case ToggleRotateCCW: playerShip.rotatingCCW = true;
				case ToggleThrottle: playerShip.throttling = true;
				case StopFire: playerShip.firing = false;
				case StopRotateCW: playerShip.rotatingCW = false;
				case StopRotateCCW: playerShip.rotatingCCW = false;
				case StopThrottle: playerShip.throttling = false;
				case PauseGame:
					type = Paused;
				case StartGame:
			}

			case Paused: switch( event ) {
				case StartGame:
					type = Playing;
				case _:
			}
		}
	}
}
