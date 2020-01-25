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
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-2Seratia-Etapa2', 'Ingresando la asignación de medicamentos (ARk) cuando 2.Serratia, Enterobacter, Citrobacter, Aeromonas, Morganella, Proteus vulgaris, Proteus penneri, Acinetobacter y Providencia');

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
			g.idBacteria IN (26,30,31,34)
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
			(dp1.idParteDelCuerpo = 0 AND a.id IN (36,40)) OR
			(dp1.idParteDelCuerpo = 1 AND a.id IN (36,37)) OR
			(dp1.idParteDelCuerpo = 2 AND a.id IN (36,40)) OR
			(dp1.idParteDelCuerpo = 3 AND a.id IN (47,37,40)) OR
			(dp1.idParteDelCuerpo = 4 AND a.id IN (37,36,18,21)) OR
			(dp1.idParteDelCuerpo = 5 AND a.id IN (36,40)) OR
			(dp1.idParteDelCuerpo = 6 AND a.id IN (36,22,40)) OR
			(dp1.idParteDelCuerpo = 7 AND a.id IN (36,40)) OR
			(dp1.idParteDelCuerpo = 8 AND a.id IN (40,48)) 
			
	) a2;

/*
•	Cuando es resistente (es decir > o =) a algún antibiótico dentro de las opciones mencionadas, entonces ese antibiótico no puede aparecer dentro de las opciones
*/
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
		g.idBacteria IN (26,30,31,34) AND 
		g.operador IN ('>=') AND
		a.idAntibiotico > 1
);

