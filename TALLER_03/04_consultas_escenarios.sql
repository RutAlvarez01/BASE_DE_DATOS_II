USE xyz_fidelizacion;

-- ====== CONSULTAS PARA ESCENARIOS DE NEGOCIO (USO DE VISTAS) ======

-- 1) Top 5 colaboradores con mejor desempeño en fidelización en el último trimestre (últimos 3 meses)
SELECT
  CONCAT(u.nombre,' ',u.apellido) AS nombre_completo,
  u.cargo,
  SUM(pa.puntos_ganados) AS puntos_ultimo_trimestre
FROM usuarios u
JOIN participacion_actividad pa ON pa.usuario_id = u.usuario_id
JOIN actividades a ON a.actividad_id = pa.actividad_id
WHERE a.fecha_actividad >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY u.usuario_id, u.nombre, u.apellido, u.cargo
ORDER BY puntos_ultimo_trimestre DESC
LIMIT 5;

-- 2) Perfiles con menor participación en actividades (para plan de incentivos)
SELECT
  nombre_perfil,
  descripcion_perfil,
  cantidad_usuarios_con_este_perfil,
  total_actividades_participadas_por_perfil,
  porcentaje_participacion_total
FROM v_actividadesPorPerfil
ORDER BY total_actividades_participadas_por_perfil ASC, porcentaje_participacion_total ASC
LIMIT 5;

-- 3) Usuarios que NO han iniciado sesión en los últimos 30 días (o nunca han tenido login exitoso)
SELECT
  nombre_completo,
  cargo,
  dias_desde_ultimo_login
FROM v_DesempenoColaboradores
WHERE dias_desde_ultimo_login IS NULL OR dias_desde_ultimo_login > 30
ORDER BY dias_desde_ultimo_login DESC;

-- 4) Reporte mensual: logins exitosos vs fallidos
SELECT
  YEAR(fecha_hora_login) AS anio,
  MONTH(fecha_hora_login) AS mes,
  SUM(CASE WHEN estado_login='exitoso' THEN 1 ELSE 0 END) AS logins_exitosos,
  SUM(CASE WHEN estado_login='fallido' THEN 1 ELSE 0 END) AS logins_fallidos,
  COUNT(*) AS total_logins
FROM login
GROUP BY YEAR(fecha_hora_login), MONTH(fecha_hora_login)
ORDER BY anio, mes;
