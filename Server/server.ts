import WebSocket, { WebSocketServer } from 'ws'
import { v4 as uuid } from 'uuid'

// If you need to kill all ports: killall -9 node

// Packet structures
type PacketData = string | Number | Number[]

interface Packet {
    type: string,
    [key: string]: PacketData
}

// Card choice structure
interface CardChoice {
    indexInDeck: Number,
    power: Number,
    element: string
}

// Extend the WebSocket type with any optional parameters we may need
interface Client extends WebSocket {
    username: string,
    deck: Array<Number>,
    ready: boolean,
    index: Number,
    roomID: string
    cardChoice: CardChoice | null
}

class Server extends WebSocketServer {
    queue: Client[]
    rooms: { [id: string]: Client[] }

    constructor(port: number) {
        super({ port: port })

        console.log(`The WebSocket server is running on port ${port}`)

        this.queue = []
        this.rooms = {}

        this.handleEvents()
    }

    handleEvents(): void {
        this.on('connection', (ws: Client) => {
            this.queue.push(ws)

            console.log(`Added connected client to queue. Length: ${this.queue.length}`)

            ws.on('message', (packet: string) => this.handlePacket(ws, packet))

            ws.on('close', () => {
                // TODO: remove clients in rooms from rooms, not the queue array (since they left the queue)
                removeFromArray(this.queue, ws)
                console.log(`Removed disconnected client from queue. Length: ${this.queue.length}`)
            })

            // handling client connection error
            ws.on('error', () => {
                console.error('An error occurred')
            })
        })
    }

    sendPacket(ws: Client, type: string, args?: { [key: string]: PacketData }): void {
        // Join the type of the packet with its arguments
        // Same as Object.assign(), just a bit more of a modern approach ig
        let data: Packet = { 
            ...{ 'type': type },
            ...args
        }

        ws.send(
            JSON.stringify(data)
        )
    }

    broadcastToQueue(type: string, args?: { [key: string]: PacketData }): void {
        this.queue.forEach(ws => this.sendPacket(ws, type, args))
    }

    broadcastToRoom(type: string, roomID: string, args?: { [key: string]: PacketData }): void {
        if (roomID in this.rooms)
            this.rooms[roomID].forEach(ws => this.sendPacket(ws, type, args))
    }

