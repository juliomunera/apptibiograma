/*
ETAPA 1
*/	

/*
Cuando todos los antibióticos sean sensibles (es decir ≤), debe salir un mensaje que diga “Germen sensible a todo el panel de antibióticos”
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Streptococcus-Etapa1','Todos sensibles.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g1.idBacteria, 
	1 as idAntibiotico,
	'Germen sensible a todo el panel de antibióticos'
FROM
	(
		SELECT g.idBacteria, COUNT(1) as total
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '+' AND
			g.idBacteria IN (11,12,13,14,15,16,17,18) AND 
			g.idPrueba = 1 AND
			((g.operador = '<=') OR (g.idAntibiotico IN (5,12) AND g.operador = '='))
		GROUP BY 
			g.idBacteria
	) g1
	INNER JOIN (
		SELECT COUNT(1) as total
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '+' AND
			g.idBacteria IN (11,12,13,14,15,16,17,18) AND 
			g.idPrueba = 1
	) g2
		ON (g1.total = g2.total)
;

/*
Cuando algún antibiótico es un numero entero (es decir =), debe salir un mensaje que diga “Germen con sensibilidad disminuida a ese <Aj>” 
(siempre y cuando no sea para todo el panel de antibióticos, debe salir mensaje por cada Aj que cumpla con la condición)
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Streptococcus-Etapa1','Algun antibiotico =.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	(SELECT 'Germen con sensibilidad disminuida a ' || a.nombre || '.' FROM Antibioticos a WHERE a.id = g.idAntibiotico)
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria IN (11,12,13,14,15,16,17,18) AND 
	g.idPrueba = 1 AND
	
	g.idAntibiotico NOT IN (5,12,6) AND 
	g.operador = '='
;

/*
	ETAPA 2: Streptococcus
*/	
/*
	Cuando es sensible a Penicilina y la infección es en:
		* Sistema nervioso central: 0
			- 	Penicilina (dosis de meníngeas) 
			- 	Ampicilina (dosis meníngeas)
			- 	Ceftriaxona (si Albumina >3.5)
			- 	Cefotaxime (si Albumina <3.5)
		* Boca y senos paranasales: 1
			- 	Ampicilina/sulbactam
		* Pulmones: 2
			- 	Ampicilina/sulbactam
		* Tejidos blandos: 7
			- 	Ampicilina/sulbactam 
		* Hueso: 5
			- 	Ampicilina/sulbactam 
			- 	Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis)
		* Abdomen: 3
			- 	Ampicilina/sulbactam
		* Tracto genitourinario: 4
			- 	Ampicilina
			- 	Ampicilina/sulbactam 
		* Próstata: 6
			- 	Penicilina (dosis meníngeas)
			- 	Ampicilina (dosis meníngeas)
		* Sangre: 8
			- 	Penicilina
			- 	Ampicilina
			- 	Ampicilina/sulbactam
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Streptococcus-Etapa2','Ingresando la asignación de medicamentos (ARK) cuando el pacientes es sensible a la Penicilina.');

INSERT INTO InterpretacionGRAMEtapa2 (idParteDelCuerpo, idBacteria, idAntibiotico, idAsignacion, mensaje)	
SELECT
	a2.idParteDelCuerpo, 
	g1.idBacteria, 
	6 as idAntibiotico,
	a2.id,
	a2.comentariosTratamiento
FROM
	(
		SELECT DISTINCT 
			g.idBacteria
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '+' AND
			g.idBacteria IN (11,12,13,14,15,16,17) AND
			
			((g.idAntibiotico IN (14,17,18) AND g.operador = '<='))
	) g1,
	(
		SELECT
			dp1.idParteDelCuerpo,
			a.id,
			a.comentariosTratamiento
		FROM
			(SELECT idParteDelCuerpo FROM DatosDelPaciente WHERE esAlergicoAPenicilina = 0) dp1,
			Asignaciones a
		WHERE
			(dp1.idParteDelCuerpo = 0 AND a.id IN (17,23,2,3)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id = 4) OR
			(dp1.idParteDelCuerpo = 2 AND a.id = 4) OR
			(dp1.idParteDelCuerpo = 3 AND a.id = 4) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (20,4)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (4)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (17,23)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id = 4) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (24,20,4)) 
	) a2;
	
/*
	Cuando es resistente a Penicilina debe aparecer un mensaje que diga “confirmar con un laboratorio de referencia”.
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Streptococcus-Etapa2','Ingresando la asignación de medicamentos (ARK) cuando el pacientes es resistente a la Penicilina.');

INSERT INTO InterpretacionGRAMEtapa2 (idParteDelCuerpo, idBacteria, idAntibiotico, idAsignacion, mensaje)	
SELECT
	a2.idParteDelCuerpo, 
	g1.idBacteria, 
	6 as idAntibiotico,
	a2.id,
	a2.comentariosTratamiento
FROM
	(
		SELECT DISTINCT 
			g.idBacteria
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '+' AND
			g.idBacteria IN (11,12,13,14,15,16,17) AND
			
			((g.idAntibiotico IN (14,17,18) AND g.operador = '>='))
	) g1,
	(
		SELECT
			dp1.idParteDelCuerpo,
			a.id,
			a.comentariosTratamiento
		FROM
			(SELECT idParteDelCuerpo FROM DatosDelPaciente WHERE esAlergicoAPenicilina = 0) dp1,
			Asignaciones a
		WHERE
			(dp1.idParteDelCuerpo = 0 AND a.id = 26) OR
			(dp1.idParteDelCuerpo = 1 AND a.id = 26) OR
			(dp1.idParteDelCuerpo = 2 AND a.id = 26) OR
			(dp1.idParteDelCuerpo = 3 AND a.id = 26) OR
			(dp1.idParteDelCuerpo = 4 AND a.id = 26) OR
			(dp1.idParteDelCuerpo = 5 AND a.id = 26) OR
			(dp1.idParteDelCuerpo = 6 AND a.id = 26) OR
			(dp1.idParteDelCuerpo = 7 AND a.id = 26) OR
			(dp1.idParteDelCuerpo = 8 AND a.id = 26) 
	) a2;
	
	
/*
	Cuando es alérgico a Penicilina y la infección es en:
		* Sistema nervioso central: 0
			- 	Ceftriaxona (si Albumina >3.5)
			- 	Cefotaxime (si Albumina <3.5)
			- 	Daptomicina
		* Boca y senos paranasales: 1
			- 	Tigeciclina
			- 	Clindamicina
		* Pulmones: 2
			- 	Vancomicina
			- 	Linezolide
		* Tejidos blandos: 7
			- 	Vancomicina
			- 	Clindamicina (si hay tejido necrótico o sospecha presencia de anaerobios)
		* Hueso: 5
			- 	Vancomicina
			- 	Daptomicina
			- 	Clindamicina
			- 	Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, pero no combinar con Clindamicina)
		* Abdomen: 3
			- 	Clindamicina
			- 	Tigeciclina
		* Tracto genitourinario: 4
			- 	Fosfomycin (pielonefritis: 3gm cada 3 dias por 7 dosis y cistitis 3 gm dosis unica)
			- 	Nitrofurantoin (solo cistitis)
			- 	Vancomicina
		* Próstata: 6
			- 	Fosfomycin (3gm cada 3 dias por 7 dosis)
			- 	Ceftriaxona (si Albumina >3.5)
			- 	Cefotaxime (si Albumina <3.5)
		* Sangre: 8
			- 	Vancomicina
			- 	Daptomicina
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Streptococcus-Etapa2','Ingresando la asignación de medicamentos (ARK) cuando el pacientes es alérgico a la Penicilina.');

INSERT INTO InterpretacionGRAMEtapa2 (idParteDelCuerpo, idBacteria, idAntibiotico, idAsignacion, mensaje)	
SELECT
	a2.idParteDelCuerpo, 
	g1.idBacteria, 
	6 as idAntibiotico,
	a2.id,
	a2.comentariosTratamiento
FROM
	(
		SELECT DISTINCT 
			g.idBacteria
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '+' AND
			g.idBacteria IN (11,12,13,14,15,16,17) 
	) g1,
	(
		SELECT
			dp1.idParteDelCuerpo,
			a.id,
			a.comentariosTratamiento
		FROM
			(SELECT idParteDelCuerpo FROM DatosDelPaciente WHERE esAlergicoAPenicilina = 1) dp1,
			Asignaciones a
		WHERE
			(dp1.idParteDelCuerpo = 0 AND a.id IN (2,3,10)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (12,16)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (11,13)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (12,16)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (18,21,13)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (13,10,12)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (18,2,3)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (13,15)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (13,10)) 
	) a2;
		
/*
	**Cuando es resistente a Clindamicina y alérgico a Penicilina, no puede aparecer Clindamicina entre las opciones de tratamiento 
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Streptococcus-Etapa2','Eliminando de la asignación de medicamentos (ARK) la Clindamicina.');

DELETE FROM InterpretacionGRAMEtapa2 WHERE idAsignacion IN (
	SELECT 
		a.id
	FROM
		(
			SELECT DISTINCT 
				g.idBacteria
			FROM
				GRAM g
			WHERE
				g.tipoGRAM = '+' AND
				g.idBacteria = 8 AND 
				(g.idAntibiotico = 2 AND g.operador = '>=') AND
				0 < (SELECT count(1) FROM DatosDelPaciente WHERE esAlergicoAPenicilina = 1)
		) g1,
		Asignaciones a
	WHERE
		a.id IN (12,15)
);