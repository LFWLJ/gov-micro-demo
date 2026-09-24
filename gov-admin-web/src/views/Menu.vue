<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">菜单管理</span>
        <div>
          <el-button @click="toggleExpand">
            {{ expandAll ? '收起全部' : '展开全部' }}
          </el-button>
          <el-button type="success" @click="openDialog(null, 0)">新增顶级菜单</el-button>
        </div>
      </div>
    </template>

    <el-table
      :key="tableKey"
      :data="tree"
      v-loading="loading"
      row-key="id"
      border
      :default-expand-all="expandAll"
      :tree-props="{ children: 'children' }"
    >
      <el-table-column prop="menuName" label="菜单名称" min-width="180" />
      <el-table-column label="类型" width="80" align="center">
        <template #default="{ row }">
          <el-tag v-if="row.menuType === 'M'" type="warning">目录</el-tag>
          <el-tag v-else-if="row.menuType === 'C'" type="primary">菜单</el-tag>
          <el-tag v-else type="info">按钮</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="path" label="路由" min-width="140" />
      <el-table-column prop="component" label="组件" min-width="130" />
      <el-table-column prop="perms" label="权限标识" min-width="170" />
      <el-table-column prop="icon" label="图标" width="110" />
      <el-table-column prop="orderNum" label="排序" width="70" align="center" />
      <el-table-column label="可见" width="70" align="center">
        <template #default="{ row }">
          <el-tag v-if="row.visible === 1" type="success">是</el-tag>
          <el-tag v-else type="info">否</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="状态" width="80" align="center">
        <template #default="{ row }">
          <el-tag v-if="row.status === 1" type="success">启用</el-tag>
          <el-tag v-else type="danger">禁用</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="220" fixed="right">
        <template #default="{ row }">
          <el-button
            v-if="row.menuType !== 'F'"
            type="primary" link size="small"
            @click="openDialog(null, row.id)"
          >
            新增子项
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
    <el-dialog
      v-model="dialogVisible"
      :title="form.id ? '编辑菜单' : '新增菜单'"
      width="620px"
    >
      <el-form :model="form" label-width="100px">
        <el-form-item label="上级菜单">
          <el-tree-select
            v-model="form.parentId"
            :data="treeSelectData"
            :props="{ label: 'menuName', value: 'id', children: 'children' }"
            check-strictly
            :render-after-expand="false"
            placeholder="不选则为顶级菜单"
            style="width:100%"
            clearable
          />
        </el-form-item>

        <el-form-item label="菜单类型" required>
          <el-radio-group v-model="form.menuType">
            <el-radio value="M">目录</el-radio>
            <el-radio value="C">菜单</el-radio>
            <el-radio value="F">按钮</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item label="菜单名称" required>
          <el-input v-model="form.menuName" placeholder="如：事项管理" />
        </el-form-item>

        <el-form-item v-if="form.menuType !== 'F'" label="路由地址">
          <el-input
            v-model="form.path"
            :placeholder="form.menuType === 'M' ? '如：/biz' : '如：/application'"
          />
        </el-form-item>

        <el-form-item v-if="form.menuType === 'C'" label="组件名">
          <el-input v-model="form.component" placeholder="如：Application" />
        </el-form-item>

        <el-form-item v-if="form.menuType === 'F'" label="权限标识" required>
          <el-input v-model="form.perms" placeholder="如：sys:user:add" />
        </el-form-item>

        <el-form-item v-if="form.menuType !== 'F'" label="图标">
          <el-input v-model="form.icon" placeholder="Element Plus 图标名，如 Setting" />
        </el-form-item>

        <el-form-item label="排序">
          <el-input-number v-model="form.orderNum" :min="0" />
        </el-form-item>

        <el-form-item v-if="form.menuType !== 'F'" label="可见">
          <el-radio-group v-model="form.visible">
            <el-radio :value="1">显示</el-radio>
            <el-radio :value="0">隐藏</el-radio>
          </el-radio-group>
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
        <el-button type="primary" :loading="submitting" @click="handleSubmit">
          提交
        </el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  getMenuTree, createMenu, updateMenu, deleteMenu
} from '../api/menu'

const tree = ref([])
const loading = ref(false)
const expandAll = ref(false)
const tableKey = ref(0)   // 用于强刷表格以应用展开状态

const dialogVisible = ref(false)
const submitting = ref(false)
const form = reactive({
  id: null,
  parentId: 0,
  menuName: '',
  menuType: 'C',
  path: '',
  component: '',
  perms: '',
  icon: '',
  orderNum: 0,
  visible: 1,
  status: 1
})

// 树选择器：加一个"顶级菜单"根节点
const treeSelectData = computed(() => {
  return [
    {
      id: 0,
      menuName: '顶级菜单',
      children: tree.value.filter(m => m.menuType !== 'F')   // 按钮不能作为父级
    }
  ]
})

async function load() {
  loading.value = true
  try {
    const res = await getMenuTree()
    if (res.code === 200) {
      tree.value = res.data || []
    }
  } finally {
    loading.value = false
  }
}

function toggleExpand() {
  expandAll.value = !expandAll.value
  tableKey.value++      // 强刷表格
}

function openDialog(row, parentId) {
  if (row) {
    Object.assign(form, {
      id: row.id,
      parentId: row.parentId,
      menuName: row.menuName,
      menuType: row.menuType,
      path: row.path || '',
      component: row.component || '',
      perms: row.perms || '',
      icon: row.icon || '',
      orderNum: row.orderNum || 0,
      visible: row.visible == null ? 1 : row.visible,
      status: row.status == null ? 1 : row.status
    })
  } else {
    Object.assign(form, {
      id: null,
      parentId: parentId || 0,
      menuName: '',
      menuType: parentId ? 'C' : 'M',
      path: '',
      component: '',
      perms: '',
      icon: '',
      orderNum: 0,
      visible: 1,
      status: 1
    })
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!form.menuName) {
    ElMessage.warning('请输入菜单名称')
    return
  }
  if (form.menuType === 'C' && !form.path) {
    ElMessage.warning('菜单类型必须填写路由地址')
    return
  }
  if (form.menuType === 'C' && !form.component) {
    ElMessage.warning('菜单类型必须填写组件名')
    return
  }
  if (form.menuType === 'F' && !form.perms) {
    ElMessage.warning('按钮类型必须填写权限标识')
    return
  }

  submitting.value = true
  try {
    const payload = { ...form, parentId: form.parentId || 0 }
    const res = form.id ? await updateMenu(payload) : await createMenu(payload)
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
    `确认删除菜单「${row.menuName}」？`,
    '提示',
    { type: 'warning' }
  )
  const res = await deleteMenu(row.id)
  if (res.code === 200) {
    ElMessage.success('已删除')
    load()
  } else {
    ElMessage.error(res.msg)
  }
}

onMounted(load)
</script>