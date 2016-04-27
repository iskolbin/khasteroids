package ;

class Const {
	public static inline var PI = 3.1415926535898;
	public static var sceneWidth = 800;
	public static var sceneHeight = 600;
	public static var sceneHalfWidth(get,null): Int;
	public static var sceneHalfHeight(get,null): Int;
	public static function get_sceneHalfWidth() return sceneWidth >> 1;
	public static function get_sceneHalfHeight() return sceneHeight >> 1;
	public static var playerAngularVelocity = PI;
	public static var playerLinearAcceleration = 1.0;
	public static var playerStartLives = 3;
	public static var playerBulletVelocity = 150.0;
	public static var playerBulletLifeSpan = 5.0;
	public static var playerCooldown = 0.2;
	public static var playerRespawnTime = 2.0;
	public static var playerInvunerabilityTime = 2.0;
	public static var bigAsteroidVelocity = 10.0;
	public static var bigAsteroidPieces = 2;
	public static var mediumAsteroidVelocity = 20.0;
	public static var mediumAsteroidPieces = 2;
	public static var smallAsteroidVelocity = 40.0;
	public static var alienBulletVelocity = 80.0;
	public static var alienBulletLifeSpan = 3.0;
	public static var alienCooldown = 1.0;
}
