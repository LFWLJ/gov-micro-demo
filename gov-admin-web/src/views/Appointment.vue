<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">预约取号</span>
        <div>
          <el-input
            v-model="query.keyword"
            placeholder="姓名/手机/预约号"
            style="width:180px; margin-right:8px;"
            clearable
            @keyup.enter="handleSearch"
          />
          <el-select
            v-model="query.status"
            placeholder="全部状态"
            style="width:130px; margin-right:8px;"
            clearable
            @change="handleSearch"
          >
            <el-option label="已预约" value="BOOKED" />
            <el-option label="已签到" value="CHECKED" />
            <el-option label="已办结" value="DONE" />
            <el-option label="已取消" value="CANCELLED" />
          </el-select>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button type="success" @click="openDialog()">新增预约</el-button>
        </div>
      </div>
    </template>

    <!-- 今日统计 -->
    <el-row :gutter="16" style="margin-bottom:16px;">
      <el-col :span="6">
        <div class="stat-box">
          <div class="stat-value">{{ stats.todayTotal || 0 }}</div>
          <div class="stat-label">今日预约</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-box" style="border-color:#409eff;">
          <div class="stat-value" style="color:#409eff;">{{ stats.todayBooked || 0 }}</div>
          <div class="stat-label">待签到</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-box" style="border-color:#e6a23c;">
          <div class="stat-value" style="color:#e6a23c;">{{ stats.todayChecked || 0 }}</div>
          <div class="stat-label">已签到</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-box" style="border-color:#67c23a;">
          <div class="stat-value" style="color:#67c23a;">{{ stats.todayDone || 0 }}</div>
          <div class="stat-label">已办结</div>
        </div>
      </el-col>
    </el-row>

    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="appointmentNo" label="预约号" width="160" />
      <el-table-column prop="queueNo" label="排队号" width="90" />
      <el-table-column prop="guideTitle" label="事项" width="180" />
      <el-table-column prop="visitorName" label="预约人" width="100" />
      <el-table-column prop="visitorPhone" label="手机号" width="130" />
      <el-table-column prop="appointDate" label="预约日期" width="120" />
      <el-table-column prop="timeSlot" label="时间段" width="120" />
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <el-tag v-if="row.status === 'BOOKED'" type="info">已预约</el-tag>
          <el-tag v-else-if="row.status === 'CHECKED'" type="warning">已签到</el-tag>
          <el-tag v-else-if="row.status === 'DONE'" type="success">已办结</el-tag>
          <el-tag v-else-if="row.status === 'CANCELLED'" type="danger">已取消</el-tag>
          <el-tag v-else>{{ row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200" fixed="right">
        <template #default="{ row }">
          <el-button
            v-if="row.status === 'BOOKED'"
            type="primary" link size="small"
            @click="handleCheckin(row)"
          >
            签到
          </el-button>
          <el-button
            v-if="row.status === 'CHECKED'"
            type="success" link size="small"
            @click="handleFinish(row)"
          >
            办结
          </el-button>
          <el-button
            v-if="row.status === 'BOOKED' || row.status === 'CHECKED'"
            type="warning" link size="small"
            @click="handleCancel(row)"
          >
            取消
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      style="margin-top:16px; text-align:right;"
      background
      layout="total, sizes, prev, pager, next"
      :total="total"
      :current-page="query.page"
      :page-size="query.size"
      :page-sizes="[10, 20, 50]"
      @current-change="(p) => { query.page = p; load(); }"
      @size-change="(s) => { query.size = s; query.page = 1; load(); }"
    />

    <!-- 新增预约弹窗 -->
    <el-dialog v-model="dialogVisible" title="新增预约" width="520px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="办理事项">
          <el-input v-model="form.guideTitle" placeholder="如 营业执照办理" />
        </el-form-item>
        <el-form-item label="事项编码">
          <el-input v-model="form.guideCode" placeholder="如 GUIDE-001" />
        </el-form-item>
        <el-form-item label="预约人" required>
          <el-input v-model="form.visitorName" />
        </el-form-item>
        <el-form-item label="手机号" required>
          <el-input v-model="form.visitorPhone" />
        </el-form-item>
        <el-form-item label="身份证号">
          <el-input v-model="form.visitorIdCard" />
        </el-form-item>
        <el-form-item label="办理部门">
          <el-input-number v-model="form.deptId" :min="1" />
        </el-form-item>
        <el-form-item label="预约日期" required>
          <el-date-picker
            v-model="form.appointDate"
            type="date"
            value-format="YYYY-MM-DD"
            :disabled-date="disabledDate"
            style="width:100%"
          />
        </el-form-item>
        <el-form-item label="时间段">
          <el-select v-model="form.timeSlot" style="width:100%">
            <el-option label="09:00-10:00" value="09:00-10:00" />
            <el-option label="10:00-11:00" value="10:00-11:00" />
            <el-option label="11:00-12:00" value="11:00-12:00" />
            <el-option label="14:00-15:00" value="14:00-15:00" />
            <el-option label="15:00-16:00" value="15:00-16:00" />
            <el-option label="16:00-17:00" value="16:00-17:00" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">提交预约</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  pageAppointments, createAppointment, checkinAppointment,
  finishAppointment, cancelAppointment, getAppointmentStats
} from '../api/appointment'

const list = ref([])
const total = ref(0)
const loading = ref(false)
const stats = reactive({})

const query = reactive({ page: 1, size: 10, keyword: '', status: '' })

const dialogVisible = ref(false)
const submitting = ref(false)
const form = reactive({
  guideCode: '',
  guideTitle: '',
  visitorName: '',
  visitorPhone: '',
  visitorIdCard: '',
  deptId: 2,
  appointDate: '',
  timeSlot: '09:00-10:00',
  remark: ''
})

function disabledDate(date) {
  // 只能选今天及以后
  return date.getTime() < Date.now() - 24 * 3600 * 1000
}

async function load() {
  loading.value = true
  try {
    const res = await pageAppointments(query)
    if (res.code === 200) {
      list.value = res.data.records || []
      total.value = res.data.total || 0
    }
  } finally {
    loading.value = false
  }
}

async function loadStats() {
  const res = await getAppointmentStats()
  if (res.code === 200) Object.assign(stats, res.data)
}

function handleSearch() {
  query.page = 1
  load()
}

function openDialog() {
  const tomorrow = new Date(Date.now() + 24 * 3600 * 1000)
  Object.assign(form, {
    guideCode: '', guideTitle: '',
    visitorName: '', visitorPhone: '', visitorIdCard: '',
    deptId: 2,
    appointDate: tomorrow.toISOString().substring(0, 10),
    timeSlot: '09:00-10:00',
    remark: ''
  })
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!form.visitorName || !form.visitorPhone || !form.appointDate) {
    ElMessage.warning('请填写预约人、手机号和日期')
    return
  }
  submitting.value = true
  try {
    const res = await createAppointment(form)
    if (res.code === 200) {
      ElMessage.success(`预约成功！预约号：${res.data.appointmentNo}，排队号：${res.data.queueNo}`)
      dialogVisible.value = false
      load()
      loadStats()
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    submitting.value = false
  }
}

async function handleCheckin(row) {
  await ElMessageBox.confirm(`确认签到「${row.visitorName}」？`, '提示')
  const res = await checkinAppointment(row.id)
  if (res.code === 200) {
    ElMessage.success('签到成功')
    load()
    loadStats()
  }
}

async function handleFinish(row) {
  await ElMessageBox.confirm(`确认办结「${row.visitorName}」的业务？`, '提示')
  const res = await finishAppointment(row.id)
  if (res.code === 200) {
    ElMessage.success('已办结')
    load()
    loadStats()
  }
}

async function handleCancel(row) {
  const { value } = await ElMessageBox.prompt('请输入取消原因', '取消预约', {
    inputPlaceholder: '如 临时有事'
  })
  const res = await cancelAppointment(row.id, value)
  if (res.code === 200) {
    ElMessage.success('已取消')
    load()
    loadStats()
  }
}

onMounted(() => {
  load()
  loadStats()
})
</script>

<style scoped>
.stat-box {
  background: #fff;
  border: 2px solid #909399;
  border-radius: 6px;
  padding: 16px;
  text-align: center;
}
.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #909399;
}
.stat-label {
  font-size: 13px;
  color: #909399;
  margin-top: 6px;
}
</style>