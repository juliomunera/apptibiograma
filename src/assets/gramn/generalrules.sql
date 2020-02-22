-- Elimina datos sonbre la tablas donde se almacenarán los resultados del análisis.

DELETE FROM InterpretacionGRAMEtapa1;

DELETE FROM InterpretacionGRAMEtapa2;

DELETE FROM InterpretacionGRAMEtapa3;


/*****************************************
GRAM-
******************************************/
/*
	Se va a crear una copia de GRAM para poder realizar los Updates respectivos de acuerdo con las pruebas
*/

DELETE FROM TMP_GRAM;

INSERT INTO TMP_GRAM SELECT * FROM GRAM;

INSERT INTO GRAM(idBacteria,idAntibiotico,idPrueba,operador,valor,tipoGRAM) 
SELECT 
	g1.idBacteria,
	1 as idAntibiotico,
	4 as idPrueba,
	'<=' as operador,
	3 as valor,
	'-' as tipoGRAM
FROM
	(SELECT DISTINCT idBacteria FROM TMP_GRAM) g1
WHERE
	0 >= (SELECT COUNT(1) FROM TMP_GRAM WHERE idPrueba = 4)
;

DELETE FROM TMP_GRAM;
INSERT INTO TMP_GRAM SELECT * FROM GRAM;



/*****
Actualizacion del valor de BLEE cuando alguno de CEFXX es = o >=
*****/
UPDATE GRAM SET valor = 1 WHERE valor = 3 AND idPrueba = 4 AND 0 < (SELECT COUNT(1) FROM TMP_GRAM WHERE idAntibiotico IN (24,25,16) AND operador IN ('=', '>='));



/*
	Cuando todos los antibióticos sean sensibles (es decir ?), debe salir un mensaje que diga “Germen sensible a todo 
	el panel de antibióticos”, 
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g1.idBacteria, 
	1 as idAntibiotico,
	'Germen sensible a todo el panel de antibióticos'
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
	ON (g1.total = g2.total);


/**
Se elimina el grupo de 4 de el grupo de serratia dado que ya no aplica para analisis
**/
DELETE FROM GRAM WHERE idAntibiotico IN (24,25,16,35) AND idBacteria IN (21,22,24,25,28);
DELETE FROM GRAM WHERE idAntibiotico IN (24,25,16,35) AND idBacteria IN (34,31,30,26); /** nuevos agregados**/
DELETE FROM GRAM WHERE idAntibiotico IN (35) AND idBacteria IN (20);


/*
	pero si se trata de los siguientes gérmenes: Serratia, Enterobacter, Citrobacter, Aeromonas, Proteus penneri, Proteus 
	vulgaris, Morganella, Acinetobacter y Providencia; debe decir además “Germen sensible a todo el panel de antibióticos, 
	pero productor de AMP-C y por ende resistente a todos los beta-lactámicos excepto Carbapenems”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g1.idBacteria, 
	1 as idAntibiotico,
	'Germen productor de AMP-C (resistente a todos los beta-lactámicos excepto Carbapenems)'
FROM
	(
		SELECT g.idBacteria, COUNT(1) as total
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '-' AND
			g.idPrueba = 1 AND
			g.operador = '<=' AND
			g.idBacteria IN (21,22,24,25,31,30,26,28,34)
		GROUP BY 
			g.idBacteria
	) g1;
	
/* Mensaje siempre*/
	
INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g1.idBacteria, 
	1 as idAntibiotico,
	'Germen intrinsecamente resistente a Ampicilina y Ampicilina/sulbactam'
FROM
	(
		SELECT g.idBacteria, COUNT(1) as total
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '-' AND
			g.idPrueba = 1
		GROUP BY 
			g.idBacteria
	) g1
WHERE
	g1.idBacteria IN (20) AND
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (24,25,16,33,22) and operador IN ('=','>='));
	
