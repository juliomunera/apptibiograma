/*
	Para la implementación del proceso de análisis de los antibióticos a usar en el tratamiento de cada una de las familias de bacterias
	se requiere de la siguientes estructuras de información sobre la base de datos Biograma, la cual  residirá  sobre  cada  dispositivo
	donde se ejecuete la aplicación móvil.
/*

/*
	Bacterias: Entidad maestra donde se almacenan las bacterias configuradas a las que se les podra realizar el análisis GRAM.
*/
DROP TABLE IF EXISTS Bacterias;

CREATE TABLE Bacterias (
    id INTEGER PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
	tipoGRAM CHAR(1) DEFAULT ('+') CHECK (tipoGRAM = '+' OR tipoGRAM = '-') NOT NULL
);	

/*
	Antibioticos: Entidad maestra donde se guardan los antibióticos usados para el análisis GRAM de las bacterias configuradas.
*/
DROP TABLE IF EXISTS Antibioticos;

CREATE TABLE Antibioticos (
    id INTEGER PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);	


/*
	Pruebas: Entidad maestra que almacena los tipos de pruebas requeridas para evaluar la sensibilidad y/o resistencia de un antibiótico.
*/
DROP TABLE IF EXISTS Pruebas;

CREATE TABLE Pruebas (
    id INTEGER PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);	


/*
	PartesDelCuerpo: Entidad  maestra donde se persiste las partes del cuerpo  que  pueden verse afectadas por las diferentes  bacterias
	configuradas .
*/
DROP TABLE IF EXISTS PartesDelCuerpo;

CREATE TABLE PartesDelCuerpo (
	id INTEGER PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL
);

/*
	Asignaciones: Entidad maestra donde se guardan las diversas asiganciones de antibióticos y comentarios generados durante la ejecución
	de la segunda etapa del análisis GRAM.
*/

DROP TABLE IF EXISTS Asignaciones;

CREATE TABLE Asignaciones (
    id INTEGER PRIMARY KEY,
	comentariosTratamiento VARCHAR2(250) NOT NULL
);

/*
	Entidad usada  para almacenar la combinación de los antibioticos y pruebas que pueden usarse para el tratamiento de cada una de  las 
	bacterias configuradas.  Importante  anotar que los  datos almacenados  en  esta  entidad  serán  usados  para  la  visualización  y 
	diligeniciamiento de los valores de referencia de cada antibiotico.
*/
DROP TABLE IF EXISTS CBxA;

CREATE TABLE CBxA (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idBacteria INTEGER NOT NULL,
	idAntibiotico INTEGER NOT NULL,
	idPrueba INTEGER NOT NULL,
	tipoControl VARCHAR(20) NOT NULL,
	tipoGRAM CHAR(1) CHECK (tipoGRAM = '+' OR tipoGRAM = '-') NOT NULL,
	
	FOREIGN KEY(idBacteria) REFERENCES Bacterias(id)
	FOREIGN KEY(idAntibiotico) REFERENCES Antibioticos(id)
	FOREIGN KEY(idPrueba) REFERENCES Pruebas(id)
);	

CREATE INDEX IF NOT EXISTS IDX_CBxA_idBacteria_idAntibiotico ON CBxA (idBacteria,idAntibiotico);


/*
	Entidad usada para almacenar la información básica del paciente en evaluación.
*/
DROP TABLE IF EXISTS DatosDelPaciente;

CREATE TABLE DatosDelPaciente (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	idParteDelCuerpo INTEGER,
	fechaRegistro DATETIME DEFAULT (DATETIME('now')),
	genero CHAR(1) CHECK (genero = 'F' OR  genero = 'M') NOT NULL,
	edad INTEGER CHECK (edad > 0 AND edad < 140) NOT NULL,	
	peso REAL,	
	creatinina REAL,
	esAlergicoAPenicilina BOOLEAN,
	requiereHemodialisis BOOLEAN,
	CAPD BOOLEAN,
	CRRT BOOLEAN,	
	depuracionCreatinina DECIMAL(10,2) DEFAULT (0.0),
	
	FOREIGN KEY(idParteDelCuerpo) REFERENCES PartesDelCuerpo(id)
);

