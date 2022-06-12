package;

import haxe.Json;

import openfl.Lib;
import openfl.Assets;

import openfl.display.MovieClip;

import openfl.text.TextField;

import openfl.geom.ColorTransform;

/*
player1 = new Player(this, 375, 240, 1, 7, 1, 'Preston');
player2 = new Player(this, 375, 240, 2, 14, 7, 'Jackie');
*/

class Penguin {
    private var game:Main;

    private var colors:Dynamic;

    private var penguin:MovieClip;
    private var body:MovieClip;
    private var frontArm:MovieClip;
    private var backArm:MovieClip;
    private var belt:MovieClip;

    private var username:TextField;

    public function new(game:Main) {
        this.game = game;

        // Load the colors JSON file
        colors = Json.parse(Assets.getText('colors'));

        // Define the TextField for the player's username
        username = game.getChild('tf_name1');
    }

    public function setup():Void {
        // Initialize the walk-on penguin MovieClip
        setupPenguin(Assets.getMovieClip('walk:walk'));

        // Add frame script to the last frame of the walk-on animation
        // Body (a child of "penguin" object) is used here, but any child can be used
        // I'm not exactly sure why but this only works with the "penguin" object's children, not the object itself
        // This changes the main penguin MovieClip to the ambient/idle animation
        body.addFrameScript(body.totalFrames - 1, () -> {
            // Remove the penguin child and re-add it as the idle animation
            game.removeChild(penguin);
            setupPenguin(Assets.getMovieClip('ambient:ambient'));
        });

        // Set the username text
        username.text = 'Preston';   
    }

    private function setupPenguin(mc:MovieClip) {
        // Store the mc object in this.penguin
        penguin = mc;

        // These are just the x and y values found in the original CJ code
        penguin.x = 375;
        penguin.y = 240;

        // For the client so that the penguin walks out from the left
        penguin.scaleX = -1;

        // Initialize the rest of the penguin's parts
        body     = cast(penguin.getChildByName('body_mc'),     MovieClip);
        frontArm = cast(penguin.getChildByName('frontArm_mc'), MovieClip);
        backArm  = cast(penguin.getChildByName('backArm_mc'),  MovieClip);
        belt     = cast(penguin.getChildByName('belt_mc'),     MovieClip);

        // Hide the orange sensei that shows by default
        cast(penguin.getChildByName('sensay_mc'), MovieClip).visible = false;

        // Set the penguin and belt color
        setColor('red');
        setBeltColor('black');

        // Add the main penguin body to the game
        // The - 3 is kind of arbitrary, but it just ensures the penguin sprite is behind the help menu
        game.addChildAt(penguin, game.numChildren - 3);
    }

    // Sets the penguin color
    private function setColor(c:String):Void {
        // Get the color HEX code based on the color name passed in from the JSON file
        // If the color doesn't exist in the JSON file, set it to the default of blue
        var color:String;

        if (Reflect.hasField(colors.penguin, c))
            color = Reflect.getProperty(colors.penguin, c);
        else
            color = Reflect.getProperty(colors.penguin, 'blue');

        // Convert the color HEX code to a usable ColorTransform
        var transform:ColorTransform = game.getHexColor(Std.parseInt(color));

        // Apply the ColorTransform to the necessary MovieClips
        body.transform.colorTransform     = transform;
        frontArm.transform.colorTransform = transform;
        backArm.transform.colorTransform  = transform;
    }

    // Sets the belt color
    private function setBeltColor(c:String):Void {
        // Get the color HEX code based on the color name passed in from the JSON file
        // If the color doesn't exist in the JSON file, set it to the default of white
        var color:String;

        if (Reflect.hasField(colors.penguin, c))
            color = Reflect.getProperty(colors.belt, c);
        else
            color = Reflect.getProperty(colors.belt, 'white');

        // Convert the color HEX code to a usable ColorTransform
        var transform:ColorTransform = game.getHexColor(Std.parseInt(color));

        // Apply the ColorTransform to the necessary MovieClips
        belt.transform.colorTransform = transform;
    }

}