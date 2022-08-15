// Card structure
export interface Card {
    indexInDeck: Number,
    power: Number,
    element: string,
    color: string
}

// Element colors structure
// This keeps track of the unique colors for each element
// Since the colors are unique and the order does not matter, we use a set here
export interface ElementColors {
    'fire':  Set<string>,
    'water': Set<string>,
    'snow':  Set<string>
}

// Returns a string of the result of the round
export function determineRoundWinner(client: Card, otherClient: Card) : string {
    // Make sure the elements passed in are valid
    let validElements: string[] = ['fire', 'water', 'snow']

    if (!(validElements.includes(client.element) && validElements.includes(otherClient.element))) {
        console.warn('Invalid element detected when trying to determine the winner')
        return 'ERROR'
    }

    // If the two clients used the same element, go by the power
    if (client.element == otherClient.element) {
        // If the clients have equal power cards AND equal power elements, return a tie
        // If the client has a greater power card, return true
        // Otherwise, return false
        if (client.power == otherClient.power)
            return 'tie'
        else
            return client.power > otherClient.power ? 'client' : 'other client'
    } else {
        // Use a switch statement with the two elements joined together
        // The client comes first, then the other client
        // We will then use string matching for every possible remaining case (6, since we already handled same element cases)
        switch (`${client.element} ${otherClient.element}`) {
            case 'fire water':
                return 'other client'

            case 'fire snow':
                return 'client'

            case 'water snow':
                return 'other client'

            case 'water fire':
                return 'client'

            case 'snow fire':
                return 'other client'

            case 'snow water':
                return 'client'
        }
    }

    // Default return
    console.warn('No winner found when trying to determine the winner')
    return 'ERROR'
}

// Returns a boolean saying if the passed-in card data would constitute winning the match
export function determineMatchWinner(elements: ElementColors) : boolean {
    console.log(elements)
    // The first check for determining a winner is if there are three colors in any element's set
    // Since the set will only have unique colors, we don't have to bother checking this ourselves
    // The second check for determing a winner is if there is a combination of fire, water, and snow with DIFFERENT colors
    // The second check is definitely the more complicated one

    // We use a set with the colors being used for the winning combination
    const winningColors: Set<string> = new Set()

    for (const element in elements) {
        // Get the colors set for the specific element
        const colors: Set<string> = elements[element]

        // If its length is 3 or more (it should never be greater; this is just for safety purposes), we can immediately return true
        if (colors.size >= 3)
            return true

        for (const color of colors) {
            // If the set does not have the current color, add it and break from this loop
            // We only want to use one color for each element, so we have to break after adding one
            if (!winningColors.has(color)) {
                winningColors.add(color)
                break
            }
        }
    }

    console.log(winningColors)

    // If a combination of exactly three elements with unique colors was found, return true
    if (winningColors.size == 3)
        return true

    // Return false by default
    return false
}