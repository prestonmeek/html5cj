export function removeFromArray<T>(array: T[], value: T) {
    var idx = array.indexOf(value)

    if (idx !== -1)
        array.splice(idx, 1)
    
    return array
}