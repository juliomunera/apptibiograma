/*
	ETAPA 1
*/	
/*
	Se evalua que sea sensible a todo el panel de antibioticos
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1','Ingresando el mensaje que indica la sensibilidad de todo el panel de antibióticos.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g1.idBacteria, 
	1 as idAntibiotico,
	'Germen Sensible a todo el panel de antibióticos'
FROM
	(
		SELECT g.idBacteria, COUNT(1) as total
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '+' AND
			g.idBacteria IN (2,3,4,5,6) AND 
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
			g.idBacteria IN (2,3,4,5,6) AND 
			g.idPrueba = 1
	) g2
		ON (g1.total = g2.total);

/*
	Cuando algún antibiótico Aj del formulario con Aj NOT IN {Linezolide, Daptomicina, Oxacilina}, posee un valor entero
	(es decir =), debe salir un mensaje que dice “Germen con sensibilidad disminuida a ese <Aj>”. 
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1','Ingresando el mensaje que indica la sensibilidad disminuida de algunos antibióticos usados para el tratamiento de la familia de bacterias Staphylococcus. Se excluyen el Linezolide, Daptomicina y Oxacilina.');

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
	g.idBacteria IN (2,3,4,5,6) AND 
	g.idPrueba = 1 AND
	g.idAntibiotico NOT IN (5,12,6) AND 
	g.operador = '=';
	
/*
	Cuando Aj del formulario con Aj in {Oxacilina} es un numero entero (es decir =), debe salir un mensaje que diga 
	“Realizar test de Cefoxitin”.
		
		Si test a Cefoxitin = positivo debe salir un mensaje que diga “Germen resistente a todos los beta-lactamicos, excepto 
		a Ceftarolina”
		
		Si test a Cefoxitin = negativo, debe salir un mensaje que diga “Germen con sensibilidad disminuida a Oxacilina, 
		mediada por BLA-Z”
		
	Si el test (test de Cefoxitin) no tiene alguna selección (positivo o negativo) se debe asumir como resultado del 
	test de Cefoxitin = negativo y se debe colocar mensaje de que se va a asumir como negativo dado que no ingreso algún valor. Lo anterior cuando le de clic en continuar. 

*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1', 'Actualizando el resultado de la prueba Cefoxitin a negativo.');

UPDATE GRAM SET valor = 0 
WHERE idPrueba = 3 AND 0 < (SELECT COUNT(1) FROM TMP_GRAM WHERE idPrueba = 3 AND COALESCE(valor, -1) < 0);

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1', 'Ingresando a la tabla InterpretacionGRAMEtapa1 el mensaje que indica que se asume como negativo los resultados de la prueba de Cefoxitin debido a que no se le diligenció un valor.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Se asume Test de Cefoxitin = Negativo debido a que no fue ingresado algun valor (Positivo o Negativo)'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria IN (2,3,4,5) AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 6 AND 
	g.operador = '=' AND
	0 < (SELECT count(1) FROM TMP_GRAM g2 WHERE g2.idPrueba = 3 AND COALESCE(g2.valor, -1) < 0);

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1', 'Ingresando el mensaje que indica que se debe realizar la prueba de Cefoxitin.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Realizar test de Cefoxitin'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria IN (2,3,4,5) AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 6 AND 
	g.operador = '=' AND
	0 < (SELECT count(1) FROM TMP_GRAM g2 WHERE g2.idPrueba = 3 AND COALESCE(g2.valor, -1) < 0);

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1', 'Ingresando el mensaje que indica que el gérmen es resistente a todos los beta-lactamicos, excepto a Ceftarolina.');

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
	g.idBacteria IN (2,3,4,5) AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 6 AND 
	g.operador = '=' AND
	0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idPrueba = 3 AND COALESCE(g2.valor, -1) = 1);

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1', 'Ingresando el mensaje que indica que el gérmen tiene sensibilidad disminuida a Oxacilina, mediada por BLA-Z.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Oxacilina, mediada por BLA-Z'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria IN (2,3,4,5) AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 6 AND 
	g.operador = '=' AND
	0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idPrueba = 3 AND COALESCE(g2.valor, -1) = 0);

/*
	Cuando el antibiotico Aj = Clidamicina  es sensible pero resistente o con sensibilidad disminuida a Eritromicina 
	(Aj = Eritromicina con signo = o >=), debe salir un mensaje que diga “Realizar D-test o Test de resistencia inducible 
	a Clindamicina”.
	
		Si Aj D-test = positivo OR Test de resistencia inducible a Clindamicina = positivo, debe salir un mensaje que diga 
		“Germen con resistencia inducible a Clindamicina, mediado por MLSb”
		Si Aj D-test = negativo OR Test de resistencia inducible a Clindamicina = negativo, debe salir un mensaje que diga 
		“Germen sensible Clindamicina”

	Si el test (D-test o Test de resistencia inducible a Clindamicina) no tiene alguna selección (positivo o negativo) se 
	debe asumir como resultado del Test de resistencia inducible a Clindamicina = negativo y se debe colocar mensaje de 
	que se va a asumir como negativo dado que no ingreso algún valor.

	Lo anterior cuando le de clic en continuar.
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1', 'Actualizando el resultado de la prueba de resistencia inducible a Clindamicina a negativo.');

UPDATE GRAM SET valor = 0 
WHERE idPrueba = 2 AND 0 < (SELECT COUNT(1) FROM TMP_GRAM WHERE idPrueba = 2 AND COALESCE(valor, -1) < 0);

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1', 'Ingresando el mensaje que indica que se asume como negativo los resultados de la prueba de resistencia inducible a Clindamicina debido a que no se le diligenció un valor.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Se asume Test de resistencia inducible a Clindamicina = Negativo debido a que no fue ingresado algun valor (Positivo o Negativo)'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria IN (2,3,4,5) AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 2 AND 
	g.operador = '<=' AND
	0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico = 3 AND g2.operador IN ('=','>=')) AND
	0 < (SELECT count(1) FROM TMP_GRAM g2 WHERE g2.idPrueba = 2 AND COALESCE(g2.valor, -1) < 0);

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1', 'Ingresando el mensaje que indica que se debe realizar la prueba de resistencia inducible a Clindamicina.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Realizar D-test o Test de resistencia inducible a Clindamicina'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria IN (2,3,4,5) AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 2 AND 
	g.operador = '=' AND
	0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico = 3 AND g2.operador IN ('=','>=')) AND
	0 < (SELECT count(1) FROM TMP_GRAM g2 WHERE g2.idPrueba = 2 AND COALESCE(g2.valor, -1) < 0);

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1', 'Ingresando  el mensaje que indica que el gérmen presenta resistencia inducible a Clindamicina, mediado por MLSb.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con resistencia inducible a Clindamicina, mediado por MLSb'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria IN (2,3,4,5) AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 2 AND 
	g.operador = '=' AND
	0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico = 3 AND g2.operador IN ('=','>=')) AND
	0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idPrueba = 2 AND COALESCE(g2.valor, -1) = 1);

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1', 'Ingresando el mensaje que indica que el gérmen es sensible a la Clindamicina.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen sensible Clindamicina'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria IN (2,3,4,5) AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 2 AND 
	g.operador = '=' AND
	0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idAntibiotico = 3 AND g2.operador IN ('=','>=')) AND
	0 < (SELECT count(1) FROM GRAM g2 WHERE g2.idPrueba = 2 AND COALESCE(g2.valor, -1) = 0);
	
/*
	Cuando en el Aj = Vancomicina es un numero entero (es decir =), debe salir un mensaje que diga “Germen con sensibilidad 
	disminuida a Vancomicina, mediada por engrosamiento de la pared"
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1', 'Ingresando el mensaje que indica que el gérmen presenta sensibilidad disminuida a Vancomicina, mediada por engrosamiento de la pared.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Vancomicina, mediada por engrosamiento de la pared'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria IN (2,3,4,5,6) AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 10 AND 
	g.operador = '=';

/*
	Cuando en el Aj = Vancomicina es resistente (es decir ≥) debe salir un mensaje que diga “Posible germen resistente a 
	Vancomicina, por favor corrobore con un laboratorio de referencia”
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa1', 'Ingresando el mensaje que indica que el gérmen posiblemente es resistente a Vancomicina por lo que se debe corroborar con un laboratorio de referencia.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Posible germen resistente a Vancomicina, por favor corrobore con un laboratorio de referencia'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria IN (2,3,4,5,6) AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 10 AND 
	g.operador = '>=';

/*
	ETAPA 2
*/	
/*
	Cuando es sensible a Oxacilina (<=) o “Cefoxitin screen”= negativo, y la infección es en (ubicacionBacteria):
		* Sistema nervioso central:  0
			- Oxacilina
			- Ceftriaxona (si Albumina >3.5)
			- Cefotaxime (si Albumina <3.5)
		* Boca y senos paranasales: 1
			- Ampicilina/sulbactam
		* Pulmones: 2
			- Oxacilina
			- Cefazolina
			- Ampicilina/sulbactam (si sospecha broncoaspiración)
		* Tejidos blandos: 7
			- Oxacilina
			- Cefazolina
			- Ampicilina/sulbactam (si hay tejido necrótico o sospecha presencia de anaerobios)
		* Hueso:   5
			- Oxacilina
			- Cefazolina
			- Ampicilina/sulbactam (si hay tejido necrótico o sospecha presencia de anaerobios)
			- Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis)
		* Abdomen: 3
			- Ampicilina/sulbactam
		* Tracto genitourinario: 4
			- Debe salir un letrero que diga: ”Descartar bacteriemia o contaminación”
		* Próstata: 6
			- Debe salir un letrero que diga: “Descartar bacteriemia o contaminación”
		* Sangre: 8
			- Oxacilina
			- Cefazolina 
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa2', 'Ingresando la asignación de medicamentos (ARk) cuando el germen es sensible a la Oxacilina o los resultados de la prueba de Cefoxitin son negativos.');

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
			g.idBacteria IN (2,3,4,5,6) AND 
			((g.idAntibiotico = 6 AND g.operador = '<=') OR (g.idPrueba = 3 AND g.valor = 0))
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (1,2,3)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id = 4) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (1,9,5)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id = 4) OR
			(dp1.idParteDelCuerpo = 4 AND a.id = 8) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (1,9,6,7)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id = 8) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (1,9,6)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (1,9)) 
			
	) a2;
	
/*
	Si  Oxacilina  es >=, y si la infección es en: [O si “Cefoxitin screen”= positivo]
		* Sistema nervioso central: 0
			- Daptomicina
			- Linezolide
		* Boca y senos paranasales: 1
			- Clindamicina
			- Vancomicina
			- [cuando solo aparezca la opción Vancomicina, es decir, se elimino clindamicina por D-test positivo, colocar 
			Linezolide]
		* Pulmones: 2
			- Vancomicina
			- Linezolide
			- Ceftaroline 
		* Tejidos blandos: 7
			- Vancomicina
			- Linezolide
			- Clindamicina (si hay tejido necrótico o sospecha presencia de anaerobios)
		* Hueso: 5
			- Vancomicina
			- Daptomicina
			- Clindamicina (si hay tejido necrótico o sospecha presencia de anaerobios)
			- Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis)
		* Abdomen: 3
			- Clindamicina
			- Tigeciclina
			- [cuando solo aparezca la opción Tigeciclina, es decir, se elimino clindamicina por D-test positivo, colocar 
			Linezolide]
		* Tracto genitourinario: 4
			- Debe salir un letrero que diga: ”Descartar bacteriemia o contaminación”
		* Próstata: 6
			- Debe salir un letrero que diga: “Descartar bacteriemia o contaminación”
		* Sangre: 8
			- Vancomicina
			- Daptomicina
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa2', 'Ingresando la asignación de medicamentos (ARk) cuando el germen es resistente a la Oxacilina o los resultados de la prueba de Cefoxitin son positivos.');

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
			g.idBacteria IN (2,3,4,5,6) AND 
			
			((g.idAntibiotico = 6 AND g.operador = '>=') OR (g.idPrueba = 3 AND g.valor = 1))
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (10,11)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (12,13)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (11,13,14)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (12,16)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id = 8) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (10,13,15,7)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id = 8) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (11,13,15)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (10,13)) 
	) a2;

/*
	Cuando es alérgico a Penicilina (snPenicilina = 1) y la infección es en:
		* Sistema nervioso central: 0
			- Ceftriaxona (si Albumina >3.5)
			- Cefotaxime (si Albumina <3.5)
			- Daptomicina (agregar)
		* Boca y senos paranasales: 1
			- Clindamicina
			- Vancomicina
		* Pulmones: 2
			- Vancomicina 
			- Linezolide
			- Cefazolina 
		* Tejidos blandos: 7
			- Vancomicina
			- Cefazolina
			- Clindamicina (si hay tejido necrótico o sospecha presencia de anaerobios)
		* Hueso: 5
			- Vancomicina
			- Cefazolina
			- Clindamicina (si hay tejido necrótico o sospecha presencia de anaerobios)
			- Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis)
		* Abdomen: 3
			- Clindamicina
			- Tigeciclina
		* Tracto genitourinario: 4
			- Debe salir un letrero que diga: ”Descartar bacteriemia o contaminación”
		* Próstata: 6
			- Debe salir un letrero que diga: “Descartar bacteriemia o contaminación”
		* Sangre: 8
			- Vancomicina
			- Cefazolina
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa2', 'Ingresando la asignación de medicamentos (ARk) cuando el paciente es alérgico a la penicilina.');

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
			g.idBacteria IN (2,3,4,5,6)
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (2,3,10)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (12,13)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (11,13,14)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (12,16)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id = 8) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (9,13,15,7)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id = 8) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (9,13,15)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (9,13)) 
	) a2;
	
/*
	** Si (D-test = positivo OR Test de resistencia inducible a Clindamicina=positivo), quita Clidamicina de todas las 
	opciones donde aparece.
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa2', 'Eliminando de la asignación de medicamentos (ARk) la Clidamicina si los resultados de la prueba de resistencia inducible a Clindamicina son positivos.');

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
				g.tipoGRAM = '+' AND
				g.idBacteria IN (2,3,4,5,6) AND 
				
				(g.idPrueba IN (2) AND g.valor = 1)
		) g1,
		Asignaciones a
	WHERE
		a.id IN (12,15)
);

/*
	Si  Oxacilina  es >=, y si la infección es en: [O si “Cefoxitin screen”= positivo]

		* Boca y senos paranasales: 1
			- Clindamicina
			- Vancomicina
			- [cuando solo aparezca la opción Vancomicina, es decir, se elimino clindamicina por D-test positivo, colocar 
			Linezolide]

		* Abdomen: 3
			- Clindamicina
			- Tigeciclina
			- [cuando solo aparezca la opción Tigeciclina, es decir, se elimino clindamicina por D-test positivo, colocar 
			Linezolide]
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-Staphylocuccus-Etapa2', 'Ingresando la asignación de medicamentos (ARk) si la Oxacilina es resistente o si los resultados de la prueba Cefoxitin son positivos.');

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
			g.idBacteria IN (2,3,4,5,6) AND 
			
			(g.idPrueba IN (2) AND g.valor = 1)
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
			(dp1.idParteDelCuerpo = 1 AND a.id IN (11)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (11))
			
	) a2;