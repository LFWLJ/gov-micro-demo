import api from './request'

export function pageConsults(params) {
  return api.get('/api/consult/page', { params })
}

export function createConsult(data) {
  return api.post('/api/consult', data)
}

export function replyConsult(id, reply) {
  return api.post(`/api/consult/reply/${id}`, { reply })
}

export function closeConsult(id) {
  return api.post(`/api/consult/close/${id}`)
}

export function deleteConsult(id) {
  return api.delete(`/api/consult/${id}`)
}

export function getConsultStats() {
  return api.get('/api/consult/stats')
}