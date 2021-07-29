<template>
  <el-select-v2
      v-model="value"
      filterable
      :height=680
      size="medium"
      :options="options"
      style="width: 400px;"
      popper-class="popper"
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
      unwatchNodesChange: null,
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
  },
  beforeUnmount() {
    if (this.unwatchNodesChange) {
      this.unwatchNodesChange()
    }
  },
}
</script>

<style>
.popper {
  width: 400px;
}

.popper .el-select-dropdown__list {
  width: 400px !important;
}
</style>