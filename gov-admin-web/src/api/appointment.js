import api from './request'

export function pageAppointments(params) {
  return api.get('/api/appointment/page', { params })
}

export function createAppointment(data) {
  return api.post('/api/appointment', data)
}

export function checkinAppointment(id) {
  return api.post(`/api/appointment/checkin/${id}`)
}

export function finishAppointment(id) {
  return api.post(`/api/appointment/finish/${id}`)
}

export function cancelAppointment(id, reason) {
  return api.post(`/api/appointment/cancel/${id}`, { reason })
}

export function getTodayQueue() {
  return api.get('/api/appointment/queue')
}

export function getAppointmentStats() {
  return api.get('/api/appointment/stats')
}