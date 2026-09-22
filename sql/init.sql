-- ============================================================
-- 政务管理系统 - 数据库完整初始化脚本
-- 数据库：gov_db
-- 字符集：utf8mb4
-- 说明：Flowable 的 ACT_* 表由应用启动时自动创建，不在本脚本中
-- 可重复执行（先 DROP 再 CREATE）
-- 日期字段用 CURDATE()/NOW() 动态生成
-- ============================================================

CREATE DATABASE IF NOT EXISTS gov_db
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;

USE gov_db;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 一、权限模块
-- ============================================================

DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
                          id          BIGINT       PRIMARY KEY AUTO_INCREMENT,
                          username    VARCHAR(64)  NOT NULL UNIQUE    COMMENT '用户名',
                          password    VARCHAR(128) NOT NULL           COMMENT '密码（生产建议 BCrypt）',
                          real_name   VARCHAR(64)                     COMMENT '真实姓名',
                          tenant_id   VARCHAR(64)  NOT NULL           COMMENT '租户ID',
                          roles       VARCHAR(256) NOT NULL           COMMENT '角色，逗号分隔',
                          dept_id     BIGINT                          COMMENT '部门ID',
                          data_scope  TINYINT      DEFAULT 3          COMMENT '数据范围: 1全部 2本部门及以下 3本部门 4仅本人',
                          status      TINYINT      DEFAULT 1          COMMENT '1启用 0禁用',
                          create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
                          update_time DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                          INDEX idx_tenant (tenant_id),
                          INDEX idx_dept (dept_id)
) COMMENT '系统用户表';

DROP TABLE IF EXISTS sys_dept;
CREATE TABLE sys_dept (
                          id          BIGINT       PRIMARY KEY AUTO_INCREMENT,
                          tenant_id   VARCHAR(64)  NOT NULL,
                          parent_id   BIGINT       DEFAULT 0          COMMENT '上级部门ID',
                          dept_name   VARCHAR(64)  NOT NULL,
                          order_num   INT          DEFAULT 0,
                          status      TINYINT      DEFAULT 1,
                          create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
                          INDEX idx_tenant (tenant_id),
                          INDEX idx_parent (parent_id)
) COMMENT '部门表';

-- ============================================================
-- 二、事项模块
-- ============================================================

DROP TABLE IF EXISTS t_application;
CREATE TABLE t_application (
                               id                  BIGINT       PRIMARY KEY AUTO_INCREMENT,
                               tenant_id           VARCHAR(64)  NOT NULL,
                               dept_id             BIGINT                        COMMENT '创建部门ID',
                               create_by           VARCHAR(64)                   COMMENT '创建人ID',
                               title               VARCHAR(256) NOT NULL,
                               applicant           VARCHAR(64),
                               status              VARCHAR(32)  DEFAULT 'DRAFT'  COMMENT 'DRAFT/PENDING/APPROVED/REJECTED',
                               process_instance_id VARCHAR(64)                   COMMENT 'Flowable 流程实例ID',
                               create_time         DATETIME     DEFAULT CURRENT_TIMESTAMP,
                               INDEX idx_tenant (tenant_id),
                               INDEX idx_dept (dept_id),
                               INDEX idx_status (status)
) COMMENT '事项表';

DROP TABLE IF EXISTS t_application_log;
CREATE TABLE t_application_log (
                                   id             BIGINT       PRIMARY KEY AUTO_INCREMENT,
                                   tenant_id      VARCHAR(64)  NOT NULL,
                                   application_id BIGINT       NOT NULL,
                                   action         VARCHAR(32)  NOT NULL  COMMENT 'SUBMIT/APPROVE/REJECT/WITHDRAW/ARCHIVE',
                                   action_name    VARCHAR(64)            COMMENT '动作中文名',
                                   operator       VARCHAR(64)            COMMENT '操作人',
                                   remark         VARCHAR(500),
                                   create_time    DATETIME     DEFAULT CURRENT_TIMESTAMP,
                                   INDEX idx_app (application_id),
                                   INDEX idx_tenant (tenant_id)
) COMMENT '办件流转日志表';

