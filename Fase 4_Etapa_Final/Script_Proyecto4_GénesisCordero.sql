/* =========================================================
TechServicesCR - Proyecto 4 (MySQL)

MODIFICACIONES
  J.Villalobos  17.Feb.2026  Creación
  
  Estudiante:
  Génesis Cordero Corea
  Cedula: 117300049

NOTAS
- Se usa INT como llave primaria por diferentes razones:
  + Rendimiento: un INT utiliza 4 bytes y VARCHAR(100) podría ocupar más de 100. Indices más pequeños, búsquedas más rápidas
  + Integridad referencial: es más limpio tener un FK que sea un número a un texto
  + Portabilidad entre motores de bases de datos
  + Los nombres pueden cambiar (Departamento de TI / Departamento de Tecnologías de Información) sin afectar la llave primaria
  
- No se utiliza ENUM, se maneja un catálogo de estados pues ENUM es propio de MySQL
*/

DROP DATABASE IF EXISTS TechServicesCR;
CREATE DATABASE TechServicesCR
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;  -- No sensible a los acentos ni a las mayúsculas/minúsculas

USE TechServicesCR;

-- -----------------------
-- Catálogos
-- -----------------------

CREATE TABLE Departamento (
  DepartamentoId INT AUTO_INCREMENT PRIMARY KEY,
  Nombre         VARCHAR(100) NOT NULL,
  CONSTRAINT UQ_Departamento_Nombre UNIQUE (Nombre)
) ENGINE=InnoDB;

CREATE TABLE Especialidad (
  EspecialidadId INT AUTO_INCREMENT PRIMARY KEY,
  Nombre         VARCHAR(100) NOT NULL,
  CONSTRAINT UQ_Especialidad_Nombre UNIQUE (Nombre)
) ENGINE=InnoDB;

CREATE TABLE EquipoTipo (
  EquipoTipoId INT AUTO_INCREMENT PRIMARY KEY,
  Nombre       VARCHAR(80) NOT NULL,
  CONSTRAINT UQ_EquipoTipo_Nombre UNIQUE (Nombre)
) ENGINE=InnoDB;

CREATE TABLE Ubicacion (
  UbicacionId INT AUTO_INCREMENT PRIMARY KEY,
  Nombre      VARCHAR(120) NOT NULL,
  CONSTRAINT UQ_Ubicacion_Nombre UNIQUE (Nombre)
) ENGINE=InnoDB;

CREATE TABLE EstadoOrden (
  EstadoOrdenId INT AUTO_INCREMENT PRIMARY KEY,
  Codigo        VARCHAR(20) NOT NULL,           -- Pendiente, En proceso, Finalizado
  EsFinal       TINYINT(1) NOT NULL DEFAULT 0,  -- Opcional para determinar cuál es el último estado del proceso
  OrdenVisual   INT NOT NULL DEFAULT 0,         -- Para determinar el orden de los procesos
  CONSTRAINT UQ_EstadoOrden_Codigo UNIQUE (Codigo)
) ENGINE=InnoDB;

-- -----------------------
-- Entidades
-- -----------------------

CREATE TABLE Usuario (
  UsuarioId      INT AUTO_INCREMENT PRIMARY KEY,
  Nombre         VARCHAR(120) NOT NULL,
  DepartamentoId INT NOT NULL,
  Telefono       VARCHAR(30) NULL,
  Email          VARCHAR(150) NOT NULL,
  CONSTRAINT UQ_Usuario_Email UNIQUE (Email),
  CONSTRAINT FK_Usuario_Departamento
    FOREIGN KEY (DepartamentoId) REFERENCES Departamento(DepartamentoId)
) ENGINE=InnoDB;

CREATE TABLE Tecnico (
  TecnicoId      INT AUTO_INCREMENT PRIMARY KEY,
  Nombre         VARCHAR(120) NOT NULL,
  EspecialidadId INT NOT NULL,
  Telefono       VARCHAR(30) NULL,
  Email          VARCHAR(150) NOT NULL,
  CONSTRAINT UQ_Tecnico_Email UNIQUE (Email),
  CONSTRAINT FK_Tecnico_Especialidad
    FOREIGN KEY (EspecialidadId) REFERENCES Especialidad(EspecialidadId)
) ENGINE=InnoDB;

