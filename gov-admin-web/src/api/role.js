import api from './request'

export function pageRoles(data) {
  return api.post('/api/role/page', data)
}

export function createRole(data) {
  return api.post('/api/role', data)
}

export function updateRole(data) {
  return api.put('/api/role', data)
}

export function deleteRole(id) {
  return api.delete(`/api/role/${id}`)
}

export function getRoleMenus(id) {
  return api.get(`/api/role/${id}/menus`)
}

export function assignRoleMenus(id, menuIds) {
  return api.put(`/api/role/${id}/menus`, { menuIds })
}

// ↓ 新增：查询角色已分配用户ID
export function getRoleUsers(id) {
  return api.get(`/api/role/${id}/users`)
}

// ↓ 新增：分配用户
export function assignRoleUsers(id, userIds) {
  return api.put(`/api/role/${id}/users`, { userIds })
}