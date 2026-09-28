# 政务管理系统（gov-micro-demo）
![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.4-brightgreen)
![Vue](https://img.shields.io/badge/Vue-3.4-42b883)
![License](https://img.shields.io/badge/license-MIT-blue)

基于 Spring Cloud Alibaba + Vue 3 的政务管理系统微服务架构，覆盖事项办理、审批流程、电子证照、好差评、咨询投诉、文件管理等政务核心场景。

## 一、技术栈

**后端**：JDK 17 · Spring Boot 3.2.4 · Spring Cloud 2023.0.1 · Spring Cloud Alibaba 2023.0.1.0 · MyBatis-Plus 3.5.5 · Flowable 7.0.1 · JJWT 0.12.5 · Knife4j 4.6.0

**前端**：Vue 3.4 · Vite 8 · Element Plus 2.7 · Pinia 2 · Vue Router 4 · Axios 1 · ECharts 5

**中间件**：MySQL 8.0 · Redis 7 · Nacos 3.2.4 · MinIO · RocketMQ 5.3.1

## 二、系统架构
浏览器 (Vue 3 SPA)
│ /api/**
▼
gov-gateway (8090) ── JWT 鉴权 + Token 黑名单 + 路由转发 + 租户注入
│
├── gov-auth (8081) 认证中心：登录、用户、租户
├── gov-application (8082) 业务服务：事项、流程、角色、菜单
└── gov-file (8083) 文件服务：上传、下载、附件关联
│
├── MySQL (3306) Redis (6379) MinIO (9000)
├── Nacos (8848) RocketMQ (9876)

text

## 三、功能模块

### 系统管理
用户管理 · 部门管理 · 角色管理 · 菜单管理 · 租户管理 · 数据字典 · 系统配置 · 敏感词管理 · 操作日志 · 登录日志

### 业务功能
事项管理 · 审批流程 · 办事指南 · 预约取号 · 好差评 · 电子证照 · 咨询投诉 · 文件管理 · 消息中心 · 统计报表 · 数据大屏

### 系统能力
- **动态路由**：登录后按角色动态生成路由，菜单改动无需重新发布前端
- **按钮权限**：`v-perm` 指令控制按钮显隐
- **接口权限**：`@RequiresPerm` 注解 + AOP 校验
- **多租户**：MyBatis-Plus 拦截器自动加 `WHERE tenant_id = ?`
- **数据权限**：部门级数据范围（全部 / 本部门及以下 / 本部门 / 仅本人）
- **Token 黑名单**：Redis 记录登出后的 token

## 四、快速开始

### 方式一：Docker Compose 一键启动（推荐）

**前置要求**：Docker Desktop 已启动，至少 8GB 内存。

```bash
# 1. 打包后端（首次必做）
mvn clean package -DskipTests

# 2. 启动全部服务
docker compose up -d --build

# 3. 等 2-3 分钟，查看状态
docker compose ps
访问地址：

服务	地址
前端	http://localhost
Nacos	http://localhost:8080/nacos
MinIO	http://localhost:9001
网关	http://localhost:8090
默认账号：admin / 123456 / tenant_a

注意事项：

MinIO 镜像：官方 minio/minio 已下架，本项目用 pgsty/silo（兼容 fork）

Nacos 健康检查：3.x 端点为 /nacos/v3/admin/core/state/readiness

镜像拉取超时：Docker Desktop → Settings → Docker Engine 配置 registry-mirrors

方式二：本地开发
前置要求：本地已启动 MySQL、Redis、Nacos、MinIO、RocketMQ。

bash
# 1. 初始化数据库
mysql -uroot -p < sql/init.sql
mysql -uroot -p < sql/role_menu.sql

# 2. IDEA 里依次启动 4 个服务
gov-gateway (8090) → gov-auth (8081) → gov-application (8082) → gov-file (8083)

# 3. 启动前端
cd gov-admin-web
npm install
npm run dev
# 访问 http://localhost:5173
五、项目结构
text
gov-micro-demo/
├── docker/                      # Docker 相关配置
├── gov-admin-web/               # 前端
│   ├── src/api/                 # 接口封装
│   ├── src/components/          # 通用组件
│   ├── src/directives/          # v-perm 指令
│   ├── src/router/              # 路由（动态路由）
│   ├── src/stores/              # Pinia 状态
│   └── src/views/               # 页面
├── gov-api/                     # Feign 接口契约
├── gov-application/             # 业务服务
├── gov-auth/                    # 认证中心
├── gov-common/                  # 公共模块
│   ├── exception/               # 全局异常
│   ├── log/                     # 操作日志
│   ├── mybatis/                 # 多租户拦截器
│   ├── perm/                    # 权限注解 + 切面
│   └── tenant/                  # 租户上下文
├── gov-file/                    # 文件服务
├── gov-gateway/                 # 网关
├── sql/                         # SQL 脚本
├── docker-compose.yml
├── Dockerfile                   # 后端通用 Dockerfile
└── README.md
六、账号信息
默认用户（密码统一 123456）：

用户名	租户	角色	数据范围
admin	tenant_a	ROLE_ADMIN	全部
dept_leader	tenant_a	ROLE_ADMIN	本部门及以下
clerk	tenant_a	ROLE_USER	本部门
user	tenant_a	ROLE_USER	本部门
gov_b_admin	tenant_b	ROLE_ADMIN	全部
中间件密码：

服务	用户名	密码
MySQL	root	root123
Nacos	nacos	7PkhQ0b92nUU
MinIO	minioadmin	minioadmin
七、常用运维命令
bash
# 状态 / 启动 / 停止
docker compose ps
docker compose up -d
docker compose down              # 停容器，保留数据
docker compose down -v           # ⚠️ 危险：同时删数据卷

# 看日志
docker compose logs -f gov-auth
docker compose logs gov-application --tail 100

# 改代码后重建某服务
mvn -pl gov-auth -am package -DskipTests
docker compose up -d --build gov-auth

# 全部重建
mvn clean package -DskipTests
docker compose up -d --build

# 进容器
docker exec -it gov-mysql mysql -uroot -proot123
docker exec -it gov-auth sh
数据持久化：所有数据存在 Docker volume 中（mysql-data、redis-data、minio-data、rocketmq-broker-store）。docker compose down 不删 volume，down -v 才删。

MySQL 初始化 SQL 只在首次执行。要重新初始化：

bash
docker compose down
docker volume rm gov-micro-demo_mysql-data
docker compose up -d
八、接口文档
启动后访问 Knife4j：

服务	地址
网关聚合	http://localhost:8090/doc.html
认证中心	http://localhost:8081/doc.html
业务服务	http://localhost:8082/doc.html
文件服务	http://localhost:8083/doc.html
九、License
MIT

text

---

## 章节结构

| # | 章节 | 内容 |
|---|---|---|
| 1 | 技术栈 | 一行列出，去掉表格 |
| 2 | 系统架构 | ASCII 图简化 |
| 3 | 功能模块 | 分 3 类，紧凑 |
| 4 | 快速开始 | Docker + 本地两套 |
| 5 | 项目结构 | 树形，精简 |
| 6 | 账号信息 | 2 张表 |
| 7 | 常用运维命令 | 全部命令 |
| 8 | 接口文档 | Knife4j 地址 |
| 9 | License | MIT |


