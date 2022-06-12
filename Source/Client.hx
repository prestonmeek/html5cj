package;

import js.html.MessageEvent;
import js.html.WebSocket;

class Client {
    private var game:Main;

    private var port:Int = 8080;
    private var ws:WebSocket;

    private var penguin:Penguin;

    public function new(game:Main) {
        this.game = game;

        ws = new WebSocket('ws://localhost:' + Std.string(port));

        penguin = new Penguin(game);

        handleEvents();
    }

    private function handleEvents():Void {
        ws.onopen = () -> {
            trace('Connected to server');
        }

        ws.onmessage = (msg: MessageEvent) -> {
            switch (msg.data) {
                case 'wait':
                    Message.prompt('Please wait for another client...', true);
                case 'begin':
                    Message.prompt('Battle beginning...');
                    init();
                default:
                    trace('Unknown message type: ' + Std.string(msg.data));
            }
        }
    }

    private function init():Void {
        penguin.setup();
    }
}