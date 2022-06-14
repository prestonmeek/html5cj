package;

import haxe.Json;

import js.html.MessageEvent;
import js.html.WebSocket;

import js.lib.Object;

class Client {
    private var game:Main;

    private var port:Int = 8080;
    private var ws:WebSocket;

    private var setup:Bool = false;

    private var player:Penguin;
    private var enemy:Penguin;

    public function new(game:Main) {
        this.game = game;

        ws = new WebSocket('ws://localhost:' + Std.string(port));

        player  = new Penguin(game, Player);
        enemy   = new Penguin(game, Enemy);

        handleEvents();
    }

    private function handleEvents():Void {
        // TODO: get this from the login information
        var username:String = 'Preston';

        ws.onopen = () -> {
            trace('Connected to server');
        }

        ws.onmessage = (msg: MessageEvent) -> {
            var data:Dynamic = Json.parse(msg.data);

            switch (data.type) {
                // Wait for another client to join the queue
                // We set the username here since we have confirmed that we are connected to the server
                case 'wait':
                    player.setUsername(username);
                    Message.prompt('Please wait for another client...', true);

                // We need to get the enemy's username
                // This packet is so the OTHER client gets OUR username (the client is the enemy in this case)
                case 'get enemy username':
                    sendPacket('send enemy username', { 'name': username });

                // Set the enemy username to the one received
                case 'set enemy username':
                    enemy.setUsername(data.name);
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

    private function sendPacket(type:String, ?args:Dynamic):Void {
        // Join the type of the packet with its arguments
        ws.send(
            Json.stringify(
                Object.assign({ 'type': type }, args)
            )
        );
    }
}