import api from './request'

export function getDeptTree() {
  return api.get('/api/dept/tree')
}

export function createDept(data) {
  return api.post('/api/dept', data)
}

export function updateDept(data) {
  return api.put('/api/dept', data)
}

export function deleteDept(id) {
  return api.delete(`/api/dept/${id}`)
}