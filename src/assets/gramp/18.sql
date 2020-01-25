/*
ETAPA 1
*/	

/*
Cuando todos los antibióticos sean sensibles (es decir ≤), debe salir un mensaje que diga “Germen sensible a todo el panel de antibióticos”
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-StreptococcusPneumoniae-Etapa1','Sensible a todos.');

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
VALUES ('GRAMPositivo-StreptococcusPneumoniae-Etapa1','Alguno entero.');

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
	ETAPA 2: Streptococcus pneumoniae
*/	
/*
	Cuando es sensible a Penicilina (alguna de las dos penicilinas?: Respuesta alguna ) y la infección es en:
		* 	Sistema nervioso central: 
			- Penicilina (dosis de meníngeas)
			- Ampicilina (dosis meníngeas)
			- Ceftriaxona (si Albumina >3.5)
			- Cefotaxime (si Albumina <3.5)
		* 	Boca y senos paranasales: 
			- Ampicilina/sulbactam
		* 	Pulmones: 
			- Ampicilina/sulbactam
		* 	Tejidos blandos: 
			- Ampicilina/sulbactam 
		* 	Hueso: 
			- Ampicilina/sulbactam 
			- Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis)
		* 	Abdomen: 
			- Ampicilina/sulbactam
		* 	Tracto genitourinario: 4
			- Debe aparecer un letrero que diga “descartar bacteriemia”
		* 	Próstata: 6
			- Debe aparecer un letrero que diga “descartar bacteriemia” 
		* 	Sangre: 8
			- Penicilina
			- Ampicilina
			- Ampicilina/sulbactam
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-StreptococcusPneumoniae-Etapa2','Ingresando la asignación de medicamentos (ARK) cuando el pacientes es sensible a la Penicilina.');

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
			g.idBacteria = 18 AND
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
			(dp1.idParteDelCuerpo = 4 AND a.id = 27) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (4)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (27)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id = 4) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (24,20,4)) 
	) a2;
	
/*
	Cuando la sensibilidad a Penicilina es un numero entero (es decir, no tiene < o >) o es resistente (o sea > o =) o es 
	alérgico a Penicilina, pero es sensible a Cefotaxime (es decir <=), y la infección es en: Equivalente a: 
	Si ( penicilina es = o >= o alérgico a penicilina) y (cefotaxime <=)
		* 	Sistema nervioso central: 0
			- Ceftriaxona (si Albumina >3.5)
			- Cefotaxime (si Albumina <3.5)
			- Daptomicina
			- Linezolide
		* 	Boca y senos paranasales: 1
			- Clindamicina
			- Tigeciclina
		* 	Pulmones: 2
			- Ceftriaxona (si Albumina >3.5)
			- Cefotaxime (si Albumina <3.5)
			- Linezolide
		* 	Tejidos blandos: 7
			- Ceftriaxona (si Albumina >3.5)
			- Cefotaxime (si Albumina <3.5)
			- Clindamicina
		* 	Hueso: 5
			- Ceftriaxona (si Albumina >3.5)
			- Cefotaxime (si Albumina <3.5)
			- Clindamicina 
			- Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, pero no combinar con Clindamicina)
		* 	Abdomen: 3
			- Clindamicina
			- Tigeciclina
		* 	Tracto genitourinario: 4
			- Debe aparecer un letrero que diga “Descartar bacteriemia”
		* 	Próstata: 6
			- Debe aparecer un letrero que diga “Descartar bacteriemia”
		* 	Sangre: 8
			- Ceftriaxona (si Albumina >3.5)
			- Cefotaxime (si Albumina <3.5)
			- Vancomicina
			- Daptomicina
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-StreptococcusPneumoniae-Etapa2','Ingresando la asignación de medicamentos (ARK) cuando el paciente tiene sensibilidad a la Penicilina o es resistente a la Penicilina o es alérgico a Penicilina, pero es sensible al Cefotaxime.');

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
			g.idBacteria IN (18) AND
			
			(	(g.idAntibiotico IN (14,17,18) AND g.operador IN ('=', '>=')) OR
				0 < (SELECT count(1) FROM DatosDelPaciente WHERE esAlergicoAPenicilina = 1) 
			) AND 
			0 < (SELECT count(1) FROM GRAM WHERE g.tipoGRAM = '+' AND g.idBacteria = 18 AND g.idAntibiotico IN (19,20) AND g.operador IN ('<='))
	) g1,
	(
		SELECT
			dp1.idParteDelCuerpo,
			a.id,
			a.comentariosTratamiento
		FROM
			(SELECT idParteDelCuerpo FROM DatosDelPaciente ) dp1,
			Asignaciones a
		WHERE
			(dp1.idParteDelCuerpo = 0 AND a.id IN (2,3,10,11)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (12,16)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (2,3,11)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (12,16)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id = 27) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (2,3,12)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id = 27) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (2,3,12)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (2,3,13,10)) 
	) a2;

/*
	Cuando es resistente o alérgico a Penicilina, y la sensibilidad a Cefotaxime es un numero entero o es 
	resistente (es decir = o > =), y la infección es en:
		* 	Sistema nervioso central: 0
			- Daptomicina
			- Linezolide
		* 	Boca y senos paranasales: 1
			- Clindamicina
			- Tigeciclina
		* 	Pulmones: 2
			- Vancomicina
			- Linezolide
		* 	Tejidos blandos: 7 
			- Vancomicina
			- Clindamicina
		* 	Hueso: 5
			- Vancomicina
			- Clindamicina
			- Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, pero no combinar con Clindamicina)
		* 	Abdomen: 3 
			- Clindamicina
			- Tigeciclina
		* 	Tracto genitourinario: 4
			- Debe aparecer un letrero que diga “Descartar bacteriemia”
		* 	Próstata: 6
			- Debe aparecer un letrero que diga “Descartar bacteriemia”
		* 	Sangre: 8
			- Vancomicina
			- Daptomicina

*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-StreptococcusPneumoniae-Etapa2','Ingresando la asignación de medicamentos (ARK) cuando el paciente es resistente a la Penicilina o es alérgico a Penicilina, pero es resistente al Cefotaxime.');

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
			g.idBacteria = 18 AND
			(	(g.idAntibiotico IN (14,17,18) AND g.operador IN ('=', '>=')) OR
				0 < (SELECT count(1) FROM DatosDelPaciente WHERE esAlergicoAPenicilina = 1) 
			) AND 
			0 < (SELECT count(1) FROM GRAM WHERE g.tipoGRAM = '+' AND g.idBacteria = 18 AND g.idAntibiotico IN (19,20) AND g.operador IN ('=', '>='))
	) g1,
	(
		SELECT
			dp1.idParteDelCuerpo,
			a.id,
			a.comentariosTratamiento
		FROM
			(SELECT idParteDelCuerpo FROM DatosDelPaciente ) dp1,
			Asignaciones a
		WHERE
			(dp1.idParteDelCuerpo = 0 AND a.id IN (10,11)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (12,16)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (13,11)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (12,16)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id = 27) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (12,13)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id = 27) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (12,13)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (13,10)) 
	) a2;