/*
	Entidad usada para almacenar la combinación de los antibioticos y pruebas que pueden usarse para el tratamiento de cada  una  de las  
	bacterias  configuradas.  Importante  anotar  que  los  datos  almacenados  en  esta  entidad  serán  usados para la visualización y 
	diligenciamiento de los valores de referencia GRAM para cada antibiótico asociado a la bacteria en proceso.
*/
DROP TABLE IF EXISTS GRAM;

CREATE TABLE GRAM (
	id INTEGER PRIMARY KEY AUTOINCREMENT,		
	idBacteria INTEGER NOT NULL,		
	idAntibiotico INTEGER NOT NULL,
	idPrueba INTEGER NOT NULL,
	operador VARCHAR(2),
	valor DECIMAL(10,5),
	tipoGRAM CHAR(1) CHECK(tipoGRAM = "+" OR tipoGRAM = "-") NOT NULL,

	FOREIGN KEY(idBacteria) REFERENCES Bacterias(id)
	FOREIGN KEY(idAntibiotico) REFERENCES Antibioticos(id)
	FOREIGN KEY(idPrueba) REFERENCES Pruebas(id)
);

CREATE INDEX IF NOT EXISTS IDX_GRAM_tipoGRAM ON GRAM( tipoGRAM );
CREATE INDEX IF NOT EXISTS IDX_GRAM_operador ON GRAM( operador );
CREATE INDEX IF NOT EXISTS IDX_GRAM_idBacteria_idPrueba ON GRAM( idBacteria, idPrueba );
CREATE INDEX IF NOT EXISTS IDX_GRAM_idBacteria_idAntibiotico_operador ON GRAM( idBacteria, idAntibiotico, operador );


DROP TABLE IF EXISTS TMP_GRAM;

CREATE TABLE TMP_GRAM (
	id INTEGER,		
	idBacteria INTEGER,		
	idAntibiotico INTEGER,
	idPrueba INTEGER,
	operador VARCHAR(2),
	valor DECIMAL(10,5),
	tipoGRAM CHAR(1)
);

CREATE INDEX IF NOT EXISTS IDX_TMP_GRAM_tipoGRAM ON TMP_GRAM( tipoGRAM );
CREATE INDEX IF NOT EXISTS IDX_TMP_GRAM_operador ON TMP_GRAM( operador );
CREATE INDEX IF NOT EXISTS IDX_TMP_GRAM_idBacteria_idPrueba ON TMP_GRAM( idBacteria, idPrueba );
CREATE INDEX IF NOT EXISTS IDX_TMP_GRAM_idBacteria_idAntibiotico_operador ON TMP_GRAM( idBacteria, idAntibiotico, operador );


/*
	Entidad donde se persiste los resultados generados en la 1era. etapa del análisis GRAM (interpretación de los valores  de referencia
	y generación de mensajes).
*/

DROP TABLE IF EXISTS InterpretacionGRAMEtapa1;

CREATE TABLE InterpretacionGRAMEtapa1 (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	idParteDelCuerpo INTEGER NOT NULL, 
	idBacteria INTEGER NOT NULL, 
	idAntibiotico INTEGER NOT NULL, 
	mensaje VARCHAR2(250) NOT NULL,
	
	FOREIGN KEY(idParteDelCuerpo) REFERENCES PartesDelCuerpo(id)
	FOREIGN KEY(idAntibiotico) REFERENCES Antibioticos(id)
	FOREIGN KEY(idBacteria) REFERENCES Bacterias(id)
);

/*
	Entidad donde se persiste los resultados generados en la 2da. etapa del análisis GRAM (asignación de medicamentos ARk).
*/
DROP TABLE IF EXISTS InterpretacionGRAMEtapa2;

CREATE TABLE InterpretacionGRAMEtapa2 (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	idParteDelCuerpo INTEGER NOT NULL, 
	idBacteria INTEGER NOT NULL, 
	idAntibiotico INTEGER NOT NULL, 
	idAsignacion INTEGER NOT NULL,
	mensaje VARCHAR2(250) NOT NULL,
	
	FOREIGN KEY(idParteDelCuerpo) REFERENCES PartesDelCuerpo(id)
	FOREIGN KEY(idAntibiotico) REFERENCES Antibioticos(id)
	FOREIGN KEY(idAsignacion) REFERENCES Asignaciones(id)
	FOREIGN KEY(idBacteria) REFERENCES Bacterias(id)
);

