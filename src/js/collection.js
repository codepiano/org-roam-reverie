export const differenceArray = (a, b) => {
    // 返回 Set
    if (!a || !b) {
        throw(new Error('param empty'))
    }
    return differenceSet(new Set(a), new Set(b))
}

export const differenceSet = (setA, setB) => {
    let _difference = new Set(setA)
    for (let elem of setB) {
        _difference.delete(elem)
    }
    return _difference
}

export const symmetricDifference = (setA, setB) => {
    let _difference = new Set(setA)
    for (let elem of setB) {
        if (_difference.has(elem)) {
            _difference.delete(elem)
        } else {
            _difference.add(elem)
        }
    }
    return _difference
}


export const arrayValueEqual = (a, b) => {
    if (a == null || b == null) {
        return a === b
    }
    let as = new Set(a), bs = new Set(b)
    return symmetricDifference(as, bs).size === 0
}

export const setCompare = (a, b) => {
    let as = new Set(a), bs = new Set(b)
    let differLeft = differenceSet(as, bs)
    let differRight = differenceSet(bs, as)
    if (differLeft.size === 0 && differRight.size === 0) {
        // 相等
        return 0
    } else if (differLeft.size !== 0 && differRight.size === 0) {
        // a 包含 b
        return 1
    } else if (differLeft.size === 0 && differRight.size !== 0) {
        // b 包含 a
        return 2
    } else {
        // 双方都不包含对方
        return 3
    }
}

