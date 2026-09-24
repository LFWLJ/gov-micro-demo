import request from './request'

// 菜单树
export function getMenuTree() {
  return request.get('/menu/tree')
}

// 扁平列表
export function getMenuList() {
  return request.get('/menu/list')
}

// 详情
export function getMenuDetail(id) {
  return request.get(`/menu/${id}`)
}

// 新增
export function createMenu(data) {
  return request.post('/menu', data)
}

// 修改
export function updateMenu(data) {
  return request.put('/menu', data)
}

// 删除
export function deleteMenu(id) {
  return request.delete(`/menu/${id}`)
}

// 某角色已分配的菜单ID
export function getRoleMenus(roleId) {
  return request.get(`/menu/role/${roleId}`)
}