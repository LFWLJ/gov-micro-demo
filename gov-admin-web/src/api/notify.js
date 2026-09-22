import api from './request'

export function pageNotifies(params) {
  return api.get('/api/notify/page', { params })
}

export function getUnreadCount(receiver) {
  return api.get('/api/notify/unread-count', { params: { receiver } })
}

export function readNotify(id, receiver) {
  return api.post(`/api/notify/read/${id}`, null, { params: { receiver } })
}

export function readAllNotify(receiver) {
  return api.post('/api/notify/read-all', null, { params: { receiver } })
}

export function deleteNotify(id, receiver) {
  return api.delete(`/api/notify/${id}`, { params: { receiver } })
}