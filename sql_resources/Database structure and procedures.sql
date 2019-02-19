CREATE DATABASE  IF NOT EXISTS `cryptocompare`;
USE `cryptocompare`;

--
-- Table structure for table `dim_coin`
--

DROP TABLE IF EXISTS `dim_coin`;
CREATE TABLE `dim_coin` (
  `id_dim_coin` int(10) unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `symbol` varchar(10) NOT NULL,
  `coin_name` varchar(100) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id_dim_coin`),
  UNIQUE KEY `id_dim_coin_UNIQUE` (`id_dim_coin`)
) ENGINE=InnoDB;

--
-- Table structure for table `dim_date`
--

DROP TABLE IF EXISTS `dim_date`;
CREATE TABLE `dim_date` (
  `id_dim_date` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `date` date DEFAULT NULL,
  `year_month_day` varchar(20) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `month` int(11) DEFAULT NULL,
  `day` int(11) DEFAULT NULL,
  `year_and_month` varchar(20) DEFAULT NULL,
  `year_month_name` varchar(20) DEFAULT NULL,
  `year_month_nick` varchar(20) DEFAULT NULL,
  `month_name` varchar(20) DEFAULT NULL,
  `month_nick` varchar(3) DEFAULT NULL,
  `day_of_week` int(11) DEFAULT NULL,
  `day_of_week_name` varchar(20) DEFAULT NULL,
  `day_of_year` int(11) DEFAULT NULL,
  `bimester` int(11) DEFAULT NULL,
  `trimester` int(11) DEFAULT NULL,
  `semester` int(11) DEFAULT NULL,
  `week_of_month` int(11) DEFAULT NULL,
  `week_of_year` int(11) DEFAULT NULL,
  `year_bimester` char(7) DEFAULT NULL,
  `year_trimester` char(7) DEFAULT NULL,
  `year_semester` char(7) DEFAULT NULL,
  `working_day` int(11) DEFAULT NULL,
  `weekend` int(11) DEFAULT NULL,
  `data_por_extenso` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id_dim_date`),
  UNIQUE KEY `id_dim_date_UNIQUE` (`id_dim_date`)
) ENGINE=InnoDB AUTO_INCREMENT=1462;

--
-- Table structure for table `dim_exchange`
--

DROP TABLE IF EXISTS `dim_exchange`;
CREATE TABLE `dim_exchange` (
  `id_dim_exchange` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `country` varchar(100) NOT NULL,
  `centralization_type` varchar(50) NOT NULL,
  `internal_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id_dim_exchange`),
  UNIQUE KEY `id_dim_exchanges_UNIQUE` (`id_dim_exchange`)
) ENGINE=InnoDB;

--
-- Table structure for table `dim_time`
--

DROP TABLE IF EXISTS `dim_time`;
CREATE TABLE `dim_time` (
  `id_dim_time` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `time` time NOT NULL,
  `hour` int(11) NOT NULL,
  `minute` int(11) NOT NULL,
  `second` int(11) NOT NULL,
  `hour_minute` varchar(5) CHARACTER SET utf8 NOT NULL,
  `minute_second` varchar(5) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  PRIMARY KEY (`id_dim_time`),
  UNIQUE KEY `id_dim_time_UNIQUE` (`id_dim_time`)
) ENGINE=InnoDB AUTO_INCREMENT=25;

--
-- Table structure for table `fact_coin`
--

