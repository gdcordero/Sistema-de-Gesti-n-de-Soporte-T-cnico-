-- ======================================================
-- 1. CREACIÓN DE LA BASE DE DATOS Y CONFIGURACIÓN
-- ======================================================
CREATE DATABASE IF NOT EXISTS genesiscordero_proyecto1;
USE genesiscordero_proyecto1;

-- Desactivar llaves foráneas para permitir el borrado limpio
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

-- ======================================================
-- 2. CREACIÓN DE TABLAS 
-- ======================================================
DROP TABLE IF EXISTS `equipos`;
CREATE TABLE `equipos` (
  `ID_Equipo` varchar(15) NOT NULL,
  `Tipo` varchar(50) NOT NULL,
  `Ubicacion` varchar(75) NOT NULL,
  `Numero_serie` varchar(15) NOT NULL,
  PRIMARY KEY (`ID_Equipo`),
  UNIQUE KEY `Numero_serie_UNIQUE` (`Numero_serie`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `funcionario`;
CREATE TABLE `funcionario` (
  `ID_Usuario` varchar(15) NOT NULL,
  `Nombre` varchar(50) NOT NULL,
  `Departamento` varchar(100) NOT NULL,
  `Telefono` varchar(15) NOT NULL,
  `Email` varchar(50) NOT NULL,
  PRIMARY KEY (`ID_Usuario`),
  UNIQUE KEY `Email_UNIQUE` (`Email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `tecnicos`;
CREATE TABLE `tecnicos` (
  `ID_Tecnico` varchar(15) NOT NULL,
  `Nombre` varchar(50) NOT NULL,
  `Especialidad` varchar(75) NOT NULL,
  `Telefono` varchar(15) NOT NULL,
  `Email` varchar(50) NOT NULL,
  PRIMARY KEY (`ID_Tecnico`),
  UNIQUE KEY `Email_UNIQUE` (`Email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `orde_servicio`;
CREATE TABLE `orde_servicio` (
  `ID_Orden` varchar(15) NOT NULL,
  `Descripcion` varchar(50) NOT NULL,
  `Fecha_creacion` varchar(10) NOT NULL,
  `Estado_actual` enum('Pendiente','En proceso','Finalizado') NOT NULL,
  `Fecha_completado` varchar(10) NOT NULL,
  `ID_Usuario` varchar(15) NOT NULL,
  `ID_Equipo` varchar(15) NOT NULL,
  `ID_Tecnico` varchar(15) NOT NULL,
  PRIMARY KEY (`ID_Orden`),
  CONSTRAINT `FK_Equipo` FOREIGN KEY (`ID_Equipo`) REFERENCES `equipos` (`ID_Equipo`),
  CONSTRAINT `FK_Tecnico` FOREIGN KEY (`ID_Tecnico`) REFERENCES `tecnicos` (`ID_Tecnico`),
  CONSTRAINT `FK_Usuario` FOREIGN KEY (`ID_Usuario`) REFERENCES `funcionario` (`ID_Usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `historial_ordenes`;
CREATE TABLE `historial_ordenes` (
  `ID_Historial` varchar(15) NOT NULL,
  `Fecha_actualizada` varchar(10) NOT NULL,
  `Descripcion` varchar(50) NOT NULL,
  `ID_Orden` varchar(15) NOT NULL,
  `ID_Tecnico` varchar(15) NOT NULL,
  PRIMARY KEY (`ID_Historial`),
  CONSTRAINT `FK_Orden_Historial` FOREIGN KEY (`ID_Orden`) REFERENCES `orde_servicio` (`ID_Orden`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;

-- ======================================================
-- 3. CARGA DE DATOS 
-- ======================================================
INSERT INTO `equipos` VALUES ('EQP-001','Laptop','Oficina 10','SN-998877');
INSERT INTO `funcionario` VALUES ('FNC-001','Juan Pérez','IT','8888-1111','juan@mail.com');
INSERT INTO `tecnicos` VALUES ('TEC-01','Génesis Cordero','Soporte Técnico','7777-2222','genesis@soporte.com');
INSERT INTO `orde_servicio` VALUES ('ORD-001','Pantalla azul al iniciar','2026-02-20','En proceso','pendiente','FNC-001','EQP-001','TEC-01');
INSERT INTO `historial_ordenes` VALUES ('HIS-01','2026-02-20','Se revisó memoria RAM, todo bien.','ORD-001','TEC-01');

-- ======================================================
-- 4. REPORTES SOLICITADOS
-- ======================================================
-- A. Reporte agrupado por estado
SELECT Estado_actual, count(*) as Total_Solicitudes FROM orde_servicio GROUP BY Estado_actual;

-- B. Historial ordenado por fecha
SELECT Fecha_actualizada, Descripcion FROM historial_ordenes WHERE ID_Orden = 'ORD-001' ORDER BY Fecha_actualizada ASC;

-- C. Técnicos involucrados 
SELECT DISTINCT T.Nombre as Tecnico_involucrado FROM tecnicos T JOIN historial_ordenes H on T.ID_Tecnico = H.ID_Tecnico WHERE H.ID_Orden = 'ORD-001';

-- Dump completed on 2026-02-21 21:48:52