/*
	Cuando algún antibiótico es un numero entero (es decir =), debe salir un mensaje que dice “Germen con sensibilidad 
	disminuida a ese antibiótico” (22,13,21,4,28,29,9,11,37,23,25,26,27,16,32,33,31 y 34).
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	(SELECT 'Germen con sensibilidad disminuida a ' || a.nombre || '.' FROM Antibioticos a WHERE a.id = g.idAntibiotico)
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico NOT IN (4,21,27,9,11,34,13,35,22,33,23,24,25,16,31,30,32,28) AND
	g.operador = '=';
	
/*
	Cuando algún antibiótico es resistente (es decir ?), debe salir un mensaje que dice “Germen resistente a ese antibiótico”,
	y por ende no puede aparecer (queda bloqueado) en las opciones de tratamiento [este bloqueo se debe validar en cada
	antibiotico para saber cual es su equivalente]
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	(SELECT 'Germen resistente a ' || a.nombre || '.' FROM Antibioticos a WHERE a.id = g.idAntibiotico)
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico NOT IN (4,21,27,9,11,34,13,35,22,33,23,24,25,16,31,30,32,28) AND
	g.operador = '>=';
	
/*
	2.	Amikacina:
	*	Cuando es un numero entero (es decir =), debe salir un mensaje que dice “Germen con sensibilidad disminuida a 
		Amikacina, mediado por	enzimas específicas”
	*	Cuando es resistente (es decir ?), debe salir un mensaje que dice “Germen resistente a Amikacina, mediado por 
		enzimas especificas´”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Amikacina, mediado por enzimas específicas'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 21 AND
	g.operador = '=';


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Amikacina, mediado por enzimas especificas'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 21 AND
	g.operador = '>=';
	
/*
	3.	Gentamicina:
	*	Cuando es un numero entero (es decir =), debe salir un mensaje que dice “Germen con sensibilidad disminuida a
		Gentamicina, mediado por enzimas específicas”
	*	Cuando es resistente (es decir ?), debe salir un mensaje que dice “Germen resistente a Gentamicina, mediado por
		enzimas específicas”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Gentamicina, mediado por enzimas específicas'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 4 AND
	g.operador = '=';


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Gentamicina, mediado por enzimas específicas'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 4 AND
	g.operador = '>=';

/*
	4.	Ciprofloxacina:
	*	Cuando es un numero entero (es decir =), debe salir un mensaje que dice “Germen con sensibilidad disminuida a 
		Ciprofloxacina, mediado por mutación del gen gyr-A”
	*	Cuando es resistente (es decir ?), debe salir un mensaje que dice “Germen resistente a Ciprofloxacina, mediado
	 	por mutación del gen gyr-A,	par-C y/o bombas de eflujo”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Ciprofloxacina, mediado por mutación del gen gyr-A'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 27 AND
	g.operador = '=';


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Ciprofloxacina, mediado por mutación del gen gyr-A, par-C y/o bombas de eflujo'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 27 AND
	g.operador = '>=';

/*
	5.	Trimetoprim sulfa:
	*	Cuando es un numero entero (es decir =), debe salir un mensaje que dice “Germen con sensibilidad disminuida a 
		Trimetoprim-sulfa, mediado por disminución en la afinidad enzimática” 
	*	Cuando es resistente (es decir ?), debe salir un mensaje que dice “Germen resistente a Trimetoprim-sulfa, mediado por disminución en la afinidad enzimatica”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Trimetoprim-sulfa, mediado por disminución en la afinidad enzimática'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 9 AND
	g.operador = '=';


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Trimetoprim-sulfa, mediado por disminución en la afinidad enzimática'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 9 AND
	g.operador = '>=';

/*
	6.	Nitrofurantoina:
	*	Cuando es un numero entero (es decir =), debe salir un mensaje que dice “Germen con sensibilidad disminuida a 
		Nitrofurantoina, mediado por cambios enzimática”
	*	Cuando es resistente (es decir ?), debe salir un mensaje que dice “Germen resistente a Nitrofurantoina, mediado
		por cambios enzimáticos”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Nitrofurantoina, mediado por cambios enzimáticos'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 11 AND
	g.operador = '=';


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Nitrofurantoina, mediado por cambios enzimáticos'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 11 AND
	g.operador = '>=';		
	
/*
	7.	Tigeciclina:
	*	Cuando es un numero entero (es decir =), debe salir un mensaje que dice “Germen con sensibilidad disminuida a 
		Tigeciclina, mediado por bombas de eflujo”
	*	Cuando es resistente (es decir ?), debe salir un mensaje que dice “Germen resistente a Tigeciclina, mediado por 
		bombas de eflujo”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Tigeciclina, mediado por bombas de eflujo'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 34 AND
	g.operador = '=';


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Tigeciclina, mediado por bombas de eflujo'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 34 AND
	g.operador = '>=';		


/* **************************************************************************************************************************************************************************************************************************** */

