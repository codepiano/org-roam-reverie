import * as mutationConst from "./store_mutation_const.js"
import Vuex from 'vuex'

const nodesData = {
    state: () => ({
        nodesMap: new Map(),
        nodesMapChanged: 0,
        aliasMap: new Map(),
    }),
    mutations: {
        [mutationConst.SetNodeMap](state, map) {
            state.nodesMap = map
            state.nodesMapChanged++
        },
        [mutationConst.MergeNodeMap](state, map) {
            map.forEach((k, v) => {
                state.nodesMap.set(k, v)
            })
            state.nodesMapChanged++
        },
        [mutationConst.SetAliasMap](state, map) {
            state.aliasMap = map
        },
    },
}

const store = new Vuex.Store({
    modules: {
        nodesData: nodesData,
    }
})

export default store
