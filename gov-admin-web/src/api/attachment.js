import api from './request'

// 上传/下载类请求的超时（大文件可能很慢），显式覆盖默认 30s
const LONG_TIMEOUT = 300000

// 上传文件（multipart）
export function uploadFile(file) {
  const form = new FormData()
  form.append('file', file)
  return api.post('/api/file/upload', form, {
    headers: { 'Content-Type': 'multipart/form-data' },
    timeout: LONG_TIMEOUT,
    // 同一个文件重复上传不应被"重复请求取消"误伤（进度/重试场景）
    allowRepeat: true
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