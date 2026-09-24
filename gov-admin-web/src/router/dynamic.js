// 扫描 views 下所有 .vue 组件（懒加载）
const modules = import.meta.glob('../views/*.vue')

// 独立路由（不走 MainLayout），动态路由生成时排除
const EXCLUDE_COMPONENTS = ['BigScreen', 'Verify', 'Login']

/**
 * 把后端菜单树转成 vue-router 路由配置
 * 说明：C 类型才生成路由，M 类型只作分组（不产生路由）
 */
export function buildRoutes(menuTree) {
  const routes = []

  const walk = (nodes) => {
    for (const node of nodes) {
      if (node.menuType === 'C') {
        const compName = node.component
        if (!compName) continue
        if (EXCLUDE_COMPONENTS.includes(compName)) continue

        const loader = modules[`../views/${compName}.vue`]
        if (!loader) {
          console.warn(`[dynamic] 未找到组件：views/${compName}.vue`)
          continue
        }

        // 去掉前导斜杠，作为 MainLayout 的相对子路由
        const path = (node.path || '').replace(/^\//, '')
        if (!path) continue

        routes.push({
          path,
          name: compName,
          component: loader,
          meta: {
            title: node.menuName,
            icon: node.icon || ''
          }
        })
      }
      if (node.children && node.children.length) {
        walk(node.children)
      }
    }
  }

  walk(menuTree)
  return routes
}