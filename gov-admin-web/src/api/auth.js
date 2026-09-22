import api from './request'

export function login(data) {
  return api.post('/api/auth/login', data)
}

export function logout() {
  return api.post('/api/auth/logout')
}