-- ============================================================
-- 三、好差评模块
-- ============================================================

DROP TABLE IF EXISTS t_evaluation;
CREATE TABLE t_evaluation (
                              id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
                              tenant_id       VARCHAR(64)  NOT NULL,
                              application_id  BIGINT,
                              business_key    VARCHAR(128),
                              evaluator       VARCHAR(64),
                              evaluator_phone VARCHAR(20),
                              score           TINYINT      NOT NULL  COMMENT '1~5',
                              content         VARCHAR(500),
                              channel         VARCHAR(32)  DEFAULT 'ONLINE'  COMMENT 'ONLINE/APP/WINDOW/PHONE',
                              is_bad          TINYINT      DEFAULT 0,
                              rectify_status  VARCHAR(32)  DEFAULT 'NONE'    COMMENT 'NONE/PENDING/DONE',
                              create_time     DATETIME     DEFAULT CURRENT_TIMESTAMP,
                              INDEX idx_tenant (tenant_id),
                              INDEX idx_app (application_id),
                              INDEX idx_bad (is_bad, rectify_status)
) COMMENT '好差评评价表';

DROP TABLE IF EXISTS t_evaluation_rectify;
CREATE TABLE t_evaluation_rectify (
                                      id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
                                      tenant_id       VARCHAR(64)  NOT NULL,
                                      evaluation_id   BIGINT       NOT NULL,
                                      rectifier       VARCHAR(64),
                                      rectify_content VARCHAR(1000),
                                      rectify_time    DATETIME,
                                      status          VARCHAR(32)  DEFAULT 'PENDING'  COMMENT 'PENDING/DONE',
                                      create_time     DATETIME     DEFAULT CURRENT_TIMESTAMP,
                                      INDEX idx_eval (evaluation_id),
                                      INDEX idx_tenant (tenant_id)
) COMMENT '差评整改表';

-- ============================================================
-- 四、电子证照模块
-- ============================================================

DROP TABLE IF EXISTS t_license_template;
CREATE TABLE t_license_template (
                                    id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
                                    tenant_id     VARCHAR(64)  NOT NULL,
                                    template_code VARCHAR(64)  NOT NULL,
                                    template_name VARCHAR(128) NOT NULL,
                                    license_type  VARCHAR(64),
                                    fields_json   TEXT,
                                    status        TINYINT      DEFAULT 1,
                                    create_time   DATETIME     DEFAULT CURRENT_TIMESTAMP,
                                    UNIQUE KEY uk_tenant_code (tenant_id, template_code)
) COMMENT '证照模板表';

DROP TABLE IF EXISTS t_license;
CREATE TABLE t_license (
                           id             BIGINT       PRIMARY KEY AUTO_INCREMENT,
                           tenant_id      VARCHAR(64)  NOT NULL,
                           license_no     VARCHAR(64)  NOT NULL,
                           template_code  VARCHAR(64)  NOT NULL,
                           holder_name    VARCHAR(64),
                           holder_id_card VARCHAR(32),
                           issue_dept     VARCHAR(128),
                           issue_date     DATE,
                           expire_date    DATE,
                           content_json   TEXT,
                           file_url       VARCHAR(512),
                           verify_code    VARCHAR(64),
                           status         VARCHAR(32)  DEFAULT 'VALID'  COMMENT 'VALID/REVOKED/EXPIRED',
                           create_time    DATETIME     DEFAULT CURRENT_TIMESTAMP,
                           UNIQUE KEY uk_license_no (license_no),
                           UNIQUE KEY uk_verify_code (verify_code),
                           INDEX idx_tenant (tenant_id),
                           INDEX idx_holder (holder_name)
) COMMENT '电子证照表';

-- ============================================================
-- 五、政务服务模块
-- ============================================================

