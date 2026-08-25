USE formula_unicorn;
# 1. ¿Cuántos circuitos diferentes hay en el dataset (77)?

SELECT COUNT(DISTINCT circuitId) AS Circuitos FROM circuits;

# 2. ¿Cuántos pilotos han competido en la historia de la Fórmula 1 (861)?

SELECT COUNT(DISTINCT driverId) AS pilotos FROM drivers;

# 3. ¿Cuáles son los equipos con más victorias en la historia (Top 5)?

SELECT 
c.constructorId AS ID,
co.name AS Escuderia, 
SUM(c.wins) AS Total_wins 
FROM constructor_standings c
JOIN constructors co ON c.constructorId = co.constructorId
GROUP BY c.constructorId, co.name
ORDER BY total_wins DESC
LIMIT 5; 

# 4. ¿Qué piloto tiene la mayor cantidad de vueltas rápidas?

SELECT 
d.driverRef,
SUM(s.fastestLap) AS vueltas_rapidas
FROM sprint_results s
JOIN drivers d ON d.driverId = s.driverId
Group BY d.driverRef
ORDER BY vueltas_rapidas DESC
LIMIT 1;

# 5. ¿Qué piloto ha obtenido más podios en la historia (Hamilton 202)?

With podios AS (
	SELECT 
		driverId,
        COUNT(position) AS num_podios
	FROM results
    WHERE 
		position IN(1, 2, 3)
	GROUP BY driverId
)
SELECT 
	d.driverRef AS Piloto,
    p.num_podios AS Podios
FROM
	drivers d
    JOIN podios p ON d.driverId = p.driverId
ORDER BY 
	p.num_podios DESC
LIMIT 1;

# 6. ¿Cuáles han sido los 5 pilotos con mejor promedio de posiciones finales?

SELECT
	r.driverId,
    d.driverRef AS Piloto,
	ROUND(AVG(r.position),2) AS prom_pos,
    COUNT(position) AS carreras
FROM results r
	JOIN drivers d ON r.driverId = d.driverId
WHERE 
	r.position IS NOT NULL
    AND r.position !='N'
GROUP BY 
	r.driverId, d.driverRef
HAVING
	prom_pos IS NOT NULL
    AND carreras >= 200
ORDER BY 
	prom_pos
LIMIT 5;

# 7. ¿Qué equipo ha logrado mayor cantidad de poles position?

SELECT
	c.name AS escuderia,
    COUNT(r.grid) AS Poles
FROM
	constructors c
    JOIN results r ON c.constructorId = r.constructorId
WHERE
	r.grid = 1
GROUP BY 
	c.name
ORDER BY
	Poles DESC
LIMIT 1;

# 8. ¿Cuántos puntos ha obtenido cada equipo en una temporada específica?

SELECT
	co.name AS Equipo,
    MAX(cs.points) AS puntos,
    r.year AS año     
FROM
	constructor_standings cs
    JOIN constructors co ON cs.constructorId =  co.constructorId
    JOIN races r ON cs.raceId = r.raceId
WHERE
	r.year = 2020
GROUP BY
	co.name, r.year
ORDER BY
	puntos DESC;

# 9. ¿Qué piloto ha mejorado más posiciones desde su salida en parrilla?

SELECT
	d.driverRef AS piloto,
    ra.name AS Gran_Premio,
    ra.year AS año,
    r.grid AS posicion_salida,
    r.position AS posicion_llegada,
	r.grid - r.position AS balance_pos
FROM
	results r 
    JOIN drivers d ON r.driverId = d.driverId
    JOIN races ra ON r.raceId = ra.raceId
WHERE
	r.position IS NOT NULL
    AND r.position != '\N'
    AND r.grid>0
ORDER BY 
	balance_pos DESC LIMIT 1;
    
# 10. ¿Cuáles son los equipos con mayor cantidad de dobletes (1er y 2do puesto en una carrera)?

SELECT
	co.name AS equipo,
    COUNT(r1.raceId) AS dobletes
FROM
	results r1
    JOIN results r2 ON r1.raceId = r2.raceId
    AND r1.constructorId = r2.constructorId
	JOIN constructors co ON r1.constructorId = co.constructorId
