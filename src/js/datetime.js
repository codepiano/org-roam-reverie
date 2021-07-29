import { format } from 'date-fns'

export const timestampToLocalString = (timestamp) => {
    return new Date(timestamp).toLocaleString()
}

export const formatTimestamp = (timestamp) => {
    format(timestamp, "YYYY-MM-dd HH:mm:ss")
}
