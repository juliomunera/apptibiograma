/*
	ETAPA 2
*/	
/*
3.	Salmonella y Shigella:
•	Cuando Ciprofloxacino y Ceftazidima son sensibles (es decir < o =), y la infección es en:
	o	Sistema nervioso central: Ciprofloxacino, Ceftriaxona dosis meningeas (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Boca y senos paranasales: Ciprofloxacino, Ceftriaxona (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Pulmones: Ciprofloxacino, Ceftriaxona (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Tejidos blandos: Ciprofloxacino, Ceftriaxona (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Hueso: Igual a tejidos blandos, pero además Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, y se demuestra sensibilidad a estos antibioticos)
	o	Abdomen: Ciprofloxacino, Ceftriaxona (si Albumina >3.5), Cefotaxime (si Albumina <3.5), considerar adicionar Metronidazol para cubrir anaerobios
	o	Tracto genitourinario: Ciprofloxacino, Ceftriaxona (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Próstata: Ciprofloxacino, Ceftriaxona (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
	o	Sangre: Ciprofloxacino, Ceftriaxona (si Albumina >3.5), Cefotaxime (si Albumina <3.5)
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Salmonella-Etapa2', 'Ingresando la asignación de medicamentos (ARk) cuando 3.	Salmonella y Shigella.');

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
			g.idBacteria IN (32,33) AND
			0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico IN (25) AND g2.operador IN ('<=')) AND
			0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico IN (27) AND g2.operador IN ('<='))
			
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (36,2,3)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (36,2,3)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (36,2,3)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (36,2,3,46)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (36,2,3)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (36,2,3)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (36,2,3)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (36,2,3)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (36,2,3)) 
			
	) a2;




/*
•	Cuando Ciprofloxacina o Ceftazidima son números enteros o son resistentes (es decir > o =), ese antibiótico no aparece dentro de las opciones, 
	se cambia por Imipenem, Meropenem, quitando lo que aparece resaltado en abdomen
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Salmonella-Etapa2', 'Ingresando la asignación de medicamentos (ARk) cuando 1.	E.coli y Proteus mirabilis.');

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
			g.idBacteria IN (32,33) AND
			0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico IN (27,25) AND g2.operador IN ('=', '>='))
			
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (39,40,2,3)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (39,40,2,3)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (39,40,2,3)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (39,40,2,3)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (39,40,2,3)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (39,40,2,3)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (39,40,2,3)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (39,40,2,3)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (39,40,2,3)) 
			
	) a2;
	
		
/*
•	Cuando es resistente (es decir > o =) a algún antibiótico dentro de las opciones mencionadas, entonces ese antibiótico no puede aparecer dentro de las opciones
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Salmonella-Etapa2', 'Eliminando Antibioticos resistentes.');

DELETE FROM InterpretacionGRAMEtapa2 WHERE idAsignacion IN (
	SELECT 
		a.idAsignacion
	FROM
		GRAM g
		
		INNER JOIN asignacionAntibiotico a
			ON (a.idAntibiotico = g.idAntibiotico)
			
	WHERE
		g.tipoGRAM = '-' AND
		g.idBacteria IN (32,33) AND 
		g.operador IN ('>=') AND
		a.idAntibiotico > 1
);
