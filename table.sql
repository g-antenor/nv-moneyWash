CREATE TABLE IF NOT EXISTS `money_laundry_machines` (
  `id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `on_off` tinyint(1) NOT NULL DEFAULT 0,
  `wash_time` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;