import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const realName = ref(localStorage.getItem('realName') || '')
  const tenantId = ref(localStorage.getItem('tenantId') || '')
  const roles = ref(localStorage.getItem('roles') || '')

  function setUser(data) {
    token.value = data.token
    realName.value = data.realName || ''
    tenantId.value = data.tenantId || ''
    roles.value = data.roles || ''
    localStorage.setItem('token', data.token)
    localStorage.setItem('realName', data.realName || '')
    localStorage.setItem('tenantId', data.tenantId || '')
    localStorage.setItem('roles', data.roles || '')
  }

  function clear() {
    token.value = ''
    realName.value = ''
    tenantId.value = ''
    roles.value = ''
    localStorage.clear()
  }

  return { token, realName, tenantId, roles, setUser, clear }
})