import axios from 'axios';
import {server} from './config.js'

export const getNetworkData = axios({
    method: 'get',
    url: `${server.url}:${server.port}/roam-data`
})
