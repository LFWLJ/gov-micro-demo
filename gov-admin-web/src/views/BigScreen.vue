<template>
  <div class="screen">
    <!-- 顶部 -->
    <div class="header">
      <div class="header-left">{{ nowDate }}</div>
      <div class="header-title">政务数据驾驶舱</div>
      <div class="header-right">
        <span class="exit-btn" @click="exitScreen">返回系统</span>
      </div>
    </div>

    <!-- 顶部指标行 -->
    <div class="top-stats">
      <div class="top-item">
        <div class="top-value">{{ ov.totalApplications || 0 }}</div>
        <div class="top-label">累计办件</div>
      </div>
      <div class="top-item">
        <div class="top-value c-cyan">{{ ov.pendingTasks || 0 }}</div>
        <div class="top-label">待办任务</div>
      </div>
      <div class="top-item">
        <div class="top-value c-green">{{ ov.approvalRate || 0 }}%</div>
        <div class="top-label">办结率</div>
      </div>
      <div class="top-item">
        <div class="top-value c-orange">{{ ov.todayApplications || 0 }}</div>
        <div class="top-label">今日办件</div>
      </div>
      <div class="top-item">
        <div class="top-value c-purple">{{ ov.userCount || 0 }}</div>
        <div class="top-label">用户数</div>
      </div>
      <div class="top-item">
        <div class="top-value c-pink">{{ appt.todayTotal || 0 }}</div>
        <div class="top-label">今日预约</div>
      </div>
      <div class="top-item">
        <div class="top-value c-blue">{{ evalStat.goodRate || 0 }}%</div>
        <div class="top-label">好评率</div>
      </div>
      <div class="top-item">
        <div class="top-value c-yellow">{{ license.total || 0 }}</div>
        <div class="top-label">电子证照</div>
      </div>
    </div>

    <!-- 主体 -->
    <div class="main">
      <!-- 左列 -->
      <div class="col">
        <div class="card">
          <div class="card-title">事项状态分布</div>
          <div ref="statusRef" class="chart chart-md"></div>
        </div>
        <div class="card">
          <div class="card-title">部门办件排名</div>
          <div ref="rankRef" class="chart chart-md"></div>
        </div>
        <div class="card">
          <div class="card-title">各模块业务量对比</div>
          <div ref="moduleRef" class="chart chart-md"></div>
        </div>
      </div>

      <!-- 中列 -->
      <div class="col col-center">
        <div class="center-hero">
          <div class="hero-value">{{ ov.totalApplications || 0 }}</div>
          <div class="hero-label">累计办件量</div>
        </div>

        <div class="card">
          <div class="card-title">近 7 天办件趋势</div>
          <div ref="trendRef" class="chart chart-lg"></div>
        </div>

        <div class="card">
          <div class="card-title">24 小时办件分布</div>
          <div ref="hourRef" class="chart chart-md"></div>
        </div>
      </div>

      <!-- 右列 -->
      <div class="col">
        <div class="card">
          <div class="card-title">好差评统计</div>
          <div class="mini-stat-grid">
            <div class="mini-item">
              <div class="mini-value">{{ evalStat.total || 0 }}</div>
              <div class="mini-label">评价总数</div>
            </div>
            <div class="mini-item">
              <div class="mini-value c-green">{{ evalStat.goodCount || 0 }}</div>
              <div class="mini-label">好评</div>
            </div>
            <div class="mini-item">
              <div class="mini-value c-red">{{ evalStat.badCount || 0 }}</div>
              <div class="mini-label">差评</div>
            </div>
            <div class="mini-item">
              <div class="mini-value c-orange">{{ evalStat.pendingRectify || 0 }}</div>
              <div class="mini-label">待整改</div>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-title">预约取号（今日）</div>
          <div class="mini-stat-grid">
            <div class="mini-item">
              <div class="mini-value c-cyan">{{ appt.todayBooked || 0 }}</div>
              <div class="mini-label">待签到</div>
            </div>
            <div class="mini-item">
              <div class="mini-value c-orange">{{ appt.todayChecked || 0 }}</div>
              <div class="mini-label">已签到</div>
            </div>
            <div class="mini-item">
              <div class="mini-value c-green">{{ appt.todayDone || 0 }}</div>
              <div class="mini-label">已办结</div>
            </div>
            <div class="mini-item">
              <div class="mini-value c-pink">{{ appt.todayTotal || 0 }}</div>
              <div class="mini-label">今日总数</div>
            </div>
          </div>
        </div>

        <div class="card">
          <div class="card-title">咨询投诉</div>
          <div class="mini-stat-grid">
            <div class="mini-item">
              <div class="mini-value c-orange">{{ consult.pending || 0 }}</div>
              <div class="mini-label">待处理</div>
            </div>
            <div class="mini-item">
              <div class="mini-value c-cyan">{{ consult.processing || 0 }}</div>
              <div class="mini-label">处理中</div>
            </div>
            <div class="mini-item">
              <div class="mini-value c-green">{{ consult.done || 0 }}</div>
              <div class="mini-label">已办结</div>
            </div>
            <div class="mini-item">
              <div class="mini-value">{{ consult.total || 0 }}</div>
              <div class="mini-label">总数</div>
            </div>
          </div>
        </div>

        <div class="card card-full">
          <div class="card-title">实时动态</div>
          <div class="log-list">
            <div v-for="(log, idx) in recentLogs" :key="idx" class="log-item">
              <span class="log-time">{{ formatTime(log.time) }}</span>
              <span class="log-module">{{ log.module }}</span>
              <span class="log-op">{{ log.operation }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 底部：其他统计 -->
    <div class="bottom-bar">
      <div class="bottom-item">
        <span class="b-label">办事指南</span>
        <span class="b-value c-cyan">{{ guide.total || 0 }}</span>
        <span class="b-sub">启用 {{ guide.enabled || 0 }} / 分类 {{ guide.categoryCount || 0 }}</span>
      </div>
      <div class="bottom-item">
        <span class="b-label">电子证照</span>
        <span class="b-value c-green">{{ license.valid || 0 }}</span>
        <span class="b-sub">本月新增 {{ license.thisMonth || 0 }} / 已吊销 {{ license.revoked || 0 }}</span>
      </div>
      <div class="bottom-item">
        <span class="b-label">文件总数</span>
        <span class="b-value c-blue">{{ file.total || 0 }}</span>
        <span class="b-sub">总大小 {{ file.totalSizeText || '0 B' }}</span>
      </div>
      <div class="bottom-item">
        <span class="b-label">平均审批时长</span>
        <span class="b-value c-orange">{{ ov.avgHours || 0 }} h</span>
      </div>
      <div class="bottom-item">
        <span class="b-label">操作日志</span>
        <span class="b-value c-purple">{{ ov.logCount || 0 }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import * as echarts from 'echarts'
import { getScreenOverview } from '../api/screen'

const router = useRouter()

const ov = reactive({})
const appt = reactive({})
const evalStat = reactive({})
const license = reactive({})
const guide = reactive({})
const consult = reactive({})
const file = reactive({})
const trend = reactive({ days: [], newApplications: [], completed: [] })
const statusDist = ref([])
const deptRank = ref([])
const hourDist = ref([])
const moduleStats = ref([])
const recentLogs = ref([])
const nowDate = ref('')

let timer = null
const statusRef = ref(null)
const rankRef = ref(null)
const moduleRef = ref(null)
const trendRef = ref(null)
const hourRef = ref(null)
let statusChart = null, rankChart = null, moduleChart = null, trendChart = null, hourChart = null

const axisStyle = {
  axisLine: { lineStyle: { color: 'rgba(0, 229, 255, 0.3)' } },
  axisLabel: { color: '#8ec5ff', fontSize: 11 },
  splitLine: { lineStyle: { color: 'rgba(0, 229, 255, 0.1)' } }
}

async function load() {
  const res = await getScreenOverview()
  if (res.code !== 200) return
  const d = res.data

  Object.assign(ov, d.overview || {})
  Object.assign(appt, d.appointment || {})
  Object.assign(evalStat, d.evaluation || {})
  Object.assign(license, d.license || {})
  Object.assign(guide, d.guide || {})
  Object.assign(consult, d.consult || {})
  Object.assign(file, d.file || {})
  Object.assign(trend, d.trend || {})
  statusDist.value = d.statusDist || []
  deptRank.value = d.deptRank || []
  hourDist.value = d.hourDist || []
  moduleStats.value = d.moduleStats || []
  recentLogs.value = d.recentLogs || []

  await nextTick()
  renderAll()
}

function renderAll() {
  renderStatus()
  renderRank()
  renderModule()
  renderTrend()
  renderHour()
}

function renderStatus() {
  if (!statusRef.value) return
  if (!statusChart) statusChart = echarts.init(statusRef.value)
  statusChart.setOption({
    tooltip: { trigger: 'item' },
    legend: { bottom: 0, textStyle: { color: '#8ec5ff', fontSize: 11 } },
    series: [{
      type: 'pie',
      radius: ['40%', '65%'],
      center: ['50%', '45%'],
      data: statusDist.value.map(s => ({
        name: s.name, value: s.value,
        itemStyle: { color: s.color }
      })),
      label: { color: '#fff', fontSize: 11, formatter: '{b}\n{c}' }
    }]
  })
}

function renderRank() {
  if (!rankRef.value) return
  if (!rankChart) rankChart = echarts.init(rankRef.value)
  rankChart.setOption({
    grid: { left: 110, right: 30, top: 10, bottom: 20 },
    xAxis: { type: 'value', ...axisStyle },
    yAxis: {
      type: 'category',
      data: deptRank.value.map(d => d.name).reverse(),
      axisLine: { lineStyle: { color: 'rgba(0, 229, 255, 0.3)' } },
      axisLabel: { color: '#8ec5ff', fontSize: 11 }
    },
    series: [{
      type: 'bar',
      data: deptRank.value.map(d => d.value).reverse(),
      itemStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
          { offset: 0, color: '#00e5ff' }, { offset: 1, color: '#00a8cc' }
        ])
      },
      barWidth: 12,
      label: { show: true, position: 'right', color: '#00e5ff', fontSize: 11 }
    }]
  })
}

