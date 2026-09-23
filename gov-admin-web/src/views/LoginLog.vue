<template>
  <el-card>
    <template #header>
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <span style="font-weight:bold;">登录日志</span>
        <div>
          <el-input
            v-model="query.username"
            placeholder="用户名"
            style="width:180px; margin-right:8px;"
            clearable
            @keyup.enter="handleSearch"
          />
          <el-select
            v-model="query.status"
            placeholder="全部结果"
            style="width:130px; margin-right:8px;"
            clearable
            @change="handleSearch"
          >
            <el-option label="成功" :value="1" />
            <el-option label="失败" :value="0" />
          </el-select>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </div>
      </div>
    </template>

    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column prop="id" label="ID" width="70" />
      <el-table-column prop="username" label="用户名" width="140" />
      <el-table-column prop="ip" label="IP 地址" width="150" />
      <el-table-column prop="browser" label="浏览器" width="110" />
      <el-table-column prop="os" label="操作系统" width="110" />
      <el-table-column label="结果" width="90">
        <template #default="{ row }">
          <el-tag v-if="row.status === 1" type="success" size="small">成功</el-tag>
          <el-tag v-else type="danger" size="small">失败</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="msg" label="备注" show-overflow-tooltip />
      <el-table-column prop="tenantId" label="租户" width="110" />
      <el-table-column prop="loginTime" label="登录时间" width="180" />
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
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { pageLoginLogs } from '../api/loginlog'

const list = ref([])
const total = ref(0)
const loading = ref(false)

const query = reactive({
  page: 1,
  size: 10,
  username: '',
  status: null
})

async function load() {
  loading.value = true
  try {
    const res = await pageLoginLogs(query)
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
  query.username = ''
  query.status = null
  query.page = 1
  load()
}

onMounted(load)
</script>