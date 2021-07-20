<template>
  <div id="network" />
</template>

<script>

import { DataSet, DataView } from "vis-data/peer";
import { Network } from "vis-network/peer";
import "vis-network/styles/vis-network.css";
import {getNetworkData} from '@/js/axios'

let nodeDataset = new DataSet();
let edgeDataset = new DataSet();

export default {
  name: 'Graph',
  methods: {
    initNetwork() {
      let option ={
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
      globalNetwork.once('startStabilizing', function() {
        let scaleOption = { scale : 0.2 };
        globalNetwork.moveTo(scaleOption);
      })
      globalNetwork.once('afterDrawing', () => {
        document.getElementById("network").style.height = '100vh'
      })
      getNetworkData.then(function (response) {
        if (response.status !== 200) {
          return []
        }
        let networkData = response.data
        nodeDataset.update(networkData.nodes)
        edgeDataset.update(networkData.edges)
      }).catch(function (error) {
        console.log(error)
        return []
      });
    },
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
