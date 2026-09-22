<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">数据字典</span>
        <div>
          <el-button type="primary" @click="openTypeDialog()">新增字典类型</el-button>
          <el-button type="success" :disabled="!currentType" @click="openDialog()">新增字典项</el-button>
        </div>
      </div>
    </template>

    <el-row :gutter="16">
      <!-- 左侧：字典类型列表 -->
      <el-col :span="6">
        <el-card shadow="never" style="height:100%;">
          <div style="font-weight:bold; margin-bottom:10px;">字典类型</div>
          <ul class="type-list">
            <li
              v-for="t in types"
              :key="t.dictType"
              :class="{ active: t.dictType === currentType }"
              @click="selectType(t.dictType)"
            >
              <div class="type-name">{{ t.dictName }}</div>
              <div class="type-code">{{ t.dictType }}</div>
            </li>
            <li v-if="types.length === 0" style="color:#909399; cursor:default;">
              暂无字典类型
            </li>
          </ul>
        </el-card>
      </el-col>

      <!-- 右侧：字典项列表 -->
      <el-col :span="18">
        <el-card shadow="never">
          <div style="margin-bottom:12px; font-weight:bold;">
            {{ currentTypeName || '请选择左侧类型' }}
          </div>
          <el-table :data="items" v-loading="loading" border stripe>
            <el-table-column prop="id" label="ID" width="70" />
            <el-table-column prop="dictLabel" label="标签" />
            <el-table-column prop="dictValue" label="值" />
            <el-table-column prop="sort" label="排序" width="80" />
            <el-table-column label="状态" width="80">
              <template #default="{ row }">
                <el-tag v-if="row.status === 1" type="success" size="small">启用</el-tag>
                <el-tag v-else type="danger" size="small">禁用</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="140" fixed="right">
              <template #default="{ row }">
                <el-button type="primary" link size="small" @click="openDialog(row)">编辑</el-button>
                <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <!-- 新增字典类型弹窗 -->
    <el-dialog v-model="typeDialogVisible" title="新增字典类型" width="480px">
      <el-form :model="typeForm" label-width="90px">
        <el-form-item label="类型编码" required>
          <el-input v-model="typeForm.dictType" placeholder="如 application_status" />
        </el-form-item>
        <el-form-item label="类型名称" required>
          <el-input v-model="typeForm.dictName" placeholder="如 事项状态" />
        </el-form-item>
        <el-form-item label="说明">
          <el-input v-model="typeForm.remark" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="typeDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmitType">提交</el-button>
      </template>
    </el-dialog>

    <!-- 新增/编辑字典项弹窗 -->
    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑字典项' : '新增字典项'" width="480px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="字典类型">
          <el-input :value="currentTypeName" disabled />
        </el-form-item>
        <el-form-item label="标签" required>
          <el-input v-model="form.dictLabel" placeholder="显示名称" />
        </el-form-item>
        <el-form-item label="值" required>
          <el-input v-model="form.dictValue" placeholder="存储值" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sort" :min="0" />
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
import { listDictTypes, getDictData, createDict, updateDict, deleteDict, createDictType } from '../api/dict'

const types = ref([])
const currentType = ref('')
const items = ref([])
const loading = ref(false)

const currentTypeName = computed(() => {
  const t = types.value.find(x => x.dictType === currentType.value)
  return t ? t.dictName : ''
})

// 字典类型弹窗
const typeDialogVisible = ref(false)
const typeForm = reactive({ dictType: '', dictName: '', remark: '' })

// 字典项弹窗
const dialogVisible = ref(false)
const submitting = ref(false)
const form = reactive({
  id: null,
  dictType: '',
  dictLabel: '',
  dictValue: '',
  sort: 0,
  status: 1
})

async function loadTypes() {
  const res = await listDictTypes()
  if (res.code === 200) {
    types.value = res.data || []
    if (types.value.length > 0 && !currentType.value) {
      selectType(types.value[0].dictType)
    }
  }
}

async function selectType(t) {
  currentType.value = t
  loading.value = true
  try {
    const res = await getDictData(t)
    if (res.code === 200) items.value = res.data || []
  } finally {
    loading.value = false
  }
}

function openTypeDialog() {
  Object.assign(typeForm, { dictType: '', dictName: '', remark: '' })
  typeDialogVisible.value = true
}

async function handleSubmitType() {
  if (!typeForm.dictType || !typeForm.dictName) {
    ElMessage.warning('请填写类型编码和名称')
    return
  }
  const res = await createDictType(typeForm)
  if (res.code === 200) {
    ElMessage.success('新增成功')
    typeDialogVisible.value = false
    await loadTypes()
  } else {
    ElMessage.error(res.msg)
  }
}

function openDialog(row) {
  if (row) {
    Object.assign(form, { ...row })
  } else {
    Object.assign(form, {
      id: null,
      dictType: currentType.value,
      dictLabel: '',
      dictValue: '',
      sort: 0,
      status: 1
    })
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!form.dictLabel || !form.dictValue) {
    ElMessage.warning('请填写标签和值')
    return
  }
  submitting.value = true
  try {
    const res = form.id ? await updateDict(form) : await createDict(form)
    if (res.code === 200) {
      ElMessage.success(form.id ? '修改成功' : '新增成功')
      dialogVisible.value = false
      await selectType(currentType.value)
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    submitting.value = false
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确认删除「${row.dictLabel}」？`, '提示', { type: 'warning' })
  const res = await deleteDict(row.id)
  if (res.code === 200) {
    ElMessage.success('已删除')
    await selectType(currentType.value)
  } else {
    ElMessage.error(res.msg)
  }
}

onMounted(loadTypes)
</script>

<style scoped>
.type-list { list-style: none; padding: 0; margin: 0; }
.type-list li {
  padding: 10px 14px; cursor: pointer; border-radius: 4px;
  margin-bottom: 4px; transition: all 0.2s;
}
.type-list li:hover { background: #ecf5ff; }
.type-list li.active { background: #409eff; }
.type-list li.active .type-name,
.type-list li.active .type-code { color: #fff; }
.type-name { font-size: 14px; color: #303133; font-weight: 500; }
.type-code { font-size: 12px; color: #909399; margin-top: 2px; font-family: monospace; }
</style>