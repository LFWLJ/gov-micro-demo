import api from './request'

// 上传文件（multipart）
export function uploadFile(file) {
  const form = new FormData()
  form.append('file', file)
  return api.post('/api/file/upload', form, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

// 关联附件到业务对象
export function saveAttachment(data) {
  return api.post('/api/attachment', data)
}

// 查询某业务对象的所有附件
export function listAttachments(params) {
  return api.get('/api/attachment/list', { params })
}

// 删除附件关联
export function deleteAttachment(id) {
  return api.delete(`/api/attachment/${id}`)
}

// 获取预签名下载链接
export function getDownloadUrl(objectName) {
  return api.get('/api/file/url', { params: { objectName } })
}