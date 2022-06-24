import WebSocket, { WebSocketServer } from 'ws'
import { v4 as uuid } from 'uuid'

// If you need to kill all ports: killall -9 node

// Packet structures
type PacketData = string | Number[]

interface Packet {
    type: string,
    [key: string]: PacketData
}

// Extend the WebSocket type with any optional parameters we may need
interface Client extends WebSocket {
    username: string,
    deck: Array<Number>
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

        console.log(data);

        ws.send(
            JSON.stringify(data)
        )
    }

    broadcastToQueue(type: string, args?: { [key: string]: PacketData }): void {
        this.queue.forEach(ws => this.sendPacket(ws, type, args))
    }

    handlePacket(ws: Client, packet: string) {
        console.log(`Client has sent us: ${packet}`)

        // Parse the stringified JSON into an object
        let data: Packet = JSON.parse(packet)

        // If the packet doesn't have a 'type', just return
        if (!('type' in data))
            return

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

                    // Reset the queue and add the two clients to a room
                    // We use [...] notation to copy the array instead of creating a reference
                    let roomID: string = uuid()
                    this.rooms[roomID] = [...this.queue]
                    this.queue = []

                    this.sendPacket(client1, 'begin', { 
                        'username': client2.username,
                        'deck': client2.deck,
                        'room ID': roomID
                    })

                    this.sendPacket(client2, 'begin', { 
                        'username': client1.username,
                        'deck': client1.deck,
                        'room ID': roomID
                    })

                    // TODO: Reset the queue and store the 2 clients in a room
                }

                break

            case 'selected card':
                console.log(data)

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

new Server(8080)