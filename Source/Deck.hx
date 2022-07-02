package;

import haxe.Timer;

import openfl.events.MouseEvent;

import Penguin.PenguinType;

class Deck {
    private var game:Main;
    private var type:PenguinType;

    private var cards:Array<Card>;

    private var selectedCard:Card;

    private var removedIndex:Int;

    public function new(game:Main, type:PenguinType) {
        this.game = game;
        this.type = type;
    }

    // We generate the cards array based on the indecies in the passed-in array
    // We use these indecies to read data from the JSON file
    public function generateCards(cardIndecies:Array<Int>):Void {
        // The cardIndecies array must be exactly 5 (a deck will always have 5 cards)
        if (cardIndecies.length != 5)
            return;

        // Generates the cards array using array comprehension
        // This uses the indecies provided in the cardIndecies array, which is then passed to the Card cl
        this.cards = [for (i in 0...5) new Card(game, type, cardIndecies[i])];
    }

    // Setup all the cards to be displayed
    public function setup():Void {
        // The card array length must be exactly 5
        if (cards.length != 5)
            return;

        // We iterate this way instead of for (card in cards) because the index is important
        for (i in 0...cards.length) {
            var card:Card = cards[i];
            
            card.setup();

            // For the player, we also want to add the Deck-specific MouseEvent listener
            // (the main MouseEvent listeners are added in the Card class directly)
            if (type == Player)
                addClickListener(card, i);
        }
    }

    // Add the Deck-specific click event listener to the card
    // This one removes all the mouse events for every card in the deck
    // This is so once a card is clicked, none of the other cards can be clicked or even hovered over
    // This is why the MouseEvents are handled in the Deck class
    // In this click event, we also tell the server that we have selected a card
    private function addClickListener(card:Card, index:Int) {
        card.addEventListener(MouseEvent.CLICK, (event:MouseEvent) -> {
            // We check if the Card body has the ROLL_OVER event listener
            // This is because after the card is clicked, it will no longer have this listener
            // Therefore, if the card DOES have it, then it means this is the first time it has been clicked
            // Thus, we can safely tell the server a card has been selected
            if (card.hasEventListener(MouseEvent.ROLL_OVER)) {
                // Store the selected card
                selectedCard = cards[index];
                
                // Get the power and element type of the card
                // Everything is sent over as a string but the server handles power as a number
                var stats:Map<String, String> = card.getStats();

                // We pass in the index inside the deck so the server knows what card has been selected
                Client.sendPacket('selected card', 
                    { 
                        'index in deck': index,
                        'power': stats['power'],
                        'element': stats['element']
                    } 
                );
            }

            // Remove all other event listeners from the card
            for (card in cards)
                card.removeEventListeners();
        });
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
                } else
                    i++;
            }
        // For the enemy, there is no delay; all the cards appear at once
        }  else {
            for (i in 0...cards.length)
                cards[i].show(i);
        }
    }

    // Store the selected card and show it being selected
    public function selectCard(index:Int):Void {
        selectedCard = cards[index];
        selectedCard.select();
    }

    // Flip the selected card
    // Only flip a card if there is a selected card and we are the Enemy's deck
    public function flipCard(?callback:() -> Void):Void {
        if (type == Enemy && selectedCard != null)
            selectedCard.flip(callback);
    }

    // Remove the currently selected card from the scene
    // This also removes the selected card from the cards array and this.selectedCard
    // We return the selected card in case it needs to be used
    public function removeSelectedCard():Card {
        if (selectedCard != null) {
            // Remove the selected card from the scene
            selectedCard.remove();

            // Store the index of the selected card before we remove it so we can properly replace it later
            removedIndex = this.cards.indexOf(selectedCard);
            this.cards.remove(selectedCard);

            // Store the selected card before we reset it
            var card:Card = selectedCard;
            selectedCard  = null;

            return card;
        }

        // Return no card by default
        return null;
    }

    // Add the important event listeners to all the cards
    // Only do this if we are the Player's deck
    public function addEventListeners():Void {
        if (type == Player) {
            for (card in cards)
                card.addEventListeners();
        }
    }

    // Adds a new card to the deck, replacing the card that was just selected
    public function addNewCard():Void {
        // Create a new card
        // TODO: change the index to a non-arbitrary value (get it from available cards in database probably?)
        var card:Card = new Card(game, type, 1);

        // Setup the card, using the stored removed index for the event listener
        // This is because the removed index will be used as the index of this new card
        card.setup();
        addClickListener(card, removedIndex);

        // Store the card in the array, inserting it at the proper index
        cards.insert(removedIndex, card);

        // Show the card at its new index
        card.show(removedIndex);

        // We only want to restart the clock once, so we check if the deck is the Player's
        // This could also be Enemy here and it would work the same
        if (type == Player)
            game.startClock();
    }
}