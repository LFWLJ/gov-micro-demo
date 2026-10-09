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
Nacos 控制台	http://localhost:8080/
MinIO	http://localhost:9001
网关（仅 API，浏览器打开根路径会 404）	http://localhost:8090
默认账号：admin / 123456 / tenant_a

注意事项：

Nacos 3.x 的控制台在 **8080 端口的根路径 `/`**（`http://localhost:8080/nacos` 会返回 500）；
8848 是服务端 API 端口，访问 `/nacos` 只会看到一句“Console default port is 8080”的提示。

网关是纯 API 网关，只转发 `/api/**`，**没有网页界面**：
用浏览器打开 `http://localhost:8090/` 必然 404，这是正常的，不是服务没起来。
验证网关是否正常请用接口，例如：

```bash
curl -X POST http://localhost:8090/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}'
```

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
中间件密码：全部通过 `.env` 注入，仓库内不提供任何默认口令/密钥。

| 变量 | 用途 |
|---|---|
| `MYSQL_ROOT_PASSWORD` | MySQL root |
| `NACOS_PASSWORD` | Nacos 控制台与客户端 |
| `MINIO_ROOT_USER` / `MINIO_ROOT_PASSWORD` | MinIO |
| `REDIS_PASSWORD` | Redis（已启用 requirepass，**不可为空**）|
| `GOV_JWT_SECRET` | JWT 签名密钥 |

> 首次使用：`cp .env.example .env`，把其中所有 `change_me_*` 换成随机值。
> 各服务配置里的默认值已清空，缺少环境变量会**启动即失败**，不会再静默使用弱口令。
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
认证中心	http://localhost:8081/doc.html
业务服务	http://localhost:8082/doc.html
文件服务	http://localhost:8083/doc.html

> 网关未做 Knife4j 聚合，`http://localhost:8090/doc.html` 是 404；请直接访问上面各服务的文档。

### 在文档页调试接口（务必先读）

各服务**不解析 JWT**，只信任网关注入的 `X-User-Id` / `X-Tenant-Id` 请求头
（"服务端不信任客户端身份"是刻意设计）。因此：

1. **文档里的接口必须经网关调用**。三个服务的 OpenAPI 已声明 `servers: http://localhost:8090`，
   文档页的「调试」会自动把请求发往网关——**前提是网关容器（gov-gateway）在运行**。
2. 调试步骤：
   - 打开 `http://localhost:8081/doc.html`，调 `POST /api/auth/login`（白名单，无需 token）拿到 token
   - 点右上角 **Authorize**，把 token 填进 `BearerAuth`（**只填 token 本身**，不要带 `Bearer `，
     否则会变成 `Bearer Bearer xxx`）
   - 之后调其它接口即可
3. Token 写法：`Authorization` 的值填**裸 token 或 `Bearer <token>` 都可以**（网关与服务端都兼容）；
   填成 `Basic xxx` 之类的其它 scheme 会被拒。
4. 文档页的请求发往哪里都能用：
   - 各服务 OpenAPI 已声明 `servers = http://localhost:8090`（网关）；
   - 同时服务端有兜底 `JwtIdentityFilter`：**即使调试请求直连 8081/8082/8083**，
     只要 `Authorization` 里带的是**签名有效的 JWT**，服务会自行解析出身份。
   - 因此"填了 token 就能调"。若填了仍返回 `未登录`，说明 token 无效 / 过期 / 已登出。
   - **不带 token 直连服务端口仍会被拒**（符合预期）。
5. 服务端兜底开关：`gov.auth.jwt-fallback-enabled`（默认 `true`）。
   生产环境若只允许经网关访问、不发布服务端口，可设为 `false`。
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


