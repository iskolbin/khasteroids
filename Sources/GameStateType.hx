package ;

@:enum abstract GameStateType(Int) {
	var GameOver = 0;
	var NewLevel = 1;
	var Playing = 2;
	var Paused = 3;
}
