// Based on
// https://github.com/underscorediscovery/differ/blob/master/differ
// http://stackoverflow.com/questions/471962/how-do-determine-if-a-polygon-is-complex-convex-nonconvex
// https://polygontriangulation.codeplex.com/releases/view/12676

package ;

class MinSat {
	public static var BAD_TRIANGULATION: Array<Array<Float>> = [];

	public static function triangulateInplace( vertices: Array<Float> ): Array<Array<Float>> {
		var triangles: Array<Array<Float>> = [];
		while ( vertices.length > 8 ) {
			var midvertex = findEar( vertices );
			if ( midvertex < 0 ) {
				return BAD_TRIANGULATION;
			}
			var triangle = vertices.slice( midvertex-2, midvertex+4 );
			triangle.push( triangle[0] );
			triangle.push( triangle[1] );
			vertices.splice( midvertex, 2 );

			triangles.push( triangle );
		}
		triangles.push( vertices );
		return triangles;
	}

	static function findEar( vertices: Array<Float> ): Int {
		var i = 0;
		while ( i < vertices.length - 4 ) {
			var ax = vertices[i];
			var ay = vertices[i+1];
			var bx = vertices[i+2];
			var by = vertices[i+3];
			var cx = vertices[i+4];
			var cy = vertices[i+5];
			var found = false;
			var j = 0;
			while ( j < vertices.length - 2 ) {
				var px = vertices[j];
				var py = vertices[j+1];
				if ( j != i && j != i+1 && pointInTriangle( px, py, ax, ay, bx, by, cx, cy )) {
					found = true;
					break;
				}
				j += 2;
			}
				
			if (!found) {
				return i + 2;
			}

			i += 2;
		}

		return -1;
	}	

	public static inline function triangulate( vertices: Array<Float> ): Array<Array<Float>> {
		return triangulateInplace( vertices.copy());
	}

	static inline function sign( x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float ) {
		return (x1 - x3) * (y2 - y3) - (x2 - x3) * (y1 - y3);
	}

	public static inline function pointInTriangle( px: Float, py: Float, x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float ) {
		var b1 = sign( px, py, x1, y1, x2, y2 ) < 0.0;
		var b2 = sign( px, py, x2, y2, x3, y3 ) < 0.0;
		var b3 = sign( px, py, x3, y3, x1, y1 ) < 0.0;

		return ((b1 == b2) && (b2 == b3));
	}


	public static function isConvex( vertices: Array<Float> ) {
		var n = vertices.length;
		var dx1 = vertices[0] - vertices[n-2];
		var dy1 = vertices[1] - vertices[n-3];
		var dx2 = vertices[2] - vertices[0];
		var dy2 = vertices[3] - vertices[1];
		var z = dx1*dy2 - dy2*dx2;
		var j = 0;
		while ( j < n-6 ) {
			dx1 = dx2;
			dy1 = dy2;
			dx2 = vertices[j+4] - vertices[j+2];
			dy2 = vertices[j+5] - vertices[j+3];
			var zz = dx1*dy2 - dy2*dx2;
			if (( z > 0 && zz < 0 )||( z < 0 && zz > 0 )) {
				return false;
			}
			j += 2;
		}
		return true;
	}

	public static function testComposites( polygon1: Array<Array<Float>>, polygon2: Array<Array<Float>>, ?result: Array<Int> ): Bool {
		for ( i in 0...polygon1.length ) { 
			var t1 = polygon1[i];
			for ( j in 0...polygon2.length ) {
				var t2 = polygon2[j];
				if ( testPolygons( t1, t2 )) {
					if ( result != null ) {
						result[0] = i;
						result[1] = j;
					}
					return true;
				}
			}
		}
		if ( result != null ) {
			result[0] = -1;
			result[1] = -1;
		}
		return false;
	}

	public static function testPolygons( vertices1: Array<Float>, vertices2: Array<Float> ): Bool {
		var intersect = true;

		// loop to begin projection
		var i = 0;
		while ( i < vertices1.length-2 && intersect ) {
			var axisX = findNormalAxisX( vertices1, i );
			var axisY = findNormalAxisY( vertices1, i );
			var aLen = vecLength( axisX, axisY );
			axisX = vecNormalize( aLen, axisX );
			axisY = vecNormalize( aLen, axisY );
			var testNum = 0.0;

			// project polygon1
			var min1 = vecDot( axisX, axisY, vertices1[0], vertices1[1] );
			var max1 = min1;

			var j = 2;
			while ( j < vertices1.length-2 ) {
				testNum = vecDot( axisX, axisY, vertices1[j], vertices1[j+1] );
				if (testNum < min1) min1 = testNum;
				if (testNum > max1) max1 = testNum;
				j += 2;
			}

			// project polygon2
			var min2 = vecDot( axisX, axisY, vertices2[0], vertices2[1] );
			var max2 = min2;

			var k = 2;
			while ( k < vertices2.length-2 ) {
				testNum = vecDot( axisX, axisY, vertices2[k], vertices2[k+1] );
				if( testNum < min2 ) min2 = testNum;
				if( testNum > max2 ) max2 = testNum;
				k += 2;
			}

			intersect = (min1 <= max2) && (min2 <= max1);
			i += 2;
		}

		return intersect;	
	} 
	
	static inline function findNormalAxisX( vertices: Array<Float>, index: Int ): Float {
		return -(vertices[index+3] - vertices[index+1]);
	}

	static inline function findNormalAxisY( vertices: Array<Float>, index: Int ): Float {
		return (vertices[index+2] - vertices[index]);
	}
	
	static inline function vecDot( x1: Float, y1: Float, x2: Float, y2: Float): Float {
		return x1 * x2 + y1 * y2;
	}	

	static inline function vecCross( x1: Float, y1: Float, x2: Float, y2: Float ): Float {
		return x1 * y2 - y1 * x2;
	}
	
	static inline function vecLength( x: Float, y: Float ): Float {
		return Math.sqrt(x * x + y * y);
	}

	static inline function vecNormalize( length: Float, component: Float ): Float {
		return length == 0.0 ? 0.0 : component / length;
	}
}

