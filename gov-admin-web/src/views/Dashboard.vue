<template>
  <div v-loading="loading">
    <el-row :gutter="16">
      <el-col :span="6">
        <el-card shadow="hover">
          <div style="font-size:13px;color:#909399;">事项总数</div>
          <div style="font-size:24px;font-weight:bold;">{{ stats.totalApplications || 0 }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div style="font-size:13px;color:#909399;">待办任务</div>
          <div style="font-size:24px;font-weight:bold;">{{ stats.pendingTasks || 0 }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div style="font-size:13px;color:#909399;">用户数</div>
          <div style="font-size:24px;font-weight:bold;">{{ stats.userCount || 0 }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div style="font-size:13px;color:#909399;">操作日志</div>
          <div style="font-size:24px;font-weight:bold;">{{ stats.logCount || 0 }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="16" style="margin-top:16px;">
      <el-col :span="12">
        <el-card>
          <div style="font-weight:bold;margin-bottom:12px;">事项状态分布</div>
          <div ref="pieRef" style="height:320px;"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <div style="font-weight:bold;margin-bottom:12px;">最近 7 天趋势</div>
          <div ref="lineRef" style="height:320px;"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import api from '../api/request'

const loading = ref(false)
const stats = reactive({})
const pieRef = ref(null)
const lineRef = ref(null)

let pieChart = null
let lineChart = null

async function load() {
  loading.value = true
  try {
    const res = await api.get('/api/dashboard/stats')
    if (res.code === 200) {
      Object.assign(stats, res.data)
      await nextTick()
      renderPie()
      renderLine()
    }
  } finally {
    loading.value = false
  }
}

function renderPie() {
  if (!pieRef.value) return
  if (!pieChart) pieChart = echarts.init(pieRef.value)
  const sc = stats.statusCount || {}
  pieChart.setOption({
    tooltip: { trigger: 'item' },
    legend: { bottom: 10 },
    series: [{
      type: 'pie',
      radius: ['40%', '65%'],
      data: [
        { value: sc.DRAFT || 0, name: '草稿', itemStyle: { color: '#909399' } },
        { value: sc.PENDING || 0, name: '待审批', itemStyle: { color: '#e6a23c' } },
        { value: sc.APPROVED || 0, name: '已通过', itemStyle: { color: '#67c23a' } }
      ],
      label: { formatter: '{b}: {c}' }
    }]
  })
}

function renderLine() {
  if (!lineRef.value) return
  if (!lineChart) lineChart = echarts.init(lineRef.value)
  const trend = stats.trend || []
  const logTrend = stats.logTrend || []
  lineChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['事项新增', '操作日志'], bottom: 10 },
    grid: { left: 40, right: 20, top: 20, bottom: 50 },
    xAxis: { type: 'category', data: trend.map(t => t.date) },
    yAxis: { type: 'value' },
    series: [
      {
        name: '事项新增', type: 'line', smooth: true,
        data: trend.map(t => t.count),
        itemStyle: { color: '#409eff' }
      },
      {
        name: '操作日志', type: 'line', smooth: true,
        data: logTrend.map(t => t.count),
        itemStyle: { color: '#67c23a' }
      }
    ]
  })
}

onMounted(load)
</script>