<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">事项管理（当前租户）</span>
        <el-button type="primary" @click="openCreate">新建事项</el-button>
      </div>
    </template>

    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="title" label="事项标题" />
      <el-table-column prop="applicant" label="申请人" width="110" />
      <el-table-column label="状态" width="110">
        <template #default="{ row }">
          <el-tag v-if="row.status === 'DRAFT'" type="info">草稿</el-tag>
          <el-tag v-else-if="row.status === 'PENDING'" type="warning">待审批</el-tag>
          <el-tag v-else-if="row.status === 'APPROVED'" type="success">已通过</el-tag>
          <el-tag v-else-if="row.status === 'REJECTED'" type="danger">已驳回</el-tag>
          <el-tag v-else>{{ row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="deptId" label="部门ID" width="90" />
      <el-table-column prop="createTime" label="创建时间" width="180" />
      <el-table-column label="操作" width="300" fixed="right">
        <template #default="{ row }">
          <el-button
            type="primary" link size="small"
            @click="showLogs(row)"
          >
            流转日志
          </el-button>
          <el-button
            type="info" link size="small"
            :disabled="!row.processInstanceId"
            @click="showTrace(row)"
          >
            审批进度
          </el-button>
          <el-button
            type="warning" link size="small"
            :disabled="row.status !== 'PENDING'"
            @click="handleReject(row)"
          >
            驳回
          </el-button>
          <el-button
            type="danger" link size="small"
            :disabled="row.status !== 'PENDING'"
            @click="handleWithdraw(row)"
          >
            撤回
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 新建事项弹窗 -->
    <el-dialog v-model="dialogVisible" title="新建事项（自动发起流程）" width="560px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="事项标题" required>
          <el-input v-model="form.title" placeholder="请输入标题" />
        </el-form-item>
        <el-form-item label="申请人" required>
          <el-input v-model="form.applicant" placeholder="请输入申请人" />
        </el-form-item>
        <el-divider content-position="left">审批人配置</el-divider>
        <el-form-item label="部门领导">
          <el-input v-model="form.deptLeader" />
        </el-form-item>
        <el-form-item label="分管领导">
          <el-input v-model="form.director" />
        </el-form-item>
        <el-form-item label="人事">
          <el-input v-model="form.hr" />
        </el-form-item>
        <el-form-item label="办理天数">
          <el-input-number v-model="form.days" :min="1" :max="30" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">
          提交并发起流程
        </el-button>
      </template>
    </el-dialog>

    <!-- 流转日志抽屉 -->
    <el-drawer v-model="logVisible" title="办件流转日志" size="520px">
      <div v-loading="logLoading">
        <el-timeline v-if="logs.length > 0">
          <el-timeline-item
            v-for="(log, idx) in logs"
            :key="idx"
            :timestamp="log.createTime"
            :type="actionType(log.action)"
            placement="top"
          >
            <el-card shadow="hover">
              <div style="font-weight:bold; color:#303133;">
                {{ log.actionName }}
              </div>
              <div style="margin-top:6px; font-size:13px; color:#606266;">
                操作人：{{ log.operator || '-' }}
              </div>
              <div v-if="log.remark" style="margin-top:4px; font-size:13px; color:#909399;">
                备注：{{ log.remark }}
              </div>
            </el-card>
          </el-timeline-item>
        </el-timeline>
        <el-empty v-else description="暂无流转记录" />
      </div>
    </el-drawer>

    <!-- 审批进度抽屉 -->
    <el-drawer v-model="traceVisible" title="审批进度" size="600px">
      <div v-loading="traceLoading">
        <el-descriptions :column="1" border style="margin-bottom:20px;">
          <el-descriptions-item label="事项">{{ currentApp.title }}</el-descriptions-item>
          <el-descriptions-item label="发起时间">{{ traceData.startTime }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag v-if="traceData.finished" type="success">已完成</el-tag>
            <el-tag v-else type="warning">进行中</el-tag>
          </el-descriptions-item>
        </el-descriptions>

        <el-timeline>
          <el-timeline-item
            v-for="(node, idx) in (traceData.nodes || [])"
            :key="idx"
            :type="node.status === 'DONE' ? 'success' : 'primary'"
            :hollow="node.status === 'PENDING'"
            :timestamp="node.startTime"
            placement="top"
          >
            <el-card shadow="hover">
              <div style="display:flex; justify-content:space-between;">
                <span style="font-weight:bold;">{{ node.taskName }}</span>
                <el-tag v-if="node.status === 'DONE'" type="success" size="small">已完成</el-tag>
                <el-tag v-else type="warning" size="small">待处理</el-tag>
              </div>
              <div style="margin-top:8px; font-size:13px; color:#666;">
                处理人：{{ node.assignee || '未指定' }}
              </div>
              <div v-if="node.endTime" style="margin-top:4px; font-size:13px; color:#666;">
                耗时：{{ (node.durationMs / 1000).toFixed(1) }} 秒
              </div>
            </el-card>
          </el-timeline-item>
        </el-timeline>
      </div>
    </el-drawer>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  listApplications, createApplication, getApplicationTrace,
  getApplicationLogs, rejectApplication, withdrawApplication
} from '../api/application'

const list = ref([])
const loading = ref(false)

const dialogVisible = ref(false)
const submitting = ref(false)
const form = reactive({
  title: '', applicant: '',
  deptLeader: 'LiSi', director: 'WangWu', hr: 'ZhaoLiu', days: 3
})

// 流转日志
const logVisible = ref(false)
const logLoading = ref(false)
const logs = ref([])

// 审批进度
const traceVisible = ref(false)
const traceLoading = ref(false)
const traceData = ref({})
const currentApp = ref({})

async function load() {
  loading.value = true
  try {
    const res = await listApplications()
    if (res.code === 200) list.value = res.data.items || []
  } finally {
    loading.value = false
  }
}

function openCreate() {
  Object.assign(form, {
    title: '', applicant: '',
    deptLeader: 'LiSi', director: 'WangWu', hr: 'ZhaoLiu', days: 3
  })
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!form.title || !form.applicant) {
    ElMessage.warning('请填写标题和申请人')
    return
  }
  submitting.value = true
  try {
    const res = await createApplication(form)
    if (res.code === 200) {
      ElMessage.success('创建成功，流程已自动发起')
      dialogVisible.value = false
      load()
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    submitting.value = false
  }
}

async function showLogs(row) {
  logVisible.value = true
  logLoading.value = true
  logs.value = []
  try {
    const res = await getApplicationLogs(row.id)
    if (res.code === 200) logs.value = res.data || []
  } finally {
    logLoading.value = false
  }
}

async function showTrace(row) {
  currentApp.value = row
  traceVisible.value = true
  traceLoading.value = true
  traceData.value = {}
  try {
    const res = await getApplicationTrace(row.id)
    if (res.code === 200) traceData.value = res.data
    else ElMessage.error(res.msg)
  } finally {
    traceLoading.value = false
  }
}

async function handleReject(row) {
  const { value } = await ElMessageBox.prompt('请输入驳回原因', '驳回', {
    inputType: 'textarea',
    inputPlaceholder: '如材料不全、不符合条件'
  })
  const res = await rejectApplication(row.id, value)
  if (res.code === 200) {
    ElMessage.success('已驳回')
    load()
  } else {
    ElMessage.error(res.msg)
  }
}

async function handleWithdraw(row) {
  await ElMessageBox.confirm(`确认撤回「${row.title}」？`, '提示', { type: 'warning' })
  const res = await withdrawApplication(row.id, '申请人撤回')
  if (res.code === 200) {
    ElMessage.success('已撤回')
    load()
  } else {
    ElMessage.error(res.msg)
  }
}

function actionType(action) {
  switch (action) {
    case 'SUBMIT':   return 'primary'
    case 'APPROVE':  return 'success'
    case 'REJECT':   return 'danger'
    case 'WITHDRAW': return 'warning'
    default:         return 'info'
  }
}

onMounted(load)
</script>