using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using PlayerIO.GameLibrary;
using System.Drawing;

namespace MyGame {
	public class Player : BasePlayer {
		public string Timestamp = "0";
		public string X = "0";
		public string Y = "0";
		public string XSpeed = "0";
		public string YSpeed = "0";
		public string RotSpeed = "0";
		public string Angle = "0";
		public int AccMod = 0;
		public int RotMod = 0;
		public bool Dead = true;
		public int Kills = 0;
		public int Deaths = 0;
		public int XP = 0;

		private string[] killers = new string[5] { "", "", "", "", "" };

		public int GetXP(Player player) {
			string name = player.ConnectUserId;
			int seen = 1;
			for(int a = 0; a < 4; a++) {
				killers[a] = killers[a + 1];
				if(name == killers[a] || name == this.ConnectUserId)
					seen++;
			}

			killers[4] = name;

			return seen <= 3 ? 1 : 0;
		}

	}

	public class GameCode : Game<Player> {
		// This method is called when an instance of your the game is created
		public override void GameStarted() {
			// anything you write to the Console will show up in the 
			// output window of the development server
			Console.WriteLine("Game is started: " + RoomId);
		
		}

		// This method is called when the last player leaves the room, and it's closed down.
		public override void GameClosed() {
			Console.WriteLine("RoomId: " + RoomId);
		}

		// This method is called whenever a player joins the game
		public override void UserJoined(Player player) {
			player.XP = 0;
			player.Send("init", player.Id, player.ConnectUserId, player.XP);

			foreach(Player tplayer in this.Players) {
				if(tplayer.Id != player.Id) {
					Player tUser = tplayer;
					player.Send("j", tUser.Id, tUser.ConnectUserId, tUser.Dead, tUser.Kills, tUser.Deaths, tUser.XP);
					player.Send("c", tUser.Id,
						tUser.Timestamp,
						tUser.X,
						tUser.Y,
						tUser.XSpeed,
						tUser.YSpeed,
						tUser.RotSpeed,
						tUser.Angle,
						tUser.AccMod,
						tUser.RotMod
					);
				}
			}

			Broadcast("j", player.Id, player.ConnectUserId, player.Dead, 0, 0, player.XP);
		}

		// This method is called when a player leaves the game
		public override void UserLeft(Player player) {
			Broadcast("l", player.Id);
		}

		// This method is called when a player sends a message into the server code
		public override void GotMessage(Player player, Message m) {

			Console.WriteLine(m.Type);
			player.Send("Is FAT!");

			return;


			switch(m.Type) {
				case "time": {
						player.Send("time", m.GetString(0), getTime());
						break;
					}
				case "c": {
					//Magic function for change direction

					player.Timestamp = m.GetString(0);
					player.X = m.GetString(1);
					player.Y = m.GetString(2);
					player.XSpeed = m.GetString(3);
					player.YSpeed = m.GetString(4);
					player.RotSpeed = m.GetString(5);
					player.Angle = m.GetString(6);
					player.AccMod = m.GetInt(7);
					player.RotMod = m.GetInt(8);

					Broadcast("c", player.Id,
						player.Timestamp,
						player.X,
						player.Y,
						player.XSpeed,
						player.YSpeed,
						player.RotSpeed,
						player.Angle,
						player.AccMod,
						player.RotMod
					);
					break;
				}
			case "s": {
					foreach(Player tplayer in this.Players) {
						if(tplayer.Id != player.Id) {
							tplayer.Send("s", player.Id,
							  m.GetString(0),
							  m.GetString(1),
							  m.GetString(2),
							  m.GetString(3),
							  m.GetString(4),
							  m.GetString(5)
							);
						}
					}
					break;
				}

			case "t": {
					Broadcast("t", player.Id, m.GetString(0));
					break;
				}
			case "d": {
					player.Dead = true;
					player.Deaths++;

					int kills = 0;
					int xp = 0;
					foreach(Player tplayer in this.Players) {
						if(tplayer.Id.ToString() == m.GetString(0)) {
							tplayer.Kills++;

							tplayer.XP += player.GetXP(tplayer);
							xp = tplayer.XP;
							kills = tplayer.Kills;
						}
					}
					Broadcast("d", player.Id, m.GetString(0), player.Deaths, kills, xp);
					break;
				}

			case "r": {
					player.Dead = false;
					Broadcast("r", player.Id);
					break;
				}
			case "h": {
					Broadcast("h", player.Id, m.GetString(0));
					break;
				}
			}
		}

		private string getTime() {
			return Math.Round((DateTime.Now - new DateTime(1970, 1, 1)).TotalMilliseconds).ToString();
		}
	}
}