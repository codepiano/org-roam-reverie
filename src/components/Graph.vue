<template>
  <div id="graph" />
</template>

<script>

import cytoscape from 'cytoscape'
import {getData} from '@/js/axios'

export default {
  name: 'Graph',
  methods: {
    createCytoscape() {
      cytoscape.warnings(false);
      const cy = cytoscape({
        container: document.getElementById('graph'),
        boxSelectionEnabled: false,
        userZoomingEnabled: false, //滚轮缩放
        wheelSensitivity: 0.1,
        autounselectify: false,
        autoungrabify: true,
        layout: {
          name: 'breadthfirst',
        },
        minZoom: 0.3,
        style: [{
          selector: 'node',
          style: {
            'content': 'data(id)',
            'text-opacity': 0.5,
            "height": 40,
            "width": 40,
            'pie-size': '100%',
            'text-valign': 'center',
            'text-halign': 'left',
          }
        },
          {
            selector: ':parent',
            css: {
              'text-valign': 'top',
              'text-halign': 'center',
            }
          },
          {
            selector: 'edge',
            style: {
              width: 3,
              label: 'data(label)',
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
