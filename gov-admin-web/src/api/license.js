import api from './request'

export function pageLicenses(params) {
  return api.get('/api/license/page', { params })
}

export function getTemplates() {
  return api.get('/api/license/templates')
}

export function issueLicense(data) {
  return api.post('/api/license/issue', data)
}

export function verifyLicense(code) {
  return api.get(`/api/license/verify/${code}`)
}

export function revokeLicense(id) {
  return api.post(`/api/license/revoke/${id}`)
}