    handlePacket(ws: Client, packet: string) {
        console.log(`Client has sent us: ${packet}`)

        // Parse the stringified JSON into an object
        let data: Packet = JSON.parse(packet)

        // If the packet doesn't have a 'type', just return
        if (!('type' in data))
            return

        // If the current client is in a room, define the otherClient variable here for ease of use
        // We give it the default value of the client in order to ignore errors of the variable not being assigned
        // This shouldn't be an issue, though, as this is checked in each packet handler when it is used
        let otherClient: Client = ws

        if (ws.roomID != null)
            // Get the other client based on the room index of the current client
            // If the current client's index is 0, the other client's is 1, and vice versa
            otherClient = this.rooms[ws.roomID][ws.index == 1 ? 0 : 1]

        switch (data['type']) {
            // When the client connects to the server, we receive its important data
            // We then store this for later use, most importantly sending it to the other client in the queue
            case 'store client data':
                // Store the username and deck
                ws.username = data['username'] as string
                ws.deck     = data['deck']     as Number[]

                // A queue will always have exactly 2 clients when full
                // If the queue length is 2, meaning it is full, we can tell both clients to begin their match
                // In this packet, we also send the username and deck to the other client
                // This way, each client has the data for BOTH clients
                if (this.queue.length == 2) {
                    let client1: Client = this.queue[0]
                    let client2: Client = this.queue[1]

                    // Store the index in which the client appears in the queue/room
                    // This allows for easy differentiation of the two clients in a room just given a room ID
                    client1.index = 0
                    client2.index = 1

                    // Also store the room ID in both clients
                    let roomID: string = uuid()

                    client1.roomID = roomID
                    client2.roomID = roomID

                    // Reset the queue and add the two clients to a room
                    // We use [...] notation to copy the array instead of creating a reference
                    this.rooms[roomID] = [...this.queue]
                    this.queue = []

                    this.sendPacket(client1, 'begin match', { 
                        'username': client2.username,
                        'deck': client2.deck,
                        'room ID': roomID
                    })

                    this.sendPacket(client2, 'begin match', { 
                        'username': client1.username,
                        'deck': client1.deck,
                        'room ID': roomID
                    })
                }

                break

            // The client is ready to begin card selection
            case 'ready for card selection':
                ws.ready = true

                // If the other client has the default value of the client (the other client was not properly assigned), return
                if (otherClient == ws)
                    return

                // Once both clients are ready, tell both to begin card selection
                // We also want to reset the ready attribute on both clients for later use
                // We make sure both clients are in the same room
                if (ws.ready && otherClient.ready && ws.roomID == otherClient.roomID) {
                    ws.ready = false
                    otherClient.ready = false

                    this.broadcastToRoom('begin card selection', ws.roomID)
                }

                break

            // The client has selected a card
            case 'selected card':
                // If the client is not in a room or the room doesn't have exactly 2 clients, return
                if (!ws.roomID || this.rooms[ws.roomID].length != 2)
                    return

                // If the other client has the default value of the client (the other client was not properly assigned), return
                // Also return if the clients are not in the same room
                if (otherClient == ws || ws.roomID != otherClient.roomID)
                    return

                // Store the card choice data
                ws.cardChoice = {
                    'indexInDeck': data['index in deck'] as Number,
                    'power': data['power'] as Number,
                    'element': data['element'] as string
                }

                // Show the other client that a card has been selected by the first client
                this.sendPacket(otherClient, 'show card selection', { 'index in deck': ws.cardChoice.indexInDeck })

                // If both clients have selected a card, we need to figure out who won
                if (ws.cardChoice != null && otherClient.cardChoice != null) {
                    let winner: string = determineWinner(ws.cardChoice, otherClient.cardChoice)

                    // Reset the card choices so this process can happen again
                    ws.cardChoice = null
                    otherClient.cardChoice = null

                    // If the client won, tell the client they are the winner and the other client the loser
                    // If the client lost, do the opposite
                    if (winner == 'client') {
                        this.sendPacket(ws, 'round over', {
                            'result': 'winner'
                        })

                        this.sendPacket(otherClient, 'round over', {
                            'result': 'loser'
                        })
                    } else if (winner == 'other client') {
                        this.sendPacket(otherClient, 'round over', {
                            'result': 'winner'
                        })

                        this.sendPacket(ws, 'round over', {
                            'result': 'loser'
                        })
                    } else if (winner == 'tie') {
                        this.broadcastToRoom('round over', ws.roomID, { 
                            'result': 'tie'
                        })
                    }
                }

                break

            // The client is ready to resume the match
            case 'ready to resume match':
                ws.ready = true

                // If the other client has the default value of the client (the other client was not properly assigned), return
                if (otherClient == ws)
                    return

                // Once both clients are ready, tell both to resume card selection
                // We also want to reset the ready attribute on both clients for later use
                // We make sure both clients are in the same room
                if (ws.ready && otherClient.ready && ws.roomID == otherClient.roomID) {
                    ws.ready = false
                    otherClient.ready = false

                    this.broadcastToRoom('resume card selection', ws.roomID)
                }

                break

            // An unknown packet is being handled
            default:
                console.warn('Unhandled packet type: ' + data['type'])
        }
    }
}

function removeFromArray<T>(array: T[], value: T) {
    var idx = array.indexOf(value)

    if (idx !== -1)
        array.splice(idx, 1)
    
    return array
}

// Returns a string of the result of the round
function determineWinner(client: CardChoice, otherClient: CardChoice) : string {
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

new Server(8080)