CREATE TABLE Equipo (
  EquipoId      INT AUTO_INCREMENT PRIMARY KEY,
  EquipoTipoId  INT NOT NULL,
  UbicacionId   INT NOT NULL,
  NumeroSerie   VARCHAR(80) NOT NULL,
  CONSTRAINT UQ_Equipo_NumeroSerie UNIQUE (NumeroSerie),
  CONSTRAINT FK_Equipo_Tipo
    FOREIGN KEY (EquipoTipoId) REFERENCES EquipoTipo(EquipoTipoId),
  CONSTRAINT FK_Equipo_Ubicacion
    FOREIGN KEY (UbicacionId) REFERENCES Ubicacion(UbicacionId)
) ENGINE=InnoDB;

-- -----------------------
-- Orden del servicio
-- -----------------------

CREATE TABLE OrdenServicio (
  OrdenId          INT AUTO_INCREMENT PRIMARY KEY,
  EquipoId         INT NOT NULL,
  UsuarioCreadorId INT NOT NULL,
  Descripcion      VARCHAR(2000) NOT NULL,  -- No utilizar TEXT pues en algunos motores no es posible consultar el tipo TEXT
  FechaCreacion    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  EstadoOrdenId    INT NOT NULL,
  FechaCompletado  DATETIME NULL,

  CONSTRAINT FK_Orden_Equipo
    FOREIGN KEY (EquipoId) REFERENCES Equipo(EquipoId),

  CONSTRAINT FK_Orden_UsuarioCreador
    FOREIGN KEY (UsuarioCreadorId) REFERENCES Usuario(UsuarioId),

  CONSTRAINT FK_Orden_Estado
    FOREIGN KEY (EstadoOrdenId) REFERENCES EstadoOrden(EstadoOrdenId),
	
  CONSTRAINT CK_Orden_FechaCompletado 
    CHECK (FechaCompletado IS NULL OR FechaCompletado > FechaCreacion)
) ENGINE=InnoDB;

-- -----------------------
-- Técnicos por orden (N:M)
-- -----------------------
CREATE TABLE OrdenTecnico (
  OrdenId   INT NOT NULL,
  TecnicoId INT NOT NULL,
  Rol       VARCHAR(60) NULL,  -- Opcional para indicar quien es el "Asignado", "Responsable" o de "Apoyo" en el tiquete 

  PRIMARY KEY (OrdenId, TecnicoId),

  CONSTRAINT FK_OrdenTecnico_Orden
    FOREIGN KEY (OrdenId) REFERENCES OrdenServicio(OrdenId),

  CONSTRAINT FK_OrdenTecnico_Tecnico
    FOREIGN KEY (TecnicoId) REFERENCES Tecnico(TecnicoId)
) ENGINE=InnoDB;

-- -----------------------
-- Historial de órdenes
-- -----------------------
CREATE TABLE HistorialOrden (
  HistorialId        INT AUTO_INCREMENT PRIMARY KEY,
  OrdenId            INT NOT NULL,
  TecnicoId          INT NOT NULL,
  FechaActualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Descripcion        VARCHAR(2000) NOT NULL,

  CONSTRAINT FK_Historial_Orden
    FOREIGN KEY (OrdenId) REFERENCES OrdenServicio(OrdenId),

  CONSTRAINT FK_Historial_Tecnico
    FOREIGN KEY (TecnicoId) REFERENCES Tecnico(TecnicoId)
) ENGINE=InnoDB;

-- -----------------------
-- Seed catálogo de estados
-- -----------------------
INSERT INTO EstadoOrden (Codigo, EsFinal, OrdenVisual)
VALUES
 ('Pendiente',   0, 1),
 ('En proceso',  0, 2),
 ('Finalizado',  1, 3);

-- -----------------------
-- Carga de Datos
-- -----------------------
-- departamento
DELIMITER //

CREATE PROCEDURE InsertarDepartamento(
    IN pNombre VARCHAR(100)
)
BEGIN
    INSERT INTO departamento (Nombre)
    VALUES (pNombre);
END //

DELIMITER ;

CALL InsertarDepartamento('Mantenimiento');
CALL InsertarDepartamento('Sistemas');

-- usuarios
DELIMITER //
CREATE PROCEDURE InsertarUsuario(
    IN pNombre VARCHAR(120),
    IN pDepartamentoId INT,
    IN pTelefono VARCHAR(30),
    IN pEmail VARCHAR(150)
)
BEGIN
    INSERT INTO usuario (Nombre, DepartamentoId, Telefono, Email)
    VALUES (pNombre, pDepartamentoId, pTelefono, pEmail);
