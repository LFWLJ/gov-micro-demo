import axios from 'axios'
import { ElMessage } from 'element-plus'

const api = axios.create({
  baseURL: '',
  timeout: 10000
})

api.interceptors.request.use(cfg => {
  const token = localStorage.getItem('token')
  if (token) {
    cfg.headers.Authorization = 'Bearer ' + token
  }
  return cfg
})

api.interceptors.response.use(
  res => res.data,
  err => {
    const status = err.response?.status
    if (status === 401) {
      localStorage.clear()
      ElMessage.error('登录已失效，请重新登录')
      window.location.href = '/login'
    } else if (status === 403) {
      ElMessage.error('无权限访问')
      window.location.href = '/403'
    } else {
      ElMessage.error(err.message || '网络错误')
    }
    return Promise.reject(err)
  }
)

export default api