<template>
  <el-card>
    <template #header>
      <div style="font-weight:bold;">办件统计报表</div>
    </template>

    <!-- 查询条件 -->
    <el-form :inline="true" :model="query" style="margin-bottom:12px;">
      <el-form-item label="时间范围">
        <el-date-picker
          v-model="timeRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          value-format="YYYY-MM-DD"
          style="width:280px"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="load">查询</el-button>
        <el-button type="success" :loading="exporting" @click="handleExport">
          导出 Excel
        </el-button>
      </el-form-item>
    </el-form>

    <!-- 汇总卡片 -->
    <el-row :gutter="16" style="margin-bottom:16px;">
      <el-col :span="6">
        <div class="stat-box">
          <div class="stat-value">{{ summary.total || 0 }}</div>
          <div class="stat-label">总办件</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-box" style="border-color:#67c23a;">
          <div class="stat-value" style="color:#67c23a;">{{ summary.approved || 0 }}</div>
          <div class="stat-label">已通过</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-box" style="border-color:#e6a23c;">
          <div class="stat-value" style="color:#e6a23c;">{{ summary.pending || 0 }}</div>
          <div class="stat-label">待审批</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-box" style="border-color:#909399;">
          <div class="stat-value" style="color:#909399;">{{ summary.draft || 0 }}</div>
          <div class="stat-label">草稿</div>
        </div>
      </el-col>
    </el-row>

    <!-- 图表 -->
    <el-row :gutter="16" style="margin-bottom:16px;">
      <el-col :span="12">
        <el-card shadow="never">
          <div style="font-weight:bold;margin-bottom:10px;">部门办件排名</div>
          <div ref="deptChartRef" style="height:320px;"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never">
          <div style="font-weight:bold;margin-bottom:10px;">日期趋势</div>
          <div ref="dateChartRef" style="height:320px;"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 部门统计表 -->
    <el-card shadow="never">
      <div style="font-weight:bold;margin-bottom:10px;">部门统计明细</div>
      <el-table :data="deptList" border stripe>
        <el-table-column prop="deptName" label="部门" />
        <el-table-column prop="total" label="总办件" width="100" />
        <el-table-column prop="approved" label="已通过" width="100" />
        <el-table-column prop="pending" label="待审批" width="100" />
        <el-table-column prop="draft" label="草稿" width="100" />
      </el-table>
    </el-card>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import { getSummary, statByDept, statByDate, exportExcel } from '../api/report'

const query = reactive({ startTime: '', endTime: '' })
const timeRange = ref(null)
const summary = reactive({})
const deptList = ref([])
const dateList = ref([])

const exporting = ref(false)
const deptChartRef = ref(null)
const dateChartRef = ref(null)
let deptChart = null, dateChart = null

async function load() {
  const params = {}
  if (timeRange.value && timeRange.value.length === 2) {
    params.startTime = timeRange.value[0]
    params.endTime = timeRange.value[1]
  }

  const s = await getSummary(params)
  if (s.code === 200) Object.assign(summary, s.data)

  const d = await statByDept(params)
  if (d.code === 200) {
    deptList.value = d.data || []
    await nextTick()
    renderDeptChart()
  }

  const dt = await statByDate(params)
  if (dt.code === 200) {
    dateList.value = dt.data || []
    await nextTick()
    renderDateChart()
  }
}

function renderDeptChart() {
  if (!deptChartRef.value) return
  if (!deptChart) deptChart = echarts.init(deptChartRef.value)
  deptChart.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: 120, right: 30, top: 20, bottom: 30 },
    xAxis: { type: 'value' },
    yAxis: {
      type: 'category',
      data: deptList.value.map(d => d.deptName).reverse()
    },
    series: [{
      type: 'bar',
      data: deptList.value.map(d => d.total).reverse(),
      itemStyle: { color: '#409eff' },
      barWidth: 18,
      label: { show: true, position: 'right' }
    }]
  })
}

function renderDateChart() {
  if (!dateChartRef.value) return
  if (!dateChart) dateChart = echarts.init(dateChartRef.value)
  dateChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['总办件', '已通过'], bottom: 0 },
    grid: { left: 40, right: 20, top: 20, bottom: 40 },
    xAxis: { type: 'category', data: dateList.value.map(d => d.date) },
    yAxis: { type: 'value' },
    series: [
      { name: '总办件', type: 'line', smooth: true,
        data: dateList.value.map(d => d.total),
        itemStyle: { color: '#409eff' } },
      { name: '已通过', type: 'line', smooth: true,
        data: dateList.value.map(d => d.approved),
        itemStyle: { color: '#67c23a' } }
    ]
  })
}

async function handleExport() {
  exporting.value = true
  try {
    const params = {}
    if (timeRange.value && timeRange.value.length === 2) {
      params.startTime = timeRange.value[0]
      params.endTime = timeRange.value[1]
    }
    const blob = await exportExcel(params)

    // 下载
    const url = window.URL.createObjectURL(new Blob([blob]))
    const a = document.createElement('a')
    a.href = url
    a.download = `办件明细_${new Date().getTime()}.xlsx`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
    ElMessage.success('导出成功')
  } catch (e) {
    ElMessage.error('导出失败')
  } finally {
    exporting.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.stat-box {
  background: #fff;
  border: 2px solid #409eff;
  border-radius: 6px;
  padding: 18px;
  text-align: center;
}
.stat-value {
  font-size: 32px;
  font-weight: bold;
  color: #409eff;
}
.stat-label {
  font-size: 13px;
  color: #909399;
  margin-top: 6px;
}
</style>