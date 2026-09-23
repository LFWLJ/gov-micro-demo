import api from './request'

export function pageLoginLogs(params) {
  return api.get('/api/auth/login-log/page', { params })
}