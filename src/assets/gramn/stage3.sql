/*
    Eliminar antibioticos de la respuesta cuando son =. >=	
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Eliminando los antibioticos de resultado que no aplican por =, >=.');


DELETE FROM InterpretacionGRAMEtapa2 WHERE idAsignacion IN (
SELECT 
	a.idAsignacion
FROM
	GRAM g
	
	INNER JOIN asignacionAntibiotico a
		ON (a.idAntibiotico = g.idAntibiotico)
		
WHERE
	g.operador IN ('>=', '=') AND
	a.idAntibiotico > 1
);

/*
ETAPA 3
*/	
/*
    Clindamycin: 600 a 900 mg IV/VO cada 8 horas	
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Clindamycin.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    '600 a 900 mg IV/VO cada 8 horas'
FROM
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 12;
    
/*
    Gentamicin: 
        -	DepuracionCreatinina Mayor de 60: Dosis de carga de 7 mg/kg (7 * peso mg) cada 24 horas y luego 4 mg/kg 
            (4 * peso mg) cada 24 horas a lo largo de 1 hora
        -	DepuracionCreatinina de 20 a 60: Dosis de carga de 7 mg/kg (7 * peso mg) cada 24 horas y luego 3 mg/kg 
            (3 * peso mg)  cada 24 horas
        -	DepuracionCreatinina Menos de 20: Dosis de carga de 7 mg/kg (7 * peso mg)  cada 24 horas y luego 3 mg/kg 
            (3 * peso mg)  cada 48 horas
        -	snHemodialisis = 1: Dosis de carga de 7 mg/kg (7 * peso mg), seguido a las 24 horas de 2 mg/kg (2 * peso mg) 
            cada 72 horas, haciendo que coincida con los días de diálisis y se aplique DESPUES de la HD (corroborar niveles)
        -	CRRT = 1: No se recomienda
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Gentamicin.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN 'No se recomienda'
            WHEN CRRT = 0 AND requiereHemodialisis = 1 THEN 
                'Dosis de carga de 7 mg/kg (' || (7*dp1.peso) || ' mg), seguido a las 24 horas de 2 mg/kg (' || (2*dp1.peso) || ' mg) cada 72 horas, haciendo que coincida con los días de diálisis y se aplique DESPUES de la HD (corroborar niveles)'
            WHEN CRRT = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 60 THEN 
                'Dosis de carga de 7 mg/kg (' || (7*dp1.peso) || ' mg) cada 24 horas y luego 4 mg/kg (' || (4*dp1.peso) || ' mg) cada 24 horas a lo largo de 1 hora'
            WHEN CRRT = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 20 AND depuracionCreatinina < 60 THEN 
                'Dosis de carga de 7 mg/kg (' || (7*dp1.peso) || ' mg) cada 24 horas y luego 3 mg/kg (' || (3*dp1.peso) || ' mg) cada 24 horas'
            WHEN CRRT = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 20 THEN 
                'Dosis de carga de 7 mg/kg (' || (7*dp1.peso) || ' mg) cada 24 horas y luego 3 mg/kg (' || (3*dp1.peso) || ' mg) cada 48 horas'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 28;
    
/*
    Linezolid: 
    -	600 mg IV/VO cada 12 horas	
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Linezolid.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    '600 mg IV/VO cada 12 horas'
FROM
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 11;
    
/*
    Oxacillin: 
    -	2 gm IV cada 4 horas
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Oxacillin.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    '2 gm IV cada 4 horas'
FROM
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 1;
    
/*
    Rifampicin: 
    -	600 mg VO cada 12 horas	
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Rifampicin.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    '600 mg VO cada 12 horas'
FROM
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion IN (7,25,49);
    
/*
    Tetracycline (Minociclina): 
    -	100 mg VO cada 12 horas 	

*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Tetracycline (Minociclina).');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    '600 a 900 mg IV/VO cada 8 horas'
FROM
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 29;

/*
    Trimethoprim/Sulfa:	
    -	DepuracionCreatinina Mayor de 30: De 5 a 20 mg/kg/día (5 * peso mg/día a 20 * peso mg/día) dividido cada 6 a 12 horas.
    -	DepuracionCreatinina de 10 a 30: De 5 a 10 mg/kg/día (5 * peso mg/día a 10 * peso mg/día) dividido cada 12 horas.
    -	DepuracionCreatinina Menor de 10: No se recomienda
    -	snHemodialisis: No se recomienda
    -	snCAPD: No se recomienda
    -	CRRT: No se recomienda
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Trimethoprim/Sulfa.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 OR CAPD = 1 OR requiereHemodialisis = 1 OR depuracionCreatinina < 10 THEN 
                'No se recomienda'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 30 THEN 
                'De 5 a 20 mg/kg/día (' || (5*dp1.peso) || ' mg/día a ' || (20*dp1.peso) || ' mg/día) dividido cada 6 a 12 horas.'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 30 THEN 
                'De 5 a 10 mg/kg/día (' || (5*dp1.peso) || ' mg/día a ' || (10*dp1.peso) || ' mg/día) dividido cada 12 horas.'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 30;

/*
    Vancomycin:
    -	DepuracionCreatinina Mayor de 50: De 15 a 30 mg/kg (15 * peso mg a 30 * peso mg) cada 12 horas.
    -	DepuracionCreatinina de 10 a 50: 15 mg/kg (15 * peso mg) cada 24 horas.
    -	DepuracionCreatinina Menos de 10: No se recomienda
    -	snHemodialisis: No se recomienda
    -	snCAPD: No se recomienda
    -	CRRT: No se recomienda
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Vancomycin.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 OR CAPD = 1 OR requiereHemodialisis = 1 OR depuracionCreatinina < 10 THEN 
                'No se recomienda'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 50 THEN 
                'De 15 a 30 mg/kg (' || (15*dp1.peso) || ' mg a ' || (30*dp1.peso) || ' mg) cada 12 horas.'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 50 THEN 
                '15 mg/kg (' || (15*dp1.peso) || ' mg) cada 24 horas.'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 13;

/*
    Nitrofurantoin:
    -	DepuracionCreatinina Mayor de 50: De 50 a 100 mg VO cada 6 a 8 horas
    -	DepuracionCreatinina Menor de 50: No se recomienda	
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Nitrofurantoin.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN depuracionCreatinina < 50 THEN 'No se recomienda'
            WHEN depuracionCreatinina >= 50 THEN 'De 50 a 100 mg VO cada 6 a 8 horas'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 21;

/*
    Daptomycin:
    -	DepuracionCreatinina Mayor de 30: 8 a 10 mg/kg (8  * peso mg a 10 * peso mg) cada 24 horas 
    -	DepuracionCreatinina Menos de 30: 8 mg/kg (8  * peso mg) cada 48 horas
    -	snHemodialisis: 8 mg/kg (8  * peso mg) cada 48 horas (dosis luego de HD)
    -	snCAPD: 8 mg/kg (8  * peso mg) cada 48 horas
    -	CRRT: 8 mg/kg (8  * peso mg) cada 48 horas
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Daptomycin.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 OR CAPD = 1 THEN '8 mg/kg (' || (8*dp1.peso) || ' mg) cada 48 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN 
                '8 mg/kg (' || (8*dp1.peso) || ' mg) cada 48 horas (dosis luego de HD)'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 30 THEN 
                '8 a 10 mg/kg (' || (8*dp1.peso) || ' mg a ' || (10*dp1.peso) || ' mg) cada 24 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 30 THEN 
                '8 mg/kg (' || (8*dp1.peso) || ' mg) cada 48 horas'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 10;


/*
    Amikacin:
    -	DepuracionCreatinina Mayor de 80: 15 mg/kg (15  * peso mg)  cada 24 horas
    -	DepuracionCreatinina de 60 a 80: 12 mg/kg (12  * peso mg)  cada 24 horas
    -	DepuracionCreatinina de 40 a 60: 7.5 mg/kg (7.5  * peso mg)  cada 24 horas
    -	DepuracionCreatinina  de 30 a 40: 4 mg/kg (4  * peso mg)  cada 24 horas
    -	DepuracionCreatinina  de 20 a 30: 7.5 mg/kg (7.5  * peso mg)  cada 48 horas
    -	DepuracionCreatinina  de 10 a 20: 4 mg/kg (4  * peso mg)  cada 48 horas
    -	snHemodialisis: 7.5 mg/kg (7.5  * peso mg)  cada 48 horas, y 3.75 mg/kg  (3.75  * peso mg) adicional después de HD (corroborar niveles)
    -	CRRT: 7.5 mg/kg/día (7.5  * peso mg)
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Amikacin.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '7.5 mg/kg/día (' || (7.5*dp1.peso) || ' mg)'
            WHEN CRRT = 0 AND requiereHemodialisis = 1 THEN '7.5 mg/kg (' || (7.5*dp1.peso) || ' mg)  cada 48 horas, y 3.75 mg/kg  (' || (3.75*dp1.peso) || ' mg) adicional después de HD (corroborar niveles)'
            WHEN CRRT = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 80 THEN 
                '15 mg/kg (' || (15*dp1.peso) || ' mg)  cada 24 horas'
            WHEN CRRT = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 60 AND depuracionCreatinina < 80 THEN 
                '12 mg/kg (' || (12*dp1.peso) || ' mg)  cada 24 horas'
            WHEN CRRT = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 40 AND depuracionCreatinina < 60 THEN 
                '7.5 mg/kg (' || (7.5*dp1.peso) || ' mg)  cada 24 horas'
            WHEN CRRT = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 30 AND depuracionCreatinina < 40 THEN 
                '4 mg/kg (' || (4*dp1.peso) || ' mg)  cada 24 horas'
            WHEN CRRT = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 20 AND depuracionCreatinina < 30 THEN 
                '7.5 mg/kg (' || (7.5*dp1.peso) || ' mg)  cada 24 horas'
            WHEN CRRT = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 20 THEN 
                '4 mg/kg (' || (4*dp1.peso) || ' mg)  cada 24 horas'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 31;
    
/*
    Ampicillin:
    -	DepuracionCreatinina Mayor de 50: De 1 a 2 gm cada 4 a 6 horas
    -	DepuracionCreatinina de 30 a 50: De 1 a 2 gm cada 6 a 8 horas
    -	DepuracionCreatinina de 10 a 30: De 1 a 2 gm cada 8 a 12 horas
    -	DepuracionCreatinina Menos de 10: De 1 a 2 gm cada 12 horas
    -	snHemodialisis: De 1 a 2 gm cada 12 horas
    -	snCAPD: De 0.5 gm a 1 gm cada 12 horas
    -	CRRT: De 1 a 2 gm cada 8 a 12 horas

    ** Cuando el órgano seleccionado es Sistema nervioso central o Próstata, debe ser solo la dosis máxima.

    La dosis máxima es:
    o	DepuracionCreatinina Mayor de 50: 2 gm cada 4 horas
    o	DepuracionCreatinina de 30 a 50: 2 gm cada 6 horas
    o	DepuracionCreatinina de 10 a 30: 2 gm cada 8 horas
    o	DepuracionCreatinina Menos de 10: 2 gm cada 12 horas
    o	snHemodialisis: 2 gm cada 12 horas
    o	snCAPD: 1 gm cada 12 horas
    o	CRRT: 2 gm cada 8 horas
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Ampicillin.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '2 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 1 THEN '1 gm cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN '2 gm cada 12 horas'
            
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 50 THEN '2 gm cada 4 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 30 AND depuracionCreatinina < 50 THEN '2 gm cada 6 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 30 THEN '2 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 10 THEN '2 gm cada 12 horas'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion in (17,20) AND
    e2.idParteDelCuerpo IN (0,6);
    
INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN 'De 1 a 2 gm cada 8 a 12 horas'
            WHEN CRRT = 0 AND CAPD = 1 THEN 'De 0.5 gm a 1 gm cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN 'De 1 a 2 gm cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 50 THEN 
                'De 1 a 2 gm cada 4 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 30 AND depuracionCreatinina < 50 THEN 
                'De 1 a 2 gm cada 6 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 30 THEN 
                'De 1 a 2 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 10 THEN 
                'De 1 a 2 gm cada 12 horas'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion in (17,20) AND
    e2.idParteDelCuerpo NOT IN (0,6);

/*
    Ampicillin/Sulbactam:
    -	DepuracionCreatinina Mayor de 50: 3 gm cada 6 horas
    -	DepuracionCreatinina de 10 a 50: 3 gm cada 8 a 12 horas
    -	DepuracionCreatinina Menor de 10: 3 gm al día
    -	snHemodialisis: 3 gm al día (dosis luego de HD)
    -	snCAPD: 3 gm al día
    -	CRRT: 3 gm cada 12 horas	
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Ampicillin/Sulbactam.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '3 gm cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 1 THEN '3 gm al día'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN '3 gm al día (dosis luego de HD)'
            
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 50 THEN '3 gm cada 6 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 50 THEN '3 gm cada 8 a 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 10 THEN '3 gm al día'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion in (4,5,6);

/*
    Aztreonam:
    -	DepuracionCreatinina Mayor de 50: 2 gm cada 8 horas
    -	DepuracionCreatinina de 10 a 50: De 1 a 1.5 gm cada 8 horas
    -	DepuracionCreatinina Menor de 10: De 1 a 2 gm al día
    -	snHemodialisis: De 1 a 2 gm al día (dosis luego de HD)
    -	snCAPD: 500 mg cada 8 horas
    -	CRRT: De 1 a 1.5 gm cada 8 horas
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Aztreonam.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN 'De 1 a 1.5 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 1 THEN '500 mg cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN 'De 1 a 2 gm al día (dosis luego de HD)'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 50 THEN 
                '2 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 50 THEN 
                'De 1 a 1.5 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 10 THEN 
                'De 1 a 2 gm al día'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 32;
    
/*
    Penicilina:
    -	DepuracionCreatinina Mayor de 50: De 1 a 4 millones UI cada 4 horas
    -	DepuracionCreatinina de10 a 50: De 1 a 4 millones de UI cada 8 horas
    -	DepuracionCreatinina Menor de 10: De 1 a 4 millones de UI cada 12 horas
    -	snHemodialisis: De 1 a 4 millones de UI cada 12 horas (dosis luego de HD) 
    -	snCAPD: De 1 a 4 millones de UI cada 12 horas
    -	CRRT: De 1 a 4 millones de UI cada 6 a 8 horas

    ** Cuando el órgano seleccionado es Sistema nervioso central o Próstata, debe ser solo la dosis máxima.

    La dosis máxima es:
    o	DepuracionCreatinina Mayor de 50: 4 millones UI cada 4 horas
    o	DepuracionCreatinina de10 a 50: De 4 millones de UI cada 8 horas
    o	DepuracionCreatinina Menor de 10: 4 millones de UI cada 12 horas
    o	snHemodialisis: 4 millones de UI cada 12 horas (dosis luego de HD) 
    o	snCAPD: 4 millones de UI cada 12 horas
    o	CRRT: 4 millones de UI cada 6 a 8 horas
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Penicilina.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '4 millones de UI cada 6 a 8 horas'
            WHEN CRRT = 0 AND CAPD = 1 THEN '4 millones de UI cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN 
                '4 millones de UI cada 12 horas (dosis luego de HD) '
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 50 THEN 
                '4 millones UI cada 4 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 50 THEN 
                '4 millones de UI cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 10 THEN '4 millones de UI cada 12 horas'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion IN (23,24) AND
    e2.idParteDelCuerpo IN (0,6);
    
INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN 'De 1 a 4 millones de UI cada 6 a 8 horas'
            WHEN CRRT = 0 AND CAPD = 1 THEN 'De 1 a 4 millones de UI cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN 
                'De 1 a 4 millones de UI cada 12 horas (dosis luego de HD) '
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 50 THEN 
                'De 1 a 4 millones UI cada 4 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 50 THEN 
                'De 1 a 4 millones de UI cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 10 THEN 
                'De 1 a 4 millones de UI cada 12 horas'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion IN (23,24) AND
    e2.idParteDelCuerpo NOT IN (0,6);
    
/*
    Cefazolin:
    -	DepuracionCreatinina Mayor de 50: 2 gm cada 6 horas
    -	DepuracionCreatinina de 10 a 50: 2 gm cada 8 horas
    -	DepuracionCreatinina Menor de 10: 2 gm cada 12 horas
    -	snHemodialisis: 2 gm al día (dosis luego de HD)
    -	snCAPD: 1 gm cada 12 horas	
    -	CRRT: 2 gm cada 12 horas
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Cefazolin.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '2 gm cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 1 THEN '1 gm cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN '2 gm al día (dosis luego de HD)'
            
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 50 THEN '2 gm cada 6 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 50 THEN '2 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 10 THEN '2 gm cada 12 horas'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 9;
    
/*
    Cefepime:
    -	DepuracionCreatinina Mayor de 60: 2 gm cada 8 horas
    -	DepuracionCreatinina de 30 a 60: 2 gm cada 12 horas
    -	DepuracionCreatinina de 10 a 30: 2 gm al día
    -	DepuracionCreatinina Menor de 10: 1 gm al día
    -	snHemodialisis: 1 gm al día (dosis luego de HD)
    -	snCAPD: 2 gm cada 48 horas
    -	CRRT: 2 gm cada 12 horas	

*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Cefepime.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '2 gm cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 1 THEN '2 gm cada 48 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN '1 gm al día (dosis luego de HD)'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 60 THEN 
                '2 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 30 AND depuracionCreatinina < 60 THEN 
                '2 gm cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 30 THEN 
                '2 gm al día'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 10 THEN 
                '1 gm al día'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion IN (33,50);
    
/*
    Ceftazidime:
    -	DepuracionCreatinina Mayor de 50: 2 gm cada 8 horas
    -	DepuracionCreatinina de 10 a 50: 2 gm cada 12 horas
    -	DepuracionCreatinina Menor de 10: 2 gm al día
    -	CRRT: 1.5 gm cada 8 horas	

*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Ceftazidime.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '1.5 gm cada 8 horas'
            
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 50 THEN '2 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 50 THEN '2 gm cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 10 THEN '2 gm al día'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 34;
            
/*
    Ceftriaxone: 
    -	1 gm cada 12 horas

    ** Cuando el órgano seleccionado es Sistema nervioso central o Próstata, debe ser la dosis: 2 gm cada 12 horas
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Ceftriaxone.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    '1 gm cada 12 horas'
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion IN (35,2,19) AND
    e2.idParteDelCuerpo NOT IN (0,6);

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    '2 gm cada 12 horas'
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion IN (35,2,19) AND
    e2.idParteDelCuerpo IN (0,6);
 
/*
    Cefotaxime:
    -	DepuracionCreatinina Mayor de 50: 2 gm cada 8 horas
    -	DepuracionCreatinina de 10 a 50: 2 gm cada 12 horas
    -	DepuracionCreatinina Menor de 10: 2 gm al día
    -	CRRT: 1.5 gm cada 8 horas	
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Cefotaxime.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '1.5 gm cada 8 horaS'
            
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 50 THEN '2 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 50 THEN '2 gm cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 10 THEN '2 gm al día'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion IN (3,19);
        
/*
    Ciprofloxacin:
    -	DepuracionCreatinina Mayor de 50: 400 mg cada 8 horas
    -	DepuracionCreatinina de 10 a 50: 400 mg cada 12 horas
    -	DepuracionCreatinina Menor de 10: 400 mg al día	
    -	snHemodialisis: 400 mg al día (dosis luego de HD)
    -	snCAPD: 400 mg al día 
    -	CRRT: 400 mg cada 12 horas

*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Ciprofloxacin.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '400 mg cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 1 THEN '400 mg al día'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN '400 mg al día (dosis luego de HD)'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 50 THEN 
                '400 mg cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 50 THEN 
                '400 mg cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 10 THEN 
                '400 mg al día'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion IN (36,47,48);
    
/*
    Ertapenem:
    -	DepuracionCreatinina Mayor de 30: 1 gm al día
    -	DepuracionCreatinina Menor de 30: 500 mg al día
    -	snHemodialisis: 500 mg al día (dosis luego de HD)
    -	snCAPD: 500 mg al día
    -	CRRT: 1 gm al día	
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Ertapenem.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '1 gm al día'
            WHEN CRRT = 0 AND CAPD = 1 THEN '500 mg al día'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN '500 mg al día (dosis luego de HD)'
            
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 30 THEN '1 gm al día'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 30 THEN '500 mg al día'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 37;

/*	
    Colistin: 
    -	Verificar con Infectología la dosis
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Colistin.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    'Verificar con Infectología la dosis'
FROM
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 38;

/*
    Imipenem:
    -	DepuracionCreatinina Mayor de 60: 500 mg cada 6 horas
    -	DepuracionCreatinina de 30 a 60: 500 mg cada 8 horas
    -	DepuracionCreatinina Menos de 30: 500 mg cada 12 horas
    -	snHemodialisis: 500 mg cada 12 horas
    -	snCAPD: 250 mg cada 12 horas
    -	CRRT: 500 mg cada 12horas	
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Imipenem.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '500 mg cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 1 THEN '250 mg cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN '500 mg cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 60 THEN 
                '500 mg cada 6 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 30 AND depuracionCreatinina < 60 THEN 
                '500 mg cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 30 THEN 
                '500 mg cada 12 horas'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 39;

/*
    Meropenem:
    -	DepuracionCreatinina Mayor de 50: 1 gm cada 8 horas
    -	DepuracionCreatinina de 25 a 50: 1 gm cada 12 horas
    -	DepuracionCreatinina  de 10 a 25: 500 mg cada 12 horas
    -	DepuracionCreatinina Menos de 10: 500 mg al día
    -	snHemodialisis: 500 mg al día (dosis luego de HD)	
    -	snCAPD: 500 mg al día
    -	CRRT: 1 gm cada 12 horas

    ** Cuando el órgano seleccionado es Sistema nervioso central o Próstata, debe ser la dosis: 2 gm cada 8 horas
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Meropenem.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '1 gm cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 1 THEN '500 mg al día'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN '500 mg al día (dosis luego de HD)'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 50 THEN 
                '1 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 25 AND depuracionCreatinina < 50 THEN 
                '1 gm cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 25 THEN 
                '500 mg cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 10 THEN 
                '500 mg al día'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion IN (40) AND
    e2.idParteDelCuerpo NOT IN (0,6);

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '1 gm cada 12 horas'
            WHEN CRRT = 0 AND CAPD = 1 THEN '500 mg al día'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN '500 mg al día (dosis luego de HD)'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 50 THEN '2 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 25 AND depuracionCreatinina < 50 THEN 
                '2 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 10 AND depuracionCreatinina < 25 THEN 
                '2 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 10 THEN 
                '2 gm cada 8 horas'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion IN (40) AND
    e2.idParteDelCuerpo IN (0,6);
 
/*
    Doripenem:
    -	DepuracionCreatinina Mayor de 50: 0.5 a 1 gm cada 8 horas
    -	DepuracionCreatinina de 30 a 50: 250 a 500 mg cada 8 horas
    -	DepuracionCreatinina de 10 a 30: 250 mg cada 12 horas
    -	CRRT: 500 mg cada 8 horas	

*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Doripenem.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '500 mg cada 8 horas'
            
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 60 THEN '0.5 a 1 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 30 AND depuracionCreatinina < 60 THEN '250 a 500 mg cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 30 THEN '250 mg cada 12 horas'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 41;

/*
    Piperacillin/Tazobactam:
    -	DepuracionCreatinina Mayor de 40: 4.5 gm cada 6 horas
    -	DepuracionCreatinina  de20 a 40: 4.5 gm cada 8 horas
    -	DepuracionCreatinina Menos de 20: 2.25 gm cada 6 horas
    -	snHemodialisis: 2.25 gm cada 6 horas
    -	snCAPD: 2.25 gm cada 8 horas
    -	CRRT: 4.5 gm cada 8 horas 	
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Piperacillin/Tazobactam.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    (
        CASE 
            WHEN CRRT = 1 THEN '54.5 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 1 THEN '2.25 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 1 THEN '2.25 gm cada 6 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 40 THEN 
                '4.5 gm cada 6 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina >= 20 AND depuracionCreatinina < 40 THEN 
                '4.5 gm cada 8 horas'
            WHEN CRRT = 0 AND CAPD = 0 AND requiereHemodialisis = 0 AND depuracionCreatinina < 20 THEN 
                '2.25 gm cada 6 horas'
        END
    )
FROM
    DatosDelPaciente dp1,
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion IN (42,43,44,45);

/*	
    Tigecycline: 
    -	Dosis de carga de 100 mg y luego 50 mg cada 12 horas
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('GRAMNegativo-Etapa3', 'Ingresando el mensaje que indica la dosis para el antibiótico Tigecycline.');

INSERT INTO InterpretacionGRAMEtapa3 (idAsignacion, mensaje)	
SELECT
    e2.idAsignacion,
    'Dosis de carga de 100 mg y luego 50 mg cada 12 horas'
FROM
    InterpretacionGRAMEtapa2 e2
WHERE	
    e2.idAsignacion = 16;