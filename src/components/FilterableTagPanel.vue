<template>
  <div>

    <div style="margin-bottom: 10px">
      <el-input
          placeholder="过滤标签"
          suffix-icon="el-icon-search"
          clearable
          @change="filterTag"
          @clear="recoverTag"
          style="width: 200px"
          v-model="input"/>
    </div>
    <el-tag size="mini" class="nodeTag" @click="$emit('tagClick', tag)" v-for="tag in tagData">{{ tag }}</el-tag>
  </div>

</template>

<script>
export default {
  name: "FilterableTagPanel",
  props: {
    tags: {
      type: Object,
      default: new Set()
    },
  },
  data() {
    return {
      input: '',
      tagData: new Set()
    }
  },
  methods: {
    filterTag(val) {
      let tmp = new Set()
      this.tagData.forEach(x => {
        if (x.includes(val)) {
          tmp.add(x)
        }
      })
      this.tagData = tmp
    },
    recoverTag() {
      this.tagData = this.tags
    }
  },
  watch: {
    tags() {
      this.tagData.clear()
      this.tags.forEach(x => this.tagData.add(x))
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