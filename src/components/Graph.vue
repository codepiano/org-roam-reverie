<template>
  <div>
    <div id="network"/>
    <el-button id="btn-setting" @click="drawer = true" type="primary" icon="el-icon-setting" circle
               size="mini"></el-button>
    <div id="node-selector">
      <NodeSelector ref="nodeSelector" v-on:selectTitle="moveToNode" :nodes-map="nodesMap"/>
    </div>
    <el-drawer title="我是标题" v-model="drawer" :direction="direction">
      <span>我来啦!</span>
    </el-drawer>
  </div>
</template>

<script>

import {DataSet, DataView} from "vis-data/peer";
import {Network} from "vis-network/peer";
import {differenceSet} from "@/js/collection"
import "vis-network/styles/vis-network.css";
import {getNetworkData, getNetworkOptions, getFileInfo, getFileChanges} from '@/js/axios'
import mitt from 'mitt'

import {visNetworkDefault} from '@/js/config'
import NodeSelector from "@/components/NodeSelector.vue";

/**
 * 需要更新的数据
 * nodeDataset vis-network 节点数据
 * edgeDataset vis-network 连接数据
 * edgesMap <nodeId, <nodeId>> ，每个节点 id 连接的 id set
 * this.nodesMap <nodeId, node>，每个节点 id 对应的节点对象
 */

let nodeDataset = new DataSet();
let edgeDataset = new DataSet();
let edgesMap = new Map()
let globalNetwork = null;

const emitter = mitt()

