import api from './request'

export function getSummary(params) {
  return api.get('/api/report/summary', { params })
}

export function statByDept(params) {
  return api.get('/api/report/by-dept', { params })
}

export function statByDate(params) {
  return api.get('/api/report/by-date', { params })
}

// 导出需要带 token，不能用普通 a 标签下载
export async function exportExcel(params) {
  const res = await api.get('/api/report/export', {
    params,
    responseType: 'blob'
  })
  return res
}