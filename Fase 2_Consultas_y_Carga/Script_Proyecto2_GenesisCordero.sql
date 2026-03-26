-- ======================================================
-- 1. CREACIÓN DE LA BASE DE DATOS Y CONFIGURACIÓN
-- ======================================================
CREATE DATABASE IF NOT EXISTS genesiscordero_proyecto2;
USE genesiscordero_proyecto2;

-- Desactivar llaves foráneas para permitir el borrado limpio
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET SQL_SAFE_UPDATES = 0;
-- ======================================================
-- 2. CREACIÓN DE TABLAS 
-- ======================================================
-- Tabla Equipos 
DROP TABLE IF EXISTS `equipos`;
CREATE TABLE `equipos` (
  `ID_Equipo` int(15) NOT NULL,
  `Nombre_equipo` varchar(100) NOT NULL,
  `Tipo` varchar(50) NOT NULL,
  `Ubicacion` varchar(75) NOT NULL,
  `Numero_serie` varchar(15) NOT NULL,
  PRIMARY KEY (`ID_Equipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Funcionarios 
DROP TABLE IF EXISTS `funcionario`;
CREATE TABLE `funcionario` (
  `ID_Usuario` int(11) NOT NULL,
  `Nombre` varchar(25) NOT NULL,
  `Apellido_1` varchar(25) NOT NULL,
  `Apellido_2` varchar(25) NOT NULL,
  `Departamento` varchar(100) NULL DEFAULT NULL,
  `Telefono` varchar(15) NULL DEFAULT NULL,
  `Email` varchar(50) NULL,
  PRIMARY KEY (`ID_Usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Técnicos
DROP TABLE IF EXISTS `tecnicos`;
CREATE TABLE `tecnicos` (
  `ID_Tecnico` int(11) NOT NULL,
  `Nombre` varchar(25) NOT NULL,
  `Apellido` varchar(25) NOT NULL,
  `Especialidad` varchar(75) NULL,
  `Telefono` varchar(15) NULL,
  `Email` varchar(50) NOT NULL,
  PRIMARY KEY (`ID_Tecnico`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Orden de Servicios
DROP TABLE IF EXISTS `orden_servicio`;
CREATE TABLE `orden_servicio` (
  `ID_Orden` int(11) NOT NULL,
  `Descripcion` varchar(100) NOT NULL,
  `Fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Estado_actual` VARCHAR(20) NULL,
  `Fecha_completado` DATETIME NULL DEFAULT NULL,
  `ID_Usuario` int(11) NOT NULL,
  `ID_Equipo` int(11) NOT NULL DEFAULT '1',
  `ID_Tecnico` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`ID_Orden`),
  CONSTRAINT `FK_Equipo` FOREIGN KEY (`ID_Equipo`) REFERENCES `equipos` (`ID_Equipo`),
  CONSTRAINT `FK_Tecnico` FOREIGN KEY (`ID_Tecnico`) REFERENCES `tecnicos` (`ID_Tecnico`),
  CONSTRAINT `FK_Usuario` FOREIGN KEY (`ID_Usuario`) REFERENCES `funcionario` (`ID_Usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Historial de Ordenes 
DROP TABLE IF EXISTS `historial_ordenes`;
CREATE TABLE `historial_ordenes` (
  `ID_Orden` int(11) NOT NULL,
  `ID_Tecnico` int(11) NOT NULL,
  `Fecha_actualizada` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Descripcion` varchar(200) NOT NULL,
  CONSTRAINT `FK_Orden_Historial` FOREIGN KEY (`ID_Orden`) REFERENCES `orden_servicio` (`ID_Orden`),
  CONSTRAINT `FK_Tecnico_Historial` FOREIGN KEY (`ID_Tecnico`) REFERENCES `tecnicos` (`ID_Tecnico`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;

-- REQUQERIMIENTO 1: COMANDOS DE BORRADO Y CARGA DE DATOS
-- ======================================================
-- 3. ELIMINACIÓN DE LOS DATOS DE LAS TABLAS 
-- ======================================================
DELETE FROM historial_ordenes; 
DELETE FROM orden_servicio;
DELETE FROM tecnicos;
DELETE FROM equipos;
DELETE FROM funcionario;

-- ======================================================
-- 4. CARGA DE DATOS 
-- ======================================================
-- A. Técnicos 
INSERT INTO tecnicos (ID_Tecnico, Nombre, Apellido, Especialidad, Telefono, Email) VALUES 
(101230456, 'Ricardo', 'Vargas', 'Soporte Hardware', '8888-1111', 'rvargas@empresa.com'),
(204560789, 'Sofía', 'Castro', 'Redes y Conectividad', '8888-2222', 'scastro@empresa.com'),
(307890123, 'Manuel', 'Solano', 'Software Base', '8888-3333', 'msolano@empresa.com');

-- B. Funcionarios 
INSERT INTO funcionario (ID_Usuario, Nombre, Apellido_1, Apellido_2, Departamento, Telefono, Email) VALUES 
(109870654, 'Lucía', 'Méndez', 'Castro', 'Recursos Humanos', '7777-1010', 'lmendez@empresa.com'),
(403210987, 'Andrés', 'Gómez', 'Salas', 'Contabilidad', '7777-2020', 'agomez@empresa.com'),
(501590753, 'Beatriz', 'Peña', 'Perez', 'Logística', '7777-3030', 'bpena@empresa.com'); 

-- C. Equipos 
INSERT INTO equipos (ID_Equipo, Nombre_equipo, Tipo, Ubicacion, Numero_serie) VALUES 
(1001, 'Dell Latitude', 'Laptop', 'Oficina 201', 'SN-DELL-9988'),
(1002, 'HP LaserJet', 'Impresora', 'Piso 2 Pasillo', 'SN-HP-5544'),
(1003, 'LG UltraWide', 'Monitor', 'Bodega Central', 'SN-LG-1122');

-- D. Órdenes de Servicio 
-- ORDENES FINALIZADAS
INSERT INTO orden_servicio (ID_Orden, Descripcion, Fecha_creacion, Fecha_completado, Estado_actual, ID_Usuario, ID_Equipo, ID_Tecnico) 
VALUES 
(5001, 'Cambio de teclado laptop', '2026-02-28 08:00:00', '2026-03-01 10:00:00', 'Finalizado', 109870654, 1001, 307890123),
(5002, 'Instalación de antivirus', '2026-02-01 09:30:00', '2026-02-01 11:30:00', 'Finalizado', 403210987, 1002, 101230456),
(5003, 'Limpieza de impresora', '2026-02-06 13:20:00', '2026-02-01 14:00:00', 'Finalizado', 109870654, 1002, 101230456),
(5004, 'Configuración Scanner', '2026-02-06 13:50:00','2026-02-01 14:30:00', 'Finalizado', 109870654, 1002, 101230456);

-- ORDENES EN PROCESO 
INSERT INTO orden_servicio (ID_Orden, Descripcion, Fecha_creacion, Estado_actual, ID_Usuario, ID_Equipo, ID_Tecnico) VALUES 
(5005, 'Revisión de puerto HDMI', '2026-03-05 14:00:00', 'En Proceso', 501590753, 1003, 204560789),
(5006, 'Mantenimiento preventivo PC', '2026-03-06 08:00:00', 'En Proceso', 109870654, 1001, 101230456),
(5007, 'Actualización de RAM', '2026-03-06 09:15:00', 'En Proceso', 403210987, 1001, 307890123),
(5008, 'Fallo en fuente de poder', '2026-03-06 10:30:00', 'En Proceso', 501590753, 1002, 204560789),
(5009, 'Configuración de correo', '2026-03-06 11:45:00', 'En Proceso', 109870654, 1001, 101230456);

-- Insertamos una orden con fecha de fin, pero estado "En proceso" para validar el requerimiento 4 más adelante 
INSERT INTO orden_servicio (ID_Orden, Descripcion, Fecha_creacion, Fecha_completado, Estado_actual, ID_Usuario, ID_Equipo, ID_Tecnico) 
VALUES (5010, 'Prueba de actualización', '2026-03-07 08:00:00', '2026-03-07 10:00:00', 'En proceso', 109870654, 1001, 307890123);

-- ORDENES PENDIENTES
INSERT INTO orden_servicio (ID_Orden, Descripcion, Fecha_creacion, Estado_actual, ID_Usuario, ID_Equipo, ID_Tecnico) VALUES 
(5011, 'Pantalla parpadea', '2026-03-06 13:00:00', 'Pendiente', 403210987, 1003, 307890123),
(5012, 'Mouse no reconocido', '2026-03-06 13:10:00', 'Pendiente', 501590753, 1001, 204560789),
(5013, 'Error de certificado VPN', '2026-03-06 14:00:00', 'Pendiente', 403210987, 1001, 307890123),
(5014, 'Actualización de BIOS', '2026-03-06 14:10:00', 'Pendiente', 501590753, 1003, 204560789),
(5015, 'Recuperación de archivos', '2026-03-06 14:20:00', 'Pendiente', 109870654, 1001, 101230456);

-- E. Historial de Órdenes
INSERT INTO historial_ordenes (ID_Orden, ID_Tecnico, Fecha_actualizada, Descripcion) VALUES 
(5001, 307890123, '2026-03-01 10:00:00', 'Se realizo el cambio de teclado'),
(5002, 101230456, '2026-02-02 15:00:00', 'Se instalo el antivirus y se configuro');

SET FOREIGN_KEY_CHECKS = 1;

-- Visualización y Verificación de Datos 
SELECT * FROM funcionario;
SELECT * FROM tecnicos;
SELECT * FROM equipos;
SELECT * FROM orden_servicio;
SELECT * FROM historial_ordenes;

-- ======================================================
-- 5. REPORTES SOLICITADOS
-- ======================================================
-- REQUERIMIENTO 2: INFORMACION DE LAS ORDENES DE SERVICIO
SELECT 
    os.ID_Orden,
    os.Descripcion AS Descripcion_Orden,
    os.Fecha_creacion,
    os.Fecha_completado,
    os.ID_Usuario,
    f.Nombre AS Nombre_Usuario,
    os.ID_Tecnico,
    t.Nombre AS Nombre_Tecnico,
    os.Estado_actual AS Descripcion_Estado,
    os.ID_Equipo,
    e.Tipo AS Nombre_Equipo,
    e.Numero_serie
FROM 
    orden_servicio os
-- Relación con la tabla de Funcionarios para obtener el nombre de quien solicita
JOIN funcionario f ON os.ID_Usuario = f.ID_Usuario
-- Relación con la tabla de Técnicos para obtener el nombre del responsable
JOIN tecnicos t ON os.ID_Tecnico = t.ID_Tecnico
-- Relación con la tabla de Equipos para obtener los detalles del activo
JOIN equipos e ON os.ID_Equipo = e.ID_Equipo
ORDER BY os.ID_Orden ASC;

-- REQUERIMIENTO 3: CANTIDAD DE ORDENES POR AGRUPACIÓN
SELECT 
    Estado_actual AS Estado, 
    COUNT(ID_Orden) AS Cantidad_Ordenes
FROM 
    orden_servicio
GROUP BY 
    Estado_actual;
    
-- REQUERIMIENTO 4: ACTUALIZACIÓN DE ORDE A FINALIZADO
UPDATE orden_servicio
SET Estado_actual = 'Finalizado'
WHERE Fecha_completado IS NOT NULL AND Estado_actual <> 'Finalizado';
    
-- VERIFICACION DE LOS DATOS DESPUES DE EJECUTAR UPDATE 
    SELECT * FROM orden_servicio 
WHERE Fecha_completado IS NOT NULL 
AND Estado_actual <> 'Finalizada';


