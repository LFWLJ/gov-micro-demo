/**
 * 图标集中注册表（替代 main.js 里"遍历注册全部约 800 个图标"的写法）
 *
 * 背景：@element-plus/icons-vue 的 dist/index.js 是单文件 barrel，
 * 一旦 `import * as Icons` 就会把全部图标打进包。这里改为**显式按需引入**。
 *
 * 两种用法：
 *   1. 模板里静态用到的图标，直接在所在文件里
 *      `import { Bell } from '@element-plus/icons-vue'`（推荐，最直观）。
 *   2. 后端菜单下发的 `icon` 是字符串（见 Menu.vue 的"图标名"输入框），
 *      模板里是 `<component :is="node.icon" />`，编译期无法静态解析，
 *      因此这里保留一个**按名查找**的小注册表供 layout 使用。
 *
 * ⚠️ 新增菜单图标时必须在这里补一行，否则图标不显示（菜单文字与跳转不受影响）。
 *    当前 registry 已覆盖 sys_menu 表中实际用到的全部图标（23 个），
 *    可通过如下 SQL 核对：
 *      SELECT DISTINCT icon FROM sys_menu WHERE icon IS NOT NULL AND icon <> '';
 */
import {
  // —— sys_menu 中实际在用的图标（务必保留）——
  Avatar,
  Briefcase,
  Calendar,
  ChatDotRound,
  Collection,
  Connection,
  DataLine,
  Document,
  Folder,
  HomeFilled,
  Key,
  Medal,
  Menu,
  Message,
  Monitor,
  Notebook,
  OfficeBuilding,
  PieChart,
  Setting,
  Star,
  Tickets,
  Tools,
  User,
  // —— 其余为界面内静态使用/预留 ——
  Bell,
  Checked,
  Clock,
  DataAnalysis,
  Delete,
  DocumentCopy,
  Download,
  EditPen,
  Files,
  House,
  List,
  Memo,
  Plus,
  Postcard,
  Refresh,
  Search,
  StarFilled,
  Upload,
  UploadFilled,
  UserFilled
} from '@element-plus/icons-vue'

/** 图标名 -> 组件 */
export const iconRegistry = {
  Avatar,
  Briefcase,
  Calendar,
  ChatDotRound,
  Collection,
  Connection,
  DataLine,
  Document,
  Folder,
  HomeFilled,
  Key,
  Medal,
  Menu,
  Message,
  Monitor,
  Notebook,
  OfficeBuilding,
  PieChart,
  Setting,
  Star,
  Tickets,
  Tools,
  User,
  Bell,
  Checked,
  Clock,
  DataAnalysis,
  Delete,
  DocumentCopy,
  Download,
  EditPen,
  Files,
  House,
  List,
  Memo,
  Plus,
  Postcard,
  Refresh,
  Search,
  StarFilled,
  Upload,
  UploadFilled,
  UserFilled
}

/** 按名字取图标组件；未登记返回 null */
export function resolveIcon(name) {
  if (!name) return null
  return iconRegistry[name] || null
}

export default iconRegistry
