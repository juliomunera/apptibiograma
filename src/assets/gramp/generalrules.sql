-- Elimina datos sonbre la tablas donde se almacenarán los resultados del análisis.
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General', 'Eliminando información de la tabla InterpretacionGRAMEtapa1.');

DELETE FROM InterpretacionGRAMEtapa1;

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General','Eliminando información de la tabla InterpretacionGRAMEtapa2.');

DELETE FROM InterpretacionGRAMEtapa2;

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General','Eliminando información de la tabla InterpretacionGRAMEtapa3.');

DELETE FROM InterpretacionGRAMEtapa3;

/*****************************************
	GRAM+
******************************************/
/*
	Se va a crear una copia de GRAM para poder realizar los Updates respectivos de acuerdo con las pruebas
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General', 'Eliminando información de la tabla temporal GRAM.');

DELETE FROM TMP_GRAM;

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General', 'Ingresando información a la tabla temporal GRAM.');

INSERT INTO TMP_GRAM SELECT * FROM GRAM;
		
/*
	Prueba Cefoxitin Screen Positivo
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General', 'Actualizando Prueba Cefoxitin Screen Positivo en la tablas GRAM.');

UPDATE GRAM SET operador = '>='
WHERE tipoGRAM = '+' AND idAntibiotico = 6 AND 0 < (SELECT COUNT(1) FROM TMP_GRAM WHERE idPrueba = 3 AND valor = 1);
	
/*
	Prueba Resist. inducible a Clindamycin Positiva
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General', 'Actualizando Prueba Resist. inducible a Clindamycin Positiva en la tablas GRAM.');

UPDATE GRAM SET operador = '>=' 
WHERE tipoGRAM = '+' AND idAntibiotico = 2 AND 0 < (SELECT COUNT(1) FROM TMP_GRAM WHERE idPrueba = 2 AND valor = 1);

/*
	Cuando algún antibiótico Aj del formulario con Aj NOT IN {Oxacilina, vancomicina}, posee un valor >=, debe salir 
	un mensaje que dice “Germen resistente a <Aj>”.
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General', 'Ingresando a la tabla InterpretacionGRAMEtapa1 la sensibilidad a los gérmenes, se excluye del análisis los antibióticos Oxacilina y la Vancomicina.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	(SELECT 'Germen sensible a ' || a.nombre || '.' FROM Antibioticos a WHERE a.id = g.idAntibiotico)
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idPrueba = 1 AND
	g.idAntibiotico NOT IN (6,10) AND 
	g.operador = '>=';
	
/*
	Si Oxacilina es >= debe salir un mensaje que dice "Germen resistente a todos los beta-lactamicos, excepto a Ceftarolina" 
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-General', 'Ingresando a la tabla InterpretacionGRAMEtapa1 la resistencia de un gérmenes a los beta-lactamicosde, exceptuando a la Ceftarolina.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a todos los beta-lactamicos, excepto a Ceftarolina'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idPrueba = 1 AND
	g.idAntibiotico = 6 AND 
	g.operador = '>=';