WHERE
	r1.position = 1 AND r2.position = 2
GROUP BY 
	co.name
ORDER BY
	dobletes DESC LIMIT 5;

# 11. ¿Cuáles han sido los 5 GP con menor diferencia entre el 1er y 2do lugar?

SELECT 
	ra.name AS GP,
    ra.year AS año,
    r1.milliseconds AS p1,
    r2.milliseconds AS p2,
    (r2.milliseconds - r1.milliseconds) AS delta
FROM 
	results r1
    JOIN results r2 ON r1.raceId = r2.raceId
    JOIN races ra ON r1.raceId = ra.raceId
WHERE
	r1.position = 1 AND r2.position = 2
    AND r1.milliseconds IS NOT NULL
    AND r2.milliseconds IS NOT NULL
    AND r1.milliseconds !='\N'
    AND r2.milliseconds !='\N'
ORDER BY 
	delta LIMIT 5;
    
# 12. ¿Cuántos pilotos han participado en cada temporada?

SELECT 
    ra.year AS año,
	COUNT(DISTINCT r.driverId) AS pilotos
FROM
	results r
    JOIN races ra ON r.raceId = ra.raceId
GROUP BY
	ra.year
ORDER BY
	año DESC;


# 13. Ranking de los 5 mejores pilotos con más puntos en una temporada.

WITH puntuaciones AS(
	SELECT
		ra.year AS anio,
        r.driverId,
        SUM(r.points) AS puntos
	FROM
		results r
        JOIN races ra ON r.raceId = ra.raceId
	GROUP BY 
		ra.year, r.driverId)
SELECT
	p.anio,
    d.driverRef AS piloto,
    p.puntos
FROM
	puntuaciones p
    JOIN drivers d ON p.driverId = d.driverId
ORDER BY
	p.puntos DESC LIMIT 5;

# 14. ¿Cuántos puntos ha obtenido cada equipo?

WITH puntos_totales AS (
SELECT
	raceId,
    constructorId,
    points
FROM
	results
UNION ALL
SELECT 
	raceId,
    constructorId,
    points
FROM
	sprint_results)
SELECT
	co.name AS equipo,
    ra.year AS anio,
    SUM(p.points) AS puntos
FROM
	puntos_totales p
    JOIN races ra ON p.raceId = ra.raceId
    JOIN constructors co ON p.constructorId = co.constructorId
GROUP BY
	ra.year, co.name
ORDER BY
	puntos DESC
LIMIT 10;


# 15. Determinar la clasificación de un piloto en una carrera.
SELECT
	d.driverRef AS piloto,
	ra.year AS anio,
	r.grid AS posicion_salida,
	r.position AS posicion_final,
	r.points AS puntos_conseguidos
FROM
	results r
    JOIN drivers d ON r.driverId = d.driverId
    JOIN races ra ON r.raceId = ra.raceId
WHERE
	d.driverRef = 'alonso'
    AND ra.year = 2023
    AND ra.name = 'Monaco Grand Prix';

# 16. Crear una vista que traduzca los estados de carrera al español.

