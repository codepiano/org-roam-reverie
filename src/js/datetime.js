import { format } from 'date-fns'

export const timestampToLocalString = (timestamp) => {
    return new Date(timestamp).toLocaleString()
}

export const formatTimestamp = (timestamp) => {
    return format(timestamp, "yyyy-MM-dd HH:mm:ss")
}
