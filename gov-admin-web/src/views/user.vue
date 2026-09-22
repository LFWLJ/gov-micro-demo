<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">用户管理</span>
        <el-button type="success" @click="openDialog()">新增用户</el-button>
      </div>
    </template>

    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="username" label="用户名" width="140" />
      <el-table-column prop="realName" label="姓名" width="120" />
      <el-table-column prop="roles" label="角色" />
      <el-table-column prop="deptId" label="部门ID" width="90" />
      <el-table-column label="状态" width="80">
        <template #default="{ row }">
          <el-tag v-if="row.status === 1" type="success">启用</el-tag>
          <el-tag v-else type="danger">禁用</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="140">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="openDialog(row)">编辑</el-button>
          <el-button type="danger" link size="small"
                     :disabled="row.username === 'admin'"
                     @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑' : '新增'" width="480px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="用户名">
          <el-input v-model="form.username" :disabled="!!form.id" />
        </el-form-item>
        <el-form-item v-if="!form.id" label="密码">
          <el-input v-model="form.password" type="password" show-password />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="form.realName" />
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="form.roles" style="width:100%">
            <el-option label="管理员" value="ROLE_ADMIN" />
            <el-option label="普通用户" value="ROLE_USER" />
          </el-select>
        </el-form-item>
        <el-form-item label="部门ID">
          <el-input-number v-model="form.deptId" :min="1" />
        </el-form-item>
        <el-form-item label="数据范围">
          <el-select v-model="form.dataScope" style="width:100%">
            <el-option label="全部数据" :value="1" />
            <el-option label="本部门及以下" :value="2" />
            <el-option label="本部门" :value="3" />
            <el-option label="仅本人" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { pageUsers, createUser, updateUser, deleteUser } from '../api/user'

const list = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const form = reactive({
  id: null, username: '', password: '', realName: '',
  roles: 'ROLE_USER', deptId: 1, dataScope: 3, status: 1
})

async function load() {
  loading.value = true
  try {
    const res = await pageUsers({ page: 1, size: 20 })
    if (res.code === 200) {
      list.value = res.data.records || []
    }
  } finally {
    loading.value = false
  }
}

function openDialog(row) {
  if (row) {
    Object.assign(form, { ...row, password: '' })
  } else {
    Object.assign(form, {
      id: null, username: '', password: '', realName: '',
      roles: 'ROLE_USER', deptId: 1, dataScope: 3, status: 1
    })
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  const res = form.id ? await updateUser(form) : await createUser(form)
  if (res.code === 200) {
    ElMessage.success('操作成功')
    dialogVisible.value = false
    load()
  } else {
    ElMessage.error(res.msg)
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确认删除「${row.username}」？`, '提示', { type: 'warning' })
  const res = await deleteUser(row.id)
  if (res.code === 200) {
    ElMessage.success('已删除')
    load()
  }
}

onMounted(load)
</script>