/*
	ETAPA 1
*/	

/*
Cuando todos los antibióticos Aj del formulario sean sensibles, debe salir el mensaje “Germen sensible a todo el panel de antibióticos, pero con 
resistencia intrínseca a Clindamicina, Quinolonas, Trimetoprim-sulfa y Cefalosporinas”
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-EnterococcusGallinarumyCasseliflvus-Etapa1','Todos sensibles.');

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
			g.tipoGRAM = '+' AND
			g.idBacteria IN (9,10) AND 
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
			g.idBacteria IN (9,10) AND 
			g.idPrueba = 1
	) g2
		ON (g1.total = g2.total)
;

/*
Cuando Aj =Vancomicina es un numero entero (es decir =), debe salir un mensaje que diga “Germen con sensibilidad disminuida a Vancomicina”
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-EnterococcusGallinarumyCasseliflvus-Etapa1','Vancomicina entero.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen con sensibilidad disminuida a Vancomicina'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria IN (9,10) AND 
	g.idPrueba = 1 AND
	
	g.idAntibiotico IN (10) AND 
	g.operador = '=' 
;

/*
Cuando Vancomicina es resistente (es decir ≥) debe salir un mensaje que diga “Germen resistente a Vancomicina mediado por VAN-C, por favor corrobore con un laboratorio de referencia”
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-EnterococcusGallinarumyCasseliflvus-Etapa1','Vancomicina resistente');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Vancomicina mediado por VAN-C, por favor corrobore con un laboratorio de referencia'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria IN (9,10) AND 
	g.idPrueba = 1 AND
	
	g.idAntibiotico IN (10) AND 
	g.operador = '>=' 
;


/*
	ETAPA 2
*/	
/*
	Cuando es sensible a Ampicilina y la infección es en:
	* Sistema nervioso central: 0
		- 	Ampicilina (dosis meníngeas)
	* Boca y senos paranasales: 1
		- 	 Ampicilina/sulbactam
	* Pulmones: 2
		- 	Ampicilina/sulbactam
	* Tejidos blandos: 7
		- 	Ampicilina/sulbactam 
	* Hueso: 5
		- 	Ampicilina/sulbactam 
		- 	Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis)
	* Abdomen: 3
		- 	Ampicilina/sulbactam
	* Tracto genitourinario: 4
		- 	Ampicilina
		- 	Ampicilina/sulbactam 
	* Próstata: 6
		- 	Ampicilina (dosis meníngeas)
		- 	Fosfomycin (3gm cada 3 dias por 7 dosis) 
	* Sangre: 8
		- 	Ampicilina/sulbactam
		- 	En caso de endocarditis: Ceftriaxona 2 gm cada 12 horas (si Albumina > 3.5) o Cefotaxima (si Albumina < 3.5)

	**Cuando es resistente a Ampicilina o alérgico a Penicilina, se comporta igual a Enterococcus faecium
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-EnterococcusGallinarumyCasseliflvus-Etapa2','Ingresando la asignación de medicamentos (ARk) cuando el germen es sensible a Ampicilina.');

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
			g.idBacteria IN (9,10) AND 
			
			((g.idAntibiotico IN (13) AND g.operador = '<='))
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (17)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (4)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (4)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (4)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (20,4)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (4,7)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (17,22)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (4)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (4,19)) 
			
	) a2;
	
/*
	**Cuando es resistente a Ampicilina o alérgico a Penicilina, se comporta igual a Enterococcus faecium
	cuando la infección es en:
			* Sistema nervioso central: 0
				- 	Daptomicina
				- 	Linezolide
			* Boca y senos paranasales: 1
				- 	Vancomicina
				- 	Tigeciclina
				- 	Linezolide
			* Pulmones: 2
				- 	Vancomicina
				- 	Linezolide
			* Tejidos blandos: 7
				- 	Vancomicina
				- 	Linezolide
			* Hueso: 5
				- 	Vancomicina
				- 	Daptomicina
				- 	Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis)
			* Abdomen: 3
				- 	Vancomicina, 
				- 	Tigeciclina
				- 	Linezolide
			* Tracto genitourinario: 4
				- 	Fosfomycin (pielonefritis: 3gm cada 3 dias por 7 dosis y cistitis 3 gm dosis unica)
				- 	Nitrofurantoin (solo cistitis)
				- 	Vancomicina
				- 	Linezolide
			* Próstata: 6
				- 	Fosfomycin (3gm cada 3 dias por 7 dosis)
				- 	Vancomicina
			* Sangre: 8
				- 	Vancomicina
				- 	Daptomicina
			**Si es además resistente a Vancomicina, se quita Vancomicina de todas las opciones donde aparece
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-EnterococcusGallinarumyCasseliflvus-Etapa2','Ingresando la asignación de medicamentos (ARk) cuando el germen es es resistente a la Ampicilina.');

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
			g.idBacteria IN (9,10) AND 
			
			((g.idAntibiotico IN (13) AND g.operador = '>='))
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
			(dp1.idParteDelCuerpo = 1 AND a.id IN (11,13,16)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (11,13)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (13,16,11)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (18,21,11,13)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (10,13,7)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (22,13)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (11,13)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (10,13)) 
	) a2;

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-EnterococcusGallinarumyCasseliflvus-Etapa2','Ingresando la asignación de medicamentos (ARk) cuando el paciente es alérgico a Penicilina.');
		
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
			g.idBacteria IN (9,10) 
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (10,11)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (11,13,16)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (11,13)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (13,16,11)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (18,21,11,13)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (10,13,7)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (22,13)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (11,13)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (10,13)) 
	) a2;

/*
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-EnterococcusGallinarumyCasseliflvus-Etapa2','Eliminando de la asignación de medicamentos (ARk) la Vancomicina.');

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
				g.idBacteria IN (9,10) AND 
				
				(g.idAntibiotico IN (10) AND g.operador = '>=') AND
				(
					0 < (SELECT count(1) FROM GRAM g2 WHERE g2.tipoGRAM = '+' AND g.idBacteria IN (7) AND (g.idAntibiotico IN (13) AND g.operador = '>=') ) OR
					0 < (SELECT count(1) FROM DatosDelPaciente WHERE esAlergicoAPenicilina = 1)
				)
		) g1,
		Asignaciones a
	WHERE
		a.id IN (13)
);
*/
