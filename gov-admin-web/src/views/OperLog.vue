<template>
  <el-card>
    <template #header>
      <div style="font-weight:bold;">操作日志</div>
    </template>

    <!-- 查询表单 -->
    <el-form :inline="true" :model="query" style="margin-bottom:12px;">
      <el-form-item label="模块">
        <el-input v-model="query.module" placeholder="如：审批流程" style="width:150px" clearable />
      </el-form-item>
      <el-form-item label="操作">
        <el-input v-model="query.operation" placeholder="如：发起流程" style="width:150px" clearable />
      </el-form-item>
      <el-form-item label="结果">
        <el-select v-model="query.result" placeholder="全部" style="width:100px" clearable>
          <el-option label="成功" :value="1" />
          <el-option label="失败" :value="0" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 表格 -->
    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="module" label="模块" width="110" />
      <el-table-column prop="operation" label="操作" width="130" />
      <el-table-column prop="method" label="方法" width="80" />
      <el-table-column prop="uri" label="URI" show-overflow-tooltip />
      <el-table-column prop="userId" label="用户" width="80" />
      <el-table-column label="结果" width="80">
        <template #default="{ row }">
          <el-tag v-if="row.result === 1" type="success">成功</el-tag>
          <el-tag v-else type="danger">失败</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="costMs" label="耗时(ms)" width="100" />
      <el-table-column prop="ip" label="IP" width="130" />
      <el-table-column prop="createTime" label="时间" width="180" />
      <el-table-column label="操作" width="90" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="showDetail(row)">详情</el-button>
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

    <!-- 详情弹窗 -->
    <el-dialog v-model="detailVisible" title="操作日志详情" width="760px">
      <el-descriptions v-if="detail" :column="2" border>
        <el-descriptions-item label="ID">{{ detail.id }}</el-descriptions-item>
        <el-descriptions-item label="租户">{{ detail.tenantId }}</el-descriptions-item>
        <el-descriptions-item label="模块">{{ detail.module }}</el-descriptions-item>
        <el-descriptions-item label="操作">{{ detail.operation }}</el-descriptions-item>
        <el-descriptions-item label="请求方法">
          <el-tag size="small">{{ detail.method }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="用户">{{ detail.userId }}</el-descriptions-item>
        <el-descriptions-item label="URI" :span="2">
          <span style="font-family:Consolas, monospace;">{{ detail.uri }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="结果">
          <el-tag v-if="detail.result === 1" type="success">成功</el-tag>
          <el-tag v-else type="danger">失败</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="耗时">{{ detail.costMs }} ms</el-descriptions-item>
        <el-descriptions-item label="IP">{{ detail.ip }}</el-descriptions-item>
        <el-descriptions-item label="时间">{{ detail.createTime }}</el-descriptions-item>
      </el-descriptions>

      <!-- 请求参数 -->
      <div v-if="detail && detail.params" style="margin-top:16px;">
        <div style="font-weight:bold; margin-bottom:8px;">请求参数</div>
        <pre class="code-block">{{ formatJson(detail.params) }}</pre>
      </div>

      <!-- 错误信息 -->
      <div v-if="detail && detail.errorMsg" style="margin-top:16px;">
        <div style="font-weight:bold; margin-bottom:8px; color:#f56c6c;">错误信息</div>
        <pre class="code-block error">{{ detail.errorMsg }}</pre>
      </div>

      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import api from '../api/request'

const list = ref([])
const total = ref(0)
const loading = ref(false)
const query = reactive({ page: 1, size: 10, module: '', operation: '', result: null })

// 详情
const detailVisible = ref(false)
const detail = ref(null)

async function load() {
  loading.value = true
  try {
    const res = await api.get('/api/operlog/page', { params: query })
    if (res.code === 200) {
      list.value = res.data.records || []
      total.value = res.data.total || 0
    }
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  query.page = 1
  load()
}

function handleReset() {
  query.module = ''
  query.operation = ''
  query.result = null
  query.page = 1
  load()
}

async function showDetail(row) {
  try {
    const res = await api.get(`/api/operlog/${row.id}`)
    if (res.code === 200) {
      detail.value = res.data
    } else {
      detail.value = row  // 兜底
    }
  } catch (e) {
    detail.value = row  // 接口失败也用行数据兜底
  }
  detailVisible.value = true
}

function formatJson(str) {
  try {
    return JSON.stringify(JSON.parse(str), null, 2)
  } catch (e) {
    return str
  }
}

onMounted(load)
</script>

<style scoped>
.code-block {
  background: #f5f7fa;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  padding: 12px;
  font-family: Consolas, Monaco, monospace;
  font-size: 13px;
  line-height: 1.5;
  max-height: 300px;
  overflow: auto;
  white-space: pre-wrap;
  word-break: break-all;
  margin: 0;
}
.code-block.error {
  background: #fef0f0;
  border-color: #fde2e2;
  color: #f56c6c;
}
</style>