import WebSocket from 'ws'
import { Card, ElementColors } from "./game";
import { Packet, PacketData } from './server';

// Extend the WebSocket type with any optional parameters we may need
export interface Client extends WebSocket {
    username: string,
    deck: Array<Number>,
    ready: boolean,
    index: Number,
    roomID: string,
    cardChoice: Card | null,
    elementColors: ElementColors,
}

export function sendPacket(ws: Client, type: string, args?: { [key: string]: PacketData }): void {
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