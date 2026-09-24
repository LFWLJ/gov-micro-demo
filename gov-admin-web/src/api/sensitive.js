import api from './request'

export function pageSensitiveWords(data) {
  return api.post('/api/sensitive/page', data)
}

export function createSensitiveWord(data) {
  return api.post('/api/sensitive', data)
}

export function updateSensitiveWord(data) {
  return api.put('/api/sensitive', data)
}

export function deleteSensitiveWord(id) {
  return api.delete(`/api/sensitive/${id}`)
}

export function batchAddSensitiveWords(data) {
  return api.post('/api/sensitive/batch', data)
}