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

enum PenguinType {
    Player;
    Enemy;
}

class Penguin {
    private var game:Main;
    private var type:PenguinType;

    private var username:String;

    private var colors:Dynamic;

    private var penguin:MovieClip;
    private var body:MovieClip;
    private var frontArm:MovieClip;
    private var backArm:MovieClip;
    private var belt:MovieClip;

    private var nameField:TextField;

    public function new(game:Main, type:PenguinType) {
        this.game = game;
        this.type = type;

        // Load the colors JSON file
        colors = Json.parse(Assets.getText('colors'));

        // Define the TextField for the player's username
        // tf_name1 is the left side (Player)
        // tf_name2 is the right side (Enemy)
        if (type == Player)
            nameField = game.getChild('tf_name1');
        else
            nameField = game.getChild('tf_name2');
    }

    public function setup():Void {
        // Initialize the walk-on penguin MovieClip
        setupPenguin(Assets.getMovieClip('walk:walk'));

        // Add frame script to the last frame of the walk-on animation
        // Body (a child of "penguin" object) is used here, but any child can be used
        // I'm not exactly sure why but this only works with the "penguin" object's children, not the object itself
        // This changes the main penguin MovieClip to the ambient/idle animation
        body.addFrameScript(body.totalFrames - 1, () -> {
            // Remove the penguin MovieClip and re-add it as the idle animation
            game.removeChild(penguin);
            setupPenguin(Assets.getMovieClip('ambient:ambient'));
        });

        // Set the player's username text so it is shown on the screen
        nameField.text = username;
    }

    // Set the username text
    public function setUsername(username:String):Void {
        this.username = username;
    }

    private function setupPenguin(mc:MovieClip) {
        // Store the mc object in this.penguin
        penguin = mc;

        // These are just the x and y values found in the original CJ code
        penguin.x = 375;
        penguin.y = 240;

        // A scaleX of -1 makes the penguin walk out from the left, so only do it for the player
        if (type == Player)
            penguin.scaleX = -1;
        else
            penguin.scaleX = 1;

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
        // The - 3 is kind of arbitrary, but it just ensures the penguin sprite is behind the game UI (like the help menu)
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