export const title = (node, title) => {
    let result = false
    if (node.title.includes(title)) {
        result = true
    } else if (node.aliases) {
        result = node.aliases.some(y => y.includes(title))
    }
    return result
}

export const tag = (node, tags) => {
    if (node.tags) {
        return node.tags.some(x => tags.has(x))
    }
    return false
}

export const Title = 'TITLE'
export const Left = 'LEFT'
export const Right = 'RIGHT'

export const filterMap = new Map(
    [
        [Title, title],
        [Left, tag],
        [Right, tag]
    ])


