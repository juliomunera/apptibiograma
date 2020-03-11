
INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	31 AS idAntibiotico,
	'Germen intrinsecamente resistente a Colistina, Tigeciclina e Imipenem'
FROM
	(
		SELECT distinct
			idBacteria
		FROM
			GRAM 
		WHERE
			tipoGRAM = '-' AND
			idBacteria IN (29)
	) g ;	
	

/*
	ETAPA 2
*/	
/*
1.	E.coli y Proteus mirabilis:
•	Cuando la infección es en:
	o	Sistema nervioso central: Aztreonam, Ceftriaxona dosis meningeas (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Boca y senos paranasales: Ampicilina/sulbactam, Piperacilina/tazobactam
	o	Pulmones: Aztreonam, Cefazolina, Ampicilina/sulbactam o Piperacilina/tazobactam (si sospecha broncoaspiración)
	o	Tejidos blandos: Aztreonam, Cefazolina, Ampicilina/sulbactam o Piperacilina/tazobactam (si hay tejido necrótico o sospecha presencia de anaerobios)
	o	Hueso: Igual a tejidos blandos, pero además Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, y se demuestra sensibilidad a estos antibioticos)
	o	Abdomen: Ampicilina/sulbactam, Piperacilina/tazobactam
	o	Tracto genitourinario: Aztreonam, Cefazolina, Ampicilina/sulbactam o Piperacilina/tazobactam
	o	Próstata: Aztreonam, Ceftriaxona (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Sangre: Aztreonam, Cefazolina, Ampicilina/sulbactam o Piperacilina/tazobactam (si se sospecha origen en abdomen)

*/

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
			g.tipoGRAM = '-' AND
			g.idBacteria IN (19,29) AND
			0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idPrueba = 4 AND g2.valor IN (0,3))
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (32,2,3)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (4,42)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (32,9,4,43,33)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (4,42,50)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (32,9,4,42,36,21,33,18,37)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (32,9,4,44,33)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (32,36,22,39,37/*,2,3*/)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (32,9,51,44,33)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (32,9,4,45,36,33)) 
			
	) a2;
	
DELETE FROM InterpretacionGRAMEtapa2 WHERE idAsignacion in (42,43,44,45) AND 0 < (SELECT COUNT(1) FROM InterpretacionGRAMEtapa1 WHERE mensaje like 'Germen sensible a todo el panel de%');

/*
•	Cuando la sensibilidad a Ampicilina/sulbactam es un numero entero o es resistente (es decir > o =), pero Cefazolina sigue siendo sensible (es decir < o =) 
	entonces este antibiótico (Ampicilina/sulbactam) desaparece de las opciones de tratamiento
*/

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
				g.tipoGRAM = '-' AND
				g.idBacteria IN (19,29) AND 
				
				(g.idAntibiotico IN (35) AND g.operador IN ('=', '>=')) AND
				0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico IN (23) AND g2.operador IN ('<='))
		) g1,
		Asignaciones a
	WHERE
		a.id IN (4,5,6)
);
	
/*
•	Cuando la sensibilidad a Ampicilina/sulbactam y Cefazolina son un numero entero o son resistentes (es decir > o =), pero Piperacilina/tazobactam sigue siendo sensible (es decir < o =) 
	entonces estos dos antibióticos (Ampicilina/sulbactam y Cefazolina) desaparecen de las opciones de tratamiento
*/	

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
				g.tipoGRAM = '-' AND
				g.idBacteria IN (19,29) AND 
				
				(g.idAntibiotico IN (35) AND g.operador IN ('=', '>=')) AND
				0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico IN (23) AND g2.operador IN ('=','>=')) AND
				0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico IN (33) AND g2.operador IN ('<='))
		) g1,
		Asignaciones a
	WHERE
		a.id IN (4,5,6,9)
);
	
/*
•	Cuando la sensibilidad a Ampicilina/sulbactam, Cefazolina y Piperacilina/tazobactam son un numero entero o son resistentes (es decir > o =), 
	estos tres antibióticos (Ampicilina/sulbactam, Cefazolina y Piperacilina/tazobactam) desaparecen de las opciones de tratamiento, 
	siendo entonces el análisis igual al que si fueran alérgicos a Penicilina (no importa si no son alérgicos a Penicilina).
*/

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
				g.tipoGRAM = '-' AND
				g.idBacteria IN (19,29) AND 
				
				(g.idAntibiotico IN (35) AND g.operador IN ('=', '>=')) AND
				0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico IN (23) AND g2.operador IN ('=','>=')) AND
				0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico IN (33) AND g2.operador IN ('=','>='))
		) g1,
		Asignaciones a
	WHERE
		a.id IN (4,5,6,9,42,43,44,45)
);

