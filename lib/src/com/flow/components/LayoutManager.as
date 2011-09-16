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

package com.flow.components {
	
	import com.flow.collections.DisplayObjectCollection;
	import com.flow.effects.AnimationProps;
	import com.flow.effects.Effect;
	import com.flow.motion.Tween;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import com.flow.containers.Application;
	import com.flow.containers.Container;

	public class LayoutManager {
		
		public static const LAYOUT_PHASE_NONE:int = 0;
		public static const LAYOUT_PHASE_VALIDATING:int = 1;
		
		public static var instance:LayoutManager = new LayoutManager();
		
		public var layoutPhase:int = 0;
		private var invalidInitList:Vector.<Component>;
		private var invalidList:Vector.<Component>;
		private var invalidLayoutList:Vector.<Container>;
		private var invalidChildrenList:Vector.<Container>;
		private var invalidEffectList:Vector.<Effect>;
		private var root:Stage;
		private var lastUpdate:Number;
		public var deltaTime:Number;
		private var invalidated:Boolean = false;
		private var animationRoot:Component;
		private var animationProperties:Dictionary;
		
		public function LayoutManager() {
			invalidInitList = new Vector.<Component>();
			invalidList = new Vector.<Component>();
			invalidLayoutList = new Vector.<Container>();
			invalidEffectList = new Vector.<Effect>();
			invalidChildrenList = new Vector.<Container>();
		}
		
		public function initialize(root:Stage):void {
			this.root = root;
			root.addEventListener(Event.RENDER, validate);
			root.addEventListener(Event.RESIZE, resize);
			root.addEventListener(Event.FULLSCREEN, resize);
			root.addEventListener(Event.ENTER_FRAME, enterFrame, false, 1000);
			resize();
		}
		
		private function resize(e:Event = null):void {
			Application.application.width = root.stageWidth;
			Application.application.height = root.stageHeight;
			validate();
		}
		
		public function invalidateInit(component:Component):void {
			if(invalidInitList.indexOf(component) == -1) {
				invalidInitList.push(component);
			}
			if(!invalidated) {
				invalidate();
			}
		}
		
		
		public function invalidateComponent(component:Component):void {
			if(invalidList.indexOf(component) == -1) {
				invalidList.push(component);
			}
			if(!invalidated) {
				invalidate();
			}
		}
		
		public function invalidateEffect(effect:Effect):void {
			if(invalidEffectList.indexOf(effect) == -1) {
				invalidEffectList.push(effect);
			}
			if(!invalidated) {
				invalidate();
			}
		}
		
		public function invalidateLayout(container:Container):void {
			if(invalidLayoutList.indexOf(container) == -1) {
				invalidLayoutList.push(container);
			}
			if(!invalidated) {
				invalidate();
			}
		}
		
		public function invalidateChildren(container:Container):void {
			if(invalidChildrenList.indexOf(container) == -1) {
				invalidChildrenList.push(container);
			}
			if(!invalidated) {
				invalidate();
			}
		}
		
		private function invalidate():void {
			if(root) {
				root.stage.invalidate();
			}
			invalidated = true;
		}
		
		public function validate(e:Event = null):void {
			while(invalidChildrenList.length) {
				invalidChildrenList.shift().validateChildren();
			}
			while(invalidInitList.length) {
				invalidInitList.shift().init();
			}
			
			layoutPhase = LAYOUT_PHASE_VALIDATING;
			invalidLayoutList.sort(depthSort);
			while(invalidLayoutList.length) {
				var container:Container = invalidLayoutList.shift();
				if(container.layoutInvalidated) {
					container.validateLayoutOnRoot();
				}
			}
			while(invalidList.length) {
				var component:Component = invalidList.shift();
				if(component.invalidated) {
					component.validate();
				}
			}
			
			while(invalidEffectList.length) {
				var effect:Effect = invalidEffectList.shift();
				if(effect.invalidated) {
					effect.validate();
				}
			}
			invalidated = false;
			layoutPhase = LAYOUT_PHASE_NONE;
			
			if(invalidChildrenList.length || invalidLayoutList.length) {
				validate();
			}
		}
		
		private function depthSort(a:Component, b:Component):int {
			if(a.depth == b.depth) {
				return 0
			} else if(a.depth < b.depth) {
				return -1;
			}
			return 0;
		}
		
		private function enterFrame(e:Event):void {
			if(!lastUpdate) {
				lastUpdate = getTimer();
			}
			var time:Number = getTimer();
			deltaTime = time - lastUpdate;
			lastUpdate = time;	
		}
		
		public function beginAnimation(target:Component):void {
			var t:Number = getTimer();
			if(animationRoot) {
				commitAnimation()
			}
			animationRoot = target;
			animationProperties = new Dictionary();
			collectProps(animationRoot, animationProperties);
		}
		
		private function collectProps(target:DisplayObject, dictionary:Dictionary):void {
			var props:AnimationProps = new AnimationProps();
			props.gatherProps(target);
			dictionary[target] = props;
			if(target is Container) {
				var list:DisplayObjectCollection = (target as Container).children as DisplayObjectCollection;
				for(var i:int = 0; i<list.length; i++) {
					collectProps(list.getItemAt(i) as DisplayObject, dictionary)
				}
			} else if(target is DisplayObjectContainer) {
				var cnt:int = (target as DisplayObjectContainer).numChildren;
				for(i = 0; i<cnt; i++) {
					collectProps((target as DisplayObjectContainer).getChildAt(i), dictionary)
				}
			}
		}
		
		public function commitAnimation(speed:Number = 0.5, tweenProps:Object = null):void {
			if(!tweenProps) {
				tweenProps = {};
			}
			var newAnimationProperties:Dictionary = new Dictionary();
			collectProps(animationRoot, newAnimationProperties);
	
			for (var o:Object in animationProperties) {
				var component:DisplayObject = o as DisplayObject;
				var changedProps:Object = (animationProperties[component] as AnimationProps).parseChanges(newAnimationProperties[component]);
				if(changedProps) {
					(animationProperties[component] as AnimationProps).applyToDisplayObject(component);
					new Tween(component, speed, changedProps, tweenProps);
				}
			}
			animationRoot = null;
			animationProperties = null;
		}
	}
}