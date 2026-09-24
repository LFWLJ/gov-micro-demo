<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">租户管理</span>
        <el-button v-perm="'sys:tenant:add'" type="success" @click="openDialog(null)">新增租户</el-button>
      </div>
    </template>

    <el-form :inline="true" style="margin-bottom:12px;">
      <el-form-item label="租户名称">
        <el-input v-model="query.tenantName" placeholder="模糊搜索" clearable style="width:200px" @keyup.enter="load" />
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="query.status" placeholder="全部" clearable style="width:120px">
          <el-option label="启用" :value="1" />
          <el-option label="禁用" :value="0" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="load">查询</el-button>
        <el-button @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-table :data="list" v-loading="loading" border>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="tenantId" label="租户标识" min-width="130" />
      <el-table-column prop="tenantName" label="租户名称" min-width="150" />
      <el-table-column prop="contact" label="联系人" width="110" />
      <el-table-column prop="phone" label="联系电话" width="140" />
      <el-table-column prop="expireDate" label="到期日期" width="130" />
      <el-table-column label="状态" width="80" align="center">
        <template #default="{ row }">
          <el-tag v-if="row.status === 1" type="success">启用</el-tag>
          <el-tag v-else type="danger">禁用</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
      <el-table-column label="操作" width="160" fixed="right">
        <template #default="{ row }">
          <el-button v-perm="'sys:tenant:edit'" type="primary" link size="small" @click="openDialog(row)">编辑</el-button>
          <el-button v-perm="'sys:tenant:del'" type="danger" link size="small"
                     :disabled="row.tenantId === 'tenant_a'"
                     @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      style="margin-top:12px; justify-content:flex-end;"
      v-model:current-page="query.pageNum"
      v-model:page-size="query.pageSize"
      :total="total"
      :page-sizes="[10, 20, 50]"
      layout="total, sizes, prev, pager, next, jumper"
      @size-change="load"
      @current-change="load"
    />

    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑租户' : '新增租户'" width="520px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="租户标识" required>
          <el-input v-model="form.tenantId" :disabled="!!form.id" placeholder="如：tenant_c" />
        </el-form-item>
        <el-form-item label="租户名称" required>
          <el-input v-model="form.tenantName" placeholder="如：C市政府" />
        </el-form-item>
        <el-form-item label="联系人">
          <el-input v-model="form.contact" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="form.phone" />
        </el-form-item>
        <el-form-item label="到期日期">
          <el-date-picker v-model="form.expireDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="2" />
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
import { pageTenants, createTenant, updateTenant, deleteTenant } from '../api/tenant'

const list = ref([])
const total = ref(0)
const loading = ref(false)

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  tenantName: '',
  status: null
})

const dialogVisible = ref(false)
const submitting = ref(false)
const form = reactive({
  id: null,
  tenantId: '',
  tenantName: '',
  contact: '',
  phone: '',
  expireDate: null,
  status: 1,
  remark: ''
})

async function load() {
  loading.value = true
  try {
    const res = await pageTenants(query)
    if (res.code === 200) {
      list.value = res.data.records || []
      total.value = res.data.total || 0
    }
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  query.tenantName = ''
  query.status = null
  query.pageNum = 1
  load()
}

function openDialog(row) {
  if (row) {
    Object.assign(form, {
      id: row.id,
      tenantId: row.tenantId,
      tenantName: row.tenantName,
      contact: row.contact || '',
      phone: row.phone || '',
      expireDate: row.expireDate || null,
      status: row.status == null ? 1 : row.status,
      remark: row.remark || ''
    })
  } else {
    Object.assign(form, {
      id: null,
      tenantId: '',
      tenantName: '',
      contact: '',
      phone: '',
      expireDate: null,
      status: 1,
      remark: ''
    })
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!form.tenantId) return ElMessage.warning('请输入租户标识')
  if (!form.tenantName) return ElMessage.warning('请输入租户名称')

  submitting.value = true
  try {
    const res = form.id ? await updateTenant(form) : await createTenant(form)
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
  await ElMessageBox.confirm(`确认删除租户「${row.tenantName}」？`, '提示', { type: 'warning' })
  const res = await deleteTenant(row.id)
  if (res.code === 200) {
    ElMessage.success('已删除')
    load()
  } else {
    ElMessage.error(res.msg)
  }
}

onMounted(load)
</script>