/*
1.	E.coli y Proteus mirabilis:
•	Cuando es alérgico a Penicilina y la infección es en:
	o	Sistema nervioso central: Aztreonam, Ceftriaxona dosis meningeas (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Boca y senos paranasales: Ciprofloxacino, Tigeciclina (excepto si es Proteus)
	o	Pulmones: Aztreonam, Cefazolina, Ciprofloxacino
	o	Tejidos blandos: Aztreonam, Cefazolina, Ciprofloxacino, Tigeciclina (excepto si es Proteus)
	o	Hueso: Igual a tejidos blandos, pero además Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, y se demuestra sensibilidad a estos antibioticos)
	o	Abdomen: Ciprofloxacino (considerar adicionar Metronidazol para cubrir anaerobios), Tigeciclina (excepto si es Proteus)
	o	Tracto genitourinario: Aztreonam, Cefazolina, Ciprofloxacino
	o	Próstata: Aztreonam, Ceftriaxona (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Sangre: Aztreonam, Cefazolina, Ciprofloxacino (considerar adicionar Amikacina durante 3 dias si la función renal lo permite)

*/

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
			g.tipoGRAM = '-' AND
			g.idBacteria IN (19,29)
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (32,2,3)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (36,16)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (32,9,36)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (47,16)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (32,9,36)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (32,9,36,16)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (32,36,22/*,2,3*/)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (32,9,36,16)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (32,9,48)) 
			
	) a2;
		
	
/*
1.	E.coli y Proteus mirabilis:
•	Cuando el test de ESBL/BLEE es positivo, y la infección es en:
	o	Sistema nervioso central: Ciprofloxacino, Imipenem (excepto si es Proteus), Meropenem
	o	Boca y senos paranasales: Ciprofloxacino, Ertapenem, Tigeciclina
	o	Pulmones: Ciprofloxacino, Imipenem (excepto si es Proteus), Meropenem
	o	Tejidos blandos: Ciprofloxacino, Tigeciclina (excepto si es Proteus), Ertapenem
	o	Hueso: Igual a tejidos blandos, pero Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, y se demuestra sensibilidad a estos antibioticos)
	o	Abdomen: Ciprofloxacino (considerar adicionar Metronidazol para cubrir anaerobios), Tigeciclina (excepto si es Proteus), Ertapenem
	o	Tracto genitourinario: Ertapenem, Ciprofloxacino, Fosfomycin (pielonefritis: 3gm cada 3 dias por 7 dosis y cistitis 3 gm dosis unica), Nitrofurantoin (solo cistitis)
	o	Próstata: Ciprofloxacino, Fosfomycin (3gm cada 3 dias por 7 dosis), Imipenem (excepto si es Proteus), Meropenem
	o	Sangre: Imipenem (excepto si es Proteus), Meropenem, Ciprofloxacino (considerar adicionar Amikacina durante 3 dias si la función renal lo permite)
*/

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
			g.tipoGRAM = '-' AND
			g.idBacteria IN (19,29) AND
			0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idPrueba = 4 AND g2.valor = 1)
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (36,39,40)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (36,37,16)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (36,39,40)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (47,16,37)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (37,36,18,21)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (36,16,37)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (36,22,39,40)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (36,16,37)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (39,40,48)) 
			
	) a2;
	
	
