Formula Unicorn: F1 Data Analytics & Relational Modeling
Formula Unicorn es un proyecto de análisis de datos estructurado sobre la base histórica de la Fórmula 1 (Ergast DB), que abarca registros desde 1950 hasta la actualidad.

Más allá de la simple extracción de estadísticas deportivas, el objetivo central de este repositorio es resolver problemas reales de arquitectura de datos: limpiar registros heredados, conciliar cambios de reglamento a lo largo de las décadas y transformar una base de datos cruda en un modelo robusto, listo para ser consumido por herramientas de Business Intelligence o entornos de Python.

Desafíos técnicos resueltos
Trabajar con más de 70 años de datos históricos requiere solucionar inconsistencias estructurales. En este proyecto se abordaron las siguientes problemáticas:

Fragmentación por cambios de reglamento: A partir de 2021, la introducción de las carreras Sprint dividió la asignación de puntos en tablas distintas. Se implementaron estructuras UNION ALL para unificar estos registros y calcular el puntaje real y absoluto de los campeonatos modernos, evitando errores de producto cartesiano.

Manejo de registros anómalos: Limpieza y estandarización de valores nulos (como los \N en tiempos de vuelta) propios de los sistemas de cronometraje de los años 50 y 60.

Lógica relacional compleja: Uso intensivo de Self-Joins para resolver consultas dependientes del contexto de una misma carrera, como identificar dobletes de escuderías o calcular diferencias de milisegundos entre el primer y segundo puesto histórico.

Arquitectura de la solución en SQL
El motor de consultas no se limita a sentencias de extracción aisladas, sino que construye una capa de preparación de datos escalable utilizando MySQL:

Tablas Temporales (CTEs): Utilizadas para aislar métricas acumuladas antes de cruzarlas con tablas dimensionales, garantizando un rendimiento óptimo en la lectura.

Capa Semántica mediante Vistas (Views): Desarrollo de una tabla diccionario virtual (vw_estados_espanol) que traduce y estandariza dinámicamente más de 130 códigos técnicos de telemetría y motivos de abandono a un vocabulario de negocio uniforme en español.

Automatización con Procedimientos Almacenados (Stored Procedures): Creación de rutinas parametrizadas que actúan como funciones backend. Permiten extraer al instante el rendimiento histórico detallado de cualquier piloto o el volumen de victorias por escudería en un año específico, sin necesidad de reescribir la lógica subyacente.

Estructura del repositorio
El código fuente está modularizado según su complejidad y función dentro de la canalización de datos:

/sql_scripts/01_exploracion_basica.sql — Consultas de reconocimiento de entidades (circuitos, escuderías, pilotos).

/sql_scripts/02_analisis_avanzado.sql — Lógica de negocio pesada, agrupaciones, subconsultas y cruces de múltiples tablas.

/sql_scripts/03_vistas_procedimientos.sql — Scripts de definición de datos (DDL) para la creación de Vistas y Stored Procedures.

Próximos pasos
Los datos modelados en esta fase de SQL servirán como base estructurada para la siguiente etapa del proyecto: la conexión directa a Power BI para la creación de cuadros de mando interactivos y la exploración predictiva utilizando Python (Pandas).

