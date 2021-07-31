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
import {setCompare} from "@/js/collection";
import * as filters from "@/js/filters";

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
        title: "",
        left: [],
        right: []
      },
      tagOptions: [],
      tags: {
        left: [],
        right: []
      }
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
      // TODO 标签的处理太复杂了，应该没必要这么优化
      let result = {
        differ: new Set(),
        restore: false
      }
      if (this.lastSearch.title !== this.form.title) {
        // 只处理参数发生变化的情况
        if (this.lastSearch.title === '') {
          // 新增标题过滤
          result.differ.add(filters.Title)
        } else {
          // 移除或修改标题过滤
          result.restore = true
          return result
        }
      }

      // 包含标签
      let leftResult = setCompare(this.tags.left, this.lastSearch.left)
      if (leftResult === 1 || leftResult === 3) {
        // 新增包含标签，需要重新计算
        result.restore = true
        return result
      } else if (leftResult === 2) {
        // 移除包含标签，过滤即可
        result.differ.add(filters.Left)
      }
      // 排除标签
      let rightResult = setCompare(this.tags.right, this.lastSearch.right)
      if (leftResult === 1) {
        // 新增排除标签
        result.differ.add(fitlers.Right)
      } else if (rightResult === 2 || rightResult === 3) {
        // 删除或者更换
        result.restore = true
        return result
      }

      return result
    },
    onSubmit() {
      if (this.form.title === "" && this.tags.left.length === 0 && this.tags.right.length === 0) {
        if (this.lastSearch.title === "" && this.lastSearch.left.length === 0 && this.lastSearch.right.length === 0) {
          // 没有搜索条件，也无需恢复
          return
        } else {
          // 搜索条件被重置
          this.gridData = this.allGridData
          this.handleCurrentChange(1)
          return
        }
      }
      let gridData = null
      let title = this.form.title
      let left = this.tags.left
      let right = this.tags.right
      let {differ, restore} = this.compareSearchOptions()
      if (restore) {
        gridData = this.allGridData
      } else {
        gridData = this.gridData
      }
      this.lastSearch.title = title
      // 构建 filterChain
      let filterChain = []
      if (left && left.length > 0 && (restore || differ.has('left'))) {
        filterChain.push(filters.Left)
      }
      if (right && right.length > 0 && (restore || differ.has('right'))) {
        filterChain.push(filters.Right)
      }
      if (title && (restore || differ.has('title'))) {
        filterChain.push(filters.Title)
      }
      // 过滤数据
      if (filterChain.length === 0) {
        this.gridData = this.allGridData
        this.handleCurrentChange(1)
        return
      }
      let data = gridData.filter(node => {
        let result = false
        filterChain.forEach(y => {
          let result = false
          if (filters.filterMap.has(y)) {
            if (y === filters.Left) {

            }
            if (y === filters.Right) {

            }
            if (y === filters.Title) {
              if (filters.title(node, title)) {
                return true
              }
            }
          }
        })
        return result
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