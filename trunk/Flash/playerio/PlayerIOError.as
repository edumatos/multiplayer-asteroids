package playerio{
	/**
	* Error object for all PlayerIO related errors
	* This class is auto generated
	*/
	public class PlayerIOError extends Error{
		/**
		* PlayerIOError type if the method requested is not supported
		*/
		public static const UnsupportedMethod:PlayerIOError = new PlayerIOError("The method requested is not supported",0);
		/**
		* PlayerIOError type if a general error occured
		*/
		public static const GeneralError:PlayerIOError = new PlayerIOError("A general error occured",1);
		/**
		* PlayerIOError type if an internal error occured
		*/
		public static const InternalError:PlayerIOError = new PlayerIOError("An internal error occured",2);
		/**
		* PlayerIOError type if access is denied
		*/
		public static const AccessDenied:PlayerIOError = new PlayerIOError("Access is denied",3);
		/**
		* PlayerIOError type if the message is malformatted
		*/
		public static const InvalidMessageFormat:PlayerIOError = new PlayerIOError("The message is malformatted",4);
		/**
		* PlayerIOError type if a value is missing
		*/
		public static const MissingValue:PlayerIOError = new PlayerIOError("A value is missing",5);
		/**
		* PlayerIOError type if a game is required to do this action
		*/
		public static const GameRequired:PlayerIOError = new PlayerIOError("A game is required to do this action",6);
		/**
		* PlayerIOError type if the game requested is not known by the server
		*/
		public static const UnknownGame:PlayerIOError = new PlayerIOError("The game requested is not known by the server",10);
		/**
		* PlayerIOError type if the connection requested is not known by the server
		*/
		public static const UnknownConnection:PlayerIOError = new PlayerIOError("The connection requested is not known by the server",11);
		/**
		* PlayerIOError type if the auth given is invalid or malformatted
		*/
		public static const InvalidAuth:PlayerIOError = new PlayerIOError("The auth given is invalid or malformatted",12);
		/**
		* PlayerIOError type if there are no servers available in the cluster, please try again later (never occurs)
		*/
		public static const NoAvailableServers:PlayerIOError = new PlayerIOError("There are no servers available in the cluster, please try again later (never occurs)",13);
		/**
		* PlayerIOError type if the initdata for the room was too large
		*/
		public static const TooMuchInitData:PlayerIOError = new PlayerIOError("The initdata for the room was too large",14);
		/**
		* PlayerIOError type if you are unable to create room because there is already a room with the specified id
		*/
		public static const RoomAlreadyExists:PlayerIOError = new PlayerIOError("You are unable to create room because there is already a room with the specified id",15);
		/**
		* PlayerIOError type if the game you're connected to does not have a server type with the specified name
		*/
		public static const UnknownServerType:PlayerIOError = new PlayerIOError("The game you're connected to does not have a server type with the specified name",16);
		/**
		* PlayerIOError type if there is no room running with that id
		*/
		public static const UnknownRoom:PlayerIOError = new PlayerIOError("There is no room running with that id",17);
		/**
		* PlayerIOError type if you can't join the room when the RoomID is null or the empty string
		*/
		public static const MissingRoomId:PlayerIOError = new PlayerIOError("You can't join the room when the RoomID is null or the empty string",18);
		/**
		* PlayerIOError type if the room already has the maxmium amount of users in it.
		*/
		public static const RoomIsFull:PlayerIOError = new PlayerIOError("The room already has the maxmium amount of users in it.",19);
		/**
		* PlayerIOError type if the key you specified is not set as searchable. You can change the searchable keys in the admin panel for the server type
		*/
		public static const NotASearchColumn:PlayerIOError = new PlayerIOError("The key you specified is not set as searchable. You can change the searchable keys in the admin panel for the server type",20);
		/**
		* @private
		*/
		protected var _type:PlayerIOError = GeneralError;
		/**
		* Create a new PlayerIOError object. 
		* Errors initialized outside the api will have the type GeneralError
		*/
		function PlayerIOError(message:String, id:int){
			super(message, id);
		}
		/**
		* The type of error the PlayerIOError object represent
		*/
		public function get type():PlayerIOError{
			return _type;
		}
	}
}
