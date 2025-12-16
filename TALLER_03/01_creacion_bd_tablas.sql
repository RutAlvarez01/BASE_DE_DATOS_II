-- TALLER #2 - Fidelización y Análisis de Colaboradores (Empresa XYZ)
-- Motor sugerido: MySQL 8.x (usa funciones de ventana para la vista de historial de login)

DROP DATABASE IF EXISTS xyz_fidelizacion;
CREATE DATABASE xyz_fidelizacion CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE xyz_fidelizacion;

-- ====== TABLAS ======

CREATE TABLE perfiles (
  perfil_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre_perfil VARCHAR(60) NOT NULL UNIQUE,
  fecha_vigencia_perfil DATE NOT NULL,
  descripcion_perfil VARCHAR(255) NOT NULL,
  encargado_perfil VARCHAR(120) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE usuarios (
  usuario_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(60) NOT NULL,
  apellido VARCHAR(60) NOT NULL,
  estado ENUM('activo','inactivo') NOT NULL,
  contrasena VARCHAR(255) NOT NULL,
  cargo VARCHAR(120) NOT NULL,
  salario DECIMAL(12,2) NOT NULL DEFAULT 0,
  fecha_ingreso DATE NOT NULL,
  perfil_id INT NOT NULL,
  CONSTRAINT fk_usuarios_perfil
    FOREIGN KEY (perfil_id) REFERENCES perfiles(perfil_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE login (
  login_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  fecha_hora_login DATETIME NOT NULL,
  estado_login ENUM('exitoso','fallido') NOT NULL,
  CONSTRAINT fk_login_usuario
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  INDEX idx_login_usuario_fecha (usuario_id, fecha_hora_login)
) ENGINE=InnoDB;

CREATE TABLE actividades (
  actividad_id INT AUTO_INCREMENT PRIMARY KEY,
  fecha_actividad DATE NOT NULL,
  tipo_actividad VARCHAR(80) NOT NULL,
  descripcion_actividad VARCHAR(255) NOT NULL,
  puntos_otorgados INT NOT NULL CHECK (puntos_otorgados >= 0),
  INDEX idx_act_fecha (fecha_actividad)
) ENGINE=InnoDB;

-- Tabla intermedia: participación de usuarios en actividades (Fidelización)
CREATE TABLE participacion_actividad (
  participacion_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  actividad_id INT NOT NULL,
  puntos_ganados INT NOT NULL CHECK (puntos_ganados >= 0),
  CONSTRAINT fk_part_usuario
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_part_actividad
    FOREIGN KEY (actividad_id) REFERENCES actividades(actividad_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  UNIQUE KEY uq_usuario_actividad (usuario_id, actividad_id)
) ENGINE=InnoDB;

-- Nota: Para prever permisos por perfil en el futuro, se recomienda una tabla "permisos"
-- y una tabla puente "perfil_permiso" (no requerida en este taller).
