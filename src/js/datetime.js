export const timestampToLocalString = (timestamp) => {
    return new Date(timestamp).toLocaleString()
}

export const formatTimestamp = timestampToLocalString