DROP TABLE IF EXISTS t_guide;
CREATE TABLE t_guide (
                         id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
                         tenant_id       VARCHAR(64)  NOT NULL,
                         guide_code      VARCHAR(64)  NOT NULL,
                         title           VARCHAR(256) NOT NULL,
                         category        VARCHAR(64),
                         dept_id         BIGINT,
                         service_object  VARCHAR(256),
                         legal_basis     TEXT,
                         conditions      TEXT,
                         materials       TEXT,
                         process_desc    TEXT,
                         legal_days      INT,
                         promise_days    INT,
                         charge_standard VARCHAR(256),
                         consult_phone   VARCHAR(64),
                         online_url      VARCHAR(512),
                         status          TINYINT      DEFAULT 1,
                         create_time     DATETIME     DEFAULT CURRENT_TIMESTAMP,
                         update_time     DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                         UNIQUE KEY uk_code (tenant_id, guide_code),
                         INDEX idx_tenant (tenant_id),
                         INDEX idx_dept (dept_id),
                         INDEX idx_category (category)
) COMMENT '办事指南表';

DROP TABLE IF EXISTS t_appointment;
CREATE TABLE t_appointment (
                               id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
                               tenant_id       VARCHAR(64)  NOT NULL,
                               appointment_no  VARCHAR(64)  NOT NULL,
                               guide_code      VARCHAR(64),
                               guide_title     VARCHAR(256),
                               visitor_name    VARCHAR(64)  NOT NULL,
                               visitor_phone   VARCHAR(20)  NOT NULL,
                               visitor_id_card VARCHAR(32),
                               dept_id         BIGINT,
                               appoint_date    DATE         NOT NULL,
                               time_slot       VARCHAR(32),
                               queue_no        VARCHAR(16),
                               status          VARCHAR(32)  DEFAULT 'BOOKED'  COMMENT 'BOOKED/CHECKED/DONE/CANCELLED/EXPIRED',
                               checkin_time    DATETIME,
                               finish_time     DATETIME,
                               cancel_reason   VARCHAR(256),
                               remark          VARCHAR(500),
                               create_time     DATETIME     DEFAULT CURRENT_TIMESTAMP,
                               UNIQUE KEY uk_appointment_no (appointment_no),
                               INDEX idx_tenant_date (tenant_id, appoint_date),
                               INDEX idx_status (status),
                               INDEX idx_visitor_phone (visitor_phone)
) COMMENT '预约取号表';

DROP TABLE IF EXISTS t_consult;
CREATE TABLE t_consult (
                           id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
                           tenant_id     VARCHAR(64)  NOT NULL,
                           consult_no    VARCHAR(64)  NOT NULL,
                           type          VARCHAR(32)  NOT NULL  COMMENT 'CONSULT/COMPLAINT/SUGGEST',
                           title         VARCHAR(256) NOT NULL,
                           content       TEXT         NOT NULL,
                           contact_name  VARCHAR(64),
                           contact_phone VARCHAR(20),
                           dept_id       BIGINT,
                           handler       VARCHAR(64),
                           reply         TEXT,
                           reply_time    DATETIME,
                           status        VARCHAR(32)  DEFAULT 'PENDING'  COMMENT 'PENDING/PROCESSING/DONE/CLOSED',
                           create_time   DATETIME     DEFAULT CURRENT_TIMESTAMP,
                           UNIQUE KEY uk_consult_no (consult_no),
                           INDEX idx_tenant (tenant_id),
                           INDEX idx_status (status)
) COMMENT '咨询投诉表';

-- ============================================================
-- 六、文件模块
-- ============================================================

DROP TABLE IF EXISTS t_file;
CREATE TABLE t_file (
                        id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
                        file_id       VARCHAR(64)  NOT NULL,
                        tenant_id     VARCHAR(64)  NOT NULL,
                        user_id       VARCHAR(64),
                        original_name VARCHAR(256),
                        object_name   VARCHAR(512) NOT NULL  COMMENT 'MinIO 对象路径',
                        content_type  VARCHAR(128),
                        size          BIGINT,
                        create_time   DATETIME     DEFAULT CURRENT_TIMESTAMP,
                        UNIQUE KEY uk_file_id (file_id),
                        INDEX idx_tenant (tenant_id),
                        INDEX idx_user (user_id)
) COMMENT '文件信息表';