END //
DELIMITER ;

CALL InsertarUsuario('Juan Pérez', 1, '8689-8088', 'juan@example.com');
CALL InsertarUsuario('Ana Gómez', 2, '8231-9999', 'ana@example.com');

-- Tipos de Equipo
DELIMITER //
CREATE PROCEDURE InsertarEquipoTipo(
    IN pNombre VARCHAR(80)
)
BEGIN
    INSERT INTO equipotipo (Nombre)
    VALUES (pNombre);
END //
DELIMITER ;

CALL InsertarEquipoTipo('Laptop');
CALL InsertarEquipoTipo('Servidor');

-- ubicacion
INSERT INTO ubicacion (UbicacionId, Nombre) VALUES (1, 'Bodega Principal');
INSERT INTO ubicacion (UbicacionId, Nombre) VALUES (2, 'Piso 3');

-- equipos
DELIMITER //
CREATE PROCEDURE InsertarEquipo(
    IN pEquipoTipoId INT,
    IN pUbicacionId INT,
    IN pNumeroSerie VARCHAR(80)
)
BEGIN
    INSERT INTO equipo (EquipoTipoId, UbicacionId, NumeroSerie)
    VALUES (pEquipoTipoId, pUbicacionId, pNumeroSerie);
END //
DELIMITER ;

CALL InsertarEquipo(1, 1, 'ABC123');
CALL InsertarEquipo(2, 1, 'XYZ789');

-- ordenes de servicio
DELIMITER //
CREATE PROCEDURE InsertarOrdenServicio(
    IN pEquipoId INT,
    IN pUsuarioCreadorId INT,
    IN pDescripcion VARCHAR(2000),
    IN pEstadoOrdenId INT,
    IN pFechaCompletado DATETIME
)
BEGIN
    INSERT INTO ordenservicio (EquipoId, UsuarioCreadorId, Descripcion, EstadoOrdenId, FechaCompletado)
    VALUES (pEquipoId, pUsuarioCreadorId, pDescripcion, pEstadoOrdenId, pFechaCompletado);
END //
DELIMITER ;

CALL InsertarOrdenServicio(1, 1, 'Revisión de laptop', 1, NULL);
CALL InsertarOrdenServicio(2, 2, 'Instalación de servidor', 2, '2026-05-15 10:00:00');

-- especialidad
INSERT INTO especialidad (EspecialidadId, Nombre)
VALUES (1, 'Soporte Hardware'),
       (2, 'Redes y Conectividad'),
       (3, 'Software Base');
       
-- tecnico
INSERT INTO tecnico (Nombre, EspecialidadId, Telefono, Email)
VALUES ('Ricardo Vargas', 1, '8168-8191', 'rvargas@empresa.com'),
       ('Sofía Castro', 2, '8288-2923', 'scastro@empresa.com'),
       ('Manuel Solano', 3, '8688-3533', 'msolano@empresa.com');
       
-- orden tecnico
INSERT INTO ordentecnico (OrdenId, TecnicoId, Rol)
VALUES (1, 1, 'Responsable'),
       (1, 2, 'Apoyo'),
       (2, 3, 'Responsable');
       
SELECT * FROM tecnico;
SELECT OrdenId, Descripcion FROM OrdenServicio;


-- ======================================================
-- 1. CREACIÓN DE LA VISTA (ordenesdetalle)
-- ======================================================
CREATE VIEW vw_OrdenesDetalle AS
SELECT 
    o.OrdenId AS IdOrden,
    o.Descripcion AS DescripcionOrden,
    o.FechaCreacion AS FechaCreacion,
    o.FechaCompletado AS FechaCompletado,
    eo.Codigo AS EstadoOrden,
    u.UsuarioId AS IdUsuario,
    u.Nombre AS NombreUsuario,
    d.Nombre AS DepartamentoUsuario,
    e.EquipoId AS IdEquipo,
    et.Nombre AS TipoEquipo,
    e.NumeroSerie AS NumeroSerie,
    t.TecnicoId AS IdTecnico,
    t.Nombre AS NombreTecnico
FROM ordenservicio o
INNER JOIN usuario u ON o.UsuarioCreadorId = u.UsuarioId
INNER JOIN departamento d ON u.DepartamentoId = d.DepartamentoId
INNER JOIN equipo e ON o.EquipoId = e.EquipoId
INNER JOIN equipotipo et ON e.EquipoTipoId = et.EquipoTipoId
INNER JOIN estadoorden eo ON o.EstadoOrdenId = eo.EstadoOrdenId
LEFT JOIN ordentecnico ot ON o.OrdenId = ot.OrdenId
LEFT JOIN tecnico t ON ot.TecnicoId = t.TecnicoId;

