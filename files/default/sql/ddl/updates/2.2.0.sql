DROP VIEW `hops_users`;

DROP TABLE `address`;
DROP TABLE `organization`;
DROP TABLE `authorized_sshkeys`;
DROP TABLE `ssh_keys`;

ALTER TABLE `users` DROP COLUMN `security_question`, DROP COLUMN `security_answer`, DROP COLUMN `mobile`;

ALTER TABLE `hopsworks`.`feature_store_tag` DROP COLUMN `type`;
ALTER TABLE `hopsworks`.`feature_store_tag` ADD COLUMN `tag_schema` VARCHAR(13000) NOT NULL DEFAULT '{"type":"string"}';
CREATE TABLE IF NOT EXISTS `validation_rule` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) COLLATE latin1_general_cs DEFAULT NULL,
  `predicate` varchar(45) COLLATE latin1_general_cs DEFAULT NULL,
  `accepted_type` varchar(45) COLLATE latin1_general_cs DEFAULT NULL,
  `description` varchar(100) COLLATE latin1_general_cs DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_validation_rule` (`name`,`predicate`,`accepted_type`)
) ENGINE=ndbcluster AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_store_expectation` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(100) COLLATE latin1_general_cs DEFAULT NULL,
    `description` varchar(1000) COLLATE latin1_general_cs DEFAULT NULL,
    `feature_store_id` int(11) NOT NULL,
    `assertions` varchar(12000) COLLATE latin1_general_cs DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `unique_fs_rules` (`feature_store_id`,`name`),
    CONSTRAINT `fk_fs_expectation_to_fs` FOREIGN KEY (`feature_store_id`) REFERENCES `feature_store` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_group_expectation` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `feature_group_id` int(11) NOT NULL,
    `feature_store_expectation_id` int(11) NOT NULL,
    `description` varchar(1000) COLLATE latin1_general_cs DEFAULT NULL,
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_fg_expectation_to_fg` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fk_fg_expectation_to_fs_expectation` FOREIGN KEY (`feature_store_expectation_id`) REFERENCES `feature_store_expectation` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE IF NOT EXISTS `feature_store_expectation_rule` (
    `feature_store_expectation_id` int(11) NOT NULL,
    `validation_rule_id` int(11) NOT NULL,
    PRIMARY KEY (`feature_store_expectation_id`, `validation_rule_id`),
    CONSTRAINT `fk_fs_expectation_rule_id` FOREIGN KEY (`feature_store_expectation_id`) REFERENCES `feature_store_expectation` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `fk_validation_rule_id` FOREIGN KEY (`validation_rule_id`) REFERENCES `validation_rule` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE  IF NOT EXISTS `feature_group_validation` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `validation_time` TIMESTAMP(3),
    `inode_pid` BIGINT(20) NOT NULL,
    `inode_name` VARCHAR(255) COLLATE latin1_general_cs NOT NULL,
    `partition_id` BIGINT(20) NOT NULL,
    `feature_group_id` INT(11),
    `status` VARCHAR(20) COLLATE latin1_general_cs NOT NULL,
    PRIMARY KEY (`id`),
    KEY `feature_group_id` (`feature_group_id`),
    CONSTRAINT `fg_fk_fgv` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `featuregroupvalidation_inode_fk` FOREIGN KEY (`inode_pid`,`inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_group` ADD COLUMN `validation_type` INT(11) DEFAULT '4' AFTER `corr_method`;
ALTER TABLE `hopsworks`.`feature_group_commit` ADD COLUMN `validation_id` int(11), ADD CONSTRAINT `fgc_fk_fgv` FOREIGN KEY (`validation_id`) REFERENCES `feature_group_validation` (`id`) ON DELETE SET NULL  ON UPDATE NO ACTION;
ALTER TABLE `hopsworks`.`oauth_client` 
ADD COLUMN `end_session_endpoint` VARCHAR(1024) DEFAULT NULL,
ADD COLUMN `logout_redirect_param` VARCHAR(45) DEFAULT NULL;

CREATE TABLE `feature_store_activity` (
  `id`                            INT(11) NOT NULL AUTO_INCREMENT,
  `event_time`                    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `uid`                           INT(11) NOT NULL,
  `type`                          INT(11) NOT NULL,
  `meta_type`                     INT(11) NULL,
  `meta_msg`                      VARCHAR(255) NULL,
  `execution_id`                  INT(11) NULL,
  `execution_last_event_time`     BIGINT(20) NULL,
  `statistics_id`                 INT(11) NULL,
  `commit_id`                     BIGINT(20) NULL,
  `validation_id`                 INT(11) NULL,
  `feature_group_id`              INT(11) NULL,
  `training_dataset_id`           INT(11) NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fs_act_fg_fk` FOREIGN KEY (`feature_group_id`) REFERENCES `feature_group` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fs_act_td_fk` FOREIGN KEY (`training_dataset_id`) REFERENCES `training_dataset` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fs_act_uid_fk` FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fs_act_exec_fk` FOREIGN KEY (`execution_id`) REFERENCES `executions` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fs_act_stat_fk` FOREIGN KEY (`statistics_id`) REFERENCES `feature_store_statistic` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fs_act_val_fk` FOREIGN KEY (`validation_id`) REFERENCES `feature_group_validation` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fs_act_commit_fk` FOREIGN KEY (`feature_group_id`, `commit_id`) REFERENCES `feature_group_commit` (`feature_group_id`, `commit_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_store_statistic` MODIFY `commit_time` DATETIME(3)  NOT NULL,
    ADD COLUMN `feature_group_commit_id` BIGINT(20),
    ADD CONSTRAINT `fg_ci_fk_fss` FOREIGN KEY (`feature_group_id`, `feature_group_commit_id`) REFERENCES `feature_group_commit` (`feature_group_id`, `commit_id`) ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`training_dataset` ADD COLUMN `coalesce` TINYINT(1) NOT NULL DEFAULT '0';

CREATE TABLE IF NOT EXISTS `hopsworks`.`feature_store_snowflake_connector` (
  `id`                       INT(11)       NOT NULL AUTO_INCREMENT,
  `url`                      VARCHAR(3000) NOT NULL,
  `database_user`            VARCHAR(128)  NOT NULL,
  `database_name`            VARCHAR(64)   NOT NULL,
  `database_schema`          VARCHAR(45)   NOT NULL,
  `table_name`               VARCHAR(128)  DEFAULT NULL,
  `role`                     VARCHAR(65)   DEFAULT NULL,
  `warehouse`                VARCHAR(128)  DEFAULT NULL,
  `arguments`                VARCHAR(8000) DEFAULT NULL,
  `database_pwd_secret_uid`  INT DEFAULT NULL,
  `database_pwd_secret_name` VARCHAR(200) DEFAULT NULL,
  `oauth_token_secret_uid`   INT DEFAULT NULL,
  `oauth_token_secret_name`  VARCHAR(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_feature_store_snowflake_connector_2_idx` (`database_pwd_secret_uid`,`database_pwd_secret_name`),
  CONSTRAINT `fk_feature_store_snowflake_connector_2` FOREIGN KEY (`database_pwd_secret_uid`, `database_pwd_secret_name`)
  REFERENCES `hopsworks`.`secrets` (`uid`, `secret_name`) ON DELETE RESTRICT,
  KEY `fk_feature_store_snowflake_connector_3_idx` (`oauth_token_secret_uid`,`oauth_token_secret_name`),
  CONSTRAINT `fk_feature_store_snowflake_connector_3` FOREIGN KEY (`oauth_token_secret_uid`, `oauth_token_secret_name`)
  REFERENCES `hopsworks`.`secrets` (`uid`, `secret_name`) ON DELETE RESTRICT
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_store_connector`
  ADD COLUMN `snowflake_id` INT(11) after `adls_id`,
  ADD CONSTRAINT `fs_connector_snowflake_fk` FOREIGN KEY (`snowflake_id`) REFERENCES `hopsworks`.`feature_store_snowflake_connector` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`jupyter_git_config` CHANGE `api_key_name` `api_key_name` VARCHAR(125) DEFAULT NULL;

-- drop metadata designer
DROP TABLE IF EXISTS `meta_data`;
DROP TABLE IF EXISTS `meta_field_predefined_values`;
DROP TABLE IF EXISTS `meta_raw_data`;
DROP TABLE IF EXISTS `meta_fields`;
DROP TABLE IF EXISTS `meta_field_types`;
DROP TABLE IF EXISTS `meta_tables`;
DROP TABLE IF EXISTS `meta_template_to_inode`;
DROP TABLE IF EXISTS `meta_templates`;
DROP TABLE IF EXISTS `meta_inode_basic_metadata`;
DROP TABLE IF EXISTS `meta_tuple_to_file`;
DROP TABLE IF EXISTS `meta_log`;

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `serving_tool` INT(11) NOT NULL DEFAULT '0';
ALTER TABLE `hopsworks`.`serving` RENAME COLUMN `serving_type` TO `model_server`;
