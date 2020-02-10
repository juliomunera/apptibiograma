
INSERT INTO InterpretacionGRAMEtapa2 (idParteDelCuerpo, idBacteria, idAntibiotico, idAsignacion, mensaje)
SELECT
	a2.idParteDelCuerpo, 
	g1.idBacteria, 
	6 as idAntibiotico,
	a2.id,
	a2.comentariosTratamiento
FROM
	(
		SELECT g.idBacteria, COUNT(1) as total
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '-' AND
			g.operador IN ('=', '>=') AND
			g.idBacteria IN (27) AND
			g.idPrueba = 1 AND
			g.idAntibiotico IN (9)
		GROUP BY 
			g.idBacteria
	) g1
	
	INNER JOIN
	(
		SELECT
			dp1.idParteDelCuerpo,
			a.id,
			a.comentariosTratamiento
		FROM
			(SELECT idParteDelCuerpo FROM DatosDelPaciente) dp1,
			Asignaciones a
		WHERE
			a.id IN (54)
			
	) a2 ON (1 = 1);





/*
	ETAPA 2
*/	
/*
5.	Stenotrophomonas:
•	Cuando es sensible a Trimetoprim/sulfa (es decir < o =), esta es la única opción a ofrecer para todos los órganos

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
			g.idBacteria IN (27) AND
			
			g.idAntibiotico = 9 AND g.operador = '<='
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (30)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (30)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (30)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (30)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (30)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (30)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (30)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (30)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (30)) 
			
	) a2;

/*
5.	Stenotrophomonas:
•	Cuando Trimetoprim/sulfa es un número entero o es resistente (es decir > o =), se debe ofrecer la opción de Ciprofloxacino y Tigeciclina en combinación

*/

/*
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Stenotrophomonas-Etapa2', 'Ingresando la asignación de medicamentos (ARk) cuando 5.Stenotrophomonas');

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
			g.idBacteria IN (27) AND
			
			g.idAntibiotico = 9 AND g.operador IN ('=','>=')
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (16,36)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (16,36)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (16,36)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (16,36)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (16,36)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (16,36)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (16,36)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (16,36)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (16,36)) 
			
	) a2;*/
