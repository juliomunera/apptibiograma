/*Elimina datos sonbre la tablas donde se almacenarán los resultados del análisis.*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General', 'Eliminando información de las tablas de interpretacion y TMP_GRAM.');

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
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General', 'Copiando datos a TMP_GRAM.');

INSERT INTO TMP_GRAM
	SELECT * FROM GRAM;
	
/*
	Prueba Cefoxitin Screen Positivo
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General', 'Prueba Cefoxitin Screen Positivo.');

UPDATE GRAM SET operador = '>=' WHERE tipoGRAM = '+' AND idAntibiotico = 6 AND 0 < (SELECT COUNT(1) FROM TMP_GRAM WHERE idPrueba = 3 AND valor = 1);

/*
	Prueba Resist. inducible a Clindamycin Positiva
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General', 'Prueba Resist. inducible a Clindamycin Positiva.');

UPDATE GRAM SET operador = '>=' WHERE tipoGRAM = '+' AND idAntibiotico = 2 AND 0 < (SELECT COUNT(1) FROM TMP_GRAM WHERE idPrueba = 2 AND valor = 1);


/*
Cuando algún antibiótico Aj del formulario con Aj NOT IN {Oxacilina, vancomicina}, posee un valor >=, debe salir un mensaje que dice “Germen resistente a <Aj>”.
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General', 'NOT IN {Oxacilina, vancomicina}.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g1.idBacteria, 
	1 as idAntibiotico,
	'Resistencia intrínseca a Clindamicina, Quinolonas, Trimetoprim-sulfa, Ampicilina, Penicilina y Cefalosporinas'
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
		g.idAntibiotico NOT IN (6,10,2) AND 
		g.operador = '>='
;