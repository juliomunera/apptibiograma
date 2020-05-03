/*Elimina datos sonbre la tablas donde se almacenarán los resultados del análisis.*/

DELETE FROM InterpretacionGRAMEtapa1;
DELETE FROM InterpretacionGRAMEtapa2;
DELETE FROM InterpretacionGRAMEtapa3;
DELETE FROM TMP_GRAM;

/*****************************************
GRAM+
******************************************/
/*
Se va a crear una copia de GRAM para poder realizar los Updates respectivos de acuerdo con las pruebas
*/

INSERT INTO TMP_GRAM
	SELECT * FROM GRAM;
	
/*
	Prueba Cefoxitin Screen Positivo
*/

UPDATE GRAM SET operador = '>=' WHERE tipoGRAM = '+' AND idAntibiotico = 6 AND 0 < (SELECT COUNT(1) FROM TMP_GRAM WHERE idPrueba = 3 AND valor = 1);

/*
	Prueba Resist. inducible a Clindamycin Positiva
*/

UPDATE GRAM SET operador = '>=' WHERE tipoGRAM = '+' AND idAntibiotico = 2 AND 0 < (SELECT COUNT(1) FROM TMP_GRAM WHERE idPrueba = 2 AND valor = 1);


/*
Cuando es prostata o orina Y STAPHYLOCOCCUS
*/


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT DISTINCT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	1 AS idAntibiotico,
	'Descartar contaminación o bacteriemia'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria IN (2,3,4,5,6) AND 
	g.idPrueba = 1 AND
	0 < (SELECT COUNT(1) FROM DatosDelPaciente WHERE idParteDelCuerpo IN (4,6))
;


/**
sangre staphylococcus
**/
/*
Mensaje para sangre
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	h.idParteDelCuerpo, 
	g.idBacteria, 
	1 AS idAntibiotico,
	'DESCARTAR CONTAMINACION'
FROM
	(SELECT DISTINCT idbacteria FROM GRAM WHERE idBacteria IN (3,4,5,6)) g,
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp WHERE idParteDelCuerpo = 8) h

;


/*
Cuando algún antibiótico Aj del formulario con Aj NOT IN {Oxacilina, vancomicina}, posee un valor >=, debe salir un mensaje que dice “Germen resistente a <Aj>”.
Ampicilina, Penicilina 
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g1.idBacteria, 
	1 as idAntibiotico,
	'Resistencia intrínseca a Clindamicina, Quinolonas, Trimetoprim-sulfa y Cefalosporinas'
FROM
	(
		SELECT g.idBacteria, COUNT(1) as total
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '+' AND
			g.idBacteria IN (8) AND 
			g.idPrueba = 1
		GROUP BY 
			g.idBacteria
	) g1
;

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
	SELECT
		(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
		g1.idBacteria, 
		1 as idAntibiotico,
		'Resistencia intrínseca a Clindamicina, Quinolonas, Trimetoprim-sulfa y Cefalosporinas'
	FROM
		(
			SELECT g.idBacteria, COUNT(1) as total
			FROM
				GRAM g
			WHERE
				g.tipoGRAM = '+' AND
				g.idBacteria IN (7,9,10) AND 
				g.idPrueba = 1
			GROUP BY 
				g.idBacteria
		) g1
;


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
	SELECT
		(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
		g.idBacteria, 
		g.idAntibiotico,
		(SELECT 'Germen resistente a ' || a.nombre || '.' FROM Antibioticos a WHERE a.id = g.idAntibiotico)
	FROM
		GRAM g
	WHERE
		g.tipoGRAM = '+' AND
		g.idPrueba = 1 AND
		g.idAntibiotico NOT IN (6,10,2,9,4) AND 
		g.operador = '>='
;

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
		g.idPrueba = 1 AND
		g.idAntibiotico NOT IN (6,10,2,5,12,9,4) AND 
		g.operador = '='
;

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
	SELECT
		(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
		g.idBacteria, 
		g.idAntibiotico,
		'Germen resistente a Gentamicin, mediado por enzimas especificas'
	FROM
		GRAM g
	WHERE
		g.tipoGRAM = '+' AND
		g.idAntibiotico IN (4) AND 
		g.operador = '>='
;

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
	SELECT
		(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
		g.idBacteria, 
		g.idAntibiotico,
		'Germen con sensibilidad disminuida a Gentamicin, mediado por enzimas especificas'
	FROM
		GRAM g
	WHERE
		g.tipoGRAM = '+' AND
		g.idAntibiotico IN (4) AND 
		g.operador = '='
;


