import api from './request'

export function listApplications() {
  return api.get('/api/application/list')
}

export function createApplication(data) {
  return api.post('/api/application/create', data)
}

export function getApplicationTrace(id) {
  return api.get(`/api/application/${id}/trace`)
}

export function getApplicationLogs(id) {
  return api.get(`/api/application/${id}/logs`)
}

export function rejectApplication(id, remark) {
  return api.post(`/api/application/${id}/reject`, { remark })
}

export function withdrawApplication(id, remark) {
  return api.post(`/api/application/${id}/withdraw`, { remark })
}