/*
	Entidad donde se persiste los resultados generados en la 3da. etapa del analisis GRAM.
*/
DROP TABLE IF EXISTS InterpretacionGRAMEtapa3;

CREATE TABLE InterpretacionGRAMEtapa3 (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	idAsignacion INTEGER NOT NULL,
	mensaje VARCHAR2(250) NOT NULL,
	
	FOREIGN KEY(idAsignacion) REFERENCES Asignaciones(id)
);

/*
	Entidad NUEVA donde se relacionan las asignaciones con los Antibioticos que se ingresan
*/
DROP TABLE IF EXISTS asignacionAntibiotico;

CREATE TABLE asignacionAntibiotico (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	idAsignacion INTEGER NOT NULL,
	idAntibiotico INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS IDX_ASIGNACIONANTIBIOTICO_Antib ON asignacionAntibiotico( idAntibiotico );
CREATE INDEX IF NOT EXISTS IDX_ASIGNACIONANTIBIOTICO_Asig_Antib ON asignacionAntibiotico( idAsignacion, idAntibiotico );

/*
	Entidad donde se almacena el token otorgado para el acceder a la funciones expuestas por la APP.
*/
DROP TABLE IF EXISTS TokenSeguridad;

CREATE TABLE TokenSeguridad (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fechaRegistro DATETIME NOT NULL,
	dias INTEGER NOT NULL
);

/*
	Entidad donde se almacena los eventos generados duraante la ejecución de algunas de las funcionalidades 
	provistas por la APP.
*/
DROP TABLE IF EXISTS BitacoraEventos;

CREATE TABLE BitacoraEventos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fechaRegistro DATETIME DEFAULT (DATETIME('now')),
	tipoEvento VARCHAR(100),
	detalleEvento TEXT NOT NULL
);

DROP VIEW IF EXISTS AntibioticosPruebas;

CREATE VIEW AntibioticosPruebas AS
	SELECT Antibioticos.id, idBacteria, idAntibiotico, 
		idPrueba, tipoControl, tipoGRAM,  Antibioticos.nombre 
	FROM CBxA INNER JOIN Antibioticos ON CBxA.idAntibiotico = Antibioticos.id 
	WHERE idPrueba = 1
	UNION ALL           
	SELECT Pruebas.id, idBacteria, idAntibiotico, 
		idPrueba, tipoControl, tipoGRAM,  Pruebas.nombre 
	FROM CBxA INNER JOIN Pruebas ON CBxA.idPrueba = Pruebas.id 
	WHERE idPrueba <> 1;


DROP VIEW IF EXISTS EtapaUnoyEtapaDos;

CREATE VIEW EtapaUnoyEtapaDos AS
	SELECT idParteDelCuerpo, idBacteria, idAntibiotico, NULL as idAsignacion, mensaje
	FROM InterpretacionGRAMEtapa1
/*	UNION ALL           
	SELECT idParteDelCuerpo, idBacteria, idAntibiotico, idAsignacion, mensaje
	FROM InterpretacionGRAMEtapa2*/;
	
DROP VIEW IF EXISTS validarTestMsg;

CREATE VIEW validarTestMsg AS
	SELECT COUNT(1) as total
	FROM InterpretacionGRAMEtapa1 
	WHERE mensaje like 'Realizar D-test%' OR mensaje like 'Realizar test%';

/* Lista base de bacterias habilitados para el funcionamiento de la aplicación. */
DELETE FROM BitacoraEventos;

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Eliminando información de la tabla Bacterias.');

DELETE FROM Bacterias;

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Ingresando información a la tabla Bacterias.');

INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (1, 'NA', '+'); 
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (2, 'Staphylococcus aureus', '+');  
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (3, 'Staphylococcus epidermidis', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (4, 'Staphylococcus haemolyticus', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (5, 'Staphylococcus warneri', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (6, 'Staphylococcus lugdunensis', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (7, 'Enterococcus faecalis', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (8, 'Enterococcus faecium', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (9, 'Enterococcus gallinarum', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (10, 'Enterococcus casseliflavus', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (11, 'Streptococcus viridans', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (12, 'Streptococcus mitis', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (13, 'Streptococcus mutans', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (14, 'Streptococcus salivarius', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (15, 'Streptococcus pyogenes', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (16, 'Streptococcus agalactiae', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (17, 'Streptococcus dysgalactiae', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (18, 'Streptococcus pneumoniae', '+');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (19, 'Escherichia Coli', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (20, 'Klebsiella', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (21, 'Serratia', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (22, 'Enterobacter', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (23, 'Pseudomonas', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (24, 'Citrobacter', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (25, 'Aeromonas', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (26, 'Morganella', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (27, 'Stenotrophomonas maltophilia', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (28, 'Acinetobacter', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (29, 'Proteus mirabilis', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (30, 'Proteus vulgaris', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (31, 'Proteus penneri', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (32, 'Salmonella', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (33, 'Shigella', '-');
INSERT INTO Bacterias(id, nombre, tipoGRAM) VALUES (34, 'Providencia', '-');

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'El ingreso de información a la tabla Bacterias fue exitoso, 32 filas afectadas.');

/* Lista base de antibióticos habilitados para el funcionamiento de la aplicación. */
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Eliminando información de la tabla Antibioticos.');

DELETE FROM Antibioticos;

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Ingresando información a la tabla Antibioticos.');

INSERT INTO Antibioticos(id, nombre) VALUES (1, 'NA'); 
INSERT INTO Antibioticos(id, nombre) VALUES (2, 'Clindamycin');
INSERT INTO Antibioticos(id, nombre) VALUES (3, 'Erythromycin');
INSERT INTO Antibioticos(id, nombre) VALUES (4, 'Gentamicin');
INSERT INTO Antibioticos(id, nombre) VALUES (5, 'Linezolid');
INSERT INTO Antibioticos(id, nombre) VALUES (6, 'Oxacillin');
INSERT INTO Antibioticos(id, nombre) VALUES (7, 'Rifampicin');
INSERT INTO Antibioticos(id, nombre) VALUES (8, 'Tetracycline');
INSERT INTO Antibioticos(id, nombre) VALUES (9, 'Trimethoprim/Sulfa');
INSERT INTO Antibioticos(id, nombre) VALUES (10, 'Vancomycin');
INSERT INTO Antibioticos(id, nombre) VALUES (11, 'Nitrofurantoin');
INSERT INTO Antibioticos(id, nombre) VALUES (12, 'Daptomycin');
INSERT INTO Antibioticos(id, nombre) VALUES (13, 'Ampicillin');
INSERT INTO Antibioticos(id, nombre) VALUES (14, 'Penicillin');
INSERT INTO Antibioticos(id, nombre) VALUES (15, 'Cefotaxima');
INSERT INTO Antibioticos(id, nombre) VALUES (16, 'Ceftriaxone');
INSERT INTO Antibioticos(id, nombre) VALUES (17, 'Penicillin meningitis');
INSERT INTO Antibioticos(id, nombre) VALUES (18, 'Penicillin otros');
INSERT INTO Antibioticos(id, nombre) VALUES (19, 'Cefotaxima meningitis');
INSERT INTO Antibioticos(id, nombre) VALUES (20, 'Cefotaxima otros');
INSERT INTO Antibioticos(id, nombre) VALUES (21, 'Amikacin');
INSERT INTO Antibioticos(id, nombre) VALUES (22, 'Aztreonam');
INSERT INTO Antibioticos(id, nombre) VALUES (23, 'Cefazolin');
INSERT INTO Antibioticos(id, nombre) VALUES (24, 'Cefepime');
INSERT INTO Antibioticos(id, nombre) VALUES (25, 'Ceftazidime');
INSERT INTO Antibioticos(id, nombre) VALUES (26, 'Cefotaxime');
INSERT INTO Antibioticos(id, nombre) VALUES (27, 'Ciprofloxacin');
INSERT INTO Antibioticos(id, nombre) VALUES (28, 'Ertapenem');
INSERT INTO Antibioticos(id, nombre) VALUES (29, 'Colistin');
INSERT INTO Antibioticos(id, nombre) VALUES (30, 'Imipenem');
INSERT INTO Antibioticos(id, nombre) VALUES (31, 'Meropenem');
INSERT INTO Antibioticos(id, nombre) VALUES (32, 'Doripenem');
INSERT INTO Antibioticos(id, nombre) VALUES (33, 'Piperacillin / Tazobactam');
INSERT INTO Antibioticos(id, nombre) VALUES (34, 'Tigecycline');
INSERT INTO Antibioticos(id, nombre) VALUES (35, 'Ampicillin / Sulbactam');
INSERT INTO Antibioticos(id, nombre) VALUES (36, 'Moxifloxacin');

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Finalizando el ingreso de información a la tabla Antibioticos, 36 filas afectadas.');

/* Lista base de pruebas habilitados para el funcionamiento de la aplicación. */
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Eliminando información de la tabla Pruebas.');

DELETE FROM Pruebas;

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Ingresando información a la tabla Pruebas.');

INSERT INTO Pruebas(id, nombre) VALUES (1, 'NA'); 
INSERT INTO Pruebas(id, nombre) VALUES (2, 'Resistencia inducible a Clindamycin');
INSERT INTO Pruebas(id, nombre) VALUES (3, 'Cefoxitin Screen');
INSERT INTO Pruebas(id, nombre) VALUES (4, 'ESBL / BLEE');

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Finalizando el ingreso de información a la tabla Pruebas, 4 filas afectadas.');

/* Lista de partes del cuerpo habilitados para el funcionamiento de la aplicación. */
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Eliminando información de la tabla PartesDelCuerpo.');

DELETE FROM PartesDelCuerpo;

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Ingresando información a la tabla PartesDelCuerpo.');

INSERT INTO PartesDelCuerpo(id,nombre) VALUES (0, 'Sistema nervioso central');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (1, 'Boca, senos paranasales y cuello');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (2, 'Pulmones y vía aérea');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (3, 'Abdomen');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (4, 'Tracto genito urinario');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (5, 'Huesos');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (6, 'Prostata');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (7, 'Tejidos blandos');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (8, 'Sangre');

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Finalizando el ingreso de información a la tabla PartesDelCuerpo, 8 filas afectadas.');

/* 	
	Lista de las combinaciones de antibioticos y pruebas que pueden usarse para el tratamiento de cada una de las
	
	Lista de las combinaciones de antibioticos y pruebas que pueden usarse para el diligenciamiento de los valores
	de referencia  obtenidos durante  un estudio infeccioso de un paciente. Importante anotar que a través de este 
	almacenamiento se identitica el tipo de control grpafico (INPUT TEXT y/o RADIO BUTTON) que deberá  presentarse
	sobre el formulario GRAM para su gestión.
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Eliminando información de la tabla CBxA.');

DELETE FROM CBxA;

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Ingresando información a la tabla CBxA.');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (2, 2, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (2, 3, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (2, 4, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (2, 5, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (2, 6, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (2, 7, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (2, 8, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (2, 9, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (2, 10, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (2, 11, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (2, 12, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (2, 1, 2,'RADIO BUTTON','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (2, 1, 3,'RADIO BUTTON','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (3, 2, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (3, 3, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (3, 4, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (3, 5, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (3, 6, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (3, 7, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (3, 8, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (3, 9, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (3, 10, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (3, 11, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (3, 12, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (3, 1, 2,'RADIO BUTTON','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (3, 1, 3,'RADIO BUTTON','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (4, 2, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (4, 3, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (4, 4, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (4, 5, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (4, 6, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (4, 7, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (4, 8, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (4, 9, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (4, 10, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (4, 11, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (4, 12, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (4, 1, 2,'RADIO BUTTON','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (4, 1, 3,'RADIO BUTTON','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (5, 2, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (5, 3, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (5, 4, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (5, 5, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (5, 6, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (5, 7, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (5, 8, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (5, 9, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (5, 10, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (5, 11, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (5, 12, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (5, 1, 2,'RADIO BUTTON','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (5, 1, 3,'RADIO BUTTON','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (6, 2, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (6, 3, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (6, 4, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (6, 5, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (6, 6, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (6, 7, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (6, 8, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (6, 9, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (6, 10, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (6, 11, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (6, 12, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (6, 1, 2,'RADIO BUTTON','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (6, 1, 3,'RADIO BUTTON','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (7, 13, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (7, 5, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (7, 8, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (7, 10, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (7, 11, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (7, 12, 1,'INPUT TEXT','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (8, 5, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (8, 8, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (8, 10, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (8, 11, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (8, 12, 1,'INPUT TEXT','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (9, 13, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (9, 5, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (9, 8, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (9, 10, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (9, 11, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (9, 12, 1,'INPUT TEXT','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (10, 13, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (10, 5, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (10, 8, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (10, 10, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (10, 11, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (10, 12, 1,'INPUT TEXT','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (11, 14, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (11, 15, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (11, 16, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (11, 2, 1,'INPUT TEXT','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (12, 14, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (12, 15, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (12, 16, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (12, 2, 1,'INPUT TEXT','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (13, 14, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (13, 15, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (13, 16, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (13, 2, 1,'INPUT TEXT','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (14, 14, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (14, 15, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (14, 16, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (14, 2, 1,'INPUT TEXT','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (15, 14, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (15, 15, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (15, 16, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (15, 2, 1,'INPUT TEXT','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (16, 14, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (16, 15, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (16, 16, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (16, 2, 1,'INPUT TEXT','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (17, 14, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (17, 15, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (17, 16, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (17, 2, 1,'INPUT TEXT','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (18, 17, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (18, 18, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (18, 19, 1,'INPUT TEXT','+');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (18, 20, 1,'INPUT TEXT','+');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 21, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 13, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 35, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 22, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 23, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 24, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 25, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 16, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 28, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 29, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 4, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 30, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 31, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 32, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 33, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 9, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 34, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 11, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (19, 1, 4,'RADIO BUTTON','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 21, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 22, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 23, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 24, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 25, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 16, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 28, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 29, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 4, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 30, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 31, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 32, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 33, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 9, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 34, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 11, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (20, 1, 4,'RADIO BUTTON','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (21, 21, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (21, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (21, 28, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (21, 4, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (21, 30, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (21, 31, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (21, 32, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (21, 9, 1,'INPUT TEXT','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (22, 21, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (22, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (22, 28, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (22, 29, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (22, 4, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (22, 30, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (22, 31, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (22, 32, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (22, 9, 1,'INPUT TEXT','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (23, 21, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (23, 24, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (23, 25, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (23, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (23, 29, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (23, 4, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (23, 30, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (23, 33, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (23, 31, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (23, 32, 1,'INPUT TEXT','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (24, 21, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (24, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (24, 28, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (24, 29, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (24, 4, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (24, 30, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (24, 31, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (24, 32, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (24, 9, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (25, 21, 1,'INPUT TEXT','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (25, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (25, 28, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (25, 29, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (25, 4, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (25, 30, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (25, 31, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (25, 32, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (25, 9, 1,'INPUT TEXT','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (26, 21, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (26, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (26, 28, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (26, 4, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (26, 31, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (26, 32, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (26, 9, 1,'INPUT TEXT','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (27, 36, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (27, 9, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (27, 34, 1,'INPUT TEXT','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (28, 21, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (28, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (28, 28, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (28, 29, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (28, 4, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (28, 30, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (28, 31, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (28, 32, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (28, 9, 1,'INPUT TEXT','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 21, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 13, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 35, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 22, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 23, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 24, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 25, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 16, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 28, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 4, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 31, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 32, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 33, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 9, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (29, 1, 4,'RADIO BUTTON','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (30, 21, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (30, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (30, 28, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (30, 4, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (30, 31, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (30, 32, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (30, 9, 1,'INPUT TEXT','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (31, 21, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (31, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (31, 28, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (31, 4, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (31, 31, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (31, 32, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (31, 9, 1,'INPUT TEXT','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (32, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (32, 25, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (33, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (33, 25, 1,'INPUT TEXT','-');

INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (34, 21, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (34, 27, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (34, 28, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (34, 4, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (34, 31, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (34, 32, 1,'INPUT TEXT','-');
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (34, 9, 1,'INPUT TEXT','-');

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Finalizando el ingreso de información a la tabla CBxA, 263 filas afectadas.');

/*  
	Lista con  la combinación de la partes del cuerpo, los antibióticos, el estado de sensibilidad, resistencia o 
	Lista de los antibióticos y/o comentarios usada para la configuración de las combinaciones  posibles  para la 
	asignación de los medicamentos requeridos en el tratamiento de un paciente.
*/
INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Eliminando información de la tabla Asignaciones.');

DELETE FROM Asignaciones;

INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Ingresando información a la tabla Asignaciones.');

INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES ( 1, 'Oxacilina');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES ( 2, 'Ceftriaxona (si Albumina > 3.5)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES ( 3, 'Cefotaxime (si Albumina < 3.5)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES ( 4, 'Ampicilina / sulbactam');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES ( 5, 'Ampicilina / sulbactam (si sospecha broncoaspiración)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES ( 6, 'Ampicilina / sulbactam (si hay tejido necrótico o sospecha presencia de anaerobios)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES ( 7, 'Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES ( 8, 'Descartar bacteriemia o contaminación');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES ( 9, 'Cefazolina ');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (10, 'Daptomicina');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (11, 'Linezolide');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (12, 'Clindamicina');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (13, 'Vancomicina');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (14, 'Ceftaroline');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (15, 'Clindamicina (si hay tejido necrótico o sospecha presencia de anaerobios)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (16, 'Tigeciclina');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (17, 'Ampicilina (dosis meníngeas)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (18, 'Fosfomycin (pielonefritis: 3gm cada 3 dias por 7 dosis y cistitis 3 gm dosis unica)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (19, 'En caso de endocarditis: Ceftriaxona 2 gm cada 12 horas (si Albumina > 3.5) o Cefotaxima (si Albumina < 3.5)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (20, 'Ampicilina');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (21, 'Nitrofurantoin (solo cistitis)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (22, 'Fosfomycin (3gm cada 3 dias por 7 dosis)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (23, 'Penicilina (dosis de meníngeas)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (24, 'Penicilina');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (25, 'Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, pero no combinar con Clindamicina)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (26, 'Confirmar con un laboratorio de referencia');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (27, 'Descartar bacteriemia');

INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (28, 'Gentamicina');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (29, 'Tetracycline (Minociclina)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (30, 'Trimethoprim / Sulfa');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (31, 'Amikacin');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (32, 'Aztreonam'); 
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (33, 'Cefepime');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (34, 'Ceftazidime');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (35, 'Ceftriaxone');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (36, 'Ciprofloxacin'); 
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (37, 'Ertapenem');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (38, 'Colistin');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (39, 'Imipenem');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (40, 'Meropenem');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (41, 'Doripenem');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (42, 'Piperacillin / Tazobactam');

INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (43, 'Piperacillin / Tazobactam (si sospecha broncoaspiración)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (44, 'Piperacilina / tazobactam (si hay tejido necrótico o sospecha presencia de anaerobios)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (45, 'Piperacilina/tazobactam (si se sospecha origen en abdomen)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (46, 'Considerar adicionar Metronidazol para cubrir anaerobios');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (47, 'Ciprofloxacin (considerar adicionar Metronidazol para cubrir anaerobios)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (48, 'Ciprofloxacin (considerar adicionar Amikacina durante 3 dias si la función renal lo permite)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (49, 'Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis, y se demuestra sensibilidad a estos antibioticos)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (50, 'Cefepime (considerar adicionar Metronidazol para cubrir anaerobios)');

INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (51, 'Ampicilina / sulbactam (si hay tejido necrótico o sospecha presencia de anaerobios)');



INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (6,1);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (16,2);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (26,3);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (35,4);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (35,5);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (35,6);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (7,7);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (1,8);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (23,9);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (12,10);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (5,11);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (2,12);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (10,13);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (1,14);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (2,15);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (34,16);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (13,17);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (1,18);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (16,19);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (13,20);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (11,21);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (1,22);

INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (14,23);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (14,24);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (17,23);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (17,24);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (18,23);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (18,24);

INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (7,25);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (1,26);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (1,27);

INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (4,28);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (8,29);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (9,30);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (21,31);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (22,32);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (24,33);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (25,34);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (16,35);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (27,36);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (28,37);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (29,38);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (30,39);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (31,40);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (32,41);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (33,42);

INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (33,43);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (33,44);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (33,45);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (1,46);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (27,47);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (27,48);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (7,49);

INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (24,50);
INSERT INTO asignacionAntibiotico (idAntibiotico, idAsignacion) VALUES (35,51);


INSERT INTO BitacoraEventos (TipoEvento, DetalleEvento) 
VALUES ('RegistroDatosBasicos', 'Finalizando el ingreso de información a la tabla Asignaciones, 42 filas afectadas.');