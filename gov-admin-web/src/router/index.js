import { createRouter, createWebHashHistory } from 'vue-router'
import MainLayout from '../layout/MainLayout.vue'
import { useUserStore } from '../stores/user'
import { usePermissionStore } from '../stores/permission'
import { getRouters, getPermissions } from '../api/menu'
import { buildRoutes } from './dynamic'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue')
  },
  {
    path: '/screen',
    name: 'BigScreen',
    component: () => import('../views/BigScreen.vue'),
    meta: { title: '数据大屏' }
  },
  {
    path: '/verify',
    name: 'Verify',
    component: () => import('../views/Verify.vue'),
    meta: { title: '证照验真' }
  },
  {
    path: '/',
    name: 'MainLayout',
    component: MainLayout,
    redirect: '/dashboard',
    children: []
  },
  {
    path: '/403',
    name: 'Forbidden',
    component: () => import('../views/403.vue'),
    meta: { title: '无权限' }
  }
  // ========== 删掉这里的 404通配路由！！不要写在这里 ==========
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

const WHITE_LIST = ['/login', '/screen', '/verify', '/403']

// 定义404路由，后面动态添加
const NotFoundRoute = {
  path: '/:pathMatch(.*)*',
  name: 'NotFound',
  component: () => import('../views/404.vue'),
  meta: { title: '页面不存在' }
}

router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()
  const permissionStore = usePermissionStore()
  const token = userStore.token || localStorage.getItem('token')

  if (!token) {
    if (WHITE_LIST.includes(to.path)) return next()
    return next('/login')
  }

  if (to.path === '/login') {
    return next('/')
  }

  if (permissionStore.loaded) {
    return next()
  }

  try {
    const [routerRes, permRes] = await Promise.all([getRouters(), getPermissions()])
    if (routerRes.code !== 200) {
      throw new Error(routerRes.msg || '加载菜单失败')
    }
    const menuTree = routerRes.data || []
    permissionStore.setMenuTree(menuTree)
    if (permRes.code === 200) {
      userStore.setPermissions(permRes.data || [])
    }
    const dynamicRoutes = buildRoutes(menuTree)
    dynamicRoutes.forEach(r => router.addRoute('MainLayout', r))

    // ✅ 全部动态路由添加完毕后，再添加404兜底路由！
    router.addRoute(NotFoundRoute)

    permissionStore.loaded = true
    // 重新进入当前路由，此时路由表已经完整
    return next({ ...to, replace: true })
  } catch (e) {
    console.error('[router] 加载动态路由失败', e)
    userStore.clear()
    permissionStore.clear()
    // 接口失败也要加上404路由
    router.addRoute(NotFoundRoute)
    return next('/login')
  }
})

export default router