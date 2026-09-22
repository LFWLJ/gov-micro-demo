<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">文件管理</span>
        <div>
          <el-input
            v-model="query.keyword"
            placeholder="文件名"
            style="width:200px; margin-right:8px;"
            clearable
            @keyup.enter="handleSearch"
          />
          <el-button type="primary" @click="handleSearch">查询</el-button>
        </div>
      </div>
    </template>

    <!-- 上传区 -->
    <el-upload
      drag
      :action="uploadUrl"
      :headers="uploadHeaders"
      :show-file-list="false"
      :on-success="handleUploadSuccess"
      :on-error="handleUploadError"
      :before-upload="beforeUpload"
      style="margin-bottom:16px;"
    >
      <el-icon class="el-icon--upload"><UploadFilled /></el-icon>
      <div class="el-upload__text">拖拽文件到此处，或 <em>点击上传</em></div>
      <template #tip>
        <div class="el-upload__tip">单文件不超过 50MB</div>
      </template>
    </el-upload>

    <!-- 文件列表 -->
    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="originalName" label="文件名" show-overflow-tooltip />
      <el-table-column prop="contentType" label="类型" width="180" />
      <el-table-column label="大小" width="100">
        <template #default="{ row }">
          {{ formatSize(row.size) }}
        </template>
      </el-table-column>
      <el-table-column prop="userId" label="上传人" width="90" />
      <el-table-column prop="createTime" label="上传时间" width="180" />
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="handleDownload(row)">下载</el-button>
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
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { pageFiles, getFileUrl, deleteFile } from '../api/file'

const list = ref([])
const total = ref(0)
const loading = ref(false)
const query = reactive({ page: 1, size: 10, keyword: '' })

const uploadUrl = '/api/file/upload'
const uploadHeaders = ref({})

function refreshUploadHeaders() {
  const token = localStorage.getItem('token')
  uploadHeaders.value = token ? { Authorization: 'Bearer ' + token } : {}
}

function beforeUpload(file) {
  if (file.size > 50 * 1024 * 1024) {
    ElMessage.warning('文件不能超过 50MB')
    return false
  }
  refreshUploadHeaders()
  return true
}

function handleUploadSuccess(res) {
  if (res.code === 200) {
    ElMessage.success('上传成功')
    load()
  } else {
    ElMessage.error(res.msg || '上传失败')
  }
}

function handleUploadError() {
  ElMessage.error('上传失败，请重试')
}

async function load() {
  loading.value = true
  try {
    const res = await pageFiles(query)
    if (res.code === 200) {
      list.value = res.data.records || []
      total.value = res.data.total || 0
    }
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  query.page = 1
  load()
}

async function handleDownload(row) {
  const res = await getFileUrl(row.objectName)
  if (res.code === 200) {
    window.open(res.data.url, '_blank')
  } else {
    ElMessage.error(res.msg)
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确认删除文件「${row.originalName}」？`, '提示', { type: 'warning' })
  const res = await deleteFile(row.objectName)
  if (res.code === 200) {
    ElMessage.success('已删除')
    load()
  } else {
    ElMessage.error(res.msg)
  }
}

function formatSize(bytes) {
  if (bytes == null) return '-'
  if (bytes < 1024) return bytes + ' B'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / 1024 / 1024).toFixed(2) + ' MB'
}

onMounted(() => {
  refreshUploadHeaders()
  load()
})
</script>