import axios from 'axios';
import {server} from './config.js'

export const getNetworkData = () => {
    return axios({
        method: 'get',
        url: `${server.url}:${server.port}/roam-data`
    })
}

export const getNetworkOptions = () => {
    return axios({
        method: 'get',
        url: `${server.url}:${server.port}/roam-network-options`
    })
}

export const getFileInfo = () => {
    return axios({
        method: 'get',
        url: `${server.url}:${server.port}/roam-get-file-changes`
    })
}

export const getFileChanges = (version) => {
    return axios({
        method: 'get',
        url: `${server.url}:${server.port}/roam-recent-changes?version=${version}`
    })
}