/**
Cuando los anteriores estan bloqueados
**/

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
			g.tipoGRAM = '-' AND
			g.idBacteria IN (19,29) AND
			0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (13,35) AND operador IN ('=', '>=')) AND
			0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (23) AND operador IN ('=', '>=')) AND
			0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (33) AND operador IN ('=', '>=')) AND
			0 >= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (27) AND operador IN ('=', '>='))
	) g1,
	(
		SELECT
			dp1.idParteDelCuerpo,
			a.id,
			a.comentariosTratamiento
		FROM
			(SELECT idParteDelCuerpo FROM DatosDelPaciente) dp1,
			Asignaciones a
		WHERE
			(dp1.idParteDelCuerpo = 1 AND a.id IN (37,36)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (33,36)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (37,16,47)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (37,36,18,21)) OR 
			(dp1.idParteDelCuerpo = 5 AND a.id IN (37,36)) OR
		/*	(dp1.idParteDelCuerpo = 6 AND a.id IN (36,22)) OR*/
			(dp1.idParteDelCuerpo = 7 AND a.id IN (37,36)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (33,39))
	) a2;

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
			g.tipoGRAM = '-' AND
			g.idBacteria IN (19,29) AND
			0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (13,35) AND operador IN ('=', '>=')) AND
			0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (23) AND operador IN ('=', '>=')) AND
			0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (33) AND operador IN ('=', '>=')) AND
			0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (27) AND operador IN ('=', '>='))
	) g1,
	(
		SELECT
			dp1.idParteDelCuerpo,
			a.id,
			a.comentariosTratamiento
		FROM
			(SELECT idParteDelCuerpo FROM DatosDelPaciente) dp1,
			Asignaciones a
		WHERE
			(dp1.idParteDelCuerpo = 1 AND a.id IN (37,36)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (33,36)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (37,16,39)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (37,36,18,21)) OR 
			(dp1.idParteDelCuerpo = 5 AND a.id IN (37,36)) OR
		/*	(dp1.idParteDelCuerpo = 6 AND a.id IN (36,22)) OR*/
			(dp1.idParteDelCuerpo = 7 AND a.id IN (37,36)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (33,39))
	) a2;
	
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
			g.tipoGRAM = '-' AND
			g.idBacteria IN (19,29) AND
			0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (13,35) AND operador IN ('=', '>=')) AND
			0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (23) AND operador IN ('<=')) AND
			0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (33) AND operador IN ('=', '>='))
	) g1,
	(
		SELECT
			dp1.idParteDelCuerpo,
			a.id,
			a.comentariosTratamiento
		FROM
			(SELECT idParteDelCuerpo FROM DatosDelPaciente) dp1,
			Asignaciones a
		WHERE
			(dp1.idParteDelCuerpo = 1 AND a.id IN (9,36)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (9,36)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (36)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (9,36)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (47,37))
			
	) a2;
	


/*
•	Cuando es resistente (es decir > o =) a algún antibiótico dentro de las opciones mencionadas, entonces ese antibiótico no puede aparecer dentro de las opciones
*/
/*
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Ecoli-Etapa2', 'Eliminando Antibioticos resistentes.');

DELETE FROM InterpretacionGRAMEtapa2 WHERE idAsignacion IN (
	SELECT 
		a.idAsignacion
	FROM
		GRAM g
		
		INNER JOIN asignacionAntibiotico a
			ON (a.idAntibiotico = g.idAntibiotico)
			
	WHERE
		g.tipoGRAM = '-' AND
		g.idBacteria IN (19,29) AND 
		g.operador IN ('>=') AND
		a.idAntibiotico > 1
);
*/



/**
primero agregamos tige y luego eliminamos piptazo 
**/
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
			g.tipoGRAM = '-' AND
			g.idBacteria IN (20) AND
			0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idPrueba = 4 AND g2.valor = 0) AND
			0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico IN (24,25,16) AND operador IN ('=', '>=')) 
	) g1,
	(
		SELECT
			dp1.idParteDelCuerpo,
			a.id,
			a.comentariosTratamiento
		FROM
			(SELECT idParteDelCuerpo FROM DatosDelPaciente) dp1,
			Asignaciones a
		WHERE
			(dp1.idParteDelCuerpo = 0 AND a.id IN (36,39,40)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (36,37,16)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (36,39,40)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (47,16,37)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (37,36,18,21)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (36,16,37)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (36,22,39,40)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (36,16,37)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (39,40,48)) 
	) a2;

DELETE FROM InterpretacionGRAMEtapa2 WHERE idAsignacion IN (42,43,44,45) AND 0 < (
	SELECT COUNT(1)
	FROM GRAM g
	WHERE
		g.tipoGRAM = '-' AND
			g.idBacteria IN (20) AND
			0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idPrueba = 4 AND g2.valor = 0) AND
			0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico IN (24,25,16) AND operador IN ('=', '>=')) 
		
);