/*
	8.	Ampicilina:
	*	Cuando es un numero entero (es decir =), debe salir un mensaje que dice “Germen con sensibilidad disminuida a 
		Ampicilina, mediado por Penicilinasas”
	*	Cuando es resistente (es decir >=), debe salir un mensaje que dice “Germen resistente a Ampicilina, mediado por
		Penicilinasas”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Ampicilina, mediado por Penicilinasas' 
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico= 13 AND
	g.operador = '=' AND

	0 >= (SELECT COUNT(1) FROM GRAM WHERE (idAntibiotico IN (24,25,16, 23,35,33) AND operador IN ('=', '>=')) OR (idPrueba = 4 AND valor = 1)) 
;
	


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Ampicilina, mediado por Penicilinasas' 
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 13 AND
	g.operador = '>=' AND
	
	0 >= (SELECT COUNT(1) FROM GRAM WHERE (idAntibiotico IN (24,25,16, 23,35,33) AND operador IN ('=', '>=')) OR (idPrueba = 4 AND valor = 1)) 
;	
	


/*
	9.	Ampicilina/sulbactam:
	*	Cuando es un numero entero (es decir =), debe salir un mensaje que dice “Germen con sensibilidad disminuida a 
		Ampicilina/sulbactam, mediado Penicilinasas parcialmente inhibibles por el Sulbactam”
	*	Cuando es resistente (es decir ?), debe salir un mensaje que dice “Germen resistente a Ampicilina/sulbactam, 
		mediado por Penicilinasas no inhibibles por el Sulbactam”

*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Ampicilina/sulbactam, mediado Penicilinasas parcialmente inhibibles por el Sulbactam'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 35 AND
	g.operador = '=' AND
	
	0 >= (SELECT COUNT(1) FROM GRAM WHERE (idAntibiotico IN (24,25,16, 23,33) AND operador IN ('=', '>=')) OR (idPrueba = 4 AND valor = 1)) AND
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (13) AND operador NOT IN ('<='))
;

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Ampicilina y Ampicilina/sulbactam, mediado Penicilinasas parcialmente inhibibles por el Sulbactam'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 35 AND
	g.operador = '=' AND
	
	0 >= (SELECT COUNT(1) FROM GRAM WHERE (idAntibiotico IN (24,25,16, 23,33) AND operador IN ('=', '>=')) OR (idPrueba = 4 AND valor = 1)) AND
	0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (13) AND operador NOT IN ('<='))
;


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Ampicilina/sulbactam, mediado por Penicilinasas no inhibibles por el Sulbactam'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 35 AND
	g.operador = '>=' AND
	
	0 >= (SELECT COUNT(1) FROM GRAM WHERE (idAntibiotico IN (24,25,16, 23,33) AND operador IN ('=', '>=')) OR (idPrueba = 4 AND valor = 1)) AND
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (13) AND operador NOT IN ('<='))
	
;	

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Ampicilina y Ampicilina/sulbactam, mediado por Penicilinasas no inhibibles por el Sulbactam'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 35 AND
	g.operador = '>=' AND
	
	0 >= (SELECT COUNT(1) FROM GRAM WHERE (idAntibiotico IN (24,25,16, 23,33) AND operador IN ('=', '>=')) OR (idPrueba = 4 AND valor = 1)) AND
	0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (13) AND operador NOT IN ('<='))
	
;	


/*
	12.	Cefazolina: 
	*	Cuando es un numero entero (es decir =), debe salir un mensaje que dice “Germen con sensibilidad disminuida a 
		Ampicilina, Ampicilima/sulbactam y Cefazolina, mediado por Beta-lactamasas de espectro ampliado”
	*	Cuando es resistente (es decir ?), debe salir un mensaje que dice “Germen resistente a Ampicilina, 
		Ampicilina/sulbactam y Cefazolina mediado por Beta-lactamasas de espectro ampliado”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Ampicilina, Ampicilina/sulbactam y Cefazolina, mediado por Beta-lactamasas de espectro ampliado'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 23 AND
	g.operador = '=' AND
	
	0 >= (SELECT COUNT(1) FROM GRAM WHERE (idAntibiotico IN (24,25,16,33) AND operador IN ('=', '>=')) OR (idPrueba = 4 AND valor = 1))
;


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Ampicilina, Ampicilina/sulbactam y Cefazolina mediado por Beta-lactamasas de espectro ampliado'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 23 AND
	g.operador = '>=' AND
	
	0 >= (SELECT COUNT(1) FROM GRAM WHERE (idAntibiotico IN (24,25,16,33) AND operador IN ('=', '>=')) OR (idPrueba = 4 AND valor = 1))
;	


/*
	13.	Cefepime, Ceftazidima y Ceftriaxona:
	*	Cuando es un numero entero (es decir =), debe salir un mensaje que dice “Germen productor de Beta-lactamasas de 
		espectro extendido, y por ende resistente a todos los beta-lactámicos excepto Carbapenems”
	*	Cuando es resistente (es decir ?), debe salir un mensaje que dice “Germen productor de Beta-lactamasas de espectro
		extendido, y por ende resistente a todos los beta-lactámicos excepto Carbapenems”
	*	Cuando el test ESBL/BLEE es positivo, debe salir un mensaje que dice “Germen productor de Beta-lactamasas de 
		espectro extendido, y por ende resistente a todos los beta-lactámicos excepto Carbapenems”, independiente de lo que
		haya marcado en estos 3 antibioticos (Cefepime, Ceftazidima y Ceftriaxona)
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g2.idBacteria, 
	24 as idAntibiotico,
	'Germen productor de Beta-lactamasas de espectro extendido (resistente a todos los beta-lactámicos excepto Carbapenems)'
FROM
	(
		SELECT 
			g.idBacteria as idBacteria,
			COUNT(1) as total
		FROM 
			GRAM g
		WHERE
			g.tipoGRAM = '-' AND 
			g.idPrueba = 1 AND
			g.idAntibiotico IN (24,25,16) AND
			g.operador = '=' AND
			0 < (SELECT count(1) FROM GRAM WHERE idPrueba = 4 AND valor NOT IN (1,0)) AND
			0 >= (SELECT count(1) FROM GRAM WHERE idAntibiotico IN (24,25,16) AND operador = '>=') AND
			g.idBacteria NOT IN (21,22,24,25,26,30,31,28,34)
		GROUP BY
			g.idBacteria
	) g2
WHERE
	g2.total > 0;

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g2.idBacteria, 
	24 as idAntibiotico,
	'Germen productor de Beta-lactamasas de espectro extendido (resistente a todos los beta-lactámicos excepto Carbapenems)'
FROM
	(
		SELECT 
			g.idBacteria  as idBacteria,
			COUNT(1) as total
		FROM 
			GRAM g
		WHERE
			g.tipoGRAM = '-' AND 
			g.idPrueba = 1 AND
			g.idAntibiotico IN (24,25,16) AND
			g.operador = '>=' AND
			0 < (SELECT count(1) FROM GRAM WHERE idPrueba = 4 AND valor NOT IN (1,0)) AND
			g.idBacteria NOT IN (21,22,24,25,26,30,31,28,34) 
		GROUP BY
			g.idBacteria
	) g2
WHERE
	g2.total > 0;
	
	
	
INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g2.idBacteria, 
	24 as idAntibiotico,
	'Germen productor de AMP-C (resistente a todos los beta-lactámicos excepto Carbapenems'
FROM
	(
		SELECT 
			g.idBacteria as idBacteria,
			COUNT(1) as total
		FROM 
			GRAM g
		WHERE
			g.tipoGRAM = '-' AND 
			g.idPrueba = 1 AND
			g.idAntibiotico IN (24,25,16) AND
			g.operador IN ('=', '>=') AND
			0 < (SELECT count(1) FROM GRAM WHERE idPrueba = 4 AND valor = 0)
		GROUP BY
			g.idBacteria
	) g2
WHERE
	g2.total > 0;
	

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen productor de Beta-lactamasas de espectro extendido (resistente a todos los beta-lactámicos excepto Carbapenems)'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 4 AND
	g.valor = 1 AND
	g.idBacteria NOT IN (21,22,24,25,26,30,31,28,34)
;


/*
	11.	Piperacilina/tazobactam:
	*	Cuando es un numero entero (es decir =), debe salir un mensaje que dice “Germen con sensibilidad disminuida a 
		Ampicilina, Ampicilima/sulbactam, Piperacilina/tazobactam y Cefazolina, mediado por Beta-lactamasas de espectro 
		ampliado”
	*	Cuando es resistente (es decir ?), debe salir un mensaje que dice “Germen resistente a Ampicilina, 
		Ampicilina/sulbactam, Piperacilina/tazobactam y Cefazolina mediado por Beta-lactamasas de espectro ampliado”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Ampicilina, Ampicilina/sulbactam, Aztreonam, Piperacilina/tazobactam y Cefazolina, mediado por Beta-lactamasas de espectro ampliado'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 33 AND
	g.operador = '=' AND
	
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (24,25,16) AND operador IN ('=', '>=')) AND
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idPrueba = 4 AND valor = 1) AND
	0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (23) AND operador IN ('=', '>='));

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Ampicilina, Ampicilina/sulbactam, Aztreonam y Piperacilina/tazobactam, mediado por Penicilinasas'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 33 AND
	g.operador = '=' AND
	
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (24,25,16) AND operador IN ('=', '>=')) AND
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idPrueba = 4 AND valor = 1) AND
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (23) AND operador IN ('=', '>='));


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Ampicilina, Ampicilina/sulbactam, Aztreonam, Piperacilina/tazobactam y Cefazolina mediado por Beta-lactamasas de espectro ampliado'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 33 AND
	g.operador = '>='  AND
	
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (24,25,16) AND operador IN ('=', '>=')) AND
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idPrueba = 4 AND valor = 1) AND
	0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (23) AND operador IN ('=', '>='));


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Ampicilina, Ampicilina/sulbactam, Aztreonam y Piperacilina/tazobactam, mediado por Penicilinasas'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 33 AND
	g.operador = '>='  AND
	
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (24,25,16) AND operador IN ('=', '>=')) AND
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idPrueba = 4 AND valor = 1) AND
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (23) AND operador IN ('=', '>='));


/* **************************************************************************************************************************************************************************************************************************** */


