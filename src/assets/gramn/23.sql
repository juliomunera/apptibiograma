
INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	31 AS idAntibiotico,
	'Germen intrinsecamente resistente a Tigeciclina'
FROM
	(
		SELECT distinct
			idBacteria
		FROM
			GRAM 
		WHERE
			tipoGRAM = '-' AND
			idBacteria IN (23)
	) g ;	
	

/**
cuando no haya opciones, bloqueados (=, >=):
cefepime o ceftazidime
Ciprofloxacin
imi, mero
**/

INSERT INTO InterpretacionGRAMEtapa2 (idParteDelCuerpo, idBacteria, idAntibiotico, idAsignacion, mensaje)
SELECT
	a2.idParteDelCuerpo, 
	(SELECT DISTINCT idBacteria FROM GRAM) as idBacteria, 
	6 as idAntibiotico,
	a2.id,
	a2.comentariosTratamiento
FROM
	(
		SELECT
			dp1.idParteDelCuerpo,
			a.id,
			a.comentariosTratamiento
		FROM
			(SELECT idParteDelCuerpo FROM DatosDelPaciente) dp1,
			Asignaciones a
		WHERE
			a.id IN (52,53)
			
	) a2
	
	INNER JOIN (
		SELECT g.idBacteria, COUNT(1) as total
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '-' AND
			g.idPrueba = 1 AND
			g.operador IN ('=', '>=')
		GROUP BY 
			g.idBacteria
	) g1 ON ( 1 = 1 )
	INNER JOIN (
		SELECT COUNT(1) as total
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '-' AND
			g.idPrueba = 1
	) g2
	ON (g1.total <> g2.total)
	
	
WHERE
	0 < (SELECT COUNT(1) FROM GRAM WHERE operador IN ('=', '>=') AND idAntibiotico IN (24,25)) AND
	0 < (SELECT COUNT(1) FROM GRAM WHERE operador IN ('=', '>=') AND idAntibiotico IN (27)) AND
	0 < (SELECT COUNT(1) FROM GRAM WHERE operador IN ('=', '>=') AND idAntibiotico IN (30)) AND
	0 < (SELECT COUNT(1) FROM GRAM WHERE operador IN ('=', '>=') AND idAntibiotico IN (31))
;



/*
	ETAPA 2
*/	

/*
•	Cuando la sensibilidad a Ceftazidime y/o Cefepime son un numero entero o son resistentes (es decir > o =), 
	el análisis igual al que si fueran productores de ESBL/BLEE (no importa si el test es negativo).
*/	

UPDATE GRAM SET valor = 1
WHERE tipoGRAM = '-' AND idPrueba = 4 AND 0 < (SELECT COUNT(1) FROM TMP_GRAM WHERE idAntibiotico IN (24,25) AND operador IN ('=','>='));

/*
6.	Pseudomonas:
•	Cuando la infección es en:
	o	Sistema nervioso central: Aztreonam, Cefepime, Meropenem
	o	Boca y senos paranasales: Aztreonam, Cefepime, Piperacilina/tazobactam
	o	Pulmones: Aztreonam, Cefepime, Piperacilina/tazobactam (si sospecha broncoaspiración)
	o	Tejidos blandos: Aztreonam, Cefepime, Piperacilina/tazobactam (si hay tejido necrótico o sospecha presencia de anaerobios)
	o	Hueso: Igual a tejidos blandos, pero además Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, y se demuestra sensibilidad a estos antibioticos)
	o	Abdomen: Cefepime, Piperacilina/tazobactam
	o	Tracto genitourinario: Aztreonam, Cefepime, Piperacilina/tazobactam
	o	Próstata: Aztreonam, Cefepime
	o	Sangre: Cefepime, Piperacilina/tazobactam (si se sospecha origen en abdomen)

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
			g.idBacteria IN (23) AND
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (33,40)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (32,33,42)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (32,33,43)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (33,42,47)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (32,33,42)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (32,33,44)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (32,33)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (32,33,44)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (33,45)) 
			
	) a2;

/*
•	Cuando la sensibilidad a Piperacilina/tazobactam es un numero entero o es resistente (es decir > o =), pero Ceftazidima y Cefepime siguen siendo sensibles (es decir < o =) 
	entonces Piperacilina/tazobactam desaparece de las opciones de tratamiento, y es reemplazada por Cefepime (muchas veces puede ya estar como opción) -33
*/

