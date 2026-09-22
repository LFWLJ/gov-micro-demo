import api from './request'

export function pageGuides(params) {
  return api.get('/api/guide/page', { params })
}

export function getGuideCategories() {
  return api.get('/api/guide/categories')
}

export function getGuide(id) {
  return api.get(`/api/guide/${id}`)
}

export function createGuide(data) {
  return api.post('/api/guide', data)
}

export function updateGuide(data) {
  return api.put('/api/guide', data)
}

export function deleteGuide(id) {
  return api.delete(`/api/guide/${id}`)
}

export function toggleGuideStatus(id, status) {
  return api.post(`/api/guide/${id}/status/${status}`)
}