DROP TABLE IF EXISTS `default_job_configuration`;

ALTER TABLE `hopsworks`.`validation_rule` DROP COLUMN `feature_type`;

DROP TABLE `hopsworks`.`cached_feature`;
