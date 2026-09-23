import api from './request'

export function getDashboardStats(params) {
  return api.get('/api/dashboard/stats', { params })
}