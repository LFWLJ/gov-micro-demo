<template>
  <el-card>
    <template #header>
      <div style="display:flex; gap:10px; align-items:center;">
        <span>待办人：</span>
        <el-input v-model="assignee" style="width:150px" size="small" @keyup.enter="load" />
        <el-button type="primary" size="small" @click="load">查询</el-button>
        <el-button type="success" size="small" @click="openStartDialog">发起新流程</el-button>
      </div>
    </template>

    <el-table :data="tasks" v-loading="loading" border stripe>
      <el-table-column prop="taskId" label="任务ID" width="280" />
      <el-table-column prop="taskName" label="任务名称" />
      <el-table-column prop="assignee" label="处理人" width="120" />
      <el-table-column prop="createTime" label="创建时间" width="180" />
      <el-table-column label="操作" width="220" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" size="small" @click="handleComplete(row)">
            审批通过
          </el-button>
          <el-button type="info" size="small" @click="showTrace(row)">
            查看轨迹
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 发起流程弹窗 -->
    <el-dialog v-model="startDialog" title="发起流程 - 请假审批" width="560px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="业务单号">
          <el-input v-model="form.businessKey" />
        </el-form-item>
        <el-form-item label="申请人">
          <el-input v-model="form.applicant" />
        </el-form-item>
        <el-form-item label="部门领导">
          <el-input v-model="form.deptLeader" />
        </el-form-item>
        <el-form-item label="分管领导">
          <el-input v-model="form.director" />
        </el-form-item>
        <el-form-item label="人事">
          <el-input v-model="form.hr" />
        </el-form-item>
        <el-form-item label="请假天数">
          <el-input-number v-model="form.days" :min="1" :max="30" />
        </el-form-item>
      </el-form>
      <el-alert type="info" :closable="false" style="margin-top:8px;">
        ≤3 天：部门领导 → 人事备案；&gt;3 天：部门领导 → 分管领导 → 人事备案
      </el-alert>
      <template #footer>
        <el-button @click="startDialog = false">取消</el-button>
        <el-button type="primary" :loading="starting" @click="handleStart">确认发起</el-button>
      </template>
    </el-dialog>

    <!-- 流程轨迹抽屉 -->
    <el-drawer v-model="traceVisible" title="流程轨迹" size="600px">
      <div v-loading="traceLoading">
        <el-descriptions :column="1" border style="margin-bottom:20px;">
          <el-descriptions-item label="流程实例">
            <span style="font-size:12px;">{{ traceData.processInstanceId }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="业务单号">{{ traceData.businessKey }}</el-descriptions-item>
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
              <div style="display:flex; justify-content:space-between; align-items:center;">
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
import { ElMessage } from 'element-plus'
import { listTasks, startProcess, completeTask } from '../api/process'
import api from '../api/request'

const assignee = ref('LiSi')
const tasks = ref([])
const loading = ref(false)

const startDialog = ref(false)
const starting = ref(false)
const form = reactive({
  businessKey: '',
  applicant: '',
  deptLeader: '',
  director: '',
  hr: '',
  days: 3
})

const traceVisible = ref(false)
const traceData = ref({})
const traceLoading = ref(false)

async function load() {
  loading.value = true
  try {
    const res = await listTasks(assignee.value)
    if (res.code === 200) {
      tasks.value = res.data.items || []
    }
  } finally {
    loading.value = false
  }
}

function openStartDialog() {
  form.businessKey = 'LEAVE-' + Date.now()
  form.applicant = 'ZhangSan'
  form.deptLeader = 'LiSi'
  form.director = 'WangWu'
  form.hr = 'ZhaoLiu'
  form.days = 3
  startDialog.value = true
}

async function handleStart() {
  starting.value = true
  try {
    const res = await startProcess({ ...form })
    if (res.code === 200) {
      ElMessage.success('流程已发起')
      startDialog.value = false
      assignee.value = form.deptLeader
      load()
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    starting.value = false
  }
}

async function handleComplete(row) {
  const res = await completeTask(row.taskId, { approved: true, comment: '同意' })
  if (res.code === 200) {
    ElMessage.success('已审批')
    load()
  }
}

async function showTrace(row) {
  traceVisible.value = true
  traceLoading.value = true
  traceData.value = {}
  try {
    const res = await api.get(`/api/process/trace/${row.processInstanceId}`)
    if (res.code === 200) {
      traceData.value = res.data
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    traceLoading.value = false
  }
}

onMounted(load)
</script>