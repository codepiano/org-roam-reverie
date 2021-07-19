import axios from 'axios';
import {server} from './config.js'

export const getData = axios({
    method: 'get',
    url: `${server.url}:${server.port}/roam-data`
}).then(function (response) {
    if (response.status !== 200) {
        return []
    }
    return response.data
}).catch(function (error) {
    console.log(error)
    return []
});
