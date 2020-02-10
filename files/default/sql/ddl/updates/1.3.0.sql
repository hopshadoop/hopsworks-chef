ALTER TABLE `hopsworks`.`hosts` ADD COLUMN `zfs_key` VARCHAR(255) COLLATE latin1_general_cs DEFAULT NULL;
ALTER TABLE `hopsworks`.`hosts` ADD COLUMN `zfs_key_rotated` VARCHAR(255) COLLATE latin1_general_cs DEFAULT NULL;
