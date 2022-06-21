package;

import haxe.Timer;

import Penguin.PenguinType;

class Deck {
    private var game:Main;
    private var type:PenguinType;

    private var cards:Array<Card>;

    public function new(game:Main, type:PenguinType) {
        this.game = game;
        this.type = type;

        // Creates an array with 5 different cards with a random index using array comprehension
        this.cards = [for (i in 0...5) new Card(game, type, Random.int(0, 1))];
    }

    // Setup all the cards to be displayed
    // TODO: add enemy functionality
    public function setup():Void {
        for (card in cards)
            card.setup();
    }

    // Show all the cards on the screen for the first time
    public function show():Void {
        // We do this for the Player using a timer so each card is on a slight delay
        if (type == Player) {
            var timer:Timer = new Timer(100);

            var i:Int = 0;

            timer.run = () -> {
                // Show the current card
                // We pass in the index so that it knows where to be positioned on the screen
                cards[i].show(i);

                // If we have gone through all the cards, break (this is when i is exactly one less than the "cards" array length)
                // We also want to start the clock countdown once all the cards have been shown
                // Otherwise, increment i
                if (i == cards.length - 1) {
                    timer.stop();
                    game.startClock();
                } 
                else
                    i++;
            }
        // For the enemy, there is no delay; all the cards appear at once
        }  else {
            for (i in 0...cards.length)
                cards[i].show(i);
        }
    }
}