DROP TABLE IF EXISTS t_attachment;
CREATE TABLE t_attachment (
                              id          BIGINT       PRIMARY KEY AUTO_INCREMENT,
                              tenant_id   VARCHAR(64)  NOT NULL,
                              biz_type    VARCHAR(32)  NOT NULL  COMMENT 'APPLICATION/GUIDE/EVALUATION',
                              biz_id      BIGINT       NOT NULL,
                              file_id     VARCHAR(64)  NOT NULL,
                              file_name   VARCHAR(256),
                              create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
                              INDEX idx_biz (biz_type, biz_id),
                              INDEX idx_tenant (tenant_id)
) COMMENT '业务附件关联表';

-- ============================================================
-- 七、系统模块
-- ============================================================

DROP TABLE IF EXISTS sys_dict;
CREATE TABLE sys_dict (
                          id          BIGINT       PRIMARY KEY AUTO_INCREMENT,
                          tenant_id   VARCHAR(64)  NOT NULL,
                          dict_type   VARCHAR(64)  NOT NULL,
                          dict_label  VARCHAR(64)  NOT NULL,
                          dict_value  VARCHAR(64)  NOT NULL,
                          sort        INT          DEFAULT 0,
                          status      TINYINT      DEFAULT 1,
                          create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
                          UNIQUE KEY uk_type_value (tenant_id, dict_type, dict_value),
                          INDEX idx_type (tenant_id, dict_type)
) COMMENT '数据字典表';

DROP TABLE IF EXISTS sys_dict_type;
CREATE TABLE sys_dict_type (
                               id          BIGINT       PRIMARY KEY AUTO_INCREMENT,
                               tenant_id   VARCHAR(64)  NOT NULL,
                               dict_type   VARCHAR(64)  NOT NULL  COMMENT '类型编码',
                               dict_name   VARCHAR(64)  NOT NULL  COMMENT '类型中文名',
                               remark      VARCHAR(256),
                               create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
                               UNIQUE KEY uk_type (tenant_id, dict_type)
) COMMENT '字典类型表';

DROP TABLE IF EXISTS sys_config;
CREATE TABLE sys_config (
                            id           BIGINT       PRIMARY KEY AUTO_INCREMENT,
                            tenant_id    VARCHAR(64)  NOT NULL,
                            config_name  VARCHAR(128)                COMMENT '配置中文名',
                            config_key   VARCHAR(128) NOT NULL,
                            config_value VARCHAR(512),
                            remark       VARCHAR(256),
                            create_time  DATETIME     DEFAULT CURRENT_TIMESTAMP,
                            UNIQUE KEY uk_key (tenant_id, config_key)
) COMMENT '系统配置表';

DROP TABLE IF EXISTS sys_oper_log;
CREATE TABLE sys_oper_log (
                              id          BIGINT       PRIMARY KEY AUTO_INCREMENT,
                              tenant_id   VARCHAR(64),
                              user_id     VARCHAR(64),
                              module      VARCHAR(64),
                              operation   VARCHAR(128),
                              method      VARCHAR(16),
                              uri         VARCHAR(256),
                              params      TEXT,
                              result      TINYINT      DEFAULT 1,
                              error_msg   TEXT,
                              cost_ms     BIGINT,
                              ip          VARCHAR(64),
                              create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
                              INDEX idx_tenant_time (tenant_id, create_time),
                              INDEX idx_user (user_id),
                              INDEX idx_result (result)
) COMMENT '操作日志表';

DROP TABLE IF EXISTS sys_login_log;
CREATE TABLE sys_login_log (
                               id         BIGINT       PRIMARY KEY AUTO_INCREMENT,
                               tenant_id  VARCHAR(64),
                               username   VARCHAR(64),
                               ip         VARCHAR(64),
                               location   VARCHAR(128),
                               browser    VARCHAR(128),
                               os         VARCHAR(64),
                               status     TINYINT      DEFAULT 1  COMMENT '1成功 0失败',
                               msg        VARCHAR(256),
                               login_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
                               INDEX idx_tenant_time (tenant_id, login_time),
                               INDEX idx_username (username)
) COMMENT '登录日志表';

