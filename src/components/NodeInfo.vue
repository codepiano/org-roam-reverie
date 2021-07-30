<template>
  <el-descriptions class="margin-top" :column="2" size="small" border>
    <el-descriptions-item label="ID">{{ node.id }}</el-descriptions-item>
    <el-descriptions-item label="节点创建时间">{{ node.createdTimeString }}</el-descriptions-item>
    <el-descriptions-item label="节点">{{ node.title }}</el-descriptions-item>
    <el-descriptions-item label="节点别名">
      <el-tag size="mini" class="nodeTag" v-for="alias in node.aliases">{{ alias }}</el-tag>
    </el-descriptions-item>
    <el-descriptions-item label="大纲路径" span="2">{{ node.olp }}</el-descriptions-item>
    <el-descriptions-item label="节点标签" span="2">
      <el-tag size="mini" class="nodeTag" v-for="tag in node.tags">{{ tag }}</el-tag>
    </el-descriptions-item>
    <el-descriptions-item label="buffer位置">{{ node.pos }}</el-descriptions-item>
    <el-descriptions-item label="级别">{{ node.level===0 ? '文件节点' : node.level }}</el-descriptions-item>
    <el-descriptions-item label="TODO">{{ node.todo ? "是" : "否" }}</el-descriptions-item>
    <el-descriptions-item label="TODO 优先级">{{ node.priority }}</el-descriptions-item>
    <el-descriptions-item label="计划时间">{{ node.scheduled }}</el-descriptions-item>
    <el-descriptions-item label="截止时间">{{ node.deadline }}</el-descriptions-item>
    <el-descriptions-item label="文件">{{ node.file }}</el-descriptions-item>
    <el-descriptions-item label="文件修改时间">{{ node.fileModifiedTimeString }}</el-descriptions-item>
    <el-descriptions-item label="属性" span="2">
      <el-tag size="mini" class="nodeTag" v-for="tag in Object.entries(node.properties)">{{ tag[0] }}:{{tag[1]}}</el-tag>
    </el-descriptions-item>
  </el-descriptions>
</template>

<script>
export default {
  name: "NodeInfo",
  props: {
    node: Object,
  }
}
</script>

<style scoped>
.nodeTag {
  margin-right: 3px;
}
</style>