<template>
  <div>
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
  </div>
</template>

<script>
export default {
  name: "NodeTable",
  props: {
    currentPageData: Object,
    tableKey: {
      type: String,
      default: 'node-table'
    }
  },
  data() {
    return {}
  },
  methods: {
    sortTable(data) {
      this.$emit('sortTable', {...data, key: this.tableKey})
    },
    handleView(index, row) {
      this.$emit('handleView', {
        index: index,
        row: row
      })
    },
    handleClick(index, row) {
      this.$emit('handleClick', {
        index: index,
        row: row
      })
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