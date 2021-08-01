<template>
  <div id="app">
    <el-tabs type="border-card">
      <el-tab-pane>
        <template #label>
          <span><i class="el-icon-share"></i> 关系图</span>
        </template>
        <Graph/>
      </el-tab-pane>
      <el-tab-pane>
        <template #label>
          <span><i class="el-icon-notebook-1"></i> 节点信息</span>
        </template>
        <NodeViewer />
      </el-tab-pane>
      <el-tab-pane>
        <template #label>
          <span><i class="el-icon-s-management"></i> 标签分组</span>
        </template>
        <TagGroup />
      </el-tab-pane>
      <el-tab-pane label="定时任务补偿">定时任务补偿</el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import Graph from "./components/Graph.vue";
import NodeViewer from "./components/NodeViewer.vue";
import TagGroup from "./components/TagGroup.vue";
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>