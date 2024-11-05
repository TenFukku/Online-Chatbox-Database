CREATE DATABASE  IF NOT EXISTS `doanck` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `doanck`;
-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: doanck
-- ------------------------------------------------------
-- Server version	8.3.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Temporary view structure for view `in_slnd`
--

DROP TABLE IF EXISTS `in_slnd`;
/*!50001 DROP VIEW IF EXISTS `in_slnd`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `in_slnd` AS SELECT 
 1 AS `SOLUONG`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `in_tb`
--

DROP TABLE IF EXISTS `in_tb`;
/*!50001 DROP VIEW IF EXISTS `in_tb`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `in_tb` AS SELECT 
 1 AS `MATB`,
 1 AS `MAND`,
 1 AS `NOIDUNG`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `in_tn`
--

DROP TABLE IF EXISTS `in_tn`;
/*!50001 DROP VIEW IF EXISTS `in_tn`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `in_tn` AS SELECT 
 1 AS `MATN`,
 1 AS `MAPC`,
 1 AS `NOIDUNG`,
 1 AS `TINHTRANG`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `in_ttnd`
--

DROP TABLE IF EXISTS `in_ttnd`;
/*!50001 DROP VIEW IF EXISTS `in_ttnd`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `in_ttnd` AS SELECT 
 1 AS `MAND`,
 1 AS `TENND`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `nd_pc`
--

DROP TABLE IF EXISTS `nd_pc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nd_pc` (
  `MAND` varchar(10) NOT NULL,
  `MAPC` varchar(10) NOT NULL,
  `QUYEN` tinyint(1) NOT NULL,
  `NGAYTG` datetime NOT NULL,
  PRIMARY KEY (`MAND`,`MAPC`),
  KEY `MAPC` (`MAPC`),
  CONSTRAINT `nd_pc_ibfk_1` FOREIGN KEY (`MAND`) REFERENCES `nguoidung` (`MAND`),
  CONSTRAINT `nd_pc_ibfk_2` FOREIGN KEY (`MAPC`) REFERENCES `phongchat` (`MAPC`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nd_pc`
--

LOCK TABLES `nd_pc` WRITE;
/*!40000 ALTER TABLE `nd_pc` DISABLE KEYS */;
/*!40000 ALTER TABLE `nd_pc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nguoidung`
--

DROP TABLE IF EXISTS `nguoidung`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nguoidung` (
  `MAND` varchar(10) NOT NULL,
  `TENND` varchar(50) NOT NULL,
  `EMAIL` varchar(20) DEFAULT NULL,
  `SDT` varchar(20) DEFAULT NULL,
  `TAIKHOAN` varchar(20) NOT NULL,
  `MATKHAU` varchar(50) NOT NULL,
  `TTTRUCTUYEN` tinyint(1) NOT NULL,
  `salt` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`MAND`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nguoidung`
--

LOCK TABLES `nguoidung` WRITE;
/*!40000 ALTER TABLE `nguoidung` DISABLE KEYS */;
/*!40000 ALTER TABLE `nguoidung` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phongchat`
--

DROP TABLE IF EXISTS `phongchat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `phongchat` (
  `MAPC` varchar(10) NOT NULL,
  `TENPC` varchar(50) NOT NULL,
  `NGAYTAO` datetime NOT NULL,
  PRIMARY KEY (`MAPC`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phongchat`
--

LOCK TABLES `phongchat` WRITE;
/*!40000 ALTER TABLE `phongchat` DISABLE KEYS */;
/*!40000 ALTER TABLE `phongchat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `thongbao`
--

DROP TABLE IF EXISTS `thongbao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thongbao` (
  `MATB` varchar(10) NOT NULL,
  `MAND` varchar(10) NOT NULL,
  `NOIDUNG` text NOT NULL,
  `NGAYNHAN` datetime NOT NULL,
  PRIMARY KEY (`MATB`),
  KEY `MAND` (`MAND`),
  CONSTRAINT `thongbao_ibfk_1` FOREIGN KEY (`MAND`) REFERENCES `nguoidung` (`MAND`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thongbao`
--

LOCK TABLES `thongbao` WRITE;
/*!40000 ALTER TABLE `thongbao` DISABLE KEYS */;
/*!40000 ALTER TABLE `thongbao` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tinnhan`
--

DROP TABLE IF EXISTS `tinnhan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tinnhan` (
  `MATN` varchar(10) NOT NULL,
  `MAND` varchar(10) NOT NULL,
  `MAPC` varchar(10) NOT NULL,
  `NOIDUNG` text NOT NULL,
  `NGAYGUI` datetime NOT NULL,
  `TINHTRANG` varchar(10) NOT NULL,
  PRIMARY KEY (`MATN`),
  KEY `MAND` (`MAND`),
  KEY `MAPC` (`MAPC`),
  CONSTRAINT `tinnhan_ibfk_1` FOREIGN KEY (`MAND`) REFERENCES `nguoidung` (`MAND`),
  CONSTRAINT `tinnhan_ibfk_2` FOREIGN KEY (`MAPC`) REFERENCES `phongchat` (`MAPC`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tinnhan`
--

LOCK TABLES `tinnhan` WRITE;
/*!40000 ALTER TABLE `tinnhan` DISABLE KEYS */;
/*!40000 ALTER TABLE `tinnhan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `in_slnd`
--

/*!50001 DROP VIEW IF EXISTS `in_slnd`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `in_slnd` AS select count(`nd_pc`.`MAND`) AS `SOLUONG` from `nd_pc` group by `nd_pc`.`MAPC` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `in_tb`
--

/*!50001 DROP VIEW IF EXISTS `in_tb`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `in_tb` AS select `thongbao`.`MATB` AS `MATB`,`thongbao`.`MAND` AS `MAND`,`thongbao`.`NOIDUNG` AS `NOIDUNG` from `thongbao` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `in_tn`
--

/*!50001 DROP VIEW IF EXISTS `in_tn`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `in_tn` AS select `tinnhan`.`MATN` AS `MATN`,`tinnhan`.`MAPC` AS `MAPC`,`tinnhan`.`NOIDUNG` AS `NOIDUNG`,`tinnhan`.`TINHTRANG` AS `TINHTRANG` from `tinnhan` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `in_ttnd`
--

/*!50001 DROP VIEW IF EXISTS `in_ttnd`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `in_ttnd` AS select `nguoidung`.`MAND` AS `MAND`,`nguoidung`.`TENND` AS `TENND` from `nguoidung` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-05-08  0:37:10
