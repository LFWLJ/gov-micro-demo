<template>
  <el-card>
    <template #header>
      <div style="font-weight:bold;">好差评管理</div>
    </template>

    <!-- 统计卡片 -->
    <el-row :gutter="16" style="margin-bottom:16px;">
      <el-col :span="6">
        <div class="stat-box">
          <div class="stat-value">{{ stats.total || 0 }}</div>
          <div class="stat-label">评价总数</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-box" style="border-color:#67c23a;">
          <div class="stat-value" style="color:#67c23a;">{{ stats.goodRate || 0 }}%</div>
          <div class="stat-label">好评率</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-box" style="border-color:#f56c6c;">
          <div class="stat-value" style="color:#f56c6c;">{{ stats.badCount || 0 }}</div>
          <div class="stat-label">差评数</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-box" style="border-color:#e6a23c;">
          <div class="stat-value" style="color:#e6a23c;">{{ stats.pendingRectify || 0 }}</div>
          <div class="stat-label">待整改</div>
        </div>
      </el-col>
    </el-row>

    <!-- 查询 -->
    <el-form :inline="true" style="margin-bottom:12px;">
      <el-form-item label="评分">
        <el-select v-model="query.score" placeholder="全部" style="width:130px" clearable>
          <el-option label="非常满意" :value="5" />
          <el-option label="满意" :value="4" />
          <el-option label="基本满意" :value="3" />
          <el-option label="不满意" :value="2" />
          <el-option label="非常不满意" :value="1" />
        </el-select>
      </el-form-item>
      <el-form-item label="是否差评">
        <el-select v-model="query.isBad" placeholder="全部" style="width:100px" clearable>
          <el-option label="是" :value="1" />
          <el-option label="否" :value="0" />
        </el-select>
      </el-form-item>
      <el-form-item label="整改状态">
        <el-select v-model="query.rectifyStatus" placeholder="全部" style="width:110px" clearable>
          <el-option label="待整改" value="PENDING" />
          <el-option label="已整改" value="DONE" />
          <el-option label="无需整改" value="NONE" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
        <el-button type="success" @click="dialogVisible = true">模拟评价</el-button>
      </el-form-item>
    </el-form>

    <!-- 表格 -->
    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="businessKey" label="业务单号" width="140" />
      <el-table-column prop="evaluator" label="评价人" width="100" />
      <el-table-column label="评分" width="140">
        <template #default="{ row }">
          <el-rate :model-value="row.score" disabled show-score />
        </template>
      </el-table-column>
      <el-table-column prop="content" label="评价内容" show-overflow-tooltip />
      <el-table-column prop="channel" label="渠道" width="90">
        <template #default="{ row }">
          <el-tag size="small">{{ channelLabel(row.channel) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="是否差评" width="90">
        <template #default="{ row }">
          <el-tag v-if="row.isBad === 1" type="danger" size="small">差评</el-tag>
          <el-tag v-else type="success" size="small">好评</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="整改状态" width="100">
        <template #default="{ row }">
          <el-tag v-if="row.rectifyStatus === 'PENDING'" type="warning" size="small">待整改</el-tag>
          <el-tag v-else-if="row.rectifyStatus === 'DONE'" type="success" size="small">已整改</el-tag>
          <el-tag v-else type="info" size="small">无需</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="评价时间" width="180" />
      <el-table-column label="操作" width="100" fixed="right">
        <template #default="{ row }">
          <el-button
            v-if="row.rectifyStatus === 'PENDING'"
            type="danger"
            link
            size="small"
            @click="openRectify(row)"
          >
            整改
          </el-button>
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

    <!-- 模拟评价弹窗 -->
    <el-dialog v-model="dialogVisible" title="模拟提交评价" width="520px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="业务单号">
          <el-input v-model="form.businessKey" />
        </el-form-item>
        <el-form-item label="评价人">
          <el-input v-model="form.evaluator" />
        </el-form-item>
        <el-form-item label="评分">
          <el-rate v-model="form.score" show-text :texts="rateTexts" />
        </el-form-item>
        <el-form-item label="评价内容">
          <el-input v-model="form.content" type="textarea" :rows="3" />
        </el-form-item>
        <el-form-item label="渠道">
          <el-select v-model="form.channel" style="width:100%">
            <el-option label="网上办事" value="ONLINE" />
            <el-option label="手机APP" value="APP" />
            <el-option label="窗口" value="WINDOW" />
            <el-option label="电话" value="PHONE" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>

    <!-- 整改弹窗 -->
    <el-dialog v-model="rectifyVisible" title="差评整改" width="520px">
      <el-form label-width="100px">
        <el-form-item label="整改内容">
          <el-input v-model="rectifyContent" type="textarea" :rows="4" placeholder="请填写整改措施和结果" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rectifyVisible = false">取消</el-button>
        <el-button type="primary" @click="handleRectify">提交整改</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  pageEvaluations, submitEvaluation, rectifyEvaluation, getEvaluationStats
} from '../api/evaluation'

const list = ref([])
const total = ref(0)
const loading = ref(false)
const stats = reactive({})

const query = reactive({ page: 1, size: 10, score: null, isBad: null, rectifyStatus: '' })

const dialogVisible = ref(false)
const form = reactive({
  businessKey: '',
  evaluator: '',
  score: 5,
  content: '',
  channel: 'ONLINE'
})
const rateTexts = ['非常不满意', '不满意', '基本满意', '满意', '非常满意']

const rectifyVisible = ref(false)
const rectifyContent = ref('')
const rectifyId = ref(null)

async function load() {
  loading.value = true
  try {
    const res = await pageEvaluations(query)
    if (res.code === 200) {
      list.value = res.data.records || []
      total.value = res.data.total || 0
    }
  } finally {
    loading.value = false
  }
}

async function loadStats() {
  const res = await getEvaluationStats()
  if (res.code === 200) Object.assign(stats, res.data)
}

function handleSearch() {
  query.page = 1
  load()
}

function handleReset() {
  query.score = null
  query.isBad = null
  query.rectifyStatus = ''
  query.page = 1
  load()
}

async function handleSubmit() {
  if (!form.businessKey || !form.evaluator) {
    ElMessage.warning('请填写业务单号和评价人')
    return
  }
  const res = await submitEvaluation({ ...form })
  if (res.code === 200) {
    ElMessage.success('评价提交成功')
    dialogVisible.value = false
    form.businessKey = ''
    form.evaluator = ''
    form.content = ''
    load()
    loadStats()
  } else {
    ElMessage.error(res.msg)
  }
}

function openRectify(row) {
  rectifyId.value = row.id
  rectifyContent.value = ''
  rectifyVisible.value = true
}

async function handleRectify() {
  if (!rectifyContent.value) {
    ElMessage.warning('请填写整改内容')
    return
  }
  const res = await rectifyEvaluation(rectifyId.value, rectifyContent.value)
  if (res.code === 200) {
    ElMessage.success('整改完成')
    rectifyVisible.value = false
    load()
    loadStats()
  } else {
    ElMessage.error(res.msg)
  }
}

function channelLabel(c) {
  const map = { ONLINE: '网上', APP: 'APP', WINDOW: '窗口', PHONE: '电话' }
  return map[c] || c
}

onMounted(() => {
  load()
  loadStats()
})
</script>

<style scoped>
.stat-box {
  background: #fff;
  border: 2px solid #409eff;
  border-radius: 6px;
  padding: 18px;
  text-align: center;
}
.stat-value {
  font-size: 30px;
  font-weight: bold;
  color: #409eff;
}
.stat-label {
  font-size: 13px;
  color: #909399;
  margin-top: 6px;
}
</style>