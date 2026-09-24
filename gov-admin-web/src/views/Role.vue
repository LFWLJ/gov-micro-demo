<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">角色管理</span>
        <el-button type="success" @click="openDialog(null)">新增角色</el-button>
      </div>
    </template>

    <!-- 搜索 -->
    <el-form :inline="true" style="margin-bottom:12px;">
      <el-form-item label="角色名称">
        <el-input
          v-model="query.roleName"
          placeholder="模糊搜索"
          clearable
          style="width:200px"
          @keyup.enter="load"
        />
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
      <el-table-column prop="roleName" label="角色名称" min-width="130" />
      <el-table-column prop="roleKey" label="角色标识" min-width="150" />
      <el-table-column prop="roleSort" label="排序" width="70" align="center" />
      <el-table-column label="数据范围" width="130">
        <template #default="{ row }">
          {{ dataScopeText(row.dataScope) }}
        </template>
      </el-table-column>
      <el-table-column label="状态" width="80" align="center">
        <template #default="{ row }">
          <el-tag v-if="row.status === 1" type="success">启用</el-tag>
          <el-tag v-else type="danger">禁用</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
      <el-table-column label="操作" width="260" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="openDialog(row)">
            编辑
          </el-button>
          <el-button type="warning" link size="small" @click="openMenuDialog(row)">
            分配菜单
          </el-button>
          <el-button type="danger" link size="small" @click="handleDelete(row)">
            删除
          </el-button>
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

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑角色' : '新增角色'" width="520px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="角色名称" required>
          <el-input v-model="form.roleName" placeholder="如：超级管理员" />
        </el-form-item>
        <el-form-item label="角色标识" required>
          <el-input v-model="form.roleKey" placeholder="如：ROLE_ADMIN" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.roleSort" :min="0" />
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
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>

    <!-- 分配菜单弹窗 -->
    <el-dialog v-model="menuDialogVisible" :title="`分配菜单 - ${currentRole?.roleName || ''}`" width="520px">
      <div style="margin-bottom:12px;">
        <el-button link type="primary" size="small" @click="expandAll">展开全部</el-button>
        <el-button link type="primary" size="small" @click="collapseAll">收起全部</el-button>
        <el-button link type="primary" size="small" @click="checkAll">全选</el-button>
        <el-button link type="primary" size="small" @click="clearAll">清空</el-button>
      </div>
      <el-tree
        ref="menuTreeRef"
        :data="menuTree"
        node-key="id"
        show-checkbox
        :props="{ label: 'menuName', children: 'children' }"
        :default-expand-all="treeExpandAll"
        style="max-height:440px; overflow:auto;"
      />
      <template #footer>
        <el-button @click="menuDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="menuSubmitting" @click="handleMenuSubmit">保存</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  pageRoles, createRole, updateRole, deleteRole,
  getRoleMenus, assignRoleMenus
} from '../api/role'
import { getMenuTree } from '../api/menu'

const list = ref([])
const total = ref(0)
const loading = ref(false)

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  roleName: '',
  status: null
})

const dialogVisible = ref(false)
const submitting = ref(false)
const form = reactive({
  id: null,
  roleName: '',
  roleKey: '',
  roleSort: 0,
  dataScope: 3,
  status: 1,
  remark: ''
})

// ---------- 分配菜单 ----------
const menuDialogVisible = ref(false)
const menuSubmitting = ref(false)
const menuTree = ref([])
const menuTreeRef = ref(null)
const currentRole = ref(null)
const treeExpandAll = ref(true)

function dataScopeText(v) {
  return { 1: '全部', 2: '本部门及以下', 3: '本部门', 4: '仅本人' }[v] || '-'
}

async function load() {
  loading.value = true
  try {
    const res = await pageRoles(query)
    if (res.code === 200) {
      list.value = res.data.records || []
      total.value = res.data.total || 0
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  query.roleName = ''
  query.status = null
  query.pageNum = 1
  load()
}

function openDialog(row) {
  if (row) {
    Object.assign(form, {
      id: row.id,
      roleName: row.roleName,
      roleKey: row.roleKey,
      roleSort: row.roleSort || 0,
      dataScope: row.dataScope == null ? 3 : row.dataScope,
      status: row.status == null ? 1 : row.status,
      remark: row.remark || ''
    })
  } else {
    Object.assign(form, {
      id: null,
      roleName: '',
      roleKey: '',
      roleSort: 0,
      dataScope: 3,
      status: 1,
      remark: ''
    })
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!form.roleName) return ElMessage.warning('请输入角色名称')
  if (!form.roleKey) return ElMessage.warning('请输入角色标识')

  submitting.value = true
  try {
    const res = form.id ? await updateRole(form) : await createRole(form)
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
  await ElMessageBox.confirm(`确认删除角色「${row.roleName}」？`, '提示', { type: 'warning' })
  const res = await deleteRole(row.id)
  if (res.code === 200) {
    ElMessage.success('已删除')
    load()
  } else {
    ElMessage.error(res.msg)
  }
}

// ---------- 分配菜单 ----------
async function ensureMenuTree() {
  if (menuTree.value.length > 0) return
  const res = await getMenuTree()
  if (res.code === 200) {
    menuTree.value = res.data || []
  }
}

async function openMenuDialog(row) {
  currentRole.value = row
  menuDialogVisible.value = true
  await ensureMenuTree()
  await nextTick()

  // 拉取已分配的菜单 id
  const res = await getRoleMenus(row.id)
  const assignedIds = (res.data || [])

  // 只回显叶子节点，避免父节点联动勾选所有子节点
  const leafSet = collectLeafIds(menuTree.value)
  const checkedLeaf = assignedIds.filter(id => leafSet.has(id))

  menuTreeRef.value.setCheckedKeys([])
  menuTreeRef.value.setCheckedKeys(checkedLeaf)
}

function collectLeafIds(nodes, set = new Set()) {
  for (const n of nodes) {
    if (!n.children || n.children.length === 0) {
      set.add(n.id)
    } else {
      collectLeafIds(n.children, set)
    }
  }
  return set
}

function expandAll() {
  treeExpandAll.value = false
  // 强制重渲染树以展开
  const nodes = menuTreeRef.value?.store?.nodesMap || {}
  Object.values(nodes).forEach(n => { n.expanded = true })
}

function collapseAll() {
  treeExpandAll.value = false
  const nodes = menuTreeRef.value?.store?.nodesMap || {}
  Object.values(nodes).forEach(n => { n.expanded = false })
}

function checkAll() {
  const allIds = []
  const walk = (nodes) => {
    for (const n of nodes) {
      allIds.push(n.id)
      if (n.children) walk(n.children)
    }
  }
  walk(menuTree.value)
  menuTreeRef.value.setCheckedKeys(allIds)
}

function clearAll() {
  menuTreeRef.value.setCheckedKeys([])
}

async function handleMenuSubmit() {
  const checked = menuTreeRef.value.getCheckedKeys()
  const half = menuTreeRef.value.getHalfCheckedKeys()
  const menuIds = [...checked, ...half]

  menuSubmitting.value = true
  try {
    const res = await assignRoleMenus(currentRole.value.id, menuIds)
    if (res.code === 200) {
      ElMessage.success('分配成功')
      menuDialogVisible.value = false
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    menuSubmitting.value = false
  }
}

onMounted(load)
</script>