CREATE VIEW vw_estados_espanol AS
SELECT
	statusId,
    status AS estado_original,
    CASE
		WHEN status = 'Finished' THEN 'Finalizado'
		WHEN status = 'Disqualified' THEN 'Descalificado'
		WHEN status ='Accident' THEN 'Accidente'
		WHEN status = 'Collision' THEN 'Colision'
		WHEN status = 'Engine' THEN 'Fallo de motor'
		WHEN status = 'Gearbox' THEN 'Caja de cambios'
		WHEN status = 'Transmission' THEN 'Transmision'
		WHEN status = 'Clutch' THEN 'Embrague'
		WHEN status = 'Hydraulics' THEN 'Sistema hidraulico'
		WHEN status = 'Electrical' THEN 'Fallo electrico'
		WHEN status = 'Spun off' THEN 'Trompo'	
		WHEN status = 'Radiator' THEN 'Radiador'
		WHEN status = 'Suspension' THEN 'Suspensión'
		WHEN status = 'Brakes' THEN 'Frenos'
		WHEN status = 'Differential' THEN 'Diferencial'
		WHEN status = 'Overheating' THEN 'Sobrecalentamiento'
		WHEN status = 'Mechanical' THEN 'Fallo Mecánico'
		WHEN status = 'Tyre' THEN 'Neumático'
		WHEN status = 'Driver Seat' THEN 'Asiento del Piloto'
		WHEN status = 'Puncture' THEN 'Pinchazo'
		WHEN status = 'Driveshaft' THEN 'Eje de Transmisión'
		WHEN status = 'Retired' THEN 'Retirado'
		WHEN status = 'Fuel pressure' THEN 'Presión de Combustible'
		WHEN status = 'Front wing' THEN 'Alerón Delantero'
		WHEN status = 'Water pressure' THEN 'Presión de Agua'
		WHEN status = 'Refuelling' THEN 'Repostaje'
		WHEN status = 'Wheel' THEN 'Rueda'
		WHEN status = 'Throttle' THEN 'Acelerador'
		WHEN status = 'Steering' THEN 'Dirección'
		WHEN status = 'Technical' THEN 'Fallo Técnico'
		WHEN status = 'Electronics' THEN 'Electrónica'
		WHEN status = 'Broken wing' THEN 'Alerón Roto'
		WHEN status = 'Heat shield fire' THEN 'Incendio del Protector Térmico'
		WHEN status = 'Exhaust' THEN 'Escape'
		WHEN status = 'Oil leak' THEN 'Fuga de Aceite'
		WHEN status = 'Wheel rim' THEN 'Llanta'
		WHEN status = 'Water leak' THEN 'Fuga de Agua'
		WHEN status = 'Fuel pump' THEN 'Bomba de Combustible'
		WHEN status = 'Track rod' THEN 'Barra de Acoplamiento'
		WHEN status = 'Oil pressure' THEN 'Presión de Aceite'
		WHEN status = 'Withdrew' THEN 'Retirado'
		WHEN status = 'Engine fire' THEN 'Incendio de Motor'
		WHEN status = 'Tyre puncture' THEN 'Pinchazo de Neumático'
		WHEN status = 'Out of fuel' THEN 'Sin Combustible'
		WHEN status = 'Wheel nut' THEN 'Tuerca de Rueda'
		WHEN status = 'Not classified' THEN 'No Clasificado'
		WHEN status = 'Pneumatics' THEN 'Neumática'
		WHEN status = 'Handling' THEN 'Manejo del Coche'
		WHEN status = 'Rear wing' THEN 'Alerón Trasero'
		WHEN status = 'Fire' THEN 'Incendio'
		WHEN status = 'Wheel bearing' THEN 'Rodamiento de Rueda'
		WHEN status = 'Physical' THEN 'Problema Físico'
		WHEN status = 'Fuel system' THEN 'Sistema de Combustible'
		WHEN status = 'Oil line' THEN 'Conducto de Aceite'
		WHEN status = 'Fuel rig' THEN 'Equipo de Repostaje'
		WHEN status = 'Launch control' THEN 'Control de Salida'
		WHEN status = 'Injured' THEN 'Lesionado'
		WHEN status = 'Fuel' THEN 'Combustible'
		WHEN status = 'Power loss' THEN 'Pérdida de Potencia'
		WHEN status = 'Vibrations' THEN 'Vibraciones'
		WHEN status = '107% Rule' THEN 'Regla del 107%'
		WHEN status = 'Safety' THEN 'Seguridad'
		WHEN status = 'Drivetrain' THEN 'Tren Motriz'
		WHEN status = 'Ignition' THEN 'Encendido'
		WHEN status = 'Did not qualify' THEN 'No Clasificó'
		WHEN status = 'Injury' THEN 'Lesión'
		WHEN status = 'Chassis' THEN 'Chasis'
		WHEN status = 'Battery' THEN 'Batería'
		WHEN status = 'Stalled' THEN 'Motor Calado'
		WHEN status = 'Halfshaft' THEN 'Semieje'
		WHEN status = 'Crankshaft' THEN 'Cigüeñal'
		WHEN status = 'Safety concerns' THEN 'Problemas de Seguridad'
		WHEN status = 'Not restarted' THEN 'No Reinició'
		WHEN status = 'Alternator' THEN 'Alternador'
		WHEN status = 'Underweight' THEN 'Peso Insuficiente'
		WHEN status = 'Safety belt' THEN 'Cinturón de Seguridad'
		WHEN status = 'Oil pump' THEN 'Bomba de Aceite'
		WHEN status = 'Fuel leak' THEN 'Fuga de Combustible'
		WHEN status = 'Excluded' THEN 'Excluido'
		WHEN status = 'Did not prequalify' THEN 'No Preclasificó'
		WHEN status = 'Injection' THEN 'Inyección'
		WHEN status = 'Distributor' THEN 'Distribuidor'
		WHEN status = 'Driver unwell' THEN 'Piloto Indispuesto'
		WHEN status = 'Turbo' THEN 'Turbo'
		WHEN status = 'CV joint' THEN 'Junta Homocinética'
		WHEN status = 'Water pump' THEN 'Bomba de Agua'
		WHEN status = 'Fatal accident' THEN 'Accidente Fatal'
		WHEN status = 'Spark plugs' THEN 'Bujías'
		WHEN status = 'Fuel pipe' THEN 'Tubería de Combustible'
		WHEN status = 'Eye injury' THEN 'Lesión Ocular'
		WHEN status = 'Oil pipe' THEN 'Tubería de Aceite'
		WHEN status = 'Axle' THEN 'Eje'
		WHEN status = 'Water pipe' THEN 'Tubería de Agua'
		WHEN status = 'Magneto' THEN 'Magneto'
		WHEN status = 'Supercharger' THEN 'Sobrealimentador'
		WHEN status = 'Engine misfire' THEN 'Fallo de Encendido'
		WHEN status = 'Collision damage' THEN 'Daños por Colisión'
		WHEN status = 'Power Unit' THEN 'Unidad de Potencia'
		WHEN status = 'ERS' THEN 'ERS'
		WHEN status = 'Brake duct' THEN 'Conducto de Freno'
		WHEN status = 'Seat' THEN 'Asiento'
		WHEN status = 'Damage' THEN 'Daños'
		WHEN status = 'Debris' THEN 'Restos en Pista'
		WHEN status = 'Illness' THEN 'Enfermedad'
		WHEN status = 'Undertray' THEN 'Fondo Plano'
		WHEN status = 'Cooling system' THEN 'Sistema de Refrigeración'
		WHEN status = 'Finished' THEN 'Finalizado'
		WHEN status = 'Disqualified' THEN 'Descalificado'
		WHEN status = 'Accident' THEN 'Accidente'
		WHEN status = 'Collision' THEN 'Colisión'
		WHEN status = 'Engine' THEN 'Fallo de Motor'
		WHEN status = 'Gearbox' THEN 'Caja de Cambios'
		WHEN status = 'Transmission' THEN 'Transmisión'
		WHEN status = 'Clutch' THEN 'Embrague'
		WHEN status = 'Hydraulics' THEN 'Hidráulico'
		WHEN status = 'Electrical' THEN 'Fallo Eléctrico'
		WHEN status LIKE '%Lap%' THEN REPLACE(REPLACE(status, 'Laps', 'Vueltas'), 'Lap', 'Vuelta')
		ELSE status 
		END AS estado_espanol
FROM status;

# 2. Crear un stored procedure que calcule el número de victorias de un equipo en un año dado.

DELIMITER //
CREATE PROCEDURE sp_victorias_equipo_anio (
	IN p_equipo VARCHAR (100),
    IN p_anio INT
    )
BEGIN
	SELECT
		co.name AS equipo,
        ra.year AS anio,
        SUM(CASE WHEN r.position = 1 THEN 1 ELSE 0 END) AS numero_victorias
    FROM
		results r
        JOIN races ra ON r.raceId = ra.raceId
        JOIN constructors co ON r.constructorId = co.constructorId
	WHERE co.name = p_equipo
		AND ra.year = p_anio
	GROUP BY
		co.name, ra.year;
END //

DELIMITER ;

CALL sp_victorias_equipo_anio('Red Bull', 2023);

CALL sp_victorias_equipo_anio('Mercedes', 2014);

CALL sp_victorias_equipo_anio('Ferrari', 2020)



