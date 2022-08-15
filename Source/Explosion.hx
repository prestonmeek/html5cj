package;

import openfl.Assets;

import openfl.display.MovieClip;

class Explosion {
    // We need two body MovieClips because there could be two explosions if there is a tie
    private static var body1:MovieClip;
    private static var body2:MovieClip;

    // Initialize the explosion MovieClip
    // Only needs to be called once (in Main.hx)
    public static function init(game:Main) {
        // Grab the explosion MovieClips
        body1 = Assets.getMovieClip('card:explosion');
        body2 = Assets.getMovieClip('card:explosion');

        // Have them stop at their first frame and be invisible
        body1.gotoAndStop(1);
        body2.gotoAndStop(1);

        body1.visible = false;
        body2.visible = false;

        // Scale them down
        body1.scaleX = .5;
        body1.scaleY = .5;

        body2.scaleX = .5;
        body2.scaleY = .5;

        // Add the explosion MovieClips to the game
        game.addChildBehindHelp(body1);
        game.addChildBehindHelp(body2);
    }

    public static function play(result:String):Void {
        // The position of the explosion goes on top of the card that lost
        // So, if the client won, we position it on top of the other client/enemy's card, and vice versa
        // In the case of a tie, both cards explode
        // These values were determined experimentally
        if (result == 'winner')
            body1.x = 420;
        else if (result == 'loser')
            body1.x = 195;
        else if (result == 'tie') {
            body1.x = 420;
            body2.x = 195;
        }

        // Since the cards have the same y-value after being selected, the explosions do too
        body1.y = 145;
        body2.y = 145;

        // Add a frame script to hide the explosions after the animation is done playing
        body1.addFrameScript(10, () -> body1.visible = false);
        body2.addFrameScript(10, () -> body2.visible = false);

        // Make the explosion visible and have it play
        body1.visible = true;
        body1.gotoAndPlay(1);

        // Only if there is a tie do we show the second explosion
        if (result == 'tie') {
            body2.visible = true;
            body2.gotoAndPlay(1);
        }
    }
}