DROP TABLE IF EXISTS sys_sensitive_word;
CREATE TABLE sys_sensitive_word (
                                    id          BIGINT       PRIMARY KEY AUTO_INCREMENT,
                                    tenant_id   VARCHAR(64),
                                    word        VARCHAR(64)  NOT NULL,
                                    category    VARCHAR(32),
                                    create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
                                    UNIQUE KEY uk_tenant_word (tenant_id, word)
) COMMENT '敏感词表';

DROP TABLE IF EXISTS t_notify;
CREATE TABLE t_notify (
                          id          BIGINT       PRIMARY KEY AUTO_INCREMENT,
                          tenant_id   VARCHAR(64)  NOT NULL              COMMENT '租户ID',
                          receiver    VARCHAR(64)  NOT NULL              COMMENT '接收人',
                          title       VARCHAR(128) NOT NULL              COMMENT '标题',
                          content     VARCHAR(500)                       COMMENT '内容',
                          type        VARCHAR(32)                        COMMENT 'TASK/EVALUATION/SYSTEM',
                          biz_id      BIGINT                             COMMENT '关联业务ID',
                          is_read     TINYINT      DEFAULT 0             COMMENT '0未读 1已读',
                          read_time   DATETIME,
                          create_time DATETIME     DEFAULT CURRENT_TIMESTAMP,
                          INDEX idx_receiver (tenant_id, receiver, is_read)
) COMMENT '消息通知表';

DROP TABLE IF EXISTS sys_job;
CREATE TABLE sys_job (
                         id             BIGINT       PRIMARY KEY AUTO_INCREMENT,
                         tenant_id      VARCHAR(64),
                         job_name       VARCHAR(128) NOT NULL,
                         job_group      VARCHAR(64)  DEFAULT 'DEFAULT',
                         invoke_target  VARCHAR(256) NOT NULL,
                         cron           VARCHAR(64)  NOT NULL,
                         misfire_policy VARCHAR(16)  DEFAULT '3',
                         status         TINYINT      DEFAULT 1,
                         remark         VARCHAR(256),
                         create_time    DATETIME     DEFAULT CURRENT_TIMESTAMP
) COMMENT '定时任务表';

DROP TABLE IF EXISTS sys_job_log;
CREATE TABLE sys_job_log (
                             id             BIGINT       PRIMARY KEY AUTO_INCREMENT,
                             job_id         BIGINT       NOT NULL,
                             job_name       VARCHAR(128),
                             invoke_target  VARCHAR(256),
                             job_message    TEXT,
                             status         TINYINT      DEFAULT 1,
                             exception_info TEXT,
                             cost_time      BIGINT,
                             create_time    DATETIME     DEFAULT CURRENT_TIMESTAMP,
                             INDEX idx_job (job_id)
) COMMENT '定时任务日志表';

-- ============================================================
-- 八、分布式事务
-- ============================================================

DROP TABLE IF EXISTS undo_log;
CREATE TABLE undo_log (
                          branch_id     BIGINT       NOT NULL,
                          xid           VARCHAR(128) NOT NULL,
                          context       VARCHAR(128) NOT NULL,
                          rollback_info LONGBLOB     NOT NULL,
                          log_status    INT          NOT NULL,
                          log_created   DATETIME(6)  NOT NULL,
                          log_modified  DATETIME(6)  NOT NULL,
                          UNIQUE KEY ux_undo_log (xid, branch_id)
) COMMENT 'Seata AT 模式回滚表';

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 初始化数据
-- ============================================================

-- -------------------- 部门（A市） --------------------
INSERT INTO sys_dept (tenant_id, parent_id, dept_name, order_num, status) VALUES
                                                                              ('tenant_a', 0, 'A市政府',         1, 1),
                                                                              ('tenant_a', 1, 'A市财政局',       1, 1),
                                                                              ('tenant_a', 1, 'A市民政局',       2, 1),
                                                                              ('tenant_a', 2, 'A市财政局预算科', 1, 1),
                                                                              ('tenant_a', 2, 'A市财政局国库科', 2, 1);

