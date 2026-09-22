import api from './request'

export function listConfigs(params) {
  return api.get('/api/config/list', { params })
}

export function getConfigValue(key) {
  return api.get(`/api/config/value/${key}`)
}

export function createConfig(data) {
  return api.post('/api/config', data)
}

export function updateConfig(data) {
  return api.put('/api/config', data)
}

export function deleteConfig(id) {
  return api.delete(`/api/config/${id}`)
}