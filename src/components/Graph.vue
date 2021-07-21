<template>
  <div id="network"/>
</template>

<script>

import {DataSet, DataView} from "vis-data/peer";
import {Network} from "vis-network/peer";
import "vis-network/styles/vis-network.css";
import {getNetworkData, getNetworkOptions} from '@/js/axios'
import {visNetworkDefault} from '@/js/config'

let nodeDataset = new DataSet();
let edgeDataset = new DataSet();
let edgesMap = new Map()
let nodesMap = new Map()

export default {
  name: 'Graph',
  data() {
    return {
      drawer: false,
      direction: 'rtl',
    }
  },
  methods: {
    // load data, init network
    initNetwork() {
      // default options
      let option = {
        height: '100%',
        width: '100%',
        nodes: {shape: "dot"},
        interaction: {hover: true},
        layout: {improvedLayout: true},
        physics: {
          solver: "forceAtlas2Based",
          forceAtlas2Based: {
            gravitationalConstant: -200,
            centralGravity: 0.01,
            springConstant: 0.56,
            damping: 1,
            avoidOverlap: 0.8
          }
        },
        edges: {
          smooth: {type: "continuous"}
        }
      }
      let view = new DataView(nodeDataset, {})
      let globalNetwork = new Network(document.getElementById("network"), {
            nodes: view,
            edges: edgeDataset
          },
          option);
      globalNetwork.once('startStabilizing', () => {
        let scaleOption = {scale: 0.05};
        globalNetwork.moveTo(scaleOption);
      })
      globalNetwork.once('afterDrawing', () => {
        document.getElementById("network").style.height = '100vh'
      })

      let that = this
      // get options and data from server
      let networkOption = null
      getNetworkOptions.then(function (response) {
        if (response.status !== 200) {
          return
        }
        networkOption = response.data
        return getNetworkData
      }).then(function (response) {
        if (response.status !== 200) {
          return
        }
        let networkData = response.data
        let nodes = networkData.nodes
        if (networkOption.autoGroup) {
          that.initNodesMap(nodes)
          that.initEdgesMap(networkData.edges)
          that.initNodeValueByEdgesMap(nodes)
          that.initNodeGroupByNodeValue(nodes)
        }
        nodeDataset.update(nodes)
        edgeDataset.update(networkData.edges)
      }).catch(function (error) {
        console.log(error)
        return []
      });
    },
    initNodeValueByEdgesMap(nodes) {
      // init node value with direct edges count
      if (edgesMap.size === 0) {
        console.log('edges map empty')
        return
      }
      nodes.forEach((node) => {
        if (edgesMap.has(node.id)) {
          node.value = visNetworkDefault.nodeScalingMin + edgesMap.get(node.id).length
        } else {
          node.value = visNetworkDefault.nodeScalingMin
        }
      })
    },
    initNodeGroupByNodeValue(nodes) {
      nodes = nodes.sort((x, y) => x.value - y.value)
      let group = 0;
      nodes.forEach((node) => {
        if (!node.group) {
          let connectedNodeIds = edgesMap.get(node.id)

          if (connectedNodeIds && connectedNodeIds.length > 0) {
            let maxNodeValue = 0
            let maxNodeId = null
            connectedNodeIds.forEach((nodeId) => {
              if (!nodesMap.has(nodeId)) {
                return
              }
              let connectedNode = nodesMap.get(nodeId)
              if (connectedNode.value > maxNodeValue) {
                maxNodeValue = connectedNode.value
                maxNodeId = connectedNode.id
              }
            })
            let maxNode = nodesMap.get(maxNodeId)
            if (!maxNode.group) {
              maxNode.group = group
              group += 1
            }
            node.group = maxNode.group
          } else {
            node.group = group
            group += 1
          }
        }
      })
    },
    initEdgesMap(edges) {
      // init node relations
      edgesMap.clear()
      edges.forEach((edge) => {
        let from = edge.from
        let to = edge.to
        if (edgesMap.has(from)) {
          edgesMap.get(from).push(to)
        } else {
          edgesMap.set(from, [to])
        }
        if (edgesMap.has(to)) {
          edgesMap.get(to).push(from)
        } else {
          edgesMap.set(to, [from])
        }
      })
    },
    initNodesMap(nodes) {
      nodesMap.clear()
      nodes.forEach((node) => {
        nodesMap.set(node.id, node)
      })
    }
    // method ends
  },
  mounted() {
    this.initNetwork()
  }
}
</script>

<style scoped>
#network {
}
</style>
