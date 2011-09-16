/**
 * Copyright (c) 2011 Tuomas Artman, http://artman.fi
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.flow.effects {
	
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	
	public class Transform3DEffect extends Effect {
		
		private var _rotationX:Number;
		private var _rotationY:Number;
		private var _rotationZ:Number;
		
		
		public function Transform3DEffect(target:DisplayObject = null, rotationX:Number = 90, rotationY:Number = 0, rotationZ:Number = 0) {
			super(target);
			_rotationX = rotationX;
			_rotationY = rotationY;
			_rotationZ = rotationZ;
		}	
		
		public function get rotationX():Number {
			return _rotationX;
		}
		public function set rotationX(value:Number):void {
			if(value != _rotationX) {
				_rotationX = value;
				invalidate();
			}
		}

		public function get rotationY():Number {
			return _rotationY;
		}
		public function set rotationY(value:Number):void {
			if(value != _rotationY) {
				_rotationY = value;
				invalidate();
			}
		}

		public function get rotationZ():Number {
			return _rotationZ;
		}
		public function set rotationZ(value:Number):void {
			if(value != _rotationZ) {
				_rotationZ = value;
				invalidate();
			}
		}

		override protected function render(val:Number):Array{
			if(val) {
				_target.rotationX = _rotationX * val;
				_target.rotationY = _rotationY * val;
				_target.rotationY = _rotationZ * val;
			} else {
				var x:Number = _target.x;
				var y:Number = _target.y;
				var trans:Matrix = _target.transform.matrix;
				_target.transform.matrix3D = null;
				_target.x = x;
				_target.y = y;
			}
			return [];
		}
	}
}