import api from './request'

export function pageUsers(params) {
  return api.get('/api/auth/user/page', { params })
}

/** 查询全部用户（跨租户、不分页，仅管理员）；config 可传 { silent: true } 抑制错误提示 */
export function getAllUsers(config = {}) {
  return api.get('/api/auth/user/all', config)
}

export function createUser(data) {
  return api.post('/api/auth/user', data)
}

export function updateUser(data) {
  return api.put('/api/auth/user', data)
}

export function deleteUser(id) {
  return api.delete(`/api/auth/user/${id}`)
}

export function resetPassword(id, password) {
  return api.post(`/api/auth/user/${id}/reset-password`, { password })
}

export function getProfile() {
  return api.get('/api/auth/user/profile')
}

export function updateProfile(data) {
  return api.put('/api/auth/user/profile', data)
}

export function changePassword(data) {
  return api.put('/api/auth/user/password', data)
}