USE xyz_fidelizacion;

-- ====== VISTAS SOLICITADAS ======

-- 1) Vista de Desempeño de Colaboradores
CREATE OR REPLACE VIEW v_DesempenoColaboradores AS
SELECT
  u.usuario_id,
  CONCAT(u.nombre,' ',u.apellido) AS nombre_completo,
  u.cargo,
  u.salario,
  u.fecha_ingreso,
  COALESCE(SUM(p.puntos_ganados),0) AS total_puntos_fidelizacion_acumulados,
  COALESCE(AVG(p.puntos_ganados),0) AS promedio_puntos_por_actividad,
  CASE
    WHEN COALESCE(SUM(p.puntos_ganados),0) > 500 THEN 'Excelente'
    WHEN COALESCE(SUM(p.puntos_ganados),0) BETWEEN 200 AND 500 THEN 'Bueno'
    ELSE 'Regular'
  END AS estado_fidelizacion,
  CASE
    WHEN MAX(CASE WHEN l.estado_login='exitoso' THEN l.fecha_hora_login END) IS NULL THEN NULL
    ELSE DATEDIFF(CURDATE(), DATE(MAX(CASE WHEN l.estado_login='exitoso' THEN l.fecha_hora_login END)))
  END AS dias_desde_ultimo_login
FROM usuarios u
LEFT JOIN participacion_actividad p ON p.usuario_id = u.usuario_id
LEFT JOIN login l ON l.usuario_id = u.usuario_id
GROUP BY
  u.usuario_id, u.nombre, u.apellido, u.cargo, u.salario, u.fecha_ingreso;

-- 2) Vista de Actividades por Perfil
CREATE OR REPLACE VIEW v_actividadesPorPerfil AS
SELECT
  pr.perfil_id,
  pr.nombre_perfil,
  pr.descripcion_perfil,
  COUNT(DISTINCT u.usuario_id) AS cantidad_usuarios_con_este_perfil,
  COUNT(pa.participacion_id) AS total_actividades_participadas_por_perfil,
  -- total puntos del perfil / cantidad de usuarios del perfil
  COALESCE(SUM(pa.puntos_ganados) / NULLIF(COUNT(DISTINCT u.usuario_id),0), 0) AS promedio_puntos_por_usuario_en_este_perfil,
  -- % de actividades (distintas) donde participó el perfil vs total de actividades realizadas
  COALESCE(
    (COUNT(DISTINCT pa.actividad_id) / NULLIF((SELECT COUNT(*) FROM actividades),0)) * 100,
    0
  ) AS porcentaje_participacion_total
FROM perfiles pr
LEFT JOIN usuarios u ON u.perfil_id = pr.perfil_id
LEFT JOIN participacion_actividad pa ON pa.usuario_id = u.usuario_id
GROUP BY pr.perfil_id, pr.nombre_perfil, pr.descripcion_perfil;

-- 3) Vista de Historial de Login Detallado
-- Nota: requiere MySQL 8+ (LAG)
CREATE OR REPLACE VIEW v_historialLoginDetallado AS
SELECT
  l.login_id,
  u.nombre AS nombre_usuario,
  u.apellido AS apellido_usuario,
  u.cargo AS cargo_usuario,
  l.fecha_hora_login,
  l.estado_login,
  TIMESTAMPDIFF(
    MINUTE,
    LAG(l.fecha_hora_login) OVER (PARTITION BY l.usuario_id ORDER BY l.fecha_hora_login),
    l.fecha_hora_login
  ) AS tiempo_desde_anterior_login_min
FROM login l
JOIN usuarios u ON u.usuario_id = l.usuario_id;
