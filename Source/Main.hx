package;

import openfl.display.DisplayObjectContainer;
import openfl.Lib;
import openfl.Assets;

import openfl.display.Sprite;
import openfl.display.MovieClip;
import openfl.display.DisplayObject;

import openfl.events.Event;
import openfl.events.MouseEvent;

import openfl.geom.ColorTransform;

import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

// TODO: embed and fix fonts

class Main extends Sprite {
	private var game_mc:MovieClip;
	private var load_mc:MovieClip;
	private var help_mc:MovieClip;
	private var border_mc:MovieClip;

	private var client:Client;

	private var clock:Clock;

	// These are taken directly from project.xml
	public static inline var NOMINAL_WIDTH:Int  = 760;
    public static inline var NOMINAL_HEIGHT:Int = 480;
	
	public function new() {
		super();

		setupDisplay();

		// NOTE: Message.init() and Explosion.init() should come before anything else in this file 
		// The method setupDisplay must come before it, though
		Message.init(this);
		Explosion.init(this);

		client = new Client(this);

		clock = new Clock(this);

		stage.addEventListener(Event.RESIZE, onResize);
		onResize();
	}

	public function getChild(childName:String, ?parent:DisplayObjectContainer):Dynamic {
		// We use unsafe cast here so that the returned object is always a Dynamic
		// This way, we can set it to either a MovieClip, TextField, or Button simply by doing something like...
		// var mc: MovieClip = getChild('mc_name');
		if (parent == null)
			return cast game_mc.getChildByName(childName);
		else
			return cast parent.getChildByName(childName);
	}

	private function setupDisplay():Void {
		game_mc = Assets.getMovieClip('card:');

		// We add the background MovieClip to just Sprite instead of Sprite.game_mc
		// This way, it will be in the very back
		// The game UI (clock, help menu, etc.) aka game_mc can now be in front of the player with the background being behind them
		// The child game_mc is added at the bottom of this function
		var background:MovieClip = getChild('background_mc');

		game_mc.removeChild(background);
		addChild(background);

		// Store the loading MovieClip
		// Remove it from the game_mc 
		// It is added to this class near the bottom of this method
		load_mc = getChild('loading_mc');
		load_mc.visible = false;

		game_mc.removeChild(load_mc);

		// Store the help menu MovieClip
		// Remove it from the game_mc 
		// It is added to this class near the bottom of this method
		help_mc = getChild('mc_help');

		game_mc.removeChild(help_mc);

		var stop_frame   = 51;	// Stops at frame 51 instead of frame 1 so that the help menu doesn't snap above the screen
		var skip_frame   = 19;	// Skips to the skipTo frame to avoid the menu closing before the user clicks it again
		var skipTo_frame = 40;	// The frame in which the menu skips to so that once it is clicked again, it closes

		// We use gotoAndPlay because frame scripts are technically called on the frame after
		// This clip will be stopped by the frame script attached to stop_frame
		help_mc.gotoAndPlay(stop_frame);

		help_mc.addFrameScript(stop_frame, () -> help_mc.stop());
		help_mc.addFrameScript(skip_frame, () -> help_mc.gotoAndStop(skipTo_frame));

		// When the help menu is rolled over, it looks clickable
		// When it is rolled off of, the cursor is set back to the arrow
		help_mc.addEventListener(MouseEvent.ROLL_OVER, (event:MouseEvent) -> Mouse.cursor = MouseCursor.BUTTON);
		help_mc.addEventListener(MouseEvent.ROLL_OUT,  (event:MouseEvent) -> Mouse.cursor = MouseCursor.ARROW);

		// When the help menu is clicked, it opens
		help_mc.addEventListener(MouseEvent.CLICK, (event:MouseEvent) -> help_mc.play());

		// Store the border MovieClip
		// Remove it from the game_mc 
		// It is added to this class near the bottom of this method
		border_mc = getChild('mc_border');

		game_mc.removeChild(border_mc);

		// Add the game UI (NOT the help menu; this is mainly just the bottom bar where cards are shown) to this class
		addChild(game_mc);

		// Then, add the help menu to this class
		addChild(help_mc);

		// Then, add the border to this class
		// This ordering of adding children ensures the help menu is behind the border
		addChild(border_mc);

		// Add the loading MovieClip in front of every other child of this class
		// Technically, this is unnecessary as it is re-added in the Message class
		// However, this is just to be safe
		addChild(load_mc);
	}

	// Adds children behind the game UI
	// This ensures that the bottom panel is always in front of these children (namely the penguins)
	public function addChildBehindUI(child:DisplayObject):Void {
		addChildAt(child, getChildIndex(game_mc));
	}

	// Adds children behind the help menu UI
	// This ensures that the help menu is always in front of these children (namely the cards)
	public function addChildBehindHelp(child:DisplayObject):Void {
		addChildAt(child, getChildIndex(help_mc));
	}

	// Set the index of a scored card
	// This is so that they stack properly on the top of the screen
	public function setScoredCardIndex(card:DisplayObject):Void {
		// We set the card's index to be one in front of the game_mc MovieClip
		// This way, all cards that are scored are moved behind all other cards in the z-ordering
		// This ensures that stacking will happen properly
		setChildIndex(card, getChildIndex(game_mc) + 1);
	}

	// Show the loading icon
	public function load():Void {
		load_mc.visible = true;
	}

	// Hide the loading icon
	public function stopLoading():Void {
		load_mc.visible = false;
	}

	// Start the clock
	public function startClock():Void {
		clock.start();
	}

	// Stop the clock
	public function stopClock():Void {
		clock.stop();
	}

	// Converts hex number to usable ColorTransform
	public function getHexColor(hex:Int):ColorTransform {
		var color:ColorTransform = new ColorTransform();
		color.color = hex;

        return color;
	}

	// Converts dynamic color to usable ColorTransform
	public function getDynamicColor(c:Dynamic):ColorTransform {
		var color:ColorTransform = new ColorTransform();
		color = new ColorTransform(c.ra / 100, c.ga / 100, c.ba / 100, c.aa / 100, c.rb, c.gb, c.bb, c.ab);

		return color;
	}

	public function getScreenWidth():Int {
		return NOMINAL_WIDTH;
	}

	public function getScreenHeight():Int {
		return NOMINAL_HEIGHT;
	}

	// Code taken from OpenFL forums
	// Just resizes the stage as the window changes size
	private function onResize(?e:Event):Void {
		var stageScaleX:Float = stage.stageWidth  / NOMINAL_WIDTH;
		var stageScaleY:Float = stage.stageHeight / NOMINAL_HEIGHT;
		
		var stageScale:Float = Math.min(stageScaleX, stageScaleY);
		
		Lib.current.x = 0;
		Lib.current.y = 0;
		Lib.current.scaleX = stageScale;
		Lib.current.scaleY = stageScale;
		
		if (stageScaleX > stageScaleY) {
			Lib.current.x = (stage.stageWidth  - NOMINAL_WIDTH  * stageScale) / 2;
		} else {
			Lib.current.y = (stage.stageHeight - NOMINAL_HEIGHT * stageScale) / 2;
		}
	}
}