function renderModule() {
  if (!moduleRef.value) return
  if (!moduleChart) moduleChart = echarts.init(moduleRef.value)
  moduleChart.setOption({
    grid: { left: 40, right: 20, top: 20, bottom: 30 },
    tooltip: { trigger: 'axis' },
    xAxis: {
      type: 'category',
      data: moduleStats.value.map(m => m.name),
      ...axisStyle
    },
    yAxis: { type: 'value', ...axisStyle },
    series: [{
      type: 'bar',
      data: moduleStats.value.map(m => m.value),
      itemStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: '#00e5ff' }, { offset: 1, color: '#004a77' }
        ])
      },
      barWidth: 20,
      label: { show: true, position: 'top', color: '#00e5ff', fontSize: 11 }
    }]
  })
}

function renderTrend() {
  if (!trendRef.value) return
  if (!trendChart) trendChart = echarts.init(trendRef.value)
  trendChart.setOption({
    grid: { left: 45, right: 20, top: 30, bottom: 35 },
    tooltip: { trigger: 'axis' },
    legend: { data: ['新增办件', '完成审批'], textStyle: { color: '#8ec5ff' }, top: 0 },
    xAxis: { type: 'category', data: trend.days, ...axisStyle },
    yAxis: { type: 'value', ...axisStyle },
    series: [
      {
        name: '新增办件', type: 'line', smooth: true, data: trend.newApplications,
        itemStyle: { color: '#00e5ff' }, lineStyle: { width: 2 },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(0, 229, 255, 0.4)' },
            { offset: 1, color: 'rgba(0, 229, 255, 0)' }
          ])
        }
      },
      {
        name: '完成审批', type: 'line', smooth: true, data: trend.completed,
        itemStyle: { color: '#67c23a' }, lineStyle: { width: 2 },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(103, 194, 58, 0.4)' },
            { offset: 1, color: 'rgba(103, 194, 58, 0)' }
          ])
        }
      }
    ]
  })
}

