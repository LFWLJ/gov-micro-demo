import api from './request'

export function pageTenants(data) {
  return api.post('/api/auth/tenant/page', data)
}

export function createTenant(data) {
  return api.post('/api/auth/tenant', data)
}

export function updateTenant(data) {
  return api.put('/api/auth/tenant', data)
}

export function deleteTenant(id) {
  return api.delete(`/api/auth/tenant/${id}`)
}