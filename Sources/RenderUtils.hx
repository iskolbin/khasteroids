package ;

class RenderUtils {
	public static var VERTICES = [
		'0' => [0.0,0.0, 1.0,0.0, 1.0,1.0, 0.0,1.0, 0.0,0.0, 1.0,1.0],
		'1' => [0.5,0.0, 0.5,1.0],
		'2' => [0.0,0.0, 1.0,0.0, 1.0,0.5, 0.0,0.5, 0.0,1.0, 1.0,1.0],
		'3' => [0.0,0.0, 1.0,0.0, 1.0,0.5, 0.0,0.5, 1.0,0.5, 1.0,1.0, 0.0,1.0],
		'4' => [0.0,0.0, 0.0,0.5, 1.0,0.5, 1.0,0.0, 1.0,1.0],
		'5' => [1.0,0.0, 0.0,0.0, 0.0,0.5, 1.0,0.5, 1.0,1.0, 0.0,1.0],
		'6' => [1.0,0.0, 0.0,0.0, 0.0,1.0, 1.0,1.0, 1.0,0.5, 0.0,0.5],
		'7' => [0.0,0.0, 1.0,0.0, 1.0,1.0],
		'8' => [0.0,0.0, 1.0,0.0, 1.0,0.5, 0.0,0.5, 0.0,0.0, 0.0,1.0, 1.0,1.0, 1.0,0.0],
		'9' => [1.0,0.5, 0.0,0.5, 0.0,0.0, 1.0,0.0, 1.0,1.0, 0.0,1.0],
		
		'A' => [0.0,1.0, 0.0,0.0, 1.0,0.0, 1.0,1.0, 1.0,0.5, 0.0,0.5],
		'B' => [0.0,0.0, 0.5,0.0, 0.5,0.5, 1.0,0.5, 0.0,0.5, 0.0,0.0, 0.0,1.0, 1.0,1.0, 1.0,0.5],
		'C' => [1.0,0.0, 0.0,0.0, 0.0,1.0, 1.0,1.0],
		'D' => [0.0,0.0, 1.0,0.5, 1.0,1.0, 0.0,1.0, 0.0,0.0],
		'E' => [1.0,0.0, 0.0,0.0, 0.0,0.5, 1.0,0.5, 0.0,0.5, 0.0,1.0, 1.0,1.0],
		'F' => [1.0,0.0, 0.0,0.0, 0.0,0.5, 1.0,0.5, 0.0,0.5, 0.0,1.0],
		'G' => [1.0,0.0, 0.0,0.0, 0.0,1.0, 1.0,1.0, 1.0,0.5, 0.5,0.5],
		'H' => [0.0,0.0, 0.0,1.0, 0.0,0.5, 1.0,0.5, 1.0,0.0, 1.0,1.0],
		'I' => [0.5,0.0, 0.5,1.0],
		'J' => [0.0,1.0, 1.0,0.5, 1.0,0.0, 0.0,0.0],
		'K' => [0.0,0.0, 0.0,1.0, 0.0,0.5, 1.0,1.0, 0.0,0.5, 1.0,0.0],
		'L' => [0.0,0.0, 0.0,1.0, 1.0,1.0],
		'M' => [0.0,1.0, 0.0,0.0, 0.5,0.5, 1.0,0.0, 1.0,1.0],
		'N' => [0.0,1.0, 0.0,0.0, 1.0,1.0, 1.0,0.0],
		'O' => [0.0,0.0, 1.0,0.0, 1.0,1.0, 0.0,1.0, 0.0,0.0],
		'P' => [0.0,1.0, 0.0,0.0, 1.0,0.0, 1.0,0.5, 0.0,0.5],
		'Q' => [1.0,1.0, 0.0,1.0, 0.0,0.0, 1.0,0.0, 1.0,1.0, 0.5,0.5],
		'R' => [0.0,1.0, 0.0,0.0, 1.0,0.0, 1.0,0.5, 0.0,0.5, 1.0,1.0],
		'S' => [1.0,0.0, 0.0,0.0, 0.0,0.5, 1.0,0.5, 1.0,1.0, 0.0,1.0],
		'T' => [0.0,0.0, 1.0,0.0, 0.5,0.0, 0.5,1.0],
		'U' => [0.0,0.0, 0.0,1.0, 1.0,1.0, 1.0,0.0],
		'V' => [0.0,0.0, 0.5,1.0, 1.0,0.0],
		'W' => [0.0,0.0, 0.25,1.0, 0.5,0.5, 0.75,1.0, 1.0,0.0],
		'X' => [0.0,0.0, 1.0,1.0, 0.5,0.5, 0.0,1.0, 1.0,0.0],
		'Y' => [0.0,0.0, 0.5,0.5, 1.0,0.0, 0.5,0.5, 0.5,1.0],
		'Z' => [0.0,0.0, 1.0,0.0, 0.0,1.0, 1.0,1.0],
		];

	public static inline var CENTER = 0;
	public static inline var LEFT = 1;
	public static inline var RIGHT = 2;

	public static inline function textLength( str: String, width: Float, height: Float, ?dx_: Float ) {
		var dx = (dx_ == null) ? Math.fceil( width/3 ) : dx_; 
		return str.length * (width+dx) - dx;
	}

	public static inline function drawText( context: RenderContext, str: String, x: Float, y: Float, width: Float, height: Float, align: Int = CENTER, ?dx_: Float ) {
		var dx = (dx_ == null) ? Math.fceil( width/3 ) : dx_; 
		var len = textLength( str, width, height, dx );
		var offset = switch ( align ) {
			case CENTER: x - 0.5 * len; 
			case LEFT: x;
			case RIGHT: x - len;
			case _: 0;
		}
		
		for ( i in 0...str.length ) {
			var vertices = VERTICES.get(str.charAt(i));
			if ( vertices != null ) {
				var x0 = offset + width*vertices[0];
				var y0 = y + height*vertices[1];
				var j = 2;
				while ( j < vertices.length ) {
					var x1 = offset + width*vertices[j];
					var y1 = y + height*vertices[j+1];
					context.drawLine( x0, y0, x1, y1, 2 );
					x0 = x1;
					y0 = y1;
					j += 2;
				}
			}
			offset += width + dx;
		}
	}
	
	public static inline function drawRectangle( context: RenderContext, aabbLeft: Float, aabbTop: Float, aabbRight: Float, aabbBottom: Float ) {
		context.drawLine( aabbLeft, aabbTop, aabbRight, aabbTop );
		context.drawLine( aabbRight, aabbTop, aabbRight, aabbBottom );
		context.drawLine( aabbRight, aabbBottom, aabbLeft, aabbBottom );
		context.drawLine( aabbLeft, aabbBottom, aabbLeft, aabbTop );
	}
	
	public static inline function drawPolygon( context: RenderContext, vertices: Array<Float>, dx: Float, dy: Float ) {
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
}