-- -------------------- 部门（B市） --------------------
INSERT INTO sys_dept (tenant_id, parent_id, dept_name, order_num, status) VALUES
    ('tenant_b', 0, 'B市政府', 1, 1);

-- -------------------- 用户（密码均为 123456） --------------------
INSERT INTO sys_user (username, password, real_name, tenant_id, roles, dept_id, data_scope, status) VALUES
                                                                                                        ('admin',       '123456', '市级管理员', 'tenant_a', 'ROLE_ADMIN', 1, 1, 1),
                                                                                                        ('user',        '123456', '普通办事员', 'tenant_a', 'ROLE_USER',  4, 3, 1),
                                                                                                        ('dept_leader', '123456', '财政局局长', 'tenant_a', 'ROLE_ADMIN', 2, 2, 1),
                                                                                                        ('clerk',       '123456', '预算科科员', 'tenant_a', 'ROLE_USER',  4, 3, 1),
                                                                                                        ('gov_b_admin', '123456', 'B市管理员',  'tenant_b', 'ROLE_ADMIN', 6, 1, 1);

-- -------------------- 事项 --------------------
INSERT INTO t_application (tenant_id, dept_id, create_by, title, applicant, status) VALUES
                                                                                        ('tenant_a', 2, '1', 'A市企业注册申请', '张三', 'PENDING'),
                                                                                        ('tenant_a', 2, '1', 'A市营业执照变更', '李四', 'APPROVED'),
                                                                                        ('tenant_a', 2, '1', 'A市税务登记',     '王五', 'DRAFT'),
                                                                                        ('tenant_b', 6, '3', 'B市食品经营许可', '赵六', 'PENDING'),
                                                                                        ('tenant_b', 6, '3', 'B市建设项目审批', '孙七', 'APPROVED');

-- -------------------- 办件流转日志（继承事项） --------------------
INSERT INTO t_application_log (tenant_id, application_id, action, action_name, operator, remark)
SELECT tenant_id, id, 'SUBMIT', '提交申请', '系统初始化', '历史数据初始化'
FROM t_application;

-- -------------------- 好差评评价 --------------------
INSERT INTO t_evaluation
(tenant_id, application_id, business_key, evaluator, score, content, channel, is_bad, rectify_status) VALUES
                                                                                                          ('tenant_a', 1, 'APP-001', '张三', 5, '办理很快，服务态度好', 'ONLINE', 0, 'NONE'),
                                                                                                          ('tenant_a', 2, 'APP-002', '李四', 4, '总体满意',           'APP',    0, 'NONE'),
                                                                                                          ('tenant_a', 3, 'APP-003', '王五', 1, '等待时间太长',       'WINDOW', 1, 'PENDING');

-- -------------------- 证照模板 --------------------
INSERT INTO t_license_template (tenant_id, template_code, template_name, license_type, fields_json, status) VALUES
                                                                                                                ('tenant_a', 'BUSINESS_LICENSE', '营业执照', '企业证照',
                                                                                                                 '["holderName","holderIdCard","issueDept","issueDate","expireDate","content"]', 1),
                                                                                                                ('tenant_a', 'TAX_REGISTER',     '税务登记证', '企业证照',
                                                                                                                 '["holderName","holderIdCard","issueDept","issueDate","content"]', 1),
                                                                                                                ('tenant_a', 'FOOD_PERMIT',      '食品经营许可证', '经营证照',
                                                                                                                 '["holderName","holderIdCard","issueDept","issueDate","expireDate","content"]', 1);

-- -------------------- 办事指南 --------------------
INSERT INTO t_guide
(tenant_id, guide_code, title, category, dept_id, service_object,
 legal_basis, conditions, materials, process_desc,
 legal_days, promise_days, charge_standard, consult_phone, online_url)
