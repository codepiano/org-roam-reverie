import * as mutationConst from "./store_mutation_const.js"
import Vuex from 'vuex'

const nodesData = {
    state: () => ({
        nodesMap: new Map(),
        nodesMapChanged: 0,
        tagSet: new Set(),
        tagSetChanged: 0,
    }),
    mutations: {
        [mutationConst.SetNodeMap](state, map) {
            state.nodesMap = map
            state.nodesMapChanged++
        },
        [mutationConst.MergeNodeMap](state, map) {
            map.forEach((v, k) => {
                state.nodesMap.set(k, v)
            })
            state.nodesMapChanged++
        },
        [mutationConst.SetTagSet](state, set) {
            state.tagSet = set
            state.tagSetChanged++
        },
        [mutationConst.MergeTagSet](state, nodesMap) {
            nodesMap.forEach((x)=>{
                if (x.tags && x.tags.length > 0) {
                    x.tags.forEach(y => state.tagSet.add(y))
                }
            })
            state.tagSetChanged++
        },
    },
}

const store = new Vuex.Store({
    modules: {
        nodesData: nodesData,
    }
})

export default store
