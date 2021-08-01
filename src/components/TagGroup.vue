<template>
  <div>
    <el-collapse>
      <el-collapse-item v-for="tag in tags" :title=tag :name=tag>
        <NodeTable :tableKey=tag @sortTable="sortTable" :currentPageData="currentPageData(tag)"
                   @handleClick="handleClick" @handleView="handleView"/>
      </el-collapse-item>
    </el-collapse>
    <el-dialog
        title="节点详细信息"
        v-model="dialogVisible" width="80%">
      <NodeInfo :node="currentRow"></NodeInfo>
    </el-dialog>
  </div>
</template>

<script>
import {openRoamProtocol} from '@/js/org'
import NodeInfo from "@/components/NodeInfo.vue";
import NodeTable from "@/components/NodeTable.vue";

export default {
  name: "TagGroup",
  components: {NodeInfo, NodeTable},
  data() {
    return {
      tagNodes: new Map(),
      unwatchNodesChange: null,
      currentRow: {},
      dialogVisible: false
    }
  },
  methods: {
    currentPageData(tag) {
      if (this.tagNodes.has(tag)) {
        return this.tagNodes.get(tag)
      } else {
        return []
      }
    },
    initTagNodeMap(add) {
      let tagNodes = new Map()
      this.$store.state.nodesData.nodesMap.forEach((v, k) => {
        if (!v.tags || v.tags.length === 0) {
          return
        }
        v.tags.forEach(x => {
          if (tagNodes.has(x)) {
            tagNodes.get(x).push(v)
          } else {
            tagNodes.set(x, [v])
          }
        })
      })
      this.tagNodes = tagNodes
    },
    handleView({index, row}) {
      this.currentRow = row
      this.dialogVisible = true
    },
    handleClick({index, row}) {
      if (row) {
        openRoamProtocol(row.id)
      }
    },
    sortTable(data) {
      let {prop, order, key} = data
      let comparator = null
      if (prop === "createdTimeString") {
        if (order === "ascending") {
          comparator = (x, y) => x.createdTime - y.createdTime
        } else if (order === "descending") {
          comparator = (x, y) => y.createdTime - x.createdTime
        }
        if (this.tagNodes.has(key)) {
          this.tagNodes.get(key).sort(comparator)
        }
      }
    }
  },
  computed: {
    tags() {
      return this.$store.state.nodesData.tagSet
    },
  },
  created() {
    this.initTagNodeMap()
    this.unwatchNodesChange = this.$store.watch((state) => state.nodesData.nodesMapChanged, () => {
      this.initTagNodeMap()
    })
  }, beforeUnmount() {
    if (this.unwatchNodesChange) {
      this.unwatchNodesChange()
    }
  }
}
</script>

<style scoped>

</style>