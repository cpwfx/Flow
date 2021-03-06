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

package com.flow.net.loaders {
	
	import flash.events.Event;
	
	/**
	 * Loads XML data from a remote location.
	 */
	public class XMLLoader extends TextLoader {
		
		private var xml:XML;
		
		/**
		 * Constructor. Starts loading the XML resource.
		 * @param The URL from which to load the XML resource. This can be of type String or URLRequest. If String, a URLRequest is automatically
		 * created using GET.
		 */
		public function XMLLoader(url:*) {
			super(url);
		}
		
		/** @private */
		override protected function complete(e:Event):void {
			xml = new XML(e.target.data);
			super.complete(e);
		}
		
		/** The resulting XML instance. */
		override public function get result():* {
			return xml;
		}
	}
}