-- A) Órdenes con estado pendiente 
SELECT *
FROM vw_OrdenesDetalle
WHERE EstadoOrden = 'Pendiente';

-- B) Órdenes de un departamento en especifico
SELECT *
FROM vw_OrdenesDetalle
WHERE DepartamentoUsuario = 'Mantenimiento';

-- ======================================================
-- 2. TIGGER DE AUDITORIA AUTOMATICA 
-- ======================================================
DELIMITER //
CREATE TRIGGER trg_AuditoriaOrden
AFTER UPDATE ON OrdenServicio
FOR EACH ROW
BEGIN
    IF OLD.EstadoOrdenId <> NEW.EstadoOrdenId THEN
        INSERT INTO HistorialOrden (OrdenId, TecnicoId, FechaActualizacion, Descripcion)
        VALUES (
            NEW.OrdenId,
            (SELECT TecnicoId FROM ordentecnico WHERE OrdenId = NEW.OrdenId LIMIT 1),
            NOW(),
            CONCAT(
                'Estado cambiado de ',
                (SELECT Codigo FROM EstadoOrden WHERE EstadoOrdenId = OLD.EstadoOrdenId),
                ' a ',
                (SELECT Codigo FROM EstadoOrden WHERE EstadoOrdenId = NEW.EstadoOrdenId)
            )
        );
    END IF;
END //
DELIMITER ;

-- Actualizar una orden 
UPDATE OrdenServicio
SET EstadoOrdenId = 2
WHERE OrdenId = 1;

-- Consultar el historial para verificar el registro creado
SELECT * FROM HistorialOrden;

-- ======================================================
-- 3. Transacción para registrar una orden con técnico
-- ======================================================
DELIMITER //
CREATE PROCEDURE pr_CrearOrden(
    IN pEquipoId INT,
    IN pUsuarioCreadorId INT,
    IN pDescripcion VARCHAR(2000),
    IN pEstadoOrdenId INT,
    IN pTecnicoId INT,
    IN pRol VARCHAR(60)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si ocurre un error, revertir todo
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: No se pudo registrar la orden con técnico. Verifique los IDs.';
    END;

    START TRANSACTION;

    -- Paso 1: Insertar la orden
    INSERT INTO OrdenServicio (EquipoId, UsuarioCreadorId, Descripcion, EstadoOrdenId, FechaCompletado)
    VALUES (pEquipoId, pUsuarioCreadorId, pDescripcion, pEstadoOrdenId, NULL);

    -- Paso 2: Insertar el técnico asignado
    INSERT INTO OrdenTecnico (OrdenId, TecnicoId, Rol)
    VALUES (LAST_INSERT_ID(), pTecnicoId, pRol);

    -- Si ambos paso se ejecutan con exto
    COMMIT;
END //
DELIMITER ;

-- Ejecución exitosa
CALL pr_CrearOrden(1, 1, 'Mantenimiento de servidor', 1, 1, 'Responsable');

SELECT * FROM OrdenServicio;
SELECT * FROM OrdenTecnico;

-- Ejecución fallida (provocar ROLLBACK)
CALL pr_CrearOrden(2, 2, 'Instalación de red', 1, 99, 'Responsable');

SELECT * FROM OrdenServicio;
SELECT * FROM OrdenTecnico;

-- ======================================================
-- 4. Creación de usuarios 
-- ======================================================
-- Usuario administrador con acceso completo
CREATE USER 'admin_techservices'@'localhost' IDENTIFIED BY 'Proyecto2026*';
GRANT SELECT, INSERT, UPDATE, DELETE ON TechServicesCR.* TO 'admin_techservices'@'localhost';

-- Usuario técnico de solo lectura
CREATE USER 'tecnico_ro'@'localhost' IDENTIFIED BY 'Proyecto2026*';
GRANT SELECT ON TechServicesCR.OrdenServicio TO 'tecnico_ro'@'localhost';
GRANT SELECT ON TechServicesCR.HistorialOrden TO 'tecnico_ro'@'localhost';
GRANT SELECT ON TechServicesCR.Equipo TO 'tecnico_ro'@'localhost';
GRANT SELECT ON TechServicesCR.OrdenTecnico TO 'tecnico_ro'@'localhost';

-- Usuario de aplicación con permisos limitados
CREATE USER 'app_techservices'@'localhost' IDENTIFIED BY 'Proyecto2026*';
GRANT SELECT, INSERT, UPDATE ON TechServicesCR.OrdenServicio TO 'app_techservices'@'localhost';
GRANT SELECT, INSERT, UPDATE ON TechServicesCR.OrdenTecnico TO 'app_techservices'@'localhost';
GRANT SELECT, INSERT, UPDATE ON TechServicesCR.HistorialOrden TO 'app_techservices'@'localhost';

-- Verificación de permisos
SHOW GRANTS FOR 'admin_techservices'@'localhost'; 
SHOW GRANTS FOR 'tecnico_ro'@'localhost';
SHOW GRANTS FOR 'app_techservices'@'localhost';

-- ======================================================
-- 5. Índices y análisis de rendimiento 
-- ======================================================
-- a) Ejecutar EXPLAIN sobre la consulta
EXPLAIN
SELECT *
FROM OrdenServicio
WHERE FechaCreacion >= '2026-01-01'
  AND FechaCreacion < '2026-04-01';

