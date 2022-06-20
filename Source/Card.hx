package;

import haxe.DynamicAccess;
import haxe.Json;

import openfl.Lib;
import openfl.Assets;

import openfl.display.MovieClip;
import openfl.display.DisplayObject;

import openfl.text.TextField;

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

        // This if-statement lets us change the setup for the player's cards and the enemy's cards
        // The player's cards start as face-forward, while the enemy cards are the opposite
        // The enemy cards are also a bit smaller
        if (type == Player) {
            // Set the card to be facing forward
            setOrientation(Front);

            // If the card has a glow, keep it visible and set its correct color
            // Otherwise, simply hide the glow MovieClip
            // We explicitly do != false for cross-compile support
            if (data.glow != false)
                glow.transform.colorTransform = data.glow;
            else
                glow.visible = false;

            // Set the elem MovieClip frame equal to the frame of the stored element
            // The frame of the element is accessed using the elements Map, which converts the element string to the frame integer
            elem.gotoAndStop(elements[data.element]);

            // Set the card color based on the JSON data
            color.transform.colorTransform = data.color;

            // Set the power of the card equal to the power stored in the JSON
            power.text = Std.string(data.power);

            // Get the icon MovieClip based on the ID of the card as stored in the JSON file
            // Add the icon as a child to the MovieClip behind everything else within the MovieClip (aka index 0)
            icon = Assets.getMovieClip(Std.string(data.id) + ':');
            body.addChildAt(icon, 0);

            // Move the glow behind everything, including the icon
            // This is why we do this step after moving the icon to the back
            body.setChildIndex(glow, 0);

            // Set the custom width and height attributes for the front-facing card
            // The reasoning is explained above the width and height declarations
            width  = power.width;
            height = power.height;
        } else {
            // Set the card to be facing backwards
            setOrientation(Back);

            // We will never see the glow, element, or power of an enemy's cards
            // Therefore, we can just hide them all
            glow.visible  = false;
            elem.visible  = false;
            power.visible = false;
        }

        // Add the card to the game
        game.addChild(body);
    }

    // Set the orientation of the card
    private function setOrientation(orientation:CardOrientation):Void {
        // This is the default frame in which a card will be stopped on
        var frame:Int;

        // The new scaleX and scaleY of the card (to scale it down)
        var scale:Float;

        // The parent that the custom width and height attributes use based on the orientation of the card
        // The reasoning for this is explained above the width and height declarations
        // The reason we store the parent and not just the width and height is because the body must be scaled down first
        // DisplayObject is used since dimensionsParent can be either TextField or MovieClip
        var dimensionsParent:DisplayObject;

        if (orientation == Front) {
            // These numbers come from the original CJ code
            frame = 1;
            scale = .275;

            // Front-facing cards use the "power" child to get their width and height
            dimensionsParent = power;
        } else {
            // These numbers come from the original CJ code
            frame = 5;
            scale = .15;

            // Back-facing cards use the "body" child to get their width and height
            dimensionsParent = body;
        }

        // Set the frame, scaleX, scaleY, width, and height of the card
        body.gotoAndStop(frame);

        body.scaleX = scale;
        body.scaleY = scale;

        width  = dimensionsParent.width;
        height = dimensionsParent.height;
    }

    // Show the card on the screen
    public function show(offset:Int):Void {
        // Since it is only the initial y that changes, we don't need an initial y variable
        var initialX:Int;

        // This if-statement lets us change the display locations for the player's cards and enemy's cards
        // For simplicity's sake, the player will always be on the left and the enemy on the right
        // These values were obtained from the original CJ code and/or experimentally
        if (type == Player)
            initialX = 50;
        else
            initialX = 530;

        // Set the card's x and y position
        // The initial X is added to the offset multiplied by the width
        // This properly spaces the cards out
        // TODO: make only the player's cards tween; enemy cards should appear all at once.
        Actuate.tween(body, .5, 
            {
                x: initialX + (offset * width),
                y: 385
            }
        );
    }
}