DROP TABLE IF EXISTS `fact_coin`;
CREATE TABLE `fact_coin` (
  `id_dim_coin` int(10) unsigned NOT NULL,
  `id_dim_time` int(10) unsigned NOT NULL,
  `id_dim_date` int(11) unsigned NOT NULL,
  `volume_from_usd` decimal(65,2) DEFAULT NULL,
  `volume_to_usd` decimal(65,2) DEFAULT NULL,
  `close` decimal(65,2) DEFAULT NULL,
  `open` decimal(65,2) DEFAULT NULL,
  `high` decimal(65,2) DEFAULT NULL,
  `low` decimal(65,2) DEFAULT NULL,
  `revenue` decimal(65,2) DEFAULT NULL,
  `is_positive` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id_dim_coin`,`id_dim_time`,`id_dim_date`),
  KEY `fk_fact_coin_dim_coin1_idx` (`id_dim_coin`),
  KEY `fk_fact_coin_dim_time1_idx` (`id_dim_time`),
  KEY `fk_fact_coin_dim_date1_idx` (`id_dim_date`),
  CONSTRAINT `fk_fact_coin_dim_coin1` FOREIGN KEY (`id_dim_coin`) REFERENCES `dim_coin` (`id_dim_coin`),
  CONSTRAINT `fk_fact_coin_dim_date1` FOREIGN KEY (`id_dim_date`) REFERENCES `dim_date` (`id_dim_date`),
  CONSTRAINT `fk_fact_coin_dim_time1` FOREIGN KEY (`id_dim_time`) REFERENCES `dim_time` (`id_dim_time`)
) ENGINE=InnoDB;

--
-- Table structure for table `fact_exchange`
--

DROP TABLE IF EXISTS `fact_exchange`;
CREATE TABLE `fact_exchange` (
  `id_fact_transactions` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_dim_date` int(11) unsigned NOT NULL,
  `id_dim_exchange` int(10) unsigned NOT NULL,
  `volume` decimal(65,2) DEFAULT NULL,
  `symbol` varchar(45) NOT NULL,
  PRIMARY KEY (`id_fact_transactions`,`id_dim_date`,`id_dim_exchange`),
  UNIQUE KEY `id_fact_transactions_UNIQUE` (`id_fact_transactions`),
  KEY `fk_fact_transactions_dim_exchange1_idx` (`id_dim_exchange`),
  KEY `fk_fact_transactions_dim_date1_idx` (`id_dim_date`),
  CONSTRAINT `fk_fact_transactions_dim_date1` FOREIGN KEY (`id_dim_date`) REFERENCES `dim_date` (`id_dim_date`),
  CONSTRAINT `fk_fact_transactions_dim_exchange1` FOREIGN KEY (`id_dim_exchange`) REFERENCES `dim_exchange` (`id_dim_exchange`)
) ENGINE=InnoDB AUTO_INCREMENT=146098;

