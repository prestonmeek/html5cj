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
        this.cards = [for (i in 0...5) new Card(game, Random.int(0, 1))];
    }

    // Setup all the cards to be displayed
    // TODO: add enemy functionality
    public function setup():Void {
        if (type == Player) {
            for (card in cards)
                card.setup();
        }
    }

    // Show all the cards
    // We do this using a timer so each card is on a slight delay
    // TODO: add enemy functionality
    public function show():Void {
        if (type == Player) {
            var timer:Timer = new Timer(100);

            var i:Int = 0;

            timer.run = () -> {
                // Show the current card
                // We pass in the index so that it knows where to be positioned on the screen
                trace(i);
                cards[i].show(i);

                // If we have gone through all the cards, break (this is when i is exactly one less than the "cards" array length)
                // Otherwise, increment i
                if (i == cards.length - 1)
                    timer.stop();
                else
                    i++;
            }
        }
    }
}