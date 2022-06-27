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

        // When the Ok button is hovered over, make the button appear clickable
        // When it is no longer being hovered over, revert this change
        btn.addEventListener(MouseEvent.ROLL_OVER, (event:MouseEvent) -> Mouse.cursor = MouseCursor.BUTTON);
        btn.addEventListener(MouseEvent.ROLL_OUT,  (event:MouseEvent) -> Mouse.cursor = MouseCursor.BUTTON);
        
        // When the Ok button is clicked, hide the dialogue box and set the mouse cursor back to the normal arrow
        btn.addEventListener(MouseEvent.CLICK, (event:MouseEvent) -> {
            box.visible = false;
            Mouse.cursor = MouseCursor.ARROW;
        });

        // Although there are loading functions in the Main class, we re-access the loading MovieClip here
        // This is because this is a static class so any methods from the game instance won't work in the other methods here
        // Basically, we can't use game.load() or game.stopLoading() in the prompt method
        // Also, we need a loading MovieClip that is even in front of the box of this class
        // Just think of this load as part of the box, while the Main class' load as part of the entire game
        // We also have to make sure that the parent for the getChild method is the game class itself, not game_mc
        // This is because we remove the loading icon from game_mc and add it to the Main class directly
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