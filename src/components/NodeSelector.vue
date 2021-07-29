<template>
  <el-select-v2
      class="node-selector"
      v-model="value"
      filterable
      :height=680
      size="medium"
      :options="options"
      clearable
      v-on:change="$emit('selectTitle', value)"
      placeholder="请选择">
    <template #default="{item}">
      <span style="margin-right: 8px;">{{ item.label }}</span>
      <span style="color: #8492a6; font-size: 13px">
        {{ item.time }}
      </span>
    </template>
  </el-select-v2>
</template>

<script>

export default {
  name: "NodeSelector",
  emits: ['selectTitle'],
  data() {
    return {
      options: [],
      value: '',
    }
  },
  methods: {
    initOptions(added) {
      let options = []
      let nodesMap = this.$store.state.nodesData.nodesMap
      for (const x of nodesMap.values()) {
        options.push({
          label: x.label,
          time: x.fileModifiedTimeString,
          value: x.id,
        })
      }
      this.options = options
    }
  },
  created() {
    this.$store.watch((state) => state.nodesData.nodesMapChanged, () => {
      this.initOptions()
    })
  }
}
</script>

<style scoped>
.node-selector {
  width: 400px;
}
</style>