/*
	10.	Aztreonam:
	*	Cuando es un numero entero (es decir =), debe salir un mensaje que dice “Germen con sensibilidad disminuida a 
		Aztreonam, mediado por Beta-lactamasas”
	*	Cuando es resistente (es decir ?), debe salir un mensaje que dice “Germen resistente a Aztreonam, mediado por 
		Beta-lactamasas”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Aztreonam, mediado por Beta-lactamasas'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 22 AND
	g.operador = '=' AND
	
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (24,25,16,33) AND operador IN ('=', '>=')) AND
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idPrueba = 4 AND valor = 1);


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Aztreonam, mediado por Beta-lactamasas'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 22 AND
	g.operador = '>=' AND
	
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (24,25,16,33) AND operador IN ('=', '>=')) AND
	0 >= (SELECT COUNT(1) FROM GRAM WHERE idPrueba = 4 AND valor = 1);	

	

/*
	14.	Ertapenem:

	*	Cuando es un numero entero (es decir =), debe salir un mensaje que dice “Germen con sensibilidad disminuida a 
		Ertapenem”
	*	Cuando es resistente (es decir ?), debe salir un mensaje que dice “Germen resistente a Ertapenem”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Ertapenem, mediado por hiperproduccion de AMP-C'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idBacteria NOT IN (21,22,24,25,31,30,26,28,34) AND
	g.idAntibiotico = 28 AND
	g.operador = '='
	
	and
	(
		0 >= (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idPrueba = 4 AND valor = 1) OR
		0 >= (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idAntibiotico IN (24,25,16) AND operador IN ('=', '>='))
	) AND
	(
		0 >= (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idAntibiotico IN (31,30,32) AND operador IN ('=', '>='))
	)
	
	AND
	0 >= (
		SELECT COUNT(1) FROM
			(
				SELECT
					idBacteria,
					SUM(CASE WHEN operador = '=' THEN 1 ELSE 0 END) as conteo,
					SUM(CASE WHEN idAntibiotico = 30 THEN valor ELSE 0 END) as valorImipenem,
					SUM(CASE WHEN idAntibiotico = 31 THEN valor ELSE 0 END) as valorMeropenem,
					SUM(CASE WHEN idAntibiotico = 32 THEN valor ELSE 0 END) as valorDoripenem,
					MAX(CASE WHEN idAntibiotico = 30 THEN operador ELSE '' END) as signoImipenem,
					MAX(CASE WHEN idAntibiotico = 31 THEN operador ELSE '' END) as signoMeropenem,
					MAX(CASE WHEN idAntibiotico = 32 THEN operador ELSE '' END) as signoDoripenem
				FROM
					GRAM 
				WHERE
					tipoGRAM = '-' AND 
					idPrueba = 1 AND
					idAntibiotico IN (30,32,31)
				GROUP BY
					idBacteria
			) g5
		WHERE
		/*	valorImipenem > valorMeropenem OR
			valorMeropenem > valorImipenem OR
			(signoImipenem = '=' AND  signoMeropenem = '<=') OR
			(signoImipenem = '<=' AND  signoMeropenem = '=')*/
			(signoImipenem IN ('>=') AND signoMeropenem IN ('>=')) OR
			(signoImipenem IN ('=') AND signoMeropenem IN ('=') AND valorImipenem = valorMeropenem)
	)
	
	;
	/*
INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Ertapenem por hiperexpresión de BLEE'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idBacteria NOT IN (21,22,24,25,31,30,26,28,34) AND
	g.idAntibiotico = 28 AND
	g.operador = '='
	
	and
	(
		0 < (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idPrueba = 4 AND valor = 1) OR
		0 >= (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idAntibiotico IN (24,25,16) AND operador IN ('=', '>='))
	) AND
	(
		0 >= (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idAntibiotico IN (31,30,32) AND operador IN ('=', '>='))
	);*/


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Ertapenem, mediado por hiperproduccion de AMP-C'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idBacteria NOT IN (21,22,24,25,31,30,26,28,34) AND
	g.idAntibiotico = 28 AND
	g.operador = '>=' 
	
	AND
	(
		0 >= (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idPrueba = 4 AND valor = 1) OR
		0 >= (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idAntibiotico IN (24,25,16) AND operador IN ('=', '>='))
	) AND
	(
		0 >= (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idAntibiotico IN (31,30,32) AND operador IN ('=', '>='))
	)
	
	AND
	0 >= (
		SELECT COUNT(1) FROM
			(
				SELECT
					idBacteria,
					SUM(CASE WHEN operador = '=' THEN 1 ELSE 0 END) as conteo,
					SUM(CASE WHEN idAntibiotico = 30 THEN valor ELSE 0 END) as valorImipenem,
					SUM(CASE WHEN idAntibiotico = 31 THEN valor ELSE 0 END) as valorMeropenem,
					SUM(CASE WHEN idAntibiotico = 32 THEN valor ELSE 0 END) as valorDoripenem,
					MAX(CASE WHEN idAntibiotico = 30 THEN operador ELSE '' END) as signoImipenem,
					MAX(CASE WHEN idAntibiotico = 31 THEN operador ELSE '' END) as signoMeropenem,
					MAX(CASE WHEN idAntibiotico = 32 THEN operador ELSE '' END) as signoDoripenem
				FROM
					GRAM 
				WHERE
					tipoGRAM = '-' AND 
					idPrueba = 1 AND
					idAntibiotico IN (30,32,31)
				GROUP BY
					idBacteria
			) g5
		WHERE
			/*	valorImipenem > valorMeropenem OR
			valorMeropenem > valorImipenem OR
			(signoImipenem = '=' AND  signoMeropenem = '<=') OR
			(signoImipenem = '<=' AND  signoMeropenem = '=')*/
			(signoImipenem IN ('>=') AND signoMeropenem IN ('>=')) OR
			(signoImipenem IN ('=') AND signoMeropenem IN ('=') AND valorImipenem = valorMeropenem)
	)
	
	;
	/*

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Ertapenem por hiperexpresión de BLEE'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idBacteria NOT IN (21,22,24,25,31,30,26,28,34) AND
	g.idAntibiotico = 28 AND
	g.operador = '>=' 
	
	AND
	(
		0 < (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idPrueba = 4 AND valor = 1) OR
		0 >= (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idAntibiotico IN (24,25,16) AND operador IN ('=', '>='))
	) AND
	(
		0 >= (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idAntibiotico IN (31,30,32) AND operador IN ('=', '>='))
	);
	*/

	/*
INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Ertapenem por hiperexpresión de BLEE'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idBacteria NOT IN (21,22,24,25,31,30,26,28,34) AND
	g.idAntibiotico = 28 AND
	g.operador = '=' AND
	(
		0 < (SELECT COUNT(1) FROM GRAM WHERE idPrueba = 4 AND valor = 1) OR
		0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (24,25,16) AND operador IN ('=', '>=')) OR
		3 <= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (30,31,32) AND operador IN ('<='))
	)
	;
	
INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Ertapenem por hiperexpresión de BLEE'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idBacteria NOT IN (21,22,24,25,31,30,26,28,34) AND
	g.idAntibiotico = 28 AND
	g.operador = '>=' AND
	(
		0 < (SELECT COUNT(1) FROM GRAM WHERE idPrueba = 4 AND valor = 1) OR
		0 < (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (24,25,16) AND operador IN ('=', '>=')) OR
		3 <= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (30,31,32) AND operador IN ('<='))
	)
	
	;*/

