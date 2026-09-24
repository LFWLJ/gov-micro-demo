<template>
  <el-container style="height: 100vh">
    <el-aside width="220px" style="background:#1e3a8a; color:#fff;">
      <div class="logo">政务管理系统</div>
      <el-menu
        :default-active="$route.path"
        router
        unique-opened
        background-color="#1e3a8a"
        text-color="#fff"
        active-text-color="#60a5fa"
      >
        <template v-for="node in menuTree" :key="node.id">
          <!-- 目录：M -->
          <el-sub-menu v-if="node.menuType === 'M'" :index="String(node.id)">
            <template #title>
              <el-icon v-if="node.icon"><component :is="node.icon" /></el-icon>
              <span>{{ node.menuName }}</span>
            </template>
            <el-menu-item
              v-for="child in node.children"
              :key="child.id"
              :index="child.path"
            >
              <el-icon v-if="child.icon"><component :is="child.icon" /></el-icon>
              <span>{{ child.menuName }}</span>
            </el-menu-item>
          </el-sub-menu>

          <!-- 菜单：C -->
          <el-menu-item v-else-if="node.menuType === 'C'" :index="node.path">
            <el-icon v-if="node.icon"><component :is="node.icon" /></el-icon>
            <span>{{ node.menuName }}</span>
          </el-menu-item>
        </template>
      </el-menu>
    </el-aside>

    <el-container>
      <el-header class="header">  
        <div style="font-weight:bold; color:#1e3a8a;">
          {{ $route.meta.title || '' }}
        </div>
        <div style="display:flex; align-items:center; font-size:14px; color:#666; gap:16px;">
          <!-- 消息铃铛 -->
          <el-badge :value="unreadCount" :hidden="unreadCount === 0" :max="99">
            <el-icon
              :size="20"
              style="cursor:pointer; color:#1e3a8a;"
              @click="openNotifyDrawer"
            >
              <Bell />
            </el-icon>
          </el-badge>

          <el-button type="primary" link @click="goScreen">数据大屏</el-button>

          <span
            style="cursor:pointer;"
            @click="$router.push('/profile')"
          >
            {{ userStore.realName }} ({{ userStore.tenantId }})
          </span>

          <el-button link type="primary" @click="handleLogout">退出</el-button>
        </div>
      </el-header>

      <el-main style="background:#f5f7fa;">
        <router-view />
      </el-main>
    </el-container>

    <!-- 消息抽屉 -->
    <el-drawer v-model="notifyVisible" title="消息中心" size="480px">
      <div style="display:flex; justify-content:space-between; margin-bottom:16px;">
        <el-radio-group v-model="notifyFilter" size="small" @change="loadNotifies">
          <el-radio-button :value="null">全部</el-radio-button>
          <el-radio-button :value="0">未读</el-radio-button>
          <el-radio-button :value="1">已读</el-radio-button>
        </el-radio-group>
        <el-button type="primary" link size="small" @click="handleReadAll">
          全部已读
        </el-button>
      </div>

      <div v-loading="notifyLoading" style="min-height:200px;">
        <el-empty v-if="notifies.length === 0" description="暂无消息" />

        <div
          v-for="item in notifies"
          :key="item.id"
          class="notify-item"
          :class="{ unread: item.isRead === 0 }"
          @click="handleRead(item)"
        >
          <div class="notify-header">
            <el-tag v-if="item.type === 'TASK'" type="warning" size="small">待办</el-tag>
            <el-tag v-else-if="item.type === 'SYSTEM'" type="info" size="small">系统</el-tag>
            <el-tag v-else size="small">{{ item.type }}</el-tag>

            <span class="notify-time">{{ formatTime(item.createTime) }}</span>

            <el-icon
              style="margin-left:auto; cursor:pointer; color:#f56c6c;"
              @click.stop="handleDelete(item)"
            >
              <Delete />
            </el-icon>
          </div>
          <div class="notify-title">{{ item.title }}</div>
          <div class="notify-content">{{ item.content }}</div>
        </div>
      </div>

      <div v-if="notifyTotal > notifies.length" style="text-align:center; margin-top:16px;">
        <el-button link type="primary" @click="loadMore">加载更多</el-button>
      </div>
    </el-drawer>
  </el-container>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '../stores/user'
