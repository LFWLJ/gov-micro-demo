<template>
  <el-container style="height: 100vh">
    <el-aside width="220px" style="background:#1e3a8a; color:#fff;">
      <div class="logo">政务管理系统</div>
      <el-menu
        :default-active="$route.path"
        router
        background-color="#1e3a8a"
        text-color="#fff"
        active-text-color="#60a5fa"
      >
        <el-menu-item index="/dashboard">
          <el-icon><HomeFilled /></el-icon>
          <span>首页</span>
        </el-menu-item>

        <el-menu-item index="/application">
          <el-icon><Document /></el-icon>
          <span>事项管理</span>
        </el-menu-item>

        <el-menu-item index="/process">
          <el-icon><Checked /></el-icon>
          <span>审批流程</span>
        </el-menu-item>

        <el-menu-item index="/file">
          <el-icon><Folder /></el-icon>
          <span>文件管理</span>
        </el-menu-item>

        <el-menu-item index="/operlog">
          <el-icon><Tickets /></el-icon>
          <span>操作日志</span>
        </el-menu-item>

        <el-menu-item index="/dept">
          <el-icon><OfficeBuilding /></el-icon>
          <span>部门管理</span>
        </el-menu-item>

        <el-menu-item index="/user">
          <el-icon><User /></el-icon>
          <span>用户管理</span>
        </el-menu-item>

        <el-menu-item index="/license">
          <el-icon><Postcard /></el-icon>
          <span>电子证照</span>
        </el-menu-item>

        <el-menu-item index="/dict">
          <el-icon><Notebook /></el-icon>
          <span>数据字典</span>
        </el-menu-item>

        <el-menu-item index="/report">
          <el-icon><DataAnalysis /></el-icon>
          <span>统计报表</span>
        </el-menu-item>

        <el-menu-item index="/guide">
          <el-icon><Memo /></el-icon>
          <span>办事指南</span>
        </el-menu-item>

        <el-menu-item index="/appointment">
          <el-icon><Calendar /></el-icon>
          <span>预约取号</span>
        </el-menu-item>

        <el-menu-item index="/evaluation">
          <el-icon><StarFilled /></el-icon>
          <span>好差评</span>
        </el-menu-item>

        <el-menu-item index="/config">
          <el-icon><Setting /></el-icon>
          <span>系统配置</span>
        </el-menu-item>

      </el-menu>
    </el-aside>

    <el-container>
      <el-header class="header">
        <div style="font-weight:bold; color:#1e3a8a;">
          {{ $route.meta.title || '' }}
        </div>
        <div style="font-size:14px; color:#666;">
          <el-button type="primary" link @click="goScreen" style="margin-right:16px;">
            数据大屏
          </el-button>
          {{ userStore.realName }} ({{ userStore.tenantId }})
          <el-button link type="primary" style="margin-left:16px;" @click="handleLogout">
            退出
          </el-button>
        </div>
      </el-header>

      <el-main style="background:#f5f7fa;">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '../stores/user'
import { logout } from '../api/auth'

const router = useRouter()
const userStore = useUserStore()

function goScreen() {
  router.push('/screen')
}

async function handleLogout() {
  try {
    await logout()
  } catch (e) {
    // 忽略
  }
  userStore.clear()
  ElMessage.success('已退出')
  router.push('/login')
}
</script>

<style scoped>
.logo {
  height: 60px;
  line-height: 60px;
  text-align: center;
  font-size: 18px;
  font-weight: bold;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}
.header {
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
}
</style>