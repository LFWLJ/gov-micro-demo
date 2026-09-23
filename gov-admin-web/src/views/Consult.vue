<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">咨询投诉</span>
        <div>
          <el-input
            v-model="query.keyword"
            placeholder="标题/联系人/工单号"
            style="width:200px; margin-right:8px;"
            clearable
            @keyup.enter="handleSearch"
          />
          <el-select
            v-model="query.type"
            placeholder="全部类型"
            style="width:130px; margin-right:8px;"
            clearable
            @change="handleSearch"
          >
            <el-option label="咨询" value="CONSULT" />
            <el-option label="投诉" value="COMPLAINT" />
            <el-option label="建议" value="SUGGEST" />
          </el-select>
          <el-select
            v-model="query.status"
            placeholder="全部状态"
            style="width:130px; margin-right:8px;"
            clearable
            @change="handleSearch"
          >
            <el-option label="待处理" value="PENDING" />
            <el-option label="处理中" value="PROCESSING" />
            <el-option label="已办结" value="DONE" />
            <el-option label="已关闭" value="CLOSED" />
          </el-select>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button type="success" @click="openCreateDialog">提交工单</el-button>
        </div>
      </div>
    </template>

    <!-- 统计卡片 -->
    <el-row :gutter="16" style="margin-bottom:16px;">
      <el-col :span="6">
        <div class="stat-box">
          <div class="stat-value">{{ stats.total || 0 }}</div>
          <div class="stat-label">工单总数</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-box" style="border-color:#e6a23c;">
          <div class="stat-value" style="color:#e6a23c;">{{ stats.pending || 0 }}</div>
          <div class="stat-label">待处理</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-box" style="border-color:#409eff;">
          <div class="stat-value" style="color:#409eff;">{{ stats.processing || 0 }}</div>
          <div class="stat-label">处理中</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-box" style="border-color:#67c23a;">
          <div class="stat-value" style="color:#67c23a;">{{ stats.done || 0 }}</div>
          <div class="stat-label">已办结</div>
        </div>
      </el-col>
    </el-row>

    <!-- 表格 -->
    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="consultNo" label="工单号" width="180" />
      <el-table-column label="类型" width="90">
        <template #default="{ row }">
          <el-tag v-if="row.type === 'CONSULT'" type="primary" size="small">咨询</el-tag>
          <el-tag v-else-if="row.type === 'COMPLAINT'" type="danger" size="small">投诉</el-tag>
          <el-tag v-else type="info" size="small">建议</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="title" label="标题" show-overflow-tooltip />
      <el-table-column prop="contactName" label="联系人" width="100" />
      <el-table-column prop="contactPhone" label="联系电话" width="130" />
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <el-tag v-if="row.status === 'PENDING'" type="warning" size="small">待处理</el-tag>
          <el-tag v-else-if="row.status === 'PROCESSING'" type="primary" size="small">处理中</el-tag>
          <el-tag v-else-if="row.status === 'DONE'" type="success" size="small">已办结</el-tag>
          <el-tag v-else type="info" size="small">已关闭</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="提交时间" width="180" />
      <el-table-column label="操作" width="200" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="showDetail(row)">详情</el-button>
          <el-button
            v-if="row.status !== 'DONE' && row.status !== 'CLOSED'"
            type="success" link size="small"
            @click="openReplyDialog(row)"
          >
            回复
          </el-button>
          <el-button
            v-if="row.status !== 'CLOSED'"
            type="info" link size="small"
            @click="handleClose(row)"
          >
            关闭
          </el-button>
          <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
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

    <!-- 提交工单弹窗 -->
    <el-dialog v-model="createVisible" title="提交工单" width="560px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="类型" required>
          <el-select v-model="form.type" style="width:100%">
            <el-option label="咨询" value="CONSULT" />
            <el-option label="投诉" value="COMPLAINT" />
            <el-option label="建议" value="SUGGEST" />
          </el-select>
        </el-form-item>
        <el-form-item label="标题" required>
          <el-input v-model="form.title" placeholder="请输入标题" />
        </el-form-item>
        <el-form-item label="内容" required>
          <el-input v-model="form.content" type="textarea" :rows="4" placeholder="请详细描述" />
        </el-form-item>
        <el-form-item label="联系人">
          <el-input v-model="form.contactName" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="form.contactPhone" />
        </el-form-item>
        <el-form-item label="处理部门">
          <el-input-number v-model="form.deptId" :min="1" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleCreate">提交</el-button>
      </template>
    </el-dialog>

    <!-- 回复弹窗 -->
    <el-dialog v-model="replyVisible" title="回复工单" width="560px">
      <el-descriptions :column="1" border style="margin-bottom:16px;">
        <el-descriptions-item label="工单号">{{ current.consultNo }}</el-descriptions-item>
        <el-descriptions-item label="标题">{{ current.title }}</el-descriptions-item>
        <el-descriptions-item label="内容">{{ current.content }}</el-descriptions-item>
      </el-descriptions>
      <el-form label-width="90px">
        <el-form-item label="回复内容" required>
          <el-input v-model="replyContent" type="textarea" :rows="4" placeholder="请输入回复内容" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="replyVisible = false">取消</el-button>
        <el-button type="primary" :loading="replying" @click="handleReply">提交回复</el-button>
      </template>
    </el-dialog>

    <!-- 详情抽屉 -->
    <el-drawer v-model="detailVisible" title="工单详情" size="520px">
      <div v-if="current.id">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="工单号">{{ current.consultNo }}</el-descriptions-item>
          <el-descriptions-item label="类型">{{ typeLabel(current.type) }}</el-descriptions-item>
          <el-descriptions-item label="标题">{{ current.title }}</el-descriptions-item>
          <el-descriptions-item label="内容">{{ current.content }}</el-descriptions-item>
          <el-descriptions-item label="联系人">{{ current.contactName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ current.contactPhone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="状态">{{ statusLabel(current.status) }}</el-descriptions-item>
          <el-descriptions-item label="提交时间">{{ current.createTime }}</el-descriptions-item>
        </el-descriptions>

        <div v-if="current.reply" class="reply-section">
          <div class="reply-title">回复内容</div>
          <div class="reply-content">{{ current.reply }}</div>
          <div class="reply-time">{{ current.replyTime }}</div>
        </div>
      </div>
    </el-drawer>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  pageConsults, createConsult, replyConsult,
  closeConsult, deleteConsult, getConsultStats
} from '../api/consult'

const list = ref([])
const total = ref(0)
const loading = ref(false)
const stats = reactive({})

const query = reactive({ page: 1, size: 10, keyword: '', type: '', status: '' })

const createVisible = ref(false)
const submitting = ref(false)
const form = reactive({
  type: 'CONSULT',
  title: '',
  content: '',
  contactName: '',
  contactPhone: '',
  deptId: 2
})

const replyVisible = ref(false)
const replying = ref(false)
const replyContent = ref('')
const current = ref({})

const detailVisible = ref(false)

async function load() {
  loading.value = true
  try {
    const res = await pageConsults(query)
    if (res.code === 200) {
      list.value = res.data.records || []
      total.value = res.data.total || 0
    }
  } finally {
    loading.value = false
  }
}

async function loadStats() {
  const res = await getConsultStats()
  if (res.code === 200) Object.assign(stats, res.data)
}

function handleSearch() {
  query.page = 1
  load()
}

function openCreateDialog() {
  Object.assign(form, {
    type: 'CONSULT',
    title: '',
    content: '',
    contactName: '',
    contactPhone: '',
    deptId: 2
  })
  createVisible.value = true
}

async function handleCreate() {
  if (!form.title || !form.content) {
    ElMessage.warning('请填写标题和内容')
    return
  }
  submitting.value = true
  try {
    const res = await createConsult(form)
    if (res.code === 200) {
      ElMessage.success('提交成功')
      createVisible.value = false
      load()
      loadStats()
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    submitting.value = false
  }
}

function openReplyDialog(row) {
  current.value = row
  replyContent.value = ''
  replyVisible.value = true
}

async function handleReply() {
  if (!replyContent.value) {
    ElMessage.warning('请输入回复内容')
    return
  }
  replying.value = true
  try {
    const res = await replyConsult(current.value.id, replyContent.value)
    if (res.code === 200) {
      ElMessage.success('回复成功')
      replyVisible.value = false
      load()
      loadStats()
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    replying.value = false
  }
}

async function handleClose(row) {
  await ElMessageBox.confirm(`确认关闭工单「${row.title}」？`, '提示', { type: 'warning' })
  const res = await closeConsult(row.id)
  if (res.code === 200) {
    ElMessage.success('已关闭')
    load()
    loadStats()
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确认删除工单「${row.title}」？`, '提示', { type: 'warning' })
  const res = await deleteConsult(row.id)
  if (res.code === 200) {
    ElMessage.success('已删除')
    load()
    loadStats()
  }
}

function showDetail(row) {
  current.value = row
  detailVisible.value = true
}

function typeLabel(t) {
  const map = { CONSULT: '咨询', COMPLAINT: '投诉', SUGGEST: '建议' }
  return map[t] || t
}

function statusLabel(s) {
  const map = {
    PENDING: '待处理',
    PROCESSING: '处理中',
    DONE: '已办结',
    CLOSED: '已关闭'
  }
  return map[s] || s
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
  padding: 18px;
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
.reply-section {
  margin-top: 20px;
}
.reply-title {
  font-weight: bold;
  font-size: 15px;
  color: #1e3a8a;
  padding-left: 10px;
  border-left: 4px solid #409eff;
  margin-bottom: 8px;
}
.reply-content {
  padding: 10px 14px;
  background: #f5f7fa;
  border-radius: 4px;
  font-size: 14px;
  line-height: 1.8;
  color: #303133;
}
.reply-time {
  font-size: 12px;
  color: #909399;
  margin-top: 6px;
  text-align: right;
}
</style>