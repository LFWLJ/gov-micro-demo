<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">敏感词管理</span>
        <div>
          <el-button v-perm="'sys:sensitive:add'" @click="openBatchDialog">批量导入</el-button>
          <el-button v-perm="'sys:sensitive:add'" type="success" @click="openDialog(null)">新增敏感词</el-button>
        </div>
      </div>
    </template>

    <el-form :inline="true" style="margin-bottom:12px;">
      <el-form-item label="敏感词">
        <el-input v-model="query.word" placeholder="模糊搜索" clearable style="width:200px" @keyup.enter="load" />
      </el-form-item>
      <el-form-item label="分类">
        <el-input v-model="query.category" placeholder="如：政治" clearable style="width:150px" @keyup.enter="load" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="load">查询</el-button>
        <el-button @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-table :data="list" v-loading="loading" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="word" label="敏感词" min-width="180" />
      <el-table-column prop="category" label="分类" width="150" />
      <el-table-column prop="createTime" label="添加时间" width="180" />
      <el-table-column label="操作" width="160" fixed="right">
        <template #default="{ row }">
          <el-button v-perm="'sys:sensitive:edit'" type="primary" link size="small" @click="openDialog(row)">编辑</el-button>
          <el-button v-perm="'sys:sensitive:del'" type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      style="margin-top:12px; justify-content:flex-end;"
      v-model:current-page="query.pageNum"
      v-model:page-size="query.pageSize"
      :total="total"
      :page-sizes="[10, 20, 50, 100]"
      layout="total, sizes, prev, pager, next, jumper"
      @size-change="load"
      @current-change="load"
    />

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑敏感词' : '新增敏感词'" width="480px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="敏感词" required>
          <el-input v-model="form.word" placeholder="如：xxx" maxlength="64" show-word-limit />
        </el-form-item>
        <el-form-item label="分类">
          <el-input v-model="form.category" placeholder="如：政治、色情、广告" maxlength="32" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>

    <!-- 批量导入弹窗 -->
    <el-dialog v-model="batchVisible" title="批量导入敏感词" width="560px">
      <el-form label-width="90px">
        <el-form-item label="分类">
          <el-input v-model="batchCategory" placeholder="可选，如：广告" maxlength="32" />
        </el-form-item>
        <el-form-item label="敏感词">
          <el-input
            v-model="batchText"
            type="textarea"
            :rows="10"
            placeholder="每行一个敏感词，重复的会自动跳过"
          />
        </el-form-item>
        <div style="color:#909399; font-size:12px; margin-left:90px;">
          共 {{ batchCount }} 行有效内容
        </div>
      </el-form>
      <template #footer>
        <el-button @click="batchVisible = false">取消</el-button>
        <el-button type="primary" :loading="batchSubmitting" @click="handleBatchSubmit">导入</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  pageSensitiveWords, createSensitiveWord, updateSensitiveWord,
  deleteSensitiveWord, batchAddSensitiveWords
} from '../api/sensitive'

const list = ref([])
const total = ref(0)
const loading = ref(false)

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  word: '',
  category: ''
})

const dialogVisible = ref(false)
const submitting = ref(false)
const form = reactive({
  id: null,
  word: '',
  category: ''
})

// 批量导入
const batchVisible = ref(false)
const batchSubmitting = ref(false)
const batchText = ref('')
const batchCategory = ref('')

const batchCount = computed(() => {
  return batchText.value.split('\n').map(s => s.trim()).filter(s => s.length > 0).length
})

async function load() {
  loading.value = true
  try {
    const res = await pageSensitiveWords(query)
    if (res.code === 200) {
      list.value = res.data.records || []
      total.value = res.data.total || 0
    }
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  query.word = ''
  query.category = ''
  query.pageNum = 1
  load()
}

function openDialog(row) {
  if (row) {
    Object.assign(form, {
      id: row.id,
      word: row.word,
      category: row.category || ''
    })
  } else {
    Object.assign(form, {
      id: null,
      word: '',
      category: ''
    })
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!form.word) return ElMessage.warning('请输入敏感词')

  submitting.value = true
  try {
    const res = form.id ? await updateSensitiveWord(form) : await createSensitiveWord(form)
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
  await ElMessageBox.confirm(`确认删除敏感词「${row.word}」？`, '提示', { type: 'warning' })
  const res = await deleteSensitiveWord(row.id)
  if (res.code === 200) {
    ElMessage.success('已删除')
    load()
  } else {
    ElMessage.error(res.msg)
  }
}

// ========== 批量导入 ==========
function openBatchDialog() {
  batchText.value = ''
  batchCategory.value = ''
  batchVisible.value = true
}

async function handleBatchSubmit() {
  const words = batchText.value.split('\n').map(s => s.trim()).filter(s => s.length > 0)
  if (words.length === 0) {
    return ElMessage.warning('请至少输入一个敏感词')
  }

  batchSubmitting.value = true
  try {
    const res = await batchAddSensitiveWords({
      words,
      category: batchCategory.value || null
    })
    if (res.code === 200) {
      ElMessage.success(res.msg || '导入成功')
      batchVisible.value = false
      load()
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    batchSubmitting.value = false
  }
}

onMounted(load)
</script>