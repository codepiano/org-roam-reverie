const ProcessorMap = new Map([
    ['REVERIE.NODE.SHAPE', (node, x) => node.shape = x],
    ['REVERIE.NODE.SIZE', (node, x) => node.size = parseInt(x)],
    ['REVERIE.NODE.COLOR', (node, x) => {
        node.color = {
            border: x,
            background: x,
            highlight: {
                border: x,
                background: x
            },
            hover: {
                border: x,
                background: x
            }
        }
    }]
])

export const propertiesExtend = (node, key, value) => {
    if (ProcessorMap.has(key)) {
        ProcessorMap.get(key).call(this, node, value)
    }
}