/*
	*	Pero en este antibiótico hay que hacer un análisis adicional para añadir a las reglas:
		-	Si es un numero entero o resistente y se trata de Serratia, Enterobacter, Citrobacter, Aeromonas, Proteus 
			penneri, Proteus vulgaris, Morganella, Acinetobacter o Providencia; debe salir un mensaje que diga “Germen 
			con sensibilidad disminuida (o resistente según el caso) a Ertapenem, mediado por hiperproduccion de AMP-C
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Ertapenem, mediado por hiperproduccion de AMP-C'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idBacteria IN (21,22,24,25,31,30,26,28,34) AND
	g.idAntibiotico = 28 AND
	g.operador = '=' AND
	
	0 <= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (30,31,32) AND operador IN ('=', '>='))
	
	AND
	0 >= (
		SELECT COUNT(1) FROM
			(
				SELECT
					idBacteria,
					SUM(CASE WHEN operador = '=' THEN 1 ELSE 0 END) as conteo,
					SUM(CASE WHEN idAntibiotico = 30 THEN valor ELSE 0 END) as valorImipenem,
					SUM(CASE WHEN idAntibiotico = 31 THEN valor ELSE 0 END) as valorMeropenem,
					SUM(CASE WHEN idAntibiotico = 32 THEN valor ELSE 0 END) as valorDoripenem,
					MAX(CASE WHEN idAntibiotico = 30 THEN operador ELSE '' END) as signoImipenem,
					MAX(CASE WHEN idAntibiotico = 31 THEN operador ELSE '' END) as signoMeropenem,
					MAX(CASE WHEN idAntibiotico = 32 THEN operador ELSE '' END) as signoDoripenem
				FROM
					GRAM 
				WHERE
					tipoGRAM = '-' AND 
					idPrueba = 1 AND
					idAntibiotico IN (30,32,31)
				GROUP BY
					idBacteria
			) g5
		WHERE
			/*	valorImipenem > valorMeropenem OR
			valorMeropenem > valorImipenem OR
			(signoImipenem = '=' AND  signoMeropenem = '<=') OR
			(signoImipenem = '<=' AND  signoMeropenem = '=')*/
			(signoImipenem IN ('>=') AND signoMeropenem IN ('>=')) OR
			(signoImipenem IN ('=') AND signoMeropenem IN ('=') AND valorImipenem = valorMeropenem)
	)
	
	/*
	AND
	0 >= (
		SELECT COUNT(1) FROM
			(
				SELECT
					idBacteria,
					SUM(CASE WHEN operador = '=' THEN 1 ELSE 0 END) as conteo,
					SUM(CASE WHEN idAntibiotico = 30 THEN valor ELSE 0 END) as valorImipenem,
					SUM(CASE WHEN idAntibiotico = 31 THEN valor ELSE 0 END) as valorMeropenem,
					SUM(CASE WHEN idAntibiotico = 32 THEN valor ELSE 0 END) as valorDoripenem,
					MAX(CASE WHEN idAntibiotico = 30 THEN operador ELSE '' END) as signoImipenem,
					MAX(CASE WHEN idAntibiotico = 31 THEN operador ELSE '' END) as signoMeropenem,
					MAX(CASE WHEN idAntibiotico = 32 THEN operador ELSE '' END) as signoDoripenem
				FROM
					GRAM 
				WHERE
					tipoGRAM = '-' AND 
					idPrueba = 1 AND
					idAntibiotico IN (30,32,31)
				GROUP BY
					idBacteria
			) g5
		WHERE
			valorImipenem > valorMeropenem OR
			valorMeropenem > valorImipenem OR
			(signoImipenem = '=' AND  signoMeropenem = '<=') OR
			(signoImipenem = '<=' AND  signoMeropenem = '=')
	)*/
	;


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Ertapenem, mediado por hiperproduccion de AMP-C'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idBacteria IN (21,22,24,25,31,30,26,28,34) AND
	g.idAntibiotico = 28 AND
	g.operador = '>=' AND
	0 <= (SELECT COUNT(1) FROM GRAM WHERE idAntibiotico IN (30,31,32) AND operador IN ('=', '>='))
	
	AND
	0 >= (
		SELECT COUNT(1) FROM
			(
				SELECT
					idBacteria,
					SUM(CASE WHEN operador = '=' THEN 1 ELSE 0 END) as conteo,
					SUM(CASE WHEN idAntibiotico = 30 THEN valor ELSE 0 END) as valorImipenem,
					SUM(CASE WHEN idAntibiotico = 31 THEN valor ELSE 0 END) as valorMeropenem,
					SUM(CASE WHEN idAntibiotico = 32 THEN valor ELSE 0 END) as valorDoripenem,
					MAX(CASE WHEN idAntibiotico = 30 THEN operador ELSE '' END) as signoImipenem,
					MAX(CASE WHEN idAntibiotico = 31 THEN operador ELSE '' END) as signoMeropenem,
					MAX(CASE WHEN idAntibiotico = 32 THEN operador ELSE '' END) as signoDoripenem
				FROM
					GRAM 
				WHERE
					tipoGRAM = '-' AND 
					idPrueba = 1 AND
					idAntibiotico IN (30,32,31)
				GROUP BY
					idBacteria
			) g5
		WHERE
			/*	valorImipenem > valorMeropenem OR
			valorMeropenem > valorImipenem OR
			(signoImipenem = '=' AND  signoMeropenem = '<=') OR
			(signoImipenem = '<=' AND  signoMeropenem = '=')*/
			(signoImipenem IN ('>=') AND signoMeropenem IN ('>=')) OR
			(signoImipenem IN ('=') AND signoMeropenem IN ('=') AND valorImipenem = valorMeropenem)
	)
	
	
	/*
	AND
	0 >= (
		SELECT COUNT(1) FROM
			(
				SELECT
					idBacteria,
					SUM(CASE WHEN operador = '=' THEN 1 ELSE 0 END) as conteo,
					SUM(CASE WHEN idAntibiotico = 30 THEN valor ELSE 0 END) as valorImipenem,
					SUM(CASE WHEN idAntibiotico = 31 THEN valor ELSE 0 END) as valorMeropenem,
					SUM(CASE WHEN idAntibiotico = 32 THEN valor ELSE 0 END) as valorDoripenem,
					MAX(CASE WHEN idAntibiotico = 30 THEN operador ELSE '' END) as signoImipenem,
					MAX(CASE WHEN idAntibiotico = 31 THEN operador ELSE '' END) as signoMeropenem,
					MAX(CASE WHEN idAntibiotico = 32 THEN operador ELSE '' END) as signoDoripenem
				FROM
					GRAM 
				WHERE
					tipoGRAM = '-' AND 
					idPrueba = 1 AND
					idAntibiotico IN (30,32,31)
				GROUP BY
					idBacteria
			) g5
		WHERE
			valorImipenem > valorMeropenem OR
			valorMeropenem > valorImipenem OR
			(signoImipenem = '=' AND  signoMeropenem = '<=') OR
			(signoImipenem = '<=' AND  signoMeropenem = '=')
	)*/
	
	;
	
