package ;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.input.Keyboard;
import kha.Key;

class Khasteroids {
	public var state: GameState;

	public function new() {
		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);
		state = new GameState();
		Keyboard.get(0).notify( onDown, onUp );
	}

	function update(): Void {
		state.update( 1/60 );	
	}

	function render(framebuffer: Framebuffer): Void {		
		framebuffer.g2.begin();
		state.render( framebuffer.g2 );
		framebuffer.g2.end();
	}

	function onDown( k: Key, s: String ) {
		switch (k) {
			case Key.UP: state.input( ToggleThrottle );
			case Key.LEFT: state.input( ToggleRotateCCW );
			case Key.RIGHT: state.input( ToggleRotateCW );
			case Key.ESC: state.input( PauseGame );
			case _: if ( s == " " ) {
								state.input( ToggleFire );
								state.input( StartGame );
							}
		}
	}

	function onUp( k: Key, s: String ) {
		switch (k) {
			case Key.UP: state.input( StopThrottle );
			case Key.LEFT: state.input( StopRotateCCW );
			case Key.RIGHT: state.input( StopRotateCW );
			case _: if ( s == " " ) state.input( StopFire );
		}
	}
}
