package;

import haxe.DynamicAccess;
import haxe.Json;

import js.html.MessageEvent;
import js.html.WebSocket;

import js.lib.Object;

class Client {
    private var game:Main;

    private var port:Int = 8080;
    private static var ws:WebSocket;

    private static var roomID:String;

    private var setup:Bool = false;

    private var player:Penguin;
    private var enemy:Penguin;

    public function new(game:Main) {
        this.game = game;

        ws = new WebSocket('ws://localhost:' + Std.string(port));

        player = new Penguin(game, Player);
        enemy  = new Penguin(game, Enemy);

        handleEvents();
    }

    private function handleEvents():Void {
        // TODO: instead of these sample values, get this info from the database
        var username:String = 'Preston';
        var deck:Array<Int> = [0, 1, 2, 3, 4];

        // When the client connects, send the server any important information
        ws.onopen = () -> {
            trace('Connected to server');

            // We set the username and deck here since we have confirmed that we are connected to the server
            player.setUsername(username);
            player.setDeck(deck);

            // Until we receive the "begin" packet, we know we have to wait for another client
            Message.prompt('Please wait for another client...', true);

            // Give the server the information to store
            sendPacket('store client data', { 'username': username, 'deck': deck });
        }

        ws.onmessage = (msg: MessageEvent) -> {
            var data:DynamicAccess<Dynamic> = Json.parse(msg.data);

            // Make sure that the packet has a type
            if (!data.exists('type'))
                return;

            switch (data.get('type')) {
                // Both clients are ready, so we can begin the match
                case 'begin':
                    // Only handle this packet if the client isn't already setup
                    // We can probably remove this later once we have a proper room system
                    // We also want to make sure the data object has the 'name' and 'deck' property
                    // The 'room ID' property is also important
                    trace(data);
                    if (!setup && (data.exists('username') && data.exists('deck') && data.exists('room ID'))) {
                        setup = true;

                        // Set the username and deck of the enemy
                        enemy.setUsername(data.get('username'));
                        enemy.setDeck(data.get('deck'));

                        // Store the room ID
                        roomID = data.get('room ID');

                        // Tell the user their battle is beginning
                        Message.prompt('Battle beginning...');
                        
                        // Setup the player and the enemy
                        player.setup();
                        enemy.setup();
                    }

                // An unknown packet is being handled
                default:
                    trace('Unknown packet type: ' + Std.string(data.get('type')));
            }
        }
    }

    private function sendPacket(type:String, ?args:Dynamic):Void {
        // Join the type of the packet with its arguments
        ws.send(
            Json.stringify(
                Object.assign({ 'type': type }, args)
            )
        );
    }

    // This function is static and public so that other classes can easily use it without weird passing of class instances
    public static function sendRoomPacket(type:String, ?args:Dynamic):Void {
        // Join the type of the packet and the room ID with its arguments
        ws.send(
            Json.stringify(
                Object.assign({ 'type': type, 'room ID': roomID }, args)
            )
        );
    }
}