function renderHour() {
  if (!hourRef.value) return
  if (!hourChart) hourChart = echarts.init(hourRef.value)
  hourChart.setOption({
    grid: { left: 45, right: 20, top: 15, bottom: 30 },
    tooltip: { trigger: 'axis' },
    xAxis: {
      type: 'category',
      data: Array.from({ length: 24 }, (_, i) => i + '时'),
      ...axisStyle,
      axisLabel: { color: '#8ec5ff', fontSize: 10, interval: 2 }
    },
    yAxis: { type: 'value', ...axisStyle },
    series: [{
      type: 'line',
      data: hourDist.value,
      smooth: true,
      symbol: 'circle',
      symbolSize: 5,
      itemStyle: { color: '#00e5ff' },
      lineStyle: { width: 2 },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(0, 229, 255, 0.4)' },
          { offset: 1, color: 'rgba(0, 229, 255, 0)' }
        ])
      }
    }]
  })
}

function formatTime(t) {
  if (!t) return ''
  const s = String(t)
  const idx = s.indexOf('T')
  return idx > 0 ? s.substring(idx + 1, idx + 9) : s.substring(11, 19)
}

function updateTime() {
  const d = new Date()
  const pad = n => String(n).padStart(2, '0')
  nowDate.value = `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
}

function exitScreen() { router.push('/dashboard') }

function resize() {
  statusChart?.resize(); rankChart?.resize(); moduleChart?.resize()
  trendChart?.resize(); hourChart?.resize()
}

onMounted(() => {
  updateTime()
  timer = setInterval(() => { updateTime(); load() }, 30000)
  window.addEventListener('resize', resize)
  load()
})

onUnmounted(() => {
  clearInterval(timer)
  window.removeEventListener('resize', resize)
  statusChart?.dispose(); rankChart?.dispose(); moduleChart?.dispose()
  trendChart?.dispose(); hourChart?.dispose()
})
</script>

<style scoped>
* { box-sizing: border-box; }

.screen {
  width: 100vw; height: 100vh;
  background: radial-gradient(ellipse at center, #0a2140 0%, #061428 100%);
  color: #fff; overflow: hidden; display: flex; flex-direction: column;
}

.header {
  height: 55px; display: flex; align-items: center; justify-content: space-between;
  padding: 0 24px;
  background: linear-gradient(180deg, rgba(0, 100, 180, 0.3), transparent);
  border-bottom: 1px solid rgba(0, 229, 255, 0.2);
  position: relative;
  flex-shrink: 0;
}
.header-title {
  position: absolute; left: 50%; transform: translateX(-50%);
  font-size: 22px; font-weight: bold;
  background: linear-gradient(180deg, #fff, #00e5ff);
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  letter-spacing: 4px;
}
.header-left { font-size: 13px; color: #8ec5ff; }
.exit-btn {
  padding: 5px 14px; border: 1px solid rgba(0, 229, 255, 0.5);
  border-radius: 4px; color: #00e5ff; cursor: pointer; font-size: 12px;
}
.exit-btn:hover { background: rgba(0, 229, 255, 0.15); }

/* 顶部指标 */
.top-stats {
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: 8px;
  padding: 8px 16px;
  flex-shrink: 0;
}
.top-item {
  background: rgba(10, 45, 90, 0.5);
  border: 1px solid rgba(0, 229, 255, 0.25);
  border-radius: 4px;
  padding: 8px 10px;
  text-align: center;
}
.top-value {
  font-size: 22px; font-weight: bold; color: #00e5ff;
  text-shadow: 0 0 8px rgba(0, 229, 255, 0.6);
  font-family: 'DIN Alternate', monospace;
  line-height: 1.1;
}
.top-label { font-size: 11px; color: #8ec5ff; margin-top: 2px; }

.c-cyan { color: #00e5ff !important; }
.c-green { color: #67c23a !important; }
.c-orange { color: #e6a23c !important; }
.c-red { color: #f56c6c !important; }
.c-blue { color: #409eff !important; }
.c-purple { color: #a78bfa !important; }
.c-pink { color: #ec4899 !important; }
.c-yellow { color: #fbbf24 !important; }

/* 主体 */
.main {
  flex: 1;
  display: grid;
  grid-template-columns: 25% 1fr 25%;
  gap: 10px;
  padding: 0 16px 8px;
  overflow: hidden;
}
.col { display: flex; flex-direction: column; gap: 8px; overflow: hidden; }
.col-center { justify-content: space-between; }

.card {
  background: rgba(10, 45, 90, 0.5);
  border: 1px solid rgba(0, 229, 255, 0.25);
  border-radius: 6px;
  padding: 8px 10px;
  position: relative;
  backdrop-filter: blur(10px);
  box-shadow: inset 0 0 20px rgba(0, 150, 255, 0.1);
}
.card::before, .card::after {
  content: ''; position: absolute; width: 30px; height: 2px;
  background: #00e5ff; box-shadow: 0 0 8px #00e5ff;
}
.card::before { top: 0; left: 0; }
.card::after { bottom: 0; right: 0; }
.card-title {
  font-size: 12px; color: #8ec5ff; margin-bottom: 6px; padding-left: 10px;
  position: relative; font-weight: bold;
}
.card-title::before {
  content: ''; position: absolute; left: 0; top: 50%; transform: translateY(-50%);
  width: 3px; height: 12px; background: #00e5ff; box-shadow: 0 0 6px #00e5ff;
}
.card-full { flex: 1; display: flex; flex-direction: column; overflow: hidden; }

.chart { width: 100%; }
.chart-md { height: 140px; }
.chart-lg { height: 200px; }

.center-hero { text-align: center; padding: 5px 0; flex-shrink: 0; }
.hero-value {
  font-size: 52px; font-weight: bold;
  background: linear-gradient(180deg, #fff, #00e5ff);
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  text-shadow: 0 0 25px rgba(0, 229, 255, 0.6);
  font-family: 'DIN Alternate', monospace; line-height: 1;
}
.hero-label { font-size: 13px; color: #8ec5ff; margin-top: 2px; letter-spacing: 3px; }

/* 迷你统计网格 */
.mini-stat-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 6px;
}
.mini-item {
  background: rgba(0, 150, 255, 0.08);
  border-radius: 3px;
  padding: 6px 4px;
  text-align: center;
}
.mini-value {
  font-size: 18px; font-weight: bold; color: #00e5ff;
  font-family: 'DIN Alternate', monospace;
  line-height: 1.1;
}
.mini-label { font-size: 10px; color: #8ec5ff; margin-top: 2px; }

/* 日志列表 */
.log-list { flex: 1; overflow: hidden; }
.log-item {
  padding: 4px 0; border-bottom: 1px dashed rgba(0, 229, 255, 0.15);
  font-size: 11px; color: #8ec5ff; display: flex; gap: 8px; align-items: center;
}
.log-time { color: #00e5ff; font-family: monospace; flex-shrink: 0; }
.log-module { color: #e6a23c; flex-shrink: 0; }
.log-op { color: #fff; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

/* 底部栏 */
.bottom-bar {
  height: 50px;
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 10px;
  padding: 0 16px 10px;
  flex-shrink: 0;
}
.bottom-item {
  background: rgba(10, 45, 90, 0.5);
  border: 1px solid rgba(0, 229, 255, 0.25);
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  font-size: 12px;
}
.b-label { color: #8ec5ff; }
.b-value {
  font-size: 20px; font-weight: bold; color: #00e5ff;
  font-family: 'DIN Alternate', monospace;
}
.b-sub { font-size: 11px; color: #6b8db5; }
</style>