package;

import haxe.Json;

import js.html.MessageEvent;
import js.html.WebSocket;

import js.lib.Object;

class Client {
    private var game:Main;

    private var port:Int = 8080;
    private static var ws:WebSocket;

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

            sendPacket('store client data', { 'username': username, 'deck': deck });
        }

        ws.onmessage = (msg: MessageEvent) -> {
            var data:Dynamic = Json.parse(msg.data);

            switch (data.type) {
                // Wait for another client to join the queue
                // We set the username and deck here since we have confirmed that we are connected to the server
                case 'wait':
                    player.setUsername(username);
                    player.setDeck(deck);

                    Message.prompt('Please wait for another client...', true);

                // We need to get the enemy's information
                // This packet is so the OTHER client gets OUR information (the client is the enemy in this case)
                // TODO: make it so we get the deck from the database
                case 'get client info':
                    sendPacket('send client info', { 'name': username, 'deck': [0, 1, 2, 3, 4] });
                
                // Now that we have the other client's info, we can set it accordingly
                case 'set client info':
                    enemy.setUsername(data.name);
                    enemy.setDeck(data.deck);

                    // Since we have received all the information we need, we can tell the server we are ready
                    sendPacket('ready');

                // Both clients are ready, so we can begin the match
                case 'begin':
                    // Only handle this packet if the client isn't already setup
                    if (!setup) {
                        setup = true;

                        Message.prompt('Battle beginning...');
                        
                        player.setup();
                        enemy.setup();
                    }

                // An unknown packet is being handled
                default:
                    trace('Unknown message type: ' + Std.string(msg.data));
            }
        }
    }

    // This function is static and public so that other classes can easily use it without weird passing of class instances
    public static function sendPacket(type:String, ?args:Dynamic):Void {
        // Join the type of the packet with its arguments
        ws.send(
            Json.stringify(
                Object.assign({ 'type': type }, args)
            )
        );
    }
}