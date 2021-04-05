CREATE TABLE `address` (
  `address_id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL,
  `address1` varchar(100) COLLATE latin1_general_cs DEFAULT '-',
  `address2` varchar(100) COLLATE latin1_general_cs DEFAULT '-',
  `address3` varchar(100) COLLATE latin1_general_cs DEFAULT '-',
  `city` varchar(40) COLLATE latin1_general_cs DEFAULT 'San Francisco',
  `state` varchar(50) COLLATE latin1_general_cs DEFAULT 'CA',
  `country` varchar(40) COLLATE latin1_general_cs DEFAULT 'US',
  `postalcode` varchar(10) COLLATE latin1_general_cs DEFAULT '-',
  PRIMARY KEY (`address_id`),
  KEY `uid` (`uid`),
  CONSTRAINT `FK_257_265` FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster AUTO_INCREMENT=178 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE `authorized_sshkeys` (
  `project` varchar(64) NOT NULL,
  `user` varchar(48) NOT NULL,
  `sshkey_name` varchar(64) NOT NULL,
  PRIMARY KEY (`project`,`user`,`sshkey_name`),
  KEY `idx_user` (`user`),
  KEY `idx_project` (`project`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1;

CREATE TABLE `ssh_keys` (
  `uid` int(11) NOT NULL,
  `name` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `public_key` varchar(2000) COLLATE latin1_general_cs NOT NULL,
  PRIMARY KEY (`uid`,`name`),
  CONSTRAINT `FK_257_471` FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

CREATE TABLE `organization` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) DEFAULT NULL,
  `org_name` varchar(100) COLLATE latin1_general_cs DEFAULT '-',
  `website` varchar(2083) COLLATE latin1_general_cs DEFAULT '-',
  `contact_person` varchar(100) COLLATE latin1_general_cs DEFAULT '-',
  `contact_email` varchar(150) COLLATE latin1_general_cs DEFAULT '-',
  `department` varchar(100) COLLATE latin1_general_cs DEFAULT '-',
  `phone` varchar(20) COLLATE latin1_general_cs DEFAULT '-',
  `fax` varchar(20) COLLATE latin1_general_cs DEFAULT '-',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`),
  CONSTRAINT `FK_257_380` FOREIGN KEY (`uid`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster AUTO_INCREMENT=178 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

ALTER TABLE `users`
    ADD COLUMN `security_question` varchar(20) COLLATE latin1_general_cs DEFAULT NULL,
    ADD COLUMN `security_answer` varchar(128) COLLATE latin1_general_cs DEFAULT NULL,
    ADD COLUMN `mobile` varchar(15) COLLATE latin1_general_cs DEFAULT "-";

ALTER TABLE `hopsworks`.`feature_store_tag` ADD COLUMN `type` varchar(45) NOT NULL DEFAULT 'STRING';
ALTER TABLE `hopsworks`.`feature_store_tag` DROP COLUMN `tag_schema`;
DROP TABLE IF EXISTS `validation_rule`;
DROP TABLE IF EXISTS `feature_group_rule`;
DROP TABLE IF EXISTS `feature_group_validation`;
DROP TABLE IF EXISTS `feature_store_expectation_rule`;
ALTER TABLE `hopsworks`.`feature_group` DROP COLUMN `validation_type`;

ALTER TABLE `hopsworks`.`oauth_client` 
DROP COLUMN `end_session_endpoint`,
DROP COLUMN `logout_redirect_param`;

DROP TABLE `feature_store_activity`;

ALTER TABLE `hopsworks`.`feature_store_statistic` MODIFY `commit_time` VARCHAR(30) NOT NULL,
    DROP COLUMN `feature_group_commit_id`,
    DROP FOREIGN KEY `fg_ci_fk_fss`;

ALTER TABLE `hopsworks`.`training_dataset` DROP COLUMN `coalesce`;

ALTER TABLE `hopsworks`.`feature_store_connector` 
DROP FOREIGN KEY `fs_connector_snowflake_fk`,
DROP COLUMN `snowflake_id`;

DROP TABLE IF EXISTS `hopsworks`.`feature_store_snowflake_connector`;

ALTER TABLE `hopsworks`.`jupyter_git_config` CHANGE `api_key_name` `api_key_name` VARCHAR(125) NOT NULL;

-- redo metadata designer

--
-- Table structure for table `meta_data`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meta_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data` varchar(12000) COLLATE latin1_general_cs NOT NULL,
  `fieldid` int(11) NOT NULL,
  `tupleid` int(11) NOT NULL,
  PRIMARY KEY (`id`,`fieldid`,`tupleid`),
  KEY `fieldid` (`fieldid`,`tupleid`),
  CONSTRAINT `FK_404_411` FOREIGN KEY (`fieldid`,`tupleid`) REFERENCES `meta_raw_data` (`fieldid`,`tupleid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meta_field_predefined_values`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meta_field_predefined_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fieldid` int(11) NOT NULL,
  `valuee` varchar(250) COLLATE latin1_general_cs NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fieldid` (`fieldid`),
  CONSTRAINT `FK_390_398` FOREIGN KEY (`fieldid`) REFERENCES `meta_fields` (`fieldid`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meta_raw_data`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meta_raw_data` (
  `fieldid` int(11) NOT NULL,
  `tupleid` int(11) NOT NULL,
  PRIMARY KEY (`fieldid`,`tupleid`),
  KEY `tupleid` (`tupleid`),
  CONSTRAINT `FK_390_405` FOREIGN KEY (`fieldid`) REFERENCES `meta_fields` (`fieldid`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_400_406` FOREIGN KEY (`tupleid`) REFERENCES `meta_tuple_to_file` (`tupleid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meta_fields`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meta_fields` (
  `fieldid` int(11) NOT NULL AUTO_INCREMENT,
  `maxsize` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE latin1_general_cs DEFAULT NULL,
  `required` tinyint(1) DEFAULT NULL,
  `searchable` tinyint(1) DEFAULT NULL,
  `tableid` int(11) DEFAULT NULL,
  `type` varchar(255) COLLATE latin1_general_cs DEFAULT NULL,
  `ftype` mediumint(11) DEFAULT '3',
  `description` varchar(250) COLLATE latin1_general_cs NOT NULL,
  `fieldtypeid` mediumint(11) NOT NULL,
  `position` mediumint(11) DEFAULT '0',
  PRIMARY KEY (`fieldid`),
  KEY `tableid` (`tableid`),
  KEY `fieldtypeid` (`fieldtypeid`),
  CONSTRAINT `FK_386_392` FOREIGN KEY (`tableid`) REFERENCES `meta_tables` (`tableid`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_384_393` FOREIGN KEY (`fieldtypeid`) REFERENCES `meta_field_types` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meta_field_types`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meta_field_types` (
  `id` mediumint(9) NOT NULL AUTO_INCREMENT,
  `description` varchar(50) COLLATE latin1_general_cs NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=ndbcluster AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meta_tables`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meta_tables` (
  `tableid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE latin1_general_cs DEFAULT NULL,
  `templateid` int(11) NOT NULL,
  PRIMARY KEY (`tableid`),
  KEY `templateid` (`templateid`),
  CONSTRAINT `FK_382_388` FOREIGN KEY (`templateid`) REFERENCES `meta_templates` (`templateid`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meta_template_to_inode`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meta_template_to_inode` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `inode_pid` bigint(20) NOT NULL,
  `inode_name` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `partition_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `template_id` (`template_id`),
  KEY `inode_pid` (`inode_pid`,`inode_name`,`partition_id`),
  CONSTRAINT `FK_149_416` FOREIGN KEY (`inode_pid`,`inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_382_415` FOREIGN KEY (`template_id`) REFERENCES `meta_templates` (`templateid`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meta_templates`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meta_templates` (
  `templateid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(250) COLLATE latin1_general_cs NOT NULL,
  PRIMARY KEY (`templateid`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meta_inode_basic_metadata`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meta_inode_basic_metadata` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inode_pid` bigint(20) NOT NULL,
  `inode_name` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `partition_id` bigint(20) NOT NULL,
  `description` varchar(3000) COLLATE latin1_general_cs DEFAULT NULL,
  `searchable` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `inode_pid` (`inode_pid`,`inode_name`,`partition_id`),
  CONSTRAINT `FK_149_422` FOREIGN KEY (`inode_pid`,`inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster AUTO_INCREMENT=249 DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meta_tuple_to_file`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meta_tuple_to_file` (
  `tupleid` int(11) NOT NULL AUTO_INCREMENT,
  `inodeid` bigint(20) NOT NULL,
  `inode_pid` bigint(20) NOT NULL,
  `inode_name` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `partition_id` bigint(20) NOT NULL,
  PRIMARY KEY (`tupleid`),
  KEY `inode_pid` (`inode_pid`,`inode_name`,`partition_id`),
  CONSTRAINT `FK_149_402` FOREIGN KEY (`inode_pid`,`inode_name`,`partition_id`) REFERENCES `hops`.`hdfs_inodes` (`parent_id`,`name`,`partition_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `meta_log`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `meta_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meta_id` int(11) NOT NULL,
  `meta_field_id` int(11) NOT NULL,
  `meta_tuple_id` int(11) NOT NULL,
  `meta_op_type` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

ALTER TABLE `hopsworks`.`serving` DROP COLUMN `serving_tool`;
ALTER TABLE `hopsworks`.`serving` RENAME COLUMN `model_server` TO `serving_type`;
