import api from './request'

export function listDictTypes() {
  return api.get('/api/dict/types')
}

export function getDictData(dictType) {
  return api.get(`/api/dict/data/${dictType}`)
}

export function createDict(data) {
  return api.post('/api/dict', data)
}

export function updateDict(data) {
  return api.put('/api/dict', data)
}

export function deleteDict(id) {
  return api.delete(`/api/dict/${id}`)
}

export function createDictType(data) {
  return api.post('/api/dict/type', data)
}