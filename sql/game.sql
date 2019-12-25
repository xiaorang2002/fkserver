/*
Navicat MySQL Data Transfer

Source Server         : localhost
Source Server Version : 50727
Source Host           : localhost:3306
Source Database       : game

Target Server Type    : MYSQL
Target Server Version : 50727
File Encoding         : 65001

Date: 2019-08-25 18:32:33
*/

SET FOREIGN_KEY_CHECKS=0;

DROP DATABASE IF EXISTS game;
CREATE DATABASE game;
USE game;

-- ----------------------------
-- Table structure for t_bag
-- ----------------------------
DROP TABLE IF EXISTS `t_bag`;
CREATE TABLE `t_bag` (
`guid`  int(11) NOT NULL COMMENT '全局唯一标识符' ,
`pb_items`  blob NULL COMMENT '所有物品' ,
PRIMARY KEY (`guid`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='背包表'

;

-- ----------------------------
-- Records of t_bag
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_bank_save_back
-- ----------------------------
DROP TABLE IF EXISTS `t_bank_save_back`;
CREATE TABLE `t_bank_save_back` (
`id`  int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键' ,
`guid`  int(11) NOT NULL COMMENT '全局唯一标识符' ,
`save_back_money`  bigint(20) NOT NULL DEFAULT 0 COMMENT '回存银行存款' ,
`status`  tinyint(2) NOT NULL DEFAULT 0 COMMENT '状态:0 待回存  1 回存成功 ' ,
`before_bank`  bigint(20) NULL DEFAULT NULL COMMENT '回存前银行金钱' ,
`after_bank`  bigint(20) NULL DEFAULT NULL COMMENT '回存后银行金钱' ,
`created_at`  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ,
`updated_at`  timestamp NULL DEFAULT NULL ,
PRIMARY KEY (`id`),
INDEX `guid_status` (`guid`, `status`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
AUTO_INCREMENT=1

;

-- ----------------------------
-- Records of t_bank_save_back
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_bank_statement
-- ----------------------------
DROP TABLE IF EXISTS `t_bank_statement`;
CREATE TABLE `t_bank_statement` (
`id`  bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '银行流水ID' ,
`guid`  int(11) NOT NULL COMMENT '全局唯一标识符' ,
`time`  timestamp NULL DEFAULT NULL COMMENT '记录时间' ,
`opt`  int(11) NOT NULL DEFAULT 0 COMMENT '操作类型' ,
`target`  varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '目标' ,
`money`  int(11) NOT NULL DEFAULT 0 COMMENT '改变的钱' ,
`bank_balance`  int(11) NOT NULL DEFAULT 0 COMMENT '当前剩余的钱' ,
PRIMARY KEY (`id`),
INDEX `index_guid` (`guid`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='银行流水表'
AUTO_INCREMENT=1

;

-- ----------------------------
-- Records of t_bank_statement
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_bonus_activity
-- ----------------------------
DROP TABLE IF EXISTS `t_bonus_activity`;
CREATE TABLE `t_bonus_activity` (
`id`  int(11) NOT NULL AUTO_INCREMENT COMMENT '红包活动id' ,
`start_time`  datetime NULL DEFAULT NULL COMMENT '红包活动开始时间' ,
`end_time`  datetime NULL DEFAULT NULL COMMENT '红包活动结束时间' ,
`cfg`  text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '红包配置' ,
`create_time`  datetime NULL DEFAULT NULL COMMENT '创建时间' ,
`update_time`  datetime NULL DEFAULT NULL COMMENT '更新时间' ,
`platform_id`  int(11) NULL DEFAULT 0 ,
PRIMARY KEY (`id`),
INDEX `index_start_time` (`start_time`) USING BTREE ,
INDEX `index_end_time` (`end_time`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='红包活动表'
AUTO_INCREMENT=1

;

-- ----------------------------
-- Records of t_bonus_activity
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_bonus_game_statistics
-- ----------------------------
DROP TABLE IF EXISTS `t_bonus_game_statistics`;
CREATE TABLE `t_bonus_game_statistics` (
`guid`  int(11) NOT NULL COMMENT '玩家guid' ,
`bonus_activity_id`  int(11) NOT NULL COMMENT '红包活动id' ,
`money`  bigint(20) NOT NULL DEFAULT 0 COMMENT '输赢金钱情况' ,
`times`  int(11) NOT NULL DEFAULT 0 COMMENT '玩游戏局数' ,
`first_game_type`  int(11) NOT NULL COMMENT '游戏first_game_type' ,
`platform_id`  int(11) NULL DEFAULT 0 ,
PRIMARY KEY (`guid`, `bonus_activity_id`, `first_game_type`),
INDEX `guid_index` (`guid`) USING BTREE ,
INDEX `bonus_activity_index` (`bonus_activity_id`) USING BTREE ,
INDEX `game_name_index` (`first_game_type`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='玩家红包法动期间玩游戏情况统计'

;

-- ----------------------------
-- Records of t_bonus_game_statistics
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_bonus_pool
-- ----------------------------
DROP TABLE IF EXISTS `t_bonus_pool`;
CREATE TABLE `t_bonus_pool` (
`bonus_pool_name`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '奖池的名字' ,
`money`  bigint(20) NULL DEFAULT 0 COMMENT '奖池的钱' ,
PRIMARY KEY (`bonus_pool_name`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci

;

-- ----------------------------
-- Records of t_bonus_pool
-- ----------------------------
BEGIN;
INSERT INTO `t_bonus_pool` VALUES ('slotma_bonus_pool', '4150'), ('zhajinhua_bonus_pool', '0');
COMMIT;

-- ----------------------------
-- Table structure for t_channel_invite_tax
-- ----------------------------
DROP TABLE IF EXISTS `t_channel_invite_tax`;
CREATE TABLE `t_channel_invite_tax` (
`id`  int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id' ,
`guid`  int(11) NOT NULL COMMENT 'guid' ,
`val`  int(11) NOT NULL DEFAULT 0 COMMENT '获得的收益' ,
PRIMARY KEY (`id`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
AUTO_INCREMENT=1

;

-- ----------------------------
-- Records of t_channel_invite_tax
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_daily_earnings_rank
-- ----------------------------
DROP TABLE IF EXISTS `t_daily_earnings_rank`;
CREATE TABLE `t_daily_earnings_rank` (
`rank`  int(11) NOT NULL AUTO_INCREMENT COMMENT '排行榜' ,
`guid`  int(11) NOT NULL COMMENT '全局唯一标识符' ,
`nickname`  varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '昵称' ,
`money`  int(11) NOT NULL DEFAULT 0 COMMENT '钱' ,
PRIMARY KEY (`rank`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='日盈利榜表'
AUTO_INCREMENT=1

;

-- ----------------------------
-- Records of t_daily_earnings_rank
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_earnings
-- ----------------------------
DROP TABLE IF EXISTS `t_earnings`;
CREATE TABLE `t_earnings` (
`guid`  int(11) NOT NULL COMMENT '全局唯一标识符' ,
`daily_earnings`  bigint(20) NOT NULL DEFAULT 0 COMMENT '日盈利' ,
`weekly_earnings`  bigint(20) NOT NULL DEFAULT 0 COMMENT '周盈利' ,
`monthly_earnings`  bigint(20) NOT NULL DEFAULT 0 COMMENT '月盈利' ,
PRIMARY KEY (`guid`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='盈利榜表'

;

-- ----------------------------
-- Records of t_earnings
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_fortune_rank
-- ----------------------------
DROP TABLE IF EXISTS `t_fortune_rank`;
CREATE TABLE `t_fortune_rank` (
`rank`  int(11) NOT NULL AUTO_INCREMENT COMMENT '排行榜' ,
`guid`  int(11) NOT NULL COMMENT '全局唯一标识符' ,
`nickname`  varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '昵称' ,
`money`  int(11) NOT NULL DEFAULT 0 COMMENT '钱' ,
PRIMARY KEY (`rank`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='总财富榜表'
AUTO_INCREMENT=1

;

-- ----------------------------
-- Records of t_fortune_rank
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_mail
-- ----------------------------
DROP TABLE IF EXISTS `t_mail`;
CREATE TABLE `t_mail` (
`id`  bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '邮件ID' ,
`expiration_time`  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '过期时间' ,
`guid`  int(11) NOT NULL COMMENT '全局唯一标识符' ,
`send_guid`  int(11) NOT NULL DEFAULT 0 COMMENT '发件人的全局唯一标识符' ,
`send_name`  varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '发件人的名字' ,
`title`  varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '标题' ,
`content`  varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '内容' ,
`pb_attachment`  blob NULL COMMENT '附件' ,
PRIMARY KEY (`id`),
INDEX `index_expiration_time_guid` (`expiration_time`, `guid`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='邮件表'
AUTO_INCREMENT=1

;

-- ----------------------------
-- Records of t_mail
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_many_ox_server_config
-- ----------------------------
DROP TABLE IF EXISTS `t_many_ox_server_config`;
CREATE TABLE `t_many_ox_server_config` (
`id`  int(11) NOT NULL ,
`FreeTime`  int(11) NOT NULL COMMENT '空闲时间' ,
`BetTime`  int(11) NOT NULL COMMENT '下注时间' ,
`EndTime`  int(11) NOT NULL COMMENT '结束时间' ,
`MustWinCoeff`  int(11) NOT NULL COMMENT '系统必赢系数' ,
`BankerMoneyLimit`  int(11) NOT NULL COMMENT '上庄条件限制' ,
`SystemBankerSwitch`  int(11) NOT NULL COMMENT '系统当庄开关' ,
`BankerCount`  int(11) NOT NULL COMMENT '连庄次数' ,
`RobotBankerInitUid`  int(11) NOT NULL COMMENT '系统庄家初始UID' ,
`RobotBankerInitMoney`  bigint(20) NOT NULL COMMENT '系统庄家初始金币' ,
`BetRobotSwitch`  int(11) NOT NULL COMMENT '下注机器人开关' ,
`BetRobotInitUid`  int(11) NOT NULL COMMENT '下注机器人初始UID' ,
`BetRobotInitMoney`  bigint(20) NOT NULL COMMENT '下注机器人初始金币' ,
`BetRobotNumControl`  int(11) NOT NULL COMMENT '下注机器人个数限制' ,
`BetRobotTimesControl`  int(11) NOT NULL COMMENT '机器人下注次数限制' ,
`RobotBetMoneyControl`  int(11) NOT NULL COMMENT '机器人下注金币限制' ,
`BasicChip`  varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '筹码信息' ,
`ExtendA`  int(11) NOT NULL COMMENT '预留字段A' ,
`ExtendB`  int(11) NOT NULL COMMENT '预留字段B' ,
PRIMARY KEY (`id`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='百人牛牛基础配置表'

;

-- ----------------------------
-- Records of t_many_ox_server_config
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_monthly_earnings_rank
-- ----------------------------
DROP TABLE IF EXISTS `t_monthly_earnings_rank`;
CREATE TABLE `t_monthly_earnings_rank` (
`rank`  int(11) NOT NULL AUTO_INCREMENT COMMENT '排行榜' ,
`guid`  int(11) NOT NULL COMMENT '全局唯一标识符' ,
`nickname`  varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '昵称' ,
`money`  int(11) NOT NULL DEFAULT 0 COMMENT '钱' ,
PRIMARY KEY (`rank`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='月盈利榜表'
AUTO_INCREMENT=1

;

-- ----------------------------
-- Records of t_monthly_earnings_rank
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_notice
-- ----------------------------
DROP TABLE IF EXISTS `t_notice`;
CREATE TABLE `t_notice` (
`id`  int(11) NOT NULL AUTO_INCREMENT ,
`number`  int(11) NULL DEFAULT 0 COMMENT '轮播次数' ,
`interval_time`  int(11) NULL DEFAULT 0 COMMENT '轮播时间间隔（秒）' ,
`type`  varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '通知类型 1：消息通知 2：公告通知 3跑马灯' ,
`send_range`  tinyint(1) NULL DEFAULT 0 COMMENT '发送范围 0：全部' ,
`name`  varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '标题' ,
`content`  text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '内容' ,
`author`  varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '发布者' ,
`start_time`  timestamp NULL DEFAULT NULL COMMENT '发送时间' ,
`end_time`  timestamp NULL DEFAULT NULL COMMENT '结束时间' ,
`created_time`  timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' ,
`platform_ids`  varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT ',0,' COMMENT '消息对应平台id' ,
PRIMARY KEY (`id`),
INDEX `index_name` (`name`) USING BTREE ,
INDEX `index_time_type` (`end_time`, `type`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='通知表'
AUTO_INCREMENT=1

;

-- ----------------------------
-- Records of t_notice
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_notice_platform
-- ----------------------------
DROP TABLE IF EXISTS `t_notice_platform`;
CREATE TABLE `t_notice_platform` (
`notice_id`  int(11) NOT NULL COMMENT '通知id' ,
`platform_id`  varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '消息对应的平台id' ,
INDEX `index_notice_id` (`notice_id`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci

;

-- ----------------------------
-- Records of t_notice_platform
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_notice_private
-- ----------------------------
DROP TABLE IF EXISTS `t_notice_private`;
CREATE TABLE `t_notice_private` (
`id`  int(11) NOT NULL AUTO_INCREMENT ,
`guid`  int(11) NULL DEFAULT NULL COMMENT '用户ID,与account.t_account' ,
`account`  varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '用户账号' ,
`nickname`  varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '用户昵称' ,
`type`  varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '通知类型 1：消息通知' ,
`name`  varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '标题' ,
`content`  text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '内容' ,
`author`  varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '发布者' ,
`start_time`  timestamp NULL DEFAULT NULL COMMENT '开始时间' ,
`end_time`  timestamp NULL DEFAULT NULL COMMENT '结束时间' ,
`created_time`  timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' ,
`is_read`  tinyint(1) NULL DEFAULT 0 COMMENT '是否阅读 1:已读 0:未读' ,
PRIMARY KEY (`id`),
INDEX `index_name` (`name`) USING BTREE ,
INDEX `index_guid` (`guid`) USING BTREE ,
INDEX `index_guid_time_type` (`guid`, `end_time`, `type`) USING BTREE ,
INDEX `index_guid_id` (`guid`, `id`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='私信通知表'
AUTO_INCREMENT=1

;

-- ----------------------------
-- Records of t_notice_private
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_notice_read
-- ----------------------------
DROP TABLE IF EXISTS `t_notice_read`;
CREATE TABLE `t_notice_read` (
`guid`  int(11) NOT NULL COMMENT '用户ID,与account.t_account' ,
`n_id`  int(11) NOT NULL COMMENT '通知ID' ,
`is_read`  tinyint(1) NULL DEFAULT 1 COMMENT '是否阅读 1：已读， 0：未读' ,
`read_time`  timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '阅读时间' ,
PRIMARY KEY (`guid`, `n_id`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='通知阅读明细表'

;

-- ----------------------------
-- Records of t_notice_read
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_ox_player_info
-- ----------------------------
DROP TABLE IF EXISTS `t_ox_player_info`;
CREATE TABLE `t_ox_player_info` (
`id`  int(11) NOT NULL AUTO_INCREMENT COMMENT '全局唯一标识符' ,
`guid`  int(11) NOT NULL COMMENT '用户ID' ,
`is_android`  int(11) NOT NULL COMMENT '是否机器人' ,
`table_id`  int(11) NOT NULL COMMENT '桌子ID' ,
`banker_id`  int(11) NOT NULL COMMENT '庄家ID' ,
`nickname`  varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '昵称' ,
`money`  bigint(20) NOT NULL COMMENT '金币数' ,
`win_money`  bigint(20) NOT NULL COMMENT '该局输赢' ,
`bet_money`  int(11) NOT NULL COMMENT '玩家下注金币' ,
`tax`  int(11) NOT NULL COMMENT '玩家台费' ,
`curtime`  int(11) NOT NULL COMMENT '当前时间' ,
PRIMARY KEY (`id`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='百人牛牛收益表'
AUTO_INCREMENT=1

;

-- ----------------------------
-- Records of t_ox_player_info
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_player
-- ----------------------------
DROP TABLE IF EXISTS `t_player`;
CREATE TABLE `t_player` (
`guid`  int(11) NOT NULL COMMENT '全局唯一标识符' ,
`is_android`  int(11) NOT NULL DEFAULT 0 COMMENT '是机器人' ,
`account`  varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '账号' ,
`nickname`  varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '昵称' ,
`level`  int(11) NOT NULL DEFAULT 0 COMMENT '玩家等级' ,
`money`  bigint(20) NOT NULL DEFAULT 0 COMMENT '有多少钱' ,
`bank`  bigint(20) NOT NULL DEFAULT 0 COMMENT '银行存款' ,
`login_award_day`  int(11) NOT NULL DEFAULT 0 COMMENT '登录奖励，该领取那一天' ,
`login_award_receive_day`  int(11) NOT NULL DEFAULT 0 COMMENT '登录奖励，最近领取在那一天' ,
`online_award_time`  int(11) NOT NULL DEFAULT 0 COMMENT '在线奖励，今天已经在线时间' ,
`online_award_num`  int(11) NOT NULL DEFAULT 0 COMMENT '在线奖励，该领取哪个奖励' ,
`relief_payment_count`  int(11) NOT NULL DEFAULT 0 COMMENT '救济金，今天领取次数' ,
`header_icon`  int(11) NOT NULL DEFAULT 0 COMMENT '头像' ,
`slotma_addition`  int(11) NOT NULL DEFAULT 0 COMMENT '老虎机中奖权重' ,
`platform_id`  varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '平台id' ,
`reg_time`  datetime NULL DEFAULT NULL ,
`reg_gold`  int(11) NULL DEFAULT 0 ,
`bind_time`  datetime NULL DEFAULT NULL ,
`bind_gold`  int(11) NULL DEFAULT 0 ,
`is_collapse`  tinyint(5) NULL DEFAULT 0 COMMENT '是否破产，1破产，0不破产' ,
PRIMARY KEY (`guid`),
UNIQUE INDEX `index_account` (`account`, `platform_id`) USING BTREE ,
INDEX `index_is_android` (`is_android`) USING BTREE ,
INDEX `index_reg_time` (`reg_time`) USING BTREE ,
INDEX `index_bind_time` (`bind_time`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='玩家表'

;

-- ----------------------------
-- Records of t_player
-- ----------------------------
BEGIN;
INSERT INTO `t_player` VALUES ('44', '0', 'guest_44', 'guest_44', '0', '29999800', '0', '5', '0', '0', '0', '0', '8', '0', '2', '2019-08-20 13:48:16', '3000000', null, '0', '0'), ('45', '0', 'guest_45', 'guest_45', '0', '30000000', '0', '1', '0', '0', '0', '0', '7', '0', '2', '2019-08-20 13:49:08', '3000000', null, '0', '0'), ('46', '0', 'guest_46', 'guest_46', '0', '30000000', '0', '1', '0', '0', '0', '0', '7', '0', '2', '2019-08-20 15:41:32', '3000000', null, '0', '0'), ('47', '0', 'guest_47', 'guest_47', '0', '30000000', '0', '1', '0', '0', '0', '0', '7', '0', '2', '2019-08-20 15:56:34', '3000000', null, '0', '0'), ('48', '0', 'guest_48', 'guest_48', '0', '30000000', '0', '1', '0', '0', '0', '0', '4', '0', '2', '2019-08-20 16:02:20', '3000000', null, '0', '0'), ('49', '0', 'guest_49', 'guest_49', '0', '30000000', '0', '1', '0', '0', '0', '0', '5', '0', '2', '2019-08-21 12:03:48', '3000000', null, '0', '0'), ('50', '0', 'guest_50', 'guest_50', '0', '29995300', '1728737', '4', '0', '0', '0', '0', '2', '0', '2', '2019-08-21 14:09:18', '3000000', null, '0', '0'), ('51', '0', 'guest_51', 'lksajfioda', '0', '30000000', '2507389', '3', '0', '0', '0', '0', '8', '0', '2', '2019-08-21 14:42:23', '3000000', null, '0', '0'), ('52', '0', 'guest_52', 'guest_52', '0', '30000000', '0', '5', '0', '0', '0', '0', '9', '0', '2', '2019-08-21 14:47:53', '3000000', null, '0', '0'), ('53', '0', '15328200638', 'guest_53', '0', '34099566', '0', '5', '0', '0', '0', '0', '1', '0', '2', '2019-08-21 14:47:58', '3000000', '2019-08-24 22:31:08', '3000000', '0'), ('54', '0', '16606911142', 'guest_54', '0', '2858895', '0', '4', '0', '0', '0', '0', '5', '0', '2', '2019-08-21 15:28:45', '3000000', '2019-08-25 14:42:15', '3000000', '0'), ('55', '0', 'guest_55', 'guest_55', '0', '30000000', '0', '2', '0', '0', '0', '0', '9', '0', '2', '2019-08-21 18:08:10', '3000000', null, '0', '0'), ('56', '0', 'guest_56', 'guest_56', '0', '30000000', '0', '1', '0', '0', '0', '0', '4', '0', '2', '2019-08-21 19:47:11', '0', null, '0', '0'), ('57', '0', 'guest_57', 'guest_57', '0', '30000000', '0', '2', '0', '0', '0', '0', '3', '0', '2', '2019-08-21 20:17:06', '0', null, '0', '0'), ('58', '0', 'guest_58', 'guest_58', '0', '30000000', '0', '1', '0', '0', '0', '0', '8', '0', '2', '2019-08-21 21:28:51', '0', null, '0', '0'), ('59', '0', 'guest_59', 'guest_59', '0', '30000000', '0', '2', '0', '0', '0', '0', '3', '0', '2', '2019-08-22 09:33:36', '3000000', null, '0', '0'), ('60', '0', 'guest_60', 'guest_60', '0', '30000000', '0', '1', '0', '0', '0', '0', '8', '0', '2', '2019-08-22 10:01:07', '3000000', null, '0', '0'), ('61', '0', 'guest_61', 'guest_61', '0', '30000000', '0', '1', '0', '0', '0', '0', '5', '0', '2', '2019-08-22 15:43:38', '3000000', null, '0', '0'), ('62', '0', 'guest_62', 'guest_62', '0', '30000000', '0', '1', '0', '0', '0', '0', '10', '0', '2', '2019-08-23 21:46:00', '3000000', null, '0', '0'), ('63', '0', 'guest_63', 'guest_63', '0', '30000000', '0', '1', '0', '0', '0', '0', '1', '0', '2', '2019-08-23 22:03:37', '3000000', null, '0', '0'), ('64', '0', 'guest_64', 'dsalkdjaof', '0', '30000000', '0', '1', '0', '0', '0', '0', '7', '0', '2', '2019-08-23 23:23:03', '3000000', null, '0', '0'), ('65', '0', 'guest_65', 'guest_65', '0', '23925466', '23651555', '4', '0', '4097', '0', '0', '10', '0', '2', '2019-08-24 09:23:43', '3000000', null, '0', '0'), ('66', '0', '18808165675', 'guest_66', '0', '11541837', '25000000', '4', '0', '1731', '0', '0', '1', '0', '2', '2019-08-24 09:32:25', '3000000', '2019-08-24 22:32:56', '3000000', '0'), ('67', '0', 'guest_67', 'guest_67', '0', '30000000', '0', '1', '0', '0', '0', '0', '3', '0', '2', '2019-08-24 10:29:56', '3000000', null, '0', '0'), ('68', '0', 'guest_68', 'guest_68', '0', '30000000', '0', '1', '0', '0', '0', '0', '2', '0', '2', '2019-08-24 11:17:52', '0', null, '0', '0'), ('69', '0', 'guest_69', 'guest_69', '0', '30000000', '0', '1', '0', '0', '0', '0', '7', '0', '2', '2019-08-24 11:31:17', '0', null, '0', '0'), ('71', '0', 'guest_71', 'guest_71', '0', '30000000', '0', '1', '0', '0', '0', '0', '8', '0', '2', '2019-08-24 11:32:46', '0', null, '0', '0'), ('72', '0', 'guest_72', 'guest_72', '0', '30083395', '0', '2', '0', '0', '0', '0', '3', '0', '2', '2019-08-24 11:36:11', '0', null, '0', '0'), ('73', '0', 'guest_73', '吃了个鸡', '0', '30000000', '0', '1', '0', '0', '0', '0', '4', '0', '2', '2019-08-24 11:37:24', '0', null, '0', '0'), ('74', '0', '13733414639', 'guest_74', '0', '30313072', '99000', '1', '0', '2165', '0', '0', '8', '0', '2', '2019-08-24 11:43:51', '0', null, '0', '0'), ('75', '0', 'guest_75', 'guest_75', '0', '0', '0', '1', '0', '0', '0', '0', '4', '0', '2', '2019-08-24 22:36:02', '0', null, '0', '0'), ('76', '0', 'guest_76', 'guest_76', '0', '3000000', '0', '1', '0', '0', '0', '0', '9', '0', '2', '2019-08-25 02:31:35', '3000000', null, '0', '0'), ('77', '0', 'guest_77', 'guest_77', '0', '5231888', '0', '2', '0', '0', '0', '0', '10', '0', '2', '2019-08-25 10:11:18', '3000000', null, '0', '0'), ('78', '0', '18583968687', '18583968687', '0', '14077362', '0', '1', '0', '0', '0', '0', '3', '0', '2', '2019-08-25 10:43:48', '0', null, '0', '0'), ('79', '0', 'guest_79', 'guest_79', '0', '3000000', '0', '1', '0', '0', '0', '0', '3', '0', '2', '2019-08-25 14:37:22', '3000000', null, '0', '0'), ('80', '0', 'guest_80', 'guest_80', '0', '12945714', '0', '2', '0', '0', '0', '0', '2', '0', '2', '2019-08-25 15:09:33', '3000000', null, '0', '0'), ('81', '0', '15608008806', '15608008806', '0', '6000000', '0', '1', '0', '0', '0', '0', '4', '0', '2', '2019-08-25 15:57:08', '0', null, '0', '0'), ('82', '0', '18728483303', 'guest_82', '0', '6000000', '0', '1', '0', '0', '0', '0', '5', '0', '2', '2019-08-25 18:05:05', '3000000', '2019-08-25 18:05:40', '3000000', '0');
COMMIT;

-- ----------------------------
-- Table structure for t_player_bonus
-- ----------------------------
DROP TABLE IF EXISTS `t_player_bonus`;
CREATE TABLE `t_player_bonus` (
`guid`  int(11) NOT NULL COMMENT '玩家guid' ,
`bonus_activity_id`  int(11) NOT NULL COMMENT '红包活动id' ,
`bonus_index`  int(11) NOT NULL DEFAULT 1 COMMENT '红包索引(本次红包活动中第几个红包）' ,
`money`  int(11) NOT NULL COMMENT '红包中的钱' ,
`get_in_game_id`  int(11) NULL DEFAULT NULL COMMENT '在哪个frist_game_type中获得的红包' ,
`get_time`  datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '获得红包时间' ,
`valid_time_until`  datetime NULL DEFAULT NULL COMMENT '红包有效期至' ,
`is_pick`  int(11) NOT NULL DEFAULT 0 COMMENT '是否领取' ,
INDEX `index_guid` (`guid`) USING BTREE ,
INDEX `index_bonus_activity` (`bonus_activity_id`) USING BTREE ,
INDEX `index_get_time` (`get_time`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='玩家获得红包记录表'

;

-- ----------------------------
-- Records of t_player_bonus
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_player_bonus_activity_limit
-- ----------------------------
DROP TABLE IF EXISTS `t_player_bonus_activity_limit`;
CREATE TABLE `t_player_bonus_activity_limit` (
`guid`  int(11) NOT NULL ,
`activity_id`  int(11) NOT NULL ,
`bonus_index`  int(11) NOT NULL ,
`play_count_min`  int(11) NOT NULL DEFAULT 0 ,
`play_count_max`  int(11) NOT NULL ,
`money`  bigint(20) NOT NULL ,
PRIMARY KEY (`guid`, `activity_id`),
INDEX `guid_index` (`guid`) USING BTREE ,
INDEX `activity_index` (`activity_id`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci

;

-- ----------------------------
-- Records of t_player_bonus_activity_limit
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_pool_activity
-- ----------------------------
DROP TABLE IF EXISTS `t_pool_activity`;
CREATE TABLE `t_pool_activity` (
`id`  int(11) NOT NULL AUTO_INCREMENT ,
`game_id`  int(11) NULL DEFAULT NULL COMMENT '游戏ID config.t_game_server_cfg表 game_id' ,
`game_name`  varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '游戏名称config.t_game_server_cfg表 game_name' ,
`opt_type`  int(11) NULL DEFAULT NULL COMMENT '对应log.t_log_game_tj表opt_type' ,
`name`  varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '奖池名称' ,
`is_show`  tinyint(2) NULL DEFAULT 1 COMMENT '是否显示在游戏大厅：1显示 0不显示' ,
`is_open`  tinyint(2) NULL DEFAULT 1 COMMENT '奖池是否开启' ,
`time_start`  timestamp NULL DEFAULT NULL COMMENT '开始时间' ,
`time_end`  timestamp NULL DEFAULT NULL COMMENT '结束时间' ,
`pool_money`  bigint(20) NULL DEFAULT 0 COMMENT '奖池余额' ,
`pool_lucky`  int(11) NULL DEFAULT 0 COMMENT '中奖率' ,
`bet_add`  int(11) NULL DEFAULT NULL COMMENT '下注加权中奖' ,
`cfg`  text CHARACTER SET utf8 COLLATE utf8_general_ci NULL ,
`created_at`  timestamp NULL DEFAULT NULL COMMENT '创建时间' ,
`updated_at`  timestamp NULL DEFAULT NULL COMMENT '奖池配置' ,
PRIMARY KEY (`id`),
INDEX `index_time_start_end` (`time_start`, `time_end`) USING BTREE ,
INDEX `index_time_crated_updated` (`created_at`, `updated_at`) USING BTREE ,
INDEX `index_game_id` (`game_id`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
AUTO_INCREMENT=1

;

-- ----------------------------
-- Records of t_pool_activity
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_rank_update_time
-- ----------------------------
DROP TABLE IF EXISTS `t_rank_update_time`;
CREATE TABLE `t_rank_update_time` (
`rank_type`  int(11) NOT NULL COMMENT '排行榜类型' ,
`update_time`  timestamp NULL DEFAULT NULL COMMENT '上次更新时间' ,
PRIMARY KEY (`rank_type`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='排行榜更新时间表'

;

-- ----------------------------
-- Records of t_rank_update_time
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for t_weekly_earnings_rank
-- ----------------------------
DROP TABLE IF EXISTS `t_weekly_earnings_rank`;
CREATE TABLE `t_weekly_earnings_rank` (
`rank`  int(11) NOT NULL AUTO_INCREMENT COMMENT '排行榜' ,
`guid`  int(11) NOT NULL COMMENT '全局唯一标识符' ,
`nickname`  varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '昵称' ,
`money`  int(11) NOT NULL DEFAULT 0 COMMENT '钱' ,
PRIMARY KEY (`rank`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='周盈利榜表'
AUTO_INCREMENT=1

;

-- ----------------------------
-- Records of t_weekly_earnings_rank
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Procedure structure for bank_transfer
-- ----------------------------
DROP PROCEDURE IF EXISTS `bank_transfer`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `bank_transfer`(IN `guid_` int,IN `time_` int,IN `target_` varchar(64),IN `money_` int,IN `bank_balance_` int)
    COMMENT '银行转账，参数guid_：转账guid，time_：时间，target_：收款guid，money_：转多少钱，bank_balance_：剩下多少'
BEGIN
	DECLARE target_guid_ INT DEFAULT 0;
	DECLARE target_bank_ INT DEFAULT 0;

	UPDATE t_player SET bank = bank + money_ WHERE account = target_;
	IF ROW_COUNT() = 0 THEN
		SELECT 1 as ret, 0 as id;
	ELSE
		SELECT guid, bank INTO target_guid_, target_bank_ FROM t_player WHERE account = target_;
		
		
		SELECT 0 as ret, LAST_INSERT_ID() as id;
	END IF;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for change_player_bank_money
-- ----------------------------
DROP PROCEDURE IF EXISTS `change_player_bank_money`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `change_player_bank_money`(IN `guid_` int,IN `money_` bigint(20),IN `force_change_` int)
    COMMENT '银行转账，参数guid_：转账guid，money_：金钱'
label_pro:BEGIN
	DECLARE oldbank  bigint(20);
	SELECT bank INTO oldbank FROM t_player WHERE guid = guid_;
	IF oldbank is null THEN
		SELECT 4 as ret,0 as oldbank,0 as newbank;
		LEAVE label_pro;
	END IF;

	IF money_ = 0 THEN
		SELECT 1 as ret,oldbank,oldbank as newbank;
		LEAVE label_pro;
	END IF;

	IF money_ < 0 THEN
		IF oldbank = 0 THEN
			SELECT 2 as ret,oldbank,oldbank as newbank;
			LEAVE label_pro;
		END IF;

		IF oldbank + money_ < 0 THEN
			IF force_change_ = 0 THEN
				SELECT 2 as ret,oldbank,oldbank as newbank;
				LEAVE label_pro;
			ELSE
				SET money_ = -oldbank;
			END IF;
		END IF;
	END IF;

	UPDATE t_player set bank = bank + money_ WHERE guid = guid_ and bank = oldbank;
	IF ROW_COUNT() = 0 THEN
		SELECT 5 as ret,oldbank,oldbank as newbank;
	ELSE
		SELECT 1 as ret,oldbank,(oldbank + money_) as newbank;
	END IF;
	
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for check_money
-- ----------------------------
DROP PROCEDURE IF EXISTS `check_money`;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `check_money`()
BEGIN
	DECLARE money_change1  bigint(20) DEFAULT 0;
	DECLARE money_change2  bigint(20) DEFAULT 0;
	SELECT SUM(tax)+SUM(change_money) FROM log.t_log_money_tj WHERE game_name = 'zhajinhua' INTO money_change1; 
	IF money_change1 IS NULL THEN
		SET money_change1 = 0;
	END IF;

	SELECT money INTO money_change2 FROM t_bonus_pool WHERE bonus_pool_name = 'zhajinhua_bonus_pool';

	SELECT money_change1 as game_get_bonus ,money_change2 as left_bonus,money_change1+money_change2 as total_bonus;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for del_msg
-- ----------------------------
DROP PROCEDURE IF EXISTS `del_msg`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `del_msg`(IN `ID_` int,
 IN `TYPE_` int)
    COMMENT 'ID_ 消息ID,TYPE_ 消息类型'
BEGIN
  DECLARE guid_ INT DEFAULT 0;
    IF TYPE_ = 1 THEN 
        select guid into guid_ from t_notice_private where id = ID_;
        delete from t_notice_private where id = ID_;
        IF ROW_COUNT() > 0 then
            select 0 as ret, guid_ as guid ;
        ELSE
            select 1 as ret, 1 as guid ;
        END IF;
    ELSEIF TYPE_ = 2 or TYPE_ = 3 THEN 
        delete from t_notice where id = ID_;
        IF ROW_COUNT() > 0 then
            delete from t_notice_read where n_id = ID_;
            select 0 as ret, 1 as guid;
        ELSE
            select 1 as ret, 1 as guid;
        END IF;
    END IF;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_daily_earnings_rank
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_daily_earnings_rank`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_daily_earnings_rank`()
    COMMENT '得到日盈利榜'
BEGIN
	DECLARE last_time_ TIMESTAMP DEFAULT 0;
	SELECT update_time INTO last_time_ FROM t_rank_update_time WHERE rank_type = 2;
	IF last_time_ = 0 OR TO_DAYS(NOW()) != TO_DAYS(last_time_) THEN
		TRUNCATE TABLE t_daily_earnings_rank;
		INSERT INTO t_daily_earnings_rank (guid, nickname, money) SELECT t_earnings.guid, t_player.nickname, t_earnings.daily_earnings FROM t_earnings, t_player WHERE t_earnings.daily_earnings > 0 AND t_earnings.guid = t_player.guid ORDER BY t_earnings.daily_earnings DESC LIMIT 50;
		REPLACE INTO t_rank_update_time SET rank_type = 2, update_time = NOW();
		UPDATE t_earnings SET daily_earnings = 0;
	END IF;
	SELECT * FROM t_daily_earnings_rank;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_fortune_rank
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_fortune_rank`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_fortune_rank`()
    COMMENT '总财富榜'
BEGIN
	DECLARE last_time_ TIMESTAMP DEFAULT 0;
	SELECT update_time INTO last_time_ FROM t_rank_update_time WHERE rank_type = 1;
	IF last_time_ = 0 OR TO_DAYS(NOW()) != TO_DAYS(last_time_) THEN
		TRUNCATE TABLE t_fortune_rank;
		INSERT INTO t_fortune_rank (guid, nickname, money) SELECT guid, nickname, money+bank FROM t_player WHERE money+bank > 0 ORDER BY money+bank DESC LIMIT 50;
		REPLACE INTO t_rank_update_time SET rank_type = 1, update_time = NOW();
	END IF;
	SELECT * FROM t_fortune_rank;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_monthly_earnings_rank
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_monthly_earnings_rank`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_monthly_earnings_rank`()
    COMMENT '得到月盈利榜'
BEGIN
	DECLARE last_time_ TIMESTAMP DEFAULT 0;
	SELECT update_time INTO last_time_ FROM t_rank_update_time WHERE rank_type = 4;
	IF last_time_ = 0 OR EXTRACT(YEAR_MONTH FROM NOW()) != EXTRACT(YEAR_MONTH FROM last_time_) THEN
		TRUNCATE TABLE t_monthly_earnings_rank;
		INSERT INTO t_monthly_earnings_rank (guid, nickname, money) SELECT t_earnings.guid, t_player.nickname, t_earnings.monthly_earnings FROM t_earnings, t_player WHERE t_earnings.monthly_earnings > 0 AND t_earnings.guid = t_player.guid ORDER BY t_earnings.monthly_earnings DESC LIMIT 50;
		REPLACE INTO t_rank_update_time SET rank_type = 4, update_time = NOW();
		UPDATE t_earnings SET monthly_earnings = 0;
	END IF;
	SELECT * FROM t_monthly_earnings_rank;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_player_data
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_player_data`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_player_data`(IN `guid_` int,IN `account_` varchar(64),IN `nick_` varchar(64),IN `money_` int,IN `platform_id_`  varchar(256), In `is_guest` int,IN `reg_money_` int)
BEGIN
	DECLARE guid_tmp INTEGER DEFAULT 0; 
	DECLARE t_error INTEGER DEFAULT 0; 
	DECLARE done INT DEFAULT 0; 
	DECLARE suc INT DEFAULT 1; 
	DECLARE tmp_val INTEGER DEFAULT 0; 
	DECLARE tmp_total INTEGER DEFAULT 0;
	DECLARE updateNum INT DEFAULT 1;
	DECLARE deleteNum INT DEFAULT 0;
	DECLARE selectNum INT DEFAULT 0;
	DECLARE header_icon_ int default 1;
	DECLARE mycur CURSOR FOR SELECT `val` FROM t_channel_invite_tax WHERE guid=guid_;#定义光标 
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
					
	SELECT guid INTO guid_tmp FROM t_player WHERE guid=guid_;
	IF guid_tmp = 0 THEN
		select mod(RAND() * 10, 10) into header_icon_;
		REPLACE INTO t_player SET guid=guid_,account=account_,nickname=nick_,money=money_,platform_id = platform_id_,header_icon = header_icon_,reg_time=current_timestamp,reg_gold=reg_money_;
	ELSE
			#START TRANSACTION; #打开光标  
			#OPEN mycur; #开始循环 
			#REPEAT 
			#		FETCH mycur INTO tmp_val;
			#		 IF NOT done THEN
			#				SET selectNum = selectNum+1;
			#				SET tmp_total = tmp_total + tmp_val;
			#				IF t_error = 1 THEN 
			#					SET suc = 0;
			#				END IF;  
			#		 END IF; 
			#UNTIL done END REPEAT;
			#CLOSE mycur;
			#IF tmp_total > 0 THEN
			#	UPDATE t_player SET money=money+(tmp_total) WHERE guid=guid_;
			#	SET updateNum = row_count();
			#END IF;
			#DELETE FROM t_channel_invite_tax WHERE guid=guid_;
			#SET deleteNum = row_count();
			
			#IF suc = 0 OR updateNum < 1 OR deleteNum != selectNum THEN
			#		ROLLBACK;
			#ELSE
			#		COMMIT; 
			#END IF;
			SET suc = 1;
		if is_guest = 2 then
			update t_player set money = money + money_ , reg_gold=0 where guid = guid_;
		end if;
	END IF;
	SELECT level, money, bank, login_award_day, login_award_receive_day, online_award_time, online_award_num, relief_payment_count, header_icon, slotma_addition FROM t_player WHERE guid=guid_;
	
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_player_invite_reward
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_player_invite_reward`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_player_invite_reward`(IN `guid_` int)
BEGIN
	DECLARE t_error INTEGER DEFAULT 0; 
	DECLARE done INT DEFAULT 0; 
	DECLARE suc INT DEFAULT 1; 
	DECLARE tmp_val INTEGER DEFAULT 0; 
	DECLARE tmp_total INTEGER DEFAULT 0;
	DECLARE deleteNum INT DEFAULT 0;
	DECLARE selectNum INT DEFAULT 0;

	DECLARE mycur CURSOR FOR SELECT `val` FROM t_channel_invite_tax WHERE guid=guid_;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
					
	START TRANSACTION; 
	OPEN mycur; 
	REPEAT 
		FETCH mycur INTO tmp_val;
	  IF NOT done THEN
					SET selectNum = selectNum+1;
					SET tmp_total = tmp_total + tmp_val;
					IF t_error = 1 THEN 
						SET suc = 0;
					END IF;  
			 END IF; 
	UNTIL done END REPEAT;
	CLOSE mycur;


	DELETE FROM t_channel_invite_tax WHERE guid=guid_;
	SET deleteNum = row_count();

	IF suc = 0 OR deleteNum != selectNum THEN
		ROLLBACK;
	ELSE
		COMMIT; 
	END IF;

	SELECT tmp_total as total_reward;
	
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_player_notice
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_player_notice`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_player_notice`(IN `guid_` int,IN `platform_id_`  varchar(256))
BEGIN

--	select * from (
--		select a.id as id,UNIX_TIMESTAMP(a.start_time) as start_time,UNIX_TIMESTAMP(a.end_time) as end_time,'2' as msg_type,
--		if(isnull(b.is_read),1,2) as is_read,a.content as content from t_notice a 
--		LEFT JOIN t_notice_read b on a.id = b.n_id and b.guid = guid_ where a.end_time > FROM_UNIXTIME(UNIX_TIMESTAMP()) and a.type = 2 and a.platform_ids like CONCAT('%,',platform_id_,',%')
--		union all
--		select c.id as id,UNIX_TIMESTAMP(c.start_time) as start_time,UNIX_TIMESTAMP(c.end_time) as end_time,'1' as msg_type,
--		if(c.is_read = 0,1,2) as is_read, c.content as content from t_notice_private as c 
--		where c.guid = guid_ and c.type = 1 and c.end_time > FROM_UNIXTIME(UNIX_TIMESTAMP())
--	) d order by end_time desc LIMIT 20;

	select a.id as id,UNIX_TIMESTAMP(a.start_time) as start_time,UNIX_TIMESTAMP(a.end_time) as end_time,'2' as msg_type,
		if(isnull(b.is_read),1,2) as is_read,a.content as content from t_notice a 
		LEFT JOIN t_notice_read b on a.id = b.n_id and b.guid = guid_ where a.end_time > FROM_UNIXTIME(UNIX_TIMESTAMP()) and a.type = 2 and a.platform_ids like CONCAT('%,',platform_id_,',%')
		union all
		(select c.id as id,UNIX_TIMESTAMP(c.start_time) as start_time,UNIX_TIMESTAMP(c.end_time) as end_time,'1' as msg_type,
		if(c.is_read = 0,1,2) as is_read, c.content as content from t_notice_private as c 
		where c.guid = guid_ and c.type = 1 and c.end_time > FROM_UNIXTIME(UNIX_TIMESTAMP()) order by end_time limit 20);
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_player_register_money
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_player_register_money`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_player_register_money`(IN `guid_` int)
BEGIN
    DECLARE reg_money_ int default 0;
    select reg_gold into reg_money_ from t_player where guid = guid_ ;
    select reg_money_ as retcode ;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for get_weekly_earnings_rank
-- ----------------------------
DROP PROCEDURE IF EXISTS `get_weekly_earnings_rank`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_weekly_earnings_rank`()
    COMMENT '得到周盈利榜'
BEGIN
	DECLARE last_time_ TIMESTAMP DEFAULT 0;
	SELECT update_time INTO last_time_ FROM t_rank_update_time WHERE rank_type = 3;
	IF last_time_ = 0 OR YEARWEEK(NOW()) != YEARWEEK(last_time_) THEN
		TRUNCATE TABLE t_weekly_earnings_rank;
		INSERT INTO t_weekly_earnings_rank (guid, nickname, money) SELECT t_earnings.guid, t_player.nickname, t_earnings.weekly_earnings FROM t_earnings, t_player WHERE t_earnings.weekly_earnings > 0 AND t_earnings.guid = t_player.guid ORDER BY t_earnings.weekly_earnings DESC LIMIT 50;
		REPLACE INTO t_rank_update_time SET rank_type = 3, update_time = NOW();
		UPDATE t_earnings SET weekly_earnings = 0;
	END IF;
	SELECT * FROM t_weekly_earnings_rank;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for judge_player_is_collapse
-- ----------------------------
DROP PROCEDURE IF EXISTS `judge_player_is_collapse`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `judge_player_is_collapse`(IN `guid_` int(11))
    COMMENT '判断玩家是否破产以及取渠道和平台id'
BEGIN
	DECLARE result_ TEXT DEFAULT '';
	DECLARE channel_id_ varchar(255);
	DECLARE is_collapse_ tinyint(5) DEFAULT 0 ;
	DECLARE platform_id_ VARCHAR(255);
	
    
	SELECT is_collapse,platform_id INTO is_collapse_,platform_id_ FROM t_player WHERE guid=guid_;
  set result_ = '{';
  #该玩家破产
	IF is_collapse_ = 1 THEN
		SELECT channel_id INTO channel_id_ FROM `account`.`t_account` WHERE guid=guid_;
		IF CHAR_LENGTH(channel_id_) > 0 THEN
			set result_ = concat( result_ ,' "is_collapse": ', is_collapse_ , ' , "platform_id" : "' , platform_id_ , '" , "channel_id" : "' , channel_id_ , '" ' );
			UPDATE t_player SET is_collapse = 0 WHERE guid=guid_;
		END IF;
	END IF;
	set result_ = concat( result_ ,'}\n'); 
	SELECT result_ as retdata;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for proc_bank_save_back
-- ----------------------------
DROP PROCEDURE IF EXISTS `proc_bank_save_back`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_bank_save_back`(IN `guid_` int, out `result_info` TEXT , out `bank_moeny` bigint)
    COMMENT '得到充值数据'
BEGIN
	DECLARE done INT DEFAULT 0;
    DECLARE id_ int(11);
    DECLARE save_back_money_ bigint(50);
    DECLARE ret int;
    DECLARE oldbank bigint(50);
    DECLARE newbank bigint(50);
    
	DECLARE cur1 CURSOR FOR select id,save_back_money from t_bank_save_back where guid = guid_ and status = 0;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
    
    set result_info = ',\n "save_back" :  [  ';
    
	OPEN cur1;
    REPEAT
    FETCH cur1 INTO id_,save_back_money_;
    if not done then
        set ret = 0,oldbank = 0 , newbank = 0;
        update t_bank_save_back set status = 1 where id = id_ and guid = guid_ and status = 0;
        IF ROW_COUNT() > 0 THEN
            call `game`.`recharge_use_change_player_bank_money`(guid_,save_back_money_,ret , oldbank , newbank );
            if ret = 1 then
                set bank_moeny = newbank;
                set result_info = concat( result_info ,'{ "id": ', id_ , ' , "save_back_money" : ' , save_back_money_ ,' , "oldbank" : ', oldbank , ' , "newbank" : ' , newbank , ' } ,\n' );
                update t_bank_save_back set status = 1 ,before_bank = oldbank , after_bank = newbank ,updated_at = CURRENT_TIMESTAMP where id = id_ and guid = guid_ and status = 1;
            else
                update t_bank_save_back set status = 0 where id = id_ and guid = guid_ and status = 1;
            end if;
        END IF;
    end if;
    UNTIL done END REPEAT;
    set result_info = left(result_info , char_length(result_info) - 2);
    set result_info = concat( result_info , '\n]');
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for recharge_use_change_player_bank_money
-- ----------------------------
DROP PROCEDURE IF EXISTS `recharge_use_change_player_bank_money`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `recharge_use_change_player_bank_money`(IN `guid_` int,IN `money_` bigint(20), out `ret` int , out `oldbank` int(50) , out `newbank` int(50))
    COMMENT '银行转账，参数guid_：转账guid，money_：金钱'
label_pro:BEGIN
    select bank into oldbank from t_player where guid = guid_;
    if oldbank is not null THEN
        if money_ = 0 THEN
            select 1 , oldbank into ret, newbank;
            -- select 1 as ret,oldbank,oldbank as newbank;
            leave label_pro;
        END IF;

        if money_ < 0 THEN
            if oldbank + money_ < 0 THEN
                select 2 , oldbank into ret, newbank;
            -- select 2 as ret,oldbank,oldbank as newbank;
            leave label_pro;
            end if;
        end if;
        update t_player set bank = bank + money_ where guid = guid_  and bank = oldbank;
        IF ROW_COUNT() = 0 THEN
            select 5 , oldbank into ret, newbank;
        else
            select 1 , (oldbank + money_) into ret, newbank;
        END IF;
    else
        select 4, 0 , 0 into ret, oldbank , newbank ;
        leave label_pro;
    end if;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for save_bank_statement
-- ----------------------------
DROP PROCEDURE IF EXISTS `save_bank_statement`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `save_bank_statement`(IN `guid_` int,IN `time_` int,IN `opt_` int,IN `target_` varchar(64),IN `money_` int,IN `bank_balance_` int)
    COMMENT '保存银行流水，参数guid_：操作guid，time_：时间，opt_：操作类型，target_：目标guid，money_：操作多少钱，bank_balance_：剩下多少'
BEGIN
	INSERT INTO t_bank_statement (guid,time,opt,target,money,bank_balance) VALUES(guid_,FROM_UNIXTIME(time_),opt_,target_,money_,bank_balance_);
	SELECT LAST_INSERT_ID() as id;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for send_mail
-- ----------------------------
DROP PROCEDURE IF EXISTS `send_mail`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `send_mail`(IN `expiration_time_` int,IN `guid_` int,IN `send_guid_` int,IN `send_name_` varchar(32),IN `title_` varchar(32),IN `content_` varchar(128),IN `attachment_` blob)
    COMMENT '发送邮件，参数expiration_time_：过期时间，guid_：收件guid，send_guid_：发件guid，send_name_：发件名字，title_：标题，content_：内容， attachment_：附件'
BEGIN
	IF NOT EXISTS(SELECT 1 FROM t_player WHERE guid = guid_) THEN
		SELECT 1 as ret, 0 as id;
	ELSE
		INSERT INTO t_mail (expiration_time, guid, send_guid, send_name, title, content, attachment) VALUES (FROM_UNIXTIME(expiration_time_), guid_, send_guid_, send_name_, title_, content_, attachment_);
		SELECT 0 as ret, LAST_INSERT_ID() as id;
	END IF;
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for update_player_register
-- ----------------------------
DROP PROCEDURE IF EXISTS `update_player_register`;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_player_register`()
BEGIN
	DECLARE done INT DEFAULT 0;
	DECLARE guid_ int(11);
    DECLARE is_guest_ int(11);
    DECLARE create_time_ timestamp;
    DECLARE register_time_ timestamp;
    
    
	DECLARE cur1 CURSOR FOR select guid,is_guest,create_time,register_time from account.t_account;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;

	OPEN cur1;

    REPEAT
    FETCH cur1 INTO guid_, is_guest_, create_time_, register_time_;
    IF NOT done THEN
        IF is_guest_ = 0 THEN
            update t_player set reg_time = create_time_ , reg_gold = 300 , bind_time = register_time_ , bind_gold = 300 where guid = guid_;
        else
            update t_player set reg_time = create_time_ , reg_gold = 300 where guid = guid_;
        END IF;
    END IF;
    UNTIL done END REPEAT;
END
;;
DELIMITER ;

-- ----------------------------
-- Auto increment value for t_bank_save_back
-- ----------------------------
ALTER TABLE `t_bank_save_back` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for t_bank_statement
-- ----------------------------
ALTER TABLE `t_bank_statement` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for t_bonus_activity
-- ----------------------------
ALTER TABLE `t_bonus_activity` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for t_channel_invite_tax
-- ----------------------------
ALTER TABLE `t_channel_invite_tax` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for t_daily_earnings_rank
-- ----------------------------
ALTER TABLE `t_daily_earnings_rank` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for t_fortune_rank
-- ----------------------------
ALTER TABLE `t_fortune_rank` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for t_mail
-- ----------------------------
ALTER TABLE `t_mail` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for t_monthly_earnings_rank
-- ----------------------------
ALTER TABLE `t_monthly_earnings_rank` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for t_notice
-- ----------------------------
ALTER TABLE `t_notice` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for t_notice_private
-- ----------------------------
ALTER TABLE `t_notice_private` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for t_ox_player_info
-- ----------------------------
ALTER TABLE `t_ox_player_info` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for t_pool_activity
-- ----------------------------
ALTER TABLE `t_pool_activity` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for t_weekly_earnings_rank
-- ----------------------------
ALTER TABLE `t_weekly_earnings_rank` AUTO_INCREMENT=1;