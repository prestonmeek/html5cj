import WebSocket, { WebSocketServer } from 'ws'

// If you need to kill all ports: killall -9 node

// Packet structure
interface Packet {
    type: string,
    [key: string]: string
}

// Extend the WebSocket type with any optional parameters we may need
interface Client extends WebSocket {
    ready: boolean
}

class Server extends WebSocketServer {
    queue: Client[]

    constructor(port: number) {
        super({ port: port })

        console.log(`The WebSocket server is running on port ${port}`)

        this.queue = []

        this.handleEvents()
    }

    handleEvents(): void {
        this.on('connection', (ws: Client) => {
            // Make sure the socket is NOT ready yet
            ws.ready = false
            this.queue.push(ws)

            console.log(`Added connected client to queue. Length: ${this.queue.length}`)

            // Tell the client that tey have to wait for another player to start a match
            this.sendPacket(ws, 'wait')
            
            // If the queue length is 2, we can have the clients query for each other's name
            if (this.queue.length == 2)
                this.broadcastToQueue('get enemy username')

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

    sendPacket(ws: Client, type: string, args?: {[key: string]: string}): void {
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

    broadcastToQueue(type: string, args?: {[key: string]: string}): void {
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
            // A queue will always have exactly 2 clients when full
            // We have to retrieve the second client's name from the first client, and vice versa
            // This receives a client's name, stores it, and then sends the name to the other/second client
            case 'send enemy username':
                // Get the index of the queue in which we send the packet to
                // If the current client is at index 0, send it to the one at index 1, and vice versa
                let sendingIndex: number = this.queue.indexOf(ws) == 0 ? 1 : 0

                // TODO: change the random usernames to be data['name']
                // We use the random names here just for clear testing (since login doesn't exist yet)
                this.sendPacket(this.queue[sendingIndex], 'set enemy username', { 'name': sendingIndex == 0 ? 'Jackie' : 'Tent' })

                break

            // This client is fully ready to start the battle
            case 'ready':
                ws.ready = true

                // If both clients are ready, begin the game
                if (this.queue[0].ready && this.queue[1].ready)
                    this.broadcastToQueue('begin')

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