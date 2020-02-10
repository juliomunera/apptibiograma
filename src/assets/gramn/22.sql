
INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	31 AS idAntibiotico,
	'Germen intrinsecamente resistente a Colistina'
FROM
	(
		SELECT distinct
			idBacteria
		FROM
			GRAM 
		WHERE
			tipoGRAM = '-' AND
			idBacteria IN (21)
	) g ;	
	

/**
cuando no haya opciones, bloqueados (=, >=):
Ciprofloxacin
imi
mero
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
	0 < (SELECT COUNT(1) FROM GRAM WHERE operador IN ('=', '>=') AND idAntibiotico IN (27)) AND
	0 < (SELECT COUNT(1) FROM GRAM WHERE operador IN ('=', '>=') AND idAntibiotico IN (30)) AND
	0 < (SELECT COUNT(1) FROM GRAM WHERE operador IN ('=', '>=') AND idAntibiotico IN (31)) AND
	(a2.idParteDelCuerpo = 8 OR 0 < (SELECT COUNT(1) FROM GRAM WHERE operador IN ('=', '>=') AND idAntibiotico IN (9))) AND
	(a2.idParteDelCuerpo NOT IN (1,3,7) OR 0 < (SELECT COUNT(1) FROM GRAM WHERE operador IN ('=', '>=') AND idAntibiotico IN (34)))
;


/*
	ETAPA 2
*/	
/*
2.	Serratia, Enterobacter, Citrobacter, Aeromonas, Morganella, Proteus vulgaris, Proteus penneri, Acinetobacter y Providencia:

•	Cuando la infección es en:
	o	Sistema nervioso central: Ciprofloxacino, Meropenem, Imipenem (excepto si es Proteus, Providencia y Morganella)
	o	Boca y senos paranasales: Ciprofloxacino, Ertapenem, Tigeciclina (excepto si es Providencia, Morganella y cualquiera de los Proteus)
	o	Pulmones: Ciprofloxacino, Imipenem (excepto si es Proteus, Providencia y Morganella), Meropenem
	o	Tejidos blandos: Ciprofloxacino, Tigeciclina (excepto si es Providencia, Morganella y cualquiera de los Proteus), Imipenem (excepto si es Proteus, Providencia y Morganella), Meropenem
	o	Hueso: Igual a tejidos blandos, pero Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, y se demuestra sensibilidad a estos antibioticos)
	o	Abdomen: Ciprofloxacino (considerar adicionar Metronidazol para cubrir anaerobios), Tigeciclina (excepto si es Providencia, Morganella y cualquiera de los Proteus), Ertapenem, Imipenem (excepto si es Proteus, Providencia y Morganella), Meropenem
	o	Tracto genitourinario: Ertapenem, Ciprofloxacino, Fosfomycin (pielonefritis: 3gm cada 3 dias por 7 dosis y cistitis 3 gm dosis unica), Nitrofurantoin (solo cistitis)
	o	Próstata: Ciprofloxacino, Fosfomycin (3gm cada 3 dias por 7 dosis), Imipenem (excepto si es Proteus, Providencia y Morganella), Meropenem
	o	Sangre: Imipenem (excepto si es Proteus, Providencia y Morganella), Meropenem, Ciprofloxacino (considerar adicionar Amikacina durante 3 dias si la función renal lo permite)

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
			g.idBacteria IN (21,22,24,25,28) AND 
			0 >= (SELECT count(1) FROM GRAM WHERE idAntibiotico IN (30) AND operador IN ('=','>='))
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (36,40,39,30)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (36,37,16,30)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (36,40,39,30)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (47,37,40,39,16,30)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (37,36,18,21,30)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (36,39,30)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (36,22,40,39,30)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (36,40,39,16,30)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (40,48,39)) 
			
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
			g.idBacteria IN (21,22,24,25,28) AND 
			0 < (SELECT count(1) FROM GRAM WHERE idAntibiotico IN (30) AND operador IN ('=','>='))
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (36,40,39,30)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (36,37,16,30)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (36,40,39,30)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (47,37,40,39,16,30)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (37,36,18,21,30)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (36,40,30)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (36,22,40,39,30)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (36,40,39,16,30)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (40,48,39)) 
			
	) a2;
/*
•	Cuando es resistente (es decir > o =) a algún antibiótico dentro de las opciones mencionadas, entonces ese antibiótico no puede aparecer dentro de las opciones
*/
/*
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-2Serriata-Etapa2', 'Eliminando Antibioticos resistentes.');

DELETE FROM InterpretacionGRAMEtapa2 WHERE idAsignacion IN (
	SELECT 
		a.idAsignacion
	FROM
		GRAM g
		
		INNER JOIN asignacionAntibiotico a
			ON (a.idAntibiotico = g.idAntibiotico)
			
	WHERE
		g.tipoGRAM = '-' AND
		g.idBacteria IN (21,22,24,25,28) AND 
		g.operador IN ('>=') AND
		a.idAntibiotico > 1
);
*/


/*
si es resistente a cipro entonces solo aparece imi, pero si imi es resistente entonces mero
*/

DELETE FROM InterpretacionGRAMEtapa2 WHERE idAsignacion IN (39,40) AND 0 < (
SELECT
	COUNT(1)
FROM
	GRAM
WHERE
	idAntibiotico IN (27) AND operador IN ('=', '>=')
);

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
			g.idBacteria IN (21,22,24,25,28) AND 
			0 >= (SELECT count(1) FROM GRAM WHERE idAntibiotico IN (30) AND operador IN ('=','>='))
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
			a.id IN (39)
			
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
			g.idBacteria IN (21,22,24,25,28) AND 
			0 < (SELECT count(1) FROM GRAM WHERE idAntibiotico IN (30) AND operador IN ('=','>='))
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
			a.id IN (40)
			
	) a2;

/*
imi y mero no van cuando es sensible a todo el panel
*/
DELETE FROM InterpretacionGRAMEtapa2 WHERE idAsignacion IN (39,40) AND 0 < (
SELECT
	COUNT(1)
FROM
	(
		SELECT g.idBacteria, COUNT(1) as total
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '-' AND
			g.idPrueba = 1 AND
			g.operador = '<='
		GROUP BY 
			g.idBacteria
	) g1
	INNER JOIN (
		SELECT COUNT(1) as total
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '-' AND
			g.idPrueba = 1
	) g2
	ON (g1.total = g2.total)
);


