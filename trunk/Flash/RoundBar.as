﻿package {	import flash.display.MovieClip	public class RoundBar extends MovieClip{		function RoundBar(){			stop();		}		public function SetValue(v:Number):void{			this.gotoAndStop(this.totalFrames-(this.totalFrames*v>>0));								}	}}