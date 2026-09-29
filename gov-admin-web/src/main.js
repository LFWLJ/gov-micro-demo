import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { provideGlobalConfig } from 'element-plus'
import zhCn from 'element-plus/es/locale/lang/zh-cn'

// ---------------------------------------------------------------------------
// Element Plus 按需引入
//   1. 组件（<el-*>）与指令（v-loading）：vite.config.js 里 unplugin-vue-components
//      的 ElementPlusResolver 自动 import，并自动注入对应样式
//      （含 element-plus/theme-chalk/base.css 的 CSS 变量）。
//   2. 编程式 API（ElMessage / ElMessageBox）：unplugin-auto-import 自动 import。
//   3. 因此这里**不再** `import ElementPlus` + `import 'element-plus/dist/index.css'`
//      （原来那份全量 CSS 是 360 kB）。
//   4. 也不再遍历注册全部约 800 个图标，改为在使用处显式 import，
//      动态菜单图标走 src/icons/index.js 的注册表。
// ---------------------------------------------------------------------------
import App from './App.vue'
import router from './router/index.js'
import permission from './directives/permission'

const app = createApp(App)

app.use(createPinia())
app.use(router)

// ↓ 全局中文语言包（等价于原来 app.use(ElementPlus, { locale: zhCn }) 的效果）
provideGlobalConfig({ locale: zhCn }, app, true)

// ↓ 注册按钮权限指令
app.directive('perm', permission)

app.mount('#app')