-- b) Crear índices
CREATE INDEX idx_fecha_creacion ON OrdenServicio(FechaCreacion);
CREATE INDEX idx_fecha_usuario ON OrdenServicio(FechaCreacion, UsuarioCreadorId);

-- c) Volver a ejecutar EXPLAIN
EXPLAIN
SELECT *
FROM OrdenServicio
WHERE FechaCreacion >= '2026-01-01'
  AND FechaCreacion < '2026-04-01';

-- ======================================================
-- 6. Escenario: Registro completo de una orden de servicio 
-- ======================================================
-- a) Registro de la orden con  app_techservices y pr_CrearOrden
-- Conectarse como usuario app_techservices
-- Ejecutar el procedimiento para registrar la orden
CALL pr_CrearOrden(1, 1, 'Laptop no enciende - Reporte RRHH', 1, 1, 'Responsable');

-- Verificar que la orden se insertó en OrdenServicio
SELECT * 
FROM OrdenServicio
ORDER BY OrdenId DESC
LIMIT 1;

-- Verificar que el técnico quedó asignado en OrdenTecnico
SELECT * 
FROM OrdenTecnico
ORDER BY OrdenId DESC
LIMIT 1;

-- b) Verificación del trigger
DELIMITER //
CREATE TRIGGER trg_AuditoriaOrdenInsert
AFTER INSERT ON OrdenServicio
FOR EACH ROW
BEGIN
    INSERT INTO HistorialOrden (OrdenId, FechaActualizacion, Descripcion)
    VALUES (NEW.OrdenId, NOW(), 'Orden creada con estado inicial');
END //
DELIMITER ;

CALL pr_CrearOrden(1, 1, 'Laptop no enciende - Reporte RRHH', 1, 1, 'Responsable');

-- 	Verificar que la orden se creó:
SELECT * 
FROM OrdenServicio
ORDER BY OrdenId DESC
LIMIT 1;

-- Verificar que el trigger insertó el historial
SELECT * 
FROM HistorialOrden
ORDER BY HistorialId DESC
LIMIT 1;

-- c) Actualización del estado de la orden a En proceso
-- 1. Identificar el Id de la orden recién creada
SELECT OrdenId 
FROM OrdenServicio
ORDER BY OrdenId DESC
LIMIT 1;

-- Utilizamos el Id de la orden dando anteriormente

-- 2. Actualizar el estado de la orden a 'En proceso'
UPDATE OrdenServicio
SET EstadoOrdenId = 2
WHERE OrdenId = 5;

-- 3. Verificar que el trSELECT *
SELECT *
FROM HistorialOrden
WHERE OrdenId = 5;

-- d) Consulta del estado actual mediante la vista 
-- 1. Identificar el Id de la orden recién creada
SELECT OrdenId 
FROM OrdenServicio
ORDER BY OrdenId DESC
LIMIT 1;

-- Utilizamos el Id de la orden dado anteriormente:

-- 2. Consultar el estado actual mediante la vista
SELECT *
FROM vw_OrdenesDetalle
WHERE IdOrden = 5;

-- e) Ejecución de EXPLAIN sobre la vista
EXPLAIN
SELECT *
FROM vw_OrdenesDetalle
WHERE IdOrden = 5;

