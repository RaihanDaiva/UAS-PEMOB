-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.30 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for camping_booking_db
CREATE DATABASE IF NOT EXISTS `camping_booking_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `camping_booking_db`;

-- Dumping structure for table camping_booking_db.admin_logs
CREATE TABLE IF NOT EXISTS `admin_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_id` int NOT NULL,
  `action_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `target_table` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `target_id` int DEFAULT NULL,
  `old_value` json DEFAULT NULL,
  `new_value` json DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_admin` (`admin_id`),
  KEY `idx_action` (`action_type`),
  KEY `idx_created` (`created_at`),
  CONSTRAINT `admin_logs_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table camping_booking_db.admin_logs: ~0 rows (approximately)

-- Dumping structure for table camping_booking_db.bookings
CREATE TABLE IF NOT EXISTS `bookings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int NOT NULL,
  `campsite_id` int NOT NULL,
  `check_in_date` date NOT NULL,
  `check_out_date` date NOT NULL,
  `num_people` int NOT NULL,
  `num_tents` int DEFAULT '1',
  `total_nights` int NOT NULL,
  `price_per_night` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `tax_amount` decimal(10,2) DEFAULT '0.00',
  `total_price` decimal(10,2) NOT NULL,
  `booking_status` enum('pending','confirmed','cancelled','completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `special_requests` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_code` (`booking_code`),
  KEY `idx_user` (`user_id`),
  KEY `idx_campsite` (`campsite_id`),
  KEY `idx_dates` (`check_in_date`,`check_out_date`),
  KEY `idx_status` (`booking_status`),
  KEY `idx_booking_code` (`booking_code`),
  KEY `idx_bookings_dates_status` (`check_in_date`,`check_out_date`,`booking_status`),
  CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`campsite_id`) REFERENCES `campsites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table camping_booking_db.bookings: ~1 rows (approximately)
INSERT IGNORE INTO `bookings` (`id`, `booking_code`, `user_id`, `campsite_id`, `check_in_date`, `check_out_date`, `num_people`, `num_tents`, `total_nights`, `price_per_night`, `subtotal`, `tax_amount`, `total_price`, `booking_status`, `special_requests`, `created_at`, `updated_at`) VALUES
	(2, 'BKG20260118480392', 10, 1, '2026-01-20', '2026-01-21', 4, 1, 1, 150000.00, 150000.00, 15000.00, 165000.00, 'completed', '', '2026-01-18 09:10:56', '2026-01-18 11:43:44');

-- Dumping structure for procedure camping_booking_db.calculate_booking_total
DELIMITER //
CREATE PROCEDURE `calculate_booking_total`(
    IN p_check_in DATE,
    IN p_check_out DATE,
    IN p_price_per_night DECIMAL(10,2),
    IN p_num_people INT,
    OUT p_total_nights INT,
    OUT p_subtotal DECIMAL(10,2),
    OUT p_tax_amount DECIMAL(10,2),
    OUT p_total_price DECIMAL(10,2)
)
BEGIN
    SET p_total_nights = DATEDIFF(p_check_out, p_check_in);
    SET p_subtotal = p_price_per_night * p_total_nights;
    SET p_tax_amount = p_subtotal * 0.10; 
    SET p_total_price = p_subtotal + p_tax_amount;
END//
DELIMITER ;

-- Dumping structure for table camping_booking_db.campsites
CREATE TABLE IF NOT EXISTS `campsites` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `location_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `capacity` int NOT NULL DEFAULT '50',
  `price_per_night` decimal(10,2) NOT NULL,
  `facilities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_location` (`latitude`,`longitude`),
  KEY `idx_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table camping_booking_db.campsites: ~3 rows (approximately)
INSERT IGNORE INTO `campsites` (`id`, `name`, `description`, `location_name`, `latitude`, `longitude`, `capacity`, `price_per_night`, `facilities`, `image_url`, `is_active`, `created_at`, `updated_at`) VALUES
	(1, 'Mountain View Camp', 'Beautiful camping site with mountain views and cool weather. Perfect for family camping.', 'Bandung, West Java', -6.91750000, 107.61910000, 50, 150000.00, 'Parking area, Restrooms, Shower facilities, BBQ area, Camping equipment rental', NULL, 1, '2025-12-18 12:28:02', '2025-12-18 12:28:02'),
	(2, 'Beach Paradise Camp', 'Coastal camping experience with stunning beach views and water activities.', 'Pangandaran, West Java', -7.68450000, 108.65010000, 40, 200000.00, 'Beach access, Water sports, Restaurant, Security 24/7, Wifi', NULL, 1, '2025-12-18 12:28:02', '2026-01-18 05:09:36'),
	(3, 'Forest Adventure Camp', 'Experience nature in the heart of the forest with hiking trails and wildlife.', 'Sukabumi, West Java', -6.93060000, 106.92670000, 30, 175000.00, 'Hiking trails, Bonfire area, Nature guide, First aid station, Clean water source', NULL, 1, '2025-12-18 12:28:02', '2026-01-18 05:14:59');

-- Dumping structure for procedure camping_booking_db.check_campsite_availability
DELIMITER //
CREATE PROCEDURE `check_campsite_availability`(
    IN p_campsite_id INT,
    IN p_check_in DATE,
    IN p_check_out DATE,
    IN p_num_people INT,
    OUT p_is_available BOOLEAN
)
BEGIN
    DECLARE v_capacity INT;
    DECLARE v_booked_people INT;
    
    SELECT capacity INTO v_capacity
    FROM campsites
    WHERE id = p_campsite_id;
    
    SELECT COALESCE(SUM(num_people), 0) INTO v_booked_people
    FROM bookings
    WHERE campsite_id = p_campsite_id
        AND booking_status IN ('pending', 'confirmed')
        AND (
            (check_in_date <= p_check_in AND check_out_date > p_check_in)
            OR (check_in_date < p_check_out AND check_out_date >= p_check_out)
            OR (check_in_date >= p_check_in AND check_out_date <= p_check_out)
        );
    
    SET p_is_available = (v_booked_people + p_num_people <= v_capacity);
END//
DELIMITER ;

-- Dumping structure for procedure camping_booking_db.generate_booking_code
DELIMITER //
CREATE PROCEDURE `generate_booking_code`(
    OUT p_booking_code VARCHAR(20)
)
BEGIN
    DECLARE v_date VARCHAR(8);
    DECLARE v_random VARCHAR(6);
    DECLARE v_count INT;
    
    SET v_date = DATE_FORMAT(NOW(), '%Y%m%d');
    
    REPEAT
        SET v_random = LPAD(FLOOR(RAND() * 1000000), 6, '0');
        SET p_booking_code = CONCAT('BKG', v_date, v_random);
        
        SELECT COUNT(*) INTO v_count 
        FROM bookings 
        WHERE booking_code = p_booking_code;
    UNTIL v_count = 0 END REPEAT;
END//
DELIMITER ;

-- Dumping structure for table camping_booking_db.notifications
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notification_type` enum('booking','payment','approval','weather_alert','system') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `related_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_read` (`is_read`),
  KEY `idx_type` (`notification_type`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table camping_booking_db.notifications: ~0 rows (approximately)
INSERT IGNORE INTO `notifications` (`id`, `user_id`, `title`, `message`, `notification_type`, `is_read`, `related_id`, `created_at`) VALUES
	(5, 6, 'Account Approved', 'Congratulations! Your account has been approved. You can now start booking camping sites.', 'approval', 0, NULL, '2026-01-18 07:49:16'),
	(6, 7, 'Account Approved', 'Congratulations! Your account has been approved. You can now start booking camping sites.', 'approval', 0, NULL, '2026-01-18 08:27:33'),
	(7, 8, 'Account Approved', 'Congratulations! Your account has been approved. You can now start booking camping sites.', 'approval', 0, NULL, '2026-01-18 08:32:23'),
	(8, 9, 'Account Approved', 'Congratulations! Your account has been approved. You can now start booking camping sites.', 'approval', 0, NULL, '2026-01-18 09:08:59'),
	(9, 10, 'Account Approved', 'Congratulations! Your account has been approved. You can now start booking camping sites.', 'approval', 0, NULL, '2026-01-18 09:09:46'),
	(10, 10, 'Booking Created Successfully', 'Your booking (BKG20260118480392) has been created. Please complete the payment.', 'booking', 0, 2, '2026-01-18 09:10:56');

-- Dumping structure for table camping_booking_db.payments
CREATE TABLE IF NOT EXISTS `payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `payment_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `booking_id` int NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` enum('cash','bank_transfer','e-wallet','credit_card') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payment_status` enum('pending','completed','failed','refunded') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `payment_date` timestamp NULL DEFAULT NULL,
  `payment_proof_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_code` (`payment_code`),
  KEY `idx_booking` (`booking_id`),
  KEY `idx_status` (`payment_status`),
  KEY `idx_payment_code` (`payment_code`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table camping_booking_db.payments: ~0 rows (approximately)

-- Dumping structure for table camping_booking_db.reviews
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `user_id` int NOT NULL,
  `campsite_id` int NOT NULL,
  `rating` int NOT NULL,
  `review_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `booking_id` (`booking_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_campsite` (`campsite_id`),
  KEY `idx_rating` (`rating`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_ibfk_3` FOREIGN KEY (`campsite_id`) REFERENCES `campsites` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_chk_1` CHECK (((`rating` >= 1) and (`rating` <= 5)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table camping_booking_db.reviews: ~0 rows (approximately)

-- Dumping structure for table camping_booking_db.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('admin','client') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'client',
  `registration_status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `profile_image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`registration_status`),
  KEY `idx_users_role_status` (`role`,`registration_status`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table camping_booking_db.users: ~6 rows (approximately)
INSERT IGNORE INTO `users` (`id`, `email`, `password_hash`, `full_name`, `phone_number`, `role`, `registration_status`, `profile_image_url`, `address`, `created_at`, `updated_at`, `last_login`, `is_active`) VALUES
	(5, 'admin@gmail.com', '$2b$12$fw.40d14b1zMikKUaQXqd.U8DVYkregdzACM47TxemTxiUosolVkK', 'admin', '08123456789', 'admin', 'approved', NULL, '', '2025-12-19 03:19:15', '2026-01-15 09:56:11', NULL, 1),
	(6, 'client@gmail.com', '$2b$12$zn9JfJ103.mjTuM5McbG.OLjfoYykfJ33n2eM1nEumH4hyulxI6z6', 'client', '08123456789', 'client', 'approved', NULL, '', '2026-01-18 07:48:45', '2026-01-18 07:49:16', NULL, 1),
	(7, 'raihan@gmail.com', '$2b$12$ENilNgr2ia2saxp8MTndKul3MSYhXjLkll2sU/Eu24AQPDINWxMPm', 'raihan', '085320633115', 'client', 'approved', NULL, '', '2026-01-18 08:27:00', '2026-01-18 08:27:33', NULL, 1),
	(8, 'naufal@gmail.com', '$2b$12$VKFYC6sCvlTp95SY6.rD6.kzWaKs5vYmb11THhWd7iIMx.ETb2boC', 'naufal', '085721621472', 'client', 'approved', NULL, '', '2026-01-18 08:32:01', '2026-01-18 08:32:23', NULL, 1),
	(9, 'firman@gmail.com', '$2b$12$6mE3cF44EQll7G2wtK5HJuzHrez4t0fENK6ChmbDK0C5Ymxxd4EH6', 'firman', '087729286244', 'client', 'approved', NULL, '', '2026-01-18 08:46:14', '2026-01-18 09:08:59', NULL, 1),
	(10, 'hasby@gmail.com', '$2b$12$l4Q6ljNOcf0D6KXHBpY9n.H9diF5JQYqI8MenV9IXkR1mE4xUnuJ6', 'hasby', '085174370106', 'client', 'approved', NULL, '', '2026-01-18 09:09:35', '2026-01-18 09:09:46', NULL, 1);

-- Dumping structure for view camping_booking_db.view_booking_summary
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `view_booking_summary` (
	`id` INT(10) NOT NULL,
	`booking_code` VARCHAR(20) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`check_in_date` DATE NOT NULL,
	`check_out_date` DATE NOT NULL,
	`total_nights` INT(10) NOT NULL,
	`num_people` INT(10) NOT NULL,
	`total_price` DECIMAL(10,2) NOT NULL,
	`booking_status` ENUM('pending','confirmed','cancelled','completed') NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`customer_name` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`customer_email` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`customer_phone` VARCHAR(20) NULL COLLATE 'utf8mb4_unicode_ci',
	`campsite_name` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`campsite_location` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`payment_status` ENUM('pending','completed','failed','refunded') NULL COLLATE 'utf8mb4_unicode_ci',
	`payment_method` ENUM('cash','bank_transfer','e-wallet','credit_card') NULL COLLATE 'utf8mb4_unicode_ci',
	`booking_date` TIMESTAMP NULL
) ENGINE=MyISAM;

-- Dumping structure for view camping_booking_db.view_monthly_revenue
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `view_monthly_revenue` (
	`month` VARCHAR(7) NULL COLLATE 'utf8mb4_0900_ai_ci',
	`campsite_name` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`total_bookings` BIGINT(19) NOT NULL,
	`total_revenue` DECIMAL(32,2) NULL,
	`avg_booking_value` DECIMAL(14,6) NULL
) ENGINE=MyISAM;

-- Dumping structure for view camping_booking_db.view_pending_approvals
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `view_pending_approvals` (
	`id` INT(10) NOT NULL,
	`email` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`full_name` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`phone_number` VARCHAR(20) NULL COLLATE 'utf8mb4_unicode_ci',
	`address` TEXT NULL COLLATE 'utf8mb4_unicode_ci',
	`created_at` TIMESTAMP NULL,
	`days_pending` BIGINT(19) NULL
) ENGINE=MyISAM;

-- Dumping structure for table camping_booking_db.weather_cache
CREATE TABLE IF NOT EXISTS `weather_cache` (
  `id` int NOT NULL AUTO_INCREMENT,
  `campsite_id` int NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `forecast_date` date NOT NULL,
  `temperature_min` decimal(5,2) DEFAULT NULL,
  `temperature_max` decimal(5,2) DEFAULT NULL,
  `temperature_avg` decimal(5,2) DEFAULT NULL,
  `weather_code` int DEFAULT NULL,
  `weather_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `precipitation_probability` decimal(5,2) DEFAULT NULL,
  `wind_speed` decimal(5,2) DEFAULT NULL,
  `humidity` int DEFAULT NULL,
  `api_response` json DEFAULT NULL,
  `cached_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_campsite_date` (`campsite_id`,`forecast_date`),
  KEY `idx_expires` (`expires_at`),
  KEY `idx_weather_lookup` (`campsite_id`,`forecast_date`,`expires_at`),
  CONSTRAINT `weather_cache_ibfk_1` FOREIGN KEY (`campsite_id`) REFERENCES `campsites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table camping_booking_db.weather_cache: ~0 rows (approximately)

-- Dumping structure for trigger camping_booking_db.after_booking_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `after_booking_insert` AFTER INSERT ON `bookings` FOR EACH ROW BEGIN
    INSERT INTO notifications (user_id, title, message, notification_type, related_id)
    VALUES (
        NEW.user_id,
        'Booking Created Successfully',
        CONCAT('Your booking (', NEW.booking_code, ') has been created. Please complete the payment.'),
        'booking',
        NEW.id
    );
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger camping_booking_db.after_user_approval
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `after_user_approval` AFTER UPDATE ON `users` FOR EACH ROW BEGIN
    IF OLD.registration_status = 'pending' AND NEW.registration_status = 'approved' THEN
        INSERT INTO notifications (user_id, title, message, notification_type)
        VALUES (
            NEW.id,
            'Account Approved',
            'Congratulations! Your account has been approved. You can now start booking camping sites.',
            'approval'
        );
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for view camping_booking_db.view_booking_summary
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `view_booking_summary`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view_booking_summary` AS select `b`.`id` AS `id`,`b`.`booking_code` AS `booking_code`,`b`.`check_in_date` AS `check_in_date`,`b`.`check_out_date` AS `check_out_date`,`b`.`total_nights` AS `total_nights`,`b`.`num_people` AS `num_people`,`b`.`total_price` AS `total_price`,`b`.`booking_status` AS `booking_status`,`u`.`full_name` AS `customer_name`,`u`.`email` AS `customer_email`,`u`.`phone_number` AS `customer_phone`,`c`.`name` AS `campsite_name`,`c`.`location_name` AS `campsite_location`,`p`.`payment_status` AS `payment_status`,`p`.`payment_method` AS `payment_method`,`b`.`created_at` AS `booking_date` from (((`bookings` `b` join `users` `u` on((`b`.`user_id` = `u`.`id`))) join `campsites` `c` on((`b`.`campsite_id` = `c`.`id`))) left join `payments` `p` on((`b`.`id` = `p`.`booking_id`)));

-- Dumping structure for view camping_booking_db.view_monthly_revenue
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `view_monthly_revenue`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view_monthly_revenue` AS select date_format(`b`.`created_at`,'%Y-%m') AS `month`,`c`.`name` AS `campsite_name`,count(`b`.`id`) AS `total_bookings`,sum(`b`.`total_price`) AS `total_revenue`,avg(`b`.`total_price`) AS `avg_booking_value` from (`bookings` `b` join `campsites` `c` on((`b`.`campsite_id` = `c`.`id`))) where (`b`.`booking_status` = 'confirmed') group by date_format(`b`.`created_at`,'%Y-%m'),`c`.`id`;

-- Dumping structure for view camping_booking_db.view_pending_approvals
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `view_pending_approvals`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `view_pending_approvals` AS select `users`.`id` AS `id`,`users`.`email` AS `email`,`users`.`full_name` AS `full_name`,`users`.`phone_number` AS `phone_number`,`users`.`address` AS `address`,`users`.`created_at` AS `created_at`,timestampdiff(DAY,`users`.`created_at`,now()) AS `days_pending` from `users` where (`users`.`registration_status` = 'pending') order by `users`.`created_at`;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