--
-- Dumping routines for database 'cryptocompare'
--
/*!50003 DROP PROCEDURE IF EXISTS `populateDimDates` */;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateDimDates`(
    IN _start_date DATE,
    IN _end_date   DATE 
)
BEGIN
    
    DECLARE _id_dim_date        INT;
    DECLARE _day                INT;
    DECLARE _day_of_week        INT;
    DECLARE _day_of_week_name   VARCHAR(15);
    DECLARE _year               INT;
    DECLARE _month              INT;
    DECLARE _month_name         VARCHAR(255);
    DECLARE _month_nickname     VARCHAR(3);
    DECLARE _bimester           INT;
    DECLARE _trimester          INT;
    DECLARE _semester           INT;
    DECLARE _working_day        INT;
    DECLARE _weekend            INT;
    DECLARE _week_of_month      INT;
    DECLARE _week_of_year       INT;

    SET _id_dim_date = 0;
    
    WHILE _start_date <= _end_date
    DO
        SET _id_dim_date  = _id_dim_date + 1;
        SET _day          = DAY(_start_date);
        SET _day_of_week  = dayofweek(_start_date);
        SET _year         = YEAR(_start_date) ;
        SET _month        = MONTH(_start_date);
        SET _week_of_year = week(_start_date) ;
        
        SET _day_of_week_name = CASE _day_of_week
                                    WHEN 1 THEN 'sunday'
                                    WHEN 2 THEN 'monday'
                                    WHEN 3 THEN 'tuesday'
                                    WHEN 4 THEN 'wednesday'
                                    WHEN 5 THEN 'thursday'
                                    WHEN 6 THEN 'friday'
                                    WHEN 7 THEN 'saturday' 
                                END;
        SET _month_name = CASE _month
                            WHEN 1  THEN 'january'
                            WHEN 2  THEN 'february'
                            WHEN 3  THEN 'march'
                            WHEN 4  THEN 'april'
                            WHEN 5  THEN 'may'
                            WHEN 6  THEN 'june'
                            WHEN 7  THEN 'july'
                            WHEN 8  THEN 'august'
                            WHEN 9  THEN 'september'
                            WHEN 10 THEN 'october'
                            WHEN 11 THEN 'november'
                            WHEN 12 THEN 'december' 
                        END;
        
        SET _month_nickname = CASE _month
                                WHEN 1  THEN 'jan'
                                WHEN 2  THEN 'feb'
                                WHEN 3  THEN 'mar'
                                WHEN 4  THEN 'apr'
                                WHEN 5  THEN 'may'
                                WHEN 6  THEN 'jun'
                                WHEN 7  THEN 'jul'
                                WHEN 8  THEN 'aug'
                                WHEN 9  THEN 'sep'
                                WHEN 10 THEN 'oct'
                                WHEN 11 THEN 'nov'
                                WHEN 12 THEN 'dec' 
                            END;
        
        SET _bimester = CASE 
                            WHEN _month <= 2  THEN 1
                            WHEN _month <= 4  THEN 2
                            WHEN _month <= 6  THEN 3
                            WHEN _month <= 8  THEN 4
                            WHEN _month <= 10 THEN 5
                            WHEN _month <= 12 THEN 6 
                        END;

        SET _trimester = CASE 
                            WHEN _month <= 3  THEN 1
                            WHEN _month <= 6  THEN 2
                            WHEN _month <= 9  THEN 3
                            WHEN _month <= 12 THEN 4 
                        END;

        SET _semester = CASE 
                            WHEN _month <= 6  THEN 1
                            WHEN _month <= 12 THEN 2 
                        END;
    
        SET _week_of_month = CASE
                                WHEN _day < 8  THEN 1
                                WHEN _day < 15 THEN 2
                                WHEN _day < 22 THEN 3
                                WHEN _day < 29 THEN 4
                                WHEN _day < 32 THEN 5 
                            END;

		SET _working_day = CASE 
            WHEN _month = 1  AND _day = 1  THEN 0 -- New Year's Day
            WHEN _month = 12 AND _day = 25 THEN 0 -- Christmas
            ELSE 1
        END;
        
       -- SET weekend 
        IF (_day_of_week = 1 OR _day_of_week = 7) THEN
            SET _weekend = 1;
            
            IF (_working_day = 1) THEN
				SET _working_day = 0;
            END IF;
            
        ELSE
        
			SET _weekend = 0;
        
			IF (_working_day = 1) THEN
				SET _working_day = 1;
            END IF;
        END IF;


        INSERT INTO dim_date (    
            id_dim_date     ,
            date            ,
            year            ,
            month           ,
            day             ,
            year_month_name ,
            year_and_month  ,
            year_month_day  ,
            year_month_nick ,
            month_name      ,
            month_nick      ,
            day_of_week     ,
            day_of_week_name,
            bimester        ,
            trimester       ,
            semester        ,
            week_of_month   ,
            week_of_year    ,
            working_day     ,
            weekend
        )
        SELECT 
            _id_dim_date AS id_dim_date,
            _start_date  AS date       ,
            _year        AS year       ,
            _month       AS month      ,
            _day         AS day        ,
            CONCAT(CAST(_year AS CHAR(4)) , '-' , _month_name)            AS year_month_name,
            CONCAT(CAST(_year AS CHAR(4)) , '-' , _month)                 AS year_and_month ,
            CONCAT(CAST(_year AS CHAR(4)) , '-' , _month_name, '-', _day) AS year_month_day ,
            CONCAT(CAST(_year AS CHAR(4)) , '-' , _month_nickname)        AS year_month_nick,
            _month_name AS month_name        ,
            _month_nickname   AS month_nick  ,
            _day_of_week      AS day_of_week ,
            _day_of_week_name AS day_of_week_name,
            _bimester         AS bimester    ,
            _trimester        AS trimester   ,
            _semester         AS semester    ,
            _week_of_month    AS week_of_month,
            _week_of_year     AS week_of_year,
            _working_day      AS working_day ,
            _weekend          AS weekend;
          
            SET _start_date = DATE_ADD(_start_date, INTERVAL 1 DAY);
        
    END WHILE;

END ;;
DELIMITER ;


/*!50003 DROP PROCEDURE IF EXISTS `populateDimTime` */;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `populateDimTime`()
BEGIN
    
    DECLARE _hour, _minute, _second      INT;
	DECLARE _hour_minute, _minute_second VARCHAR(5);
    DECLARE _time TIME;
    
    SET _hour   = 0;
    SET _minute = 0;
    SET _second = 0;
    
    WHILE _hour <= 23
    DO
    
        SET _time          = CONCAT(_hour, ':', _minute, ':', _second);
        SET _hour_minute   = CONCAT(_hour, ':', _minute);
        SET _minute_second = CONCAT(_minute, ':', _second);
        
        INSERT INTO dim_time (
            `time`,
            `hour`,
            `minute`,
            `second`,
            `hour_minute`,
            `minute_second`
        )
        VALUES (
            _time,
            _hour,
            _minute,
            _second,
            _hour_minute,
            _minute_second
        );
        
		SET _hour = _hour + 1;
    END WHILE;
END ;;
DELIMITER ;

-- Dump completed
