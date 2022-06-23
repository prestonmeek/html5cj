package;

import openfl.Assets;

import openfl.display.MovieClip;
import openfl.display.SimpleButton;

import openfl.text.TextField;

import openfl.events.MouseEvent;

import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

class Message {
    private static var box:MovieClip;
    private static var txt:TextField;
    private static var btn:SimpleButton;
    private static var load:MovieClip;

    // Initialize the message box information
    // Only needs to be called once (in Main.hx)
    public static function init(game:Main) {
        box = Assets.getMovieClip('card:dialogue');

        box.visible = false;

        box.x = (Main.NOMINAL_WIDTH  - box.width)  / 2;
        box.y = (Main.NOMINAL_HEIGHT - box.height) / 2;

        txt = game.getChild('message_txt', box);

        btn = game.getChild('dialogue_btn', box);

        // When the Ok button is clicked, hide the dialogue box and set the mouse cursor back to the normal arrow
        btn.addEventListener(MouseEvent.CLICK, (event:MouseEvent) -> {
            box.visible = false;
            Mouse.cursor = MouseCursor.ARROW;
        });

        load = game.getChild('loading_mc');

        load.visible = false;

        // We first add the box and then the loading icon so that the loading icon goes in front
        game.addChild(box);
        game.addChild(load);
    }

    public static function prompt(msg:String, loading:Bool=false):Void {
        // If we want the prompt to load, we hide the button and show the loading icon
        // If we don't want the prompt to load, we show the button and hide the loading icon
        btn.visible  = !loading;
        load.visible = loading;

        txt.text = msg;

        box.visible = true;
    }
}