<template>
  <el-select-v2
      class="node-selector"
      v-model="value"
      filterable
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
import {formatTimestamp} from '@/js/datetime.js'

export default {
  name: "NodeSelector",
  props: {
    nodesMap: Object
  },
  data() {
    return {
      options: [],
      value: '',
    }
  },
  methods: {
    initOptions() {
      let options = []
      for (const x of this.nodesMap.values()) {
        options.push({
          label: x.label,
          time: formatTimestamp(x.fileModifiedTime),
          value: x.id,
        })
      }
      this.options = options
    }
  },
  watch: {
    nodesMap() {
      console.log("nodesMap changed")
      this.initOptions()
    }
  }
}
</script>

<style scoped>
.node-selector {
  width: 400px;
}
</style>