import { usePermissionStore } from '../stores/permission'
import { logout } from '../api/auth'
import {
  pageNotifies, getUnreadCount, readNotify, readAllNotify, deleteNotify
} from '../api/notify'

const router = useRouter()
const userStore = useUserStore()
const permissionStore = usePermissionStore()

// ↓ 侧边栏菜单树（来自 Pinia）
const menuTree = computed(() => permissionStore.menuTree)

// 消息状态
const notifyVisible = ref(false)
const notifyLoading = ref(false)
const notifies = ref([])
const notifyTotal = ref(0)
const notifyPage = ref(1)
const notifySize = 10
const notifyFilter = ref(null)
const unreadCount = ref(0)

let timer = null

function goScreen() {
  router.push('/screen')
}

async function handleLogout() {
  try {
    await logout()
  } catch (e) {}
  userStore.clear()
  permissionStore.clear()
  ElMessage.success('已退出')
  router.push('/login')
}

async function loadUnreadCount() {
  try {
    const res = await getUnreadCount(userStore.realName)
    if (res.code === 200) {
      unreadCount.value = res.data || 0
    }
  } catch (e) {}
}

function openNotifyDrawer() {
  notifyVisible.value = true
  notifyPage.value = 1
  notifies.value = []
  loadNotifies()
  loadUnreadCount()
}

async function loadNotifies() {
  notifyLoading.value = true
  try {
    const res = await pageNotifies({
      receiver: userStore.realName,
      page: notifyPage.value,
      size: notifySize,
      isRead: notifyFilter.value
    })
    if (res.code === 200) {
      notifies.value = res.data.records || []
      notifyTotal.value = res.data.total || 0
    }
  } finally {
    notifyLoading.value = false
  }
}

async function loadMore() {
  notifyPage.value++
  notifyLoading.value = true
  try {
    const res = await pageNotifies({
      receiver: userStore.realName,
      page: notifyPage.value,
      size: notifySize,
      isRead: notifyFilter.value
    })
    if (res.code === 200) {
      notifies.value = notifies.value.concat(res.data.records || [])
    }
  } finally {
    notifyLoading.value = false
  }
}

async function handleRead(item) {
  if (item.isRead === 1) return
  await readNotify(item.id, userStore.realName)
  item.isRead = 1
  loadUnreadCount()
}

async function handleReadAll() {
  await readAllNotify(userStore.realName)
  ElMessage.success('已全部标记为已读')
  loadNotifies()
  loadUnreadCount()
}

async function handleDelete(item) {
  await deleteNotify(item.id, userStore.realName)
  ElMessage.success('已删除')
  loadNotifies()
  loadUnreadCount()
}

function formatTime(t) {
  if (!t) return ''
  const s = String(t)
  const idx = s.indexOf('T')
  if (idx > 0) {
    return s.substring(0, 10) + ' ' + s.substring(idx + 1, idx + 9)
  }
  return s
}

onMounted(() => {
  loadUnreadCount()
  timer = setInterval(loadUnreadCount, 30000)
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})
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

.notify-item {
  padding: 12px;
  border-bottom: 1px solid #ebeef5;
  cursor: pointer;
  transition: background 0.2s;
  border-radius: 4px;
}
.notify-item:hover {
  background: #f5f7fa;
}
.notify-item.unread {
  background: #ecf5ff;
}
.notify-item.unread .notify-title {
  font-weight: bold;
}
.notify-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
}
.notify-time {
  font-size: 12px;
  color: #909399;
}
.notify-title {
  font-size: 14px;
  color: #303133;
  margin-bottom: 4px;
}
.notify-content {
  font-size: 13px;
  color: #606266;
  line-height: 1.5;
}
</style>