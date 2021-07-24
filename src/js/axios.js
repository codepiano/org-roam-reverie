import axios from 'axios';
import {server} from './config.js'

export const getNetworkData = axios({
    method: 'get',
    url: `${server.url}:${server.port}/roam-data`
})

export const getNetworkOptions = axios({
    method: 'get',
    url: `${server.url}:${server.port}/roam-network-options`
})

export const getFileChangeInfo = axios({
    method: 'get',
    url: `${server.url}:${server.port}/roam-check-file-change`
})

export const getFileChanges = (version) => {
    return axios({
        method: 'get',
        url: `${server.url}:${server.port}/roam-get-file-changes?version=${version}`
    })
}
