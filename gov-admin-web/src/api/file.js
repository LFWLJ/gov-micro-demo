import api from './request'

export function pageFiles(params) {
  return api.get('/api/file/page', { params })
}

export function getFileUrl(objectName) {
  return api.get('/api/file/url', { params: { objectName } })
}

export function deleteFile(objectName) {
  return api.delete('/api/file', { params: { objectName } })
}