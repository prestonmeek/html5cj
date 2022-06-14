package;

import haxe.Json;

import openfl.Assets;

import openfl.display.MovieClip;

import openfl.text.TextField;

import openfl.geom.ColorTransform;

class Card {
    private var game:Main;

    // Define the different elements and their corresponding frames
    private final elements:Map<String, Int> = [
        'fire'  => 1,
        'water' => 2,
        'snow'  => 3
    ];

    private var colors:Dynamic;
    private var cards:Dynamic;

    private var data:Dynamic;

    private var body:MovieClip;

    private var glow:MovieClip;
    private var elem:MovieClip;
    private var color:MovieClip;

    private var power:TextField;

    private var icon:MovieClip;

    public function new(game:Main, id:Int) {
        this.game = game;

        // Load the colors JSON file
        // Select "card" since we only need the card colors here
        colors = Json.parse(Assets.getText('colors')).card;

        // Load the cards JSON file
        cards = Json.parse(Assets.getText('cards'));

        // Get the specific card's data from the JSON data based on its ID
        // We subtact 1 since an ID of 1 equals an index of 0, and so on
        data = cards[id - 1];

        // Overwrite the data object's color property and add a glow property
        // This converts the stored color string into a usable ColorTransform
        // This also adds a glow property as a ColorTransform as well
        // The glow property must be added first since it uses the original color property to get its data
        data.glow  = game.getDynamicColor(colors[data.color].glow);
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
        // This is the default frame in which a card will be stopped on
        body.gotoAndStop(1);

        // If the card has a glow, keep it visible and set its correct color
        // Otherwise, simply hide the glow MovieClip
        if (data.glow)
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

        // Add the card to the game
        game.addChild(body);
    }
}