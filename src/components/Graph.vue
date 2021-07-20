<template>
  <div id="graph" />
</template>

<script>

import cytoscape from 'cytoscape'
import cola from 'cytoscape-cola'
import {getData} from '@/js/axios'

export default {
  name: 'Graph',
  methods: {
    createCytoscape() {

      cytoscape.use(cola);
      const cy = cytoscape({
        container: document.getElementById('graph'),
        boxSelectionEnabled: false,
        userZoomingEnabled: true, //滚轮缩放
        layout: {
          name: 'cola',
          nodeDimensionsIncludeLabels: true,
        },
        style: [{
          selector: 'node',
          style: {
            'content': 'data(title)',
            'pie-size': '100%',
            'text-wrap': "wrap",
            'text-max-width': "150",
            'text-overflow-wrap': "anywhere",
            'text-justification': "center",
            'text-valign': 'center',
            'text-halign': 'left',
          }
        },
          {
            selector: 'edge',
            style: {
              width: 3,
              'target-arrow-shape': 'triangle',
              'line-color': '#9dbaea',
              'target-arrow-color': '#9dbaea',
              'curve-style': 'bezier',
            }
          },

        ],
        elements: Promise.resolve(getData),
      });
    },
  },
  mounted() {
    this.createCytoscape()
  }
}
</script>

<style scoped>
  #graph {
    height: 1000px;
  }
</style>