/*
	*	Si es un numero entero o resistente, y además tiene test ESBL/BLEE positivo o Cefepime, Ceftazidima o Cerfriaxona 
		son numeros enteros o resistentes (es decir son productores de Betalactamasas de espectro extendido); debe salir 
		un mensaje que diga “Germen con sensibilidad disminuida (o resistente según el caso) a Ertapenem, mediado por 
		hiperproduccion de Beta-lactamasas de expectro extendido”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Ertapenem, mediado por hiperproduccion de Beta-lactamasas de expectro extendido'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 28 AND
	g.operador = '=' AND
	(
		0 < (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idPrueba = 4 AND valor = 1) /*OR
		0 < (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idAntibiotico IN (24,25,16) AND operador IN ('=', '>='))*/
	)
	
	
	AND
	0 >= (
		SELECT COUNT(1) FROM
			(
				SELECT
					idBacteria,
					SUM(CASE WHEN operador = '=' THEN 1 ELSE 0 END) as conteo,
					SUM(CASE WHEN idAntibiotico = 30 THEN valor ELSE 0 END) as valorImipenem,
					SUM(CASE WHEN idAntibiotico = 31 THEN valor ELSE 0 END) as valorMeropenem,
					SUM(CASE WHEN idAntibiotico = 32 THEN valor ELSE 0 END) as valorDoripenem,
					MAX(CASE WHEN idAntibiotico = 30 THEN operador ELSE '' END) as signoImipenem,
					MAX(CASE WHEN idAntibiotico = 31 THEN operador ELSE '' END) as signoMeropenem,
					MAX(CASE WHEN idAntibiotico = 32 THEN operador ELSE '' END) as signoDoripenem
				FROM
					GRAM 
				WHERE
					tipoGRAM = '-' AND 
					idPrueba = 1 AND
					idAntibiotico IN (30,32,31)
				GROUP BY
					idBacteria
			) g5
		WHERE
			/*	valorImipenem > valorMeropenem OR
			valorMeropenem > valorImipenem OR
			(signoImipenem = '=' AND  signoMeropenem = '<=') OR
			(signoImipenem = '<=' AND  signoMeropenem = '=')*/
			(signoImipenem IN ('>=') AND signoMeropenem IN ('>=')) OR
			(signoImipenem IN ('=') AND signoMeropenem IN ('=') AND valorImipenem = valorMeropenem)
	)
	
	;


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Ertapenem, mediado por hiperproduccion de Beta-lactamasas de expectro extendido'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 28 AND
	g.operador = '>=' AND
	(
		0 < (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idPrueba = 4 AND valor = 1)/* OR
		0 < (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idAntibiotico IN (24,25,16) AND operador IN ('=', '>='))*/
	)
	
	AND
	0 >= (
		SELECT COUNT(1) FROM
			(
				SELECT
					idBacteria,
					SUM(CASE WHEN operador = '=' THEN 1 ELSE 0 END) as conteo,
					SUM(CASE WHEN idAntibiotico = 30 THEN valor ELSE 0 END) as valorImipenem,
					SUM(CASE WHEN idAntibiotico = 31 THEN valor ELSE 0 END) as valorMeropenem,
					SUM(CASE WHEN idAntibiotico = 32 THEN valor ELSE 0 END) as valorDoripenem,
					MAX(CASE WHEN idAntibiotico = 30 THEN operador ELSE '' END) as signoImipenem,
					MAX(CASE WHEN idAntibiotico = 31 THEN operador ELSE '' END) as signoMeropenem,
					MAX(CASE WHEN idAntibiotico = 32 THEN operador ELSE '' END) as signoDoripenem
				FROM
					GRAM 
				WHERE
					tipoGRAM = '-' AND 
					idPrueba = 1 AND
					idAntibiotico IN (30,32,31)
				GROUP BY
					idBacteria
			) g5
		WHERE
			/*	valorImipenem > valorMeropenem OR
			valorMeropenem > valorImipenem OR
			(signoImipenem = '=' AND  signoMeropenem = '<=') OR
			(signoImipenem = '<=' AND  signoMeropenem = '=')*/
			(signoImipenem IN ('>=') AND signoMeropenem IN ('>=')) OR
			(signoImipenem IN ('=') AND signoMeropenem IN ('=') AND valorImipenem = valorMeropenem)
	)
	
	
	;

