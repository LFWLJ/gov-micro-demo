<template>
  <div class="error-container">
    <div class="error-code">404</div>
    <div class="error-title">页面不存在</div>
    <div class="error-desc">抱歉，您访问的页面走丢了</div>
    <div class="error-actions">
      <el-button type="primary" @click="goHome">返回首页</el-button>
      <el-button @click="goBack">返回上一页</el-button>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()
function goHome() { router.push('/') }
function goBack() { router.back() }
</script>

<style scoped>
.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background: #f5f7fa;
}
.error-code {
  font-size: 120px;
  font-weight: bold;
  color: #1e3a8a;
  line-height: 1;
  letter-spacing: 8px;
}
.error-title {
  font-size: 24px;
  color: #303133;
  margin-top: 16px;
}
.error-desc {
  font-size: 14px;
  color: #909399;
  margin-top: 8px;
  margin-bottom: 32px;
}
.error-actions {
  display: flex;
  gap: 12px;
}
</style>