<template>
  <el-row :gutter="16">
    <!-- 左侧：个人信息卡片 -->
    <el-col :span="8">
      <el-card>
        <div class="profile-header">
          <el-avatar :size="80" class="avatar">
            {{ avatarText }}
          </el-avatar>
          <div class="real-name">{{ form.realName || '未设置' }}</div>
          <div class="username">@{{ form.username }}</div>
        </div>

        <el-divider />

        <el-descriptions :column="1" size="small" border>
          <el-descriptions-item label="用户ID">{{ form.id }}</el-descriptions-item>
          <el-descriptions-item label="用户名">{{ form.username }}</el-descriptions-item>
          <el-descriptions-item label="租户">{{ form.tenantId }}</el-descriptions-item>
          <el-descriptions-item label="角色">
            <el-tag v-if="form.roles && form.roles.includes('ADMIN')" type="danger" size="small">
              管理员
            </el-tag>
            <el-tag v-else type="info" size="small">普通用户</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="部门ID">{{ form.deptId || '-' }}</el-descriptions-item>
          <el-descriptions-item label="数据范围">{{ scopeLabel }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag v-if="form.status === 1" type="success" size="small">启用</el-tag>
            <el-tag v-else type="danger" size="small">禁用</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ form.createTime || '-' }}</el-descriptions-item>
        </el-descriptions>
      </el-card>
    </el-col>

    <!-- 右侧：修改表单 -->
    <el-col :span="16">
      <el-card>
        <template #header>
          <div style="font-weight:bold;">基本资料</div>
        </template>

        <el-form :model="form" label-width="100px" style="max-width:500px;">
          <el-form-item label="用户名">
            <el-input v-model="form.username" disabled />
          </el-form-item>
          <el-form-item label="真实姓名">
            <el-input v-model="form.realName" placeholder="请输入真实姓名" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="saving" @click="handleSaveProfile">
              保存
            </el-button>
          </el-form-item>
        </el-form>

        <el-divider />

        <template #footer>
          <div style="font-weight:bold; margin-bottom:16px;">修改密码</div>
        </template>

        <el-form :model="pwdForm" label-width="100px" style="max-width:500px;">
          <el-form-item label="原密码">
            <el-input
              v-model="pwdForm.oldPassword"
              type="password"
              show-password
              placeholder="请输入原密码"
            />
          </el-form-item>
          <el-form-item label="新密码">
            <el-input
              v-model="pwdForm.newPassword"
              type="password"
              show-password
              placeholder="至少 6 位"
            />
          </el-form-item>
          <el-form-item label="确认新密码">
            <el-input
              v-model="pwdForm.confirmPassword"
              type="password"
              show-password
              placeholder="再次输入新密码"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="warning" :loading="changingPwd" @click="handleChangePassword">
              修改密码
            </el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </el-col>
  </el-row>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getProfile, updateProfile, changePassword } from '../api/user'
import { useUserStore } from '../stores/user'

const router = useRouter()
const userStore = useUserStore()

const form = reactive({
  id: null,
  username: '',
  realName: '',
  tenantId: '',
  roles: '',
  deptId: null,
  dataScope: null,
  status: 1,
  createTime: ''
})

const pwdForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const saving = ref(false)
const changingPwd = ref(false)

const avatarText = computed(() => {
  return form.realName ? form.realName.substring(0, 1) : 'U'
})

const scopeLabel = computed(() => {
  const map = { 1: '全部数据', 2: '本部门及以下', 3: '本部门', 4: '仅本人' }
  return map[form.dataScope] || '-'
})

async function load() {
  try {
    const res = await getProfile()
    if (res.code === 200) {
      Object.assign(form, res.data)
      // 处理时间格式
      if (form.createTime) {
        form.createTime = String(form.createTime).replace('T', ' ').substring(0, 19)
      }
    } else {
      ElMessage.error(res.msg)
    }
  } catch (e) {
    ElMessage.error('加载失败')
  }
}

async function handleSaveProfile() {
  if (!form.realName) {
    ElMessage.warning('姓名不能为空')
    return
  }
  saving.value = true
  try {
    const res = await updateProfile({ realName: form.realName })
    if (res.code === 200) {
      ElMessage.success('保存成功')
      // 同步到 store 和 localStorage
      userStore.realName = form.realName
      localStorage.setItem('realName', form.realName)
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    saving.value = false
  }
}

async function handleChangePassword() {
  if (!pwdForm.oldPassword) {
    ElMessage.warning('请输入原密码')
    return
  }
  if (!pwdForm.newPassword || pwdForm.newPassword.length < 6) {
    ElMessage.warning('新密码至少 6 位')
    return
  }
  if (pwdForm.newPassword !== pwdForm.confirmPassword) {
    ElMessage.warning('两次输入的密码不一致')
    return
  }
  changingPwd.value = true
  try {
    const res = await changePassword({
      oldPassword: pwdForm.oldPassword,
      newPassword: pwdForm.newPassword
    })
    if (res.code === 200) {
      ElMessage.success('密码修改成功，请重新登录')
      setTimeout(() => {
        userStore.clear()
        router.push('/login')
      }, 1000)
    } else {
      ElMessage.error(res.msg)
    }
  } finally {
    changingPwd.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.profile-header {
  text-align: center;
  padding: 10px 0;
}
.avatar {
  background: #1e3a8a;
  font-size: 32px;
  font-weight: bold;
}
.real-name {
  font-size: 20px;
  font-weight: bold;
  color: #303133;
  margin-top: 12px;
}
.username {
  font-size: 13px;
  color: #909399;
  margin-top: 4px;
}
</style>