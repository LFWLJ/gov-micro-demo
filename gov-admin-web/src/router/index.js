import { createRouter, createWebHistory } from 'vue-router'
import MainLayout from '../layout/MainLayout.vue'

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
    component: MainLayout,
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('../views/Dashboard.vue'),
        meta: { title: '首页' }
      },
      {
        path: 'application',
        name: 'Application',
        component: () => import('../views/Application.vue'),
        meta: { title: '事项管理' }
      },
      {
        path: 'process',
        name: 'Process',
        component: () => import('../views/Process.vue'),
        meta: { title: '审批流程' }
      },
      {
        path: 'file',
        name: 'File',
        component: () => import('../views/File.vue'),
        meta: { title: '文件管理' }
      },
      {
        path: 'operlog',
        name: 'OperLog',
        component: () => import('../views/OperLog.vue'),
        meta: { title: '操作日志' }
      },
      {
        path: 'user',
        name: 'User',
        component: () => import('../views/User.vue'),
        meta: { title: '用户管理' }
      },
      {
        path:'dept',
        name:'Dept',
        component: () => import('../views/Dept.vue'),
        meta: {title: '部门管理'}
      },
        {
        path: 'report',
        name: 'Report',
        component: () => import('../views/Report.vue'),
        meta: { title: '统计报表' }
      },
       {
        path: 'license',
        name: 'License',
        component: () => import('../views/License.vue'),
        meta: { title: '电子证照' }
      },
        {
        path: 'dict',
        name: 'Dict',
        component: () => import('../views/Dict.vue'),
        meta: { title: '数据字典' }
      },
        {
        path: 'evaluation',
        name: 'Evaluation',
        component: () => import('../views/Evaluation.vue'),
        meta: { title: '好差评' }
      },
      {
        path: 'config',
        name: 'Config',
        component: () => import('../views/Config.vue'),
        meta: { title: '系统配置' }
      },
      {
        path: 'guide',
        name: 'Guide',
        component: () => import('../views/Guide.vue'),
        meta: { title: '办事指南' }
      },
      {
        path: 'appointment',
        name: 'Appointment',
        component: () => import('../views/Appointment.vue'),
        meta: { title: '预约取号' }
      },
       {
        path: 'profile',
        name: 'Profile',
        component: () => import('../views/Profile.vue'),
        meta: { title: '个人中心' }
      },
      {
        path: 'consult',
        name: 'Consult',
        component: () => import('../views/Consult.vue'),
        meta: { title: '咨询投诉' }
      },
      {
        path: 'loginlog',
        name: 'LoginLog',
        component: () => import('../views/LoginLog.vue'),
        meta: { title: '登录日志' }
      },
      
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (to.path !== '/login' && !token) {
    next('/login')
  } else {
    next()
  }
})

export default router