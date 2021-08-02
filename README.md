# org-roam-reverie

功能和 org-roam-server 类似，适配 org-roam v2

第一阶段最终目标是 fork org-roam v2，为 org-roam-server 的功能进行一些功能修改，最终目标是将两个项目整合一个插件

org-roam v2 做了一些很好的改动，但是作为一个核心功能提供者，对插件开发不太友好，数据库设计也只是为自身使用方便，为插件的功能实现带来了一些麻烦和问题

# 目标
## v1.0.0

- [√] v1.0.0 插件化改造，完成网络图绘制，动态更新功能，节点定位功能
- [√] v1.0.1 完成通过properties自定义节点属性，笔记标签自动折行
- [√] v1.0.2 笔记标题展示、节点详细信息展示
- [√] v1.0.3 笔记标题搜索
- [√] v1.0.4 笔记标题分组
- [] v1.0.5 笔记过滤
- [] v1.0.6 完成所有笔记信息在前端进行展示和预览
- [] v1.1.0 整合 org-roam，在保持兼容性的基础上，改造数据库结构

- 在网络图之外，再外挂其他图形展示方式，类似数据库的视图
- 笔记连接上可以附加属性，增强连接展示功能
- 选一个节点，以此为根节点，把它和它的所有子节点导出成幕布那样的大纲思维导图格式
- 网络图上任意两个节点间自动寻路、路径高亮
- 网络图上一组概念相近的相邻节点折叠成单个节点
- 直接在网络图上新增、删除、编辑笔记和连接
- 笔记内容的高级全文检索
- 笔记内容分词，计算相似度

# 功能
## 自定义节点属性
在节点的 properties 中添加属性定制节点的形状、颜色等

```
:PROPERTIES:
:ID:       3BACC352-D657-44F9-8DD5-83817942D38C
:reverie.node.shape: star
:reverie.node.size: 40
:reverie.node.color: #ED553B
:END:
```

### 目前支持的属性列表

- reverie.node.shape 节点形状，枚举值： diamond, dot, star, triangle, triangleDown, hexagon, square.
- reverie.node.size 节点大小，10 以上数字
- reverie.node.color 颜色，#ED553B、red、rgba(120,110,119)
- reverie.node.icon font-awesome 图表作为节点形状，具体见下方说明，配置了 icon 之后 `reverie.node.shape` `reverie.node.size` `reverie.node.color` 会失效

### 使用 font-awesome 作为节点形状

在节点中配置属性 `:reverie.node.icon: f549_100_red` 属性值为 unicode\_size\_color 拼接，该例配置了图标为 shcool，大小为 100，颜色为红色的节点

渲染的时候会使用 '\_' 分割属性值，分割后第一个值是图表的 unicode，可以在[font-awesome](https://fontawesome.com/) 网站中查询，是形如 'f549' 的 unicode 字符串，注意不是图标的英文名称，第二个值如果是数字，则当做节点大小使用，如果不是数字，当做颜色使用，第三个值为颜色