VALUES
    ('tenant_a', 'GUIDE-001', '营业执照办理', '企业登记', 2, '企业法人、个体工商户',
     '《中华人民共和国公司法》《市场主体登记管理条例》',
     '1. 有符合规定的名称；2. 有固定的经营场所；3. 有符合规定的经营范围。',
     '1. 申请书；\n2. 法人身份证复印件；\n3. 经营场所证明；\n4. 公司章程。',
     '申请 → 受理 → 审核 → 发证',
     15, 3, '免费', '0571-88880001', 'https://zwfw.gov.cn/business'),

    ('tenant_a', 'GUIDE-002', '税务登记', '税务', 2, '企业法人',
     '《中华人民共和国税收征收管理法》',
     '已取得营业执照，且在法定期限内。',
     '1. 营业执照副本；\n2. 法人身份证；\n3. 银行开户许可证。',
     '受理 → 核实 → 登记 → 发放税务登记证',
     5, 1, '免费', '0571-88880002', 'https://zwfw.gov.cn/tax'),

    ('tenant_a', 'GUIDE-003', '食品经营许可证', '市场监督', 2, '餐饮企业、食品销售企业',
     '《中华人民共和国食品安全法》《食品经营许可管理办法》',
     '1. 有营业执照；2. 有符合要求的经营场所和设备；3. 有食品安全管理制度。',
     '1. 申请书；\n2. 营业执照；\n3. 经营场所平面图；\n4. 从业人员健康证。',
     '申请 → 现场核查 → 审批 → 发证',
     20, 10, '免费', '0571-88880003', 'https://zwfw.gov.cn/food'),

    ('tenant_a', 'GUIDE-004', '建设工程规划许可证', '建设规划', 2, '建设单位',
     '《中华人民共和国城乡规划法》',
     '1. 已取得土地使用权；2. 有符合规划的建设项目。',
     '1. 申请表；\n2. 土地证；\n3. 设计方案；\n4. 环评报告。',
     '申请 → 受理 → 公示 → 审批 → 发证',
     30, 15, '按建筑面积收费', '0571-88880004', 'https://zwfw.gov.cn/construction');

-- -------------------- 预约取号 --------------------
INSERT INTO t_appointment
(tenant_id, appointment_no, guide_code, guide_title,
 visitor_name, visitor_phone, dept_id,
 appoint_date, time_slot, queue_no, status)
VALUES
    ('tenant_a', CONCAT('APT-', DATE_FORMAT(CURDATE(), '%Y%m%d'), '-001'),
     'GUIDE-001', '营业执照办理', '张三', '13800000001', 2,
     CURDATE(), '09:00-10:00', 'A001', 'BOOKED'),
    ('tenant_a', CONCAT('APT-', DATE_FORMAT(CURDATE(), '%Y%m%d'), '-002'),
     'GUIDE-002', '税务登记', '李四', '13800000002', 2,
     CURDATE(), '10:00-11:00', 'A002', 'BOOKED'),
    ('tenant_a', CONCAT('APT-', DATE_FORMAT(CURDATE(), '%Y%m%d'), '-003'),
     'GUIDE-001', '营业执照办理', '王五', '13800000003', 2,
     CURDATE(), '14:00-15:00', 'A003', 'CHECKED');

-- -------------------- 咨询投诉 --------------------
INSERT INTO t_consult
(tenant_id, consult_no, type, title, content, contact_name, contact_phone,
 dept_id, status)
VALUES
    ('tenant_a', CONCAT('CON-', DATE_FORMAT(CURDATE(), '%Y%m%d'), '-001'),
     'CONSULT', '营业执照办理需要什么材料？',
     '我想开一家餐饮店，请问营业执照需要哪些材料？',
     '张三', '13800000001', 2, 'PENDING'),

    ('tenant_a', CONCAT('CON-', DATE_FORMAT(CURDATE(), '%Y%m%d'), '-002'),
     'COMPLAINT', '窗口人员服务态度差',
     '今天下午3点，3号窗口工作人员态度冷淡。',
     '李四', '13800000002', 2, 'PROCESSING');

