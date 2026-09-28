# 贡献指南

## 分支策略

- `main` —— 稳定分支，随时可部署
- `dev` —— 开发分支，日常提交
- `feature/xxx` —— 功能分支，从 dev 切出

## 提交规范

使用 [Conventional Commits](https://www.conventionalcommits.org/)：

<type>(<scope>): <subject>

text

**type 类型**：

| 类型 | 说明 |
|---|---|
| feat | 新功能 |
| fix | 修复 bug |
| docs | 文档 |
| style | 格式（不影响代码运行） |
| refactor | 重构 |
| perf | 性能优化 |
| test | 测试 |
| chore | 构建/工具 |

**示例**：
feat(role): 新增角色分配用户功能
fix(auth): 修复登录时租户上下文丢失
docs(readme): 更新 Docker 部署说明

text

## 代码规范

### 后端
- 统一响应体 `R<T>`
- 业务异常抛 `BizException`
- `@RequestParam` / `@PathVariable` 显式指定参数名
- 新表没有 `tenant_id` 列时，需在 `TenantLineHandlerImpl.IGNORE_TABLES` 登记

### 前端
- API 放 `src/api/`，请求走 `request.js`
- 按钮权限用 `v-perm="'sys:xxx:yyy'"`
- 页面放 `src/views/`

## Pull Request 流程

1. Fork 本仓库
2. 从 `dev` 切出 `feature/xxx` 分支
3. 提交代码（遵循提交规范）
4. 提 PR 到 `dev` 分支
5. 等待 Review