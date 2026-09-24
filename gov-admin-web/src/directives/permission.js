import { useUserStore } from '../stores/user'

/**
 * 按钮权限指令
 * 用法：
 *   v-perm="'sys:user:add'"
 *   v-perm="['sys:user:add', 'sys:user:edit']"   // 满足任一即可
 *
 * 无权限时直接移除元素
 */
export default {
  mounted(el, binding) {
    const userStore = useUserStore()
    const perms = userStore.permissions || []
    const value = binding.value

    if (!value) return

    const required = Array.isArray(value) ? value : [value]
    const hasPerm = required.some(p => perms.includes(p))

    if (!hasPerm) {
      el.parentNode && el.parentNode.removeChild(el)
    }
  }
}