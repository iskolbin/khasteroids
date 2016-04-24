package ;

class GameState {
	public var type: GameStateType;
	public var entities: Array<GameEntity>;
	public var playerShip: GameEntity;

	public var level: Int;
	public var lives: Int;
	public var score: Int;
	public var goalEnemiesCount: Int;

	public var left: Float;
	public var right: Float;
	public var top: Float;
	public var bottom: Float;

	public function new() {
		this.type = GameOver;
		this.entities = [];
		updateBounds( Const.sceneHalfWidth, Const.sceneHalfHeight );
	}

	public function create( etype: GameEntityType, x: Float, y: Float, velocity: Float, angle: Float ) {
		var e = new GameEntity( this, etype, x, y, velocity*Math.cos(angle), velocity*Math.sin(angle), angle );
		if ( etype == PlayerShip ) {
			playerShip = e;
		}
		entities.push( e );
	}

	public function destroy( e: GameEntity ) {
		var index = entities.indexOf( e );
		if ( index >= 0 ) {
			entities.splice( index, 1 );
			
			switch ( e.type ) {
				case PlayerShip: 
					lives--; 
					checkLives();
					playerShip = null;
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
		}
	}

	public function update( dt: Float ) {
		switch ( type ) {
			case Playing: for ( e in entities ) e.update( dt ); 
			case _:
		}
	}

	inline function drawPolygon( context: RenderContext, vertices: Array<Float>, dx: Float, dy: Float ) {
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

	public function render( context: RenderContext ) {
		var hw = Const.sceneHalfWidth;
	 	var hh = Const.sceneHalfHeight;	
		switch ( type ) {
			case Playing: 
				for ( e in entities ) {
					drawPolygon( context, e.rotatedVertices, e.x + hw, e.y + hh );
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
					create( PlayerShip, 0, 0, 0, Const.PI/2 ); 
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
