package;

import openfl.display.MovieClip;
import openfl.text.TextField;

class Clock {
    private var game:Main;

    private var body:MovieClip;
    private var displayTime:TextField;

    private var timer:haxe.Timer;

    private var currentTime:Int;

    public function new(game:Main) {
        this.game = game;

        // Set the body (the main clock MovieClip)
        body = game.getChild('mc_clock');

        // Set the displayTime TextField
        displayTime = game.getChild('timer_txt', body);

        reset(false);
    }

    // Reset the clock
    private function reset(visible:Bool):Void {
        // Set the body's default frame and hide it
        // Frame 1 is a fully green clock
        body.gotoAndStop(1);
        body.visible = visible;

        // The clock starts with 20 seconds by default
        currentTime = 20;

        // Set the default display text to be the default currentTime value (20 seconds)
        displayTime.text = Std.string(currentTime);
    }

    // Start the countdown of the clock
    public function start():Void {
        // Reset the clock, but make sure it is visible
        reset(true);
        
        // Have a timer run every second
        timer = new haxe.Timer(1000);

        timer.run = () -> {
            // Decrement the current time
            currentTime -= 1;

            // Set the display text to the stringified current time
            displayTime.text = Std.string(currentTime);

            // Have the clock body tick frames
            body.nextFrame();

            // If there is no time left, stop this timer loop from running
            if (currentTime == 1)
                timer.stop();
        }
    }

    public function stop():Void {
        timer.stop();
    }
}