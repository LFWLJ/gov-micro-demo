import api from './request'

export function getWorkspaceSummary(params) {
  return api.get('/api/workspace/summary', { params })
}