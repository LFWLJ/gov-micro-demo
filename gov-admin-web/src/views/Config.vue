<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">系统配置</span>
        <div>
          <el-input
            v-model="keyword"
            placeholder="配置名/键"
            style="width:200px; margin-right:8px;"
            clearable
            @keyup.enter="load"
          />
          <el-button type="primary" @click="load">查询</el-button>
          <el-button type="success" @click="openDialog()">新增配置</el-button>
        </div>
      </div>
    </template>

    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="configName" label="配置名称" width="180">
        <template #default="{ row }">
          {{ row.configName || '-' }}
        </template>
      </el-table-column>
      <el-table-column prop="configKey" label="配置键" width="220" />
      <el-table-column prop="configValue" label="配置值" show-overflow-tooltip>
        <template #default="{ row }">
          <span v-if="row.configKey.includes('password') || row.configKey.includes('secret')">
            ******
          </span>
          <span v-else>{{ row.configValue || '-' }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="remark" label="说明" show-overflow-tooltip />
      <el-table-column prop="createTime" label="创建时间" width="180" />
      <el-table-column label="操作" width="140" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="openDialog(row)">编辑</el-button>
          <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑配置' : '新增配置'" width="520px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="配置名称" required>
          <el-input v-model="form.configName" placeholder="如 系统名称" />
        </el-form-item>
        <el-form-item label="配置键" required>
          <el-input v-model="form.configKey" :disabled="!!form.id" placeholder="如 system.name" />
        </el-form-item>
        <el-form-item label="配置值">
          <el-input v-model="form.configValue" type="textarea" :rows="3" />
        </el-form-item>
        <el-form-item label="说明">
          <el-input v-model="form.remark" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listConfigs, createConfig, updateConfig, deleteConfig } from '../api/config'

const list = ref([])
const loading = ref(false)
const keyword = ref('')

const dialogVisible = ref(false)
const submitting = ref(false)
const form = reactive({
  id: null,
  configName: '',
  configKey: '',
  configValue: '',
  remark: ''
})

async function load() {
  loading.value = true
  try {
    const res = await listConfigs({ keyword: keyword.value })
    if (res.code === 200) list.value = res.data || []
  } finally {
    loading.value = false
  }
}

function openDialog(row) {
  if (row) {
    Object.assign(form, { ...row })
  } else {
    Object.assign(form, { id: null, configName: '', configKey: '', configValue: '', remark: '' })
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!form.configKey || !form.configName) {
    ElMessage.warning('请填写配置名称和配置键')
    return
  }
  submitting.value = true
  try {
    const res = form.id ? await updateConfig(form) : await createConfig(form)
    if (res.code === 200) {
      ElMessage.success(form.id ? '修改成功' : '新增成功')
      dialogVisible.value = false
      load()
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    submitting.value = false
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确认删除「${row.configName}」？`, '提示', { type: 'warning' })
  const res = await deleteConfig(row.id)
  if (res.code === 200) {
    ElMessage.success('已删除')
    load()
  } else {
    ElMessage.error(res.msg)
  }
}

onMounted(load)
</script>