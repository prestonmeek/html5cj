package;

import haxe.DynamicAccess;
import haxe.Json;

import openfl.Lib;
import openfl.Assets;

import openfl.display.MovieClip;
import openfl.display.DisplayObject;

import openfl.text.TextField;

import openfl.events.MouseEvent;

import motion.Actuate;

import Penguin.PenguinType;

enum CardOrientation {
    Front;
    Back;
}

class Card {
    private var game:Main;
    private var type:PenguinType;

    // Define the different elements and their corresponding frames
    private final elements:Map<String, Int> = [
        'fire'  => 1,
        'water' => 2,
        'snow'  => 3
    ];

    private var colors:DynamicAccess<Dynamic>;
    private var cards:Dynamic;

    private var data:Dynamic;

    private var body:MovieClip;

    private var glow:MovieClip;
    private var elem:MovieClip;
    private var color:MovieClip;

    private var power:TextField;

    private var icon:MovieClip;

    // For some reason, the front-facing cards use the width of the "power" child, not the "body" child
    // However, the back facing cards do use the "body" child's width
    // I have no idea why it works this way
    // Therefore, I use custom width and height attributes based on the orientation of the card
    // Initially, the Player's cards are facing the front and the enemy's cards are facing the back
    private var width:Float;
    private var height:Float;

    public function new(game:Main, type:PenguinType, index:Int) {
        this.game = game;
        this.type = type;

        // Load the colors JSON file
        // Select "card" since we only need the card colors here
        colors = Json.parse(Assets.getText('colors')).card;

        // Load the cards JSON file
        cards = Json.parse(Assets.getText('cards'));

        // Get the specific card's data from the JSON data based on its index
        // Since this is an array, we don't need to use .get()
        data = cards[index];

        // Overwrite the data object's color property and add a glow property
        // This converts the stored color string into a usable ColorTransform
        // This also adds a glow property as a ColorTransform as well, if the card is supposed to have one
        // The glow property must be added first since it uses the original color property to get its data
        if (data.glow) {
            // We need to use .get() here in order to keep this application cross-platform
            // Something like colors[data.color] works in the web, but not for macos building
            // Assumably, this is because the web handles Dynamics like JS objects, but they are handled differently in C++
            data.glow = game.getDynamicColor(colors.get(data.color).glow);
        }
        
        data.color = game.getHexColor(Std.parseInt(colors[data.color].hex));

        // Load the relevant components of the card MovieClip
        body = Assets.getMovieClip('card:card');

        glow  = game.getChild('mc_glow', body);
        elem  = game.getChild('mc_atr',  body);
        color = game.getChild('mc_col',  body);

        // The power text field must be accessed within a child MovieClip
        power = game.getChild('tf_pt', cast(body.getChildByName('mc_pt'), MovieClip));
    }

    // Setup the visual aspects of the card MovieClip
    public function setup():Void {
        // Set the card's initial x and y position
        // It will be positioned at the bottom center of the screen
        body.x = (game.getScreenWidth() - width) / 2;
        body.y = game.getScreenHeight();

        // Get the icon MovieClip based on the ID of the card as stored in the JSON file
        // Add the icon as a child to the MovieClip
        // The icon will be moved behind everything else in the setOrientation method
        icon = Assets.getMovieClip(Std.string(data.id) + ':');
        body.addChild(icon);

        // This if-statement lets us change the setup for the player's cards and the enemy's cards
        // The player's cards start as face-forward, while the enemy cards are the opposite
        // The enemy cards are also a bit smaller
        if (type == Player) {
            // Set the card to be facing forward
            setOrientation(Front);

            // When the card is rolled over, set it to frame 2
            // This gives it a slight shadow tint
            body.addEventListener(MouseEvent.ROLL_OVER, (event:MouseEvent) -> setOrientation(Front, 2));

            // When the card is rolled out of, set it back to the default frame 1
            body.addEventListener(MouseEvent.ROLL_OUT, (event:MouseEvent) -> setOrientation(Front));
        } else {
            // Set the card to be facing backwards
            setOrientation(Back);
        }

        // Add the card to the game
        game.addChild(body);
    }

    // Set the orientation of the card
    private function setOrientation(orientation:CardOrientation, ?frame:Int):Void {
        // Frame 1 is the default front-facing frame
        // Frame 5 is the default back-facing frame
        if (frame == null) {
            if (orientation == Front)
                frame = 1;
            else
                frame = 5;
        }

        // Set the frame of the card
        body.gotoAndStop(frame);

        // The new scaleX and scaleY of the card (to scale it down)
        var scale:Float;

        // The parent that the custom width and height attributes use based on the orientation of the card
        // The reasoning for this is explained above the width and height declarations
        // The reason we store the parent and not just the width and height is because the body must be scaled down first
        // DisplayObject is used since dimensionsParent can be either TextField or MovieClip
        var dimensionsParent:DisplayObject;

         // If the card is facing forward, set its color, icon, element, and power
        // Otherwise, hide them (since the back side doesn't show an element or power)
        if (orientation == Front) {
            // This number come from the original CJ code
            scale = .275;

            // Front-facing cards use the "power" child to get their width and height
            dimensionsParent = power;

            // We will always see the icon, element, and power (and sometimes glow) of a front-facing card
            // Make sure all of these are visible
            // If the card doesn't have a glow, it is set to be invisible below
            icon.visible  = true;
            elem.visible  = true;
            glow.visible  = true;
            power.visible = true;

            // Set the card color based on the JSON data
            color.transform.colorTransform = data.color;
            
            // Move the icon behind everything else (aka index 0)
            body.setChildIndex(icon, 0);

            // If the card has a glow, keep it visible and set its correct color
            // Otherwise, simply hide the glow MovieClip
            // We explicitly do != false for cross-compile support
            if (data.glow != false)
                glow.transform.colorTransform = data.glow;
            else
                glow.visible = false;

            // Move the glow behind everything, including the icon
            // This is why we do this step after moving the icon to the back
            body.setChildIndex(glow, 0);

            // Set the elem MovieClip frame equal to the frame of the stored element
            // The frame of the element is accessed using the elements Map, which converts the element string to the frame integer
            elem.gotoAndStop(elements[data.element]);

            // Set the power of the card equal to the power stored in the JSON
            power.text = Std.string(data.power);
        } else {
            // This number come from the original CJ code
            scale = .15;

            // Back-facing cards use the "body" child to get their width and height
            dimensionsParent = body;

            // We will never see the icon, element, glow, or power of a back-facing card
            // Therefore, we can just hide them
            icon.visible  = false;
            elem.visible  = false;
            glow.visible  = false;
            power.visible = false;
        }

        // Set the scaleX, scaleY, width, and height of the card
        body.scaleX = scale;
        body.scaleY = scale;

        width  = dimensionsParent.width;
        height = dimensionsParent.height;
    }

    // Show the cards on the screen for the first time
    public function show(offset:Int):Void {
        // The initial x-value for the Player and Enemy change
        var initialX:Int;

        // The same y-value is used for both the Player's and the Enemy's cards, so we can define it here
        var y:Int = 385;

        // This if-statement lets us change the display locations for the player's cards and enemy's cards
        // For simplicity's sake, the player will always be on the left and the enemy on the right
        // These seemingly random values for x and y were obtained from the original CJ code and/or experimentally
        if (type == Player)
            initialX = 50;
        else
            initialX = 530;

        // Set the card's x and y position with an animation
        // The initial x-value of 50 is added to the offset multiplied by the width
        // This properly spaces the cards out
        Actuate.tween(body, .5, 
            {
                x: initialX + (offset * width),
                y: y
            }
        );
    }
}