-- -------------------- 消息通知 --------------------
INSERT INTO t_notify (tenant_id, receiver, title, content, type, is_read, create_time) VALUES
                                                                                           ('tenant_a', '市级管理员', '系统通知', '欢迎使用政务管理系统，祝您工作愉快！', 'SYSTEM', 0, NOW()),
                                                                                           ('tenant_a', '市级管理员', '待办提醒', '您有 3 条事项待审批，请及时处理', 'TASK', 0, NOW()),
                                                                                           ('tenant_a', '市级管理员', '办件完成', '事项「A市营业执照变更」已审批通过', 'SYSTEM', 1, NOW() - INTERVAL 1 DAY),
                                                                                           ('tenant_b', 'B市管理员', '系统通知', 'B市政务系统已上线', 'SYSTEM', 0, NOW());

-- -------------------- 字典类型 --------------------
INSERT INTO sys_dict_type (tenant_id, dict_type, dict_name, remark) VALUES
                                                                        ('tenant_a', 'application_status', '事项状态', '事项的办理状态'),
                                                                        ('tenant_a', 'evaluation_channel', '评价渠道', '群众提交评价的渠道'),
                                                                        ('tenant_a', 'evaluation_score',   '评价等级', '好差评评分等级'),
                                                                        ('tenant_a', 'gender',             '性别',     '性别字典'),
                                                                        ('tenant_a', 'yes_no',             '是否',     '通用是否字典');

-- -------------------- 字典项 --------------------
INSERT INTO sys_dict (tenant_id, dict_type, dict_label, dict_value, sort, status) VALUES
                                                                                      ('tenant_a', 'application_status', '草稿',      'DRAFT',    1, 1),
                                                                                      ('tenant_a', 'application_status', '待审批',    'PENDING',  2, 1),
                                                                                      ('tenant_a', 'application_status', '已通过',    'APPROVED', 3, 1),
                                                                                      ('tenant_a', 'application_status', '已驳回',    'REJECTED', 4, 1),
                                                                                      ('tenant_a', 'evaluation_channel', '网上办事',  'ONLINE',   1, 1),
                                                                                      ('tenant_a', 'evaluation_channel', '手机APP',   'APP',      2, 1),
                                                                                      ('tenant_a', 'evaluation_channel', '窗口',      'WINDOW',   3, 1),
                                                                                      ('tenant_a', 'evaluation_channel', '电话',      'PHONE',    4, 1),
                                                                                      ('tenant_a', 'evaluation_score',   '非常满意',  '5',        1, 1),
                                                                                      ('tenant_a', 'evaluation_score',   '满意',      '4',        2, 1),
                                                                                      ('tenant_a', 'evaluation_score',   '基本满意',  '3',        3, 1),
                                                                                      ('tenant_a', 'evaluation_score',   '不满意',    '2',        4, 1),
                                                                                      ('tenant_a', 'evaluation_score',   '非常不满意','1',        5, 1),
                                                                                      ('tenant_a', 'gender',             '男',        'M',        1, 1),
                                                                                      ('tenant_a', 'gender',             '女',        'F',        2, 1),
                                                                                      ('tenant_a', 'yes_no',             '是',        'Y',        1, 1),
                                                                                      ('tenant_a', 'yes_no',             '否',        'N',        2, 1);

-- -------------------- 系统配置 --------------------
INSERT INTO sys_config (tenant_id, config_name, config_key, config_value, remark) VALUES
                                                                                      ('tenant_a', '系统名称',         'system.name',         '政务管理系统', '系统名称'),
                                                                                      ('tenant_a', '系统Logo',         'system.logo',         '',             '系统Logo URL'),
                                                                                      ('tenant_a', '办件超期天数',     'application.timeout', '7',            '办件超期天数'),
                                                                                      ('tenant_a', '办结后自动发评价', 'evaluation.autoSend', 'true',         '办结后自动发送评价邀请'),
                                                                                      ('tenant_a', '短信通知开关',     'notify.sms.enabled',  'false',        '是否启用短信通知');

-- ============================================================
-- 完成
-- ============================================================

SELECT '数据库初始化完成' AS result;
SELECT COUNT(*) AS table_count FROM information_schema.tables WHERE table_schema = 'gov_db';