/*
	*	Si es un numero entero o resistente, y además Meropenem y/o Imipenem y/o Doripenem son números enteros o resistentes;
		debe salir un mensaje que diga “Germen con sensibilidad disminuida (o resistente según el caso), mediado por 
		mecanismos de permeabilidad o KPC.
*/
/*
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-General', 'Ingresando el mensaje que indica que el germen tiene sensibilidad disminuida a Ertapenem, mediado por mecanismos de permeabilidad o KPC.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Ertapenem, mediado por mecanismos de permeabilidad o KPC'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 28 AND
	g.operador = '=' AND
	(
		0 < (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idAntibiotico IN (31,30,32) AND operador IN ('=', '>='))
	)
	
	AND
	0 >= (
		SELECT COUNT(1) FROM
			(
				SELECT
					idBacteria,
					SUM(CASE WHEN operador = '=' THEN 1 ELSE 0 END) as conteo,
					SUM(CASE WHEN idAntibiotico = 30 THEN valor ELSE 0 END) as valorImipenem,
					SUM(CASE WHEN idAntibiotico = 31 THEN valor ELSE 0 END) as valorMeropenem,
					SUM(CASE WHEN idAntibiotico = 32 THEN valor ELSE 0 END) as valorDoripenem,
					MAX(CASE WHEN idAntibiotico = 30 THEN operador ELSE '' END) as signoImipenem,
					MAX(CASE WHEN idAntibiotico = 31 THEN operador ELSE '' END) as signoMeropenem,
					MAX(CASE WHEN idAntibiotico = 32 THEN operador ELSE '' END) as signoDoripenem
				FROM
					GRAM 
				WHERE
					tipoGRAM = '-' AND 
					idPrueba = 1 AND
					idAntibiotico IN (30,32,31)
				GROUP BY
					idBacteria
			) g5
		WHERE
			(signoImipenem IN ('>=') AND signoMeropenem IN ('>=')) OR
			(signoImipenem IN ('=') AND signoMeropenem IN ('=') AND valorImipenem = valorMeropenem)
	)
	;
	*/
/*
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-General', 'Ingresando el mensaje que indica que el germen es resistente a Ertapenem, mediado por mecanismos de permeabilidad o KPC.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Ertapenem, mediado por mecanismos de permeabilidad o KPC'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '-' AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 28 AND
	g.operador = '>=' AND
	(
		0 < (SELECT count(1) FROM GRAM WHERE tipoGRAM = '-' AND idAntibiotico IN (31,30,32) AND operador IN ('=', '>='))
	)
	
	AND
	0 >= (
		SELECT COUNT(1) FROM
			(
				SELECT
					idBacteria,
					SUM(CASE WHEN operador = '=' THEN 1 ELSE 0 END) as conteo,
					SUM(CASE WHEN idAntibiotico = 30 THEN valor ELSE 0 END) as valorImipenem,
					SUM(CASE WHEN idAntibiotico = 31 THEN valor ELSE 0 END) as valorMeropenem,
					SUM(CASE WHEN idAntibiotico = 32 THEN valor ELSE 0 END) as valorDoripenem,
					MAX(CASE WHEN idAntibiotico = 30 THEN operador ELSE '' END) as signoImipenem,
					MAX(CASE WHEN idAntibiotico = 31 THEN operador ELSE '' END) as signoMeropenem,
					MAX(CASE WHEN idAntibiotico = 32 THEN operador ELSE '' END) as signoDoripenem
				FROM
					GRAM 
				WHERE
					tipoGRAM = '-' AND 
					idPrueba = 1 AND
					idAntibiotico IN (30,32,31)
				GROUP BY
					idBacteria
			) g5
		WHERE
			
			(signoImipenem IN ('>=') AND signoMeropenem IN ('>=')) OR
			(signoImipenem IN ('=') AND signoMeropenem IN ('=') AND valorImipenem = valorMeropenem)
	)
	;		
	*/
	
	
/*
	15.	Imipenem, Doripenem y Meropenem:
	
	*	Cuando alguno de los antibióticos es un numero entero (es decir =), debe salir un mensaje que dice “Germen con 
		sensibilidad disminuida a ese antibiótico….” (ver abajo para saber que continúa en el mensaje según el caso). 
	*	Cuando es resistente (es decir ?), debe salir un mensaje que dice “Germen resistente a ese antibiótico… ” (ver 
		abajo para saber que continua según el caso)
	*	Pero en estos antibióticos hay que hacer un análisis adicional para añadir a las reglas:
		-	Si los 3 antibióticos son resistentes (es decir ?) o los 3 antibióticos tienen exactamente el mismo número 
			entero, debe salir un mensaje que diga “Germen con sensibilidad disminuida (o resistente según el caso), a 
			Imipenem, Meropenem y Doripenem, mediado por KPC, corroborar con un laboratorio de referencia”
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	31 AS idAntibiotico,
	'Germen con sensibilidad disminuida a Carbapenems mediado por KPC, corroborar con laboratorio de referencia'
FROM
	(
		SELECT
			idBacteria,
			SUM(CASE WHEN operador = '=' THEN 1 ELSE 0 END) as conteo,
			SUM(CASE WHEN idAntibiotico = 30 THEN valor ELSE 0 END) as valorImipenem,
			SUM(CASE WHEN idAntibiotico = 31 THEN valor ELSE 0 END) as valorMeropenem,
			SUM(valor) as suma
		FROM
			GRAM 
		WHERE
			tipoGRAM = '-' AND 
			idPrueba = 1 AND
			idAntibiotico IN (30,31)
		GROUP BY
			idBacteria
	) g
WHERE
	g.conteo = 2 AND
	valorImipenem = valorMeropenem
	/*OR
	g.suma = CAST((g.suma / 3) AS INTEGER) * 3*/;


INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	31 AS idAntibiotico,
	'Germen resistente a Carbapenems mediado por KPC, corroborar con laboratorio de referencia'
FROM
	(
		SELECT
			idBacteria,
			SUM(CASE WHEN operador = '>=' THEN 1 ELSE 0 END) as conteo,
			SUM(CASE WHEN idAntibiotico = 30 THEN valor ELSE 0 END) as valorImipenem,
			SUM(CASE WHEN idAntibiotico = 31 THEN valor ELSE 0 END) as valorMeropenem,
			SUM(valor) as suma
		FROM
			GRAM 
		WHERE
			tipoGRAM = '-' AND 
			idPrueba = 1 AND
			idAntibiotico IN (30,31)
		GROUP BY
			idBacteria
	) g
WHERE
	g.conteo = 2 ;	
	
/*
	*	Si ninguno es resistente, y los 3 tienen números enteros pero diferentes, se deben comparar aritméticamente los 
		numeros de Imipenem y Meropenem (solo se comparan estos dos y se ignora a Doripenem) asi:
	
	-	Si el número de Imipenem es mayor que el de Meropenem, debe salir un mensaje que diga “Germen con sensibilidad 
		disminuida a Carbapenems mediado por cierre de porinas”
	-	Si el número de Meropenem es mayor que el de Imipenem, debe salir un mensaje que diga “Germen con sensibilidad 
		disminuida a Carbapenems mediado por bombas de eflujo”	
*/

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	31 AS idAntibiotico,
	(
		CASE
			/*WHEN  (signoImipenem IN ('=', '>=') AND  signoMeropenem = '<=') OR (signoImipenem = '>=' AND  signoMeropenem = '=') THEN 'Germen con sensibilidad disminuida a Imipenem mediante cierre de porinas'
			WHEN  (signoMeropenem IN ('=', '>=') AND  signoImipenem = '<=') OR (signoMeropenem = '>=' AND  signoImipenem = '=') THEN 'Germen con sensibilidad disminuida a Meropenem mediante bombas de eflujo'*/
			
			WHEN  (signoImipenem IN ('=') AND  signoMeropenem = '<=') THEN 'Germen con sensibilidad disminuida a Imipenem mediante cierre de porinas'
			WHEN  (signoImipenem IN ('>=') AND  signoMeropenem = '<=') THEN 'Germen resistente a Imipenem mediante cierre de porinas'
			
			WHEN  (signoImipenem IN ('>=') AND  signoMeropenem = '=') THEN 'Germen resistente a Imipenem y con sensibilidad disminuida a Meropenem mediante cierre de porinas'
			
			
			WHEN  (signoMeropenem IN ('=') AND  signoImipenem = '<=')  THEN 'Germen con sensibilidad disminuida a Meropenem mediante bombas de eflujo'
			WHEN  (signoMeropenem IN ('>=') AND  signoImipenem = '<=')  THEN 'Germen resistente a Meropenem mediante bombas de eflujo'
			WHEN  (signoMeropenem IN ('>=') AND  signoImipenem = '=') THEN 'Germen resistente a Meropenem y con sensibilidad disminuida a Imipenem mediante bombas de eflujo'
			
			
			WHEN (valorImipenem > valorMeropenem) AND (signoImipenem = '=' AND  signoMeropenem = '=') THEN 'Germen con sensibilidad disminuida a Carbapenems mediado por cierre de porinas'
			WHEN (valorMeropenem > valorImipenem) AND (signoImipenem = '=' AND  signoMeropenem = '=') THEN 'Germen con sensibilidad disminuida a Carbapenems mediado por bombas de eflujo'
		END
	) AS Mensaje
FROM
	(
		SELECT
			idBacteria,
			SUM(CASE WHEN operador <> '>=' THEN 1 ELSE 0 END) as conteo,
			SUM(CASE WHEN idAntibiotico = 30 THEN valor ELSE 0 END) as valorImipenem,
			SUM(CASE WHEN idAntibiotico = 31 THEN valor ELSE 0 END) as valorMeropenem,
			SUM(CASE WHEN idAntibiotico = 32 THEN valor ELSE 0 END) as valorDoripenem,
			MAX(CASE WHEN idAntibiotico = 30 THEN operador ELSE '' END) as signoImipenem,
			MAX(CASE WHEN idAntibiotico = 31 THEN operador ELSE '' END) as signoMeropenem,
			MAX(CASE WHEN idAntibiotico = 32 THEN operador ELSE '' END) as signoDoripenem
			
		FROM
			GRAM 
		WHERE
			tipoGRAM = '-' AND 
			idPrueba = 1 AND
			idAntibiotico IN (30,32,31)
		GROUP BY
			idBacteria
	) g
WHERE
	/*g.conteo = 3 AND*/
	(
	/*	valorImipenem <> valorMeropenem AND
		valorImipenem <> valorDoripenem AND
		valorMeropenem <> valorDoripenem */
		((valorImipenem > valorMeropenem) AND (signoImipenem = '=' AND  signoMeropenem = '=')) OR (signoImipenem IN ('=', '>=') AND  signoMeropenem = '<=') OR (signoImipenem = '>=' AND  signoMeropenem = '=') OR
		((valorMeropenem > valorImipenem) AND (signoImipenem = '=' AND  signoMeropenem = '=')) OR (signoMeropenem IN ('=', '>=') AND  signoImipenem = '<=') OR (signoMeropenem = '>=' AND  signoImipenem = '=')
		
	);
	
	





