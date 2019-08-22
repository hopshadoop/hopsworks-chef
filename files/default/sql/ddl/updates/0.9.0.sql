<<<<<<< HEAD
DROP TABLE IF EXISTS `rstudio_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rstudio_settings` (
  `project_id` int(11) NOT NULL,
  `team_member` varchar(150) COLLATE latin1_general_cs NOT NULL,
  `num_tf_gpus` int(11) DEFAULT '0',
  `appmaster_cores` int(11) DEFAULT '1',
  `appmaster_memory` int(11) DEFAULT '1024',
  `num_executors` int(11) DEFAULT '1',
  `num_executor_cores` int(11) DEFAULT '1',
  `executor_memory` int(11) DEFAULT '1024',
  `dynamic_initial_executors` int(11) DEFAULT '1',
  `dynamic_min_executors` int(11) DEFAULT '1',
  `dynamic_max_executors` int(11) DEFAULT '1',
  `secret` varchar(255) COLLATE latin1_general_cs NOT NULL,
  `log_level` varchar(32) COLLATE latin1_general_cs DEFAULT 'INFO',
  `mode` varchar(32) COLLATE latin1_general_cs NOT NULL,
  `umask` varchar(32) COLLATE latin1_general_cs DEFAULT '022',
  `advanced` tinyint(1) DEFAULT '0',
  `archives` varchar(1500) COLLATE latin1_general_cs DEFAULT '',
  `jars` varchar(1500) COLLATE latin1_general_cs DEFAULT '',
  `files` varchar(1500) COLLATE latin1_general_cs DEFAULT '',
  `py_files` varchar(1500) COLLATE latin1_general_cs DEFAULT '',
  `spark_params` varchar(6500) COLLATE latin1_general_cs DEFAULT '',
  `shutdown_level` int(11) NOT NULL DEFAULT '6',
  PRIMARY KEY (`project_id`,`team_member`),
  KEY `team_member` (`team_member`),
  KEY `secret_idx` (`secret`),
  CONSTRAINT `FK_262_309` FOREIGN KEY (`team_member`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `FK_284_308` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;
=======
ALTER TABLE jupyter_project ADD CONSTRAINT unique_hdfs_user UNIQUE (hdfs_user_id);

-- Find the name of the FK
SET @fk_name = (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = "hopsworks" AND TABLE_NAME = "jupyter_project" AND REFERENCED_TABLE_NAME="hdfs_users");
SET @s := concat('ALTER TABLE hopsworks.jupyter_project DROP FOREIGN KEY `', @fk_name, '`');
PREPARE stmt1 FROM @s;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;


ALTER TABLE jupyter_project ADD CONSTRAINT `fk_hdfs_user_id` FOREIGN KEY (`hdfs_user_id`) REFERENCES `hops`.`hdfs_users` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE jupyter_project DROP KEY `hdfs_user_idx`;
>>>>>>> 34b59323aae9b09878ddfb1784afa193e7f18053
