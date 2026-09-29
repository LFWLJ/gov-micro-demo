import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import AutoImport from 'unplugin-auto-import/vite'
import Components from 'unplugin-vue-components/vite'
import { ElementPlusResolver } from 'unplugin-vue-components/resolvers'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig({
  plugins: [
    vue(),
    // Element Plus 的编程式 API（ElMessage / ElMessageBox / ElLoading ...）按需自动 import
    AutoImport({
      imports: [],                    // 只处理 Element Plus，不接管 vue / vue-router 的导入
      resolvers: [ElementPlusResolver()],
      // 自动生成的类型声明（仅给 IDE 用）
      dts: 'src/types/auto-imports.d.ts',
      eslintrc: { enabled: false }
    }),
    // 模板里的 <el-*> 组件与 v-loading 等指令按需引入 + 按需注入样式
    Components({
      dirs: [],                       // 不自动扫描本地组件，避免行为变化
      resolvers: [ElementPlusResolver({ importStyle: 'css' })],
      dts: 'src/types/components.d.ts'
    })
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  build: {
    rollupOptions: {
      output: {
        // 把 echarts 单独拆成 chunk：体积大、变化少，可长期缓存。
        // 注意：Vite 8 底层是 rolldown，manualChunks 只接受函数，不接受对象映射。
        manualChunks(id) {
          if (!id) return
          const p = id.replace(/\\/g, '/')
          if (p.includes('/node_modules/echarts/') || p.includes('/node_modules/zrender/')) {
            return 'echarts'
          }
        }
      }
    }
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:8090',
        changeOrigin: true
      }
    }
  }
})
