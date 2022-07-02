package;

import haxe.DynamicAccess;
import haxe.Json;

import openfl.Lib;
import openfl.Assets;

import openfl.display.MovieClip;
import openfl.display.DisplayObject;

import openfl.filters.BlurFilter;

import openfl.text.TextField;

import openfl.events.MouseEvent;
import openfl.events.EventType;

import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

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

    private var dist:Float;

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

        // The distance for separating the cards in the deck on the bottom of the screen
        // For some reason, the front-facing cards use the distance/width of the "power" child, not the "body" child
        // However, the back facing cards do use the "body" child's distance/width
        // I have no idea why it works this way, but that's why the dist variable exists
        // These values are roughly equal to power.width and body.width
        // I just used exact values rather than the dynamic values since body.width doesn't work until the proper frame is set
        // That isn't done until the setup method is called, so these estimated values work just fine
        if (type == Player)
            dist = 72;
        else
            dist = 35;
    }

    // Setup the visual aspects of the card MovieClip
    public function setup():Void {
        // Set the card's initial x and y position
        // It will be positioned at the bottom center of the screen
        // We use dist here instead of width since dist essentially acts as the width
        // Since it is the unit used to space the cards out, it will be equivalent to the seeming width
        body.x = (game.getScreenWidth() - dist) / 2;
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

            // Add all the important event listeners
            addEventListeners();
        } else {
            // Set the card to be facing backwards
            setOrientation(Back);
        }

        // Add the card to the game
        game.addChild(body);
    }

    // Return the power and element of the card for packet-sending purposes
    // Everything is sent over as a string but the server handles power as a number
    public function getStats():Map<String, String> {
        return [
            'power'   => data.power,
            'element' => data.element
        ];
    }

    // Return the element of the card
    public function getElement():String {
        return data.element;
    }

    // Adds the event listener to the body
    // This is so the Deck class can add event listeners
    public function addEventListener(type:EventType<MouseEvent>, listener: (event:MouseEvent) -> Void):Void {
        body.addEventListener(type, listener);
    }

    // This adds all the important event listeners
    // We make sure we give the click event listener priority
    // This is so that it always go before the click event listener added in the Deck class
    public function addEventListeners():Void {
        body.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
        body.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
        body.addEventListener(MouseEvent.CLICK, onClick, false, 1);
    }

    // Checks if the Card body has an event listener
    // This is so the Deck class can check for event listeners
    public function hasEventListener(type:String):Bool {
        return body.hasEventListener(type);
    }

    // Removes all the event listeners from the Card body
    // This is so the Deck class can remove event listeners
    public function removeEventListeners():Void {
        body.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
        body.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
        body.removeEventListener(MouseEvent.CLICK, onClick);
    }

    // When the card is rolled over, set it to frame 2
    // This gives it a slight shadow tint
    // Also, change the mouse cursor so the card looks clickable
    public function onRollOver(event:MouseEvent):Void {
        setOrientation(Front, 2);
        Mouse.cursor = MouseCursor.BUTTON;
    }

    // When the card is rolled out of, set it back to the default frame 1
    // Also, change the mouse cursor so that it is back to being the default arrow
    public function onRollOut(event:MouseEvent):Void {
        setOrientation(Front);
        Mouse.cursor = MouseCursor.ARROW;
    }

    // When the card is clicked, stop the clock and send the card to the center
    public function onClick(event:MouseEvent):Void {
        // Stop the game clock
        game.stopClock();

        // Reset the cursor to the default arrow
        Mouse.cursor = MouseCursor.ARROW;

        // Make sure the card is on frame 1
        setOrientation(Front);

        // Show that the card that has been selected
        select();
    }

    // Animate the card to tween to the middle of the screen, showing it has been selected
    public function select():Void {
        // The x-value for the Player and Enemy cards
        var x:Int;

        // This if-statement lets us change the display locations for the player's cards and enemy's cards
        // For simplicity's sake, the player will always be on the left and the enemy on the right
        // These seemingly random values for x and y were obtained from the original CJ code and/or experimentally
        if (type == Player)
            x = 215;
        else
            x = 440;

        // The same y-value is used for both the Player's and the Enemy's cards, so we can define it here
        var y:Int = 165;

        // Set the card's x and y position with an animation
        // Also scale the card up in this animation
        Actuate.tween(body, .6, 
            {
                x: x, 
                y: y, 
                scaleX: .375, 
                scaleY: .375
            }
        );
    }

    // Flip the enemy's card, revealing it to the player
    public function flip(?callback:() -> Void):Void {
        if (type != Enemy)
            return;

        // We add a two-second delay here to make sure that all tweens are completed
        Actuate.timer(2).onComplete(() -> {
            // We store the proper scaleX and scaleY so we can tween the card back to its original scale
            // We do this at the start of all the tweening since setOrientation method sets the scaleX to when the card is in your deck
            // We do it after the delay to make sure all tweens are completed
            // This is smaller than when a card has been selected
            var oldScaleX:Float = body.scaleX;
            var oldScaleY:Float = body.scaleY;

            // We also want to store the width of the body
            // This is because when we change the orientation/body frame of the card, its width changes
            // This behavior is weird but I talk about it a bit near the bottom of the constructor of this class
            var oldWidth:Float = body.width;

            // This value was determined experimentally
            var duration:Float = 0.2;
            
            // We then blur the card on the x-axis so the flip looks more realistic
            Actuate.effects(body, duration).filter(BlurFilter, { blurX: 2, quality: 2 });

            // We make it so the card shrinks to a scale X of 0
            // We also make it move towards its center
            // Basically, think of this like pushing its sides together towards the center until it appears to have 0 width
            Actuate.tween(body, duration, { scaleX: 0, x: body.x + (oldWidth / 2) }).onComplete(() -> {
                // Flip the card to the front
                setOrientation(Front);
                
                // We then reset the actual scaleX back to 0 (since this was reverted in the setOrientation method)
                // We also reset to the original scaleY
                body.scaleX = 0;
                body.scaleY = oldScaleY;

                // Remove the card's blur effect after it is partly complete with the second flip animation (the tween below)
                // This gives the blur a more natural feel as it is removed within the animation
                // The / 2 was determined experimentally
                Actuate.timer(duration / 2).onComplete(() -> body.filters = null);

                // Return the card to its original position and scale
                // The * 3 was determined experimentally
                Actuate.tween(body, duration * 3, { scaleX: oldScaleX, x: body.x - (oldWidth / 2) });

                // Delay two seconds to show the results
                // After the delay, if a callback was passed in, run the calllback
                Actuate.timer(2).onComplete(() -> {
                    if (callback != null)
                        callback();
                });
            });
        });
    }

    // Remove the card from the scene
    public function remove():Void {
        game.removeChild(body);
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

        // If the card is facing forward, set its color, icon, element, and power
        // Otherwise, hide them (since the back side doesn't show an element or power)
        if (orientation == Front) {
            // This number come from the original CJ code
            scale = .275;

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
    }

    // Show the cards on the screen for the first time
    public function show(offset:Int):Void {
        // The initial x-value for the Player and Enemy cards
        var initialX:Int;

        // This if-statement lets us change the display locations for the player's cards and enemy's cards
        // For simplicity's sake, the player will always be on the left and the enemy on the right
        // These seemingly random values for x and y were obtained from the original CJ code and/or experimentally
        if (type == Player)
            initialX = 50;
        else
            initialX = 530;

        // The same y-value is used for both the Player's and the Enemy's cards, so we can define it here
        var y:Int = 385;

        // Set the card's x and y position with an animation
        // The initial x-value of 50 is added to the offset multiplied by the proper distance between each card
        // This properly spaces the cards out
        Actuate.tween(body, .5, 
            {
                x: initialX + (offset * dist),
                y: y
            }
        );
    }
}