<template>
  <el-dialog title="所有节点" v-model="dialogVisible" @close="$emit('nodeViewerClose', true)" fullscreen>
    <NodeTable></NodeTable>
  </el-dialog>
</template>

<script>
import NodeTable from "@/components/NodeTable.vue";

export default {
  name: "NodeViewer",
  components: {NodeTable},
  emits: ['nodeViewerClose'],
  props: {
    visible: Boolean,
  },
  data() {
    return {
      dialogVisible: false,
    }
  },
  methods: {},
  watch: {
    visible() {
      this.dialogVisible = this.visible
    }
  }
}
</script>

<style scoped>

</style>