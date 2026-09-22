<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">部门管理</span>
        <el-button type="success" @click="openDialog(null, 0)">新增顶级部门</el-button>
      </div>
    </template>

    <el-table
      :data="tree"
      v-loading="loading"
      row-key="id"
      border
      default-expand-all
      :tree-props="{ children: 'children' }"
    >
      <el-table-column prop="deptName" label="部门名称" min-width="200" />
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="parentId" label="上级ID" width="90" />
      <el-table-column prop="orderNum" label="排序" width="80" />
      <el-table-column label="状态" width="80">
        <template #default="{ row }">
          <el-tag v-if="row.status === 1" type="success">启用</el-tag>
          <el-tag v-else type="danger">禁用</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="240" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="openDialog(null, row.id)">
            新增子部门
          </el-button>
          <el-button type="primary" link size="small" @click="openDialog(row)">
            编辑
          </el-button>
          <el-button type="danger" link size="small" @click="handleDelete(row)">
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑部门' : '新增部门'" width="480px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="上级部门">
          <el-tree-select
            v-model="form.parentId"
            :data="treeSelectData"
            :props="{ label: 'deptName', value: 'id', children: 'children' }"
            check-strictly
            :render-after-expand="false"
            placeholder="不选则为顶级部门"
            style="width:100%"
            clearable
          />
        </el-form-item>
        <el-form-item label="部门名称" required>
          <el-input v-model="form.deptName" placeholder="如：财政局预算科" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.orderNum" :min="0" />
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
        <el-button type="primary" :loading="submitting" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getDeptTree, createDept, updateDept, deleteDept } from '../api/dept'

const tree = ref([])
const loading = ref(false)

const dialogVisible = ref(false)
const submitting = ref(false)
const form = reactive({
  id: null,
  parentId: 0,
  deptName: '',
  orderNum: 0,
  status: 1
})

// 树选择器数据：加一个"顶级部门"根节点
const treeSelectData = computed(() => {
  return [
    {
      id: 0,
      deptName: '顶级部门',
      children: tree.value
    }
  ]
})

async function load() {
  loading.value = true
  try {
    const res = await getDeptTree()
    if (res.code === 200) {
      tree.value = res.data || []
    }
  } finally {
    loading.value = false
  }
}

function openDialog(row, parentId) {
  if (row) {
    // 编辑
    Object.assign(form, {
      id: row.id,
      parentId: row.parentId,
      deptName: row.deptName,
      orderNum: row.orderNum,
      status: row.status
    })
  } else {
    // 新增
    Object.assign(form, {
      id: null,
      parentId: parentId || 0,
      deptName: '',
      orderNum: 0,
      status: 1
    })
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!form.deptName) {
    ElMessage.warning('请输入部门名称')
    return
  }
  submitting.value = true
  try {
    // parentId 为 0 时改成 null，避免前端树选择器传 0 给后端
    const payload = { ...form, parentId: form.parentId || 0 }
    const res = form.id ? await updateDept(payload) : await createDept(payload)
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
  await ElMessageBox.confirm(
    `确认删除部门「${row.deptName}」？`,
    '提示',
    { type: 'warning' }
  )
  const res = await deleteDept(row.id)
  if (res.code === 200) {
    ElMessage.success('已删除')
    load()
  } else {
    ElMessage.error(res.msg)
  }
}

onMounted(load)
</script>