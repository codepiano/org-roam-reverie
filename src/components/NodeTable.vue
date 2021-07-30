<template>
  <div>
    <el-form :inline="true" :model="form">
      <el-form-item label="标题" label-width="40px">
        <el-input v-model="form.title" style="width: 400px" placeholder=""></el-input>
      </el-form-item>
      <el-form-item label="标签" label-width="auto">
        <MutuallyExclusiveSelections :options="tagOptions"
                                     v-model="tags"
                                     left="包含标签"
                                     right="排除标签"/>
      </el-form-item>
      <el-form-item label-width="auto" label="操作">
        <el-button type="primary" size="mini" @click="onSubmit">查询</el-button>
      </el-form-item>
    </el-form>
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
              @click="handleView(scope.$index, scope.row)">查看
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
    <el-dialog
        title="节点详细信息"
        v-model="dialogVisible" width="80%">
      <NodeInfo :node="currentRow"></NodeInfo>
    </el-dialog>
  </div>
</template>

<script>

import NodeInfo from "@/components/NodeInfo.vue";
import MutuallyExclusiveSelections from "@/components/MutuallyExclusiveSelections.vue";

export default {
  name: "NodeTable",
  components: {MutuallyExclusiveSelections, NodeInfo},
  data() {
    return {
      gridData: [],
      allGridData: [],
      pageSize: 50,
      currentPage: 1,
      currentRow: {},
      currentPageData: [],
      unwatchNodesChange: null,
      dialogVisible: false,
      form: {
        title: ""
      },
      lastSearch: {
        title: ""
      },
      tagOptions: [],
      tags: {}
    }
  },
  methods: {
    initGridData(added) {
      let gridData = []
      let nodesMap = this.$store.state.nodesData.nodesMap
      let tagSet = new Set()
      // 初始化表格数据
      for (const x of nodesMap.values()) {
        gridData.push(x)
        if (x.tags) {
          x.tags.forEach(y => tagSet.add(y))
        }
      }
      this.gridData = gridData
      this.allGridData = gridData
      this.currentPageData = gridData.slice(0, this.pageSize)
      // 初始化 tag
      let tagOptions = []
      tagSet.forEach(x =>
          tagOptions.push({
            label: x,
            value: x
          })
      )
      this.tagOptions = tagOptions
    },
    handleCurrentChange(val) {
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
    handleView(index, row) {
      this.currentRow = row
      this.dialogVisible = true
    },
    compareSearchOptions() {
      let result = {
        added: [],
        restore: false
      }
      let added = []
      if (this.lastSearch.title !== this.form.title) {
        // 只处理参数发生变化的情况
        if (this.lastSearch.title === '') {
          // 新增标题过滤
          added.push('title')
        } else {
          // 移除或修改标题过滤
          result.restore = true
          return result
        }
      }
      return result
    },
    onSubmit() {
      let gridData = null
      let title = this.form.title
      let {added, restore} = this.compareSearchOptions()
      if (restore) {
        gridData = this.allGridData
      } else {
        gridData = this.gridData
      }
      this.lastSearch.title = title
      let data = gridData.filter(x => {
        if (x.title.includes(title)) {
          return true
        }
        if (x.aliases) {
          return x.aliases.some(y => y.includes(title))
        }
        return false
      })
      if (data.length !== this.gridData.length) {
        this.gridData = data
        this.handleCurrentChange(1)
      }
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
  watch: {
    tags() {
    }
  }
}
</script>

<style scoped>

</style>