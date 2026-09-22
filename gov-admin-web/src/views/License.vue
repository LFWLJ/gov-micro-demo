<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">电子证照</span>
        <div>
          <el-input v-model="query.keyword" placeholder="证照编号/持证人" style="width:200px; margin-right:8px;" clearable @keyup.enter="handleSearch" />
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button type="success" @click="openIssueDialog">生成证照</el-button>
        </div>
      </div>
    </template>

    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="licenseNo" label="证照编号" width="200" />
      <el-table-column prop="holderName" label="持证人" width="120" />
      <el-table-column prop="issueDept" label="发证机关" show-overflow-tooltip />
      <el-table-column prop="issueDate" label="发证日期" width="120" />
      <el-table-column prop="expireDate" label="有效期至" width="120" />
      <el-table-column label="状态" width="100">
        <template #default="{ row }">
          <el-tag v-if="row.status === 'VALID'" type="success" size="small">有效</el-tag>
          <el-tag v-else-if="row.status === 'REVOKED'" type="danger" size="small">已吊销</el-tag>
          <el-tag v-else type="info" size="small">{{ row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="openQr(row)">二维码</el-button>
          <el-button
            v-if="row.status === 'VALID'"
            type="danger"
            link
            size="small"
            @click="handleRevoke(row)"
          >
            吊销
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

    <!-- 生成证照弹窗 -->
    <el-dialog v-model="issueVisible" title="生成电子证照" width="560px">
      <el-form :model="form" label-width="110px">
        <el-form-item label="证照模板">
          <el-select v-model="form.templateCode" style="width:100%">
            <el-option v-for="t in templates" :key="t.templateCode"
                       :label="t.templateName" :value="t.templateCode" />
          </el-select>
        </el-form-item>
        <el-form-item label="持证人">
          <el-input v-model="form.holderName" />
        </el-form-item>
        <el-form-item label="身份证号">
          <el-input v-model="form.holderIdCard" />
        </el-form-item>
        <el-form-item label="发证机关">
          <el-input v-model="form.issueDept" />
        </el-form-item>
        <el-form-item label="发证日期">
          <el-date-picker v-model="form.issueDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="有效期至">
          <el-date-picker v-model="form.expireDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="证照内容">
          <el-input v-model="form.contentJson" type="textarea" :rows="3" placeholder="如：统一社会信用代码 xxx" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="issueVisible = false">取消</el-button>
        <el-button type="primary" :loading="issuing" @click="handleIssue">生成</el-button>
      </template>
    </el-dialog>

    <!-- 二维码弹窗 -->
    <el-dialog v-model="qrVisible" title="证照验真二维码" width="400px" align-center>
      <div style="text-align:center;">
        <div ref="qrRef" style="display:inline-block; padding:16px; background:#fff;"></div>
        <div style="margin-top:12px; font-size:13px; color:#666;">
          扫码验真 · 验真码：{{ currentVerifyCode }}
        </div>
      </div>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import QRCode from 'qrcode'
import { pageLicenses, getTemplates, issueLicense, revokeLicense } from '../api/license'

const list = ref([])
const total = ref(0)
const loading = ref(false)
const templates = ref([])

const query = reactive({ page: 1, size: 10, keyword: '' })

const issueVisible = ref(false)
const issuing = ref(false)
const form = reactive({
  templateCode: '',
  holderName: '',
  holderIdCard: '',
  issueDept: '',
  issueDate: '',
  expireDate: '',
  contentJson: ''
})

const qrVisible = ref(false)
const qrRef = ref(null)
const currentVerifyCode = ref('')

async function load() {
  loading.value = true
  try {
    const res = await pageLicenses(query)
    if (res.code === 200) {
      list.value = res.data.records || []
      total.value = res.data.total || 0
    }
  } finally {
    loading.value = false
  }
}

async function loadTemplates() {
  const res = await getTemplates()
  if (res.code === 200) templates.value = res.data || []
}

function handleSearch() {
  query.page = 1
  load()
}

function openIssueDialog() {
  Object.assign(form, {
    templateCode: templates.value[0]?.templateCode || '',
    holderName: '',
    holderIdCard: '',
    issueDept: '',
    issueDate: new Date().toISOString().substring(0, 10),
    expireDate: '',
    contentJson: ''
  })
  issueVisible.value = true
}

async function handleIssue() {
  if (!form.holderName || !form.issueDept) {
    ElMessage.warning('请填写持证人和发证机关')
    return
  }
  issuing.value = true
  try {
    const res = await issueLicense(form)
    if (res.code === 200) {
      ElMessage.success('证照生成成功')
      issueVisible.value = false
      load()
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    issuing.value = false
  }
}

async function openQr(row) {
  currentVerifyCode.value = row.verifyCode
  qrVisible.value = true
  await nextTick()
  const verifyUrl = `http://localhost:5173/verify?code=${row.verifyCode}`
  await QRCode.toCanvas(qrRef.value, verifyUrl, { width: 240 })
}

async function handleRevoke(row) {
  await ElMessageBox.confirm(`确认吊销证照「${row.licenseNo}」？`, '提示', { type: 'warning' })
  const res = await revokeLicense(row.id)
  if (res.code === 200) {
    ElMessage.success('已吊销')
    load()
  }
}

onMounted(() => {
  load()
  loadTemplates()
})
</script>