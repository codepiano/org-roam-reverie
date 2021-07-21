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
