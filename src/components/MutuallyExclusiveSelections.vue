<template>
  <div>
    <span class="labelText">{{ left }}</span>
    <el-select v-model="leftModel"
               @change="setOptions"
               @remove-tag="setOptions"
               @clear="setOptions"
               filterable
               multiple
               style="width: 400px"
               placeholder="请选择">
      <el-option
          v-for="item in leftOptions"
          :key="item.value"
          :label="item.label"
          :value="item.value">
      </el-option>
    </el-select>
    <span class="labelText">{{ right }}</span>
    <el-select v-model="rightModel"
               @change="setOptions"
               @remove-tag="setOptions"
               @clear="setOptions"
               filterable
               multiple
               style="width: 400px"
               placeholder="请选择">
      <el-option
          v-for="item in rightOptions"
          :key="item.value"
          :label="item.label"
          :value="item.value">
      </el-option>
    </el-select>
  </div>
</template>

<script>
export default {
  name: "MutuallyExclusiveSelections",
  props: {
    options: Array,
    modelValue: Object,
    left: {
      type: String,
      default: '包含'
    },
    right: {
      type: String,
      default: '排除'
    },
    leftPlaceholder: {
      type: String,
      default: '请选择'
    },
    rightPlaceholder: {
      type: String,
      default: '请选择'
    }
  },
  data() {
    return {
      leftModel: [],
      rightModel: [],
      leftOptions: [],
      rightOptions: [],
    }
  },
  methods: {
    reset() {
      this.leftModel = []
      this.rightModel = []
    },
    exclusive(val) {
      // val 是 leftModel 或者 rightModel，返回另一个组件的 options
      let valSet = new Set()
      val.forEach(x => valSet.add(x))
      return this.options.filter(x => !valSet.has(x.value))
    },
    setOptions(emit) {
      let left = this.leftModel, right = this.rightModel
      if ((left || left.length === 0) && (right || right.len === 0)) {
        // 未选择时，均能选择所有选项
        this.leftOptions = this.options
        this.rightOptions = this.options
      }
      if (left && left.length > 0) {
        this.rightOptions = this.exclusive(this.leftModel)
      }
      if (right && right.length > 0) {
        this.leftOptions = this.exclusive(this.rightModel)
      }
      if (emit !== false) {
        this.$emit('update:modelValue', {
          left: this.leftModel,
          right: this.rightModel
        })
      }
    }
  },
  watch: {
    options() {
      this.setOptions(false)
    }
  }
}
</script>

<style scoped>
.labelText {
  margin-left: 8px;
  margin-right: 8px;
}
</style>