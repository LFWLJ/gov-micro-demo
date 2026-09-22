<template>
  <div class="login-wrap">
    <div class="login-box">
      <h2>政务管理系统</h2>
      <el-form :model="form" label-width="0" @keyup.enter="handleLogin">
        <el-form-item>
          <el-input v-model="form.username" placeholder="用户名" size="large" />
        </el-form-item>
        <el-form-item>
          <el-input v-model="form.password" type="password" placeholder="密码" size="large" show-password />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" style="width:100%" :loading="loading" @click="handleLogin">
            登 录
          </el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { login } from '../api/auth'
import { useUserStore } from '../stores/user'

const router = useRouter()
const userStore = useUserStore()

const form = reactive({ username: 'admin', password: '123456' })
const loading = ref(false)

async function handleLogin() {
  if (!form.username || !form.password) {
    ElMessage.warning('请输入用户名和密码')
    return
  }
  loading.value = true
  try {
    const res = await login(form)
    if (res.code !== 200) {
      ElMessage.error(res.msg || '登录失败')
      return
    }
    userStore.setUser(res.data)
    ElMessage.success('登录成功')
    router.push('/application')
  } catch (e) {
    // 拦截器已处理
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-wrap {
  display: flex; align-items: center; justify-content: center;
  height: 100vh;
  background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
}
.login-box {
  width: 400px; padding: 40px; background: #fff; border-radius: 8px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
}
.login-box h2 {
  text-align: center; margin-bottom: 30px; color: #1e3a8a;
}
</style>