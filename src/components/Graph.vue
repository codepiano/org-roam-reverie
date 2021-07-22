<template>
  <div>
    <div id="network"/>
    <el-button id="btn-setting" @click="drawer = true" type="primary" icon="el-icon-setting" circle
               size="mini"></el-button>
    <div id="node-selector" >
      <NodeSelector v-on:selectNode="moveToNode" :nodes-map="nodesMap"/>
    </div>
    <el-drawer title="我是标题" v-model="drawer" :direction="direction">
      <span>我来啦!</span>
    </el-drawer>
  </div>
</template>

<script>

import {DataSet, DataView} from "vis-data/peer";
import {Network} from "vis-network/peer";
import "vis-network/styles/vis-network.css";
import {getNetworkData, getNetworkOptions} from '@/js/axios'
import {visNetworkDefault} from '@/js/config'
import NodeSelector from "@/components/NodeSelector.vue";

let nodeDataset = new DataSet();
let edgeDataset = new DataSet();
let edgesMap = new Map()
let globalNetwork = null;

export default {
  name: 'Graph',
  components: {NodeSelector},
  data() {
    return {
      drawer: false,
      direction: 'rtl',
      nodesMap: new Map()
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
            gravitationalConstant: -500,
            centralGravity: 0.005,
            springConstant: 0.6,
            springLength: 60,
            damping: 1,
            avoidOverlap: 0.5
          },
          maxVelocity: 2000,
          minVelocity: 60,
          stabilization: {
            enabled: true,
          },
          timestep: 0.3,
        },
        edges: {
          smooth: {type: "continuous"}
        }
      }
      let view = new DataView(nodeDataset, {})
      globalNetwork = new Network(document.getElementById("network"), {
            nodes: view,
            edges: edgeDataset
          },
          option);
      globalNetwork.once('startStabilizing', () => {
        let scaleOption = {scale: 0.05};
        globalNetwork.moveTo(scaleOption);
      })
      globalNetwork.once('afterDrawing', () => {
        console.log("after drawing")
        document.getElementById("network").style.height = '100vh'
      })
      globalNetwork.on("stabilizationIterationsDone", function () {
        console.log("stabilizationIterationsDone")
        globalNetwork.setOptions({physics: false});
      });
      // let count = 1
      // globalNetwork.on("stabilizationProgress", () => console.log('doing'))
      // globalNetwork.on("stabilized", () => console.log('done'))
      // globalNetwork.on("resize", () => console.log('resize'))
      // globalNetwork.on("initRedraw", () => console.log('initRedraw' + count++))
      // globalNetwork.on("beforeDrawing", () => console.log('beforeDrawing'))
      //
      // globalNetwork.on("afterDrawing", () => console.log('afterDrawing'))
      // globalNetwork.on("animationFinished", () => console.log('animationFinished'))

      // get options and data from server
      let networkOption = null
      getNetworkOptions.then(response => {
        if (response.status !== 200) {
          return
        }
        networkOption = response.data
        return getNetworkData
      }).then(response => {
        if (response.status !== 200) {
          return
        }
        let networkData = response.data
        let nodes = networkData.nodes
        this.initNodesMap(nodes)
        this.initEdgesMap(networkData.edges)
        this.initNodeValueByEdgesMap(nodes)
        if (networkOption.autoGroup) {
          this.initNodeGroupByNodeValue(nodes)
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
              if (!this.nodesMap.has(nodeId)) {
                return
              }
              let connectedNode = this.nodesMap.get(nodeId)
              if (connectedNode.value > maxNodeValue) {
                maxNodeValue = connectedNode.value
                maxNodeId = connectedNode.id
              }
            })
            let maxNode = this.nodesMap.get(maxNodeId)
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
      let nodesMap = new Map()
      nodes.forEach((node) => {
        nodesMap.set(node.id, node)
      })
      this.nodesMap = nodesMap
    },
    moveToNode: (nodeId)  => {
      console.log(nodeId)
      if (!nodeId) {
        return
      }
      globalNetwork.focus(nodeId, {
        "animation": true
      })
      globalNetwork.selectNodes([nodeId])
    }

    // method ends
  },
  mounted() {
    this.initNetwork()
  }
}
</script>

<style scoped>
#btn-setting {
  position: absolute;
  right: 9px;
  top: 9px;
}

#node-selector {
  position: absolute;
  left: 9px;
  top: 9px;
}
</style>