UPDATE InterpretacionGRAMEtapa2 SET idAsignacion = 33, mensaje = 'Cefepime' WHERE idAsignacion IN (
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
				g.idBacteria IN (23) AND 
				
				(g.idAntibiotico IN (33) AND g.operador IN ('=', '>=')) AND
				0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico IN (24) AND g2.operador IN ('<=')) AND
				0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico IN (25) AND g2.operador IN ('<='))
		) g1,
		Asignaciones a
	WHERE
		a.id IN (44,45)
);


/*
•	Cuando es alérgico a Penicilina y la infección es en:
	o	Sistema nervioso central: Aztreonam, Cefepime, Meropenem
	o	Boca y senos paranasales: Aztreonam, Cefepime, Ciprofloxacino
	o	Pulmones: Aztreonam, Cefepime, Ciprofloxacino
	o	Tejidos blandos: Aztreonam, Ciprofloxacino, Cefepime
	o	Hueso: Igual a tejidos blandos, pero además Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, y se demuestra sensibilidad a estos antibioticos)
	o	Abdomen: Ciprofloxacino (considerar adicionar Metronidazol para cubrir anaerobios), Cefepime
	o	Tracto genitourinario: Aztreonam, Ciprofloxacino, Cefepime
	o	Próstata: Aztreonam, Cefepime, Ciprofloxacino 
	o	Sangre: Cefepime, Meropenem, Ciprofloxacino (considerar adicionar Amikacina durante 3 dias si la función renal lo permite)
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
			g.idBacteria IN (23)
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (32,33,40)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (32,33,36)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (32,33,36)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (33,47)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (32,33,36)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (32,33,36)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (32,33,36)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (32,33,36)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (33,40,48))  
			
	) a2;
		
	
/*
•	Cuando el test de ESBL/BLEE es positivo, y la infección es en:
	o	Sistema nervioso central: Ciprofloxacino, Imipenem, Meropenem
	o	Boca y senos paranasales: Ciprofloxacino, Meropemem, Imipenem
	o	Pulmones: Ciprofloxacino, Imipenem, Meropenem
	o	Tejidos blandos: Ciprofloxacino, Imipenem, Meropenem
	o	Hueso: Igual a tejidos blandos, pero Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, y se demuestra sensibilidad a estos antibioticos)
	o	Abdomen: Ciprofloxacino (considerar adicionar Metronidazol para cubrir anaerobios), Imipenem, Meropenem 
	o	Tracto genitourinario: Ciprofloxacino, Imipenem, Meropenem, Fosfomycin (pielonefritis: 3gm cada 3 dias por 7 dosis y cistitis 3 gm dosis unica), Nitrofurantoin (solo cistitis)
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
			g.idBacteria IN (23) AND
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
			(dp1.idParteDelCuerpo = 1 AND a.id IN (36,39,40)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (36,39,40)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (47,39,40)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (36,39,40,22,21)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (36,39,40)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (36,22,39,40)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (36,39,40)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (39,40,48)) 
			
	) a2;
		
/*
• Cuando es resistente (es decir > o =) a algún antibiótico dentro de las opciones mencionadas, entonces ese antibiótico no puede aparecer dentro de las opciones
*/
/*
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Pseudomonas-Etapa2', 'Eliminando Antibioticos resistentes.');

DELETE FROM InterpretacionGRAMEtapa2 WHERE idAsignacion IN (
	SELECT 
		a.idAsignacion
	FROM
		GRAM g
		
		INNER JOIN asignacionAntibiotico a
			ON (a.idAntibiotico = g.idAntibiotico)
			
	WHERE
		g.tipoGRAM = '-' AND
		g.idBacteria IN (23) AND 
		g.operador IN ('>=') AND
		a.idAntibiotico > 1
);*/
