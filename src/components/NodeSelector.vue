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
},
  watch: {
    nodesMap(val) {
      console.log("nodesMap changed")
      let options = []
      for (const x of val.values()) {
        options.push({
          label: x.label,
          time: formatTimestamp(x.fileAtime),
          value: x.id,
        })
      }
      this.options = options
    }
  }
}
</script>

<style scoped>
.node-selector {
  width: 400px;
}
</style>