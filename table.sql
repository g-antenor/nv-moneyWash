CREATE TABLE IF NOT EXISTS `money_laundry_machines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`coords`)),
  `heading` float NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `on_off` tinyint(1) NOT NULL DEFAULT 0,
  `wash_time` int(11) NOT NULL DEFAULT 0,
  `cooldown` int(11) DEFAULT NULL,
  `rounds` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
