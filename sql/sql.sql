CREATE TABLE IF NOT EXISTS `ethicalpixel_admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` varchar(50) DEFAULT NULL,
  `favorite` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`favorite`)),
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

INSERT INTO `ethicalpixel_admin` (`id`, `cid`, `favorite`) VALUES
	(4, 'WAC28700', '[{"name":"changemodel"},{"name":"ban"},{"name":"bring"},{"name":"csay"},{"name":"fixvehicle"},{"name":"givecash"},{"name":"godmode"},{"name":"noclip"},{"name":"clothes"}]');

CREATE TABLE IF NOT EXISTS `ethicalpixel_admin_banned` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `steam` varchar(50) DEFAULT NULL,
  `reason` varchar(50) DEFAULT NULL,
  `length` varchar(50) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `discord` varchar(50) DEFAULT NULL,
  `license` varchar(50) DEFAULT NULL,
  `DisplayName` varchar(50) DEFAULT NULL,
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `ethicalpixel_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Identifier` varchar(50) DEFAULT NULL,
  `log` longtext DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=latin1;
