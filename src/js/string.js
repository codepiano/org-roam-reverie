export const linewrap = (line, chunkSize) => {
    if (line.length <= chunkSize) {
        return line
    }
    let result = line.slice(0, chunkSize-1)
    for (let i = chunkSize - 1; i < line.length; i++) {
        let c = line.charAt(i)
        if (isNumberOrLetter(c)) {
            result += c
        } else {
            result += "\n" + line.slice(i, i + chunkSize)
            i += chunkSize
        }
    }
    return result
}

// english letter only
const isNumberOrLetter = (c) => {
    return ((c >= 'a' && c <= 'z') ||
        (c >= 'A' && c <= 'Z') ||
        (c >= '0' && c <= '9'))
}
