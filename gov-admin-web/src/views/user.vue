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

    <el-pagination
      style="margin-top:12px; justify-content:flex-end;"
      background
      layout="total, sizes, prev, pager, next, jumper"
      :total="total"
      :current-page="query.page"
      :page-size="query.size"
      :page-sizes="[10, 20, 50, 100]"
      @current-change="onPageChange"
      @size-change="onSizeChange" />

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
          <el-select v-model="form.roles" style="width:100%" placeholder="请选择角色">
            <el-option
              v-for="r in roleOptions"
              :key="r.roleKey + '@' + r.tenantId"
              :label="r.tenantId ? `${r.roleName} (${r.roleKey}) · ${r.tenantId}` : `${r.roleName} (${r.roleKey})`"
              :value="r.roleKey" />
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
import { getAllRoles } from '../api/role'

const list = ref([])
const total = ref(0)
const loading = ref(false)
const dialogVisible = ref(false)

// 表格走分页接口（不再用 /all 一次性拉全量），并补上分页控件
const query = reactive({ page: 1, size: 10 })

// 角色下拉仍用「查全部」接口：下拉需要完整候选集，且该接口只对管理员开放
const DEFAULT_ROLES = [
  { roleKey: 'ROLE_ADMIN', roleName: '管理员', tenantId: '' },
  { roleKey: 'ROLE_USER', roleName: '普通用户', tenantId: '' }
]
const roleOptions = ref([...DEFAULT_ROLES])

async function loadRoles() {
  try {
    // silent：非管理员调用会被权限拦下，不该弹错误提示，静默回退到默认两项即可
    const res = await getAllRoles({ silent: true })
    if (res.code === 200 && Array.isArray(res.data) && res.data.length) {
      roleOptions.value = res.data
    }
  } catch (e) {
    // 保留默认两项，避免下拉为空
  }
}

const form = reactive({
  id: null, username: '', password: '', realName: '',
  roles: 'ROLE_USER', deptId: 1, dataScope: 3, status: 1
})

async function load() {
  loading.value = true
  try {
    const res = await pageUsers({ page: query.page, size: query.size })
    if (res.code === 200) {
      list.value = res.data.records || []
      total.value = res.data.total || 0
    }
  } finally {
    loading.value = false
  }
}

function onPageChange(p) {
  query.page = p
  load()
}

function onSizeChange(s) {
  query.size = s
  query.page = 1
  load()
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

onMounted(() => {
  load()
  loadRoles()
})
</script>