
/*
	ETAPA 2
*/	
/*
4.	Klebsiella:
•	Cuando la infección es en:
	o	Sistema nervioso central: Aztreonam, Ceftriaxona dosis meningeas (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Boca y senos paranasales: Piperacilina/tazobactam, Aztreonam, Cefepime
	o	Pulmones: Aztreonam, Cefepime, Piperacilina/tazobactam (si sospecha broncoaspiración)
	o	Tejidos blandos: Aztreonam, Cefepime, Piperacilina/tazobactam (si hay tejido necrótico o sospecha presencia de anaerobios)
	o	Hueso: Igual a tejidos blandos, pero además Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, y se demuestra sensibilidad a estos antibioticos)
	o	Abdomen: Piperacilina/tazobactam, Cefepime (considerar adicionar Metronidazol para cubrir anaerobios)
	o	Tracto genitourinario: Aztreonam, Piperacilina/tazobactam
	o	Próstata: Aztreonam, Ceftriaxona (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Sangre: Aztreonam, Cefepime, Piperacilina/tazobactam (si se sospecha origen en abdomen)

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
			g.idBacteria IN (20) AND
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
			(dp1.idParteDelCuerpo = 1 AND a.id IN (42,32,33)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (32,33,43)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (42,50,47)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (32,42)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (32,33,44)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (32,2,3)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (32,33,44)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (32,33,45)) 
			
	) a2;

/*
•	Cuando la sensibilidad a Piperacilina/tazobactam es un numero entero o es resistente (es decir > o =), entonces Piperacilina/tazobactam) desaparece de las opciones de tratamiento, siendo entonces el análisis igual al que si fueran alérgicos a Penicilina (no importa si no son alérgicos a Penicilina).
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
				g.idBacteria IN (20) AND 
				
				(g.idAntibiotico IN (33) AND g.operador IN ('=', '>='))
		) g1,
		Asignaciones a
	WHERE
		a.id IN (42,43,44,45)
);
	

/*
•	Cuando es alérgico a Penicilina y la infección es en:
	o	Sistema nervioso central: Aztreonam, Ceftriaxona dosis meningeas (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Boca y senos paranasales: Ciprofloxacino, Tigeciclina
	o	Pulmones: Aztreonam, Ciprofloxacino, Cefepime
	o	Tejidos blandos: Aztreonam, Ciprofloxacino, Tigeciclina, Cefepime
	o	Hueso: Igual a tejidos blandos, pero además Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, y se demuestra sensibilidad a estos antibioticos)
	o	Abdomen: Cefepime, Ciprofloxacino (considerar adicionar Metronidazol para cubrir anaerobios), Tigeciclina 
	o	Tracto genitourinario: Aztreonam, Ciprofloxacino
	o	Próstata: Aztreonam, Ceftriaxona (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Sangre: Aztreonam, Cefepime, Ciprofloxacino (considerar adicionar Amikacina durante 3 dias si la función renal lo permite)


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
			g.idBacteria IN (20)
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
			(dp1.idParteDelCuerpo = 2 AND a.id IN (32,36,33)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (33,47,16)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (32,36)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (32,36,16,33)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (32,2,3)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (32,36,16,33)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (32,33,48)) 
			
	) a2;
		
	
/*
•	Cuando el test de ESBL/BLEE es positivo, y la infección es en:
	o	Sistema nervioso central: Ciprofloxacino, Imipenem, Meropenem
	o	Boca y senos paranasales: Ciprofloxacino, Ertapenem, Tigeciclina
	o	Pulmones: Ciprofloxacino, Imipenem, Meropenem
	o	Tejidos blandos: Ciprofloxacino, Tigeciclina, Ertapenem
	o	Hueso: Igual a tejidos blandos, pero Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, y se demuestra sensibilidad a estos antibioticos)
	o	Abdomen: Ciprofloxacino (considerar adicionar Metronidazol para cubrir anaerobios), Tigeciclina, Ertapenem
	o	Tracto genitourinario: Ertapenem, Ciprofloxacino, Fosfomycin (pielonefritis: 3gm cada 3 dias por 7 dosis y cistitis 3 gm dosis unica), Nitrofurantoin (solo cistitis)
	o	Próstata: Ciprofloxacino, Fosfomycin (3gm cada 3 dias por 7 dosis), Imipenem, Meropenem
	o	Sangre: Imipenem, Meropenem, Ciprofloxacino (considerar adicionar Amikacina durante 3 dias si la función renal lo permite)

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
			g.idBacteria IN (20) AND
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
		
/*
•	Cuando es resistente (es decir > o =) a algún antibiótico dentro de las opciones mencionadas, entonces ese antibiótico no puede aparecer dentro de las opciones
*/
/*
DELETE FROM InterpretacionGRAMEtapa2 WHERE idAsignacion IN (
	SELECT 
		a.idAsignacion
	FROM
		GRAM g
		
		INNER JOIN asignacionAntibiotico a
			ON (a.idAntibiotico = g.idAntibiotico)
			
	WHERE
		g.tipoGRAM = '-' AND
		g.idBacteria IN (20) AND 
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
