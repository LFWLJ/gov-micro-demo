<template>
  <div class="file-upload">
    <el-upload
      :show-file-list="false"
      :before-upload="beforeUpload"
      :http-request="customUpload"
      :disabled="disabled"
      multiple
    >
      <el-button type="primary" :disabled="disabled" :loading="uploading" size="small">
        <el-icon><Upload /></el-icon>
        上传附件
      </el-button>
    </el-upload>

    <el-table
      :data="list"
      v-loading="loading"
      size="small"
      border
      style="margin-top:12px;"
      empty-text="暂无附件"
    >
      <el-table-column prop="fileName" label="文件名" min-width="200" show-overflow-tooltip />
      <el-table-column label="大小" width="110">
        <template #default="{ row }">{{ formatSize(row.size) }}</template>
      </el-table-column>
      <el-table-column prop="createTime" label="上传时间" width="170" />
      <el-table-column label="操作" width="150" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="handleDownload(row)">
            下载
          </el-button>
          <el-button
            v-if="!disabled"
            type="danger" link size="small"
            @click="handleDelete(row)"
          >
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  uploadFile, saveAttachment, listAttachments, deleteAttachment, getDownloadUrl
} from '../api/attachment'

const props = defineProps({
  bizType: { type: String, required: true },
  bizId:   { type: [Number, String], required: true },
  disabled: { type: Boolean, default: false }
})

const list = ref([])
const loading = ref(false)
const uploading = ref(false)

async function load() {
  if (!props.bizId) {
    list.value = []
    return
  }
  loading.value = true
  try {
    const res = await listAttachments({
      bizType: props.bizType,
      bizId: props.bizId
    })
    if (res.code === 200) {
      list.value = res.data || []
    }
  } finally {
    loading.value = false
  }
}

function beforeUpload(file) {
  const maxSize = 50 * 1024 * 1024
  if (file.size > maxSize) {
    ElMessage.error('文件不能超过 50MB')
    return false
  }
  return true
}

async function customUpload({ file }) {
  uploading.value = true
  try {
    const upRes = await uploadFile(file)
    if (upRes.code !== 200) {
      ElMessage.error(upRes.msg || '上传失败')
      return
    }
    const data = upRes.data || {}
    const fileId = data.fileId
    if (!fileId) {
      ElMessage.error('上传返回缺少 fileId')
      return
    }

    const asRes = await saveAttachment({
      bizType: props.bizType,
      bizId: props.bizId,
      fileId,
      fileName: data.originalName || file.name
    })
    if (asRes.code === 200) {
      ElMessage.success('上传成功')
      load()
    } else {
      ElMessage.error(asRes.msg || '关联失败')
    }
  } catch (e) {
    ElMessage.error('上传失败')
  } finally {
    uploading.value = false
  }
}

async function handleDownload(row) {
  if (!row.objectName) {
    ElMessage.warning('缺少文件路径，无法下载')
    return
  }
  try {
    const res = await getDownloadUrl(row.objectName)
    if (res.code === 200 && res.data?.url) {
      window.open(res.data.url, '_blank')
    } else {
      ElMessage.error('获取下载链接失败')
    }
  } catch (e) {
    ElMessage.error('下载失败')
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确认删除附件「${row.fileName}」？`, '提示', { type: 'warning' })
  const res = await deleteAttachment(row.id)
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
  if (bytes < 1024 * 1024 * 1024) return (bytes / 1024 / 1024).toFixed(2) + ' MB'
  return (bytes / 1024 / 1024 / 1024).toFixed(2) + ' GB'
}

watch(() => [props.bizType, props.bizId], load)

onMounted(load)

defineExpose({ load })
</script>

<style scoped>
.file-upload {
  width: 100%;
}
</style>