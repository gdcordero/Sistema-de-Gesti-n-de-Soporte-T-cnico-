-- ======================================================
-- 1. CREACIÓN DE LA BASE DE DATOS Y CONFIGURACIÓN
-- ======================================================
CREATE DATABASE IF NOT EXISTS genesiscordero_proyecto3;
USE genesiscordero_proyecto3;

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

ALTER TABLE orden_servicio MODIFY COLUMN ID_Orden INT AUTO_INCREMENT;

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

-- ======================================================
-- 3. CARGA DE DATOS 
-- ======================================================
-- A. Técnicos 
INSERT INTO tecnicos (ID_Tecnico, Nombre, Apellido, Especialidad, Telefono, Email) VALUES 
(101230456, 'Ricardo', 'Vargas', 'Soporte Hardware', '8888-1111', 'rvargas@empresa.com'),
(204560789, 'Sofía', 'Castro', 'Redes y Conectividad', '8888-2222', 'scastro@empresa.com'),
(307890123, 'Manuel', 'Solano', 'Software Base', '8888-3333', 'msolano@empresa.com');

-- B. Equipos 
INSERT INTO equipos (ID_Equipo, Nombre_equipo, Tipo, Ubicacion, Numero_serie) VALUES 
(1001, 'Dell Latitude', 'Laptop', 'Oficina 201', 'SN-DELL-9988'),
(1002, 'HP LaserJet', 'Impresora', 'Piso 2 Pasillo', 'SN-HP-5544'),
(1003, 'LG UltraWide', 'Monitor', 'Bodega Central', 'SN-LG-1122');

-- ======================================================
-- 4. REQUERIMIENTOS 
-- ======================================================

-- REQUQERIMIENTO 1: PROCEDIMIENTO ALMACENADO
DELIMITER //

CREATE PROCEDURE sp_InsertarFuncionario(
    IN p_id_usuario INT,
    IN p_nombre VARCHAR(25),
    IN p_apellido_1 VARCHAR(25),
    IN p_apellido_2 VARCHAR(25),
    IN p_departamento VARCHAR(100),
    IN p_telefono VARCHAR(15),
    IN p_email VARCHAR(50)
)
BEGIN
    INSERT INTO funcionario (
        ID_Usuario, 
        Nombre, 
        Apellido_1, 
        Apellido_2, 
        Departamento, 
        Telefono, 
        Email
    )
    VALUES (
        p_id_usuario, 
        p_nombre, 
        p_apellido_1, 
        p_apellido_2, 
        p_departamento, 
        p_telefono, 
        p_email
    );
END //

DELIMITER ;

-- Inserción de los funcionarios 
CALL sp_InsertarFuncionario(
    109870654, 
    'Lucía', 
    'Méndez', 
    'Castro', 
    'Recursos Humanos', 
    '7777-1010', 
    'lmendez@empresa.com'
);

CALL sp_InsertarFuncionario(
    403210987, 
    'Andrés', 
    'Gómez', 
    'Salas', 
    'Contabilidad', 
    '7777-2020', 
    'agomez@empresa.com'
);

CALL sp_InsertarFuncionario(
    501590753, 
    'Beatriz', 
    'Peña', 
    'Perez', 
    'Logística', 
    '7777-3030', 
    'bpena@empresa.com'
);

-- Verificar que los tres se agregaron correctamente
SELECT * FROM funcionario;

-- REQUQERIMIENTO 2: FUNCION 
DELIMITER //

CREATE FUNCTION fn_ObtenerNombreCompleto(
    p_id_usuario INT
) 
RETURNS VARCHAR(100) -- Tamaño para que nos cargue las tres palabras 
DETERMINISTIC 
BEGIN
    DECLARE v_resultado VARCHAR(100);

    -- Usamos CONCAT para unir el Nombre y los apellidos agregando un espcacio entre cada uno
    SELECT CONCAT(Nombre, ' ', Apellido_1, ' ', Apellido_2) INTO v_resultado
    FROM funcionario
    WHERE ID_Usuario = p_id_usuario;

    RETURN v_resultado;
END //

DELIMITER ;

-- Verificación de los datos de la funcion que devuelve el nombre del funcionario 
SELECT fn_ObtenerNombreCompleto(109870654) AS Nombre_Funcionario; -- Cambia el ID para consultar por los demás funcionarios

-- REQUQERIMIENTO 3: PROCEDIMIENTO ALMACENADO
DELIMITER //

