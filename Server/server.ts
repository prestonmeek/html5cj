import WebSocket, { WebSocketServer } from 'ws';

// If you need to kill all ports: killall -9 node

class Server extends WebSocketServer {
    queue: WebSocket[]

    constructor(port: number) {
        super({ port: port })

        console.log(`The WebSocket server is running on port ${port}`)

        this.queue = []

        this.handleEvents()
    }

    handleEvents(): void {
        this.on('connection', (ws: WebSocket) => {
            this.queue.push(ws)
            console.log(`Added connected client to queue. Length: ${this.queue.length}`)

            // If the queue length is 1, then we have to wait for another player to start a match
            // If the queue length is 2, we can tell the clients to begin their match
            if (this.queue.length == 1)
                // TODO: CHANGE THIS STRING TO 'wait' -- THIS IS JUST FOR EASY TESTING
                ws.send('begin')
            else if (this.queue.length == 2)
                this.queue.forEach((ws: WebSocket) => ws.send('begin'))

            ws.on('message', data => {
                console.log(`Client has sent us: ${data}`)
            })

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
}

function removeFromArray<T>(array: T[], value: T) {
    var idx = array.indexOf(value)

    if (idx !== -1)
        array.splice(idx, 1)
    
    return array
}

new Server(8080)