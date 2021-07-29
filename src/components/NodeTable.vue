<template>
  <div>
    <el-table size="small" stripe :data="currentPageData">
      <el-table-column property="createdTimeString" label="创建日期" width="150"></el-table-column>
      <el-table-column property="title" label="标题"></el-table-column>
      <el-table-column label="标签">
        <template #default="scope">
          <el-tag size="mini" v-for="tag in scope.row.tags">{{ tag }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作">
        <template #default="scope">
          <el-button
              size="mini"
              @click="handleView(scope.$index, scope.row)">编辑
          </el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        :current-page="currentPage"
        :page-sizes="[100, 200, 300, 400]"
        :page-size="pageSize"
        :pager-count=17
        hide-on-single-page
        layout="total, sizes, prev, pager, next, jumper"
        background
        :total="totalSize">
    </el-pagination>
  </div>
</template>

<script>

export default {
  name: "NodeTable",
  data() {
    return {
      gridData: [],
      pageSize: 50,
      currentPage: 1,
      currentPageData: [],
      unwatchNodesChange: null
    }
  },
  methods: {
    initGridData(added) {
      let gridData = []
      let nodesMap = this.$store.state.nodesData.nodesMap
      for (const x of nodesMap.values()) {
        gridData.push(x)
      }
      this.gridData = gridData
      this.currentPageData = gridData.slice(0, this.pageSize)
    },
    handleCurrentChange(val) {
      console.log(this.currentPage)
      let start = (val - 1) * this.pageSize
      if (start < 0 || start > this.gridData.length) {
        start = 0
      }
      let end = start + this.pageSize
      if (end > this.gridData.length) {
        end = this.gridData.length
      }
      this.currentPage = val
      this.currentPageData = this.gridData.slice(start, end)
    },
    handleSizeChange(size) {
      console.log("size change")
      let currentPageStart = this.pageSize * (this.currentPage - 1)
      this.pageSize = size
      let currentPage = Math.round(currentPageStart / size)
      this.handleCurrentChange(currentPage)
    },
    handleView(index, node) {

    }
  },
  computed: {
    totalSize() {
      return this.gridData.length
    }
  },
  created() {
    this.initGridData()
    this.unwatchNodesChange = this.$store.watch((state) => state.nodesData.nodesMapChanged, () => {
      this.initGridData()
    })
  },
  beforeUnmount() {
    if (this.unwatchNodesChange) {
      this.unwatchNodesChange()
    }
  },
}
</script>

<style scoped>

</style>