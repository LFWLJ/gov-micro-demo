-- ============================================================
-- 03-index.sql —— 补性能索引（幂等，可重复执行）
--
-- 背景：
--   t_application 现有索引只有 PRIMARY(id)、idx_tenant(tenant_id)、
--   idx_dept(dept_id)、idx_status(status)。
--   但大屏 / 报表 / dashboard 的查询形态是
--       WHERE tenant_id = ? AND create_time BETWEEN ? AND ?
--   ORDER BY create_time DESC
--   单列 idx_tenant 的区分度极低（本 demo 只有 tenant_a/tenant_b），
--   优化器往往直接放弃索引 -> 全表扫 + filesort。
--   补 (tenant_id, create_time) 复合索引后可以完全走索引范围扫描。
--
-- 幂等写法说明：
--   MySQL 8 不支持 `CREATE INDEX IF NOT EXISTS`（那是 MariaDB 的扩展），
--   所以这里用 information_schema.statistics 预检 + PREPARE/EXECUTE 的
--   动态 SQL 方案：先查索引是否存在，不存在才 ALTER TABLE 添加。
--   这样本文件既能被 docker-entrypoint-initdb.d 首次初始化时执行，
--   也能在已有库上手动重放，不会因为 "Duplicate key name" 报错。
--
-- ⚠️ 开头必须 USE gov_db;，否则 mysql 客户端会报 No database selected
--    （02-perms.sql 也是同样写法）。
-- ============================================================

USE `gov_db`;

-- ------------------------------------------------------------
-- 1. t_application (tenant_id, create_time) 复合索引
-- ------------------------------------------------------------
SET @idx_exists := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 't_application'
    AND index_name   = 'idx_tenant_create_time'
);

SET @ddl := IF(
  @idx_exists = 0,
  'ALTER TABLE `t_application` ADD INDEX `idx_tenant_create_time` (`tenant_id`, `create_time`)',
  'SELECT ''[03-index] idx_tenant_create_time already exists, skip'' AS msg'
);

PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ------------------------------------------------------------
-- 2. t_application_log (tenant_id, create_time) 复合索引
--    事项流转日志同样按「租户 + 时间范围」翻页查询。
--    注意：不同环境该表结构可能不一致（比如没有 tenant_id），
--    因此这里先判断列是否存在，再决定是否建索引。
-- ------------------------------------------------------------
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name   = 't_application_log'
    AND column_name  = 'tenant_id'
);

SET @idx_exists := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name   = 't_application_log'
    AND index_name   = 'idx_tenant_create_time'
);

SET @ddl := IF(
  @col_exists = 0,
  'SELECT ''[03-index] t_application_log has no tenant_id column, skip'' AS msg',
  IF(
    @idx_exists = 0,
    'ALTER TABLE `t_application_log` ADD INDEX `idx_tenant_create_time` (`tenant_id`, `create_time`)',
    'SELECT ''[03-index] t_application_log.idx_tenant_create_time already exists, skip'' AS msg'
  )
);

PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ------------------------------------------------------------
-- 3. 收尾：打印最终索引，便于人工确认
-- ------------------------------------------------------------
SELECT table_name, index_name,
       GROUP_CONCAT(column_name ORDER BY seq_in_index) AS columns_in_order
FROM information_schema.statistics
WHERE table_schema = DATABASE()
  AND table_name IN ('t_application', 't_application_log')
GROUP BY table_name, index_name
ORDER BY table_name, index_name;
