/**
 * ECharts 按需引入统一注册入口
 *
 * 不要在这些文件里 `import * as echarts from 'echarts'`（会打进全量包 ~1.1MB）。
 * 统一从这里 import，保证两个图表页面注册的模块一致、不重复。
 *
 * 目前项目实际用到的能力（已对照 BigScreen.vue / Report.vue 的真实代码）：
 *   图表：pie、bar、line
 *   组件：grid（笛卡尔坐标系，含 xAxis/yAxis 内置）、tooltip、legend、title
 *   渲染器：CanvasRenderer
 *   另外用到 echarts.graphic.LinearGradient（通过 echarts/core 的 graphic 导出）
 */
import * as echarts from 'echarts/core'
import { PieChart, BarChart, LineChart } from 'echarts/charts'
import {
  GridComponent,
  TooltipComponent,
  LegendComponent,
  TitleComponent
} from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'

echarts.use([
  PieChart,
  BarChart,
  LineChart,
  GridComponent,
  TooltipComponent,
  LegendComponent,
  TitleComponent,
  CanvasRenderer
])

// graphic（LinearGradient 等）由 echarts/core 透传自 zrender，按需模式下依然可用
export const graphic = echarts.graphic

export { echarts }
export default echarts
