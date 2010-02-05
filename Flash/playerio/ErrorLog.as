﻿package playerio{	/**	 * Allows developers to insert entries into the Player.IO error log from ActionScript  	 * 	 */		public interface ErrorLog{		/**		 * Insert error into Player.IO error log 		 * @param error error name		 * @param details error details		 * @param stacktrace possible stacktrace		 * @param extraData additional debug data		 * @param callback optional callback executed when error was submitted to the server		 * @param errorHandler optional callback executed if the error request failed		 * 		 */		function writeError(error:String, details:String, stacktrace:String, extraData:Object, callback:Function=null, errorHandler:Function=null):void;	}}