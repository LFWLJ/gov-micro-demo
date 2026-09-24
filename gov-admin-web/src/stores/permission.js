import { defineStore } from 'pinia'
import { ref } from 'vue'

export const usePermissionStore = defineStore('permission', () => {
  // 侧边栏渲染用的菜单树（含 M 目录）
  const menuTree = ref([])
  // 是否已加载
  const loaded = ref(false)

  function setMenuTree(tree) {
    menuTree.value = tree || []
    loaded.value = true
  }

  function clear() {
    menuTree.value = []
    loaded.value = false
  }

  return { menuTree, loaded, setMenuTree, clear }
})