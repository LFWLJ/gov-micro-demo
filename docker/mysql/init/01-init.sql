-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: gov_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `gov_db`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `gov_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `gov_db`;

--
-- Table structure for table `act_evt_log`
--

DROP TABLE IF EXISTS `act_evt_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_evt_log` (
  `LOG_NR_` bigint NOT NULL AUTO_INCREMENT,
  `TYPE_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TIME_STAMP_` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `DATA_` longblob,
  `LOCK_OWNER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `LOCK_TIME_` timestamp(3) NULL DEFAULT NULL,
  `IS_PROCESSED_` tinyint DEFAULT '0',
  PRIMARY KEY (`LOG_NR_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_evt_log`
--

LOCK TABLES `act_evt_log` WRITE;
/*!40000 ALTER TABLE `act_evt_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_evt_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ge_bytearray`
--

DROP TABLE IF EXISTS `act_ge_bytearray`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ge_bytearray` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `DEPLOYMENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `BYTES_` longblob,
  `GENERATED_` tinyint DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_FK_BYTEARR_DEPL` (`DEPLOYMENT_ID_`),
  CONSTRAINT `ACT_FK_BYTEARR_DEPL` FOREIGN KEY (`DEPLOYMENT_ID_`) REFERENCES `act_re_deployment` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ge_bytearray`
--

LOCK TABLES `act_ge_bytearray` WRITE;
/*!40000 ALTER TABLE `act_ge_bytearray` DISABLE KEYS */;
INSERT INTO `act_ge_bytearray` VALUES ('11b22817-b272-11f1-ad93-202b20a0f17a',1,'processes/leave-approval.bpmn20.xml','11b22816-b272-11f1-ad93-202b20a0f17a',_binary '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<definitions xmlns=\"http://www.omg.org/spec/BPMN/20100524/MODEL\"\r\n             xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\r\n             xmlns:flowable=\"http://flowable.org/bpmn\"\r\n             targetNamespace=\"http://gov.com/process\">\r\n\r\n    <process id=\"leaveApproval\" name=\"请假审批\" isExecutable=\"true\">\r\n\r\n        <startEvent id=\"start\" name=\"发起申请\"/>\r\n\r\n        <sequenceFlow id=\"flow1\" sourceRef=\"start\" targetRef=\"deptLeaderTask\"/>\r\n\r\n        <!-- 第一步：部门领导审批 -->\r\n        <userTask id=\"deptLeaderTask\" name=\"部门领导审批\"\r\n                  flowable:assignee=\"${deptLeader}\"/>\r\n\r\n        <sequenceFlow id=\"flow2\" sourceRef=\"deptLeaderTask\" targetRef=\"decision\"/>\r\n\r\n        <!-- 排他网关：根据天数判断是否需要上级审批 -->\r\n        <exclusiveGateway id=\"decision\" name=\"是否需要上级审批\"/>\r\n\r\n        <sequenceFlow id=\"flow3\" sourceRef=\"decision\" targetRef=\"hrTask\">\r\n            <conditionExpression xsi:type=\"tFormalExpression\">\r\n                <![CDATA[${days <= 3}]]>\r\n            </conditionExpression>\r\n        </sequenceFlow>\r\n\r\n        <sequenceFlow id=\"flow4\" sourceRef=\"decision\" targetRef=\"directorTask\">\r\n            <conditionExpression xsi:type=\"tFormalExpression\">\r\n                <![CDATA[${days > 3}]]>\r\n            </conditionExpression>\r\n        </sequenceFlow>\r\n\r\n        <!-- 第二步（≤3 天）：人事备案 -->\r\n        <userTask id=\"hrTask\" name=\"人事备案\"\r\n                  flowable:assignee=\"${hr}\"/>\r\n\r\n        <!-- 第二步（>3 天）：分管领导审批 -->\r\n        <userTask id=\"directorTask\" name=\"分管领导审批\"\r\n                  flowable:assignee=\"${director}\"/>\r\n\r\n        <sequenceFlow id=\"flow5\" sourceRef=\"hrTask\" targetRef=\"end\"/>\r\n        <sequenceFlow id=\"flow6\" sourceRef=\"directorTask\" targetRef=\"hrTask2\"/>\r\n\r\n        <!-- >3 天需要人事再次备案 -->\r\n        <userTask id=\"hrTask2\" name=\"人事备案\"\r\n                  flowable:assignee=\"${hr}\"/>\r\n\r\n        <sequenceFlow id=\"flow7\" sourceRef=\"hrTask2\" targetRef=\"end\"/>\r\n\r\n        <endEvent id=\"end\" name=\"审批完成\"/>\r\n\r\n    </process>\r\n</definitions>',0),('11c38d3a-b272-11f1-ad93-202b20a0f17a',1,'processes/leave-approval.bpmn20.xml','11c38d39-b272-11f1-ad93-202b20a0f17a',_binary '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<definitions xmlns=\"http://www.omg.org/spec/BPMN/20100524/MODEL\"\r\n             xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\r\n             xmlns:flowable=\"http://flowable.org/bpmn\"\r\n             targetNamespace=\"http://gov.com/process\">\r\n\r\n    <process id=\"leaveApproval\" name=\"请假审批\" isExecutable=\"true\">\r\n\r\n        <startEvent id=\"start\" name=\"发起申请\"/>\r\n\r\n        <sequenceFlow id=\"flow1\" sourceRef=\"start\" targetRef=\"deptLeaderTask\"/>\r\n\r\n        <!-- 第一步：部门领导审批 -->\r\n        <userTask id=\"deptLeaderTask\" name=\"部门领导审批\"\r\n                  flowable:assignee=\"${deptLeader}\"/>\r\n\r\n        <sequenceFlow id=\"flow2\" sourceRef=\"deptLeaderTask\" targetRef=\"decision\"/>\r\n\r\n        <!-- 排他网关：根据天数判断是否需要上级审批 -->\r\n        <exclusiveGateway id=\"decision\" name=\"是否需要上级审批\"/>\r\n\r\n        <sequenceFlow id=\"flow3\" sourceRef=\"decision\" targetRef=\"hrTask\">\r\n            <conditionExpression xsi:type=\"tFormalExpression\">\r\n                <![CDATA[${days <= 3}]]>\r\n            </conditionExpression>\r\n        </sequenceFlow>\r\n\r\n        <sequenceFlow id=\"flow4\" sourceRef=\"decision\" targetRef=\"directorTask\">\r\n            <conditionExpression xsi:type=\"tFormalExpression\">\r\n                <![CDATA[${days > 3}]]>\r\n            </conditionExpression>\r\n        </sequenceFlow>\r\n\r\n        <!-- 第二步（≤3 天）：人事备案 -->\r\n        <userTask id=\"hrTask\" name=\"人事备案\"\r\n                  flowable:assignee=\"${hr}\"/>\r\n\r\n        <!-- 第二步（>3 天）：分管领导审批 -->\r\n        <userTask id=\"directorTask\" name=\"分管领导审批\"\r\n                  flowable:assignee=\"${director}\"/>\r\n\r\n        <sequenceFlow id=\"flow5\" sourceRef=\"hrTask\" targetRef=\"end\"/>\r\n        <sequenceFlow id=\"flow6\" sourceRef=\"directorTask\" targetRef=\"hrTask2\"/>\r\n\r\n        <!-- >3 天需要人事再次备案 -->\r\n        <userTask id=\"hrTask2\" name=\"人事备案\"\r\n                  flowable:assignee=\"${hr}\"/>\r\n\r\n        <sequenceFlow id=\"flow7\" sourceRef=\"hrTask2\" targetRef=\"end\"/>\r\n\r\n        <endEvent id=\"end\" name=\"审批完成\"/>\r\n\r\n    </process>\r\n</definitions>',0),('55c36a18-b707-11f1-a03d-202b20a0f17a',1,'D:\\Government Affairs System\\gov-micro-demo\\gov-application\\target\\classes\\processes\\leave-approval.bpmn20.xml','55c36a17-b707-11f1-a03d-202b20a0f17a',_binary '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<definitions xmlns=\"http://www.omg.org/spec/BPMN/20100524/MODEL\"\r\n             xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\r\n             xmlns:flowable=\"http://flowable.org/bpmn\"\r\n             xmlns:bpmndi=\"http://www.omg.org/spec/BPMN/20100524/DI\"\r\n             xmlns:omgdc=\"http://www.omg.org/spec/DD/20100524/DC\"\r\n             xmlns:omgdi=\"http://www.omg.org/spec/DD/20100524/DI\"\r\n             typeLanguage=\"http://www.w3.org/2001/XMLSchema\"\r\n             expressionLanguage=\"http://www.w3.org/1999/XPath\"\r\n             targetNamespace=\"http://gov.com/process\">\r\n\r\n    <process id=\"leaveApproval\" name=\"请假审批\" isExecutable=\"true\">\r\n\r\n        <startEvent id=\"start\" name=\"发起申请\"/>\r\n\r\n        <sequenceFlow id=\"flow1\" sourceRef=\"start\" targetRef=\"deptLeaderTask\"/>\r\n\r\n        <userTask id=\"deptLeaderTask\" name=\"部门领导审批\"\r\n                  flowable:assignee=\"${deptLeader}\"/>\r\n\r\n        <sequenceFlow id=\"flow2\" sourceRef=\"deptLeaderTask\" targetRef=\"decision\"/>\r\n\r\n        <exclusiveGateway id=\"decision\" name=\"天数判断\"/>\r\n\r\n        <sequenceFlow id=\"flow3\" sourceRef=\"decision\" targetRef=\"hrTask\">\r\n            <conditionExpression xsi:type=\"tFormalExpression\">\r\n                <![CDATA[${days <= 3}]]>\r\n            </conditionExpression>\r\n        </sequenceFlow>\r\n\r\n        <sequenceFlow id=\"flow4\" sourceRef=\"decision\" targetRef=\"directorTask\">\r\n            <conditionExpression xsi:type=\"tFormalExpression\">\r\n                <![CDATA[${days > 3}]]>\r\n            </conditionExpression>\r\n        </sequenceFlow>\r\n\r\n        <userTask id=\"hrTask\" name=\"人事备案\"\r\n                  flowable:assignee=\"${hr}\"/>\r\n\r\n        <userTask id=\"directorTask\" name=\"分管领导审批\"\r\n                  flowable:assignee=\"${director}\"/>\r\n\r\n        <sequenceFlow id=\"flow5\" sourceRef=\"hrTask\" targetRef=\"end\"/>\r\n\r\n        <sequenceFlow id=\"flow6\" sourceRef=\"directorTask\" targetRef=\"hrTask2\"/>\r\n\r\n        <userTask id=\"hrTask2\" name=\"人事备案\"\r\n                  flowable:assignee=\"${hr}\"/>\r\n\r\n        <sequenceFlow id=\"flow7\" sourceRef=\"hrTask2\" targetRef=\"end\"/>\r\n\r\n        <endEvent id=\"end\" name=\"审批完成\"/>\r\n\r\n    </process>\r\n\r\n</definitions>',0),('b0b745b7-b337-11f1-a240-202b20a0f17a',1,'D:\\pdf\\management\\gov-micro-demo\\gov-application\\target\\classes\\processes\\leave-approval.bpmn20.xml','b0b745b6-b337-11f1-a240-202b20a0f17a',_binary '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<definitions xmlns=\"http://www.omg.org/spec/BPMN/20100524/MODEL\"\r\n             xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\r\n             xmlns:flowable=\"http://flowable.org/bpmn\"\r\n             xmlns:bpmndi=\"http://www.omg.org/spec/BPMN/20100524/DI\"\r\n             xmlns:omgdc=\"http://www.omg.org/spec/DD/20100524/DC\"\r\n             xmlns:omgdi=\"http://www.omg.org/spec/DD/20100524/DI\"\r\n             typeLanguage=\"http://www.w3.org/2001/XMLSchema\"\r\n             expressionLanguage=\"http://www.w3.org/1999/XPath\"\r\n             targetNamespace=\"http://gov.com/process\">\r\n\r\n    <process id=\"leaveApproval\" name=\"请假审批\" isExecutable=\"true\">\r\n\r\n        <startEvent id=\"start\" name=\"发起申请\"/>\r\n\r\n        <sequenceFlow id=\"flow1\" sourceRef=\"start\" targetRef=\"deptLeaderTask\"/>\r\n\r\n        <userTask id=\"deptLeaderTask\" name=\"部门领导审批\"\r\n                  flowable:assignee=\"${deptLeader}\"/>\r\n\r\n        <sequenceFlow id=\"flow2\" sourceRef=\"deptLeaderTask\" targetRef=\"decision\"/>\r\n\r\n        <exclusiveGateway id=\"decision\" name=\"天数判断\"/>\r\n\r\n        <sequenceFlow id=\"flow3\" sourceRef=\"decision\" targetRef=\"hrTask\">\r\n            <conditionExpression xsi:type=\"tFormalExpression\">\r\n                <![CDATA[${days <= 3}]]>\r\n            </conditionExpression>\r\n        </sequenceFlow>\r\n\r\n        <sequenceFlow id=\"flow4\" sourceRef=\"decision\" targetRef=\"directorTask\">\r\n            <conditionExpression xsi:type=\"tFormalExpression\">\r\n                <![CDATA[${days > 3}]]>\r\n            </conditionExpression>\r\n        </sequenceFlow>\r\n\r\n        <userTask id=\"hrTask\" name=\"人事备案\"\r\n                  flowable:assignee=\"${hr}\"/>\r\n\r\n        <userTask id=\"directorTask\" name=\"分管领导审批\"\r\n                  flowable:assignee=\"${director}\"/>\r\n\r\n        <sequenceFlow id=\"flow5\" sourceRef=\"hrTask\" targetRef=\"end\"/>\r\n\r\n        <sequenceFlow id=\"flow6\" sourceRef=\"directorTask\" targetRef=\"hrTask2\"/>\r\n\r\n        <userTask id=\"hrTask2\" name=\"人事备案\"\r\n                  flowable:assignee=\"${hr}\"/>\r\n\r\n        <sequenceFlow id=\"flow7\" sourceRef=\"hrTask2\" targetRef=\"end\"/>\r\n\r\n        <endEvent id=\"end\" name=\"审批完成\"/>\r\n\r\n    </process>\r\n\r\n</definitions>',0),('bcdd8b22-b17d-11f1-b0e6-202b20a0f17a',1,'D:\\pdf\\gov-micro-demo\\gov-application\\target\\classes\\processes\\leave-approval.bpmn20.xml','bcdd8b21-b17d-11f1-b0e6-202b20a0f17a',_binary '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<definitions xmlns=\"http://www.omg.org/spec/BPMN/20100524/MODEL\"\r\n             xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\r\n             xmlns:flowable=\"http://flowable.org/bpmn\"\r\n             targetNamespace=\"http://gov.com/process\">\r\n\r\n    <process id=\"leaveApproval\" name=\"请假审批\" isExecutable=\"true\">\r\n\r\n        <startEvent id=\"start\" name=\"发起申请\"/>\r\n\r\n        <sequenceFlow id=\"flow1\" sourceRef=\"start\" targetRef=\"deptLeaderTask\"/>\r\n\r\n        <!-- 第一步：部门领导审批 -->\r\n        <userTask id=\"deptLeaderTask\" name=\"部门领导审批\"\r\n                  flowable:assignee=\"${deptLeader}\"/>\r\n\r\n        <sequenceFlow id=\"flow2\" sourceRef=\"deptLeaderTask\" targetRef=\"decision\"/>\r\n\r\n        <!-- 排他网关：根据天数判断是否需要上级审批 -->\r\n        <exclusiveGateway id=\"decision\" name=\"是否需要上级审批\"/>\r\n\r\n        <sequenceFlow id=\"flow3\" sourceRef=\"decision\" targetRef=\"hrTask\">\r\n            <conditionExpression xsi:type=\"tFormalExpression\">\r\n                <![CDATA[${days <= 3}]]>\r\n            </conditionExpression>\r\n        </sequenceFlow>\r\n\r\n        <sequenceFlow id=\"flow4\" sourceRef=\"decision\" targetRef=\"directorTask\">\r\n            <conditionExpression xsi:type=\"tFormalExpression\">\r\n                <![CDATA[${days > 3}]]>\r\n            </conditionExpression>\r\n        </sequenceFlow>\r\n\r\n        <!-- 第二步（≤3 天）：人事备案 -->\r\n        <userTask id=\"hrTask\" name=\"人事备案\"\r\n                  flowable:assignee=\"${hr}\"/>\r\n\r\n        <!-- 第二步（>3 天）：分管领导审批 -->\r\n        <userTask id=\"directorTask\" name=\"分管领导审批\"\r\n                  flowable:assignee=\"${director}\"/>\r\n\r\n        <sequenceFlow id=\"flow5\" sourceRef=\"hrTask\" targetRef=\"end\"/>\r\n        <sequenceFlow id=\"flow6\" sourceRef=\"directorTask\" targetRef=\"hrTask2\"/>\r\n\r\n        <!-- >3 天需要人事再次备案 -->\r\n        <userTask id=\"hrTask2\" name=\"人事备案\"\r\n                  flowable:assignee=\"${hr}\"/>\r\n\r\n        <sequenceFlow id=\"flow7\" sourceRef=\"hrTask2\" targetRef=\"end\"/>\r\n\r\n        <endEvent id=\"end\" name=\"审批完成\"/>\r\n\r\n    </process>\r\n</definitions>',0);
/*!40000 ALTER TABLE `act_ge_bytearray` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ge_property`
--

DROP TABLE IF EXISTS `act_ge_property`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ge_property` (
  `NAME_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `VALUE_` varchar(300) COLLATE utf8mb3_bin DEFAULT NULL,
  `REV_` int DEFAULT NULL,
  PRIMARY KEY (`NAME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ge_property`
--

LOCK TABLES `act_ge_property` WRITE;
/*!40000 ALTER TABLE `act_ge_property` DISABLE KEYS */;
INSERT INTO `act_ge_property` VALUES ('batch.schema.version','7.0.1.1',1),('cfg.execution-related-entities-count','true',1),('cfg.task-related-entities-count','true',1),('common.schema.version','7.0.1.1',1),('entitylink.schema.version','7.0.1.1',1),('eventsubscription.schema.version','7.0.1.1',1),('identitylink.schema.version','7.0.1.1',1),('job.schema.version','7.0.1.1',1),('next.dbid','1',1),('schema.history','create(7.0.1.1)',1),('schema.version','7.0.1.1',1),('task.schema.version','7.0.1.1',1),('variable.schema.version','7.0.1.1',1);
/*!40000 ALTER TABLE `act_ge_property` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_hi_actinst`
--

DROP TABLE IF EXISTS `act_hi_actinst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_hi_actinst` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT '1',
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `ACT_ID_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `CALL_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `ACT_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ACT_TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `ASSIGNEE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `START_TIME_` datetime(3) NOT NULL,
  `END_TIME_` datetime(3) DEFAULT NULL,
  `TRANSACTION_ORDER_` int DEFAULT NULL,
  `DURATION_` bigint DEFAULT NULL,
  `DELETE_REASON_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_HI_ACT_INST_START` (`START_TIME_`),
  KEY `ACT_IDX_HI_ACT_INST_END` (`END_TIME_`),
  KEY `ACT_IDX_HI_ACT_INST_PROCINST` (`PROC_INST_ID_`,`ACT_ID_`),
  KEY `ACT_IDX_HI_ACT_INST_EXEC` (`EXECUTION_ID_`,`ACT_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_hi_actinst`
--

LOCK TABLES `act_hi_actinst` WRITE;
/*!40000 ALTER TABLE `act_hi_actinst` DISABLE KEYS */;
INSERT INTO `act_hi_actinst` VALUES ('166f13fa-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:30:49.759','2026-09-17 16:30:49.768',1,9,NULL,'tenant_a'),('1670728b-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:30:49.768','2026-09-17 16:30:49.768',2,0,NULL,'tenant_a'),('1670728c-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','1672203d-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:30:49.768','2026-09-17 16:31:34.960',3,45192,NULL,'tenant_a'),('1f6a1dbe-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:31:04.826','2026-09-17 16:31:04.826',1,0,NULL,'tenant_a'),('1f6a1dbf-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:31:04.826','2026-09-17 16:31:04.826',2,0,NULL,'tenant_a'),('1f6a1dc0-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','1f6a1dc1-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:31:04.826','2026-09-17 16:32:49.973',3,105147,NULL,'tenant_a'),('31603328-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:31:34.960','2026-09-17 16:31:34.960',1,0,NULL,'tenant_a'),('31603329-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-17 16:31:34.960','2026-09-17 16:31:34.968',2,8,NULL,'tenant_a'),('31616baa-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:31:34.968','2026-09-17 16:31:34.968',3,0,NULL,'tenant_a'),('31616bab-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','directorTask','31616bac-b272-11f1-ad93-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-17 16:31:34.968',NULL,4,NULL,NULL,'tenant_a'),('383aa7dd-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:31:46.458','2026-09-17 16:31:46.458',1,0,NULL,'tenant_a'),('383aceee-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:31:46.459','2026-09-17 16:31:46.459',2,0,NULL,'tenant_a'),('383aceef-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','383acef0-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:31:46.459','2026-09-17 16:34:27.112',3,160653,NULL,'tenant_a'),('5a518a87-b58f-11f1-9502-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a518a86-b58f-11f1-9502-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-21 15:37:52.544','2026-09-21 15:37:52.547',1,3,NULL,'tenant_a'),('5a524dd8-b58f-11f1-9502-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a518a86-b58f-11f1-9502-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-21 15:37:52.549','2026-09-21 15:37:52.549',2,0,NULL,'tenant_a'),('5a524dd9-b58f-11f1-9502-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a518a86-b58f-11f1-9502-202b20a0f17a','deptLeaderTask','5a55d04a-b58f-11f1-9502-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-21 15:37:52.549',NULL,3,NULL,NULL,'tenant_a'),('5e16e2d7-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:32:49.977','2026-09-17 16:32:49.977',1,0,NULL,'tenant_a'),('5e1709e8-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-17 16:32:49.978','2026-09-17 16:32:49.978',2,0,NULL,'tenant_a'),('5e1709e9-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:32:49.978','2026-09-17 16:32:49.978',3,0,NULL,'tenant_a'),('5e1730fa-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','directorTask','5e1730fb-b272-11f1-ad93-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-17 16:32:49.979',NULL,4,NULL,NULL,'tenant_a'),('5e2551f5-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 12:18:44.214','2026-09-20 12:18:44.214',1,0,NULL,'tenant_a'),('5e25a016-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-20 12:18:44.216','2026-09-20 12:18:44.242',2,26,NULL,'tenant_a'),('5e2997b7-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 12:18:44.242','2026-09-20 12:18:44.242',3,0,NULL,'tenant_a'),('5e2997b8-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','directorTask','5e29bec9-b4aa-11f1-8fff-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-20 12:18:44.242',NULL,4,NULL,NULL,'tenant_a'),('5ee3c000-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 12:18:45.462','2026-09-20 12:18:45.462',1,0,NULL,'tenant_a'),('5ee3c001-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-20 12:18:45.462','2026-09-20 12:18:45.462',2,0,NULL,'tenant_a'),('5ee3c002-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 12:18:45.462','2026-09-20 12:18:45.462',3,0,NULL,'tenant_a'),('5ee3e713-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','directorTask','5ee3e714-b4aa-11f1-8fff-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-20 12:18:45.463',NULL,4,NULL,NULL,'tenant_a'),('62dc0c1c-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:32:57.980','2026-09-17 16:32:57.980',1,0,NULL,'tenant_a'),('62dc0c1d-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:32:57.980','2026-09-17 16:32:57.980',2,0,NULL,'tenant_a'),('62dc0c1e-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','62dc0c1f-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:32:57.980','2026-09-17 16:34:28.059',3,90079,NULL,'tenant_a'),('63f607b0-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:32:59.828','2026-09-17 16:32:59.828',1,0,NULL,'tenant_a'),('63f607b1-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:32:59.828','2026-09-17 16:32:59.828',2,0,NULL,'tenant_a'),('63f607b2-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','63f607b3-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:32:59.828','2026-09-17 16:34:28.965',3,89137,NULL,'tenant_a'),('82c27772-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-20 15:47:21.047','2026-09-20 15:47:21.050',1,3,NULL,'tenant_a'),('82c339c3-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 15:47:21.052','2026-09-20 15:47:21.052',2,0,NULL,'tenant_a'),('82c339c4-b4c7-11f1-bea6-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','deptLeaderTask','82c69525-b4c7-11f1-bea6-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-20 15:47:21.052','2026-09-20 15:49:27.423',3,126371,NULL,'tenant_a'),('91ae861a-b662-11f1-b8de-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a','91ae8619-b662-11f1-b8de-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-22 16:49:49.238','2026-09-22 16:49:49.241',1,3,NULL,'tenant_a'),('91af225b-b662-11f1-b8de-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a','91ae8619-b662-11f1-b8de-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-22 16:49:49.242','2026-09-22 16:49:49.242',2,0,NULL,'tenant_a'),('91af225c-b662-11f1-b8de-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a','91ae8619-b662-11f1-b8de-202b20a0f17a','deptLeaderTask','91b27dbd-b662-11f1-b8de-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-22 16:49:49.242',NULL,3,NULL,NULL,'tenant_a'),('9290a48f-b4bc-11f1-a476-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-20 14:29:03.100','2026-09-20 14:29:03.104',1,4,NULL,'tenant_a'),('929167e0-b4bc-11f1-a476-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 14:29:03.105','2026-09-20 14:29:03.105',2,0,NULL,'tenant_a'),('929167e1-b4bc-11f1-a476-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','deptLeaderTask','92955f82-b4bc-11f1-a476-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-20 14:29:03.105','2026-09-20 14:29:16.558',3,13453,NULL,'tenant_a'),('97fcaa0a-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:27.113','2026-09-17 16:34:27.113',1,0,NULL,'tenant_a'),('97fcaa0b-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-17 16:34:27.113','2026-09-17 16:34:27.113',2,0,NULL,'tenant_a'),('97fcaa0c-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:27.113','2026-09-17 16:34:27.113',3,0,NULL,'tenant_a'),('97fcaa0d-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','directorTask','97fcaa0e-b272-11f1-ad93-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-17 16:34:27.113',NULL,4,NULL,NULL,'tenant_a'),('988d7865-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:28.062','2026-09-17 16:34:28.062',1,0,NULL,'tenant_a'),('988d7866-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-17 16:34:28.062','2026-09-17 16:34:28.063',2,1,NULL,'tenant_a'),('988d9f77-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:28.063','2026-09-17 16:34:28.063',3,0,NULL,'tenant_a'),('988d9f78-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','directorTask','988d9f79-b272-11f1-ad93-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-17 16:34:28.063',NULL,4,NULL,NULL,'tenant_a'),('991741e0-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:28.965','2026-09-17 16:34:28.965',1,0,NULL,'tenant_a'),('991741e1-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-17 16:34:28.965','2026-09-17 16:34:28.965',2,0,NULL,'tenant_a'),('991741e2-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:28.965','2026-09-17 16:34:28.965',3,0,NULL,'tenant_a'),('991741e3-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','directorTask','991741e4-b272-11f1-ad93-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-17 16:34:28.965',NULL,4,NULL,NULL,'tenant_a'),('9a831c22-b338-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-18 16:11:51.702','2026-09-18 16:11:51.702',1,0,NULL,'tenant_a'),('9a834333-b338-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-18 16:11:51.703','2026-09-18 16:11:51.703',2,0,NULL,'tenant_a'),('9a834334-b338-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-18 16:11:51.703','2026-09-18 16:11:51.703',3,0,NULL,'tenant_a'),('9a834335-b338-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','directorTask','9a834336-b338-11f1-a240-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-18 16:11:51.703',NULL,4,NULL,NULL,'tenant_a'),('9a9652c9-b4bc-11f1-a476-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 14:29:16.559','2026-09-20 14:29:16.559',1,0,NULL,'tenant_a'),('9a9652ca-b4bc-11f1-a476-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-20 14:29:16.559','2026-09-20 14:29:16.565',2,6,NULL,'tenant_a'),('9a973d2b-b4bc-11f1-a476-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 14:29:16.565','2026-09-20 14:29:16.565',3,0,NULL,'tenant_a'),('9a97643c-b4bc-11f1-a476-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','directorTask','9a97643d-b4bc-11f1-a476-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-20 14:29:16.566',NULL,4,NULL,NULL,'tenant_a'),('9c581515-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:34:34.423','2026-09-17 16:34:34.423',1,0,NULL,'tenant_a'),('9c581516-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:34.423','2026-09-17 16:34:34.423',2,0,NULL,'tenant_a'),('9c581517-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','9c581518-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:34:34.423','2026-09-17 16:34:48.264',3,13841,NULL,'tenant_a'),('a4980d2f-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:48.264','2026-09-17 16:34:48.264',1,0,NULL,'tenant_a'),('a4980d30-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-17 16:34:48.264','2026-09-17 16:34:48.264',2,0,NULL,'tenant_a'),('a4980d31-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:48.264','2026-09-17 16:34:48.264',3,0,NULL,'tenant_a'),('a4980d32-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','directorTask','a4980d33-b272-11f1-ad93-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-17 16:34:48.264',NULL,4,NULL,NULL,'tenant_a'),('a6088d34-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:34:50.679','2026-09-17 16:34:50.679',1,0,NULL,'tenant_a'),('a6088d35-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:50.679','2026-09-17 16:34:50.679',2,0,NULL,'tenant_a'),('a6088d36-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','a6088d37-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:34:50.679','2026-09-20 12:18:45.461',3,243834782,NULL,'tenant_a'),('c651c7b8-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:35:44.846','2026-09-17 16:35:44.847',1,1,NULL,'tenant_a'),('c651eec9-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:35:44.847','2026-09-17 16:35:44.847',2,0,NULL,'tenant_a'),('c651eeca-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','c651eecb-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:35:44.847','2026-09-20 12:18:44.208',3,243779361,NULL,'tenant_a'),('cb7f32f1-b337-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-18 16:06:04.388','2026-09-18 16:06:04.388',1,0,NULL,'tenant_a'),('cb7f32f2-b337-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-18 16:06:04.388','2026-09-18 16:06:04.388',2,0,NULL,'tenant_a'),('cb7f32f3-b337-11f1-a240-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','deptLeaderTask','cb826744-b337-11f1-a240-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-18 16:06:04.388','2026-09-18 16:07:01.884',3,57496,NULL,'tenant_a'),('ce16100c-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 15:49:27.424','2026-09-20 15:49:27.424',1,0,NULL,'tenant_a'),('ce16100d-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-20 15:49:27.424','2026-09-20 15:49:27.430',2,6,NULL,'tenant_a'),('ce16fa6e-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 15:49:27.430','2026-09-20 15:49:27.430',3,0,NULL,'tenant_a'),('ce17217f-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','directorTask','ce172180-b4c7-11f1-bea6-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-20 15:49:27.431',NULL,4,NULL,NULL,'tenant_a'),('d58cb4cc-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:36:10.398','2026-09-17 16:36:10.398',1,0,NULL,'tenant_a'),('d58cb4cd-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:36:10.398','2026-09-17 16:36:10.398',2,0,NULL,'tenant_a'),('d58cb4ce-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','d58cb4cf-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:36:10.398','2026-09-18 16:11:51.702',3,84941304,NULL,'tenant_a'),('edc46479-b337-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-18 16:07:01.884','2026-09-18 16:07:01.884',1,0,NULL,'tenant_a'),('edc575ea-b337-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-18 16:07:01.891','2026-09-18 16:07:01.894',2,3,NULL,'tenant_a'),('edc5eb1b-b337-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-18 16:07:01.894','2026-09-18 16:07:01.894',3,0,NULL,'tenant_a'),('edc5eb1c-b337-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','directorTask','edc5eb1d-b337-11f1-a240-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-18 16:07:01.894',NULL,4,NULL,NULL,'tenant_a'),('fd9a85b1-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85b0-b4c7-11f1-bea6-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-20 15:50:47.145','2026-09-20 15:50:47.145',1,0,NULL,'tenant_a'),('fd9a85b2-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85b0-b4c7-11f1-bea6-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 15:50:47.145','2026-09-20 15:50:47.145',2,0,NULL,'tenant_a'),('fd9a85b3-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85b0-b4c7-11f1-bea6-202b20a0f17a','deptLeaderTask','fd9a85b4-b4c7-11f1-bea6-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-20 15:50:47.145',NULL,3,NULL,NULL,'tenant_a');
/*!40000 ALTER TABLE `act_hi_actinst` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_hi_attachment`
--

DROP TABLE IF EXISTS `act_hi_attachment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_hi_attachment` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `DESCRIPTION_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `URL_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `CONTENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TIME_` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_hi_attachment`
--

LOCK TABLES `act_hi_attachment` WRITE;
/*!40000 ALTER TABLE `act_hi_attachment` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_hi_attachment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_hi_comment`
--

DROP TABLE IF EXISTS `act_hi_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_hi_comment` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TIME_` datetime(3) NOT NULL,
  `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `ACTION_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `MESSAGE_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `FULL_MSG_` longblob,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_hi_comment`
--

LOCK TABLES `act_hi_comment` WRITE;
/*!40000 ALTER TABLE `act_hi_comment` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_hi_comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_hi_detail`
--

DROP TABLE IF EXISTS `act_hi_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_hi_detail` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `ACT_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `NAME_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `VAR_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `REV_` int DEFAULT NULL,
  `TIME_` datetime(3) NOT NULL,
  `BYTEARRAY_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `DOUBLE_` double DEFAULT NULL,
  `LONG_` bigint DEFAULT NULL,
  `TEXT_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `TEXT2_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_HI_DETAIL_PROC_INST` (`PROC_INST_ID_`),
  KEY `ACT_IDX_HI_DETAIL_ACT_INST` (`ACT_INST_ID_`),
  KEY `ACT_IDX_HI_DETAIL_TIME` (`TIME_`),
  KEY `ACT_IDX_HI_DETAIL_NAME` (`NAME_`),
  KEY `ACT_IDX_HI_DETAIL_TASK_ID` (`TASK_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_hi_detail`
--

LOCK TABLES `act_hi_detail` WRITE;
/*!40000 ALTER TABLE `act_hi_detail` DISABLE KEYS */;
INSERT INTO `act_hi_detail` VALUES ('166f13ee-b272-11f1-ad93-202b20a0f17a','VariableUpdate','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-17 16:30:49.759',NULL,NULL,NULL,'WangWu',NULL),('166f13f0-b272-11f1-ad93-202b20a0f17a','VariableUpdate','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-17 16:30:49.759',NULL,NULL,NULL,'tenant_a',NULL),('166f13f2-b272-11f1-ad93-202b20a0f17a','VariableUpdate','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-17 16:30:49.759',NULL,NULL,5,'5',NULL),('166f13f4-b272-11f1-ad93-202b20a0f17a','VariableUpdate','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-17 16:30:49.759',NULL,NULL,NULL,'ZhaoLiu',NULL),('166f13f6-b272-11f1-ad93-202b20a0f17a','VariableUpdate','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-17 16:30:49.759',NULL,NULL,NULL,'LiSi',NULL),('166f13f8-b272-11f1-ad93-202b20a0f17a','VariableUpdate','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-17 16:30:49.759',NULL,NULL,NULL,'ZhangSan',NULL),('1f6a1db2-b272-11f1-ad93-202b20a0f17a','VariableUpdate','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-17 16:31:04.826',NULL,NULL,NULL,'WangWu',NULL),('1f6a1db4-b272-11f1-ad93-202b20a0f17a','VariableUpdate','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-17 16:31:04.826',NULL,NULL,NULL,'tenant_a',NULL),('1f6a1db6-b272-11f1-ad93-202b20a0f17a','VariableUpdate','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-17 16:31:04.826',NULL,NULL,5,'5',NULL),('1f6a1db8-b272-11f1-ad93-202b20a0f17a','VariableUpdate','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-17 16:31:04.826',NULL,NULL,NULL,'ZhaoLiu',NULL),('1f6a1dba-b272-11f1-ad93-202b20a0f17a','VariableUpdate','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-17 16:31:04.826',NULL,NULL,NULL,'LiSi',NULL),('1f6a1dbc-b272-11f1-ad93-202b20a0f17a','VariableUpdate','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-17 16:31:04.826',NULL,NULL,NULL,'ZhangSan',NULL),('31603325-b272-11f1-ad93-202b20a0f17a','VariableUpdate','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,'1670728c-b272-11f1-ad93-202b20a0f17a','approved','boolean',0,'2026-09-17 16:31:34.960',NULL,NULL,1,NULL,NULL),('31603327-b272-11f1-ad93-202b20a0f17a','VariableUpdate','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,'1670728c-b272-11f1-ad93-202b20a0f17a','comment','string',0,'2026-09-17 16:31:34.960',NULL,NULL,NULL,'同意',NULL),('383a59b1-b272-11f1-ad93-202b20a0f17a','VariableUpdate','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-17 16:31:46.456',NULL,NULL,NULL,'WangWu',NULL),('383a59b3-b272-11f1-ad93-202b20a0f17a','VariableUpdate','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-17 16:31:46.456',NULL,NULL,NULL,'tenant_a',NULL),('383a59b5-b272-11f1-ad93-202b20a0f17a','VariableUpdate','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-17 16:31:46.456',NULL,NULL,5,'5',NULL),('383a59b7-b272-11f1-ad93-202b20a0f17a','VariableUpdate','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-17 16:31:46.456',NULL,NULL,NULL,'ZhaoLiu',NULL),('383a59b9-b272-11f1-ad93-202b20a0f17a','VariableUpdate','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-17 16:31:46.456',NULL,NULL,NULL,'LiSi',NULL),('383aa7db-b272-11f1-ad93-202b20a0f17a','VariableUpdate','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-17 16:31:46.458',NULL,NULL,NULL,'ZhangSan',NULL),('5a51636b-b58f-11f1-9502-202b20a0f17a','VariableUpdate','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-21 15:37:52.543',NULL,NULL,NULL,'WangWu',NULL),('5a51636d-b58f-11f1-9502-202b20a0f17a','VariableUpdate','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-21 15:37:52.543',NULL,NULL,NULL,'tenant_a',NULL),('5a51636f-b58f-11f1-9502-202b20a0f17a','VariableUpdate','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-21 15:37:52.543',NULL,NULL,3,'3',NULL),('5a518a81-b58f-11f1-9502-202b20a0f17a','VariableUpdate','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-21 15:37:52.544',NULL,NULL,NULL,'ZhaoLiu',NULL),('5a518a83-b58f-11f1-9502-202b20a0f17a','VariableUpdate','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-21 15:37:52.544',NULL,NULL,NULL,'LiSi',NULL),('5a518a85-b58f-11f1-9502-202b20a0f17a','VariableUpdate','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-21 15:37:52.544',NULL,NULL,NULL,'??',NULL),('5e164694-b272-11f1-ad93-202b20a0f17a','VariableUpdate','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,'1f6a1dc0-b272-11f1-ad93-202b20a0f17a','approved','boolean',0,'2026-09-17 16:32:49.973',NULL,NULL,1,NULL,NULL),('5e164696-b272-11f1-ad93-202b20a0f17a','VariableUpdate','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,'1f6a1dc0-b272-11f1-ad93-202b20a0f17a','comment','string',0,'2026-09-17 16:32:49.973',NULL,NULL,NULL,'同意',NULL),('5e22e0f2-b4aa-11f1-8fff-202b20a0f17a','VariableUpdate','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,'c651eeca-b272-11f1-ad93-202b20a0f17a','approved','boolean',0,'2026-09-20 12:18:44.198',NULL,NULL,1,NULL,NULL),('5e230804-b4aa-11f1-8fff-202b20a0f17a','VariableUpdate','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,'c651eeca-b272-11f1-ad93-202b20a0f17a','comment','string',0,'2026-09-20 12:18:44.199',NULL,NULL,NULL,'同意',NULL),('5ee34acd-b4aa-11f1-8fff-202b20a0f17a','VariableUpdate','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,'a6088d36-b272-11f1-ad93-202b20a0f17a','approved','boolean',0,'2026-09-20 12:18:45.459',NULL,NULL,1,NULL,NULL),('5ee34acf-b4aa-11f1-8fff-202b20a0f17a','VariableUpdate','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,'a6088d36-b272-11f1-ad93-202b20a0f17a','comment','string',0,'2026-09-20 12:18:45.459',NULL,NULL,NULL,'同意',NULL),('62dc0c10-b272-11f1-ad93-202b20a0f17a','VariableUpdate','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-17 16:32:57.980',NULL,NULL,NULL,'WangWu',NULL),('62dc0c12-b272-11f1-ad93-202b20a0f17a','VariableUpdate','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-17 16:32:57.980',NULL,NULL,NULL,'tenant_a',NULL),('62dc0c14-b272-11f1-ad93-202b20a0f17a','VariableUpdate','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-17 16:32:57.980',NULL,NULL,5,'5',NULL),('62dc0c16-b272-11f1-ad93-202b20a0f17a','VariableUpdate','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-17 16:32:57.980',NULL,NULL,NULL,'ZhaoLiu',NULL),('62dc0c18-b272-11f1-ad93-202b20a0f17a','VariableUpdate','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-17 16:32:57.980',NULL,NULL,NULL,'LiSi',NULL),('62dc0c1a-b272-11f1-ad93-202b20a0f17a','VariableUpdate','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-17 16:32:57.980',NULL,NULL,NULL,'ZhangSan',NULL),('63f607a4-b272-11f1-ad93-202b20a0f17a','VariableUpdate','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-17 16:32:59.828',NULL,NULL,NULL,'WangWu',NULL),('63f607a6-b272-11f1-ad93-202b20a0f17a','VariableUpdate','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-17 16:32:59.828',NULL,NULL,NULL,'tenant_a',NULL),('63f607a8-b272-11f1-ad93-202b20a0f17a','VariableUpdate','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-17 16:32:59.828',NULL,NULL,5,'5',NULL),('63f607aa-b272-11f1-ad93-202b20a0f17a','VariableUpdate','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-17 16:32:59.828',NULL,NULL,NULL,'ZhaoLiu',NULL),('63f607ac-b272-11f1-ad93-202b20a0f17a','VariableUpdate','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-17 16:32:59.828',NULL,NULL,NULL,'LiSi',NULL),('63f607ae-b272-11f1-ad93-202b20a0f17a','VariableUpdate','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-17 16:32:59.828',NULL,NULL,NULL,'ZhangSan',NULL),('82c25056-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-20 15:47:21.046',NULL,NULL,NULL,'WangWu',NULL),('82c25058-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-20 15:47:21.046',NULL,NULL,NULL,'tenant_a',NULL),('82c2776a-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-20 15:47:21.047',NULL,NULL,5,'5',NULL),('82c2776c-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-20 15:47:21.047',NULL,NULL,NULL,'ZhaoLiu',NULL),('82c2776e-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-20 15:47:21.047',NULL,NULL,NULL,'LiSi',NULL),('82c27770-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-20 15:47:21.047',NULL,NULL,NULL,'张三',NULL),('91ae5efe-b662-11f1-b8de-202b20a0f17a','VariableUpdate','91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-22 16:49:49.237',NULL,NULL,NULL,'WangWu',NULL),('91ae5f00-b662-11f1-b8de-202b20a0f17a','VariableUpdate','91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-22 16:49:49.237',NULL,NULL,NULL,'tenant_a',NULL),('91ae5f02-b662-11f1-b8de-202b20a0f17a','VariableUpdate','91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-22 16:49:49.237',NULL,NULL,5,'5',NULL),('91ae5f04-b662-11f1-b8de-202b20a0f17a','VariableUpdate','91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-22 16:49:49.237',NULL,NULL,NULL,'ZhaoLiu',NULL),('91ae5f06-b662-11f1-b8de-202b20a0f17a','VariableUpdate','91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-22 16:49:49.237',NULL,NULL,NULL,'LiSi',NULL),('91ae5f08-b662-11f1-b8de-202b20a0f17a','VariableUpdate','91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-22 16:49:49.237',NULL,NULL,NULL,'ZhangSan',NULL),('92907d73-b4bc-11f1-a476-202b20a0f17a','VariableUpdate','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-20 14:29:03.099',NULL,NULL,NULL,'tenant_a',NULL),('92907d75-b4bc-11f1-a476-202b20a0f17a','VariableUpdate','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-20 14:29:03.099',NULL,NULL,4,'4',NULL),('92907d77-b4bc-11f1-a476-202b20a0f17a','VariableUpdate','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-20 14:29:03.099',NULL,NULL,NULL,'ZhaoLiu',NULL),('92907d79-b4bc-11f1-a476-202b20a0f17a','VariableUpdate','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-20 14:29:03.099',NULL,NULL,NULL,'LiSi',NULL),('92907d7b-b4bc-11f1-a476-202b20a0f17a','VariableUpdate','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-20 14:29:03.099',NULL,NULL,NULL,'WangWu',NULL),('92907d7d-b4bc-11f1-a476-202b20a0f17a','VariableUpdate','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-20 14:29:03.099',NULL,NULL,NULL,'ZhangSan',NULL),('97fc34d7-b272-11f1-ad93-202b20a0f17a','VariableUpdate','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,'383aceef-b272-11f1-ad93-202b20a0f17a','approved','boolean',0,'2026-09-17 16:34:27.110',NULL,NULL,1,NULL,NULL),('97fc34d9-b272-11f1-ad93-202b20a0f17a','VariableUpdate','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,'383aceef-b272-11f1-ad93-202b20a0f17a','comment','string',0,'2026-09-17 16:34:27.110',NULL,NULL,NULL,'同意',NULL),('988d0332-b272-11f1-ad93-202b20a0f17a','VariableUpdate','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,'62dc0c1e-b272-11f1-ad93-202b20a0f17a','approved','boolean',0,'2026-09-17 16:34:28.059',NULL,NULL,1,NULL,NULL),('988d0334-b272-11f1-ad93-202b20a0f17a','VariableUpdate','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,'62dc0c1e-b272-11f1-ad93-202b20a0f17a','comment','string',0,'2026-09-17 16:34:28.059',NULL,NULL,NULL,'同意',NULL),('99171acd-b272-11f1-ad93-202b20a0f17a','VariableUpdate','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,'63f607b2-b272-11f1-ad93-202b20a0f17a','approved','boolean',0,'2026-09-17 16:34:28.964',NULL,NULL,1,NULL,NULL),('99171acf-b272-11f1-ad93-202b20a0f17a','VariableUpdate','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,'63f607b2-b272-11f1-ad93-202b20a0f17a','comment','string',0,'2026-09-17 16:34:28.964',NULL,NULL,NULL,'同意',NULL),('9a958f76-b4bc-11f1-a476-202b20a0f17a','VariableUpdate','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,'929167e1-b4bc-11f1-a476-202b20a0f17a','approved','boolean',0,'2026-09-20 14:29:16.554',NULL,NULL,1,NULL,NULL),('9a958f78-b4bc-11f1-a476-202b20a0f17a','VariableUpdate','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,'929167e1-b4bc-11f1-a476-202b20a0f17a','comment','string',0,'2026-09-20 14:29:16.554',NULL,NULL,NULL,'同意',NULL),('9c581509-b272-11f1-ad93-202b20a0f17a','VariableUpdate','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-17 16:34:34.423',NULL,NULL,NULL,'WangWu',NULL),('9c58150b-b272-11f1-ad93-202b20a0f17a','VariableUpdate','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-17 16:34:34.423',NULL,NULL,NULL,'tenant_a',NULL),('9c58150d-b272-11f1-ad93-202b20a0f17a','VariableUpdate','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-17 16:34:34.423',NULL,NULL,5,'5',NULL),('9c58150f-b272-11f1-ad93-202b20a0f17a','VariableUpdate','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-17 16:34:34.423',NULL,NULL,NULL,'ZhaoLiu',NULL),('9c581511-b272-11f1-ad93-202b20a0f17a','VariableUpdate','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-17 16:34:34.423',NULL,NULL,NULL,'LiSi',NULL),('9c581513-b272-11f1-ad93-202b20a0f17a','VariableUpdate','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-17 16:34:34.423',NULL,NULL,NULL,'ZhangSan',NULL),('a49797fc-b272-11f1-ad93-202b20a0f17a','VariableUpdate','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,'9c581517-b272-11f1-ad93-202b20a0f17a','approved','boolean',0,'2026-09-17 16:34:48.261',NULL,NULL,1,NULL,NULL),('a49797fe-b272-11f1-ad93-202b20a0f17a','VariableUpdate','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,'9c581517-b272-11f1-ad93-202b20a0f17a','comment','string',0,'2026-09-17 16:34:48.261',NULL,NULL,NULL,'同意',NULL),('a607f0e8-b272-11f1-ad93-202b20a0f17a','VariableUpdate','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-17 16:34:50.675',NULL,NULL,NULL,'WangWu',NULL),('a607f0ea-b272-11f1-ad93-202b20a0f17a','VariableUpdate','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-17 16:34:50.675',NULL,NULL,NULL,'tenant_a',NULL),('a607f0ec-b272-11f1-ad93-202b20a0f17a','VariableUpdate','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-17 16:34:50.675',NULL,NULL,5,'5',NULL),('a607f0ee-b272-11f1-ad93-202b20a0f17a','VariableUpdate','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-17 16:34:50.675',NULL,NULL,NULL,'ZhaoLiu',NULL),('a6088d30-b272-11f1-ad93-202b20a0f17a','VariableUpdate','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-17 16:34:50.679',NULL,NULL,NULL,'LiSi',NULL),('a6088d32-b272-11f1-ad93-202b20a0f17a','VariableUpdate','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-17 16:34:50.679',NULL,NULL,NULL,'ZhangSan',NULL),('c651c7ac-b272-11f1-ad93-202b20a0f17a','VariableUpdate','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-17 16:35:44.846',NULL,NULL,NULL,'WangWu',NULL),('c651c7ae-b272-11f1-ad93-202b20a0f17a','VariableUpdate','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-17 16:35:44.846',NULL,NULL,NULL,'tenant_a',NULL),('c651c7b0-b272-11f1-ad93-202b20a0f17a','VariableUpdate','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-17 16:35:44.846',NULL,NULL,5,'5',NULL),('c651c7b2-b272-11f1-ad93-202b20a0f17a','VariableUpdate','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-17 16:35:44.846',NULL,NULL,NULL,'ZhaoLiu',NULL),('c651c7b4-b272-11f1-ad93-202b20a0f17a','VariableUpdate','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-17 16:35:44.846',NULL,NULL,NULL,'LiSi',NULL),('c651c7b6-b272-11f1-ad93-202b20a0f17a','VariableUpdate','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-17 16:35:44.846',NULL,NULL,NULL,'ZhangSan',NULL),('ce1573c9-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,'82c339c4-b4c7-11f1-bea6-202b20a0f17a','approved','boolean',0,'2026-09-20 15:49:27.420',NULL,NULL,1,NULL,NULL),('ce159adb-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,'82c339c4-b4c7-11f1-bea6-202b20a0f17a','comment','string',0,'2026-09-20 15:49:27.421',NULL,NULL,NULL,'同意',NULL),('d58c8db0-b272-11f1-ad93-202b20a0f17a','VariableUpdate','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-17 16:36:10.397',NULL,NULL,NULL,'WangWu',NULL),('d58c8db2-b272-11f1-ad93-202b20a0f17a','VariableUpdate','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-17 16:36:10.397',NULL,NULL,NULL,'tenant_a',NULL),('d58c8db4-b272-11f1-ad93-202b20a0f17a','VariableUpdate','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-17 16:36:10.397',NULL,NULL,5,'5',NULL),('d58c8db6-b272-11f1-ad93-202b20a0f17a','VariableUpdate','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-17 16:36:10.397',NULL,NULL,NULL,'ZhaoLiu',NULL),('d58c8db8-b272-11f1-ad93-202b20a0f17a','VariableUpdate','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-17 16:36:10.397',NULL,NULL,NULL,'LiSi',NULL),('d58cb4ca-b272-11f1-ad93-202b20a0f17a','VariableUpdate','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-17 16:36:10.398',NULL,NULL,NULL,'ZhangSan',NULL),('fd9a85a5-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,'tenantId','string',0,'2026-09-20 15:50:47.145',NULL,NULL,NULL,'tenant_a',NULL),('fd9a85a7-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,'days','integer',0,'2026-09-20 15:50:47.145',NULL,NULL,3,'3',NULL),('fd9a85a9-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,'hr','string',0,'2026-09-20 15:50:47.145',NULL,NULL,NULL,'ZhaoLiu',NULL),('fd9a85ab-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,'deptLeader','string',0,'2026-09-20 15:50:47.145',NULL,NULL,NULL,'LiSi',NULL),('fd9a85ad-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,'director','string',0,'2026-09-20 15:50:47.145',NULL,NULL,NULL,'WangWu',NULL),('fd9a85af-b4c7-11f1-bea6-202b20a0f17a','VariableUpdate','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,'applicant','string',0,'2026-09-20 15:50:47.145',NULL,NULL,NULL,'ZhangSan',NULL);
/*!40000 ALTER TABLE `act_hi_detail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_hi_entitylink`
--

DROP TABLE IF EXISTS `act_hi_entitylink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_hi_entitylink` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `LINK_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` datetime(3) DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PARENT_ELEMENT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `REF_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `REF_SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `REF_SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ROOT_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ROOT_SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `HIERARCHY_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_HI_ENT_LNK_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`,`LINK_TYPE_`),
  KEY `ACT_IDX_HI_ENT_LNK_REF_SCOPE` (`REF_SCOPE_ID_`,`REF_SCOPE_TYPE_`,`LINK_TYPE_`),
  KEY `ACT_IDX_HI_ENT_LNK_ROOT_SCOPE` (`ROOT_SCOPE_ID_`,`ROOT_SCOPE_TYPE_`,`LINK_TYPE_`),
  KEY `ACT_IDX_HI_ENT_LNK_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`,`LINK_TYPE_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_hi_entitylink`
--

LOCK TABLES `act_hi_entitylink` WRITE;
/*!40000 ALTER TABLE `act_hi_entitylink` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_hi_entitylink` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_hi_identitylink`
--

DROP TABLE IF EXISTS `act_hi_identitylink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_hi_identitylink` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `GROUP_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` datetime(3) DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_HI_IDENT_LNK_USER` (`USER_ID_`),
  KEY `ACT_IDX_HI_IDENT_LNK_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_IDENT_LNK_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_IDENT_LNK_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_IDENT_LNK_TASK` (`TASK_ID_`),
  KEY `ACT_IDX_HI_IDENT_LNK_PROCINST` (`PROC_INST_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_hi_identitylink`
--

LOCK TABLES `act_hi_identitylink` WRITE;
/*!40000 ALTER TABLE `act_hi_identitylink` DISABLE KEYS */;
INSERT INTO `act_hi_identitylink` VALUES ('1672203e-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','LiSi','1672203d-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:30:49.779',NULL,NULL,NULL,NULL,NULL),('1672203f-b272-11f1-ad93-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-17 16:30:49.779','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('1f6a1dc2-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','LiSi','1f6a1dc1-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:31:04.826',NULL,NULL,NULL,NULL,NULL),('1f6a1dc3-b272-11f1-ad93-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-17 16:31:04.826','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('31616bad-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','WangWu','31616bac-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:31:34.968',NULL,NULL,NULL,NULL,NULL),('31616bae-b272-11f1-ad93-202b20a0f17a',NULL,'participant','WangWu',NULL,'2026-09-17 16:31:34.968','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('383acef1-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','LiSi','383acef0-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:31:46.459',NULL,NULL,NULL,NULL,NULL),('383acef2-b272-11f1-ad93-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-17 16:31:46.459','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('5a56457b-b58f-11f1-9502-202b20a0f17a',NULL,'assignee','LiSi','5a55d04a-b58f-11f1-9502-202b20a0f17a','2026-09-21 15:37:52.575',NULL,NULL,NULL,NULL,NULL),('5a566c8c-b58f-11f1-9502-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-21 15:37:52.576','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,NULL,NULL),('5e1730fc-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','WangWu','5e1730fb-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:32:49.979',NULL,NULL,NULL,NULL,NULL),('5e1730fd-b272-11f1-ad93-202b20a0f17a',NULL,'participant','WangWu',NULL,'2026-09-17 16:32:49.979','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('5e29e5da-b4aa-11f1-8fff-202b20a0f17a',NULL,'assignee','WangWu','5e29bec9-b4aa-11f1-8fff-202b20a0f17a','2026-09-20 12:18:44.244',NULL,NULL,NULL,NULL,NULL),('5e2af74b-b4aa-11f1-8fff-202b20a0f17a',NULL,'participant','WangWu',NULL,'2026-09-20 12:18:44.251','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('5ee3e715-b4aa-11f1-8fff-202b20a0f17a',NULL,'assignee','WangWu','5ee3e714-b4aa-11f1-8fff-202b20a0f17a','2026-09-20 12:18:45.463',NULL,NULL,NULL,NULL,NULL),('5ee40e26-b4aa-11f1-8fff-202b20a0f17a',NULL,'participant','WangWu',NULL,'2026-09-20 12:18:45.464','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('62dc0c20-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','LiSi','62dc0c1f-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:32:57.980',NULL,NULL,NULL,NULL,NULL),('62dc0c21-b272-11f1-ad93-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-17 16:32:57.980','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('63f607b4-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','LiSi','63f607b3-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:32:59.828',NULL,NULL,NULL,NULL,NULL),('63f607b5-b272-11f1-ad93-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-17 16:32:59.828','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('82c70a56-b4c7-11f1-bea6-202b20a0f17a',NULL,'assignee','LiSi','82c69525-b4c7-11f1-bea6-202b20a0f17a','2026-09-20 15:47:21.077',NULL,NULL,NULL,NULL,NULL),('82c75877-b4c7-11f1-bea6-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-20 15:47:21.079','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL),('91b319fe-b662-11f1-b8de-202b20a0f17a',NULL,'assignee','LiSi','91b27dbd-b662-11f1-b8de-202b20a0f17a','2026-09-22 16:49:49.268',NULL,NULL,NULL,NULL,NULL),('91b3410f-b662-11f1-b8de-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-22 16:49:49.269','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,NULL,NULL),('9295d4b3-b4bc-11f1-a476-202b20a0f17a',NULL,'assignee','LiSi','92955f82-b4bc-11f1-a476-202b20a0f17a','2026-09-20 14:29:03.134',NULL,NULL,NULL,NULL,NULL),('9295fbc4-b4bc-11f1-a476-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-20 14:29:03.135','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL),('97fcaa0f-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','WangWu','97fcaa0e-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:34:27.113',NULL,NULL,NULL,NULL,NULL),('97fcaa10-b272-11f1-ad93-202b20a0f17a',NULL,'participant','WangWu',NULL,'2026-09-17 16:34:27.113','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('988d9f7a-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','WangWu','988d9f79-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:34:28.063',NULL,NULL,NULL,NULL,NULL),('988d9f7b-b272-11f1-ad93-202b20a0f17a',NULL,'participant','WangWu',NULL,'2026-09-17 16:34:28.063','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('991741e5-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','WangWu','991741e4-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:34:28.965',NULL,NULL,NULL,NULL,NULL),('9917de26-b272-11f1-ad93-202b20a0f17a',NULL,'participant','WangWu',NULL,'2026-09-17 16:34:28.969','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('9a834337-b338-11f1-a240-202b20a0f17a',NULL,'assignee','WangWu','9a834336-b338-11f1-a240-202b20a0f17a','2026-09-18 16:11:51.703',NULL,NULL,NULL,NULL,NULL),('9a834338-b338-11f1-a240-202b20a0f17a',NULL,'participant','WangWu',NULL,'2026-09-18 16:11:51.703','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('9a97643e-b4bc-11f1-a476-202b20a0f17a',NULL,'assignee','WangWu','9a97643d-b4bc-11f1-a476-202b20a0f17a','2026-09-20 14:29:16.566',NULL,NULL,NULL,NULL,NULL),('9a978b4f-b4bc-11f1-a476-202b20a0f17a',NULL,'participant','WangWu',NULL,'2026-09-20 14:29:16.567','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL),('9c581519-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','LiSi','9c581518-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:34:34.423',NULL,NULL,NULL,NULL,NULL),('9c58151a-b272-11f1-ad93-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-17 16:34:34.423','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('a4980d34-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','WangWu','a4980d33-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:34:48.264',NULL,NULL,NULL,NULL,NULL),('a4980d35-b272-11f1-ad93-202b20a0f17a',NULL,'participant','WangWu',NULL,'2026-09-17 16:34:48.264','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('a6088d38-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','LiSi','a6088d37-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:34:50.679',NULL,NULL,NULL,NULL,NULL),('a6088d39-b272-11f1-ad93-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-17 16:34:50.679','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('c651eecc-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','LiSi','c651eecb-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:35:44.847',NULL,NULL,NULL,NULL,NULL),('c651eecd-b272-11f1-ad93-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-17 16:35:44.847','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('cb826745-b337-11f1-a240-202b20a0f17a',NULL,'assignee','LiSi','cb826744-b337-11f1-a240-202b20a0f17a','2026-09-18 16:06:04.409',NULL,NULL,NULL,NULL,NULL),('cb826746-b337-11f1-a240-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-18 16:06:04.409','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL),('ce172181-b4c7-11f1-bea6-202b20a0f17a',NULL,'assignee','WangWu','ce172180-b4c7-11f1-bea6-202b20a0f17a','2026-09-20 15:49:27.431',NULL,NULL,NULL,NULL,NULL),('ce176fa2-b4c7-11f1-bea6-202b20a0f17a',NULL,'participant','WangWu',NULL,'2026-09-20 15:49:27.433','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL),('d58cb4d0-b272-11f1-ad93-202b20a0f17a',NULL,'assignee','LiSi','d58cb4cf-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:36:10.398',NULL,NULL,NULL,NULL,NULL),('d58cb4d1-b272-11f1-ad93-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-17 16:36:10.398','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL),('edc5eb1e-b337-11f1-a240-202b20a0f17a',NULL,'assignee','WangWu','edc5eb1d-b337-11f1-a240-202b20a0f17a','2026-09-18 16:07:01.894',NULL,NULL,NULL,NULL,NULL),('edc5eb1f-b337-11f1-a240-202b20a0f17a',NULL,'participant','WangWu',NULL,'2026-09-18 16:07:01.894','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL),('fd9a85b5-b4c7-11f1-bea6-202b20a0f17a',NULL,'assignee','LiSi','fd9a85b4-b4c7-11f1-bea6-202b20a0f17a','2026-09-20 15:50:47.145',NULL,NULL,NULL,NULL,NULL),('fd9ad3d6-b4c7-11f1-bea6-202b20a0f17a',NULL,'participant','LiSi',NULL,'2026-09-20 15:50:47.147','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `act_hi_identitylink` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_hi_procinst`
--

DROP TABLE IF EXISTS `act_hi_procinst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_hi_procinst` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT '1',
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `BUSINESS_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `START_TIME_` datetime(3) NOT NULL,
  `END_TIME_` datetime(3) DEFAULT NULL,
  `DURATION_` bigint DEFAULT NULL,
  `START_USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `START_ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `END_ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUPER_PROCESS_INSTANCE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `DELETE_REASON_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CALLBACK_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CALLBACK_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `REFERENCE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `REFERENCE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROPAGATED_STAGE_INST_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `BUSINESS_STATUS_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  UNIQUE KEY `PROC_INST_ID_` (`PROC_INST_ID_`),
  KEY `ACT_IDX_HI_PRO_INST_END` (`END_TIME_`),
  KEY `ACT_IDX_HI_PRO_I_BUSKEY` (`BUSINESS_KEY_`),
  KEY `ACT_IDX_HI_PRO_SUPER_PROCINST` (`SUPER_PROCESS_INSTANCE_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_hi_procinst`
--

LOCK TABLES `act_hi_procinst` WRITE;
/*!40000 ALTER TABLE `act_hi_procinst` DISABLE KEYS */;
INSERT INTO `act_hi_procinst` VALUES ('166f13ec-b272-11f1-ad93-202b20a0f17a',1,'166f13ec-b272-11f1-ad93-202b20a0f17a','LEAVE-1789633849738','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:30:49.759',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('1f6a1db0-b272-11f1-ad93-202b20a0f17a',1,'1f6a1db0-b272-11f1-ad93-202b20a0f17a','LEAVE-1789633864817','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:31:04.826',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('383a59af-b272-11f1-ad93-202b20a0f17a',1,'383a59af-b272-11f1-ad93-202b20a0f17a','LEAVE-1789633906448','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:31:46.456',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('5a50ee39-b58f-11f1-9502-202b20a0f17a',1,'5a50ee39-b58f-11f1-9502-202b20a0f17a','12','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-21 15:37:52.540',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('62dc0c0e-b272-11f1-ad93-202b20a0f17a',1,'62dc0c0e-b272-11f1-ad93-202b20a0f17a','LEAVE-1789633977971','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:32:57.980',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('63f607a2-b272-11f1-ad93-202b20a0f17a',1,'63f607a2-b272-11f1-ad93-202b20a0f17a','LEAVE-1789633979826','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:32:59.828',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('82c1db24-b4c7-11f1-bea6-202b20a0f17a',1,'82c1db24-b4c7-11f1-bea6-202b20a0f17a','11','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-20 15:47:21.043',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('91adc2bc-b662-11f1-b8de-202b20a0f17a',1,'91adc2bc-b662-11f1-b8de-202b20a0f17a','13','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-22 16:49:49.233',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('92900841-b4bc-11f1-a476-202b20a0f17a',1,'92900841-b4bc-11f1-a476-202b20a0f17a','LEAVE-1789885728459','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-20 14:29:03.096',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('9c581507-b272-11f1-ad93-202b20a0f17a',1,'9c581507-b272-11f1-ad93-202b20a0f17a','LEAVE-1789634074418','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:34:34.423',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('a607f0e6-b272-11f1-ad93-202b20a0f17a',1,'a607f0e6-b272-11f1-ad93-202b20a0f17a','LEAVE-1789634090669','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:34:50.675',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('c651c7aa-b272-11f1-ad93-202b20a0f17a',1,'c651c7aa-b272-11f1-ad93-202b20a0f17a','LEAVE-1789634144837','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:35:44.846',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('cb7f32e9-b337-11f1-a240-202b20a0f17a',1,'cb7f32e9-b337-11f1-a240-202b20a0f17a','LEAVE-20260918160603','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-18 16:06:04.388',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('d58c8dae-b272-11f1-ad93-202b20a0f17a',1,'d58c8dae-b272-11f1-ad93-202b20a0f17a','LEAVE-1789634170388','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-17 16:36:10.397',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL),('fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',1,'fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','LEAVE-1789890643223','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','2026-09-20 15:50:47.144',NULL,NULL,NULL,'start',NULL,NULL,NULL,'tenant_a',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `act_hi_procinst` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_hi_taskinst`
--

DROP TABLE IF EXISTS `act_hi_taskinst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_hi_taskinst` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT '1',
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROPAGATED_STAGE_INST_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `STATE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PARENT_TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `DESCRIPTION_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `OWNER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ASSIGNEE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `START_TIME_` datetime(3) NOT NULL,
  `IN_PROGRESS_TIME_` datetime(3) DEFAULT NULL,
  `IN_PROGRESS_STARTED_BY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CLAIM_TIME_` datetime(3) DEFAULT NULL,
  `CLAIMED_BY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUSPENDED_TIME_` datetime(3) DEFAULT NULL,
  `SUSPENDED_BY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `END_TIME_` datetime(3) DEFAULT NULL,
  `COMPLETED_BY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `DURATION_` bigint DEFAULT NULL,
  `DELETE_REASON_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `PRIORITY_` int DEFAULT NULL,
  `IN_PROGRESS_DUE_DATE_` datetime(3) DEFAULT NULL,
  `DUE_DATE_` datetime(3) DEFAULT NULL,
  `FORM_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  `LAST_UPDATED_TIME_` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_HI_TASK_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_TASK_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_TASK_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_TASK_INST_PROCINST` (`PROC_INST_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_hi_taskinst`
--

LOCK TABLES `act_hi_taskinst` WRITE;
/*!40000 ALTER TABLE `act_hi_taskinst` DISABLE KEYS */;
INSERT INTO `act_hi_taskinst` VALUES ('1672203d-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'completed','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-17 16:30:49.768',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-17 16:31:34.960',NULL,45192,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-17 16:31:34.960'),('1f6a1dc1-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'completed','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-17 16:31:04.826',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-17 16:32:49.973',NULL,105147,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-17 16:32:49.973'),('31616bac-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'directorTask','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,NULL,'WangWu','2026-09-17 16:31:34.968',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-17 16:31:34.968'),('383acef0-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'completed','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-17 16:31:46.459',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-17 16:34:27.110',NULL,160651,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-17 16:34:27.110'),('5a55d04a-b58f-11f1-9502-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a518a86-b58f-11f1-9502-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-21 15:37:52.550',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-21 15:37:52.575'),('5e1730fb-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'directorTask','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,NULL,'WangWu','2026-09-17 16:32:49.979',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-17 16:32:49.979'),('5e29bec9-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'directorTask','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,NULL,'WangWu','2026-09-20 12:18:44.243',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-20 12:18:44.244'),('5ee3e714-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'directorTask','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,NULL,'WangWu','2026-09-20 12:18:45.463',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-20 12:18:45.463'),('62dc0c1f-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'completed','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-17 16:32:57.980',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-17 16:34:28.059',NULL,90079,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-17 16:34:28.059'),('63f607b3-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'completed','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-17 16:32:59.828',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-17 16:34:28.964',NULL,89136,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-17 16:34:28.964'),('82c69525-b4c7-11f1-bea6-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'completed','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-20 15:47:21.052',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-20 15:49:27.421',NULL,126369,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-20 15:49:27.421'),('91b27dbd-b662-11f1-b8de-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','91adc2bc-b662-11f1-b8de-202b20a0f17a','91ae8619-b662-11f1-b8de-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-22 16:49:49.244',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-22 16:49:49.267'),('92955f82-b4bc-11f1-a476-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'completed','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-20 14:29:03.105',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-20 14:29:16.554',NULL,13449,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-20 14:29:16.554'),('97fcaa0e-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'directorTask','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,NULL,'WangWu','2026-09-17 16:34:27.113',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-17 16:34:27.113'),('988d9f79-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'directorTask','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,NULL,'WangWu','2026-09-17 16:34:28.063',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-17 16:34:28.063'),('991741e4-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'directorTask','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,NULL,'WangWu','2026-09-17 16:34:28.965',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-17 16:34:28.965'),('9a834336-b338-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'directorTask','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,NULL,'WangWu','2026-09-18 16:11:51.703',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-18 16:11:51.703'),('9a97643d-b4bc-11f1-a476-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'directorTask','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,NULL,'WangWu','2026-09-20 14:29:16.566',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-20 14:29:16.566'),('9c581518-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'completed','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-17 16:34:34.423',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-17 16:34:48.261',NULL,13838,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-17 16:34:48.261'),('a4980d33-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'directorTask','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,NULL,'WangWu','2026-09-17 16:34:48.264',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-17 16:34:48.264'),('a6088d37-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'completed','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-17 16:34:50.679',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-20 12:18:45.459',NULL,243834780,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-20 12:18:45.459'),('c651eecb-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'completed','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-17 16:35:44.847',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-20 12:18:44.200',NULL,243779353,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-20 12:18:44.200'),('cb826744-b337-11f1-a240-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'completed','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-18 16:06:04.388',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-18 16:07:01.884',NULL,57496,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-18 16:07:01.884'),('ce172180-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'directorTask','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,NULL,'WangWu','2026-09-20 15:49:27.431',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-20 15:49:27.431'),('d58cb4cf-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'completed','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-17 16:36:10.398',NULL,NULL,NULL,NULL,NULL,NULL,'2026-09-18 16:11:51.692',NULL,84941294,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-18 16:11:51.692'),('edc5eb1d-b337-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'directorTask','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,NULL,'WangWu','2026-09-18 16:07:01.894',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-18 16:07:01.894'),('fd9a85b4-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeaderTask','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85b0-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,'created','部门领导审批',NULL,NULL,NULL,'LiSi','2026-09-20 15:50:47.145',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50,NULL,NULL,NULL,NULL,'tenant_a','2026-09-20 15:50:47.145');
/*!40000 ALTER TABLE `act_hi_taskinst` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_hi_tsk_log`
--

DROP TABLE IF EXISTS `act_hi_tsk_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_hi_tsk_log` (
  `ID_` bigint NOT NULL AUTO_INCREMENT,
  `TYPE_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `TIME_STAMP_` timestamp(3) NOT NULL,
  `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `DATA_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_hi_tsk_log`
--

LOCK TABLES `act_hi_tsk_log` WRITE;
/*!40000 ALTER TABLE `act_hi_tsk_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_hi_tsk_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_hi_varinst`
--

DROP TABLE IF EXISTS `act_hi_varinst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_hi_varinst` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT '1',
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `NAME_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `VAR_TYPE_` varchar(100) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `BYTEARRAY_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `DOUBLE_` double DEFAULT NULL,
  `LONG_` bigint DEFAULT NULL,
  `TEXT_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `TEXT2_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `META_INFO_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` datetime(3) DEFAULT NULL,
  `LAST_UPDATED_TIME_` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_HI_PROCVAR_NAME_TYPE` (`NAME_`,`VAR_TYPE_`),
  KEY `ACT_IDX_HI_VAR_SCOPE_ID_TYPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_VAR_SUB_ID_TYPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_HI_PROCVAR_PROC_INST` (`PROC_INST_ID_`),
  KEY `ACT_IDX_HI_PROCVAR_TASK_ID` (`TASK_ID_`),
  KEY `ACT_IDX_HI_PROCVAR_EXE` (`EXECUTION_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_hi_varinst`
--

LOCK TABLES `act_hi_varinst` WRITE;
/*!40000 ALTER TABLE `act_hi_varinst` DISABLE KEYS */;
INSERT INTO `act_hi_varinst` VALUES ('166f13ed-b272-11f1-ad93-202b20a0f17a',0,'166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-17 16:30:49.759','2026-09-17 16:30:49.759'),('166f13ef-b272-11f1-ad93-202b20a0f17a',0,'166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:30:49.759','2026-09-17 16:30:49.759'),('166f13f1-b272-11f1-ad93-202b20a0f17a',0,'166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL,'2026-09-17 16:30:49.759','2026-09-17 16:30:49.759'),('166f13f3-b272-11f1-ad93-202b20a0f17a',0,'166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-17 16:30:49.759','2026-09-17 16:30:49.759'),('166f13f5-b272-11f1-ad93-202b20a0f17a',0,'166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-17 16:30:49.759','2026-09-17 16:30:49.759'),('166f13f7-b272-11f1-ad93-202b20a0f17a',0,'166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL,'2026-09-17 16:30:49.759','2026-09-17 16:30:49.759'),('1f6a1db1-b272-11f1-ad93-202b20a0f17a',0,'1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-17 16:31:04.826','2026-09-17 16:31:04.826'),('1f6a1db3-b272-11f1-ad93-202b20a0f17a',0,'1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:31:04.826','2026-09-17 16:31:04.826'),('1f6a1db5-b272-11f1-ad93-202b20a0f17a',0,'1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL,'2026-09-17 16:31:04.826','2026-09-17 16:31:04.826'),('1f6a1db7-b272-11f1-ad93-202b20a0f17a',0,'1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-17 16:31:04.826','2026-09-17 16:31:04.826'),('1f6a1db9-b272-11f1-ad93-202b20a0f17a',0,'1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-17 16:31:04.826','2026-09-17 16:31:04.826'),('1f6a1dbb-b272-11f1-ad93-202b20a0f17a',0,'1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL,'2026-09-17 16:31:04.826','2026-09-17 16:31:04.826'),('31600c14-b272-11f1-ad93-202b20a0f17a',0,'166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,'approved','boolean',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2026-09-17 16:31:34.959','2026-09-17 16:31:34.959'),('31603326-b272-11f1-ad93-202b20a0f17a',0,'166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,'comment','string',NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL,'2026-09-17 16:31:34.960','2026-09-17 16:31:34.960'),('383a59b0-b272-11f1-ad93-202b20a0f17a',0,'383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-17 16:31:46.456','2026-09-17 16:31:46.456'),('383a59b2-b272-11f1-ad93-202b20a0f17a',0,'383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:31:46.456','2026-09-17 16:31:46.456'),('383a59b4-b272-11f1-ad93-202b20a0f17a',0,'383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL,'2026-09-17 16:31:46.456','2026-09-17 16:31:46.456'),('383a59b6-b272-11f1-ad93-202b20a0f17a',0,'383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-17 16:31:46.456','2026-09-17 16:31:46.456'),('383a59b8-b272-11f1-ad93-202b20a0f17a',0,'383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-17 16:31:46.456','2026-09-17 16:31:46.456'),('383aa7da-b272-11f1-ad93-202b20a0f17a',0,'383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL,'2026-09-17 16:31:46.458','2026-09-17 16:31:46.458'),('5a51154a-b58f-11f1-9502-202b20a0f17a',0,'5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-21 15:37:52.543','2026-09-21 15:37:52.543'),('5a51636c-b58f-11f1-9502-202b20a0f17a',0,'5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-21 15:37:52.543','2026-09-21 15:37:52.543'),('5a51636e-b58f-11f1-9502-202b20a0f17a',0,'5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,3,'3',NULL,NULL,'2026-09-21 15:37:52.543','2026-09-21 15:37:52.543'),('5a516370-b58f-11f1-9502-202b20a0f17a',0,'5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-21 15:37:52.544','2026-09-21 15:37:52.544'),('5a518a82-b58f-11f1-9502-202b20a0f17a',0,'5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-21 15:37:52.544','2026-09-21 15:37:52.544'),('5a518a84-b58f-11f1-9502-202b20a0f17a',0,'5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'??',NULL,NULL,'2026-09-21 15:37:52.544','2026-09-21 15:37:52.544'),('5e164693-b272-11f1-ad93-202b20a0f17a',0,'1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,'approved','boolean',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2026-09-17 16:32:49.973','2026-09-17 16:32:49.973'),('5e164695-b272-11f1-ad93-202b20a0f17a',0,'1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,'comment','string',NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL,'2026-09-17 16:32:49.973','2026-09-17 16:32:49.973'),('5e21a871-b4aa-11f1-8fff-202b20a0f17a',0,'c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,'approved','boolean',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2026-09-20 12:18:44.194','2026-09-20 12:18:44.194'),('5e230803-b4aa-11f1-8fff-202b20a0f17a',0,'c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,'comment','string',NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL,'2026-09-20 12:18:44.199','2026-09-20 12:18:44.199'),('5ee323bc-b4aa-11f1-8fff-202b20a0f17a',0,'a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,'approved','boolean',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2026-09-20 12:18:45.458','2026-09-20 12:18:45.458'),('5ee34ace-b4aa-11f1-8fff-202b20a0f17a',0,'a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,'comment','string',NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL,'2026-09-20 12:18:45.459','2026-09-20 12:18:45.459'),('62dc0c0f-b272-11f1-ad93-202b20a0f17a',0,'62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-17 16:32:57.980','2026-09-17 16:32:57.980'),('62dc0c11-b272-11f1-ad93-202b20a0f17a',0,'62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:32:57.980','2026-09-17 16:32:57.980'),('62dc0c13-b272-11f1-ad93-202b20a0f17a',0,'62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL,'2026-09-17 16:32:57.980','2026-09-17 16:32:57.980'),('62dc0c15-b272-11f1-ad93-202b20a0f17a',0,'62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-17 16:32:57.980','2026-09-17 16:32:57.980'),('62dc0c17-b272-11f1-ad93-202b20a0f17a',0,'62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-17 16:32:57.980','2026-09-17 16:32:57.980'),('62dc0c19-b272-11f1-ad93-202b20a0f17a',0,'62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL,'2026-09-17 16:32:57.980','2026-09-17 16:32:57.980'),('63f607a3-b272-11f1-ad93-202b20a0f17a',0,'63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-17 16:32:59.828','2026-09-17 16:32:59.828'),('63f607a5-b272-11f1-ad93-202b20a0f17a',0,'63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:32:59.828','2026-09-17 16:32:59.828'),('63f607a7-b272-11f1-ad93-202b20a0f17a',0,'63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL,'2026-09-17 16:32:59.828','2026-09-17 16:32:59.828'),('63f607a9-b272-11f1-ad93-202b20a0f17a',0,'63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-17 16:32:59.828','2026-09-17 16:32:59.828'),('63f607ab-b272-11f1-ad93-202b20a0f17a',0,'63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-17 16:32:59.828','2026-09-17 16:32:59.828'),('63f607ad-b272-11f1-ad93-202b20a0f17a',0,'63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL,'2026-09-17 16:32:59.828','2026-09-17 16:32:59.828'),('82c20235-b4c7-11f1-bea6-202b20a0f17a',0,'82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-20 15:47:21.046','2026-09-20 15:47:21.046'),('82c25057-b4c7-11f1-bea6-202b20a0f17a',0,'82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-20 15:47:21.046','2026-09-20 15:47:21.046'),('82c27769-b4c7-11f1-bea6-202b20a0f17a',0,'82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL,'2026-09-20 15:47:21.047','2026-09-20 15:47:21.047'),('82c2776b-b4c7-11f1-bea6-202b20a0f17a',0,'82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-20 15:47:21.047','2026-09-20 15:47:21.047'),('82c2776d-b4c7-11f1-bea6-202b20a0f17a',0,'82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-20 15:47:21.047','2026-09-20 15:47:21.047'),('82c2776f-b4c7-11f1-bea6-202b20a0f17a',0,'82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'张三',NULL,NULL,'2026-09-20 15:47:21.047','2026-09-20 15:47:21.047'),('91ae10dd-b662-11f1-b8de-202b20a0f17a',0,'91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-22 16:49:49.236','2026-09-22 16:49:49.236'),('91ae5eff-b662-11f1-b8de-202b20a0f17a',0,'91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-22 16:49:49.237','2026-09-22 16:49:49.237'),('91ae5f01-b662-11f1-b8de-202b20a0f17a',0,'91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL,'2026-09-22 16:49:49.237','2026-09-22 16:49:49.237'),('91ae5f03-b662-11f1-b8de-202b20a0f17a',0,'91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-22 16:49:49.237','2026-09-22 16:49:49.237'),('91ae5f05-b662-11f1-b8de-202b20a0f17a',0,'91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-22 16:49:49.237','2026-09-22 16:49:49.237'),('91ae5f07-b662-11f1-b8de-202b20a0f17a',0,'91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL,'2026-09-22 16:49:49.237','2026-09-22 16:49:49.237'),('92900842-b4bc-11f1-a476-202b20a0f17a',0,'92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-20 14:29:03.098','2026-09-20 14:29:03.098'),('92907d74-b4bc-11f1-a476-202b20a0f17a',0,'92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,4,'4',NULL,NULL,'2026-09-20 14:29:03.099','2026-09-20 14:29:03.099'),('92907d76-b4bc-11f1-a476-202b20a0f17a',0,'92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-20 14:29:03.099','2026-09-20 14:29:03.099'),('92907d78-b4bc-11f1-a476-202b20a0f17a',0,'92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-20 14:29:03.099','2026-09-20 14:29:03.099'),('92907d7a-b4bc-11f1-a476-202b20a0f17a',0,'92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-20 14:29:03.099','2026-09-20 14:29:03.099'),('92907d7c-b4bc-11f1-a476-202b20a0f17a',0,'92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL,'2026-09-20 14:29:03.099','2026-09-20 14:29:03.099'),('97fc0dc6-b272-11f1-ad93-202b20a0f17a',0,'383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,'approved','boolean',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2026-09-17 16:34:27.109','2026-09-17 16:34:27.109'),('97fc34d8-b272-11f1-ad93-202b20a0f17a',0,'383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,'comment','string',NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL,'2026-09-17 16:34:27.110','2026-09-17 16:34:27.110'),('988cdc21-b272-11f1-ad93-202b20a0f17a',0,'62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,'approved','boolean',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2026-09-17 16:34:28.058','2026-09-17 16:34:28.058'),('988d0333-b272-11f1-ad93-202b20a0f17a',0,'62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,'comment','string',NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL,'2026-09-17 16:34:28.059','2026-09-17 16:34:28.059'),('99171acc-b272-11f1-ad93-202b20a0f17a',0,'63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,'approved','boolean',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2026-09-17 16:34:28.964','2026-09-17 16:34:28.964'),('99171ace-b272-11f1-ad93-202b20a0f17a',0,'63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,'comment','string',NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL,'2026-09-17 16:34:28.964','2026-09-17 16:34:28.964'),('9a819580-b338-11f1-a240-202b20a0f17a',0,'d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,'approved','boolean',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2026-09-18 16:11:51.692','2026-09-18 16:11:51.692'),('9a819581-b338-11f1-a240-202b20a0f17a',0,'d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,'comment','string',NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL,'2026-09-18 16:11:51.692','2026-09-18 16:11:51.692'),('9a954155-b4bc-11f1-a476-202b20a0f17a',0,'92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,'approved','boolean',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2026-09-20 14:29:16.552','2026-09-20 14:29:16.552'),('9a958f77-b4bc-11f1-a476-202b20a0f17a',0,'92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,'comment','string',NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL,'2026-09-20 14:29:16.554','2026-09-20 14:29:16.554'),('9c581508-b272-11f1-ad93-202b20a0f17a',0,'9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-17 16:34:34.423','2026-09-17 16:34:34.423'),('9c58150a-b272-11f1-ad93-202b20a0f17a',0,'9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:34:34.423','2026-09-17 16:34:34.423'),('9c58150c-b272-11f1-ad93-202b20a0f17a',0,'9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL,'2026-09-17 16:34:34.423','2026-09-17 16:34:34.423'),('9c58150e-b272-11f1-ad93-202b20a0f17a',0,'9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-17 16:34:34.423','2026-09-17 16:34:34.423'),('9c581510-b272-11f1-ad93-202b20a0f17a',0,'9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-17 16:34:34.423','2026-09-17 16:34:34.423'),('9c581512-b272-11f1-ad93-202b20a0f17a',0,'9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL,'2026-09-17 16:34:34.423','2026-09-17 16:34:34.423'),('a49797fb-b272-11f1-ad93-202b20a0f17a',0,'9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,'approved','boolean',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2026-09-17 16:34:48.261','2026-09-17 16:34:48.261'),('a49797fd-b272-11f1-ad93-202b20a0f17a',0,'9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,'comment','string',NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL,'2026-09-17 16:34:48.261','2026-09-17 16:34:48.261'),('a607f0e7-b272-11f1-ad93-202b20a0f17a',0,'a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-17 16:34:50.675','2026-09-17 16:34:50.675'),('a607f0e9-b272-11f1-ad93-202b20a0f17a',0,'a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:34:50.675','2026-09-17 16:34:50.675'),('a607f0eb-b272-11f1-ad93-202b20a0f17a',0,'a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL,'2026-09-17 16:34:50.675','2026-09-17 16:34:50.675'),('a607f0ed-b272-11f1-ad93-202b20a0f17a',0,'a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-17 16:34:50.675','2026-09-17 16:34:50.675'),('a607f0ef-b272-11f1-ad93-202b20a0f17a',0,'a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-17 16:34:50.675','2026-09-17 16:34:50.675'),('a6088d31-b272-11f1-ad93-202b20a0f17a',0,'a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL,'2026-09-17 16:34:50.679','2026-09-17 16:34:50.679'),('c651c7ab-b272-11f1-ad93-202b20a0f17a',0,'c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-17 16:35:44.846','2026-09-17 16:35:44.846'),('c651c7ad-b272-11f1-ad93-202b20a0f17a',0,'c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:35:44.846','2026-09-17 16:35:44.846'),('c651c7af-b272-11f1-ad93-202b20a0f17a',0,'c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL,'2026-09-17 16:35:44.846','2026-09-17 16:35:44.846'),('c651c7b1-b272-11f1-ad93-202b20a0f17a',0,'c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-17 16:35:44.846','2026-09-17 16:35:44.846'),('c651c7b3-b272-11f1-ad93-202b20a0f17a',0,'c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-17 16:35:44.846','2026-09-17 16:35:44.846'),('c651c7b5-b272-11f1-ad93-202b20a0f17a',0,'c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL,'2026-09-17 16:35:44.846','2026-09-17 16:35:44.846'),('cb7f32ea-b337-11f1-a240-202b20a0f17a',0,'cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-18 16:06:04.388','2026-09-18 16:06:04.388'),('cb7f32eb-b337-11f1-a240-202b20a0f17a',0,'cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL,'2026-09-18 16:06:04.388','2026-09-18 16:06:04.388'),('cb7f32ec-b337-11f1-a240-202b20a0f17a',0,'cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-18 16:06:04.388','2026-09-18 16:06:04.388'),('cb7f32ed-b337-11f1-a240-202b20a0f17a',0,'cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-18 16:06:04.388','2026-09-18 16:06:04.388'),('cb7f32ee-b337-11f1-a240-202b20a0f17a',0,'cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-18 16:06:04.388','2026-09-18 16:06:04.388'),('cb7f32ef-b337-11f1-a240-202b20a0f17a',0,'cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL,'2026-09-18 16:06:04.388','2026-09-18 16:06:04.388'),('ce154cb8-b4c7-11f1-bea6-202b20a0f17a',0,'82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,'approved','boolean',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2026-09-20 15:49:27.419','2026-09-20 15:49:27.419'),('ce1573ca-b4c7-11f1-bea6-202b20a0f17a',0,'82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,'comment','string',NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL,'2026-09-20 15:49:27.421','2026-09-20 15:49:27.421'),('d58c8daf-b272-11f1-ad93-202b20a0f17a',0,'d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-17 16:36:10.397','2026-09-17 16:36:10.397'),('d58c8db1-b272-11f1-ad93-202b20a0f17a',0,'d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:36:10.397','2026-09-17 16:36:10.397'),('d58c8db3-b272-11f1-ad93-202b20a0f17a',0,'d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL,'2026-09-17 16:36:10.397','2026-09-17 16:36:10.397'),('d58c8db5-b272-11f1-ad93-202b20a0f17a',0,'d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-17 16:36:10.397','2026-09-17 16:36:10.397'),('d58c8db7-b272-11f1-ad93-202b20a0f17a',0,'d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-17 16:36:10.397','2026-09-17 16:36:10.397'),('d58c8db9-b272-11f1-ad93-202b20a0f17a',0,'d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL,'2026-09-17 16:36:10.398','2026-09-17 16:36:10.398'),('edc46477-b337-11f1-a240-202b20a0f17a',0,'cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,'approved','boolean',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,'2026-09-18 16:07:01.884','2026-09-18 16:07:01.884'),('edc46478-b337-11f1-a240-202b20a0f17a',0,'cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,'comment','string',NULL,NULL,NULL,NULL,NULL,NULL,'??',NULL,NULL,'2026-09-18 16:07:01.884','2026-09-18 16:07:01.884'),('fd9a85a4-b4c7-11f1-bea6-202b20a0f17a',0,'fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,'tenantId','string',NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL,'2026-09-20 15:50:47.145','2026-09-20 15:50:47.145'),('fd9a85a6-b4c7-11f1-bea6-202b20a0f17a',0,'fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,'days','integer',NULL,NULL,NULL,NULL,NULL,3,'3',NULL,NULL,'2026-09-20 15:50:47.145','2026-09-20 15:50:47.145'),('fd9a85a8-b4c7-11f1-bea6-202b20a0f17a',0,'fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,'hr','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL,'2026-09-20 15:50:47.145','2026-09-20 15:50:47.145'),('fd9a85aa-b4c7-11f1-bea6-202b20a0f17a',0,'fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,'deptLeader','string',NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL,'2026-09-20 15:50:47.145','2026-09-20 15:50:47.145'),('fd9a85ac-b4c7-11f1-bea6-202b20a0f17a',0,'fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,'director','string',NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL,'2026-09-20 15:50:47.145','2026-09-20 15:50:47.145'),('fd9a85ae-b4c7-11f1-bea6-202b20a0f17a',0,'fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,'applicant','string',NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL,'2026-09-20 15:50:47.145','2026-09-20 15:50:47.145');
/*!40000 ALTER TABLE `act_hi_varinst` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_id_bytearray`
--

DROP TABLE IF EXISTS `act_id_bytearray`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_id_bytearray` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `BYTES_` longblob,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_id_bytearray`
--

LOCK TABLES `act_id_bytearray` WRITE;
/*!40000 ALTER TABLE `act_id_bytearray` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_id_bytearray` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_id_group`
--

DROP TABLE IF EXISTS `act_id_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_id_group` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_id_group`
--

LOCK TABLES `act_id_group` WRITE;
/*!40000 ALTER TABLE `act_id_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_id_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_id_info`
--

DROP TABLE IF EXISTS `act_id_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_id_info` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `USER_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `VALUE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PASSWORD_` longblob,
  `PARENT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_id_info`
--

LOCK TABLES `act_id_info` WRITE;
/*!40000 ALTER TABLE `act_id_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_id_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_id_membership`
--

DROP TABLE IF EXISTS `act_id_membership`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_id_membership` (
  `USER_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `GROUP_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  PRIMARY KEY (`USER_ID_`,`GROUP_ID_`),
  KEY `ACT_FK_MEMB_GROUP` (`GROUP_ID_`),
  CONSTRAINT `ACT_FK_MEMB_GROUP` FOREIGN KEY (`GROUP_ID_`) REFERENCES `act_id_group` (`ID_`),
  CONSTRAINT `ACT_FK_MEMB_USER` FOREIGN KEY (`USER_ID_`) REFERENCES `act_id_user` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_id_membership`
--

LOCK TABLES `act_id_membership` WRITE;
/*!40000 ALTER TABLE `act_id_membership` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_id_membership` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_id_priv`
--

DROP TABLE IF EXISTS `act_id_priv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_id_priv` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `NAME_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  PRIMARY KEY (`ID_`),
  UNIQUE KEY `ACT_UNIQ_PRIV_NAME` (`NAME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_id_priv`
--

LOCK TABLES `act_id_priv` WRITE;
/*!40000 ALTER TABLE `act_id_priv` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_id_priv` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_id_priv_mapping`
--

DROP TABLE IF EXISTS `act_id_priv_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_id_priv_mapping` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `PRIV_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `GROUP_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_FK_PRIV_MAPPING` (`PRIV_ID_`),
  KEY `ACT_IDX_PRIV_USER` (`USER_ID_`),
  KEY `ACT_IDX_PRIV_GROUP` (`GROUP_ID_`),
  CONSTRAINT `ACT_FK_PRIV_MAPPING` FOREIGN KEY (`PRIV_ID_`) REFERENCES `act_id_priv` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_id_priv_mapping`
--

LOCK TABLES `act_id_priv_mapping` WRITE;
/*!40000 ALTER TABLE `act_id_priv_mapping` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_id_priv_mapping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_id_property`
--

DROP TABLE IF EXISTS `act_id_property`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_id_property` (
  `NAME_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `VALUE_` varchar(300) COLLATE utf8mb3_bin DEFAULT NULL,
  `REV_` int DEFAULT NULL,
  PRIMARY KEY (`NAME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_id_property`
--

LOCK TABLES `act_id_property` WRITE;
/*!40000 ALTER TABLE `act_id_property` DISABLE KEYS */;
INSERT INTO `act_id_property` VALUES ('schema.version','7.0.1.1',1);
/*!40000 ALTER TABLE `act_id_property` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_id_token`
--

DROP TABLE IF EXISTS `act_id_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_id_token` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `TOKEN_VALUE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TOKEN_DATE_` timestamp(3) NULL DEFAULT NULL,
  `IP_ADDRESS_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `USER_AGENT_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TOKEN_DATA_` varchar(2000) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_id_token`
--

LOCK TABLES `act_id_token` WRITE;
/*!40000 ALTER TABLE `act_id_token` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_id_token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_id_user`
--

DROP TABLE IF EXISTS `act_id_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_id_user` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `FIRST_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `LAST_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `DISPLAY_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `EMAIL_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PWD_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PICTURE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_id_user`
--

LOCK TABLES `act_id_user` WRITE;
/*!40000 ALTER TABLE `act_id_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_id_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_procdef_info`
--

DROP TABLE IF EXISTS `act_procdef_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_procdef_info` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `INFO_JSON_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  UNIQUE KEY `ACT_UNIQ_INFO_PROCDEF` (`PROC_DEF_ID_`),
  KEY `ACT_IDX_INFO_PROCDEF` (`PROC_DEF_ID_`),
  KEY `ACT_FK_INFO_JSON_BA` (`INFO_JSON_ID_`),
  CONSTRAINT `ACT_FK_INFO_JSON_BA` FOREIGN KEY (`INFO_JSON_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_INFO_PROCDEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_procdef_info`
--

LOCK TABLES `act_procdef_info` WRITE;
/*!40000 ALTER TABLE `act_procdef_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_procdef_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_re_deployment`
--

DROP TABLE IF EXISTS `act_re_deployment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_re_deployment` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  `DEPLOY_TIME_` timestamp(3) NULL DEFAULT NULL,
  `DERIVED_FROM_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `DERIVED_FROM_ROOT_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PARENT_DEPLOYMENT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ENGINE_VERSION_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_re_deployment`
--

LOCK TABLES `act_re_deployment` WRITE;
/*!40000 ALTER TABLE `act_re_deployment` DISABLE KEYS */;
INSERT INTO `act_re_deployment` VALUES ('11b22816-b272-11f1-ad93-202b20a0f17a','leaveApproval-tenant_a',NULL,NULL,'tenant_a','2026-09-17 08:30:41.810',NULL,NULL,'11b22816-b272-11f1-ad93-202b20a0f17a',NULL),('11c38d39-b272-11f1-ad93-202b20a0f17a','leaveApproval-tenant_b',NULL,NULL,'tenant_b','2026-09-17 08:30:41.924',NULL,NULL,'11c38d39-b272-11f1-ad93-202b20a0f17a',NULL),('55c36a17-b707-11f1-a03d-202b20a0f17a','SpringBootAutoDeployment',NULL,NULL,'','2026-09-23 04:29:15.662',NULL,NULL,'55c36a17-b707-11f1-a03d-202b20a0f17a',NULL),('b0b745b6-b337-11f1-a240-202b20a0f17a','SpringBootAutoDeployment',NULL,NULL,'','2026-09-18 08:05:19.450',NULL,NULL,'b0b745b6-b337-11f1-a240-202b20a0f17a',NULL),('bcdd8b21-b17d-11f1-b0e6-202b20a0f17a','SpringBootAutoDeployment',NULL,NULL,'','2026-09-16 03:21:42.284',NULL,NULL,'bcdd8b21-b17d-11f1-b0e6-202b20a0f17a',NULL);
/*!40000 ALTER TABLE `act_re_deployment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_re_model`
--

DROP TABLE IF EXISTS `act_re_model`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_re_model` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `LAST_UPDATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `VERSION_` int DEFAULT NULL,
  `META_INFO_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `DEPLOYMENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `EDITOR_SOURCE_VALUE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `EDITOR_SOURCE_EXTRA_VALUE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_FK_MODEL_SOURCE` (`EDITOR_SOURCE_VALUE_ID_`),
  KEY `ACT_FK_MODEL_SOURCE_EXTRA` (`EDITOR_SOURCE_EXTRA_VALUE_ID_`),
  KEY `ACT_FK_MODEL_DEPLOYMENT` (`DEPLOYMENT_ID_`),
  CONSTRAINT `ACT_FK_MODEL_DEPLOYMENT` FOREIGN KEY (`DEPLOYMENT_ID_`) REFERENCES `act_re_deployment` (`ID_`),
  CONSTRAINT `ACT_FK_MODEL_SOURCE` FOREIGN KEY (`EDITOR_SOURCE_VALUE_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_MODEL_SOURCE_EXTRA` FOREIGN KEY (`EDITOR_SOURCE_EXTRA_VALUE_ID_`) REFERENCES `act_ge_bytearray` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_re_model`
--

LOCK TABLES `act_re_model` WRITE;
/*!40000 ALTER TABLE `act_re_model` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_re_model` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_re_procdef`
--

DROP TABLE IF EXISTS `act_re_procdef`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_re_procdef` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `KEY_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `VERSION_` int NOT NULL,
  `DEPLOYMENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `RESOURCE_NAME_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `DGRM_RESOURCE_NAME_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `DESCRIPTION_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `HAS_START_FORM_KEY_` tinyint DEFAULT NULL,
  `HAS_GRAPHICAL_NOTATION_` tinyint DEFAULT NULL,
  `SUSPENSION_STATE_` int DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  `ENGINE_VERSION_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `DERIVED_FROM_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `DERIVED_FROM_ROOT_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `DERIVED_VERSION_` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID_`),
  UNIQUE KEY `ACT_UNIQ_PROCDEF` (`KEY_`,`VERSION_`,`DERIVED_VERSION_`,`TENANT_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_re_procdef`
--

LOCK TABLES `act_re_procdef` WRITE;
/*!40000 ALTER TABLE `act_re_procdef` DISABLE KEYS */;
INSERT INTO `act_re_procdef` VALUES ('leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',1,'http://gov.com/process','请假审批','leaveApproval',1,'11b22816-b272-11f1-ad93-202b20a0f17a','processes/leave-approval.bpmn20.xml',NULL,NULL,0,0,1,'tenant_a',NULL,NULL,NULL,0),('leaveApproval:1:11c5fe3b-b272-11f1-ad93-202b20a0f17a',1,'http://gov.com/process','请假审批','leaveApproval',1,'11c38d39-b272-11f1-ad93-202b20a0f17a','processes/leave-approval.bpmn20.xml',NULL,NULL,0,0,1,'tenant_b',NULL,NULL,NULL,0),('leaveApproval:1:bceef043-b17d-11f1-b0e6-202b20a0f17a',1,'http://gov.com/process','请假审批','leaveApproval',1,'bcdd8b21-b17d-11f1-b0e6-202b20a0f17a','D:\\pdf\\gov-micro-demo\\gov-application\\target\\classes\\processes\\leave-approval.bpmn20.xml',NULL,NULL,0,0,1,'',NULL,NULL,NULL,0),('leaveApproval:2:b0c3a1c8-b337-11f1-a240-202b20a0f17a',1,'http://gov.com/process','请假审批','leaveApproval',2,'b0b745b6-b337-11f1-a240-202b20a0f17a','D:\\pdf\\management\\gov-micro-demo\\gov-application\\target\\classes\\processes\\leave-approval.bpmn20.xml',NULL,NULL,0,0,1,'',NULL,NULL,NULL,0),('leaveApproval:3:55d1e909-b707-11f1-a03d-202b20a0f17a',1,'http://gov.com/process','请假审批','leaveApproval',3,'55c36a17-b707-11f1-a03d-202b20a0f17a','D:\\Government Affairs System\\gov-micro-demo\\gov-application\\target\\classes\\processes\\leave-approval.bpmn20.xml',NULL,NULL,0,0,1,'',NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `act_re_procdef` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ru_actinst`
--

DROP TABLE IF EXISTS `act_ru_actinst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ru_actinst` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT '1',
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `ACT_ID_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `CALL_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `ACT_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ACT_TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `ASSIGNEE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `START_TIME_` datetime(3) NOT NULL,
  `END_TIME_` datetime(3) DEFAULT NULL,
  `DURATION_` bigint DEFAULT NULL,
  `TRANSACTION_ORDER_` int DEFAULT NULL,
  `DELETE_REASON_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_RU_ACTI_START` (`START_TIME_`),
  KEY `ACT_IDX_RU_ACTI_END` (`END_TIME_`),
  KEY `ACT_IDX_RU_ACTI_PROC` (`PROC_INST_ID_`),
  KEY `ACT_IDX_RU_ACTI_PROC_ACT` (`PROC_INST_ID_`,`ACT_ID_`),
  KEY `ACT_IDX_RU_ACTI_EXEC` (`EXECUTION_ID_`),
  KEY `ACT_IDX_RU_ACTI_EXEC_ACT` (`EXECUTION_ID_`,`ACT_ID_`),
  KEY `ACT_IDX_RU_ACTI_TASK` (`TASK_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ru_actinst`
--

LOCK TABLES `act_ru_actinst` WRITE;
/*!40000 ALTER TABLE `act_ru_actinst` DISABLE KEYS */;
INSERT INTO `act_ru_actinst` VALUES ('166f13fa-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:30:49.759','2026-09-17 16:30:49.768',9,1,NULL,'tenant_a'),('1670728b-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:30:49.768','2026-09-17 16:30:49.768',0,2,NULL,'tenant_a'),('1670728c-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','1672203d-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:30:49.768','2026-09-17 16:31:34.960',45192,3,NULL,'tenant_a'),('1f6a1dbe-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:31:04.826','2026-09-17 16:31:04.826',0,1,NULL,'tenant_a'),('1f6a1dbf-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:31:04.826','2026-09-17 16:31:04.826',0,2,NULL,'tenant_a'),('1f6a1dc0-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','1f6a1dc1-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:31:04.826','2026-09-17 16:32:49.973',105147,3,NULL,'tenant_a'),('31603328-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:31:34.960','2026-09-17 16:31:34.960',0,1,NULL,'tenant_a'),('31603329-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-17 16:31:34.960','2026-09-17 16:31:34.968',8,2,NULL,'tenant_a'),('31616baa-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:31:34.968','2026-09-17 16:31:34.968',0,3,NULL,'tenant_a'),('31616bab-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13f9-b272-11f1-ad93-202b20a0f17a','directorTask','31616bac-b272-11f1-ad93-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-17 16:31:34.968',NULL,NULL,4,NULL,'tenant_a'),('383aa7dd-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:31:46.458','2026-09-17 16:31:46.458',0,1,NULL,'tenant_a'),('383aceee-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:31:46.459','2026-09-17 16:31:46.459',0,2,NULL,'tenant_a'),('383aceef-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','383acef0-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:31:46.459','2026-09-17 16:34:27.112',160653,3,NULL,'tenant_a'),('5a518a87-b58f-11f1-9502-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a518a86-b58f-11f1-9502-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-21 15:37:52.544','2026-09-21 15:37:52.547',3,1,NULL,'tenant_a'),('5a524dd8-b58f-11f1-9502-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a518a86-b58f-11f1-9502-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-21 15:37:52.549','2026-09-21 15:37:52.549',0,2,NULL,'tenant_a'),('5a524dd9-b58f-11f1-9502-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a518a86-b58f-11f1-9502-202b20a0f17a','deptLeaderTask','5a55d04a-b58f-11f1-9502-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-21 15:37:52.549',NULL,NULL,3,NULL,'tenant_a'),('5e16e2d7-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:32:49.977','2026-09-17 16:32:49.977',0,1,NULL,'tenant_a'),('5e1709e8-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-17 16:32:49.978','2026-09-17 16:32:49.978',0,2,NULL,'tenant_a'),('5e1709e9-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:32:49.978','2026-09-17 16:32:49.978',0,3,NULL,'tenant_a'),('5e1730fa-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1dbd-b272-11f1-ad93-202b20a0f17a','directorTask','5e1730fb-b272-11f1-ad93-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-17 16:32:49.979',NULL,NULL,4,NULL,'tenant_a'),('5e2551f5-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 12:18:44.214','2026-09-20 12:18:44.214',0,1,NULL,'tenant_a'),('5e25a016-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-20 12:18:44.216','2026-09-20 12:18:44.242',26,2,NULL,'tenant_a'),('5e2997b7-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 12:18:44.242','2026-09-20 12:18:44.242',0,3,NULL,'tenant_a'),('5e2997b8-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','directorTask','5e29bec9-b4aa-11f1-8fff-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-20 12:18:44.242',NULL,NULL,4,NULL,'tenant_a'),('5ee3c000-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 12:18:45.462','2026-09-20 12:18:45.462',0,1,NULL,'tenant_a'),('5ee3c001-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-20 12:18:45.462','2026-09-20 12:18:45.462',0,2,NULL,'tenant_a'),('5ee3c002-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 12:18:45.462','2026-09-20 12:18:45.462',0,3,NULL,'tenant_a'),('5ee3e713-b4aa-11f1-8fff-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','directorTask','5ee3e714-b4aa-11f1-8fff-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-20 12:18:45.463',NULL,NULL,4,NULL,'tenant_a'),('62dc0c1c-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:32:57.980','2026-09-17 16:32:57.980',0,1,NULL,'tenant_a'),('62dc0c1d-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:32:57.980','2026-09-17 16:32:57.980',0,2,NULL,'tenant_a'),('62dc0c1e-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','62dc0c1f-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:32:57.980','2026-09-17 16:34:28.059',90079,3,NULL,'tenant_a'),('63f607b0-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:32:59.828','2026-09-17 16:32:59.828',0,1,NULL,'tenant_a'),('63f607b1-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:32:59.828','2026-09-17 16:32:59.828',0,2,NULL,'tenant_a'),('63f607b2-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','63f607b3-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:32:59.828','2026-09-17 16:34:28.965',89137,3,NULL,'tenant_a'),('82c27772-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-20 15:47:21.047','2026-09-20 15:47:21.050',3,1,NULL,'tenant_a'),('82c339c3-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 15:47:21.052','2026-09-20 15:47:21.052',0,2,NULL,'tenant_a'),('82c339c4-b4c7-11f1-bea6-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','deptLeaderTask','82c69525-b4c7-11f1-bea6-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-20 15:47:21.052','2026-09-20 15:49:27.423',126371,3,NULL,'tenant_a'),('91ae861a-b662-11f1-b8de-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a','91ae8619-b662-11f1-b8de-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-22 16:49:49.238','2026-09-22 16:49:49.241',3,1,NULL,'tenant_a'),('91af225b-b662-11f1-b8de-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a','91ae8619-b662-11f1-b8de-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-22 16:49:49.242','2026-09-22 16:49:49.242',0,2,NULL,'tenant_a'),('91af225c-b662-11f1-b8de-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a','91ae8619-b662-11f1-b8de-202b20a0f17a','deptLeaderTask','91b27dbd-b662-11f1-b8de-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-22 16:49:49.242',NULL,NULL,3,NULL,'tenant_a'),('9290a48f-b4bc-11f1-a476-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-20 14:29:03.100','2026-09-20 14:29:03.104',4,1,NULL,'tenant_a'),('929167e0-b4bc-11f1-a476-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 14:29:03.105','2026-09-20 14:29:03.105',0,2,NULL,'tenant_a'),('929167e1-b4bc-11f1-a476-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','deptLeaderTask','92955f82-b4bc-11f1-a476-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-20 14:29:03.105','2026-09-20 14:29:16.558',13453,3,NULL,'tenant_a'),('97fcaa0a-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:27.113','2026-09-17 16:34:27.113',0,1,NULL,'tenant_a'),('97fcaa0b-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-17 16:34:27.113','2026-09-17 16:34:27.113',0,2,NULL,'tenant_a'),('97fcaa0c-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:27.113','2026-09-17 16:34:27.113',0,3,NULL,'tenant_a'),('97fcaa0d-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','383aa7dc-b272-11f1-ad93-202b20a0f17a','directorTask','97fcaa0e-b272-11f1-ad93-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-17 16:34:27.113',NULL,NULL,4,NULL,'tenant_a'),('988d7865-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:28.062','2026-09-17 16:34:28.062',0,1,NULL,'tenant_a'),('988d7866-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-17 16:34:28.062','2026-09-17 16:34:28.063',1,2,NULL,'tenant_a'),('988d9f77-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:28.063','2026-09-17 16:34:28.063',0,3,NULL,'tenant_a'),('988d9f78-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c1b-b272-11f1-ad93-202b20a0f17a','directorTask','988d9f79-b272-11f1-ad93-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-17 16:34:28.063',NULL,NULL,4,NULL,'tenant_a'),('991741e0-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:28.965','2026-09-17 16:34:28.965',0,1,NULL,'tenant_a'),('991741e1-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-17 16:34:28.965','2026-09-17 16:34:28.965',0,2,NULL,'tenant_a'),('991741e2-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:28.965','2026-09-17 16:34:28.965',0,3,NULL,'tenant_a'),('991741e3-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607af-b272-11f1-ad93-202b20a0f17a','directorTask','991741e4-b272-11f1-ad93-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-17 16:34:28.965',NULL,NULL,4,NULL,'tenant_a'),('9a831c22-b338-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-18 16:11:51.702','2026-09-18 16:11:51.702',0,1,NULL,'tenant_a'),('9a834333-b338-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-18 16:11:51.703','2026-09-18 16:11:51.703',0,2,NULL,'tenant_a'),('9a834334-b338-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-18 16:11:51.703','2026-09-18 16:11:51.703',0,3,NULL,'tenant_a'),('9a834335-b338-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','directorTask','9a834336-b338-11f1-a240-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-18 16:11:51.703',NULL,NULL,4,NULL,'tenant_a'),('9a9652c9-b4bc-11f1-a476-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 14:29:16.559','2026-09-20 14:29:16.559',0,1,NULL,'tenant_a'),('9a9652ca-b4bc-11f1-a476-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-20 14:29:16.559','2026-09-20 14:29:16.565',6,2,NULL,'tenant_a'),('9a973d2b-b4bc-11f1-a476-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 14:29:16.565','2026-09-20 14:29:16.565',0,3,NULL,'tenant_a'),('9a97643c-b4bc-11f1-a476-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','9290a48e-b4bc-11f1-a476-202b20a0f17a','directorTask','9a97643d-b4bc-11f1-a476-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-20 14:29:16.566',NULL,NULL,4,NULL,'tenant_a'),('9c581515-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:34:34.423','2026-09-17 16:34:34.423',0,1,NULL,'tenant_a'),('9c581516-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:34.423','2026-09-17 16:34:34.423',0,2,NULL,'tenant_a'),('9c581517-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','9c581518-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:34:34.423','2026-09-17 16:34:48.264',13841,3,NULL,'tenant_a'),('a4980d2f-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:48.264','2026-09-17 16:34:48.264',0,1,NULL,'tenant_a'),('a4980d30-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-17 16:34:48.264','2026-09-17 16:34:48.264',0,2,NULL,'tenant_a'),('a4980d31-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:48.264','2026-09-17 16:34:48.264',0,3,NULL,'tenant_a'),('a4980d32-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','9c581514-b272-11f1-ad93-202b20a0f17a','directorTask','a4980d33-b272-11f1-ad93-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-17 16:34:48.264',NULL,NULL,4,NULL,'tenant_a'),('a6088d34-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:34:50.679','2026-09-17 16:34:50.679',0,1,NULL,'tenant_a'),('a6088d35-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:34:50.679','2026-09-17 16:34:50.679',0,2,NULL,'tenant_a'),('a6088d36-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','a6088d33-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','a6088d37-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:34:50.679','2026-09-20 12:18:45.461',243834782,3,NULL,'tenant_a'),('c651c7b8-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:35:44.846','2026-09-17 16:35:44.847',1,1,NULL,'tenant_a'),('c651eec9-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:35:44.847','2026-09-17 16:35:44.847',0,2,NULL,'tenant_a'),('c651eeca-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7b7-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','c651eecb-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:35:44.847','2026-09-20 12:18:44.208',243779361,3,NULL,'tenant_a'),('cb7f32f1-b337-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-18 16:06:04.388','2026-09-18 16:06:04.388',0,1,NULL,'tenant_a'),('cb7f32f2-b337-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-18 16:06:04.388','2026-09-18 16:06:04.388',0,2,NULL,'tenant_a'),('cb7f32f3-b337-11f1-a240-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','deptLeaderTask','cb826744-b337-11f1-a240-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-18 16:06:04.388','2026-09-18 16:07:01.884',57496,3,NULL,'tenant_a'),('ce16100c-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 15:49:27.424','2026-09-20 15:49:27.424',0,1,NULL,'tenant_a'),('ce16100d-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-20 15:49:27.424','2026-09-20 15:49:27.430',6,2,NULL,'tenant_a'),('ce16fa6e-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 15:49:27.430','2026-09-20 15:49:27.430',0,3,NULL,'tenant_a'),('ce17217f-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c27771-b4c7-11f1-bea6-202b20a0f17a','directorTask','ce172180-b4c7-11f1-bea6-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-20 15:49:27.431',NULL,NULL,4,NULL,'tenant_a'),('d58cb4cc-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-17 16:36:10.398','2026-09-17 16:36:10.398',0,1,NULL,'tenant_a'),('d58cb4cd-b272-11f1-ad93-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-17 16:36:10.398','2026-09-17 16:36:10.398',0,2,NULL,'tenant_a'),('d58cb4ce-b272-11f1-ad93-202b20a0f17a',2,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58cb4cb-b272-11f1-ad93-202b20a0f17a','deptLeaderTask','d58cb4cf-b272-11f1-ad93-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-17 16:36:10.398','2026-09-18 16:11:51.702',84941304,3,NULL,'tenant_a'),('edc46479-b337-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','flow2',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-18 16:07:01.884','2026-09-18 16:07:01.884',0,1,NULL,'tenant_a'),('edc575ea-b337-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','decision',NULL,NULL,'是否需要上级审批','exclusiveGateway',NULL,'2026-09-18 16:07:01.891','2026-09-18 16:07:01.894',3,2,NULL,'tenant_a'),('edc5eb1b-b337-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','flow4',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-18 16:07:01.894','2026-09-18 16:07:01.894',0,3,NULL,'tenant_a'),('edc5eb1c-b337-11f1-a240-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32f0-b337-11f1-a240-202b20a0f17a','directorTask','edc5eb1d-b337-11f1-a240-202b20a0f17a',NULL,'分管领导审批','userTask','WangWu','2026-09-18 16:07:01.894',NULL,NULL,4,NULL,'tenant_a'),('fd9a85b1-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85b0-b4c7-11f1-bea6-202b20a0f17a','start',NULL,NULL,'发起申请','startEvent',NULL,'2026-09-20 15:50:47.145','2026-09-20 15:50:47.145',0,1,NULL,'tenant_a'),('fd9a85b2-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85b0-b4c7-11f1-bea6-202b20a0f17a','flow1',NULL,NULL,NULL,'sequenceFlow',NULL,'2026-09-20 15:50:47.145','2026-09-20 15:50:47.145',0,2,NULL,'tenant_a'),('fd9a85b3-b4c7-11f1-bea6-202b20a0f17a',1,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85b0-b4c7-11f1-bea6-202b20a0f17a','deptLeaderTask','fd9a85b4-b4c7-11f1-bea6-202b20a0f17a',NULL,'部门领导审批','userTask','LiSi','2026-09-20 15:50:47.145',NULL,NULL,3,NULL,'tenant_a');
/*!40000 ALTER TABLE `act_ru_actinst` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ru_deadletter_job`
--

DROP TABLE IF EXISTS `act_ru_deadletter_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ru_deadletter_job` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `EXCLUSIVE_` tinyint(1) DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS_INSTANCE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CORRELATION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_STACK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_MSG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `DUEDATE_` timestamp(3) NULL DEFAULT NULL,
  `REPEAT_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_CFG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `CUSTOM_VALUES_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_DEADLETTER_JOB_EXCEPTION_STACK_ID` (`EXCEPTION_STACK_ID_`),
  KEY `ACT_IDX_DEADLETTER_JOB_CUSTOM_VALUES_ID` (`CUSTOM_VALUES_ID_`),
  KEY `ACT_IDX_DEADLETTER_JOB_CORRELATION_ID` (`CORRELATION_ID_`),
  KEY `ACT_IDX_DJOB_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_DJOB_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_DJOB_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_FK_DEADLETTER_JOB_EXECUTION` (`EXECUTION_ID_`),
  KEY `ACT_FK_DEADLETTER_JOB_PROCESS_INSTANCE` (`PROCESS_INSTANCE_ID_`),
  KEY `ACT_FK_DEADLETTER_JOB_PROC_DEF` (`PROC_DEF_ID_`),
  CONSTRAINT `ACT_FK_DEADLETTER_JOB_CUSTOM_VALUES` FOREIGN KEY (`CUSTOM_VALUES_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_DEADLETTER_JOB_EXCEPTION` FOREIGN KEY (`EXCEPTION_STACK_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_DEADLETTER_JOB_EXECUTION` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_DEADLETTER_JOB_PROC_DEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_DEADLETTER_JOB_PROCESS_INSTANCE` FOREIGN KEY (`PROCESS_INSTANCE_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ru_deadletter_job`
--

LOCK TABLES `act_ru_deadletter_job` WRITE;
/*!40000 ALTER TABLE `act_ru_deadletter_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_ru_deadletter_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ru_entitylink`
--

DROP TABLE IF EXISTS `act_ru_entitylink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ru_entitylink` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CREATE_TIME_` datetime(3) DEFAULT NULL,
  `LINK_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PARENT_ELEMENT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `REF_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `REF_SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `REF_SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ROOT_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ROOT_SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `HIERARCHY_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_ENT_LNK_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`,`LINK_TYPE_`),
  KEY `ACT_IDX_ENT_LNK_REF_SCOPE` (`REF_SCOPE_ID_`,`REF_SCOPE_TYPE_`,`LINK_TYPE_`),
  KEY `ACT_IDX_ENT_LNK_ROOT_SCOPE` (`ROOT_SCOPE_ID_`,`ROOT_SCOPE_TYPE_`,`LINK_TYPE_`),
  KEY `ACT_IDX_ENT_LNK_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`,`LINK_TYPE_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ru_entitylink`
--

LOCK TABLES `act_ru_entitylink` WRITE;
/*!40000 ALTER TABLE `act_ru_entitylink` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_ru_entitylink` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ru_event_subscr`
--

DROP TABLE IF EXISTS `act_ru_event_subscr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ru_event_subscr` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `EVENT_TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `EVENT_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `ACTIVITY_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `CONFIGURATION_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATED_` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `LOCK_TIME_` timestamp(3) NULL DEFAULT NULL,
  `LOCK_OWNER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_EVENT_SUBSCR_CONFIG_` (`CONFIGURATION_`),
  KEY `ACT_IDX_EVENT_SUBSCR_SCOPEREF_` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_FK_EVENT_EXEC` (`EXECUTION_ID_`),
  CONSTRAINT `ACT_FK_EVENT_EXEC` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ru_event_subscr`
--

LOCK TABLES `act_ru_event_subscr` WRITE;
/*!40000 ALTER TABLE `act_ru_event_subscr` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_ru_event_subscr` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ru_execution`
--

DROP TABLE IF EXISTS `act_ru_execution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ru_execution` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `BUSINESS_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PARENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUPER_EXEC_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `IS_ACTIVE_` tinyint DEFAULT NULL,
  `IS_CONCURRENT_` tinyint DEFAULT NULL,
  `IS_SCOPE_` tinyint DEFAULT NULL,
  `IS_EVENT_SCOPE_` tinyint DEFAULT NULL,
  `IS_MI_ROOT_` tinyint DEFAULT NULL,
  `SUSPENSION_STATE_` int DEFAULT NULL,
  `CACHED_ENT_STATE_` int DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `START_ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `START_TIME_` datetime(3) DEFAULT NULL,
  `START_USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `LOCK_TIME_` timestamp(3) NULL DEFAULT NULL,
  `LOCK_OWNER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `IS_COUNT_ENABLED_` tinyint DEFAULT NULL,
  `EVT_SUBSCR_COUNT_` int DEFAULT NULL,
  `TASK_COUNT_` int DEFAULT NULL,
  `JOB_COUNT_` int DEFAULT NULL,
  `TIMER_JOB_COUNT_` int DEFAULT NULL,
  `SUSP_JOB_COUNT_` int DEFAULT NULL,
  `DEADLETTER_JOB_COUNT_` int DEFAULT NULL,
  `EXTERNAL_WORKER_JOB_COUNT_` int DEFAULT NULL,
  `VAR_COUNT_` int DEFAULT NULL,
  `ID_LINK_COUNT_` int DEFAULT NULL,
  `CALLBACK_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CALLBACK_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `REFERENCE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `REFERENCE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROPAGATED_STAGE_INST_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `BUSINESS_STATUS_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_EXEC_BUSKEY` (`BUSINESS_KEY_`),
  KEY `ACT_IDC_EXEC_ROOT` (`ROOT_PROC_INST_ID_`),
  KEY `ACT_IDX_EXEC_REF_ID_` (`REFERENCE_ID_`),
  KEY `ACT_FK_EXE_PROCINST` (`PROC_INST_ID_`),
  KEY `ACT_FK_EXE_PARENT` (`PARENT_ID_`),
  KEY `ACT_FK_EXE_SUPER` (`SUPER_EXEC_`),
  KEY `ACT_FK_EXE_PROCDEF` (`PROC_DEF_ID_`),
  CONSTRAINT `ACT_FK_EXE_PARENT` FOREIGN KEY (`PARENT_ID_`) REFERENCES `act_ru_execution` (`ID_`) ON DELETE CASCADE,
  CONSTRAINT `ACT_FK_EXE_PROCDEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_EXE_PROCINST` FOREIGN KEY (`PROC_INST_ID_`) REFERENCES `act_ru_execution` (`ID_`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `ACT_FK_EXE_SUPER` FOREIGN KEY (`SUPER_EXEC_`) REFERENCES `act_ru_execution` (`ID_`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ru_execution`
--

LOCK TABLES `act_ru_execution` WRITE;
/*!40000 ALTER TABLE `act_ru_execution` DISABLE KEYS */;
INSERT INTO `act_ru_execution` VALUES ('166f13ec-b272-11f1-ad93-202b20a0f17a',1,'166f13ec-b272-11f1-ad93-202b20a0f17a','LEAVE-1789633849738',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-17 16:30:49.759',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('166f13f9-b272-11f1-ad93-202b20a0f17a',2,'166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,'166f13ec-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'166f13ec-b272-11f1-ad93-202b20a0f17a','directorTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:30:49.759',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('1f6a1db0-b272-11f1-ad93-202b20a0f17a',1,'1f6a1db0-b272-11f1-ad93-202b20a0f17a','LEAVE-1789633864817',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-17 16:31:04.826',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('1f6a1dbd-b272-11f1-ad93-202b20a0f17a',2,'1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,'1f6a1db0-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'1f6a1db0-b272-11f1-ad93-202b20a0f17a','directorTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:31:04.826',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('383a59af-b272-11f1-ad93-202b20a0f17a',1,'383a59af-b272-11f1-ad93-202b20a0f17a','LEAVE-1789633906448',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'383a59af-b272-11f1-ad93-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-17 16:31:46.456',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('383aa7dc-b272-11f1-ad93-202b20a0f17a',2,'383a59af-b272-11f1-ad93-202b20a0f17a',NULL,'383a59af-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'383a59af-b272-11f1-ad93-202b20a0f17a','directorTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:31:46.458',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('5a50ee39-b58f-11f1-9502-202b20a0f17a',1,'5a50ee39-b58f-11f1-9502-202b20a0f17a','12',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-21 15:37:52.540',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('5a518a86-b58f-11f1-9502-202b20a0f17a',1,'5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,'5a50ee39-b58f-11f1-9502-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'5a50ee39-b58f-11f1-9502-202b20a0f17a','deptLeaderTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-21 15:37:52.544',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('62dc0c0e-b272-11f1-ad93-202b20a0f17a',1,'62dc0c0e-b272-11f1-ad93-202b20a0f17a','LEAVE-1789633977971',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-17 16:32:57.980',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('62dc0c1b-b272-11f1-ad93-202b20a0f17a',2,'62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,'62dc0c0e-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'62dc0c0e-b272-11f1-ad93-202b20a0f17a','directorTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:32:57.980',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('63f607a2-b272-11f1-ad93-202b20a0f17a',1,'63f607a2-b272-11f1-ad93-202b20a0f17a','LEAVE-1789633979826',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-17 16:32:59.828',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('63f607af-b272-11f1-ad93-202b20a0f17a',2,'63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,'63f607a2-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'63f607a2-b272-11f1-ad93-202b20a0f17a','directorTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:32:59.828',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('82c1db24-b4c7-11f1-bea6-202b20a0f17a',1,'82c1db24-b4c7-11f1-bea6-202b20a0f17a','11',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-20 15:47:21.043',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('82c27771-b4c7-11f1-bea6-202b20a0f17a',2,'82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,'82c1db24-b4c7-11f1-bea6-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'82c1db24-b4c7-11f1-bea6-202b20a0f17a','directorTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-20 15:47:21.047',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('91adc2bc-b662-11f1-b8de-202b20a0f17a',1,'91adc2bc-b662-11f1-b8de-202b20a0f17a','13',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-22 16:49:49.233',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('91ae8619-b662-11f1-b8de-202b20a0f17a',1,'91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,'91adc2bc-b662-11f1-b8de-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'91adc2bc-b662-11f1-b8de-202b20a0f17a','deptLeaderTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-22 16:49:49.237',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('92900841-b4bc-11f1-a476-202b20a0f17a',1,'92900841-b4bc-11f1-a476-202b20a0f17a','LEAVE-1789885728459',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'92900841-b4bc-11f1-a476-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-20 14:29:03.096',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('9290a48e-b4bc-11f1-a476-202b20a0f17a',2,'92900841-b4bc-11f1-a476-202b20a0f17a',NULL,'92900841-b4bc-11f1-a476-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'92900841-b4bc-11f1-a476-202b20a0f17a','directorTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-20 14:29:03.099',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('9c581507-b272-11f1-ad93-202b20a0f17a',1,'9c581507-b272-11f1-ad93-202b20a0f17a','LEAVE-1789634074418',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'9c581507-b272-11f1-ad93-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-17 16:34:34.423',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('9c581514-b272-11f1-ad93-202b20a0f17a',2,'9c581507-b272-11f1-ad93-202b20a0f17a',NULL,'9c581507-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'9c581507-b272-11f1-ad93-202b20a0f17a','directorTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:34:34.423',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('a607f0e6-b272-11f1-ad93-202b20a0f17a',1,'a607f0e6-b272-11f1-ad93-202b20a0f17a','LEAVE-1789634090669',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-17 16:34:50.675',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('a6088d33-b272-11f1-ad93-202b20a0f17a',2,'a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,'a607f0e6-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'a607f0e6-b272-11f1-ad93-202b20a0f17a','directorTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:34:50.679',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('c651c7aa-b272-11f1-ad93-202b20a0f17a',1,'c651c7aa-b272-11f1-ad93-202b20a0f17a','LEAVE-1789634144837',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-17 16:35:44.846',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('c651c7b7-b272-11f1-ad93-202b20a0f17a',2,'c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,'c651c7aa-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'c651c7aa-b272-11f1-ad93-202b20a0f17a','directorTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:35:44.846',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('cb7f32e9-b337-11f1-a240-202b20a0f17a',1,'cb7f32e9-b337-11f1-a240-202b20a0f17a','LEAVE-20260918160603',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-18 16:06:04.388',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('cb7f32f0-b337-11f1-a240-202b20a0f17a',2,'cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,'cb7f32e9-b337-11f1-a240-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'cb7f32e9-b337-11f1-a240-202b20a0f17a','directorTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-18 16:06:04.388',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('d58c8dae-b272-11f1-ad93-202b20a0f17a',1,'d58c8dae-b272-11f1-ad93-202b20a0f17a','LEAVE-1789634170388',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-17 16:36:10.397',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('d58cb4cb-b272-11f1-ad93-202b20a0f17a',2,'d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,'d58c8dae-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'d58c8dae-b272-11f1-ad93-202b20a0f17a','directorTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-17 16:36:10.398',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',1,'fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','LEAVE-1789890643223',NULL,'leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,1,0,1,0,0,1,NULL,'tenant_a',NULL,'start','2026-09-20 15:50:47.144',NULL,NULL,NULL,1,0,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL),('fd9a85b0-b4c7-11f1-bea6-202b20a0f17a',1,'fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,'fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,'fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','deptLeaderTask',1,0,0,0,0,1,NULL,'tenant_a',NULL,NULL,'2026-09-20 15:50:47.145',NULL,NULL,NULL,1,0,1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `act_ru_execution` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ru_external_job`
--

DROP TABLE IF EXISTS `act_ru_external_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ru_external_job` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `LOCK_EXP_TIME_` timestamp(3) NULL DEFAULT NULL,
  `LOCK_OWNER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCLUSIVE_` tinyint(1) DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS_INSTANCE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CORRELATION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `RETRIES_` int DEFAULT NULL,
  `EXCEPTION_STACK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_MSG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `DUEDATE_` timestamp(3) NULL DEFAULT NULL,
  `REPEAT_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_CFG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `CUSTOM_VALUES_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_EXTERNAL_JOB_EXCEPTION_STACK_ID` (`EXCEPTION_STACK_ID_`),
  KEY `ACT_IDX_EXTERNAL_JOB_CUSTOM_VALUES_ID` (`CUSTOM_VALUES_ID_`),
  KEY `ACT_IDX_EXTERNAL_JOB_CORRELATION_ID` (`CORRELATION_ID_`),
  KEY `ACT_IDX_EJOB_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_EJOB_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_EJOB_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  CONSTRAINT `ACT_FK_EXTERNAL_JOB_CUSTOM_VALUES` FOREIGN KEY (`CUSTOM_VALUES_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_EXTERNAL_JOB_EXCEPTION` FOREIGN KEY (`EXCEPTION_STACK_ID_`) REFERENCES `act_ge_bytearray` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ru_external_job`
--

LOCK TABLES `act_ru_external_job` WRITE;
/*!40000 ALTER TABLE `act_ru_external_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_ru_external_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ru_history_job`
--

DROP TABLE IF EXISTS `act_ru_history_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ru_history_job` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `LOCK_EXP_TIME_` timestamp(3) NULL DEFAULT NULL,
  `LOCK_OWNER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `RETRIES_` int DEFAULT NULL,
  `EXCEPTION_STACK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_MSG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_CFG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `CUSTOM_VALUES_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `ADV_HANDLER_CFG_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ru_history_job`
--

LOCK TABLES `act_ru_history_job` WRITE;
/*!40000 ALTER TABLE `act_ru_history_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_ru_history_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ru_identitylink`
--

DROP TABLE IF EXISTS `act_ru_identitylink`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ru_identitylink` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `GROUP_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_IDENT_LNK_USER` (`USER_ID_`),
  KEY `ACT_IDX_IDENT_LNK_GROUP` (`GROUP_ID_`),
  KEY `ACT_IDX_IDENT_LNK_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_IDENT_LNK_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_IDENT_LNK_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_ATHRZ_PROCEDEF` (`PROC_DEF_ID_`),
  KEY `ACT_FK_TSKASS_TASK` (`TASK_ID_`),
  KEY `ACT_FK_IDL_PROCINST` (`PROC_INST_ID_`),
  CONSTRAINT `ACT_FK_ATHRZ_PROCEDEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_IDL_PROCINST` FOREIGN KEY (`PROC_INST_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_TSKASS_TASK` FOREIGN KEY (`TASK_ID_`) REFERENCES `act_ru_task` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ru_identitylink`
--

LOCK TABLES `act_ru_identitylink` WRITE;
/*!40000 ALTER TABLE `act_ru_identitylink` DISABLE KEYS */;
INSERT INTO `act_ru_identitylink` VALUES ('1672203f-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('1f6a1dc3-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('31616bae-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','WangWu',NULL,'166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('383acef2-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('5a566c8c-b58f-11f1-9502-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('5e1730fd-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','WangWu',NULL,'1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('5e2af74b-b4aa-11f1-8fff-202b20a0f17a',1,NULL,'participant','WangWu',NULL,'c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('5ee40e26-b4aa-11f1-8fff-202b20a0f17a',1,NULL,'participant','WangWu',NULL,'a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('62dc0c21-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('63f607b5-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('82c75877-b4c7-11f1-bea6-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('91b3410f-b662-11f1-b8de-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('9295fbc4-b4bc-11f1-a476-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('97fcaa10-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','WangWu',NULL,'383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('988d9f7b-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','WangWu',NULL,'62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('9917de26-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','WangWu',NULL,'63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('9a834338-b338-11f1-a240-202b20a0f17a',1,NULL,'participant','WangWu',NULL,'d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('9a978b4f-b4bc-11f1-a476-202b20a0f17a',1,NULL,'participant','WangWu',NULL,'92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('9c58151a-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('a4980d35-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','WangWu',NULL,'9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('a6088d39-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('c651eecd-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('cb826746-b337-11f1-a240-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('ce176fa2-b4c7-11f1-bea6-202b20a0f17a',1,NULL,'participant','WangWu',NULL,'82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('d58cb4d1-b272-11f1-ad93-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('edc5eb1f-b337-11f1-a240-202b20a0f17a',1,NULL,'participant','WangWu',NULL,'cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL,NULL),('fd9ad3d6-b4c7-11f1-bea6-202b20a0f17a',1,NULL,'participant','LiSi',NULL,'fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `act_ru_identitylink` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ru_job`
--

DROP TABLE IF EXISTS `act_ru_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ru_job` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `LOCK_EXP_TIME_` timestamp(3) NULL DEFAULT NULL,
  `LOCK_OWNER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCLUSIVE_` tinyint(1) DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS_INSTANCE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CORRELATION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `RETRIES_` int DEFAULT NULL,
  `EXCEPTION_STACK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_MSG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `DUEDATE_` timestamp(3) NULL DEFAULT NULL,
  `REPEAT_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_CFG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `CUSTOM_VALUES_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_JOB_EXCEPTION_STACK_ID` (`EXCEPTION_STACK_ID_`),
  KEY `ACT_IDX_JOB_CUSTOM_VALUES_ID` (`CUSTOM_VALUES_ID_`),
  KEY `ACT_IDX_JOB_CORRELATION_ID` (`CORRELATION_ID_`),
  KEY `ACT_IDX_JOB_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_JOB_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_JOB_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_FK_JOB_EXECUTION` (`EXECUTION_ID_`),
  KEY `ACT_FK_JOB_PROCESS_INSTANCE` (`PROCESS_INSTANCE_ID_`),
  KEY `ACT_FK_JOB_PROC_DEF` (`PROC_DEF_ID_`),
  CONSTRAINT `ACT_FK_JOB_CUSTOM_VALUES` FOREIGN KEY (`CUSTOM_VALUES_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_JOB_EXCEPTION` FOREIGN KEY (`EXCEPTION_STACK_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_JOB_EXECUTION` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_JOB_PROC_DEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_JOB_PROCESS_INSTANCE` FOREIGN KEY (`PROCESS_INSTANCE_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ru_job`
--

LOCK TABLES `act_ru_job` WRITE;
/*!40000 ALTER TABLE `act_ru_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_ru_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ru_suspended_job`
--

DROP TABLE IF EXISTS `act_ru_suspended_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ru_suspended_job` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `EXCLUSIVE_` tinyint(1) DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS_INSTANCE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CORRELATION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `RETRIES_` int DEFAULT NULL,
  `EXCEPTION_STACK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_MSG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `DUEDATE_` timestamp(3) NULL DEFAULT NULL,
  `REPEAT_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_CFG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `CUSTOM_VALUES_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_SUSPENDED_JOB_EXCEPTION_STACK_ID` (`EXCEPTION_STACK_ID_`),
  KEY `ACT_IDX_SUSPENDED_JOB_CUSTOM_VALUES_ID` (`CUSTOM_VALUES_ID_`),
  KEY `ACT_IDX_SUSPENDED_JOB_CORRELATION_ID` (`CORRELATION_ID_`),
  KEY `ACT_IDX_SJOB_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_SJOB_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_SJOB_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_FK_SUSPENDED_JOB_EXECUTION` (`EXECUTION_ID_`),
  KEY `ACT_FK_SUSPENDED_JOB_PROCESS_INSTANCE` (`PROCESS_INSTANCE_ID_`),
  KEY `ACT_FK_SUSPENDED_JOB_PROC_DEF` (`PROC_DEF_ID_`),
  CONSTRAINT `ACT_FK_SUSPENDED_JOB_CUSTOM_VALUES` FOREIGN KEY (`CUSTOM_VALUES_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_SUSPENDED_JOB_EXCEPTION` FOREIGN KEY (`EXCEPTION_STACK_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_SUSPENDED_JOB_EXECUTION` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_SUSPENDED_JOB_PROC_DEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_SUSPENDED_JOB_PROCESS_INSTANCE` FOREIGN KEY (`PROCESS_INSTANCE_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ru_suspended_job`
--

LOCK TABLES `act_ru_suspended_job` WRITE;
/*!40000 ALTER TABLE `act_ru_suspended_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_ru_suspended_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ru_task`
--

DROP TABLE IF EXISTS `act_ru_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ru_task` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROPAGATED_STAGE_INST_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `STATE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `PARENT_TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `DESCRIPTION_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `OWNER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ASSIGNEE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `DELEGATION_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PRIORITY_` int DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `IN_PROGRESS_TIME_` datetime(3) DEFAULT NULL,
  `IN_PROGRESS_STARTED_BY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CLAIM_TIME_` datetime(3) DEFAULT NULL,
  `CLAIMED_BY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUSPENDED_TIME_` datetime(3) DEFAULT NULL,
  `SUSPENDED_BY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `IN_PROGRESS_DUE_DATE_` datetime(3) DEFAULT NULL,
  `DUE_DATE_` datetime(3) DEFAULT NULL,
  `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUSPENSION_STATE_` int DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  `FORM_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `IS_COUNT_ENABLED_` tinyint DEFAULT NULL,
  `VAR_COUNT_` int DEFAULT NULL,
  `ID_LINK_COUNT_` int DEFAULT NULL,
  `SUB_TASK_COUNT_` int DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_TASK_CREATE` (`CREATE_TIME_`),
  KEY `ACT_IDX_TASK_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_TASK_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_TASK_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_FK_TASK_EXE` (`EXECUTION_ID_`),
  KEY `ACT_FK_TASK_PROCINST` (`PROC_INST_ID_`),
  KEY `ACT_FK_TASK_PROCDEF` (`PROC_DEF_ID_`),
  CONSTRAINT `ACT_FK_TASK_EXE` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_TASK_PROCDEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_TASK_PROCINST` FOREIGN KEY (`PROC_INST_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ru_task`
--

LOCK TABLES `act_ru_task` WRITE;
/*!40000 ALTER TABLE `act_ru_task` DISABLE KEYS */;
INSERT INTO `act_ru_task` VALUES ('31616bac-b272-11f1-ad93-202b20a0f17a',1,'166f13f9-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,'directorTask',NULL,'WangWu',NULL,50,'2026-09-17 08:31:34.968',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('5a55d04a-b58f-11f1-9502-202b20a0f17a',1,'5a518a86-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','部门领导审批',NULL,NULL,'deptLeaderTask',NULL,'LiSi',NULL,50,'2026-09-21 07:37:52.550',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('5e1730fb-b272-11f1-ad93-202b20a0f17a',1,'1f6a1dbd-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,'directorTask',NULL,'WangWu',NULL,50,'2026-09-17 08:32:49.979',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('5e29bec9-b4aa-11f1-8fff-202b20a0f17a',1,'c651c7b7-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,'directorTask',NULL,'WangWu',NULL,50,'2026-09-20 04:18:44.243',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('5ee3e714-b4aa-11f1-8fff-202b20a0f17a',1,'a6088d33-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,'directorTask',NULL,'WangWu',NULL,50,'2026-09-20 04:18:45.463',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('91b27dbd-b662-11f1-b8de-202b20a0f17a',1,'91ae8619-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','部门领导审批',NULL,NULL,'deptLeaderTask',NULL,'LiSi',NULL,50,'2026-09-22 08:49:49.244',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('97fcaa0e-b272-11f1-ad93-202b20a0f17a',1,'383aa7dc-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,'directorTask',NULL,'WangWu',NULL,50,'2026-09-17 08:34:27.113',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('988d9f79-b272-11f1-ad93-202b20a0f17a',1,'62dc0c1b-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,'directorTask',NULL,'WangWu',NULL,50,'2026-09-17 08:34:28.063',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('991741e4-b272-11f1-ad93-202b20a0f17a',1,'63f607af-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,'directorTask',NULL,'WangWu',NULL,50,'2026-09-17 08:34:28.965',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('9a834336-b338-11f1-a240-202b20a0f17a',1,'d58cb4cb-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,'directorTask',NULL,'WangWu',NULL,50,'2026-09-18 08:11:51.703',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('9a97643d-b4bc-11f1-a476-202b20a0f17a',1,'9290a48e-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,'directorTask',NULL,'WangWu',NULL,50,'2026-09-20 06:29:16.566',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('a4980d33-b272-11f1-ad93-202b20a0f17a',1,'9c581514-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,'directorTask',NULL,'WangWu',NULL,50,'2026-09-17 08:34:48.264',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('ce172180-b4c7-11f1-bea6-202b20a0f17a',1,'82c27771-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,'directorTask',NULL,'WangWu',NULL,50,'2026-09-20 07:49:27.431',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('edc5eb1d-b337-11f1-a240-202b20a0f17a',1,'cb7f32f0-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','分管领导审批',NULL,NULL,'directorTask',NULL,'WangWu',NULL,50,'2026-09-18 08:07:01.894',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0),('fd9a85b4-b4c7-11f1-bea6-202b20a0f17a',1,'fd9a85b0-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','leaveApproval:1:11beab38-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,'created','部门领导审批',NULL,NULL,'deptLeaderTask',NULL,'LiSi',NULL,50,'2026-09-20 07:50:47.145',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'tenant_a',NULL,1,0,0,0);
/*!40000 ALTER TABLE `act_ru_task` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ru_timer_job`
--

DROP TABLE IF EXISTS `act_ru_timer_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ru_timer_job` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `LOCK_EXP_TIME_` timestamp(3) NULL DEFAULT NULL,
  `LOCK_OWNER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCLUSIVE_` tinyint(1) DEFAULT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROCESS_INSTANCE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ELEMENT_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_DEFINITION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CORRELATION_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `RETRIES_` int DEFAULT NULL,
  `EXCEPTION_STACK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `EXCEPTION_MSG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `DUEDATE_` timestamp(3) NULL DEFAULT NULL,
  `REPEAT_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `HANDLER_CFG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `CUSTOM_VALUES_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` timestamp(3) NULL DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_TIMER_JOB_EXCEPTION_STACK_ID` (`EXCEPTION_STACK_ID_`),
  KEY `ACT_IDX_TIMER_JOB_CUSTOM_VALUES_ID` (`CUSTOM_VALUES_ID_`),
  KEY `ACT_IDX_TIMER_JOB_CORRELATION_ID` (`CORRELATION_ID_`),
  KEY `ACT_IDX_TIMER_JOB_DUEDATE` (`DUEDATE_`),
  KEY `ACT_IDX_TJOB_SCOPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_TJOB_SUB_SCOPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_TJOB_SCOPE_DEF` (`SCOPE_DEFINITION_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_FK_TIMER_JOB_EXECUTION` (`EXECUTION_ID_`),
  KEY `ACT_FK_TIMER_JOB_PROCESS_INSTANCE` (`PROCESS_INSTANCE_ID_`),
  KEY `ACT_FK_TIMER_JOB_PROC_DEF` (`PROC_DEF_ID_`),
  CONSTRAINT `ACT_FK_TIMER_JOB_CUSTOM_VALUES` FOREIGN KEY (`CUSTOM_VALUES_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_TIMER_JOB_EXCEPTION` FOREIGN KEY (`EXCEPTION_STACK_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_TIMER_JOB_EXECUTION` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_TIMER_JOB_PROC_DEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
  CONSTRAINT `ACT_FK_TIMER_JOB_PROCESS_INSTANCE` FOREIGN KEY (`PROCESS_INSTANCE_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ru_timer_job`
--

LOCK TABLES `act_ru_timer_job` WRITE;
/*!40000 ALTER TABLE `act_ru_timer_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `act_ru_timer_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `act_ru_variable`
--

DROP TABLE IF EXISTS `act_ru_variable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `act_ru_variable` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `NAME_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `BYTEARRAY_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `DOUBLE_` double DEFAULT NULL,
  `LONG_` bigint DEFAULT NULL,
  `TEXT_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `TEXT2_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  `META_INFO_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  KEY `ACT_IDX_RU_VAR_SCOPE_ID_TYPE` (`SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_IDX_RU_VAR_SUB_ID_TYPE` (`SUB_SCOPE_ID_`,`SCOPE_TYPE_`),
  KEY `ACT_FK_VAR_BYTEARRAY` (`BYTEARRAY_ID_`),
  KEY `ACT_IDX_VARIABLE_TASK_ID` (`TASK_ID_`),
  KEY `ACT_FK_VAR_EXE` (`EXECUTION_ID_`),
  KEY `ACT_FK_VAR_PROCINST` (`PROC_INST_ID_`),
  CONSTRAINT `ACT_FK_VAR_BYTEARRAY` FOREIGN KEY (`BYTEARRAY_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
  CONSTRAINT `ACT_FK_VAR_EXE` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
  CONSTRAINT `ACT_FK_VAR_PROCINST` FOREIGN KEY (`PROC_INST_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `act_ru_variable`
--

LOCK TABLES `act_ru_variable` WRITE;
/*!40000 ALTER TABLE `act_ru_variable` DISABLE KEYS */;
INSERT INTO `act_ru_variable` VALUES ('166f13ed-b272-11f1-ad93-202b20a0f17a',1,'string','director','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('166f13ef-b272-11f1-ad93-202b20a0f17a',1,'string','tenantId','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('166f13f1-b272-11f1-ad93-202b20a0f17a',1,'integer','days','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL),('166f13f3-b272-11f1-ad93-202b20a0f17a',1,'string','hr','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('166f13f5-b272-11f1-ad93-202b20a0f17a',1,'string','deptLeader','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('166f13f7-b272-11f1-ad93-202b20a0f17a',1,'string','applicant','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL),('1f6a1db1-b272-11f1-ad93-202b20a0f17a',1,'string','director','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('1f6a1db3-b272-11f1-ad93-202b20a0f17a',1,'string','tenantId','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('1f6a1db5-b272-11f1-ad93-202b20a0f17a',1,'integer','days','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL),('1f6a1db7-b272-11f1-ad93-202b20a0f17a',1,'string','hr','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('1f6a1db9-b272-11f1-ad93-202b20a0f17a',1,'string','deptLeader','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('1f6a1dbb-b272-11f1-ad93-202b20a0f17a',1,'string','applicant','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL),('31600c14-b272-11f1-ad93-202b20a0f17a',1,'boolean','approved','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL),('31603326-b272-11f1-ad93-202b20a0f17a',1,'string','comment','166f13ec-b272-11f1-ad93-202b20a0f17a','166f13ec-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL),('383a59b0-b272-11f1-ad93-202b20a0f17a',1,'string','director','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('383a59b2-b272-11f1-ad93-202b20a0f17a',1,'string','tenantId','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('383a59b4-b272-11f1-ad93-202b20a0f17a',1,'integer','days','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL),('383a59b6-b272-11f1-ad93-202b20a0f17a',1,'string','hr','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('383a59b8-b272-11f1-ad93-202b20a0f17a',1,'string','deptLeader','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('383aa7da-b272-11f1-ad93-202b20a0f17a',1,'string','applicant','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL),('5a51154a-b58f-11f1-9502-202b20a0f17a',1,'string','director','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('5a51636c-b58f-11f1-9502-202b20a0f17a',1,'string','tenantId','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('5a51636e-b58f-11f1-9502-202b20a0f17a',1,'integer','days','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,3,'3',NULL,NULL),('5a516370-b58f-11f1-9502-202b20a0f17a',1,'string','hr','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('5a518a82-b58f-11f1-9502-202b20a0f17a',1,'string','deptLeader','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('5a518a84-b58f-11f1-9502-202b20a0f17a',1,'string','applicant','5a50ee39-b58f-11f1-9502-202b20a0f17a','5a50ee39-b58f-11f1-9502-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'??',NULL,NULL),('5e164693-b272-11f1-ad93-202b20a0f17a',1,'boolean','approved','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL),('5e164695-b272-11f1-ad93-202b20a0f17a',1,'string','comment','1f6a1db0-b272-11f1-ad93-202b20a0f17a','1f6a1db0-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL),('5e21a871-b4aa-11f1-8fff-202b20a0f17a',1,'boolean','approved','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL),('5e230803-b4aa-11f1-8fff-202b20a0f17a',1,'string','comment','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL),('5ee323bc-b4aa-11f1-8fff-202b20a0f17a',1,'boolean','approved','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL),('5ee34ace-b4aa-11f1-8fff-202b20a0f17a',1,'string','comment','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL),('62dc0c0f-b272-11f1-ad93-202b20a0f17a',1,'string','director','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('62dc0c11-b272-11f1-ad93-202b20a0f17a',1,'string','tenantId','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('62dc0c13-b272-11f1-ad93-202b20a0f17a',1,'integer','days','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL),('62dc0c15-b272-11f1-ad93-202b20a0f17a',1,'string','hr','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('62dc0c17-b272-11f1-ad93-202b20a0f17a',1,'string','deptLeader','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('62dc0c19-b272-11f1-ad93-202b20a0f17a',1,'string','applicant','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL),('63f607a3-b272-11f1-ad93-202b20a0f17a',1,'string','director','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('63f607a5-b272-11f1-ad93-202b20a0f17a',1,'string','tenantId','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('63f607a7-b272-11f1-ad93-202b20a0f17a',1,'integer','days','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL),('63f607a9-b272-11f1-ad93-202b20a0f17a',1,'string','hr','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('63f607ab-b272-11f1-ad93-202b20a0f17a',1,'string','deptLeader','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('63f607ad-b272-11f1-ad93-202b20a0f17a',1,'string','applicant','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL),('82c20235-b4c7-11f1-bea6-202b20a0f17a',1,'string','director','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('82c25057-b4c7-11f1-bea6-202b20a0f17a',1,'string','tenantId','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('82c27769-b4c7-11f1-bea6-202b20a0f17a',1,'integer','days','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL),('82c2776b-b4c7-11f1-bea6-202b20a0f17a',1,'string','hr','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('82c2776d-b4c7-11f1-bea6-202b20a0f17a',1,'string','deptLeader','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('82c2776f-b4c7-11f1-bea6-202b20a0f17a',1,'string','applicant','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'张三',NULL,NULL),('91ae10dd-b662-11f1-b8de-202b20a0f17a',1,'string','director','91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('91ae5eff-b662-11f1-b8de-202b20a0f17a',1,'string','tenantId','91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('91ae5f01-b662-11f1-b8de-202b20a0f17a',1,'integer','days','91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL),('91ae5f03-b662-11f1-b8de-202b20a0f17a',1,'string','hr','91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('91ae5f05-b662-11f1-b8de-202b20a0f17a',1,'string','deptLeader','91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('91ae5f07-b662-11f1-b8de-202b20a0f17a',1,'string','applicant','91adc2bc-b662-11f1-b8de-202b20a0f17a','91adc2bc-b662-11f1-b8de-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL),('92900842-b4bc-11f1-a476-202b20a0f17a',1,'string','tenantId','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('92907d74-b4bc-11f1-a476-202b20a0f17a',1,'integer','days','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,4,'4',NULL,NULL),('92907d76-b4bc-11f1-a476-202b20a0f17a',1,'string','hr','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('92907d78-b4bc-11f1-a476-202b20a0f17a',1,'string','deptLeader','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('92907d7a-b4bc-11f1-a476-202b20a0f17a',1,'string','director','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('92907d7c-b4bc-11f1-a476-202b20a0f17a',1,'string','applicant','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL),('97fc0dc6-b272-11f1-ad93-202b20a0f17a',1,'boolean','approved','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL),('97fc34d8-b272-11f1-ad93-202b20a0f17a',1,'string','comment','383a59af-b272-11f1-ad93-202b20a0f17a','383a59af-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL),('988cdc21-b272-11f1-ad93-202b20a0f17a',1,'boolean','approved','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL),('988d0333-b272-11f1-ad93-202b20a0f17a',1,'string','comment','62dc0c0e-b272-11f1-ad93-202b20a0f17a','62dc0c0e-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL),('99171acc-b272-11f1-ad93-202b20a0f17a',1,'boolean','approved','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL),('99171ace-b272-11f1-ad93-202b20a0f17a',1,'string','comment','63f607a2-b272-11f1-ad93-202b20a0f17a','63f607a2-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL),('9a819580-b338-11f1-a240-202b20a0f17a',1,'boolean','approved','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL),('9a819581-b338-11f1-a240-202b20a0f17a',1,'string','comment','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL),('9a954155-b4bc-11f1-a476-202b20a0f17a',1,'boolean','approved','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL),('9a958f77-b4bc-11f1-a476-202b20a0f17a',1,'string','comment','92900841-b4bc-11f1-a476-202b20a0f17a','92900841-b4bc-11f1-a476-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL),('9c581508-b272-11f1-ad93-202b20a0f17a',1,'string','director','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('9c58150a-b272-11f1-ad93-202b20a0f17a',1,'string','tenantId','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('9c58150c-b272-11f1-ad93-202b20a0f17a',1,'integer','days','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL),('9c58150e-b272-11f1-ad93-202b20a0f17a',1,'string','hr','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('9c581510-b272-11f1-ad93-202b20a0f17a',1,'string','deptLeader','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('9c581512-b272-11f1-ad93-202b20a0f17a',1,'string','applicant','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL),('a49797fb-b272-11f1-ad93-202b20a0f17a',1,'boolean','approved','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL),('a49797fd-b272-11f1-ad93-202b20a0f17a',1,'string','comment','9c581507-b272-11f1-ad93-202b20a0f17a','9c581507-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL),('a607f0e7-b272-11f1-ad93-202b20a0f17a',1,'string','director','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('a607f0e9-b272-11f1-ad93-202b20a0f17a',1,'string','tenantId','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('a607f0eb-b272-11f1-ad93-202b20a0f17a',1,'integer','days','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL),('a607f0ed-b272-11f1-ad93-202b20a0f17a',1,'string','hr','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('a607f0ef-b272-11f1-ad93-202b20a0f17a',1,'string','deptLeader','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('a6088d31-b272-11f1-ad93-202b20a0f17a',1,'string','applicant','a607f0e6-b272-11f1-ad93-202b20a0f17a','a607f0e6-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL),('c651c7ab-b272-11f1-ad93-202b20a0f17a',1,'string','director','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('c651c7ad-b272-11f1-ad93-202b20a0f17a',1,'string','tenantId','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('c651c7af-b272-11f1-ad93-202b20a0f17a',1,'integer','days','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL),('c651c7b1-b272-11f1-ad93-202b20a0f17a',1,'string','hr','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('c651c7b3-b272-11f1-ad93-202b20a0f17a',1,'string','deptLeader','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('c651c7b5-b272-11f1-ad93-202b20a0f17a',1,'string','applicant','c651c7aa-b272-11f1-ad93-202b20a0f17a','c651c7aa-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL),('cb7f32ea-b337-11f1-a240-202b20a0f17a',1,'string','tenantId','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('cb7f32eb-b337-11f1-a240-202b20a0f17a',1,'integer','days','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL),('cb7f32ec-b337-11f1-a240-202b20a0f17a',1,'string','hr','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('cb7f32ed-b337-11f1-a240-202b20a0f17a',1,'string','deptLeader','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('cb7f32ee-b337-11f1-a240-202b20a0f17a',1,'string','director','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('cb7f32ef-b337-11f1-a240-202b20a0f17a',1,'string','applicant','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL),('ce154cb8-b4c7-11f1-bea6-202b20a0f17a',1,'boolean','approved','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL),('ce1573ca-b4c7-11f1-bea6-202b20a0f17a',1,'string','comment','82c1db24-b4c7-11f1-bea6-202b20a0f17a','82c1db24-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'同意',NULL,NULL),('d58c8daf-b272-11f1-ad93-202b20a0f17a',1,'string','director','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('d58c8db1-b272-11f1-ad93-202b20a0f17a',1,'string','tenantId','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('d58c8db3-b272-11f1-ad93-202b20a0f17a',1,'integer','days','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,5,'5',NULL,NULL),('d58c8db5-b272-11f1-ad93-202b20a0f17a',1,'string','hr','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('d58c8db7-b272-11f1-ad93-202b20a0f17a',1,'string','deptLeader','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('d58c8db9-b272-11f1-ad93-202b20a0f17a',1,'string','applicant','d58c8dae-b272-11f1-ad93-202b20a0f17a','d58c8dae-b272-11f1-ad93-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL),('edc46477-b337-11f1-a240-202b20a0f17a',1,'boolean','approved','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL),('edc46478-b337-11f1-a240-202b20a0f17a',1,'string','comment','cb7f32e9-b337-11f1-a240-202b20a0f17a','cb7f32e9-b337-11f1-a240-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'??',NULL,NULL),('fd9a85a4-b4c7-11f1-bea6-202b20a0f17a',1,'string','tenantId','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tenant_a',NULL,NULL),('fd9a85a6-b4c7-11f1-bea6-202b20a0f17a',1,'integer','days','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,3,'3',NULL,NULL),('fd9a85a8-b4c7-11f1-bea6-202b20a0f17a',1,'string','hr','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhaoLiu',NULL,NULL),('fd9a85aa-b4c7-11f1-bea6-202b20a0f17a',1,'string','deptLeader','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'LiSi',NULL,NULL),('fd9a85ac-b4c7-11f1-bea6-202b20a0f17a',1,'string','director','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'WangWu',NULL,NULL),('fd9a85ae-b4c7-11f1-bea6-202b20a0f17a',1,'string','applicant','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a','fd9a85a3-b4c7-11f1-bea6-202b20a0f17a',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ZhangSan',NULL,NULL);
/*!40000 ALTER TABLE `act_ru_variable` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flw_channel_definition`
--

DROP TABLE IF EXISTS `flw_channel_definition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flw_channel_definition` (
  `ID_` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `NAME_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `VERSION_` int DEFAULT NULL,
  `KEY_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `CATEGORY_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `DEPLOYMENT_ID_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `CREATE_TIME_` datetime(3) DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `RESOURCE_NAME_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `DESCRIPTION_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `TYPE_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `IMPLEMENTATION_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  UNIQUE KEY `ACT_IDX_CHANNEL_DEF_UNIQ` (`KEY_`,`VERSION_`,`TENANT_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flw_channel_definition`
--

LOCK TABLES `flw_channel_definition` WRITE;
/*!40000 ALTER TABLE `flw_channel_definition` DISABLE KEYS */;
/*!40000 ALTER TABLE `flw_channel_definition` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flw_ev_databasechangelog`
--

DROP TABLE IF EXISTS `flw_ev_databasechangelog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flw_ev_databasechangelog` (
  `ID` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `AUTHOR` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `FILENAME` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `DATEEXECUTED` datetime NOT NULL,
  `ORDEREXECUTED` int NOT NULL,
  `EXECTYPE` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `MD5SUM` varchar(35) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `DESCRIPTION` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `COMMENTS` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `TAG` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `LIQUIBASE` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `CONTEXTS` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `LABELS` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `DEPLOYMENT_ID` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flw_ev_databasechangelog`
--

LOCK TABLES `flw_ev_databasechangelog` WRITE;
/*!40000 ALTER TABLE `flw_ev_databasechangelog` DISABLE KEYS */;
INSERT INTO `flw_ev_databasechangelog` VALUES ('1','flowable','org/flowable/eventregistry/db/liquibase/flowable-eventregistry-db-changelog.xml','2026-09-16 11:21:37',1,'EXECUTED','9:63268f536c469325acef35970312551b','createTable tableName=FLW_EVENT_DEPLOYMENT; createTable tableName=FLW_EVENT_RESOURCE; createTable tableName=FLW_EVENT_DEFINITION; createIndex indexName=ACT_IDX_EVENT_DEF_UNIQ, tableName=FLW_EVENT_DEFINITION; createTable tableName=FLW_CHANNEL_DEFIN...','',NULL,'4.24.0',NULL,NULL,'9528897212'),('2','flowable','org/flowable/eventregistry/db/liquibase/flowable-eventregistry-db-changelog.xml','2026-09-16 11:21:37',2,'EXECUTED','9:dcb58b7dfd6dbda66939123a96985536','addColumn tableName=FLW_CHANNEL_DEFINITION; addColumn tableName=FLW_CHANNEL_DEFINITION','',NULL,'4.24.0',NULL,NULL,'9528897212'),('3','flowable','org/flowable/eventregistry/db/liquibase/flowable-eventregistry-db-changelog.xml','2026-09-16 11:21:37',3,'EXECUTED','9:d0c05678d57af23ad93699991e3bf4f6','customChange','',NULL,'4.24.0',NULL,NULL,'9528897212');
/*!40000 ALTER TABLE `flw_ev_databasechangelog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flw_ev_databasechangeloglock`
--

DROP TABLE IF EXISTS `flw_ev_databasechangeloglock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flw_ev_databasechangeloglock` (
  `ID` int NOT NULL,
  `LOCKED` tinyint(1) NOT NULL,
  `LOCKGRANTED` datetime DEFAULT NULL,
  `LOCKEDBY` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flw_ev_databasechangeloglock`
--

LOCK TABLES `flw_ev_databasechangeloglock` WRITE;
/*!40000 ALTER TABLE `flw_ev_databasechangeloglock` DISABLE KEYS */;
INSERT INTO `flw_ev_databasechangeloglock` VALUES (1,0,NULL,NULL);
/*!40000 ALTER TABLE `flw_ev_databasechangeloglock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flw_event_definition`
--

DROP TABLE IF EXISTS `flw_event_definition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flw_event_definition` (
  `ID_` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `NAME_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `VERSION_` int DEFAULT NULL,
  `KEY_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `CATEGORY_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `DEPLOYMENT_ID_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `RESOURCE_NAME_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `DESCRIPTION_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`ID_`),
  UNIQUE KEY `ACT_IDX_EVENT_DEF_UNIQ` (`KEY_`,`VERSION_`,`TENANT_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flw_event_definition`
--

LOCK TABLES `flw_event_definition` WRITE;
/*!40000 ALTER TABLE `flw_event_definition` DISABLE KEYS */;
/*!40000 ALTER TABLE `flw_event_definition` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flw_event_deployment`
--

DROP TABLE IF EXISTS `flw_event_deployment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flw_event_deployment` (
  `ID_` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `NAME_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `CATEGORY_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `DEPLOY_TIME_` datetime(3) DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `PARENT_DEPLOYMENT_ID_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flw_event_deployment`
--

LOCK TABLES `flw_event_deployment` WRITE;
/*!40000 ALTER TABLE `flw_event_deployment` DISABLE KEYS */;
/*!40000 ALTER TABLE `flw_event_deployment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flw_event_resource`
--

DROP TABLE IF EXISTS `flw_event_resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flw_event_resource` (
  `ID_` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `NAME_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `DEPLOYMENT_ID_` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `RESOURCE_BYTES_` longblob,
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flw_event_resource`
--

LOCK TABLES `flw_event_resource` WRITE;
/*!40000 ALTER TABLE `flw_event_resource` DISABLE KEYS */;
/*!40000 ALTER TABLE `flw_event_resource` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flw_ru_batch`
--

DROP TABLE IF EXISTS `flw_ru_batch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flw_ru_batch` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `TYPE_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `SEARCH_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SEARCH_KEY2_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` datetime(3) NOT NULL,
  `COMPLETE_TIME_` datetime(3) DEFAULT NULL,
  `STATUS_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `BATCH_DOC_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flw_ru_batch`
--

LOCK TABLES `flw_ru_batch` WRITE;
/*!40000 ALTER TABLE `flw_ru_batch` DISABLE KEYS */;
/*!40000 ALTER TABLE `flw_ru_batch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `flw_ru_batch_part`
--

DROP TABLE IF EXISTS `flw_ru_batch_part`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flw_ru_batch_part` (
  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `REV_` int DEFAULT NULL,
  `BATCH_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TYPE_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
  `SCOPE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SUB_SCOPE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SCOPE_TYPE_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `SEARCH_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `SEARCH_KEY2_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `CREATE_TIME_` datetime(3) NOT NULL,
  `COMPLETE_TIME_` datetime(3) DEFAULT NULL,
  `STATUS_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `RESULT_DOC_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
  `TENANT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT '',
  PRIMARY KEY (`ID_`),
  KEY `FLW_IDX_BATCH_PART` (`BATCH_ID_`),
  CONSTRAINT `FLW_FK_BATCH_PART_PARENT` FOREIGN KEY (`BATCH_ID_`) REFERENCES `flw_ru_batch` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flw_ru_batch_part`
--

LOCK TABLES `flw_ru_batch_part` WRITE;
/*!40000 ALTER TABLE `flw_ru_batch_part` DISABLE KEYS */;
/*!40000 ALTER TABLE `flw_ru_batch_part` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_config`
--

DROP TABLE IF EXISTS `sys_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `config_name` varchar(128) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '配置中文名',
  `config_key` varchar(128) COLLATE utf8mb4_general_ci NOT NULL,
  `config_value` varchar(512) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `remark` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_key` (`tenant_id`,`config_key`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='系统配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_config`
--

LOCK TABLES `sys_config` WRITE;
/*!40000 ALTER TABLE `sys_config` DISABLE KEYS */;
INSERT INTO `sys_config` VALUES (1,'tenant_a','系统名称','system.name','政务管理系统','系统名称','2026-09-23 14:54:01'),(2,'tenant_a','系统Logo','system.logo','','系统Logo URL','2026-09-23 14:54:01'),(3,'tenant_a','办件超期天数','application.timeout','7','办件超期天数','2026-09-23 14:54:01'),(4,'tenant_a','办结后自动发评价','evaluation.autoSend','true','办结后自动发送评价邀请','2026-09-23 14:54:01'),(5,'tenant_a','短信通知开关','notify.sms.enabled','false','是否启用短信通知','2026-09-23 14:54:01');
/*!40000 ALTER TABLE `sys_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dept`
--

DROP TABLE IF EXISTS `sys_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dept` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `parent_id` bigint DEFAULT '0' COMMENT '上级部门ID',
  `dept_name` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `order_num` int DEFAULT '0',
  `status` tinyint DEFAULT '1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_tenant` (`tenant_id`),
  KEY `idx_parent` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='部门表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dept`
--

LOCK TABLES `sys_dept` WRITE;
/*!40000 ALTER TABLE `sys_dept` DISABLE KEYS */;
INSERT INTO `sys_dept` VALUES (1,'tenant_a',0,'A市政府',1,1,'2026-09-23 14:54:01'),(2,'tenant_a',1,'A市财政局',1,1,'2026-09-23 14:54:01'),(3,'tenant_a',1,'A市民政局',2,1,'2026-09-23 14:54:01'),(4,'tenant_a',2,'A市财政局预算科',1,1,'2026-09-23 14:54:01'),(5,'tenant_a',2,'A市财政局国库科',2,1,'2026-09-23 14:54:01'),(6,'tenant_b',0,'B市政府',1,1,'2026-09-23 14:54:01');
/*!40000 ALTER TABLE `sys_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict`
--

DROP TABLE IF EXISTS `sys_dict`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `dict_type` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `dict_label` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `dict_value` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `sort` int DEFAULT '0',
  `status` tinyint DEFAULT '1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_type_value` (`tenant_id`,`dict_type`,`dict_value`),
  KEY `idx_type` (`tenant_id`,`dict_type`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='数据字典表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict`
--

LOCK TABLES `sys_dict` WRITE;
/*!40000 ALTER TABLE `sys_dict` DISABLE KEYS */;
INSERT INTO `sys_dict` VALUES (1,'tenant_a','application_status','草稿','DRAFT',1,1,'2026-09-23 14:54:01'),(2,'tenant_a','application_status','待审批','PENDING',2,1,'2026-09-23 14:54:01'),(3,'tenant_a','application_status','已通过','APPROVED',3,1,'2026-09-23 14:54:01'),(4,'tenant_a','application_status','已驳回','REJECTED',4,1,'2026-09-23 14:54:01'),(5,'tenant_a','evaluation_channel','网上办事','ONLINE',1,1,'2026-09-23 14:54:01'),(6,'tenant_a','evaluation_channel','手机APP','APP',2,1,'2026-09-23 14:54:01'),(7,'tenant_a','evaluation_channel','窗口','WINDOW',3,1,'2026-09-23 14:54:01'),(8,'tenant_a','evaluation_channel','电话','PHONE',4,1,'2026-09-23 14:54:01'),(9,'tenant_a','evaluation_score','非常满意','5',1,1,'2026-09-23 14:54:01'),(10,'tenant_a','evaluation_score','满意','4',2,1,'2026-09-23 14:54:01'),(11,'tenant_a','evaluation_score','基本满意','3',3,1,'2026-09-23 14:54:01'),(12,'tenant_a','evaluation_score','不满意','2',4,1,'2026-09-23 14:54:01'),(13,'tenant_a','evaluation_score','非常不满意','1',5,1,'2026-09-23 14:54:01'),(14,'tenant_a','gender','男','M',1,1,'2026-09-23 14:54:01'),(15,'tenant_a','gender','女','F',2,1,'2026-09-23 14:54:01'),(16,'tenant_a','yes_no','是','Y',1,1,'2026-09-23 14:54:01'),(17,'tenant_a','yes_no','否','N',2,1,'2026-09-23 14:54:01');
/*!40000 ALTER TABLE `sys_dict` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_type`
--

DROP TABLE IF EXISTS `sys_dict_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_type` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `dict_type` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型编码',
  `dict_name` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '类型中文名',
  `remark` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_type` (`tenant_id`,`dict_type`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='字典类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_type`
--

LOCK TABLES `sys_dict_type` WRITE;
/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;
INSERT INTO `sys_dict_type` VALUES (1,'tenant_a','application_status','事项状态','事项的办理状态','2026-09-23 14:54:01'),(2,'tenant_a','evaluation_channel','评价渠道','群众提交评价的渠道','2026-09-23 14:54:01'),(3,'tenant_a','evaluation_score','评价等级','好差评评分等级','2026-09-23 14:54:01'),(4,'tenant_a','gender','性别','性别字典','2026-09-23 14:54:01'),(5,'tenant_a','yes_no','是否','通用是否字典','2026-09-23 14:54:01');
/*!40000 ALTER TABLE `sys_dict_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_job`
--

DROP TABLE IF EXISTS `sys_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_job` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `job_name` varchar(128) COLLATE utf8mb4_general_ci NOT NULL,
  `job_group` varchar(64) COLLATE utf8mb4_general_ci DEFAULT 'DEFAULT',
  `invoke_target` varchar(256) COLLATE utf8mb4_general_ci NOT NULL,
  `cron` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `misfire_policy` varchar(16) COLLATE utf8mb4_general_ci DEFAULT '3',
  `status` tinyint DEFAULT '1',
  `remark` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='定时任务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_job`
--

LOCK TABLES `sys_job` WRITE;
/*!40000 ALTER TABLE `sys_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_job_log`
--

DROP TABLE IF EXISTS `sys_job_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_job_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `job_id` bigint NOT NULL,
  `job_name` varchar(128) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `invoke_target` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `job_message` text COLLATE utf8mb4_general_ci,
  `status` tinyint DEFAULT '1',
  `exception_info` text COLLATE utf8mb4_general_ci,
  `cost_time` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_job` (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='定时任务日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_job_log`
--

LOCK TABLES `sys_job_log` WRITE;
/*!40000 ALTER TABLE `sys_job_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_job_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_login_log`
--

DROP TABLE IF EXISTS `sys_login_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_login_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `username` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ip` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `location` varchar(128) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `browser` varchar(128) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `os` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` tinyint DEFAULT '1' COMMENT '1成功 0失败',
  `msg` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `login_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_tenant_time` (`tenant_id`,`login_time`),
  KEY `idx_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='登录日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_login_log`
--

LOCK TABLES `sys_login_log` WRITE;
/*!40000 ALTER TABLE `sys_login_log` DISABLE KEYS */;
INSERT INTO `sys_login_log` VALUES (1,NULL,'admin','127.0.0.1',NULL,'Chrome','Windows',0,'用户名或密码错误','2026-09-23 14:54:08'),(2,NULL,'admin','127.0.0.1',NULL,'Chrome','Windows',0,'用户名或密码错误','2026-09-23 14:54:13'),(3,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-23 14:54:48'),(4,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-23 17:24:59'),(5,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-23 17:28:11'),(6,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-23 17:36:12'),(7,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 10:03:53'),(8,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 10:08:29'),(9,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 10:08:57'),(10,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 10:27:52'),(11,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 10:34:44'),(12,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 10:37:10'),(13,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 10:43:03'),(14,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 10:51:26'),(15,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 11:04:27'),(16,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 11:22:42'),(17,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 11:46:32'),(18,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 11:49:07'),(19,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 11:49:11'),(20,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 11:49:14'),(21,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 11:51:49'),(22,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 13:35:44'),(23,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 13:40:37'),(24,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 14:12:07'),(25,NULL,'user','127.0.0.1',NULL,'Other','Windows',0,'用户名或密码错误','2026-09-24 14:12:56'),(26,NULL,'user','127.0.0.1',NULL,'Other','Windows',0,'用户名或密码错误','2026-09-24 14:13:48'),(27,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 14:15:56'),(28,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 14:22:12'),(29,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 14:22:56'),(30,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 14:27:50'),(31,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 14:32:21'),(32,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 14:36:27'),(33,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 15:03:32'),(34,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 15:05:14'),(35,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 15:06:22'),(36,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 15:07:25'),(37,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 15:11:24'),(38,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 15:25:20'),(39,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 15:27:59'),(40,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 15:28:00'),(41,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 15:28:45'),(42,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 15:31:14'),(43,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 15:32:19'),(44,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 15:35:05'),(45,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 15:35:40'),(46,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 15:36:12'),(47,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 15:37:15'),(48,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 15:37:31'),(49,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 15:37:38'),(50,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 15:41:05'),(51,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 15:41:12'),(52,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 16:19:43'),(53,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 16:20:33'),(54,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 16:20:37'),(55,'tenant_a','admin','127.0.0.1',NULL,'Other','Windows',1,'登录成功','2026-09-24 16:22:02'),(56,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 16:24:26'),(57,'tenant_a','admin','127.0.0.1',NULL,'Chrome','Windows',1,'登录成功','2026-09-24 16:31:37');
/*!40000 ALTER TABLE `sys_login_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_menu`
--

DROP TABLE IF EXISTS `sys_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `parent_id` bigint DEFAULT '0' COMMENT '父菜单ID，0为顶级',
  `menu_name` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜单名称',
  `menu_type` char(1) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'M目录 C菜单 F按钮',
  `path` varchar(128) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '路由地址，C类型为完整路径如 /application',
  `component` varchar(128) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '组件名，如 Application；目录为 Layout',
  `perms` varchar(128) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '权限标识，如 sys:user:add',
  `icon` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '图标名（Element Plus）',
  `order_num` int DEFAULT '0' COMMENT '排序',
  `visible` tinyint DEFAULT '1' COMMENT '1显示 0隐藏',
  `status` tinyint DEFAULT '1' COMMENT '1启用 0禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_parent` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=445 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='菜单权限表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_menu`
--

LOCK TABLES `sys_menu` WRITE;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` VALUES (1,0,'首页','C','/dashboard','Dashboard',NULL,'HomeFilled',1,1,1,'2026-09-23 11:12:49'),(2,0,'业务办理','M','/biz','Layout',NULL,'Briefcase',2,1,1,'2026-09-23 11:12:49'),(3,0,'互动服务','M','/interact','Layout',NULL,'ChatDotRound',3,1,1,'2026-09-23 11:12:49'),(4,0,'统计分析','M','/stat','Layout',NULL,'DataLine',4,1,1,'2026-09-23 11:12:49'),(5,0,'系统管理','M','/system','Layout',NULL,'Setting',5,1,1,'2026-09-23 11:12:49'),(6,0,'文件管理','C','/file','File',NULL,'Folder',6,1,1,'2026-09-23 11:12:49'),(10,2,'事项管理','C','/application','Application',NULL,'Document',1,1,1,'2026-09-23 11:12:49'),(11,2,'审批流程','C','/process','Process',NULL,'Connection',2,1,1,'2026-09-23 11:12:49'),(12,2,'预约取号','C','/appointment','Appointment',NULL,'Calendar',3,1,1,'2026-09-23 11:12:49'),(13,2,'电子证照','C','/license','License',NULL,'Medal',4,1,1,'2026-09-23 11:12:49'),(14,2,'办事指南','C','/guide','Guide',NULL,'Notebook',5,1,1,'2026-09-23 11:12:49'),(20,3,'好差评','C','/evaluation','Evaluation',NULL,'Star',1,1,1,'2026-09-23 11:12:49'),(21,3,'咨询投诉','C','/consult','Consult',NULL,'Message',2,1,1,'2026-09-23 11:12:49'),(30,4,'统计报表','C','/report','Report',NULL,'PieChart',1,1,1,'2026-09-23 11:12:49'),(31,4,'数据大屏','C','/screen','BigScreen',NULL,'Monitor',2,1,1,'2026-09-23 11:12:49'),(40,5,'用户管理','C','/user','User',NULL,'User',1,1,1,'2026-09-23 11:12:49'),(41,5,'部门管理','C','/dept','Dept',NULL,'OfficeBuilding',2,1,1,'2026-09-23 11:12:49'),(42,5,'角色管理','C','/role','Role',NULL,'Avatar',3,1,1,'2026-09-23 11:12:49'),(43,5,'菜单管理','C','/menu','Menu',NULL,'Menu',4,1,1,'2026-09-23 11:12:49'),(44,5,'数据字典','C','/dict','Dict',NULL,'Collection',5,1,1,'2026-09-23 11:12:49'),(45,5,'系统配置','C','/config','Config',NULL,'Tools',6,1,1,'2026-09-23 11:12:49'),(46,5,'操作日志','C','/operlog','OperLog',NULL,'Tickets',7,1,1,'2026-09-23 11:12:49'),(47,5,'登录日志','C','/loginlog','LoginLog',NULL,'Key',8,1,1,'2026-09-23 11:12:49'),(401,40,'用户新增','F',NULL,NULL,'sys:user:add',NULL,1,1,1,'2026-09-23 11:12:49'),(402,40,'用户修改','F',NULL,NULL,'sys:user:edit',NULL,2,1,1,'2026-09-23 11:12:49'),(403,40,'用户删除','F',NULL,NULL,'sys:user:del',NULL,3,1,1,'2026-09-23 11:12:49'),(404,40,'重置密码','F',NULL,NULL,'sys:user:resetPwd',NULL,4,1,1,'2026-09-23 11:12:49'),(405,40,'分配角色','F',NULL,NULL,'sys:user:assignRole',NULL,5,1,1,'2026-09-23 11:12:49'),(420,42,'角色新增','F',NULL,NULL,'sys:role:add',NULL,1,1,1,'2026-09-23 11:12:49'),(421,42,'角色修改','F',NULL,NULL,'sys:role:edit',NULL,2,1,1,'2026-09-23 11:12:49'),(422,42,'角色删除','F',NULL,NULL,'sys:role:del',NULL,3,1,1,'2026-09-23 11:12:49'),(423,42,'分配菜单','F',NULL,NULL,'sys:role:assignMenu',NULL,4,1,1,'2026-09-23 11:12:49'),(424,42,'分配用户','F',NULL,NULL,'sys:role:assignUser',NULL,5,1,1,'2026-09-23 11:12:49'),(430,43,'菜单新增','F',NULL,NULL,'sys:menu:add',NULL,1,1,1,'2026-09-23 11:12:49'),(431,43,'菜单修改','F',NULL,NULL,'sys:menu:edit',NULL,2,1,1,'2026-09-23 11:12:49'),(432,43,'菜单删除','F',NULL,NULL,'sys:menu:del',NULL,3,1,1,'2026-09-23 11:12:49'),(434,0,'个人中心','C','/profile','Profile',NULL,'User',99,0,1,'2026-09-24 11:37:38'),(435,0,'????','M','/perm-test','Layout',NULL,NULL,999,0,1,'2026-09-24 14:23:15'),(436,0,'????A','M','/adv-a','Layout',NULL,NULL,999,0,1,'2026-09-24 14:36:44'),(437,5,'租户管理','C','/tenant','Tenant',NULL,'OfficeBuilding',9,1,1,'2026-09-24 16:06:00'),(438,437,'租户新增','F',NULL,NULL,'sys:tenant:add',NULL,1,1,1,'2026-09-24 16:06:00'),(439,437,'租户修改','F',NULL,NULL,'sys:tenant:edit',NULL,2,1,1,'2026-09-24 16:06:00'),(440,437,'租户删除','F',NULL,NULL,'sys:tenant:del',NULL,3,1,1,'2026-09-24 16:06:00'),(441,5,'敏感词管理','C','/sensitive','SensitiveWord',NULL,'Warning',10,1,1,'2026-09-24 16:19:19'),(442,441,'敏感词新增','F',NULL,NULL,'sys:sensitive:add',NULL,1,1,1,'2026-09-24 16:19:19'),(443,441,'敏感词修改','F',NULL,NULL,'sys:sensitive:edit',NULL,2,1,1,'2026-09-24 16:19:19'),(444,441,'敏感词删除','F',NULL,NULL,'sys:sensitive:del',NULL,3,1,1,'2026-09-24 16:19:19');
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_oper_log`
--

DROP TABLE IF EXISTS `sys_oper_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_oper_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `user_id` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `module` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `operation` varchar(128) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `method` varchar(16) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `uri` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `params` text COLLATE utf8mb4_general_ci,
  `result` tinyint DEFAULT '1',
  `error_msg` text COLLATE utf8mb4_general_ci,
  `cost_ms` bigint DEFAULT NULL,
  `ip` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_tenant_time` (`tenant_id`,`create_time`),
  KEY `idx_user` (`user_id`),
  KEY `idx_result` (`result`)
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='操作日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_oper_log`
--

LOCK TABLES `sys_oper_log` WRITE;
/*!40000 ALTER TABLE `sys_oper_log` DISABLE KEYS */;
INSERT INTO `sys_oper_log` VALUES (1,'__SYSTEM__',NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,0,'用户名或密码错误',10,'127.0.0.1','2026-09-23 14:54:07'),(2,'__SYSTEM__',NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,0,'用户名或密码错误',8,'127.0.0.1','2026-09-23 14:54:13'),(3,'__SYSTEM__',NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,844,'127.0.0.1','2026-09-23 14:54:47'),(4,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,914,'127.0.0.1','2026-09-24 10:34:44'),(5,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,80,'127.0.0.1','2026-09-24 10:37:09'),(6,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,927,'127.0.0.1','2026-09-24 10:43:03'),(7,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,109,'127.0.0.1','2026-09-24 10:51:25'),(8,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,912,'127.0.0.1','2026-09-24 11:04:26'),(9,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,909,'127.0.0.1','2026-09-24 11:22:42'),(10,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,110,'127.0.0.1','2026-09-24 11:46:32'),(11,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,109,'127.0.0.1','2026-09-24 11:49:07'),(12,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,78,'127.0.0.1','2026-09-24 11:49:11'),(13,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,77,'127.0.0.1','2026-09-24 11:49:13'),(14,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,95,'127.0.0.1','2026-09-24 11:51:49'),(15,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,144,'127.0.0.1','2026-09-24 13:35:43'),(16,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,90,'127.0.0.1','2026-09-24 13:40:36'),(17,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,949,'127.0.0.1','2026-09-24 14:12:06'),(18,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,0,'用户名或密码错误',82,'127.0.0.1','2026-09-24 14:12:56'),(19,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,0,'用户名或密码错误',83,'127.0.0.1','2026-09-24 14:13:48'),(20,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,75,'127.0.0.1','2026-09-24 14:15:56'),(21,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,88,'127.0.0.1','2026-09-24 14:22:11'),(22,'tenant_a','1','用户管理','新增用户','POST','/api/auth/user',NULL,0,'\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'tenant_id\' doesn\'t have a default value\r\n### The error may exist in com/gov/auth/mapper/SysUserMapper.java (best guess)\r\n### The error may involve com.gov.auth.mapper.SysUserMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO sys_user (username, password, real_name, roles, dept_id, data_scope, status) VALUES (?, ?, ?, ?, ?, ?, ?)\r\n### Cause: java.sql.SQLException: Field \'tenant_id\' doesn\'',217,'127.0.0.1','2026-09-24 14:22:21'),(23,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,810,'127.0.0.1','2026-09-24 14:22:56'),(24,'tenant_a','1','用户管理','新增用户','POST','/api/auth/user',NULL,0,'\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'tenant_id\' doesn\'t have a default value\r\n### The error may exist in com/gov/auth/mapper/SysUserMapper.java (best guess)\r\n### The error may involve com.gov.auth.mapper.SysUserMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO sys_user (username, password, real_name, roles, dept_id, data_scope, status) VALUES (?, ?, ?, ?, ?, ?, ?)\r\n### Cause: java.sql.SQLException: Field \'tenant_id\' doesn\'',227,'127.0.0.1','2026-09-24 14:23:05'),(25,'tenant_a','1','用户管理','新增用户','POST','/api/auth/user',NULL,0,'\r\n### Error updating database.  Cause: java.sql.SQLException: Field \'tenant_id\' doesn\'t have a default value\r\n### The error may exist in com/gov/auth/mapper/SysUserMapper.java (best guess)\r\n### The error may involve com.gov.auth.mapper.SysUserMapper.insert-Inline\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO sys_user (username, password, real_name, roles, dept_id, data_scope, status) VALUES (?, ?, ?, ?, ?, ?, ?)\r\n### Cause: java.sql.SQLException: Field \'tenant_id\' doesn\'',72,'127.0.0.1','2026-09-24 14:24:06'),(26,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,808,'127.0.0.1','2026-09-24 14:27:49'),(27,'tenant_a','1','用户管理','新增用户','POST','/api/auth/user',NULL,1,NULL,136,'127.0.0.1','2026-09-24 14:27:59'),(28,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,103,'127.0.0.1','2026-09-24 14:32:21'),(29,'tenant_a','1','用户管理','新增用户','POST','/api/auth/user',NULL,1,NULL,77,'127.0.0.1','2026-09-24 14:32:32'),(30,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,827,'127.0.0.1','2026-09-24 14:36:27'),(31,'tenant_a','1','用户管理','新增用户','POST','/api/auth/user',NULL,1,NULL,122,'127.0.0.1','2026-09-24 14:37:24'),(32,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,1107,'127.0.0.1','2026-09-24 15:03:31'),(33,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,79,'127.0.0.1','2026-09-24 15:05:13'),(34,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,74,'127.0.0.1','2026-09-24 15:06:21'),(35,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,78,'127.0.0.1','2026-09-24 15:07:24'),(36,'tenant_a','1','文件服务','上传文件','POST','/api/file/upload',NULL,1,NULL,375,'127.0.0.1','2026-09-24 15:07:46'),(37,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,791,'127.0.0.1','2026-09-24 15:11:24'),(38,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,904,'127.0.0.1','2026-09-24 15:25:19'),(39,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,93,'127.0.0.1','2026-09-24 15:27:58'),(40,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,86,'127.0.0.1','2026-09-24 15:28:00'),(41,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,76,'127.0.0.1','2026-09-24 15:28:44'),(42,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,76,'127.0.0.1','2026-09-24 15:31:14'),(43,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,74,'127.0.0.1','2026-09-24 15:32:19'),(44,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,75,'127.0.0.1','2026-09-24 15:35:04'),(45,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,900,'127.0.0.1','2026-09-24 15:35:40'),(46,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,80,'127.0.0.1','2026-09-24 15:36:12'),(47,'tenant_a','1','认证中心','用户登出','POST','/api/auth/logout','[\"Bearer eyJhbGciOiJIUzM4NCJ9.eyJ1aWQiOiIxIiwidGlkIjoidGVuYW50X2EiLCJyb2xlcyI6IlJPTEVfQURNSU4iLCJpYXQiOjE3OTAyMzUzNzEsImV4cCI6MTc5MDI3ODU3MX0.qYXNrh82b2T3cXFHVOJcRmoYijAGr6MSmplrNUDFizJT2D5UlhSSXi7J96HClux3\"]',1,NULL,28,'127.0.0.1','2026-09-24 15:37:14'),(48,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,73,'127.0.0.1','2026-09-24 15:37:15'),(49,'tenant_a','1','认证中心','用户登出','POST','/api/auth/logout','[\"Bearer eyJhbGciOiJIUzM4NCJ9.eyJ1aWQiOiIxIiwidGlkIjoidGVuYW50X2EiLCJyb2xlcyI6IlJPTEVfQURNSU4iLCJpYXQiOjE3OTAyMzU0MzUsImV4cCI6MTc5MDI3ODYzNX0.IhdhxUgGYPuNc1gH3qC9WW9TFbPzsMq3XM1O3iGWMGgcsUTI2An0I8GfdXhoY69V\"]',1,NULL,1,'127.0.0.1','2026-09-24 15:37:29'),(50,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,80,'127.0.0.1','2026-09-24 15:37:30'),(51,'tenant_a','1','认证中心','用户登出','POST','/api/auth/logout','[\"Bearer eyJhbGciOiJIUzM4NCJ9.eyJ1aWQiOiIxIiwidGlkIjoidGVuYW50X2EiLCJyb2xlcyI6IlJPTEVfQURNSU4iLCJpYXQiOjE3OTAyMzU0NTAsImV4cCI6MTc5MDI3ODY1MH0.ONYJUicSgsnOm_WB9j5N7EciThrvrRinCs_21bM-9--qZg_piugwSFp6-_fn1YoX\"]',1,NULL,1,'127.0.0.1','2026-09-24 15:37:37'),(52,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,80,'127.0.0.1','2026-09-24 15:37:38'),(53,'tenant_a','1','认证中心','用户登出','POST','/api/auth/logout','[\"Bearer eyJhbGciOiJIUzM4NCJ9.eyJ1aWQiOiIxIiwidGlkIjoidGVuYW50X2EiLCJyb2xlcyI6IlJPTEVfQURNSU4iLCJpYXQiOjE3OTAyMzU0NTgsImV4cCI6MTc5MDI3ODY1OH0.fZelm3ocVIoRgXihf5CaplFV6YOfR8vbd4kRm8qTmheonMdKXII5IdBZAv-TP4wi\"]',1,NULL,2,'127.0.0.1','2026-09-24 15:41:03'),(54,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,86,'127.0.0.1','2026-09-24 15:41:04'),(55,'tenant_a','1','认证中心','用户登出','POST','/api/auth/logout','[\"Bearer eyJhbGciOiJIUzM4NCJ9.eyJ1aWQiOiIxIiwidGlkIjoidGVuYW50X2EiLCJyb2xlcyI6IlJPTEVfQURNSU4iLCJpYXQiOjE3OTAyMzU2NjQsImV4cCI6MTc5MDI3ODg2NH0.tka3PZtLyhBvWbYBaKP0wdY06WkHu-ZRU8rwajl3JKMxFqf5hbESkHgSybUOULt-\"]',1,NULL,2,'127.0.0.1','2026-09-24 15:41:10'),(56,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,74,'127.0.0.1','2026-09-24 15:41:11'),(57,'tenant_a','1','文件服务','删除文件','DELETE','/api/file','[\"tenant_a/2026/0924/27ddb89f7ae749fe9d6ddfef0da6d141.txt\"]',1,NULL,15,'127.0.0.1','2026-09-24 15:41:25'),(58,'tenant_a','1','文件服务','删除文件','DELETE','/api/file','[\"tenant_a/2026/0924/27ddb89f7ae749fe9d6ddfef0da6d141.txt\"]',1,NULL,10,'127.0.0.1','2026-09-24 15:41:37'),(59,'tenant_a','1','文件服务','上传文件','POST','/api/file/upload',NULL,1,NULL,41,'127.0.0.1','2026-09-24 15:42:00'),(60,'tenant_a','1','文件服务','删除文件','DELETE','/api/file','[\"tenant_a/2026/0924/27ddb89f7ae749fe9d6ddfef0da6d141.txt\"]',1,NULL,2,'127.0.0.1','2026-09-24 15:42:08'),(61,'tenant_a','1','文件服务','删除文件','DELETE','/api/file','[\"tenant_a/2026/0924/27ddb89f7ae749fe9d6ddfef0da6d141.txt\"]',1,NULL,9,'127.0.0.1','2026-09-24 15:45:32'),(62,'tenant_a','1','文件服务','删除文件','DELETE','/api/file','[\"tenant_a/2026/0924/67624c5bd18148ee8bebc710434ec903.txt\"]',1,NULL,7,'127.0.0.1','2026-09-24 15:47:55'),(63,'tenant_a','1','文件服务','删除文件','DELETE','/api/file','[\"tenant_a/2026/0924/27ddb89f7ae749fe9d6ddfef0da6d141.txt\"]',1,NULL,22,'127.0.0.1','2026-09-24 15:49:04'),(64,'tenant_a','1','文件服务','删除文件','DELETE','/api/file','[\"tenant_a/2026/0924/67624c5bd18148ee8bebc710434ec903.txt\"]',1,NULL,11,'127.0.0.1','2026-09-24 15:55:22'),(65,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,920,'127.0.0.1','2026-09-24 16:19:43'),(66,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,873,'127.0.0.1','2026-09-24 16:20:33'),(67,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,80,'127.0.0.1','2026-09-24 16:20:36'),(68,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,74,'127.0.0.1','2026-09-24 16:22:01'),(69,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,77,'127.0.0.1','2026-09-24 16:24:26'),(70,'tenant_a','1','认证中心','用户登出','POST','/api/auth/logout','[\"Bearer eyJhbGciOiJIUzM4NCJ9.eyJ1aWQiOiIxIiwidGlkIjoidGVuYW50X2EiLCJyb2xlcyI6IlJPTEVfQURNSU4iLCJpYXQiOjE3OTAyMzgyNjYsImV4cCI6MTc5MDI4MTQ2Nn0.pLpRoS7cbSMhJJq5Mh1wHmPsWS8BhFaXtBs_3zk_2lmZdt5bdBPf2N7jqxw2uwdq\"]',1,NULL,31,'127.0.0.1','2026-09-24 16:31:36'),(71,NULL,NULL,'认证中心','用户登录','POST','/api/auth/login',NULL,1,NULL,97,'127.0.0.1','2026-09-24 16:31:37');
/*!40000 ALTER TABLE `sys_oper_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role`
--

DROP TABLE IF EXISTS `sys_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '租户ID',
  `role_name` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色标识，如 ROLE_ADMIN',
  `role_sort` int DEFAULT '0' COMMENT '排序',
  `data_scope` tinyint DEFAULT '3' COMMENT '默认数据范围: 1全部 2本部门及以下 3本部门 4仅本人',
  `status` tinyint DEFAULT '1' COMMENT '1启用 0禁用',
  `remark` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_role_key` (`tenant_id`,`role_key`),
  KEY `idx_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES (1,'tenant_a','超级管理员','ROLE_ADMIN',1,1,1,'A市超级管理员，拥有全部权限','2026-09-23 11:12:49','2026-09-23 11:12:49'),(2,'tenant_a','普通用户','ROLE_USER',2,3,1,'A市普通办事员，本部门权限','2026-09-23 11:12:49','2026-09-23 11:12:49'),(3,'tenant_b','超级管理员','ROLE_ADMIN',1,1,1,'B市超级管理员，拥有全部权限','2026-09-23 11:12:49','2026-09-23 11:12:49');
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_dept`
--

DROP TABLE IF EXISTS `sys_role_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_dept` (
  `role_id` bigint NOT NULL,
  `dept_id` bigint NOT NULL,
  PRIMARY KEY (`role_id`,`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色-部门关联表（数据范围=2 时使用）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_dept`
--

LOCK TABLES `sys_role_dept` WRITE;
/*!40000 ALTER TABLE `sys_role_dept` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_role_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_menu`
--

DROP TABLE IF EXISTS `sys_role_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_menu` (
  `role_id` bigint NOT NULL,
  `menu_id` bigint NOT NULL,
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色-菜单关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_menu`
--

LOCK TABLES `sys_role_menu` WRITE;
/*!40000 ALTER TABLE `sys_role_menu` DISABLE KEYS */;
INSERT INTO `sys_role_menu` VALUES (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,10),(1,11),(1,12),(1,13),(1,14),(1,20),(1,21),(1,30),(1,31),(1,40),(1,41),(1,42),(1,43),(1,44),(1,45),(1,46),(1,47),(1,401),(1,402),(1,403),(1,404),(1,405),(1,420),(1,421),(1,422),(1,423),(1,424),(1,430),(1,431),(1,432),(1,434),(1,437),(1,438),(1,439),(1,440),(1,441),(1,442),(1,443),(1,444),(2,1),(2,2),(2,3),(2,4),(2,5),(2,6),(2,10),(2,11),(2,12),(2,13),(2,14),(2,20),(2,21),(2,30),(2,31),(2,42),(2,421),(2,422),(2,423),(2,424),(2,434),(3,1),(3,2),(3,3),(3,4),(3,5),(3,6),(3,10),(3,11),(3,12),(3,13),(3,14),(3,20),(3,21),(3,30),(3,31),(3,40),(3,41),(3,42),(3,43),(3,44),(3,45),(3,46),(3,47),(3,401),(3,402),(3,403),(3,404),(3,405),(3,420),(3,421),(3,422),(3,423),(3,424),(3,430),(3,431),(3,432),(3,434);
/*!40000 ALTER TABLE `sys_role_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_sensitive_word`
--

DROP TABLE IF EXISTS `sys_sensitive_word`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_sensitive_word` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `word` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `category` varchar(32) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_word` (`tenant_id`,`word`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='敏感词表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_sensitive_word`
--

LOCK TABLES `sys_sensitive_word` WRITE;
/*!40000 ALTER TABLE `sys_sensitive_word` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_sensitive_word` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_tenant`
--

DROP TABLE IF EXISTS `sys_tenant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_tenant` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '租户标识，如 tenant_a',
  `tenant_name` varchar(128) COLLATE utf8mb4_general_ci NOT NULL COMMENT '租户名称',
  `contact` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系人',
  `phone` varchar(32) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '联系电话',
  `expire_date` date DEFAULT NULL COMMENT '到期日期',
  `status` tinyint DEFAULT '1' COMMENT '1启用 0禁用',
  `remark` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tenant_id` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='租户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_tenant`
--

LOCK TABLES `sys_tenant` WRITE;
/*!40000 ALTER TABLE `sys_tenant` DISABLE KEYS */;
INSERT INTO `sys_tenant` VALUES (1,'tenant_a','A市政府','张三',NULL,NULL,1,'示例租户 A','2026-09-24 15:57:44','2026-09-24 15:57:44'),(2,'tenant_b','B市政府','李四',NULL,NULL,1,'示例租户 B','2026-09-24 15:57:44','2026-09-24 15:57:44');
/*!40000 ALTER TABLE `sys_tenant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名',
  `password` varchar(128) COLLATE utf8mb4_general_ci NOT NULL COMMENT '密码（生产建议 BCrypt）',
  `real_name` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '真实姓名',
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '租户ID',
  `roles` varchar(256) COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色，逗号分隔',
  `dept_id` bigint DEFAULT NULL COMMENT '部门ID',
  `data_scope` tinyint DEFAULT '3' COMMENT '数据范围: 1全部 2本部门及以下 3本部门 4仅本人',
  `status` tinyint DEFAULT '1' COMMENT '1启用 0禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `idx_tenant` (`tenant_id`),
  KEY `idx_dept` (`dept_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='系统用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES (1,'admin','$2a$10$JbAfNi.fJcj81EU.Zl0yxe2hYpkZ0kXmG8ahW9kgAgg49WDhuH4pC','市级管理员','tenant_a','ROLE_ADMIN',1,1,1,'2026-09-16 09:19:50','2026-09-23 17:26:59'),(2,'user','$2a$10$JbAfNi.fJcj81EU.Zl0yxe2hYpkZ0kXmG8ahW9kgAgg49WDhuH4pC','普通办事员','tenant_a','ROLE_USER',4,3,1,'2026-09-23 14:54:01','2026-09-24 14:17:24'),(3,'dept_leader','$2a$10$JbAfNi.fJcj81EU.Zl0yxe2hYpkZ0kXmG8ahW9kgAgg49WDhuH4pC','财政局局长','tenant_a','ROLE_ADMIN',2,2,1,'2026-09-23 14:54:01','2026-09-24 14:17:42'),(4,'clerk','$2a$10$JbAfNi.fJcj81EU.Zl0yxe2hYpkZ0kXmG8ahW9kgAgg49WDhuH4pC','预算科科员','tenant_a','ROLE_USER',4,3,1,'2026-09-23 14:54:01','2026-09-24 14:17:42'),(5,'gov_b_admin','$2a$10$JbAfNi.fJcj81EU.Zl0yxe2hYpkZ0kXmG8ahW9kgAgg49WDhuH4pC','B市管理员','tenant_b','ROLE_ADMIN',6,1,1,'2026-09-23 14:54:01','2026-09-24 14:17:42');
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_role`
--

DROP TABLE IF EXISTS `sys_user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_role` (
  `user_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户-角色关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_role`
--

LOCK TABLES `sys_user_role` WRITE;
/*!40000 ALTER TABLE `sys_user_role` DISABLE KEYS */;
INSERT INTO `sys_user_role` VALUES (1,1),(2,2),(3,3),(4,1),(5,2);
/*!40000 ALTER TABLE `sys_user_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_application`
--

DROP TABLE IF EXISTS `t_application`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_application` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `dept_id` bigint DEFAULT NULL COMMENT '创建部门ID',
  `create_by` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '创建人ID',
  `title` varchar(256) COLLATE utf8mb4_general_ci NOT NULL,
  `applicant` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` varchar(32) COLLATE utf8mb4_general_ci DEFAULT 'DRAFT' COMMENT 'DRAFT/PENDING/APPROVED/REJECTED',
  `process_instance_id` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Flowable 流程实例ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_tenant` (`tenant_id`),
  KEY `idx_dept` (`dept_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='事项表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_application`
--

LOCK TABLES `t_application` WRITE;
/*!40000 ALTER TABLE `t_application` DISABLE KEYS */;
INSERT INTO `t_application` VALUES (1,'tenant_a',2,'1','A市企业注册申请','张三','PENDING',NULL,'2026-09-23 14:54:01'),(2,'tenant_a',2,'1','A市营业执照变更','李四','APPROVED',NULL,'2026-09-23 14:54:01'),(3,'tenant_a',2,'1','A市税务登记','王五','DRAFT',NULL,'2026-09-23 14:54:01'),(4,'tenant_b',6,'3','B市食品经营许可','赵六','PENDING',NULL,'2026-09-23 14:54:01'),(5,'tenant_b',6,'3','B市建设项目审批','孙七','APPROVED',NULL,'2026-09-23 14:54:01');
/*!40000 ALTER TABLE `t_application` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_application_log`
--

DROP TABLE IF EXISTS `t_application_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_application_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `application_id` bigint NOT NULL,
  `action` varchar(32) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'SUBMIT/APPROVE/REJECT/WITHDRAW/ARCHIVE',
  `action_name` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '动作中文名',
  `operator` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '操作人',
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_app` (`application_id`),
  KEY `idx_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='办件流转日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_application_log`
--

LOCK TABLES `t_application_log` WRITE;
/*!40000 ALTER TABLE `t_application_log` DISABLE KEYS */;
INSERT INTO `t_application_log` VALUES (1,'tenant_a',1,'SUBMIT','提交申请','系统初始化','历史数据初始化','2026-09-23 14:54:01'),(2,'tenant_a',2,'SUBMIT','提交申请','系统初始化','历史数据初始化','2026-09-23 14:54:01'),(3,'tenant_a',3,'SUBMIT','提交申请','系统初始化','历史数据初始化','2026-09-23 14:54:01'),(4,'tenant_b',4,'SUBMIT','提交申请','系统初始化','历史数据初始化','2026-09-23 14:54:01'),(5,'tenant_b',5,'SUBMIT','提交申请','系统初始化','历史数据初始化','2026-09-23 14:54:01');
/*!40000 ALTER TABLE `t_application_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_appointment`
--

DROP TABLE IF EXISTS `t_appointment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_appointment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `appointment_no` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `guide_code` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `guide_title` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `visitor_name` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `visitor_phone` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `visitor_id_card` varchar(32) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `dept_id` bigint DEFAULT NULL,
  `appoint_date` date NOT NULL,
  `time_slot` varchar(32) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `queue_no` varchar(16) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` varchar(32) COLLATE utf8mb4_general_ci DEFAULT 'BOOKED' COMMENT 'BOOKED/CHECKED/DONE/CANCELLED/EXPIRED',
  `checkin_time` datetime DEFAULT NULL,
  `finish_time` datetime DEFAULT NULL,
  `cancel_reason` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `remark` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_appointment_no` (`appointment_no`),
  KEY `idx_tenant_date` (`tenant_id`,`appoint_date`),
  KEY `idx_status` (`status`),
  KEY `idx_visitor_phone` (`visitor_phone`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='预约取号表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_appointment`
--

LOCK TABLES `t_appointment` WRITE;
/*!40000 ALTER TABLE `t_appointment` DISABLE KEYS */;
INSERT INTO `t_appointment` VALUES (1,'tenant_a','APT-20260923-001','GUIDE-001','营业执照办理','张三','13800000001',NULL,2,'2026-09-23','09:00-10:00','A001','BOOKED',NULL,NULL,NULL,NULL,'2026-09-23 14:54:01'),(2,'tenant_a','APT-20260923-002','GUIDE-002','税务登记','李四','13800000002',NULL,2,'2026-09-23','10:00-11:00','A002','BOOKED',NULL,NULL,NULL,NULL,'2026-09-23 14:54:01'),(3,'tenant_a','APT-20260923-003','GUIDE-001','营业执照办理','王五','13800000003',NULL,2,'2026-09-23','14:00-15:00','A003','CHECKED',NULL,NULL,NULL,NULL,'2026-09-23 14:54:01');
/*!40000 ALTER TABLE `t_appointment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_attachment`
--

DROP TABLE IF EXISTS `t_attachment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_attachment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `biz_type` varchar(32) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'APPLICATION/GUIDE/EVALUATION',
  `biz_id` bigint NOT NULL,
  `file_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `file_name` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_biz` (`biz_type`,`biz_id`),
  KEY `idx_tenant` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='业务附件关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_attachment`
--

LOCK TABLES `t_attachment` WRITE;
/*!40000 ALTER TABLE `t_attachment` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_attachment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_consult`
--

DROP TABLE IF EXISTS `t_consult`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_consult` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `consult_no` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `type` varchar(32) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'CONSULT/COMPLAINT/SUGGEST',
  `title` varchar(256) COLLATE utf8mb4_general_ci NOT NULL,
  `content` text COLLATE utf8mb4_general_ci NOT NULL,
  `contact_name` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `contact_phone` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `dept_id` bigint DEFAULT NULL,
  `handler` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `reply` text COLLATE utf8mb4_general_ci,
  `reply_time` datetime DEFAULT NULL,
  `status` varchar(32) COLLATE utf8mb4_general_ci DEFAULT 'PENDING' COMMENT 'PENDING/PROCESSING/DONE/CLOSED',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_consult_no` (`consult_no`),
  KEY `idx_tenant` (`tenant_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='咨询投诉表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_consult`
--

LOCK TABLES `t_consult` WRITE;
/*!40000 ALTER TABLE `t_consult` DISABLE KEYS */;
INSERT INTO `t_consult` VALUES (1,'tenant_a','CON-20260923-001','CONSULT','营业执照办理需要什么材料？','我想开一家餐饮店，请问营业执照需要哪些材料？','张三','13800000001',2,NULL,NULL,NULL,'PENDING','2026-09-23 14:54:01'),(2,'tenant_a','CON-20260923-002','COMPLAINT','窗口人员服务态度差','今天下午3点，3号窗口工作人员态度冷淡。','李四','13800000002',2,NULL,NULL,NULL,'PROCESSING','2026-09-23 14:54:01');
/*!40000 ALTER TABLE `t_consult` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_evaluation`
--

DROP TABLE IF EXISTS `t_evaluation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_evaluation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `application_id` bigint DEFAULT NULL,
  `business_key` varchar(128) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `evaluator` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `evaluator_phone` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `score` tinyint NOT NULL COMMENT '1~5',
  `content` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `channel` varchar(32) COLLATE utf8mb4_general_ci DEFAULT 'ONLINE' COMMENT 'ONLINE/APP/WINDOW/PHONE',
  `is_bad` tinyint DEFAULT '0',
  `rectify_status` varchar(32) COLLATE utf8mb4_general_ci DEFAULT 'NONE' COMMENT 'NONE/PENDING/DONE',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_tenant` (`tenant_id`),
  KEY `idx_app` (`application_id`),
  KEY `idx_bad` (`is_bad`,`rectify_status`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='好差评评价表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_evaluation`
--

LOCK TABLES `t_evaluation` WRITE;
/*!40000 ALTER TABLE `t_evaluation` DISABLE KEYS */;
INSERT INTO `t_evaluation` VALUES (1,'tenant_a',1,'APP-001','张三',NULL,5,'办理很快，服务态度好','ONLINE',0,'NONE','2026-09-23 14:54:01'),(2,'tenant_a',2,'APP-002','李四',NULL,4,'总体满意','APP',0,'NONE','2026-09-23 14:54:01'),(3,'tenant_a',3,'APP-003','王五',NULL,1,'等待时间太长','WINDOW',1,'PENDING','2026-09-23 14:54:01');
/*!40000 ALTER TABLE `t_evaluation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_evaluation_rectify`
--

DROP TABLE IF EXISTS `t_evaluation_rectify`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_evaluation_rectify` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `evaluation_id` bigint NOT NULL,
  `rectifier` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `rectify_content` varchar(1000) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `rectify_time` datetime DEFAULT NULL,
  `status` varchar(32) COLLATE utf8mb4_general_ci DEFAULT 'PENDING' COMMENT 'PENDING/DONE',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_eval` (`evaluation_id`),
  KEY `idx_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='差评整改表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_evaluation_rectify`
--

LOCK TABLES `t_evaluation_rectify` WRITE;
/*!40000 ALTER TABLE `t_evaluation_rectify` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_evaluation_rectify` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_file`
--

DROP TABLE IF EXISTS `t_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_file` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `file_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `user_id` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `original_name` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `object_name` varchar(512) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'MinIO 对象路径',
  `content_type` varchar(128) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `size` bigint DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_file_id` (`file_id`),
  KEY `idx_tenant` (`tenant_id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='文件信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_file`
--

LOCK TABLES `t_file` WRITE;
/*!40000 ALTER TABLE `t_file` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_file` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_guide`
--

DROP TABLE IF EXISTS `t_guide`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_guide` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `guide_code` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `title` varchar(256) COLLATE utf8mb4_general_ci NOT NULL,
  `category` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `dept_id` bigint DEFAULT NULL,
  `service_object` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `legal_basis` text COLLATE utf8mb4_general_ci,
  `conditions` text COLLATE utf8mb4_general_ci,
  `materials` text COLLATE utf8mb4_general_ci,
  `process_desc` text COLLATE utf8mb4_general_ci,
  `legal_days` int DEFAULT NULL,
  `promise_days` int DEFAULT NULL,
  `charge_standard` varchar(256) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `consult_phone` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `online_url` varchar(512) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` tinyint DEFAULT '1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`tenant_id`,`guide_code`),
  KEY `idx_tenant` (`tenant_id`),
  KEY `idx_dept` (`dept_id`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='办事指南表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_guide`
--

LOCK TABLES `t_guide` WRITE;
/*!40000 ALTER TABLE `t_guide` DISABLE KEYS */;
INSERT INTO `t_guide` VALUES (1,'tenant_a','GUIDE-001','营业执照办理','企业登记',2,'企业法人、个体工商户','《中华人民共和国公司法》《市场主体登记管理条例》','1. 有符合规定的名称；2. 有固定的经营场所；3. 有符合规定的经营范围。','1. 申请书；\n2. 法人身份证复印件；\n3. 经营场所证明；\n4. 公司章程。','申请 → 受理 → 审核 → 发证',15,3,'免费','0571-88880001','https://zwfw.gov.cn/business',1,'2026-09-23 14:54:01','2026-09-23 14:54:01'),(2,'tenant_a','GUIDE-002','税务登记','税务',2,'企业法人','《中华人民共和国税收征收管理法》','已取得营业执照，且在法定期限内。','1. 营业执照副本；\n2. 法人身份证；\n3. 银行开户许可证。','受理 → 核实 → 登记 → 发放税务登记证',5,1,'免费','0571-88880002','https://zwfw.gov.cn/tax',1,'2026-09-23 14:54:01','2026-09-23 14:54:01'),(3,'tenant_a','GUIDE-003','食品经营许可证','市场监督',2,'餐饮企业、食品销售企业','《中华人民共和国食品安全法》《食品经营许可管理办法》','1. 有营业执照；2. 有符合要求的经营场所和设备；3. 有食品安全管理制度。','1. 申请书；\n2. 营业执照；\n3. 经营场所平面图；\n4. 从业人员健康证。','申请 → 现场核查 → 审批 → 发证',20,10,'免费','0571-88880003','https://zwfw.gov.cn/food',1,'2026-09-23 14:54:01','2026-09-23 14:54:01'),(4,'tenant_a','GUIDE-004','建设工程规划许可证','建设规划',2,'建设单位','《中华人民共和国城乡规划法》','1. 已取得土地使用权；2. 有符合规划的建设项目。','1. 申请表；\n2. 土地证；\n3. 设计方案；\n4. 环评报告。','申请 → 受理 → 公示 → 审批 → 发证',30,15,'按建筑面积收费','0571-88880004','https://zwfw.gov.cn/construction',1,'2026-09-23 14:54:01','2026-09-23 14:54:01');
/*!40000 ALTER TABLE `t_guide` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_license`
--

DROP TABLE IF EXISTS `t_license`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_license` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `license_no` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `template_code` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `holder_name` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `holder_id_card` varchar(32) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `issue_dept` varchar(128) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `issue_date` date DEFAULT NULL,
  `expire_date` date DEFAULT NULL,
  `content_json` text COLLATE utf8mb4_general_ci,
  `file_url` varchar(512) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `verify_code` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` varchar(32) COLLATE utf8mb4_general_ci DEFAULT 'VALID' COMMENT 'VALID/REVOKED/EXPIRED',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_license_no` (`license_no`),
  UNIQUE KEY `uk_verify_code` (`verify_code`),
  KEY `idx_tenant` (`tenant_id`),
  KEY `idx_holder` (`holder_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='电子证照表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_license`
--

LOCK TABLES `t_license` WRITE;
/*!40000 ALTER TABLE `t_license` DISABLE KEYS */;
/*!40000 ALTER TABLE `t_license` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_license_template`
--

DROP TABLE IF EXISTS `t_license_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_license_template` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `template_code` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
  `template_name` varchar(128) COLLATE utf8mb4_general_ci NOT NULL,
  `license_type` varchar(64) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `fields_json` text COLLATE utf8mb4_general_ci,
  `status` tinyint DEFAULT '1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_code` (`tenant_id`,`template_code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='证照模板表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_license_template`
--

LOCK TABLES `t_license_template` WRITE;
/*!40000 ALTER TABLE `t_license_template` DISABLE KEYS */;
INSERT INTO `t_license_template` VALUES (1,'tenant_a','BUSINESS_LICENSE','营业执照','企业证照','[\"holderName\",\"holderIdCard\",\"issueDept\",\"issueDate\",\"expireDate\",\"content\"]',1,'2026-09-23 14:54:01'),(2,'tenant_a','TAX_REGISTER','税务登记证','企业证照','[\"holderName\",\"holderIdCard\",\"issueDept\",\"issueDate\",\"content\"]',1,'2026-09-23 14:54:01'),(3,'tenant_a','FOOD_PERMIT','食品经营许可证','经营证照','[\"holderName\",\"holderIdCard\",\"issueDept\",\"issueDate\",\"expireDate\",\"content\"]',1,'2026-09-23 14:54:01');
/*!40000 ALTER TABLE `t_license_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_notify`
--

DROP TABLE IF EXISTS `t_notify`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_notify` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '租户ID',
  `receiver` varchar(64) COLLATE utf8mb4_general_ci NOT NULL COMMENT '接收人',
  `title` varchar(128) COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题',
  `content` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '内容',
  `type` varchar(32) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'TASK/EVALUATION/SYSTEM',
  `biz_id` bigint DEFAULT NULL COMMENT '关联业务ID',
  `is_read` tinyint DEFAULT '0' COMMENT '0未读 1已读',
  `read_time` datetime DEFAULT NULL,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_receiver` (`tenant_id`,`receiver`,`is_read`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='消息通知表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_notify`
--

LOCK TABLES `t_notify` WRITE;
/*!40000 ALTER TABLE `t_notify` DISABLE KEYS */;
INSERT INTO `t_notify` VALUES (1,'tenant_a','市级管理员','系统通知','欢迎使用政务管理系统，祝您工作愉快！','SYSTEM',NULL,0,NULL,'2026-09-23 14:54:01'),(2,'tenant_a','市级管理员','待办提醒','您有 3 条事项待审批，请及时处理','TASK',NULL,0,NULL,'2026-09-23 14:54:01'),(3,'tenant_a','市级管理员','办件完成','事项「A市营业执照变更」已审批通过','SYSTEM',NULL,1,NULL,'2026-09-22 14:54:01'),(4,'tenant_b','B市管理员','系统通知','B市政务系统已上线','SYSTEM',NULL,0,NULL,'2026-09-23 14:54:01');
/*!40000 ALTER TABLE `t_notify` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_process_instance`
--

DROP TABLE IF EXISTS `t_process_instance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_process_instance` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `process_key` varchar(64) NOT NULL COMMENT '流程定义key',
  `business_key` varchar(128) DEFAULT NULL COMMENT '业务主键',
  `applicant` varchar(64) NOT NULL COMMENT '发起人',
  `status` varchar(16) NOT NULL COMMENT 'RUNNING/COMPLETED',
  `current_activity` varchar(64) DEFAULT NULL COMMENT '当前节点key',
  `tenant_id` varchar(64) NOT NULL COMMENT '租户ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `finish_time` datetime DEFAULT NULL,
  `variables` text COMMENT '流程变量JSON',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_status` (`tenant_id`,`status`),
  KEY `idx_business_key` (`business_key`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='流程实例';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_process_instance`
--

LOCK TABLES `t_process_instance` WRITE;
/*!40000 ALTER TABLE `t_process_instance` DISABLE KEYS */;
INSERT INTO `t_process_instance` VALUES (1,'leaveApproval','LEAVE-20260918154851','ZhangSan','RUNNING','deptLeaderTask','tenant_a','2026-09-18 15:48:52',NULL,'{\"tenantId\":\"tenant_a\",\"days\":5,\"hr\":\"ZhaoLiu\",\"deptLeader\":\"LiSi\",\"director\":\"WangWu\",\"applicant\":\"ZhangSan\"}'),(2,'leaveApproval','LEAVE-20260918155155','ZhangSan','RUNNING','deptLeaderTask','tenant_a','2026-09-18 15:51:55',NULL,'{\"tenantId\":\"tenant_a\",\"days\":5,\"hr\":\"ZhaoLiu\",\"deptLeader\":\"LiSi\",\"director\":\"WangWu\",\"applicant\":\"ZhangSan\"}');
/*!40000 ALTER TABLE `t_process_instance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_process_task`
--

DROP TABLE IF EXISTS `t_process_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_process_task` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `instance_id` bigint NOT NULL COMMENT '流程实例ID',
  `task_key` varchar(64) NOT NULL COMMENT '任务节点key',
  `task_name` varchar(64) NOT NULL COMMENT '任务名称',
  `assignee` varchar(64) DEFAULT NULL COMMENT '处理人',
  `status` varchar(16) NOT NULL COMMENT 'PENDING/COMPLETED',
  `tenant_id` varchar(64) NOT NULL COMMENT '租户ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `complete_time` datetime DEFAULT NULL,
  `comment` text COMMENT '审批意见',
  PRIMARY KEY (`id`),
  KEY `idx_instance` (`instance_id`),
  KEY `idx_assignee_status` (`assignee`,`status`,`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='流程任务';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_process_task`
--

LOCK TABLES `t_process_task` WRITE;
/*!40000 ALTER TABLE `t_process_task` DISABLE KEYS */;
INSERT INTO `t_process_task` VALUES (1,1,'deptLeaderTask','部门领导审批','LiSi','PENDING','tenant_a','2026-09-18 15:48:52',NULL,NULL),(2,2,'deptLeaderTask','部门领导审批','LiSi','PENDING','tenant_a','2026-09-18 15:51:55',NULL,NULL);
/*!40000 ALTER TABLE `t_process_task` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `undo_log`
--

DROP TABLE IF EXISTS `undo_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `undo_log` (
  `branch_id` bigint NOT NULL,
  `xid` varchar(128) COLLATE utf8mb4_general_ci NOT NULL,
  `context` varchar(128) COLLATE utf8mb4_general_ci NOT NULL,
  `rollback_info` longblob NOT NULL,
  `log_status` int NOT NULL,
  `log_created` datetime(6) NOT NULL,
  `log_modified` datetime(6) NOT NULL,
  UNIQUE KEY `ux_undo_log` (`xid`,`branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Seata AT 模式回滚表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `undo_log`
--

LOCK TABLES `undo_log` WRITE;
/*!40000 ALTER TABLE `undo_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `undo_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'gov_db'
--

--
-- Dumping routines for database 'gov_db'
--

--
-- Current Database: `nacos_config`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `nacos_config` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `nacos_config`;

--
-- Table structure for table `ai_resource`
--

DROP TABLE IF EXISTS `ai_resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_resource` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  `name` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资源名称',
  `type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资源类型',
  `c_desc` varchar(2048) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '资源描述',
  `status` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '资源状态',
  `namespace_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '命名空间ID',
  `biz_tags` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '业务标签',
  `ext` longtext COLLATE utf8mb4_unicode_ci COMMENT '扩展信息(JSON)',
  `c_from` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'local' COMMENT '来源标识(导入/同步来源)',
  `version_info` longtext COLLATE utf8mb4_unicode_ci COMMENT '版本信息(JSON)',
  `meta_version` bigint NOT NULL DEFAULT '1' COMMENT '元数据版本(乐观锁)',
  `scope` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PRIVATE' COMMENT '可见性: PUBLIC/PRIVATE',
  `owner` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '创建者用户名',
  `download_count` bigint NOT NULL DEFAULT '0' COMMENT '下载次数',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ai_resource_ns_name_type` (`namespace_id`,`name`,`type`,`c_from`),
  KEY `idx_ai_resource_name` (`name`),
  KEY `idx_ai_resource_type` (`type`),
  KEY `idx_ai_resource_gmt_modified` (`gmt_modified`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI资源元数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_resource`
--

LOCK TABLES `ai_resource` WRITE;
/*!40000 ALTER TABLE `ai_resource` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_resource` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_resource_version`
--

DROP TABLE IF EXISTS `ai_resource_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_resource_version` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  `type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资源类型',
  `author` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '作者',
  `name` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资源名称',
  `c_desc` varchar(2048) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '版本描述',
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '版本状态',
  `version` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '版本号',
  `namespace_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '命名空间ID',
  `storage` longtext COLLATE utf8mb4_unicode_ci COMMENT '存储信息(JSON)',
  `publish_pipeline_info` longtext COLLATE utf8mb4_unicode_ci COMMENT '发布流水线信息(JSON)',
  `download_count` bigint NOT NULL DEFAULT '0' COMMENT '下载次数',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ai_resource_ver_ns_name_type_ver` (`namespace_id`,`name`,`type`,`version`),
  KEY `idx_ai_resource_ver_name` (`name`),
  KEY `idx_ai_resource_ver_status` (`status`),
  KEY `idx_ai_resource_ver_gmt_modified` (`gmt_modified`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI资源版本表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_resource_version`
--

LOCK TABLES `ai_resource_version` WRITE;
/*!40000 ALTER TABLE `ai_resource_version` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_resource_version` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config_info`
--

DROP TABLE IF EXISTS `config_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `config_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `data_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'data_id',
  `group_id` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'group_id',
  `content` longtext COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'content',
  `md5` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'md5',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  `src_user` text COLLATE utf8mb4_unicode_ci COMMENT 'source user',
  `src_ip` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'source ip',
  `app_name` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'app_name',
  `tenant_id` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '租户字段',
  `c_desc` varchar(256) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'configuration description',
  `c_use` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'configuration usage',
  `effect` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '配置生效的描述',
  `type` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '配置的类型',
  `c_schema` text COLLATE utf8mb4_unicode_ci COMMENT '配置的模式',
  `encrypted_data_key` varchar(1024) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '密钥',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_configinfo_datagrouptenant` (`data_id`,`group_id`,`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='config_info';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config_info`
--

LOCK TABLES `config_info` WRITE;
/*!40000 ALTER TABLE `config_info` DISABLE KEYS */;
INSERT INTO `config_info` VALUES (10,'gateway-routes.yaml','DEFAULT_GROUP','spring:\r\n  cloud:\r\n    gateway:\r\n      routes:\r\n        - id: gov-auth\r\n          uri: lb://gov-auth\r\n          predicates:\r\n            - Path=/api/auth/**,/api/user/**,/api/loginlog/**\r\n        - id: gov-file\r\n          uri: lb://gov-file\r\n          predicates:\r\n            - Path=/api/file/**,/api/attachment/**\r\n        - id: gov-application\r\n          uri: lb://gov-application\r\n          predicates:\r\n            - Path=/api/application/**,/api/process/**,/api/operlog/**,/api/dashboard/**,/api/dept/**,/api/screen/**,/api/report/**,/api/evaluation/**,/api/license/**,/api/dict/**,/api/config/**,/api/guide/**,/api/appointment/**,/api/notify/**,/api/consult/**,/api/workspace/**,/api/role/**,/api/menu/**,/api/sensitive/**','f55ca82eeb3717728abd26b9ad0217be','2026-09-23 16:09:28','2026-09-24 16:23:55','nacos_namespace_migrate','0:0:0:0:0:0:0:1','','','网关路由配置',NULL,NULL,'yaml',NULL,''),(11,'gateway-routes.yaml','DEFAULT_GROUP','spring:\r\n  cloud:\r\n    gateway:\r\n      routes:\r\n        - id: gov-auth\r\n          uri: lb://gov-auth\r\n          predicates:\r\n            - Path=/api/auth/**,/api/user/**,/api/loginlog/**\r\n        - id: gov-file\r\n          uri: lb://gov-file\r\n          predicates:\r\n            - Path=/api/file/**,/api/attachment/**\r\n        - id: gov-application\r\n          uri: lb://gov-application\r\n          predicates:\r\n            - Path=/api/application/**,/api/process/**,/api/operlog/**,/api/dashboard/**,/api/dept/**,/api/screen/**,/api/report/**,/api/evaluation/**,/api/license/**,/api/dict/**,/api/config/**,/api/guide/**,/api/appointment/**,/api/notify/**,/api/consult/**,/api/workspace/**,/api/role/**,/api/menu/**,/api/sensitive/**','f55ca82eeb3717728abd26b9ad0217be','2026-09-23 16:09:28','2026-09-24 16:23:55','nacos','0:0:0:0:0:0:0:1','','public','网关路由配置',NULL,NULL,'yaml',NULL,'');
/*!40000 ALTER TABLE `config_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config_info_gray`
--

DROP TABLE IF EXISTS `config_info_gray`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `config_info_gray` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `data_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'data_id',
  `group_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'group_id',
  `content` longtext COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'content',
  `md5` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'md5',
  `src_user` text COLLATE utf8mb4_unicode_ci COMMENT 'src_user',
  `src_ip` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'src_ip',
  `gmt_create` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT 'gmt_create',
  `gmt_modified` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT 'gmt_modified',
  `app_name` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'app_name',
  `tenant_id` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'tenant_id',
  `gray_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'gray_name',
  `gray_rule` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'gray_rule',
  `encrypted_data_key` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'encrypted_data_key',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_configinfogray_datagrouptenantgray` (`data_id`,`group_id`,`tenant_id`,`gray_name`),
  KEY `idx_dataid_gmt_modified` (`data_id`,`gmt_modified`),
  KEY `idx_gmt_modified` (`gmt_modified`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='config_info_gray';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config_info_gray`
--

LOCK TABLES `config_info_gray` WRITE;
/*!40000 ALTER TABLE `config_info_gray` DISABLE KEYS */;
/*!40000 ALTER TABLE `config_info_gray` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config_tags_relation`
--

DROP TABLE IF EXISTS `config_tags_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `config_tags_relation` (
  `id` bigint NOT NULL COMMENT 'id',
  `tag_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'tag_name',
  `tag_type` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'tag_type',
  `data_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'data_id',
  `group_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'group_id',
  `tenant_id` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'tenant_id',
  `nid` bigint NOT NULL AUTO_INCREMENT COMMENT 'nid, 自增长标识',
  PRIMARY KEY (`nid`),
  UNIQUE KEY `uk_configtagrelation_configidtag` (`id`,`tag_name`,`tag_type`),
  KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='config_tag_relation';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config_tags_relation`
--

LOCK TABLES `config_tags_relation` WRITE;
/*!40000 ALTER TABLE `config_tags_relation` DISABLE KEYS */;
/*!40000 ALTER TABLE `config_tags_relation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_capacity`
--

DROP TABLE IF EXISTS `group_capacity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `group_capacity` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `group_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Group ID，空字符表示整个集群',
  `quota` int unsigned NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
  `usage` int unsigned NOT NULL DEFAULT '0' COMMENT '使用量',
  `max_size` int unsigned NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
  `max_aggr_count` int unsigned NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数，，0表示使用默认值',
  `max_aggr_size` int unsigned NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
  `max_history_count` int unsigned NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_group_id` (`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='集群、各Group容量信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_capacity`
--

LOCK TABLES `group_capacity` WRITE;
/*!40000 ALTER TABLE `group_capacity` DISABLE KEYS */;
INSERT INTO `group_capacity` VALUES (1,'',0,2,0,0,0,0,'2026-09-14 09:41:50','2026-09-24 17:13:06');
/*!40000 ALTER TABLE `group_capacity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `his_config_info`
--

DROP TABLE IF EXISTS `his_config_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `his_config_info` (
  `id` bigint unsigned NOT NULL COMMENT 'id',
  `nid` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'nid, 自增标识',
  `data_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'data_id',
  `group_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'group_id',
  `app_name` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'app_name',
  `content` longtext COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'content',
  `md5` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'md5',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  `src_user` text COLLATE utf8mb4_unicode_ci COMMENT 'source user',
  `src_ip` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'source ip',
  `op_type` char(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'operation type',
  `tenant_id` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT '租户字段',
  `encrypted_data_key` varchar(1024) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '密钥',
  `publish_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'formal' COMMENT 'publish type gray or formal',
  `gray_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'gray name',
  `ext_info` longtext COLLATE utf8mb4_unicode_ci COMMENT 'ext info',
  PRIMARY KEY (`nid`),
  KEY `idx_gmt_create` (`gmt_create`),
  KEY `idx_gmt_modified` (`gmt_modified`),
  KEY `idx_did` (`data_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='多租户改造';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `his_config_info`
--

LOCK TABLES `his_config_info` WRITE;
/*!40000 ALTER TABLE `his_config_info` DISABLE KEYS */;
INSERT INTO `his_config_info` VALUES (0,1,'application-dev.yml','DEFAULT_GROUP','','# 公共配置 application-dev.yml\r\nspring:\r\n  # 数据源配置\r\n  datasource:\r\n    type: com.alibaba.druid.pool.DruidDataSource\r\n    druid:\r\n      # 主库数据源\r\n      master:\r\n        url: jdbc:mysql://127.0.0.1:3306/ry-cloud?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=false&serverTimezone=Asia/Shanghai\r\n        username: root\r\n        password: root123\r\n        driver-class-name: com.mysql.cj.jdbc.Driver\r\n  # redis配置\r\n  redis:\r\n    host: 127.0.0.1\r\n    port: 6379\r\n    password:\r\n','3dd6c24238d9ae964dda248f4bd20d26','2026-09-14 09:41:50','2026-09-14 09:41:50','nacos','0:0:0:0:0:0:0:1','I','public','','formal','','{\"src_user\":\"nacos\",\"type\":\"yaml\"}'),(0,2,'ruoyi-system-dev.yml','DEFAULT_GROUP','','# ruoyi-auth 认证模块私有配置\r\n# 认证相关客户端、token配置\r\nsecurity:\r\n  oauth2:\r\n    client:\r\n      client-id: ruoyi\r\n      client-secret: ruoyi123\r\n      scope: server\r\n','b95c52e36e8acf6fb9927f7400d42706','2026-09-14 09:47:03','2026-09-14 09:47:03','nacos','0:0:0:0:0:0:0:1','I','public','','formal','','{\"src_user\":\"nacos\",\"type\":\"text\"}'),(4,3,'ruoyi-system-dev.yml','DEFAULT_GROUP','','# ruoyi-auth 认证模块私有配置\r\n# 认证相关客户端、token配置\r\nsecurity:\r\n  oauth2:\r\n    client:\r\n      client-id: ruoyi\r\n      client-secret: ruoyi123\r\n      scope: server\r\n','b95c52e36e8acf6fb9927f7400d42706','2026-09-14 09:47:15','2026-09-14 09:47:15','nacos','0:0:0:0:0:0:0:1','U','public','','formal','','{\"type\":\"text\",\"src_user\":\"nacos\"}'),(0,4,'ruoyi-gateway-dev.yml','DEFAULT_GROUP','','# 网关路由配置\r\nspring:\r\n  cloud:\r\n    gateway:\r\n      routes:\r\n        # 系统模块路由\r\n        - id: ruoyi-system\r\n          uri: lb://ruoyi-system\r\n          predicates:\r\n            - Path=/system/**\r\n        # 认证模块路由\r\n        - id: ruoyi-auth\r\n          uri: lb://ruoyi-auth\r\n          predicates:\r\n            - Path=/auth/**\r\n        # 代码生成模块路由\r\n        - id: ruoyi-gen\r\n          uri: lb://ruoyi-gen\r\n          predicates:\r\n            - Path=/gen/**\r\n','85d8622ace9cd4c0a41f7d5ea89f4d2d','2026-09-14 09:47:59','2026-09-14 09:47:59','nacos','0:0:0:0:0:0:0:1','I','public','','formal','','{\"src_user\":\"nacos\",\"type\":\"yaml\"}'),(0,5,'ruoyi-gen-dev.yml','DEFAULT_GROUP','','# 代码生成模块\r\nmybatis-plus:\r\n  mapper-locations: classpath:mapper/**/*.xml\r\n  type-aliases-package: com.ruoyi.gen.domain\r\n  configuration:\r\n    map-underscore-to-camel-case: true\r\n','8c6e034649050a95b50ebe4654b27e48','2026-09-14 09:48:43','2026-09-14 09:48:44','nacos','0:0:0:0:0:0:0:1','I','public','','formal','','{\"src_user\":\"nacos\",\"type\":\"yaml\"}'),(1,6,'application-dev.yml','DEFAULT_GROUP','','spring:\n  autoconfigure:\n    exclude: com.alibaba.druid.spring.boot3.autoconfigure.DruidDataSourceAutoConfigure\n\n# feign ??\nfeign:\n  sentinel:\n    enabled: true\n  okhttp:\n    enabled: true\n  httpclient:\n    enabled: false\n  client:\n    config:\n      default:\n        connectTimeout: 10000\n        readTimeout: 10000\n  compression:\n    request:\n      enabled: true\n      min-request-size: 8192\n    response:\n      enabled: true\n\n# ??????\nmanagement:\n  endpoints:\n    web:\n      exposure:\n        include: \'*\'\n','abeacac503abea6d3c7d099451166896','2026-09-15 15:01:03','2026-09-15 15:01:04','nacos','0:0:0:0:0:0:0:1','D','public','','formal','','{\"type\":\"yaml\",\"src_user\":\"nacos_namespace_migrate\",\"c_desc\":\"????\"}'),(2,7,'ruoyi-gateway-dev.yml','DEFAULT_GROUP','','spring:\n  data:\n    redis:\n      host: localhost\n      port: 6379\n      password: \n  cloud:\n    gateway:\n      server:\n        webflux:\n          discovery:\n            locator:\n              lowerCaseServiceId: true\n              enabled: true\n          routes:\n            # ????\n            - id: ruoyi-auth\n              uri: lb://ruoyi-auth\n              predicates:\n                - Path=/auth/**\n              filters:\n                # ?????\n                - name: CacheRequestBody\n                  args:\n                    bodyClass: java.lang.String\n                - ValidateCodeFilter\n                - StripPrefix=1\n            # ????\n            - id: ruoyi-gen\n              uri: lb://ruoyi-gen\n              predicates:\n                - Path=/code/**\n              filters:\n                - StripPrefix=1\n            # ????\n            - id: ruoyi-job\n              uri: lb://ruoyi-job\n              predicates:\n                - Path=/schedule/**\n              filters:\n                - StripPrefix=1\n            # ????\n            - id: ruoyi-system\n              uri: lb://ruoyi-system\n              predicates:\n                - Path=/system/**\n              filters:\n                - StripPrefix=1\n            # ????\n            - id: ruoyi-file\n              uri: lb://ruoyi-file\n              predicates:\n                - Path=/file/**\n              filters:\n                - StripPrefix=1\n\n# ????\nsecurity:\n  # ???\n  captcha:\n    enabled: true\n    type: math\n  # ??XSS??\n  xss:\n    enabled: true\n    excludeUrls:\n      - /system/notice\n\n  # ??????\n  ignore:\n    whites:\n      - /auth/logout\n      - /auth/login\n      - /auth/register\n      - /auth/captchaImage\n      - /*/v2/api-docs\n      - /*/v3/api-docs\n      - /csrf\n\n# springdoc??\nspringdoc:\n  webjars:\n    # ????\n    prefix:\n','511c4dcc4e5b66df7522dfed1ed7edcb','2026-09-15 15:01:06','2026-09-15 15:01:06','nacos','0:0:0:0:0:0:0:1','D','public','','formal','','{\"type\":\"yaml\",\"src_user\":\"nacos_namespace_migrate\",\"c_desc\":\"????\"}'),(3,8,'ruoyi-auth-dev.yml','DEFAULT_GROUP','','spring:\n  data:\n    redis:\n      host: localhost\n      port: 6379\n      password: \n','72565b1a725e013154ee57c8fd3045c4','2026-09-15 15:01:12','2026-09-15 15:01:12','nacos','0:0:0:0:0:0:0:1','D','public','','formal','','{\"type\":\"yaml\",\"src_user\":\"nacos_namespace_migrate\",\"c_desc\":\"????\"}'),(4,9,'ruoyi-monitor-dev.yml','DEFAULT_GROUP','','# spring\nspring:\n  security:\n    user:\n      name: ruoyi\n      password: 123456\n  boot:\n    admin:\n      ui:\n        title: ????????\n','8c191652cb6080cda1c2f57fccb2800f','2026-09-15 15:01:14','2026-09-15 15:01:14','nacos','0:0:0:0:0:0:0:1','D','public','','formal','','{\"type\":\"yaml\",\"src_user\":\"nacos_namespace_migrate\",\"c_desc\":\"????\"}'),(5,10,'ruoyi-system-dev.yml','DEFAULT_GROUP','','# spring??\nspring:\n  data:\n    redis:\n      host: localhost\n      port: 6379\n      password: \n  datasource:\n    druid:\n      stat-view-servlet:\n        enabled: true\n        loginUsername: ruoyi\n        loginPassword: 123456\n    dynamic:\n      druid:\n        initial-size: 5\n        min-idle: 5\n        maxActive: 20\n        maxWait: 60000\n        connectTimeout: 30000\n        socketTimeout: 60000\n        timeBetweenEvictionRunsMillis: 60000\n        minEvictableIdleTimeMillis: 300000\n        validationQuery: SELECT 1 FROM DUAL\n        testWhileIdle: true\n        testOnBorrow: false\n        testOnReturn: false\n        poolPreparedStatements: true\n        maxPoolPreparedStatementPerConnectionSize: 20\n        filters: stat,slf4j\n        connectionProperties: druid.stat.mergeSql\\=true;druid.stat.slowSqlMillis\\=5000\n      datasource:\n          # ?????\n          master:\n            driver-class-name: com.mysql.cj.jdbc.Driver\n            url: jdbc:mysql://localhost:3306/ry-cloud?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8\n            username: root\n            password: root123\n          # ?????\n          # slave:\n            # username: \n            # password: \n            # url: \n            # driver-class-name: \n\n# mybatis??\nmybatis:\n    # ???????\n    typeAliasesPackage: com.ruoyi.system\n    # ??mapper?????????mapper.xml????\n    mapperLocations: classpath:mapper/**/*.xml\n\n# springdoc??\nspringdoc:\n  gatewayUrl: http://localhost:8081/${spring.application.name}\n  api-docs:\n    # ????????\n    enabled: true\n  info:\n    # ??\n    title: \'????????\'\n    # ??\n    description: \'????????\'\n    # ????\n    contact:\n      name: RuoYi\n      url: https://ruoyi.vip\n','8c9c82b2b0bc8d0e1431a74886e6ecfa','2026-09-15 15:01:16','2026-09-15 15:01:16','nacos','0:0:0:0:0:0:0:1','D','public','','formal','','{\"type\":\"yaml\",\"src_user\":\"nacos_namespace_migrate\",\"c_desc\":\"????\"}'),(6,11,'ruoyi-gen-dev.yml','DEFAULT_GROUP','','# spring??\nspring:\n  data:\n    redis:\n      host: localhost\n      port: 6379\n      password: \n  datasource:\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    url: jdbc:mysql://localhost:3306/ry-cloud?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8\n    username: root\n    password: root123\n\n# mybatis??\nmybatis:\n    # ???????\n    typeAliasesPackage: com.ruoyi.gen.domain\n    # ??mapper?????????mapper.xml????\n    mapperLocations: classpath:mapper/**/*.xml\n\n# springdoc??\nspringdoc:\n  gatewayUrl: http://localhost:8081/${spring.application.name}\n  api-docs:\n    # ????????\n    enabled: true\n  info:\n    # ??\n    title: \'????????\'\n    # ??\n    description: \'????????\'\n    # ????\n    contact:\n      name: RuoYi\n      url: https://ruoyi.vip\n\n# ????\ngen:\n  # ??\n  author: ruoyi\n  # ??????? system ?????????? ? system monitor tool\n  packageName: com.ruoyi.system\n  # ???????????false\n  autoRemovePre: false\n  # ????????????????????????\n  tablePrefix: sys_\n  # ??????????????????????????\n  allowOverwrite: false','8e9306fa13daed79ea1cfc6acde235fd','2026-09-15 15:01:18','2026-09-15 15:01:18','nacos','0:0:0:0:0:0:0:1','D','public','','formal','','{\"type\":\"yaml\",\"src_user\":\"nacos_namespace_migrate\",\"c_desc\":\"????\"}'),(7,12,'ruoyi-job-dev.yml','DEFAULT_GROUP','','# spring??\nspring:\n  data:\n    redis:\n      host: localhost\n      port: 6379\n      password: \n  datasource:\n    driver-class-name: com.mysql.cj.jdbc.Driver\n    url: jdbc:mysql://localhost:3306/ry-cloud?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8\n    username: root\n    password: root123\n\n# mybatis??\nmybatis:\n    # ???????\n    typeAliasesPackage: com.ruoyi.job.domain\n    # ??mapper?????????mapper.xml????\n    mapperLocations: classpath:mapper/**/*.xml\n\n# springdoc??\nspringdoc:\n  gatewayUrl: http://localhost:8081/${spring.application.name}\n  api-docs:\n    # ????????\n    enabled: true\n  info:\n    # ??\n    title: \'????????\'\n    # ??\n    description: \'????????\'\n    # ????\n    contact:\n      name: RuoYi\n      url: https://ruoyi.vip\n','040f13ea4bce9bdb468e7515bf3af0d1','2026-09-15 15:01:20','2026-09-15 15:01:20','nacos','0:0:0:0:0:0:0:1','D','public','','formal','','{\"type\":\"yaml\",\"src_user\":\"nacos_namespace_migrate\",\"c_desc\":\"????\"}'),(8,13,'ruoyi-file-dev.yml','DEFAULT_GROUP','','# ??????    \nfile:\n    domain: http://127.0.0.1:9300\n    path: D:/ruoyi/uploadPath\n    prefix: /statics\n\n# FastDFS??\nfdfs:\n  domain: http://127.0.0.1\n  soTimeout: 3000\n  connectTimeout: 2000\n  trackerList: 127.0.0.1:22122\n\n# Minio??\nminio:\n  url: http://127.0.0.1:9000\n  accessKey: minioadmin\n  secretKey: minioadmin\n  bucketName: test\n\n  # ?????\nreferer:\n  # ?????\n  enabled: false\n  # ???????\n  allowed-domains: localhost,127.0.0.1,ruoyi.vip,www.ruoyi.vip\n','0d2f4a1f0616a12616036d1fd0a0434b','2026-09-15 15:01:22','2026-09-15 15:01:22','nacos','0:0:0:0:0:0:0:1','D','public','','formal','','{\"type\":\"yaml\",\"src_user\":\"nacos_namespace_migrate\",\"c_desc\":\"????\"}'),(9,14,'sentinel-ruoyi-gateway','DEFAULT_GROUP','','[\r\n    {\r\n        \"resource\": \"ruoyi-auth\",\r\n        \"count\": 500,\r\n        \"grade\": 1,\r\n        \"limitApp\": \"default\",\r\n        \"strategy\": 0,\r\n        \"controlBehavior\": 0\r\n    },\r\n	{\r\n        \"resource\": \"ruoyi-system\",\r\n        \"count\": 1000,\r\n        \"grade\": 1,\r\n        \"limitApp\": \"default\",\r\n        \"strategy\": 0,\r\n        \"controlBehavior\": 0\r\n    },\r\n	{\r\n        \"resource\": \"ruoyi-gen\",\r\n        \"count\": 200,\r\n        \"grade\": 1,\r\n        \"limitApp\": \"default\",\r\n        \"strategy\": 0,\r\n        \"controlBehavior\": 0\r\n    },\r\n	{\r\n        \"resource\": \"ruoyi-job\",\r\n        \"count\": 300,\r\n        \"grade\": 1,\r\n        \"limitApp\": \"default\",\r\n        \"strategy\": 0,\r\n        \"controlBehavior\": 0\r\n    }\r\n]','9f3a3069261598f74220bc47958ec252','2026-09-15 15:01:24','2026-09-15 15:01:24','nacos','0:0:0:0:0:0:0:1','D','public','','formal','','{\"type\":\"json\",\"src_user\":\"nacos_namespace_migrate\",\"c_desc\":\"????\"}'),(0,15,'gateway-routes.yaml','DEFAULT_GROUP','','spring:\r\n  cloud:\r\n    gateway:\r\n      routes:\r\n        - id: gov-auth\r\n          uri: lb://gov-auth\r\n          predicates:\r\n            - Path=/api/auth/**,/api/user/**,/api/loginlog/**\r\n        - id: gov-file\r\n          uri: lb://gov-file\r\n          predicates:\r\n            - Path=/api/file/**\r\n        - id: gov-application\r\n          uri: lb://gov-application\r\n          predicates:\r\n            - Path=/api/application/**,/api/process/**,/api/operlog/**,/api/dashboard/**,/api/dept/**,/api/screen/**,/api/report/**,/api/evaluation/**,/api/license/**,/api/dict/**,/api/config/**,/api/guide/**,/api/appointment/**,/api/notify/**,/api/consult/**,/api/workspace/**,/api/role/**','a3f1b9bfd97503b177ae27c78dcb811e','2026-09-23 16:09:27','2026-09-23 16:09:28','nacos','0:0:0:0:0:0:0:1','I','public','','formal','','{\"src_user\":\"nacos\",\"type\":\"yaml\",\"c_desc\":\"网关路由配置\"}'),(11,16,'gateway-routes.yaml','DEFAULT_GROUP','','spring:\r\n  cloud:\r\n    gateway:\r\n      routes:\r\n        - id: gov-auth\r\n          uri: lb://gov-auth\r\n          predicates:\r\n            - Path=/api/auth/**,/api/user/**,/api/loginlog/**\r\n        - id: gov-file\r\n          uri: lb://gov-file\r\n          predicates:\r\n            - Path=/api/file/**\r\n        - id: gov-application\r\n          uri: lb://gov-application\r\n          predicates:\r\n            - Path=/api/application/**,/api/process/**,/api/operlog/**,/api/dashboard/**,/api/dept/**,/api/screen/**,/api/report/**,/api/evaluation/**,/api/license/**,/api/dict/**,/api/config/**,/api/guide/**,/api/appointment/**,/api/notify/**,/api/consult/**,/api/workspace/**,/api/role/**','a3f1b9bfd97503b177ae27c78dcb811e','2026-09-24 10:06:31','2026-09-24 10:06:31','nacos','0:0:0:0:0:0:0:1','U','public','','formal','','{\"type\":\"yaml\",\"src_user\":\"nacos\",\"c_desc\":\"网关路由配置\"}'),(11,17,'gateway-routes.yaml','DEFAULT_GROUP','','spring:\r\n  cloud:\r\n    gateway:\r\n      routes:\r\n        - id: gov-auth\r\n          uri: lb://gov-auth\r\n          predicates:\r\n            - Path=/api/auth/**,/api/user/**,/api/loginlog/**\r\n        - id: gov-file\r\n          uri: lb://gov-file\r\n          predicates:\r\n            - Path=/api/file/**\r\n        - id: gov-application\r\n          uri: lb://gov-application\r\n          predicates:\r\n            - Path=/api/application/**,/api/process/**,/api/operlog/**,/api/dashboard/**,/api/dept/**,/api/screen/**,/api/report/**,/api/evaluation/**,/api/license/**,/api/dict/**,/api/config/**,/api/guide/**,/api/appointment/**,/api/notify/**,/api/consult/**,/api/workspace/**,/api/role/**,/api/menu/**','9c85618f71d58fba22d78e52d2156b84','2026-09-24 15:02:38','2026-09-24 15:02:38','nacos','0:0:0:0:0:0:0:1','U','public','','formal','','{\"type\":\"yaml\",\"src_user\":\"nacos\",\"c_desc\":\"网关路由配置\"}'),(11,18,'gateway-routes.yaml','DEFAULT_GROUP','','spring:\r\n  cloud:\r\n    gateway:\r\n      routes:\r\n        - id: gov-auth\r\n          uri: lb://gov-auth\r\n          predicates:\r\n            - Path=/api/auth/**,/api/user/**,/api/loginlog/**\r\n        - id: gov-file\r\n          uri: lb://gov-file\r\n          predicates:\r\n            - Path=/api/file/**\r\n        - id: gov-application\r\n          uri: lb://gov-application\r\n          predicates:\r\n            - Path=/api/application/**,/api/process/**,/api/operlog/**,/api/dashboard/**,/api/dept/**,/api/screen/**,/api/report/**,/api/evaluation/**,/api/license/**,/api/dict/**,/api/config/**,/api/guide/**,/api/appointment/**,/api/notify/**,/api/consult/**,/api/workspace/**,/api/role/**,/api/menu/**,/api/attachment/**','10898fdae5d7066a48bba471ae68fdba','2026-09-24 15:24:01','2026-09-24 15:24:01','nacos','0:0:0:0:0:0:0:1','U','public','','formal','','{\"type\":\"yaml\",\"src_user\":\"nacos\",\"c_desc\":\"网关路由配置\"}'),(11,19,'gateway-routes.yaml','DEFAULT_GROUP','','spring:\r\n  cloud:\r\n    gateway:\r\n      routes:\r\n        - id: gov-auth\r\n          uri: lb://gov-auth\r\n          predicates:\r\n            - Path=/api/auth/**,/api/user/**,/api/loginlog/**\r\n        - id: gov-file\r\n          uri: lb://gov-file\r\n          predicates:\r\n            - Path=/api/file/**,/api/attachment/**\r\n        - id: gov-application\r\n          uri: lb://gov-application\r\n          predicates:\r\n            - Path=/api/application/**,/api/process/**,/api/operlog/**,/api/dashboard/**,/api/dept/**,/api/screen/**,/api/report/**,/api/evaluation/**,/api/license/**,/api/dict/**,/api/config/**,/api/guide/**,/api/appointment/**,/api/notify/**,/api/consult/**,/api/workspace/**,/api/role/**,/api/menu/**','f80df39c28bc759c449a89681abaf91c','2026-09-24 16:18:53','2026-09-24 16:18:54','nacos','0:0:0:0:0:0:0:1','U','public','','formal','','{\"type\":\"yaml\",\"src_user\":\"nacos\",\"c_desc\":\"网关路由配置\"}'),(11,20,'gateway-routes.yaml','DEFAULT_GROUP','','spring:\r\n  cloud:\r\n    gateway:\r\n      routes:\r\n        - id: gov-auth\r\n          uri: lb://gov-auth\r\n          predicates:\r\n            - Path=/api/auth/**,/api/user/**,/api/loginlog/**\r\n        - id: gov-file\r\n          uri: lb://gov-file\r\n          predicates:\r\n            - Path=/api/file/**,/api/attachment/**\r\n        - id: gov-application\r\n          uri: lb://gov-application,/api/sensitive/**\r\n          predicates:\r\n            - Path=/api/application/**,/api/process/**,/api/operlog/**,/api/dashboard/**,/api/dept/**,/api/screen/**,/api/report/**,/api/evaluation/**,/api/license/**,/api/dict/**,/api/config/**,/api/guide/**,/api/appointment/**,/api/notify/**,/api/consult/**,/api/workspace/**,/api/role/**,/api/menu/**','9190c880d8269f1d2ab569b07fff49de','2026-09-24 16:23:55','2026-09-24 16:23:55','nacos','0:0:0:0:0:0:0:1','U','public','','formal','','{\"type\":\"yaml\",\"src_user\":\"nacos\",\"c_desc\":\"网关路由配置\"}');
/*!40000 ALTER TABLE `his_config_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `role` varchar(50) NOT NULL COMMENT 'role',
  `resource` varchar(128) NOT NULL COMMENT 'resource',
  `action` varchar(8) NOT NULL COMMENT 'action',
  UNIQUE KEY `uk_role_permission` (`role`,`resource`,`action`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pipeline_execution`
--

DROP TABLE IF EXISTS `pipeline_execution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pipeline_execution` (
  `execution_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '执行ID',
  `resource_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资源类型',
  `resource_name` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资源名称',
  `namespace_id` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '命名空间ID',
  `version` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '版本',
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '执行状态',
  `pipeline` longtext COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'pipeline节点结果JSON',
  `create_time` bigint NOT NULL COMMENT '创建时间',
  `update_time` bigint NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`execution_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI资源发布审核Pipeline执行记录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pipeline_execution`
--

LOCK TABLES `pipeline_execution` WRITE;
/*!40000 ALTER TABLE `pipeline_execution` DISABLE KEYS */;
/*!40000 ALTER TABLE `pipeline_execution` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `username` varchar(50) NOT NULL COMMENT 'username',
  `role` varchar(50) NOT NULL COMMENT 'role',
  UNIQUE KEY `idx_user_role` (`username`,`role`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES ('nacos','ROLE_ADMIN');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tenant_capacity`
--

DROP TABLE IF EXISTS `tenant_capacity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tenant_capacity` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Tenant ID',
  `quota` int unsigned NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
  `usage` int unsigned NOT NULL DEFAULT '0' COMMENT '使用量',
  `max_size` int unsigned NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
  `max_aggr_count` int unsigned NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数',
  `max_aggr_size` int unsigned NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
  `max_history_count` int unsigned NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_id` (`tenant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='租户容量信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tenant_capacity`
--

LOCK TABLES `tenant_capacity` WRITE;
/*!40000 ALTER TABLE `tenant_capacity` DISABLE KEYS */;
INSERT INTO `tenant_capacity` VALUES (1,'public',0,1,0,0,0,0,'2026-09-14 09:41:50','2026-09-24 17:13:06');
/*!40000 ALTER TABLE `tenant_capacity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tenant_info`
--

DROP TABLE IF EXISTS `tenant_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tenant_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `kp` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'kp',
  `tenant_id` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'tenant_id',
  `tenant_name` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'tenant_name',
  `tenant_desc` varchar(256) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'tenant_desc',
  `create_source` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'create_source',
  `gmt_create` bigint NOT NULL COMMENT '创建时间',
  `gmt_modified` bigint NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_info_kptenantid` (`kp`,`tenant_id`),
  KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='tenant_info';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tenant_info`
--

LOCK TABLES `tenant_info` WRITE;
/*!40000 ALTER TABLE `tenant_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `tenant_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `username` varchar(50) NOT NULL COMMENT 'username',
  `password` varchar(500) NOT NULL COMMENT 'password',
  `enabled` tinyint(1) NOT NULL COMMENT 'enabled',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('nacos','$2a$10$Ohzv/RK54rIHc3PlhQ.fJOHN2HIHhcArNt8nzoxaKpJsfpKkQlTra',1);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'nacos_config'
--

--
-- Dumping routines for database 'nacos_config'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-24 17:15:36
