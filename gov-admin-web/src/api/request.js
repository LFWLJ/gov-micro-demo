import axios from 'axios'
import { ElMessage } from 'element-plus'

/**
 * 本项目自己写入 localStorage 的键。
 * 401 时只清理这些键，绝不再用 localStorage.clear()（会误删其它应用/无关键）。
 */
export const APP_STORAGE_KEYS = ['token', 'realName', 'tenantId', 'roles', 'permissions']

/** 默认超时：30s（原来 10s 偏短，导出/慢查询容易误报网络错误） */
const DEFAULT_TIMEOUT = 30000

const api = axios.create({
  baseURL: '',
  timeout: DEFAULT_TIMEOUT
})

/* ------------------------------------------------------------------ *
 * 重复请求取消（AbortController + pending map）
 * key = method + url + 序列化后的 params/data
 * 通过 config.allowRepeat = true 可跳过取消逻辑。
 * ------------------------------------------------------------------ */
const pendingMap = new Map()

function stableStringify(value) {
  if (value == null) return ''
  if (typeof value !== 'object') return String(value)
  if (value instanceof FormData) return '[FormData]'
  if (typeof Blob !== 'undefined' && value instanceof Blob) return '[Blob]'
  if (Array.isArray(value)) return '[' + value.map(stableStringify).join(',') + ']'
  return (
    '{' +
    Object.keys(value)
      .sort()
      .map(k => JSON.stringify(k) + ':' + stableStringify(value[k]))
      .join(',') +
    '}'
  )
}

function buildKey(cfg) {
  const method = (cfg.method || 'get').toLowerCase()
  return [method, cfg.url || '', stableStringify(cfg.params), stableStringify(cfg.data)].join('|')
}

function isCanceled(err) {
  return (
    axios.isCancel?.(err) ||
    err?.code === 'ERR_CANCELED' ||
    err?.name === 'CanceledError' ||
    err?.__canceled === true
  )
}

/** 供调用方判断"这个失败只是被重复请求取消/主动取消"，用于静默处理 */
export function isCanceledError(err) {
  return isCanceled(err)
}

function addPending(cfg) {
  const key = buildKey(cfg)
  const prev = pendingMap.get(key)
  if (prev) {
    // 同一个请求还没回来，先把上一次的取消掉
    prev.controller.abort()
    pendingMap.delete(key)
  }
  const controller = new AbortController()
  cfg.signal = controller.signal
  cfg.__pendingKey = key
  pendingMap.set(key, { controller })
  return cfg
}

function removePending(cfg) {
  if (cfg && cfg.__pendingKey) {
    pendingMap.delete(cfg.__pendingKey)
  }
}

/** 供 401 / 登出时一次性取消所有在途请求 */
export function cancelAllPending() {
  pendingMap.forEach(entry => entry.controller.abort())
  pendingMap.clear()
}

/* ------------------------------------------------------------------ *
 * 请求拦截
 * ------------------------------------------------------------------ */
api.interceptors.request.use(
  cfg => {
    const token = localStorage.getItem('token')
    if (token) {
      cfg.headers.Authorization = 'Bearer ' + token
    }
    // 允许在单个请求上覆盖超时（上传/导出用长超时）
    if (cfg.timeout == null) cfg.timeout = DEFAULT_TIMEOUT
    if (!cfg.allowRepeat) addPending(cfg)
    return cfg
  },
  error => Promise.reject(error)
)

/* ------------------------------------------------------------------ *
 * 401 处理：只清本项目键 + router.replace，避免整页重载丢 Pinia / 动态路由
 *
 * 这里刻意用 **动态 import** 取 router，而不是顶层静态 import：
 * 静态 import 会让 request.js 反向依赖 router，把 router + Element Plus
 * 一起拉进入口 chunk，首屏体积明显变大。动态 import 只在 401/403 真正
 * 发生时加载，且因为 main.js 已经加载过 router，这次加载是零成本的。
 * ------------------------------------------------------------------ */
let redirectingToLogin = false

async function getRouter() {
  try {
    const mod = await import('../router/index.js')
    return mod.default || mod
  } catch (e) {
    return null
  }
}

async function handleUnauthorized() {
  cancelAllPending()
  APP_STORAGE_KEYS.forEach(k => localStorage.removeItem(k))

  if (redirectingToLogin) return
  const router = await getRouter()
  if (!router) return
  if (router.currentRoute.value.path === '/login') return

  redirectingToLogin = true
  try {
    // replace 而不是 window.location.href：不整页重载，Pinia 状态与
    // 已注册的动态路由都不会丢。路由守卫在无 token 时会放行 /login，
    // 不会形成 401 → /login → 401 的循环。
    await router.replace('/login')
  } finally {
    setTimeout(() => { redirectingToLogin = false }, 1000)
  }
}

async function goForbidden() {
  const router = await getRouter()
  if (!router) return
  if (router.currentRoute.value.path !== '/403') {
    router.replace('/403')
  }
}

/* ------------------------------------------------------------------ *
 * 响应拦截
 *
 * 兼容策略（重要）：
 *   视图层有 85+ 处 `if (res.code === 200)`，因此成功分支仍然 **原样返回
 *   后端响应体** `{ code, msg, data }`，形状完全不变。
 *   只有 code !== 200 的失败分支改为：ElMessage.error(msg) + Promise.reject，
 *   这样既统一了后端 BizException（HTTP 200 + code!=200）的提示，
 *   也让调用方能走到 catch，不再"静默成功"。
 *   想跳过自动提示：请求 config 上加 `silent: true`。
 * ------------------------------------------------------------------ */
api.interceptors.response.use(
  res => {
    removePending(res.config)

    // blob / arraybuffer（文件导出、下载）直接返回，不做业务码解析
    const responseType = res.config?.responseType
    if (responseType === 'blob' || responseType === 'arraybuffer') {
      return res.data
    }

    const body = res.data
    // 非标准包装体（例如纯字符串 / 数组）原样返回，避免误伤
    if (!body || typeof body !== 'object' || body.code == null) {
      return body
    }

    if (body.code !== 200) {
      const msg = body.msg || body.message || '请求失败'
      if (!res.config?.silent) ElMessage.error(msg)
      const err = new Error(msg)
      err.code = body.code
      err.msg = msg
      err.data = body.data
      err.response = res
      err.config = res.config
      err.isBizError = true
      // 业务码失败同样要从 pending map 里摘掉，否则后续同名请求会被误取消
      removePending(res.config)
      return Promise.reject(err)
    }

    return body
  },
  err => {
    removePending(err.config)

    // 主动取消的重复请求：静默，不弹提示
    if (isCanceled(err)) {
      return Promise.reject(err)
    }

    const status = err.response?.status
    const cfg = err.config || {}

    if (status === 401) {
      if (!cfg.silent) ElMessage.error('登录已失效，请重新登录')
      handleUnauthorized()
    } else if (status === 403) {
      if (!cfg.silent) ElMessage.error('无权限访问')
      goForbidden()
    } else if (err.code === 'ECONNABORTED' || /timeout/i.test(err.message || '')) {
      if (!cfg.silent) ElMessage.error('请求超时，请稍后重试')
    } else if (!cfg.silent) {
      ElMessage.error(err.response?.data?.msg || err.message || '网络错误')
    }

    return Promise.reject(err)
  }
)

export default api
