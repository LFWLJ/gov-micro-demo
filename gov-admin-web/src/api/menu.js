import api from './request'

export function getMenuTree() {
  return api.get('/api/menu/tree')
}

export function getMenuList() {
  return api.get('/api/menu/list')
}

export function getMenuDetail(id) {
  return api.get(`/api/menu/${id}`)
}

export function createMenu(data) {
  return api.post('/api/menu', data)
}

export function updateMenu(data) {
  return api.put('/api/menu', data)
}

export function deleteMenu(id) {
  return api.delete(`/api/menu/${id}`)
}

export function getRoleMenus(roleId) {
  return api.get(`/api/menu/role/${roleId}`)
}

// ↓ 新增：当前用户路由菜单树
export function getRouters() {
  return api.get('/api/menu/routers')
}

// ↓ 新增：当前用户按钮权限
export function getPermissions() {
  return api.get('/api/menu/permissions')
}