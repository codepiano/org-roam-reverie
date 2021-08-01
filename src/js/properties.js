const ProcessorMap = new Map([
    ['REVERIE.NODE.SHAPE', (node, x) => node.shape = x],
    ['REVERIE.NODE.ICON', nodeIcon],
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

function nodeIcon(node, x) {
    if (!x) {
        return
    }
    let values = x.split('_')
    node.shape = 'icon'
    let code = values[0]
    if (!code.startsWith('0x')) {
        code = `0x${code}`
    }
    node.icon = {
        face: "'Font Awesome 5 Free'",
        weight: "bold",
        code: String.fromCharCode(code),
    }
    if (values.length > 1) {
        let size = parseInt(values[1])
        if (isNaN(size)) {
            node.icon.color = values[1]
        } else {
            node.icon.size = size
        }
    }
    if (values.length > 2) {
        node.icon.color = values[2]
    }
}

export const propertiesExtend = (node, key, value) => {
    if (ProcessorMap.has(key)) {
        ProcessorMap.get(key).call(this, node, value)
    }
}
