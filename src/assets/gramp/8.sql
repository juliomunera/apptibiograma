/*
	ETAPA 1
*/	

/*
	Cuando todos los antibióticos Aj del formulario sean sensibles, debe salir el mensaje “Germen sensible a todo el panel
	de antibióticos, pero con resistencia intrínseca a Clindamicina, Quinolonas, Trimetoprim-sulfa, Ampicilina, Penicilina 
	y Cefalosporinas”
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-EnterecoccusFaecium-Etapa1','Ingresando el mensaje que indica que el germen es sensible a todo el panel de antibióticos.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g1.idBacteria, 
	1 as idAntibiotico,
	'Germen sensible a todo el panel de antibióticos, pero con resistencia intrínseca a Clindamicina, Quinolonas, Trimetoprim-sulfa, Ampicilina, Penicilina y Cefalosporinas'
FROM
	(
		SELECT g.idBacteria, COUNT(1) as total
		FROM
			GRAM g
		WHERE
			g.tipoGRAM = '+' AND
			g.idBacteria = 8 AND 
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
			g.idBacteria = 8 AND 
			g.idPrueba = 1
	) g2
	ON (g1.total = g2.total);
		
/*
	Cuando Aj = Vancomicina es un numero entero (es decir signo =), debe salir un mensaje que diga “Germen con sensibilidad
	 disminuida a Vancomicina”
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-EnterecoccusFaecium-Etapa1','Ingresando el mensaje que indica que el germen presenta sensibilidad disminuida a Vancomicina.');

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
	g.idBacteria = 8 AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 10 AND 
	g.operador = '=';

/*
	Cuando Vancomicina es resistente (es decir signo >=) debe salir un mensaje que diga “Germen resistente a Vancomicina 
	mediado por VAN-A o VAN-B, por favor corrobore con un laboratorio de referencia”
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-EnterecoccusFaecium-Etapa1','Ingresando el mensaje que indica que el germen es resistente a Vancomicina mediado por VAN-A o VAN-B, por lo que se deberá corroborar con un laboratorio de referencia.');

INSERT INTO InterpretacionGRAMEtapa1 (idParteDelCuerpo, idBacteria, idAntibiotico, mensaje)
SELECT
	(SELECT dp.idParteDelCuerpo FROM DatosDelPaciente dp), 
	g.idBacteria, 
	g.idAntibiotico,
	'Germen resistente a Vancomicina mediado por VAN-A o VAN-B, por favor corrobore con un laboratorio de referencia'
FROM
	GRAM g
WHERE
	g.tipoGRAM = '+' AND
	g.idBacteria = 8 AND 
	g.idPrueba = 1 AND
	g.idAntibiotico = 10 AND 
	g.operador = '>=';

/*
	ETAPA 2
*/	
	
/*
	Cuando la infección es en:
		* Sistema nervioso central: 0
			- Daptomicina
			- Linezolide
		* Boca y senos paranasales: 1
			- Vancomicina
			- Tigeciclina
			- Linezolide
		* Pulmones: 2
			- Vancomicina
			- Linezolide
		* Tejidos blandos: 7
			- Vancomicina
			- Linezolide
		* Hueso: 5
			- Vancomicina
			- Daptomicina
			- Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis)
		* Abdomen: 3
			- Vancomicina, 
			- Tigeciclina
			- Linezolide
		* Tracto genitourinario: 4
			- Fosfomycin (pielonefritis: 3gm cada 3 dias por 7 dosis y cistitis 3 gm dosis unica)
			- Nitrofurantoin (solo cistitis)
			- Vancomicina
			- Linezolide
		* Próstata: 6
			- Fosfomycin (3gm cada 3 dias por 7 dosis)
			- Vancomicina
		* Sangre: 8
			- Vancomicina
			- Daptomicina
	
	**Si es además resistente a Vancomicina, se quita Vancomicina de todas las opciones donde aparece
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMPositivo-EnterecoccusFaecium-Etapa2', 'Ingresando la asignación de medicamentos (ARk).');

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
			g.idBacteria = 8
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
VALUES ('GRAMPositivo-EnterecoccusFaecium-Etapa2', 'Eliminando de la asignación de medicamentos (ARk) la Vancomicina.');

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
				g.idBacteria = 8 AND 
				(g.idAntibiotico = 10 AND g.operador = '>=')
		) g1,
		Asignaciones a
	WHERE
		a.id = 13
);
