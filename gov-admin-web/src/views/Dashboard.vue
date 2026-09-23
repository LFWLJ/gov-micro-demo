<template>
  <div v-loading="loading">
    <!-- 欢迎卡片 -->
    <el-card class="welcome-card" shadow="never">
      <div class="welcome-content">
        <div>
          <div class="welcome-title">
            {{ greeting }}，{{ userStore.realName }}！
          </div>
          <div class="welcome-sub">
            今天有 <strong>{{ summary.pendingTaskCount || 0 }}</strong> 条待办，
            未读消息 <strong>{{ summary.unreadCount || 0 }}</strong> 条
          </div>
        </div>
        <div class="welcome-time">{{ nowDate }}</div>
      </div>
    </el-card>

    <!-- 统计卡片 -->
    <el-row :gutter="16" style="margin-top:16px;">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card" @click="goProcess">
          <div class="stat-icon" style="background:#e6a23c;">
            <el-icon :size="28"><Clock /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-label">待办任务</div>
            <div class="stat-value">{{ summary.pendingTaskCount || 0 }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card" @click="goApplication">
          <div class="stat-icon" style="background:#409eff;">
            <el-icon :size="28"><Document /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-label">我的申请</div>
            <div class="stat-value">{{ summary.myApplicationCount || 0 }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background:#67c23a;">
            <el-icon :size="28"><Bell /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-label">未读消息</div>
            <div class="stat-value">{{ summary.unreadCount || 0 }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background:#909399;">
            <el-icon :size="28"><Tickets /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-label">累计办件</div>
            <div class="stat-value">{{ dashboard.totalApplications || 0 }}</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 主体：左待办 + 右消息 -->
    <el-row :gutter="16" style="margin-top:16px;">
      <!-- 待办任务 -->
      <el-col :span="14">
        <el-card shadow="never">
          <template #header>
            <div style="display:flex; justify-content:space-between; align-items:center;">
              <span style="font-weight:bold;">我的待办</span>
              <el-button link type="primary" @click="goProcess">查看全部</el-button>
            </div>
          </template>

          <el-empty
            v-if="!summary.pendingTasks || summary.pendingTasks.length === 0"
            description="暂无待办任务"
            :image-size="80"
          />
          <div v-else>
            <div
              v-for="task in summary.pendingTasks"
              :key="task.taskId"
              class="list-item"
            >
              <div class="item-left">
                <el-tag type="warning" size="small">待办</el-tag>
                <span class="item-title">{{ task.taskName }}</span>
              </div>
              <div class="item-right">
                <span class="item-time">{{ task.createTime }}</span>
                <el-button link type="primary" size="small" @click="goProcess">
                  去处理
                </el-button>
              </div>
            </div>
          </div>
        </el-card>

        <!-- 我的申请 -->
        <el-card shadow="never" style="margin-top:16px;">
          <template #header>
            <div style="display:flex; justify-content:space-between; align-items:center;">
              <span style="font-weight:bold;">我的申请</span>
              <el-button link type="primary" @click="goApplication">查看全部</el-button>
            </div>
          </template>

          <el-empty
            v-if="!summary.myApplications || summary.myApplications.length === 0"
            description="暂无申请记录"
            :image-size="80"
          />
          <div v-else>
            <div
              v-for="app in summary.myApplications"
              :key="app.id"
              class="list-item"
            >
              <div class="item-left">
                <el-tag :type="statusType(app.status)" size="small">
                  {{ statusLabel(app.status) }}
                </el-tag>
                <span class="item-title">{{ app.title }}</span>
              </div>
              <div class="item-right">
                <span class="item-time">{{ app.createTime }}</span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 消息 + 快捷入口 -->
      <el-col :span="10">
        <el-card shadow="never">
          <template #header>
            <span style="font-weight:bold;">最新消息</span>
          </template>

          <el-empty
            v-if="!summary.recentNotifies || summary.recentNotifies.length === 0"
            description="暂无消息"
            :image-size="80"
          />
          <div v-else>
            <div
              v-for="n in summary.recentNotifies"
              :key="n.id"
              class="notify-item"
            >
              <div class="notify-title">
                <el-tag v-if="n.type === 'TASK'" type="warning" size="small">待办</el-tag>
                <el-tag v-else-if="n.type === 'SYSTEM'" type="info" size="small">系统</el-tag>
                <el-tag v-else size="small">{{ n.type }}</el-tag>
                <span style="margin-left:6px;">{{ n.title }}</span>
              </div>
              <div class="notify-content">{{ n.content }}</div>
            </div>
          </div>
        </el-card>

        <el-card shadow="never" style="margin-top:16px;">
          <template #header>
            <span style="font-weight:bold;">快捷入口</span>
          </template>
          <div class="quick-links">
            <div class="quick-item" @click="goPath('/application')">
              <el-icon :size="22" color="#409eff"><Document /></el-icon>
              <span>事项管理</span>
            </div>
            <div class="quick-item" @click="goPath('/process')">
              <el-icon :size="22" color="#e6a23c"><Checked /></el-icon>
              <span>审批流程</span>
            </div>
            <div class="quick-item" @click="goPath('/guide')">
              <el-icon :size="22" color="#67c23a"><Memo /></el-icon>
              <span>办事指南</span>
            </div>
            <div class="quick-item" @click="goPath('/appointment')">
              <el-icon :size="22" color="#a78bfa"><Calendar /></el-icon>
              <span>预约取号</span>
            </div>
            <div class="quick-item" @click="goPath('/evaluation')">
              <el-icon :size="22" color="#f56c6c"><StarFilled /></el-icon>
              <span>好差评</span>
            </div>
            <div class="quick-item" @click="goPath('/license')">
              <el-icon :size="22" color="#ec4899"><Postcard /></el-icon>
              <span>电子证照</span>
            </div>
            <div class="quick-item" @click="goPath('/report')">
              <el-icon :size="22" color="#fbbf24"><DataAnalysis /></el-icon>
              <span>统计报表</span>
            </div>
            <div class="quick-item" @click="goPath('/file')">
              <el-icon :size="22" color="#00bcd4"><Folder /></el-icon>
              <span>文件管理</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getWorkspaceSummary } from '../api/workspace'
import { getDashboardStats } from '../api/dashboard'
import { useUserStore } from '../stores/user'

const router = useRouter()
const userStore = useUserStore()

const loading = ref(false)
const summary = reactive({
  pendingTaskCount: 0,
  pendingTasks: [],
  myApplicationCount: 0,
  myApplications: [],
  unreadCount: 0,
  recentNotifies: []
})
const dashboard = reactive({})

const nowDate = ref('')

const greeting = computed(() => {
  const h = new Date().getHours()
  if (h < 6) return '凌晨好'
  if (h < 9) return '早上好'
  if (h < 12) return '上午好'
  if (h < 14) return '中午好'
  if (h < 18) return '下午好'
  return '晚上好'
})

async function load() {
  loading.value = true
  try {
    // 工作台数据
    const res = await getWorkspaceSummary({
      assignee: userStore.realName,
      applicant: userStore.realName,
      receiver: userStore.realName
    })
    if (res.code === 200) {
      Object.assign(summary, res.data)
    }

    // 仪表盘数据（复用累计办件等）
    const dres = await getDashboardStats()
    if (dres.code === 200) {
      Object.assign(dashboard, dres.data?.overview || {})
    }
  } finally {
    loading.value = false
  }
}

function goProcess() { router.push('/process') }
function goApplication() { router.push('/application') }
function goPath(p) { router.push(p) }

function statusType(s) {
  const map = {
    DRAFT: 'info',
    PENDING: 'warning',
    APPROVED: 'success',
    REJECTED: 'danger'
  }
  return map[s] || 'info'
}

function statusLabel(s) {
  const map = {
    DRAFT: '草稿',
    PENDING: '待审批',
    APPROVED: '已通过',
    REJECTED: '已驳回'
  }
  return map[s] || s
}

function updateTime() {
  const d = new Date()
  const pad = n => String(n).padStart(2, '0')
  const weekdays = ['日', '一', '二', '三', '四', '五', '六']
  nowDate.value = `${d.getFullYear()}年${pad(d.getMonth()+1)}月${pad(d.getDate())}日 星期${weekdays[d.getDay()]} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}

onMounted(() => {
  updateTime()
  load()
})
</script>

<style scoped>
.welcome-card {
  background: linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%);
  border: none;
  color: #fff;
}
.welcome-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.welcome-title {
  font-size: 22px;
  font-weight: bold;
  margin-bottom: 8px;
}
.welcome-sub {
  font-size: 14px;
  opacity: 0.9;
}
.welcome-sub strong {
  font-size: 18px;
  color: #fbbf24;
}
.welcome-time {
  font-size: 14px;
  opacity: 0.85;
}

.stat-card {
  cursor: pointer;
  transition: all 0.2s;
}
.stat-card:hover {
  transform: translateY(-2px);
}
.stat-card :deep(.el-card__body) {
  display: flex;
  align-items: center;
  padding: 16px;
}
.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  margin-right: 14px;
  flex-shrink: 0;
}
.stat-info {
  flex: 1;
}
.stat-label {
  font-size: 13px;
  color: #909399;
  margin-bottom: 4px;
}
.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
}

.list-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
}
.list-item:last-child {
  border-bottom: none;
}
.item-left {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
  min-width: 0;
}
.item-title {
  font-size: 14px;
  color: #303133;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.item-right {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-shrink: 0;
}
.item-time {
  font-size: 12px;
  color: #909399;
}

.notify-item {
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
}
.notify-item:last-child {
  border-bottom: none;
}
.notify-title {
  font-size: 13px;
  color: #303133;
  margin-bottom: 4px;
  display: flex;
  align-items: center;
}
.notify-content {
  font-size: 12px;
  color: #909399;
  line-height: 1.5;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.quick-links {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}
.quick-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px;
  border-radius: 6px;
  background: #f5f7fa;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 13px;
  color: #606266;
}
.quick-item:hover {
  background: #ecf5ff;
  color: #409eff;
}
</style>