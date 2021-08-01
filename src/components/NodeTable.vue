<template>
  <div>
    <el-form :model="form">
      <el-form-item label="标题" label-width="40px">
        <el-input v-model="form.title" style="width: 400px" placeholder=""></el-input>
      </el-form-item>
      <el-form-item label="标签" label-width="40px">
        <MutuallyExclusiveSelections ref="mutexSelection" :options="tagOptions"
                                     v-model="tags"
        />
      </el-form-item>
      <el-form-item label-width="40px" label="操作">
        <el-button type="primary" size="mini" @click="onSubmit">查 询</el-button>
        <el-button type="warning" size="mini" @click="resetSearch">重 置</el-button>
      </el-form-item>
    </el-form>
    <el-table size="small" @sort-change="sortTable" stripe :data="currentPageData">
      <el-table-column sortable="custom" property="createdTimeString" label="创建日期" width="150"></el-table-column>
      <el-table-column label="标题">
        <template #default="scope">
          <el-popover v-if="scope.row.aliases && scope.row.aliases.length>0"
                      placement="top-start"
                      title="节点别名"
                      trigger="hover">
            <template #reference>
              <span>{{ scope.row.title }} <i class="el-icon-info"/></span>
            </template>
            <el-tag size="small" effect="plain" class="nodeTag" v-for="alias in scope.row.aliases">{{ alias }}</el-tag>
          </el-popover>
          <div v-if="!scope.row.aliases || scope.row.aliases.length===0">
            <span>{{ scope.row.title }}</span>
          </div>

        </template>
      </el-table-column>
      <el-table-column label="标签">
        <template #default="scope">
          <el-tag size="mini" class="nodeTag" v-for="tag in scope.row.tags">{{ tag }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作">
        <template #default="scope">
          <el-button size="mini" type="primary" @click="handleView(scope.$index, scope.row)">查看</el-button>
          <el-button size="mini" @click="handleClick(scope.$index, scope.row)">打开</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div style="text-align: center">
      <el-pagination
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          :current-page="currentPage"
          :page-sizes="[100, 200, 300, 400]"
          :page-size="pageSize"
          :pager-count=17
          layout="total, sizes, prev, pager, next, jumper"
          background
          style="margin-top: 20px;"
          :total="totalSize">
      </el-pagination>
    </div>
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
import {setCompare, differenceArray} from "@/js/collection";
import * as filters from "@/js/filters";
import {openRoamProtocol} from '@/js/org'

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
      unwatchTagsChange: null,
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
    initTagOptions() {
      let tagOptions = []
      this.$store.state.nodesData.tagSet.forEach(x =>
          tagOptions.push({
            label: x,
            value: x
          })
      )
      this.tagOptions = tagOptions
    },
    initGridData(added) {
      let gridData = []
      let nodesMap = this.$store.state.nodesData.nodesMap
      // 初始化表格数据
      for (const x of nodesMap.values()) {
        gridData.push(x)
      }
      gridData.sort((x, y) => y.createdTime - x.createdTime)
      this.gridData = gridData
      this.allGridData = gridData
      this.currentPageData = gridData.slice(0, this.pageSize)
      // 初始化 tag
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
      let currentPageStart = this.pageSize * (this.currentPage - 1)
      this.pageSize = size
      let currentPage = Math.round(currentPageStart / size)
      this.handleCurrentChange(currentPage)
    },
    handleView(index, row) {
      this.currentRow = row
      this.dialogVisible = true
    },
    handleClick(index, row) {
      if (row) {
        openRoamProtocol(row.id)
      }
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
      /**
       * 包含标签
       *
       * 上一次  本次 c   改动类型
       * 空     有   1           filter
       * 有     空   2           restore
       * 空     空   0           nothing
       * 有     有   0 完全相同    nothing
       * 有     有   1 只本次新增  restore
       * 有     有   2 只本次删除  restore/filter（过滤的时候不能只按被删除的标签过滤，
       *                         因为一个节点可能有多个标签，其中一个被删除，但是其他的标签还包含在本次中)
       * 有     有   3 都有改动    restore
       */
      let leftResult = setCompare(this.tags.left, this.lastSearch.left)
      if (leftResult !== 0) {
        // 新增包含标签，需要重新计算
        if (leftResult === 1) {
          if (this.tags.left.length !== 0 && this.lastSearch.left.length === 0) {
            result.differ.add(filters.Left)
          }
        }
        result.restore = true
        return result
      }
      /**
       * 排除标签
       *
       * 上一次  本次 c 改动类型
       * 空     有   1           filter
       * 有     空   2           restore
       * 空     空   0           nothing
       * 有     有   0 完全相同    nothing
       * 有     有   1 只本次新增  filter
       * 有     有   2 只本次删除  restore
       * 有     有   3 都有改动    restore
       */
      let rightResult = setCompare(this.tags.right, this.lastSearch.right)
      if (rightResult !== 0) {
        // 新增包含标签，需要重新计算
        if (rightResult === 1) {
          result.differ.add(filters.Right)
        } else {
          result.restore = true
          return result
        }
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
      // 构建 filterChain
      let filterChain = []
      if (left && left.length > 0 && (restore || differ.has(filters.Left))) {
        filterChain.push(filters.Left)
      }
      if (right && right.length > 0 && (restore || differ.has(filters.Right))) {
        filterChain.push(filters.Right)
      }
      if (title && (restore || differ.has(filters.Title))) {
        filterChain.push(filters.Title)
      }
      // 过滤数据
      if (filterChain.length === 0) {
        return
      }
      // 生成过滤的集合
      let leftDifferenceSet = null
      let rightDifferenceArray = null
      leftDifferenceSet = new Set(left)
      if (restore) {
        // restore 的时候需要重新过滤，直接使用 right 的值
        rightDifferenceArray = new Set(right)
      } else {
        // 不需要 restore 的时候，为添加了标签的情况，需要 diff 出来被添加的标签
        rightDifferenceArray = differenceArray(right, this.lastSearch.right)
      }
      let data = gridData.filter(node => {
            return filterChain.every(y => {
              if (!filters.filterMap.has(y)) {
                throw (new Error("no filter match"))
              }
              switch (y) {
                case filters.Left: {
                  if (filters.tag(node, leftDifferenceSet)) {
                    return true
                  }
                  break
                }
                case filters.Right: {
                  if (!filters.tag(node, rightDifferenceArray)) {
                    return true
                  }
                  break
                }
                case filters.Title: {
                  if (filters.title(node, title)) {
                    return true
                  }
                  break
                }
              }
              return false
            })
          }
      )
      this.lastSearch.title = title
      this.lastSearch.left = left
      this.lastSearch.right = right
      if (data.length !== this.gridData.length) {
        this.gridData = data
        this.handleCurrentChange(1)
      }
    },
    resetSearch() {
      this.form.title = ""
      this.tags = {
        left: [],
        right: []
      }
      this.lastSearch = {
        title: "",
        left: [],
        right: []
      }
      this.$refs.mutexSelection.reset()
    },
    sortTable({column, prop, order}) {
      let comparator = null
      if (prop === "createdTimeString") {
        if (order === "ascending") {
          comparator = (x, y) => x.createdTime - y.createdTime
        } else if (order === "descending") {
          comparator = (x, y) => y.createdTime - x.createdTime
        }
        this.gridData.sort(comparator)
        this.handleCurrentChange(this.currentPage)
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
    this.initTagOptions()
    this.unwatchNodesChange = this.$store.watch((state) => state.nodesData.nodesMapChanged, () => {
      this.initGridData()
    })
    this.unwatchTagsChange = this.$store.watch((state) => state.nodesData.tagSetChanged, () => {
      this.initTagOptions()
    })
  },
  beforeUnmount() {
    if (this.unwatchNodesChange) {
      this.unwatchNodesChange()
    }
    if (this.unwatchTagsChange) {
      this.unwatchTagsChange()
    }
  }
}
</script>

<style scoped>
.nodeTag {
  margin-top: 2px;
  margin-right: 8px;
}
</style>