export default {
  name: 'Graph',
  components: {NodeSelector},
  data() {
    return {
      drawer: false,
      direction: 'rtl',
      nodesMap: new Map(),
      version: 0,
    }
  },
  methods: {
    // load data, init network
    initNetwork() {
      // default network options
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
      // resize canvas
      globalNetwork.once('afterDrawing', () => {
        document.getElementById("network").style.height = '100vh'
      })
      // add node click event
      globalNetwork.on("selectNode", this.openRoamProtocol)


      // let count = 1
      // globalNetwork.on("stabilizationProgress", () => console.log('doing'))
      globalNetwork.on("stabilized", () => console.log('graph physical stabilized'))
      // globalNetwork.on("resize", () => console.log('resize'))
      // globalNetwork.on("initRedraw", () => console.log('initRedraw' + count++))
      // globalNetwork.on("beforeDrawing", () => console.log('beforeDrawing'))
      //
      // globalNetwork.on("afterDrawing", () => console.log('afterDrawing'))
      // globalNetwork.on("animationFinished", () => console.log('animationFinished'))

      // get options and data from server
      let networkOption = null
      getNetworkOptions().then(response => {
        networkOption = response.data
        return getNetworkData()
      }).then(response => {
        let networkData = response.data
        let nodes = networkData.nodes
        // init nodesMap and version
        let {nodesMap, version} = this.initNodesMapAndVersion(nodes)
        this.nodesMap = nodesMap
        this.version = version
        // init edgesMap
        edgesMap = this.initEdgesMap(networkData.edges)
        this.initNodeValueByEdgesMap(nodes)
        if (networkOption.autoGroup) {
          // this.initNodeGroupByNodeValue(nodes)
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
          node.value = visNetworkDefault.nodeScalingMin + edgesMap.get(node.id).size
        } else {
          node.value = visNetworkDefault.nodeScalingMin
        }
      })
    },
    initNodeGroupByNodeValue(nodes) {
      // init group by direct link number
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
      if (!edges) {
        return
      }
      let edgesMap = new Map()
      edges.forEach((edge) => {
        let from = edge.from
        let to = edge.to
        if (edgesMap.has(from)) {
          edgesMap.get(from).add(to)
        } else {
          edgesMap.set(from, new Set().add(to))
        }
        if (edgesMap.has(to)) {
          edgesMap.get(to).add(from)
        } else {
          edgesMap.set(to, new Set().add(from))
        }
      })
      return edgesMap
    },
    initNodesMapAndVersion(nodes) {
      // init <id, node> map, set max file modified time
      let nodesMap = new Map()
      let version = 0
      nodes.forEach((node) => {
        if (node.fileModifiedTime > version) {
          version = node.fileModifiedTime
        }
        nodesMap.set(node.id, node)
      })
      return {
        nodesMap: nodesMap,
        version: version
      }
    },
    moveToNode(nodeId) {
      // move view, focus specific node
      if (!nodeId) {
        return
      }
      globalNetwork.focus(nodeId, {
        "animation": true
      })
      globalNetwork.selectNodes([nodeId])
    },
    openRoamProtocol(data) {
      // open org-roam protocol
      if (data.nodes.length !== 1) {
        return
      }
      let nodeId = data.nodes[0]
      let url = `org-protocol://roam-node?node=${nodeId}`
      window.open(url, "_self")
    },
    updateLinks(changedNodes, changedEdges) {
      // 通过和 node 原 link 数据 diff，来判断新增、删除，同时需要修改对向数据
      // todo v2.0 改造 org-roam，加入通知机制
      changedNodes.forEach((node) => {
        let originEdges = edgesMap.get(node.id)
        let currentEdges = changedEdges.get(node.id)
        // 更新node link的另一端
        // 移除的关系，需要到被移除方的数据中删除
        let deleted = differenceSet(originEdges, currentEdges)
        deleted.forEach((id) => {
          let otherEnd = edgesMap.get(id)
          if (otherEnd && otherEnd.length > 0) {
            edgesMap.get(id).delete(node.id)
          }
        })
        // 从edgeDataset中找到 node 不再连接的 edge，并删除
        let edgesToRemove = edgeDataset.get({
          filter: (item) => {
            return item.from === node.id && deleted.has(item.to)
          }
        })
        edgeDataset.remove(edgesToRemove)
        // 新增的关系，需要到被新增方的数据中增加
        let added = differenceSet(currentEdges, originEdges)
        added.forEach((id) => {
          let otherEnd = edgesMap.get(id)
          if (otherEnd && otherEnd.length > 0) {
            edgesMap.get(id).add(node.id)
          }
        })
        // 更新自身
        edgesMap.set(node.id, currentEdges)
      })
    },
    checkFileChange() {
      getFileInfo().then(response => {
        let data = response.data
        if (data.mtime !== this.version || data.fileNumber !== nodeDataset.length) {
          // mtime 可以识别新增和修改，fileNumber 可以识别删除
          this.version = data.mtime
          console.log(this.version)
          return getFileChanges(this.version).then(response => {
            console.log(this.response)
            let nodes = response.data.nodes
            let links = response.data.links
            if (!nodes || nodes.length === 0) {
              return
            }
            // update edgesMap
            let changedEdgesMap = this.initEdgesMap(links)
            nodes.forEach((node) => {
              // recalculate node id
              if (changedEdgesMap.has(node.id)) {
                node.value = visNetworkDefault.nodeScalingMin + edgesMap.get(node.id).length
              } else {
                node.value = visNetworkDefault.nodeScalingMin
              }
              // update nodesMap
              this.nodesMap.set(node.id, node)
            })
            // update edgesMap
            this.updateLinks(nodes, changedEdgesMap)
            // update graph data
            nodeDataset.update(nodes)
            edgeDataset.update(links)
            // refresh node selector options
            this.$refs.child.NodeSelector.initOptions()
          })
        }
      }).catch((e) => {
        console.log(e)
      })
    }
    // method ends
  },
  mounted() {
    this.initNetwork()
    const timer = setInterval(this.checkFileChange, 60000);
    emitter.on('hook:beforeDestroy', () => {
      if (timer) {
        console.debug("timer destroyed")
        clearInterval(timer)
      }
    })
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
