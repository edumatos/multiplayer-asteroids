﻿package sample.ui.components{	import flash.text.TextField	import flash.text.TextFormat	import flash.text.TextFormatAlign	import flash.text.TextFieldType	public class Input extends Label{		function Input(text:String,  size:Number = 12, align:String = "left", isPassword:Boolean = false){			super(text, size, align)			this.type = TextFieldType.INPUT;			this.mouseEnabled = true;			this.border = true			this.background = true												this.borderColor = 0x558888						if(isPassword)				this.displayAsPassword = true;		}								public function setStyle(border:Boolean = true, background:Boolean = true, backgroundColor:Number = 0xffffff, borderColor:Number = 0x558888):Input{			this.border = border			this.borderColor = borderColor						this.background = background			this.borderColor = borderColor			return this		}						public override function Clone():Label{			return new Input(this.text, this.defaultTextFormat.size as Number, this.defaultTextFormat.align);		}	}	}