﻿package {	import flash.display.MovieClip	import flash.events.Event	import flash.utils.setTimeout	import flash.text.TextField	import flash.events.KeyboardEvent;	import flash.events.MouseEvent	import flash.utils.setTimeout	import flash.events.MouseEvent	import flash.display.SimpleButton	import flash.display.StageScaleMode	import flash.display.StageAlign		import playerio.*	import sample.ui.Prompt	import sample.ui.Lobby	public class MultiplayerAsteroids extends MovieClip{		private var connection:Connection		private var deltas:Array = []		private var offset:Number = 0		private var ready:Boolean = false		private var me:Ship;				private var ships:Object = {}		private var shots:Object = {};		private var xspeed:Number = 0		private var yspeed:Number = 0;		private var xs:Number = 0		private var ys:Number = 0		private var scape:StarScape				private var hold:Number = 100;		private var shield:Number = 100;				private var base:World;		private var hud:Hud;		private var respawn:RespawnBox		private var join:MovieClip;				private var userlist:Userlist;				private var ktexts:Array = ["","",""];		private var kchat:Array = ["","","","","","","","","",""]			private var xpbar:XPBar				function MultiplayerAsteroids(){			stop();						new Prompt(stage, "What's your name?", "Guest-" + (Math.random()*9999<<0), function(name:String){				PlayerIO.connect(					stage,								//Referance to stage					"multiplayer-asteroids-xvg732dfm0stiyvfl4pcgw",			//Game id (Get your own at playerio.com. 1: Create user, 2:Goto admin pannel, 3:Create game, 4: Copy game id inside the "")					"public",							//Connection id, default is public					name,								//Username					"",									//User auth. Can be left blank if authentication is disabled on connection					handleConnect,						//Function executed on successful connect					handleError							//Function executed if we recive an error				);   			})			stage.scaleMode = StageScaleMode.NO_SCALE			stage.align = StageAlign.TOP_LEFT									var w:Number = 700			var h:Number = 500						base = new World(w,h);			addChild(base);			status.text = "loading"						scape = new StarScape(w,h,300);			base.AddChild(scape);						hud = new Hud();			hud.x = w/2			hud.y = h/2			base.AddChild(hud, false);						hud.visible = false						userlist = new Userlist();			userlist.y = 20			userlist.Refresh()			addChild(userlist);			chat.visible = false			join = new JoinBox()			addChild(join);			stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);			stage.addEventListener(Event.RESIZE, handleResize)			handleResize()												mute.useHandCursor = true;			mute.addEventListener(MouseEvent.MOUSE_DOWN, function(){				SoundManager.muted =! SoundManager.muted				mute.play();			})					}				private function handleConnect(client:Client):void{			trace("Sucessfully connected to player.io");						//Set developmentsever (Comment out to connect to your server online)			//My development server runs on n.c you likeley want to use localhost:8184			//client.multiplayer.developmentServer = "n.c:8184";						//var lobby:Lobby = new Lobby(client, "MultiplayerAsteroids", handleJoin, handleError)						//Show lobby (parsing true hides the cancel button)			//lobby.show(true);						//function writeError(error:String, details:String, stacktrace:String, extraData:Object, callback:Function=null, errorHandler:Function=null):void;						//Create pr join the room test			client.multiplayer.createJoinRoom(				"newmpa",							//Room id. If set to null a random roomid is used				"MultiplayerAsteroids",				//The game type started on the server				false,								//Should the room be hidden from the lobby?				{},									//Room data. This data is returned to lobby list. Variabels can be modifed on the server				{},									//User join data				handleJoin,							//Function executed on successful joining of the room				function(e:PlayerIOError){										//If the basic room is full show a lobby!					if(e.type == PlayerIOError.RoomIsFull){												var lobby:Lobby = new Lobby(client, "MultiplayerAsteroids", handleJoin, handleError);						lobby.show(true);											}else handleError(e); //Handle all other errors with the basic handler				}			);		}						private function handleResize(e:Event = null){			base.SetSize(stage.stageWidth,stage.stageHeight-20-19)						base.x = (stage.stageWidth - base.width)/2			base.y = (stage.stageHeight - base.height)/2+20-19						topbg.width = stage.stageWidth			playertitle.x = stage.stageWidth			mute.x = stage.stageWidth - 215						userlist.x = stage.stageWidth - userlist.width						chat.y = stage.stageHeight  - 19;			chatlog.y = stage.stageHeight-chatlog.textHeight-30  - 19						status.x = stage.stageWidth - 278			status.y = stage.stageHeight - 18  - 19 - 13						getgame.x = stage.stageWidth - 313			getgame.y = stage.stageHeight - 18  - 19						if(join != null){				join.x = stage.stageWidth/2;				join.y = stage.stageHeight/2;			}						if(xpbar != null){				xpbar.x = 5;				xpbar.width = stage.stageWidth - 10				xpbar.y = stage.stageHeight - 19;			}					}				private function spawn(){			if(respawn == null || me == null || !me.Dead || !ready)return						hold = 100;			shield = 100;						me.Teleport(Math.random()*1600,Math.random()*1600)			me.Spawn();						removeChild(respawn)			respawn = null						updateShipState(true);						connection.send("r");		};				private function doTimeSync(e:Object = null){//			writeDebug("Sending time!")			connection.send("time", new Date().getTime().toString());		}						private function get time():Number{			return ( new Date().getTime() + offset )		}				private var isFirst:Boolean = true				private function handleJoin(connection:Connection):void{			trace("Successfully connected the multiplayer server")			this.connection = connection;						//Moved the keylisteners here to prevent bug where connection where undefined on space			stage.addEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown)			stage.addEventListener(KeyboardEvent.KEY_UP,handleKeyUp)									connection.addMessageHandler("init", function(m:Message, id:String, name:String, xp:Number){				me = new Ship(id,name, 0 ,0, xp)				level.text.text = XPBar.GetLevel(xp);				userlist.AddUser(me);				base.addChild(me)				xpbar = new XPBar(me);				addChild(xpbar)				handleResize();															doTimeSync();			})									connection.addMessageHandler("time", function(m:Message, time:Number, sdelta:Number){//				writeDebug("Got time " + time +" "+ sdelta)																																																				var lag:Number = new Date().getTime() - time;				var latency:Number = Math.round( lag / 2 )				var delta:Number = sdelta-new Date().getTime() + latency;				deltas.push(delta);								if(deltas.length < 10){					setTimeout(doTimeSync, 100);					status.text = deltas.length.toString();										if(join != null){						join.t.text = "Building world... " + (10 - deltas.length)					}									}else{					if(join != null){						removeChild(join)						join = null;						hud.visible = true					}					if(deltas.length>100)deltas.shift()										var avg:Number = 0					for( var a:int=0;a<deltas.length;a++){						avg += deltas[a]					}										avg = (avg / deltas.length)										var dists:Array = [];					for( a=0;a<deltas.length;a++){						dists.push({offset:Math.abs(deltas[a]-avg), time:deltas[a], toString:function(){return "offset:" + this.offset + ", time: " + this.time }})					}										dists.sortOn("offset", Array.NUMERIC )					var serverOffset = 0					for( a=0;a<dists.length-3;a++){						serverOffset += dists[a].time					}										offset = Math.round( serverOffset / (dists.length-3) )															if(isFirst){						isFirst = false;						ready = true;						me.Teleport(Math.random()*1600,Math.random()*1600)						updateShipState(true);						connection.send("r");						me.Spawn()						status.text = "ready!"								}										status.text = "Version 0.5.1 : Server time offset: " + offset + " - Ping: " + lag;										setTimeout(doTimeSync, 1000);				}					   			})						connection.addMessageHandler("d", function(m:Message, id:String, target:String, count:Number, xp:Number){				var dt:Ship = ships[id] as Ship 				if(dt != null){					explode(dt.X, dt.Y);					dt.Die();				}												var actt:Ship = ships[target] as Ship 				if(id == me.Id) dt = me				if(target == me.Id) actt = me								var xpdiff:int = 0;				if(dt != null) dt.Deaths = count				if(actt != null){					actt.Kills = count					var oxp:Number = actt.XP					actt.XP = xp										if(target == me.Id){						xpbar.Refresh();												if(actt.XP != oxp) xpdiff = actt.XP-oxp												var nl:int = XPBar.GetLevel(me.XP) 						if(nl != XPBar.GetLevel(oxp)){							level.text.text = nl														var tmno:levelup = new levelup();							tmno.inner.level.text.text = nl							addChild(tmno)														tmno.x = stage.stageWidth							tmno.y = stage.stageHeight-35							}					}									}				userlist.Refresh();				insertKill(actt,dt,xpdiff)   			})									connection.addMessageHandler("r", function(m:Message, id:String){				var rt:Ship = ships[id] as Ship				if(rt != null){					rt.Spawn();				}																 				   			})			connection.addMessageHandler("h", function(m:Message, id:String, shotid:String){				var ht:Ship = ships[id] as Ship				if(ht != null){					ht.Blink();					var shot:Shot = shots[shotid] as Shot;					if(shot != null){						base.removeChild(shot);						delete shots[shotid]					}				}				   			})			connection.addMessageHandler("t", function(m:Message, id:String, text:String){				var tt:Ship = ships[id] as Ship				if(id == me.Id) tt = me								if(tt){					kchat.splice(0,1);					kchat.push(tt.Title + ": " +text)					chatlog.text = kchat.join("\n")					chatlog.y = stage.stageHeight-chatlog.textHeight-30  - 19				}			})			//t:Number, x:Number, y:Number, xSpeed:Number, ySpeed:Number, rotSpeed:Number, angle:Number, accMod:int, rotMod:int			connection.addMessageHandler("c", function(m:Message, id:String, time:Number, x:Number, y:Number, xSpeed:Number, ySpeed:Number, rotSpeed:Number, angle:Number, accMod:int, rotMod:int){			  	var target:Ship = ships[id] as Ship				if(target != null){					target.SetState(						time,						x,						y,						xSpeed, 						ySpeed, 						rotSpeed, 						angle, 						accMod,						rotMod 					)				} 			})						connection.addMessageHandler("s", function(m:Message, id:String, time:Number, x:Number, y:Number, xspeed:Number, yspeed:Number, angle:Number){			 	 if(me.Id != id){					spawnFire(						id,						time,						x,						y,						xspeed,						yspeed,						angle					)				}			})			connection.addMessageHandler("j", function(m:Message, id:String, title:String, isDead:Boolean,  kills:Number, deaths:Number, xp:int){//			 	trace(m);			 			 	if(me.Id != id){					var ship:Ship = new Ship(id,title,kills,deaths,xp);					base.addChild(ship)					ships[id] = ship					userlist.AddUser(ship);					if(!isDead) ship.Spawn();					hud.AddBlip(new blip(), ship);					}			})			connection.addMessageHandler("l", function(m:Message, id:String){			   	var target:Ship = ships[id] as Ship				if(target != null){					userlist.RemoveUser(target);					target.parent.removeChild(target);					delete ships[id]					hud.RemoveBlip(target);				}			})								}						private function writeDebug(text:String){			kchat.splice(0,1);			kchat.push("Debug" + ": " +text)			chatlog.text = kchat.join("\n")			chatlog.y = stage.stageHeight-chatlog.textHeight-30  - 19		}						private function spawnFire(id:String, time:Number, x:Number, y:Number, xspeed:Number, yspeed:Number, angle:Number){			if(shots[time] == null){				SoundManager.Play(new lasersound, x,y)								var shot = new Shot(id, time, x, y, xspeed, yspeed, angle)				base.addChild(shot)				shots[time] = shot;			}		}				private function fire(e:KeyboardEvent){			if(me.Dead) return;						var addX:Number = -Math.cos(me.Angle)*0.30			var addY:Number = -Math.sin(me.Angle)*0.30						var t:Number = time						selftick(t)						connection.send("s", 				t.toString(),				(me.X+addX*10).toString(),				(me.Y+addY*10).toString(),				(me.XSpeed+addX).toString(),				(me.YSpeed+addY).toString(),				(me.Angle).toString()			)						SoundManager.Move(me.X, me.Y)						spawnFire(me.Id, t, me.X+addX*10, me.Y+addY*10,me.XSpeed+addX, me.YSpeed+addY, me.Angle )			//spawnFire(me.Id, t, me.X-Math.cos(me.Angle)*4, me.Y-Math.sin(me.Angle)*4,me.XSpeed+addX, me.YSpeed+addY, me.Angle )//			e.updateAfterEvent();					}				private function selftick(t:Number):void{			if(me != null && !me.Dead){				var ox:Number = me.X				var oy:Number = me.Y				me.Tick(t)				scape.Move(ox-me.X, oy-me.Y)			}		}				var pt:Number = 0;		private function handleEnterFrame(e:Event){			//Execution order is, REALLY REALLY imoportant here, do not fuck it up			var t:Number = time						if(ready){				selftick(t);				for(var id:String in ships){					var ship:Ship = ships[id] as Ship					ship.Tick(t)										var ox:Number = ship.X - me.X					var oy:Number = ship.Y - me.Y					var dist:Number = Math.sqrt(ox*ox+oy*oy)					var a:Number = Math.atan2(oy,ox)				}				for( var s:String in shots){					var sh:Shot = shots[s] as Shot;					if( sh.Tick(t) ){						base.removeChild(sh)						delete shots[s]					}else if(me.Id != sh.Id && !me.Dead){						var oxd:Number = sh.X - me.X						var oyd:Number = sh.Y - me.Y						var hdist:Number = Math.sqrt(oxd*oxd+oyd*oyd)						if(hdist<10){							connection.send("h", sh.Spawn.toString());														shield -= 75							if(shield<0){								hold+=shield;								shield=0;																if(hold <= 0){									connection.send("d", sh.Id)									explode(me.x,me.y);									me.Die();																		setTimeout(function(){										respawn = new RespawnBox(spawn);										addChild(respawn)										respawn.x = stage.stageWidth/2										respawn.y = stage.stageHeight/2									},1000)																											hold = 0;								}							}														me.Blink();							base.removeChild(sh)							delete shots[s]																				}					};				}				hud.Refresh(me.X, me.Y)			}						hud.SetShield(shield/100)			hud.SetHold(hold/100)						if(pt && ready){				var off:Number = t - pt;				shield = Math.min(100, shield+off/200)			}			pt = t						if(me!=null){				base.Center(me.x, me.y)			}		}				private var rDown:int = 0		private var lDown:int = 0		private var uDown:int = 0		private var dDown:int = 0				private var rl:int = 0;		private var ud:int = 0;				private function explode(x:Number, y:Number){						SoundManager.Play(new diesound, x, y)						for( var a:int=0;a<100;a++){				var p:Particle = new Particle(x,y,Math.random()*2,Math.random(),Math.random()*Math.PI*2,1000)				base.addChild(p)			}		}				private function updateShipState(force:Boolean = false):void{			if(ready){				var nrl:int = lDown + rDown;				var nud:int = uDown + dDown;								if(nrl != rl || ud != nud  || force){					var t:Number = time										me.Rotate( nrl )					me.Accelerate( nud )					selftick(t)										connection.send("c", 						t.toString(),						me.X.toString(),						me.Y.toString(),						me.XSpeed.toString(),						me.YSpeed.toString(),						me.RotSpeed.toString(),						me.Angle.toString(),						me.AccMod,						me.RotMod					)										rl = nrl					ud = nud				}			}		}				//Rather boring key event handling;		var firedown:Boolean = false		var lastfire:Number = new Date().getTime();		private function handleKeyDown(e:KeyboardEvent){			switch(e.keyCode){								case 17:{					spawn();					break;				}				case 27:{					chat.visible = false					chat.inp.text = "";					break;				}								case 222:{				}				case 13:{					if(!chat.visible){						chat.visible = true						stage.focus = chat.inp;					}else{						if(chat.inp.text != ""){							connection.send("t", chat.inp.text)						}						chat.inp.text = "";						chat.visible = false					}					break;				}								case 65:{}				case 37:{					lDown = -1					break;				}				case 68:{}				case 39:{					rDown = 1					break;				}								case 87:{}				case 38:{					uDown = -1					break;				}								case 83:{}				case 40:{					dDown = 1					break;				}								case 32:{					if( 					   !firedown &&					   new Date().getTime()-lastfire > 100 // Put a limit on how fast we are able to fire (This code should be replicated on the server for security)					 ){						fire(e);						firedown = true;						lastfire = new Date().getTime();					}					break;				}			}			updateShipState();		}		private function handleKeyUp(e:KeyboardEvent){			switch(e.keyCode){				case 65:{}				case 37:{					lDown = 0					break;				}				case 68:{}				case 39:{					rDown = 0					break;				}								case 87:{}				case 38:{					uDown = 0					break;				}								case 83:{}				case 40:{					dDown = 0					break;				}								case 32:{					firedown = false					break;				}			}			updateShipState();		}						/* Tempoary Functions */		private function insertKill(actor:Ship, target:Ship, xp:int){			if(actor && target){								var act:String = actor == me ? "You" : actor.Title				var tat:String = target == me ? "you" : target.Title								ktexts.pop();								if(actor == me){					if(xp != 0){						ktexts.unshift('<font color="#FFFFFF">' + act + '</font> won <font color="#00FF00">' + xp + 'xp </font>for' + [" owning ", " killing ", " neutralizing "][Math.random()*3>>0] + '<font color="#FFFFFF">' + tat + '</font>!')					}else if((actor == me || target == me ) && actor.Title == target.Title){						ktexts.unshift('Nope you don\'t get <font color="#ff0000">xp</font> for' + [" owning ", " killing ", " neutralizing "][Math.random()*3>>0] + 'yourself.')					}else{						ktexts.unshift('<font color="#FFFFFF">' + act + '</font> don\'t get <font color="#ff0000">xp</font> for' + [" owning ", " killing ", " neutralizing "][Math.random()*3>>0] + '<font color="#FFFFFF">' + tat + '</font> repeatedly.')					}				}else{					ktexts.unshift('<font color="#FFFFFF">' + act + '</font>' + [" owned ", " killed ", " neutralized "][Math.random()*3>>0] + '<font color="#FFFFFF">' + tat + '</font>')				}												killlog.htmlText = ktexts.join("\n")							}		}				public function ToggleUserList(show:Boolean){			userlist.visible = show;		}				private function handleDisconnect():void{			trace("Disconnected from server")		}				private function handleError(e:PlayerIOError):void{			trace("Got", e)			gotoAndStop(3);		}					}	}