CREATE PROCEDURE sp_RegistrarOrdenServicio(
    IN p_id_usuario INT,
    IN p_id_tecnico INT,
    IN p_id_equipo INT,
    IN p_descripcion VARCHAR(100), -- Ajustado al largo de tu tabla (100)
    IN p_estado VARCHAR(20),       -- Ajustado al largo de tu tabla (20)
    IN p_fecha_creacion DATETIME   -- Ajustado al tipo de dato de tu tabla
)
BEGIN
    DECLARE v_existe_usuario INT;
    DECLARE v_existe_tecnico INT;
    DECLARE v_existe_equipo INT;

    -- 1. Validar que el Usuario exista
    SELECT COUNT(*) INTO v_existe_usuario FROM funcionario WHERE ID_Usuario = p_id_usuario;
    -- 2. Validar que el Técnico exista
    SELECT COUNT(*) INTO v_existe_tecnico FROM tecnicos WHERE ID_Tecnico = p_id_tecnico;
    -- 3. Validar que el Equipo exista
    SELECT COUNT(*) INTO v_existe_equipo FROM equipos WHERE ID_Equipo = p_id_equipo;

    -- Si los tres existen, procedemos a insertar
    IF v_existe_usuario > 0 AND v_existe_tecnico > 0 AND v_existe_equipo > 0 THEN
        INSERT INTO orden_servicio (
            ID_Usuario, 
            ID_Tecnico, 
            ID_Equipo, 
            Descripcion, 
            Estado_actual, 
            Fecha_creacion
        )
        VALUES (
            p_id_usuario, 
            p_id_tecnico, 
            p_id_equipo, 
            p_descripcion, 
            p_estado, 
            p_fecha_creacion
        );
        SELECT 'Éxito: Orden registrada correctamente.' AS Mensaje;
    ELSE
        SELECT 'Error: Verifique que el Usuario, Técnico y Equipo existan.' AS Mensaje;
    END IF;
END //

DELIMITER ;

-- Inserción de las ordenes de servicio
CALL sp_RegistrarOrdenServicio(
    109870654,           -- ID_Usuario (Lucía)
    101230456,           -- ID_Tecnico (Ricardo)
    1001,                -- ID_Equipo (Dell Latitude)
    'Revisión de hardware - No enciende', 
    'En proceso', 
    NOW()                -- Fecha y hora actual
);

CALL sp_RegistrarOrdenServicio(
    403210987,           -- ID_Usuario (Andrés)
    204560789,           -- ID_Tecnico (Sofía)
    1002,                -- ID_Equipo (Impresora HP LaserJet)
    'Falla en los cartuchos de tinta. La tinta se riega a la hora de imprimir.', 
    'Pendiente', 
    NOW()                -- Fecha y hora actual
);

-- Verificación del requerimiento 3
SELECT * FROM orden_servicio;

-- REQUQERIMIENTO 4: FUNCION 
DELIMITER //

CREATE FUNCTION fn_ConsultarEstadoOrden(
    p_id_orden INT
) 
RETURNS VARCHAR(20)
DETERMINISTIC 
BEGIN
    DECLARE v_estado VARCHAR(20);

    -- Buscamos el estado actual para el ID de orden recibido
    SELECT Estado_actual INTO v_estado
    FROM orden_servicio
    WHERE ID_Orden = p_id_orden;

    -- Retornamos el valor (ej: 'En proceso', 'Pendiente', 'Finalizado')
    RETURN v_estado;
END //

DELIMITER ;

-- Consultar el estado de la orden que acabamos de crear
SELECT fn_ConsultarEstadoOrden(1) AS Estado_Actual_Orden;

-- REQUQERIMIENTO 5: PROCEDIMIENTO ALMACENADO
DELIMITER //

CREATE PROCEDURE sp_RegistrarHistorialOrden(
    IN p_id_orden INT,
    IN p_id_tecnico INT,      
    IN p_descripcion VARCHAR(200) 
)
BEGIN
    DECLARE v_existe_orden INT;
    DECLARE v_existe_tecnico INT;

    -- Validamos que la orden y el técnico existan
    SELECT COUNT(*) INTO v_existe_orden FROM orden_servicio WHERE ID_Orden = p_id_orden;
    SELECT COUNT(*) INTO v_existe_tecnico FROM tecnicos WHERE ID_Tecnico = p_id_tecnico;

    IF v_existe_orden > 0 AND v_existe_tecnico > 0 THEN
        -- Insertamos en 'historial_ordenes'
        INSERT INTO historial_ordenes (
            ID_Orden, 
            ID_Tecnico, 
            Descripcion, 
            Fecha_actualizada
        )
        VALUES (
            p_id_orden, 
            p_id_tecnico, 
            p_descripcion, 
            NOW() -- La fecha actual automática
        );
        SELECT 'Éxito: Evento registrado en el historial.' AS Mensaje;
    ELSE
        SELECT 'Error: La Orden o el Técnico no existen.' AS Mensaje;
    END IF;
END //

DELIMITER ;

-- Registramos que el técnico Ricardo revisó la orden #1
CALL sp_RegistrarHistorialOrden(
    1, 
    101230456, 
    'Se realizó el cambio de pasta térmica y limpieza.'
);

-- Verificamos el resultado
SELECT * FROM historial_ordenes;

-- REQUQERIMIENTO 6: FUNCION
DELIMITER //

CREATE FUNCTION fn_CantidadOrdenesPorEquipo(
    p_id_equipo INT
) 
RETURNS INT
DETERMINISTIC 
BEGIN
    DECLARE v_total_ordenes INT;

    -- Contamos cuántas órdenes existen para el equipo solicitado
    SELECT COUNT(*) INTO v_total_ordenes
    FROM orden_servicio
    WHERE ID_Equipo = p_id_equipo;

    -- Devolvemos el número total
    RETURN v_total_ordenes;
END //

DELIMITER ;

-- Consultar cuántas órdenes tiene la Dell Latitude
SELECT fn_CantidadOrdenesPorEquipo(1001) AS Total_Ordenes_Equipo;
