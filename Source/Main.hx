package;

import openfl.Lib;
import openfl.Assets;

import openfl.display.Sprite;
import openfl.display.MovieClip;
import openfl.display.DisplayObject;

import openfl.events.Event;
import openfl.events.MouseEvent;

import openfl.geom.ColorTransform;

// TODO: fix fonts

class Main extends Sprite {
	private var game_mc:MovieClip;

	private var client:Client;

	private var clock:Clock;

	// These are taken directly from project.xml
	public static inline var NOMINAL_WIDTH:Int  = 760;
    public static inline var NOMINAL_HEIGHT:Int = 480;
	
	public function new() {
		super();

		setupDisplay();

		// NOTE: Message.init() should come before anything else in this file (setupDisplay must come before it, though)
		Message.init(this);

		// client = new Client(this);
		// TODO: remove this later, this is just for testing
		var player = new Penguin(this, Player);
        var enemy  = new Penguin(this, Enemy);
		player.setup();
        enemy.setup();

		clock = new Clock(this);

		stage.addEventListener(Event.RESIZE, onResize);
		onResize();
	}

	public function getChild(childName:String, ?parent:MovieClip):Dynamic {
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

		var help_mc = getChild('mc_help');

		var stop_frame   = 51;	// Stops at frame 51 instead of frame 1 so that the help menu doesn't snap above the screen
		var skip_frame   = 19;	// Skips to the skipTo frame to avoid the menu closing before the user clicks it again
		var skipTo_frame = 40;	// The frame in which the menu skips to so that once it is clicked again, it closes

		// We use gotoAndPlay because frame scripts are technically called on the frame after
		// This clip will be stopped by the frame script attached to stop_frame
		help_mc.gotoAndPlay(stop_frame);

		help_mc.addFrameScript(stop_frame, () -> help_mc.stop());
		help_mc.addFrameScript(skip_frame, () -> help_mc.gotoAndStop(skipTo_frame));

		help_mc.addEventListener(MouseEvent.CLICK, (event:MouseEvent) -> help_mc.play());

		addChild(game_mc);
	}

	// Adds children behind the game UI
	// This ensures that the help panel is always in front of these children (namely the penguins)
	public function addChildBehindUI(child:DisplayObject):Void {
		addChildAt(child, getChildIndex(game_mc));
	}

	// Start the clock
	public function startClock():Void {
		clock.start();
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

	// Code taken from online
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
