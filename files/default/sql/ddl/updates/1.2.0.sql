ALTER TABLE `hopsworks`.`feature_group` 
    ADD COLUMN `name` VARCHAR(255) AFTER `id`,
    ADD INDEX `name_key` (`name`);

-- Add all the names from on_demand feature groups
UPDATE `hopsworks`.`feature_group` `f` 
JOIN `hopsworks`.`on_demand_feature_group` `o` 
ON `f`.`on_demand_feature_group_id` = `o`.`id`
SET `f`.`name` = `o`.`name`;

ALTER TABLE `hopsworks`.`on_demand_feature_group` DROP COLUMN `name`;

UPDATE `hopsworks`.`feature_group` `f` 
JOIN `hopsworks`.`cached_feature_group` `c` 
JOIN `metastore`.`TBLS` `m`
ON `f`.`cached_feature_group_id` = `c`.`id` AND `c`.`offline_feature_group` = `m`.`TBL_ID`
SET `f`.`name` = REVERSE(SUBSTR(REVERSE(`m`.`TBL_NAME`), 1+LOCATE('_', REVERSE(`m`.`TBL_NAME`))));


ALTER TABLE `hopsworks`.`training_dataset` 
    ADD COLUMN `name` VARCHAR(255) AFTER `id`,
    ADD INDEX `name_key` (`name`);

UPDATE `hopsworks`.`training_dataset` `t`
JOIN `hopsworks`.`external_training_dataset` `e`
ON `t`.`external_training_dataset_id` = `e`.`id`
SET `t`.`name` = `e`.`name`;

ALTER TABLE `hopsworks`.`external_training_dataset` DROP COLUMN `name`;

UPDATE `hopsworks`.`training_dataset` `t`
JOIN `hopsworks`.`hopsfs_training_dataset` `h`
ON `t`.`hopsfs_training_dataset_id` = `h`.`id`
SET `t`.`name` = REVERSE(SUBSTR(REVERSE(`h`.`inode_name`), 1+LOCATE('_', REVERSE(`h`.`inode_name`))));
