-- ============================================================
-- 业务模块按钮级权限种子
-- ------------------------------------------------------------
-- 背景：sys_menu 里原本只有 sys:* 共 19 个按钮权限，业务模块
--       一个都没有。而 @RequiresPerm 的校验逻辑是
--       「从当前用户的角色菜单里取 menu_type='F' 的 perms」，
--       所以新增权限注解必须同步补上这里的数据，否则管理员
--       也会被判成无权限。
--
-- 本文件被 docker-compose 挂载到 /docker-entrypoint-initdb.d，
-- 首次初始化时会在 01-init.sql 之后执行；对已存在的库，
-- 直接手动执行本文件即可（语句幂等）。
--
-- 角色：1 = tenant_a 管理员, 2 = tenant_a 普通用户, 3 = tenant_b 管理员
-- ============================================================

USE `gov_db`;

-- ---------- 1. 新增按钮权限（id 500+，避开既有 401-444）----------
INSERT IGNORE INTO `sys_menu`
(`id`,`parent_id`,`menu_name`,`menu_type`,`path`,`component`,`perms`,`icon`,`order_num`,`visible`,`status`,`create_time`) VALUES
-- 电子证照（父菜单 13）
(501,13,'证照生成','F',NULL,NULL,'biz:license:issue',NULL,1,1,1,NOW()),
(502,13,'证照吊销','F',NULL,NULL,'biz:license:revoke',NULL,2,1,1,NOW()),
-- 事项管理（父菜单 10）
(503,10,'事项创建','F',NULL,NULL,'biz:application:add',NULL,1,1,1,NOW()),
(504,10,'事项审批','F',NULL,NULL,'biz:application:approve',NULL,2,1,1,NOW()),
-- 审批流程（父菜单 11）
(505,11,'发起流程','F',NULL,NULL,'biz:process:start',NULL,1,1,1,NOW()),
(506,11,'完成审批','F',NULL,NULL,'biz:process:complete',NULL,2,1,1,NOW()),
-- 办事指南（父菜单 14）
(507,14,'指南新增','F',NULL,NULL,'biz:guide:add',NULL,1,1,1,NOW()),
(508,14,'指南修改','F',NULL,NULL,'biz:guide:edit',NULL,2,1,1,NOW()),
(509,14,'指南删除','F',NULL,NULL,'biz:guide:del',NULL,3,1,1,NOW()),
-- 咨询投诉（父菜单 21）
(510,21,'工单回复','F',NULL,NULL,'biz:consult:reply',NULL,1,1,1,NOW()),
(511,21,'工单关闭','F',NULL,NULL,'biz:consult:close',NULL,2,1,1,NOW()),
(512,21,'工单删除','F',NULL,NULL,'biz:consult:del',NULL,3,1,1,NOW()),
-- 好差评（父菜单 20）
(513,20,'差评整改','F',NULL,NULL,'biz:evaluation:rectify',NULL,1,1,1,NOW()),
-- 文件管理（父菜单 6）
(514,6,'附件关联','F',NULL,NULL,'biz:attachment:add',NULL,1,1,1,NOW()),
(515,6,'附件删除','F',NULL,NULL,'biz:attachment:del',NULL,2,1,1,NOW()),
-- 部门管理（父菜单 41）
(516,41,'部门新增','F',NULL,NULL,'sys:dept:add',NULL,1,1,1,NOW()),
(517,41,'部门修改','F',NULL,NULL,'sys:dept:edit',NULL,2,1,1,NOW()),
(518,41,'部门删除','F',NULL,NULL,'sys:dept:del',NULL,3,1,1,NOW()),
-- 数据字典（父菜单 44）
(519,44,'字典新增','F',NULL,NULL,'sys:dict:add',NULL,1,1,1,NOW()),
(520,44,'字典修改','F',NULL,NULL,'sys:dict:edit',NULL,2,1,1,NOW()),
(521,44,'字典删除','F',NULL,NULL,'sys:dict:del',NULL,3,1,1,NOW()),
-- 系统配置（父菜单 45）
(522,45,'配置新增','F',NULL,NULL,'sys:config:add',NULL,1,1,1,NOW()),
(523,45,'配置修改','F',NULL,NULL,'sys:config:edit',NULL,2,1,1,NOW()),
(524,45,'配置删除','F',NULL,NULL,'sys:config:del',NULL,3,1,1,NOW());

-- ---------- 2. 管理员角色：授予全部新增权限 ----------
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`)
SELECT r.id, m.id FROM `sys_role` r
JOIN `sys_menu` m ON m.id BETWEEN 501 AND 524
WHERE r.role_key = 'ROLE_ADMIN';

-- ---------- 3. 普通用户角色：仅授予日常经办权限 ----------
-- 不含：证照签发/吊销、审批完成、部门/字典/系统配置的维护
INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`) VALUES
(2,503),  -- 事项创建
(2,507),(2,508),  -- 指南新增/修改
(2,510),(2,511),  -- 工单回复/关闭
(2,513),  -- 差评整改
(2,514),(2,515);  -- 附件关联/删除
