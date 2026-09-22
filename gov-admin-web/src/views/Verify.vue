<template>
  <div class="verify-wrap">
    <div class="verify-box">
      <div class="verify-title">电子证照验真</div>

      <el-input
        v-model="code"
        placeholder="请输入验真码"
        size="large"
        style="margin-bottom:16px;"
      >
        <template #append>
          <el-button @click="handleVerify">验真</el-button>
        </template>
      </el-input>

      <div v-if="result" class="result">
        <el-result
          :icon="result.expired || result.status !== 'VALID' ? 'warning' : 'success'"
          :title="result.expired ? '证照已过期' : (result.status === 'REVOKED' ? '证照已吊销' : '证照真实有效')"
        >
          <template #sub-title>
            <div style="text-align:left; margin-top:20px; font-size:14px; line-height:2;">
              <div><strong>证照编号：</strong>{{ result.licenseNo }}</div>
              <div><strong>持证人：</strong>{{ result.holderName }}</div>
              <div><strong>发证机关：</strong>{{ result.issueDept }}</div>
              <div><strong>发证日期：</strong>{{ result.issueDate }}</div>
              <div><strong>有效期至：</strong>{{ result.expireDate || '长期' }}</div>
              <div><strong>证照状态：</strong>{{ statusText }}</div>
            </div>
          </template>
        </el-result>
      </div>

      <el-empty v-else description="输入验真码查看证照真伪" />
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { verifyLicense } from '../api/license'

const route = useRoute()
const code = ref(route.query.code || '')
const result = ref(null)

const statusText = computed(() => {
  if (!result.value) return ''
  if (result.value.status === 'REVOKED') return '已吊销'
  if (result.value.expired) return '已过期'
  return '有效'
})

async function handleVerify() {
  if (!code.value) {
    ElMessage.warning('请输入验真码')
    return
  }
  try {
    const res = await verifyLicense(code.value)
    if (res.code === 200) {
      result.value = res.data
    } else {
      ElMessage.error(res.msg)
    }
  } catch (e) {
    result.value = null
    ElMessage.error('验证失败')
  }
}

// 页面加载时自动验真
if (code.value) {
  handleVerify()
}
</script>

<style scoped>
.verify-wrap {
  display: flex; align-items: center; justify-content: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
  padding: 20px;
}
.verify-box {
  width: 560px;
  background: #fff;
  border-radius: 8px;
  padding: 40px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
}
.verify-title {
  text-align: center;
  font-size: 24px;
  font-weight: bold;
  color: #1e3a8a;
  margin-bottom: 30px;
}
</style>