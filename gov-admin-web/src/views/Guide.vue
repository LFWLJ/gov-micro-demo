<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">办事指南</span>
        <div>
          <el-input
            v-model="query.keyword"
            placeholder="事项名称/编码"
            style="width:180px; margin-right:8px;"
            clearable
            @keyup.enter="handleSearch"
          />
          <el-select
            v-model="query.category"
            placeholder="全部分类"
            style="width:140px; margin-right:8px;"
            clearable
            @change="handleSearch"
          >
            <el-option v-for="c in categories" :key="c" :label="c" :value="c" />
          </el-select>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button type="success" @click="openDialog()">新增指南</el-button>
        </div>
      </div>
    </template>

    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="guideCode" label="编码" width="120" />
      <el-table-column prop="title" label="事项名称" />
      <el-table-column prop="category" label="分类" width="120" />
      <el-table-column prop="promiseDays" label="承诺时限" width="100">
        <template #default="{ row }">
          <span v-if="row.promiseDays">{{ row.promiseDays }}天</span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column prop="chargeStandard" label="收费" width="120" />
      <el-table-column label="状态" width="80">
        <template #default="{ row }">
          <el-tag v-if="row.status === 1" type="success" size="small">启用</el-tag>
          <el-tag v-else type="info" size="small">停用</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="240" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="showDetail(row)">详情</el-button>
          <el-button type="primary" link size="small" @click="openDialog(row)">编辑</el-button>
          <el-button
            type="warning" link size="small"
            @click="handleToggle(row)"
          >
            {{ row.status === 1 ? '停用' : '启用' }}
          </el-button>
          <el-button type="danger" link size="small" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      style="margin-top:16px; text-align:right;"
      background
      layout="total, sizes, prev, pager, next"
      :total="total"
      :current-page="query.page"
      :page-size="query.size"
      :page-sizes="[10, 20, 50]"
      @current-change="(p) => { query.page = p; load(); }"
      @size-change="(s) => { query.size = s; query.page = 1; load(); }"
    />

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑指南' : '新增指南'" width="800px" top="5vh">
      <el-form :model="form" label-width="110px">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="指南编码" required>
              <el-input v-model="form.guideCode" :disabled="!!form.id" placeholder="如 GUIDE-005" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="分类">
              <el-input v-model="form.category" placeholder="如 企业登记" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="事项名称" required>
          <el-input v-model="form.title" />
        </el-form-item>

        <el-row :gutter="16">
          <el-col :span="8">
            <el-form-item label="办理部门ID">
              <el-input-number v-model="form.deptId" :min="1" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="法定时限(天)">
              <el-input-number v-model="form.legalDays" :min="0" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="承诺时限(天)">
              <el-input-number v-model="form.promiseDays" :min="0" style="width:100%" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="收费标准">
              <el-input v-model="form.chargeStandard" placeholder="如 免费" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="咨询电话">
              <el-input v-model="form.consultPhone" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="服务对象">
          <el-input v-model="form.serviceObject" />
        </el-form-item>

        <el-form-item label="在线办理地址">
          <el-input v-model="form.onlineUrl" placeholder="https://..." />
        </el-form-item>

        <el-form-item label="法律依据">
          <el-input v-model="form.legalBasis" type="textarea" :rows="2" />
        </el-form-item>

        <el-form-item label="办理条件">
          <el-input v-model="form.conditions" type="textarea" :rows="3" />
        </el-form-item>

        <el-form-item label="所需材料">
          <el-input v-model="form.materials" type="textarea" :rows="4" placeholder="每行一项材料" />
        </el-form-item>

        <el-form-item label="办理流程">
          <el-input v-model="form.processDesc" type="textarea" :rows="2" placeholder="如 申请 → 受理 → 审核 → 发证" />
        </el-form-item>

        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>

    <!-- 详情抽屉 -->
    <el-drawer v-model="detailVisible" title="办事指南详情" size="700px">
      <div v-loading="detailLoading" v-if="detail.id">
        <h2 style="margin:0 0 16px 0; color:#1e3a8a;">{{ detail.title }}</h2>

        <el-descriptions :column="2" border>
          <el-descriptions-item label="编码">{{ detail.guideCode }}</el-descriptions-item>
          <el-descriptions-item label="分类">{{ detail.category }}</el-descriptions-item>
          <el-descriptions-item label="服务对象" :span="2">{{ detail.serviceObject || '-' }}</el-descriptions-item>
          <el-descriptions-item label="法定时限">{{ detail.legalDays || '-' }} 天</el-descriptions-item>
          <el-descriptions-item label="承诺时限">{{ detail.promiseDays || '-' }} 天</el-descriptions-item>
          <el-descriptions-item label="收费标准">{{ detail.chargeStandard || '-' }}</el-descriptions-item>
          <el-descriptions-item label="咨询电话">{{ detail.consultPhone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="在线办理" :span="2">
            <a v-if="detail.onlineUrl" :href="detail.onlineUrl" target="_blank">{{ detail.onlineUrl }}</a>
            <span v-else>-</span>
          </el-descriptions-item>
        </el-descriptions>

        <div class="section">
          <div class="section-title">法律依据</div>
          <div class="section-content">{{ detail.legalBasis || '-' }}</div>
        </div>

        <div class="section">
          <div class="section-title">办理条件</div>
          <div class="section-content">{{ detail.conditions || '-' }}</div>
        </div>

        <div class="section">
          <div class="section-title">所需材料</div>
          <div class="section-content" style="white-space:pre-wrap;">{{ detail.materials || '-' }}</div>
        </div>

        <div class="section">
          <div class="section-title">办理流程</div>
          <div class="section-content">{{ detail.processDesc || '-' }}</div>
        </div>
      </div>
    </el-drawer>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  pageGuides, getGuideCategories, getGuide,
  createGuide, updateGuide, deleteGuide, toggleGuideStatus
} from '../api/guide'

const list = ref([])
const total = ref(0)
const loading = ref(false)
const categories = ref([])

const query = reactive({ page: 1, size: 10, keyword: '', category: '' })

const dialogVisible = ref(false)
const submitting = ref(false)
const form = reactive({
  id: null, guideCode: '', title: '', category: '', deptId: 2,
  serviceObject: '', legalBasis: '', conditions: '', materials: '',
  processDesc: '', legalDays: 0, promiseDays: 0,
  chargeStandard: '免费', consultPhone: '', onlineUrl: '', status: 1
})

const detailVisible = ref(false)
const detailLoading = ref(false)
const detail = ref({})

async function load() {
  loading.value = true
  try {
    const res = await pageGuides(query)
    if (res.code === 200) {
      list.value = res.data.records || []
      total.value = res.data.total || 0
    }
  } finally {
    loading.value = false
  }
}

async function loadCategories() {
  const res = await getGuideCategories()
  if (res.code === 200) categories.value = res.data || []
}

function handleSearch() {
  query.page = 1
  load()
}

function openDialog(row) {
  if (row) {
    Object.assign(form, { ...row })
  } else {
    Object.assign(form, {
      id: null, guideCode: '', title: '', category: '', deptId: 2,
      serviceObject: '', legalBasis: '', conditions: '', materials: '',
      processDesc: '', legalDays: 0, promiseDays: 0,
      chargeStandard: '免费', consultPhone: '', onlineUrl: '', status: 1
    })
  }
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!form.guideCode || !form.title) {
    ElMessage.warning('请填写编码和名称')
    return
  }
  submitting.value = true
  try {
    const res = form.id ? await updateGuide(form) : await createGuide(form)
    if (res.code === 200) {
      ElMessage.success(form.id ? '修改成功' : '新增成功')
      dialogVisible.value = false
      load()
      loadCategories()
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    submitting.value = false
  }
}

async function showDetail(row) {
  detailVisible.value = true
  detailLoading.value = true
  try {
    const res = await getGuide(row.id)
    if (res.code === 200) detail.value = res.data
  } finally {
    detailLoading.value = false
  }
}

async function handleToggle(row) {
  const newStatus = row.status === 1 ? 0 : 1
  const action = newStatus === 0 ? '停用' : '启用'
  const res = await toggleGuideStatus(row.id, newStatus)
  if (res.code === 200) {
    ElMessage.success(`已${action}`)
    load()
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确认删除「${row.title}」？`, '提示', { type: 'warning' })
  const res = await deleteGuide(row.id)
  if (res.code === 200) {
    ElMessage.success('已删除')
    load()
  }
}

onMounted(() => {
  load()
  loadCategories()
})
</script>

<style scoped>
.section {
  margin-top: 20px;
}
.section-title {
  font-weight: bold;
  font-size: 15px;
  color: #1e3a8a;
  padding-left: 10px;
  border-left: 4px solid #409eff;
  margin-bottom: 8px;
}
.section-content {
  padding: 10px 14px;
  background: #f5f7fa;
  border-radius: 4px;
  font-size: 14px;
  line-height: 1.8;
  color: #303133;
}
</style>