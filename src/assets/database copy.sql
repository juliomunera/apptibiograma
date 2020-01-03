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
    nombre VARCHAR(100) NOT NULL
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
	comentariosTratamiento  VARCHAR2(250) NOT NULL
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
	tipoGRAM CHAR(1) NOT NULL,
	
	FOREIGN KEY(idBacteria) REFERENCES Bacterias(id)
	FOREIGN KEY(idAntibiotico) REFERENCES Antibioticos(id)
	FOREIGN KEY(idPrueba) REFERENCES Pruebas(id)
);	

CREATE INDEX IF NOT EXISTS IDX_CBxA_idBacteria_idAntibiotico ON CBxA (idBacteria,idAntibiotico);

/*
	Entidad usada para 
*/
DROP TABLE IF EXISTS CPDCxA;

CREATE TABLE CPDCxA (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
	idGrupo INTEGER NOT NULL,
	idParteDelCuerpo INTEGER NOT NULL,
	idAntibiotico INTEGER NOT NULL,
	esSensible SMALLINT NOT NULL,
	esResistente SMALLINT NOT NULL,
	enEquilibrio SMALLINT NOT NULL,
	idAsignacion INTEGER NOT NULL,
	codigoReferencia VARCHAR2(5),
	
	FOREIGN KEY(idParteDelCuerpo) REFERENCES PartesDelCuerpo(id)
	FOREIGN KEY(idAntibiotico) REFERENCES Antibioticos(id)
	FOREIGN KEY(idAsignacion) REFERENCES Asignaciones(id)
);	

CREATE INDEX IF NOT EXISTS IDX_CPDCxA_codigoReferencia ON CPDCxA (codigoReferencia);

/*
	Desencadenador activo después de ingresar un registro y usado para calcular  el  campo depuracionCreatinina  cuando  el  genero  del 
	paciente es masculino.
*/
DROP TRIGGER IF EXISTS TRAI_CPDCxA_CalcularCodigoReferencia;

/*
	Entidad usada para almacenar la información básica del paciente en evaluación.
*/
DROP TABLE IF EXISTS DatosDelPaciente;

CREATE TABLE DatosDelPaciente (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	idParteDelCuerpo INTEGER,
	fechaRegistro DATETIME DEFAULT (DATETIME('now')),
	genero CHAR(1),
	edad INTEGER,	
	peso REAL,	
	creatinina REAL,
	esAlergicoAPenicilina BOOLEAN,
	requiereHemodialisis BOOLEAN,
	CAPD BOOLEAN,
	CRRT BOOLEAN,	
	depuracionCreatinina DECIMAL(10,2),
	
	FOREIGN KEY(idParteDelCuerpo) REFERENCES PartesDelCuerpo(id)
);

/*
	Desencadenador activo después de ingresar un registro y usado para calcular  el  campo depuracionCreatinina  cuando  el  genero  del 
	paciente es femenino.
*/
DROP TRIGGER IF EXISTS TRAI_DDP_CalculoDepuracionCreatininaMujer;	

/*
	Desencadenador activo después de ingresar un registro y usado para calcular  el  campo depuracionCreatinina  cuando  el  genero  del 
	paciente es masculino.
*/
DROP TRIGGER IF EXISTS TRAI_DDP_CalculoDepuracionCreatininaHombre;

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
	tipoGRAM CHAR(1) NOT NULL,

	FOREIGN KEY(idBacteria) REFERENCES Bacterias(id)
	FOREIGN KEY(idAntibiotico) REFERENCES Antibioticos(id)
	FOREIGN KEY(idPrueba) REFERENCES Pruebas(id)
);

CREATE INDEX IF NOT EXISTS IDX_GRAM_operador ON GRAM( operador );
CREATE INDEX IF NOT EXISTS IDX_GRAM_idBacteria_idPrueba ON GRAM( idBacteria, idPrueba );
CREATE INDEX IF NOT EXISTS IDX_GRAM_idBacteria_idAntibiotico_operador ON GRAM( idBacteria, idAntibiotico, operador );

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

DROP TABLE IF EXISTS TokenSeguridad;

CREATE TABLE IF NOT EXISTS TokenSeguridad (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	fechaRegistro DATETIME,
	dias INTEGER
);

/*
	Las siguientes son algunas de las vistas que hacen parte del conjunto de mecanismos usados para ejecutar las etapas del análisis GRAM.
*/
DROP VIEW IF EXISTS GermenesSensibles;

CREATE VIEW GermenesSensibles AS
	SELECT g.*, a.nombre
	FROM GRAM AS g
	JOIN Antibioticos a
	ON g.idAntibiotico = a.id
	WHERE g.operador = "<="
		AND g.idAntibiotico <> 1;

DROP VIEW IF EXISTS GermenesEnEquilibrio;

CREATE VIEW GermenesEnEquilibrio AS
	SELECT g.*, a.nombre
	FROM GRAM AS g
	JOIN Antibioticos a
	ON g.idAntibiotico = a.id
	WHERE g.operador = "="
		AND g.idAntibiotico <> 1; 
		
DROP VIEW IF EXISTS GermenesResistentes;

CREATE VIEW GermenesResistentes AS
	SELECT g.*, a.nombre
	FROM GRAM AS g
	JOIN Antibioticos a
	ON g.idAntibiotico = a.id
	WHERE g.operador = ">="
		AND g.idAntibiotico <> 1; 

DROP VIEW IF EXISTS GermenesSensiblesoEnEquilibrio;

CREATE VIEW GermenesSensiblesoEnEquilibrio AS
	SELECT g.*, a.nombre
	FROM GRAM AS g
	JOIN Antibioticos a
	ON g.idAntibiotico = a.id
	WHERE (g.operador = "<=" 
		OR g.operador = "=")
		AND g.idAntibiotico <> 1;

DROP VIEW IF EXISTS GermenesResistentesoEnEquilibrio;

CREATE VIEW GermenesResistentesoEnEquilibrio AS
	SELECT g.*, a.nombre
	FROM GRAM AS g
	JOIN Antibioticos a
	ON g.idAntibiotico = a.id
	WHERE (g.operador = ">=" 
		OR g.operador = "=")
		AND g.idAntibiotico <> 1; 		
		
DROP VIEW IF EXISTS PruebasAplicadas;

CREATE VIEW PruebasAplicadas AS
	SELECT g.*, p.nombre
	FROM GRAM AS g
	JOIN Pruebas p
	ON g.idPrueba = p.id
	WHERE g.idAntibiotico = 1;

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


/* Lista base de bacterias habilitados para el funcionamiento de la aplicación. */
DELETE FROM Bacterias;

INSERT INTO Bacterias(id, nombre) VALUES (1, 'NA'); 
INSERT INTO Bacterias(id, nombre) VALUES (2, 'Staphylococcus aureus');  
INSERT INTO Bacterias(id, nombre) VALUES (3, 'Staphylococcus epidermidis');
INSERT INTO Bacterias(id, nombre) VALUES (4, 'Staphylococcus haemolyticus');
INSERT INTO Bacterias(id, nombre) VALUES (5, 'Staphylococcus warneri');
INSERT INTO Bacterias(id, nombre) VALUES (6, 'Staphylococcus lugdunensis');
INSERT INTO Bacterias(id, nombre) VALUES (7, 'Enterococcus faecalis');
INSERT INTO Bacterias(id, nombre) VALUES (8, 'Enterococcus faecium');
INSERT INTO Bacterias(id, nombre) VALUES (9, 'Enterococcus gallinarum');
INSERT INTO Bacterias(id, nombre) VALUES (10, 'Enterococcus casseliflavus');
INSERT INTO Bacterias(id, nombre) VALUES (11, 'Streptococcus viridans');
INSERT INTO Bacterias(id, nombre) VALUES (12, 'Streptococcus mitis');
INSERT INTO Bacterias(id, nombre) VALUES (13, 'Streptococcus mutans');
INSERT INTO Bacterias(id, nombre) VALUES (14, 'Streptococcus salivarius');
INSERT INTO Bacterias(id, nombre) VALUES (15, 'Streptococcus pyogenes');
INSERT INTO Bacterias(id, nombre) VALUES (16, 'Streptococcus agalactiae');
INSERT INTO Bacterias(id, nombre) VALUES (17, 'Streptococcus dysgalactiae');
INSERT INTO Bacterias(id, nombre) VALUES (18, 'Streptococcus pneumoniae');

/* Lista base de antibióticos habilitados para el funcionamiento de la aplicación. */
DELETE FROM Antibioticos;

INSERT INTO Antibioticos(id, nombre) VALUES (1, 'NA'); 
INSERT INTO Antibioticos(id, nombre) VALUES (2, 'Clindamycin');
INSERT INTO Antibioticos(id, nombre) VALUES (3, 'Erythromycin');
INSERT INTO Antibioticos(id, nombre) VALUES (4, 'Gentamicin');
INSERT INTO Antibioticos(id, nombre) VALUES (5, 'Linezolid');
INSERT INTO Antibioticos(id, nombre) VALUES (6, 'Oxacillin');
INSERT INTO Antibioticos(id, nombre) VALUES (7, 'Rifampicin');
INSERT INTO Antibioticos(id, nombre) VALUES (8, 'Tetracycline');
INSERT INTO Antibioticos(id, nombre) VALUES (9, 'Trimethoprim / Sulfa');
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

/* Lista base de pruebas habilitados para el funcionamiento de la aplicación. */
DELETE FROM Pruebas;

INSERT INTO Pruebas(id, nombre) VALUES (1, 'NA'); 
INSERT INTO Pruebas(id, nombre) VALUES (2, 'Resistencia inducible a Clindamycin');
INSERT INTO Pruebas(id, nombre) VALUES (3, 'Cefoxitin Screen');

/* Lista de partes del cuerpo habilitados para el funcionamiento de la aplicación. */
DELETE FROM PartesDelCuerpo;

INSERT INTO PartesDelCuerpo(id,nombre) VALUES (0, 'Sistema nervioso central');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (1, 'Boca, senos paranasales y cuello');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (2, 'Pulmones y vía aérea');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (3, 'Abdomen');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (4, 'Tracto genito urinario');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (5, 'Huesos');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (6, 'Prostata');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (7, 'Tejidos blandos');
INSERT INTO PartesDelCuerpo(id,nombre) VALUES (8, 'Sangre');

/* 	
	Lista de las combinaciones de antibioticos y pruebas que pueden usarse para el tratamiento de cada una de las
	
	Lista de las combinaciones de antibioticos y pruebas que pueden usarse para el diligenciamiento de los valores
	de referencia  obtenidos durante  un estudio infeccioso de un paciente. Importante anotar que a través de este 
	almacenamiento se identitica el tipo de control grpafico (INPUT TEXT y/o RADIO BUTTON) que deberá  presentarse
	sobre el formulario GRAM para su gestión.
*/
DELETE FROM CBxA;

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
INSERT INTO CBxA(idBacteria,idAntibiotico,idPrueba,tipoControl,tipoGRAM) VALUES (18, 21, 1,'INPUT TEXT','+');

/*  
	Lista con  la combinación de la partes del cuerpo, los antibióticos, el estado de sensibilidad, resistencia o 
	Lista de los antibióticos y/o comentarios usada para la configuración de las combinaciones  posibles  para la 
	asignación de los medicamentos requeridos en el tratamiento de un paciente.
*/
DELETE FROM Asignaciones;

INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (1, 'Oxacilina');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (2, 'Ceftriaxona (si Albumina > 3.5)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (3, 'Cefotaxime (si Albumina < 3.5)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (4, 'Ampicilina/sulbactam');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (5, 'Ampicilina/sulbactam (si sospecha broncoaspiración)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (6, 'Ampicilina/sulbactam (si hay tejido necrótico o sospecha presencia de anaerobios)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (7, 'Rifampicina o Minociclina (si hay material de osteosíntesis o prótesis)');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (8, 'Descartar bacteriemia o contaminación');
INSERT INTO Asignaciones(id,comentariosTratamiento) VALUES (9, 'Cefazolina ');
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

/*  
	Lista con  la combinación de la partes del cuerpo, los antibióticos, el estado de sensibilidad, resistencia o 
	equilibrio de  estos  y  comentarios  usado  para  determinar los  medicamentos que deberán asignarse para el 
	tratamiento de un paciente.
*/
DELETE FROM CPDCxA;

/*
	Staphylococcus (Grupo 1)
*/
-- Sensibilidad al antibiótico 6 (Oxacilina)
-- Sistema nervioso central
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 0, 1, 0, 0, 1);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 0, 1, 0, 0, 2);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 0, 1, 0, 0, 3);
-- Boca y senos paranasales
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 1, 1, 0, 0, 4);
-- Pulmones
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 2, 1, 0, 0, 1);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 2, 1, 0, 0, 9);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 2, 1, 0, 0, 5);
-- Tejidos blandos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 7, 1, 0, 0, 1);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 7, 1, 0, 0, 9);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 7, 1, 0, 0, 6);
-- Huesos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 5, 1, 0, 0, 1);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 5, 1, 0, 0, 9);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 5, 1, 0, 0, 6);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 5, 1, 0, 0, 7);
-- Abdomen
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 3, 1, 0, 0, 4);
-- Tracto genitourinario
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 4, 1, 0, 0, 8);
-- Abdomen
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 6, 1, 0, 0, 8);
-- Sangre
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 8, 1, 0, 0, 1);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 8, 1, 0, 0, 9);

-- Resistencia al antibiótico 6 (Oxacilina)
-- Sistema nervioso central
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 0, 0, 1, 0, 10);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 0, 0, 1, 0, 11);
-- Boca y senos paranasales
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 1, 0, 1, 0, 12);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 1, 0, 1, 0, 13);
-- Pulmones
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 2, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 2, 0, 1, 0, 11);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 2, 0, 1, 0, 14);
-- Tejidos blandos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 7, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 7, 0, 1, 0, 11);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 7, 0, 1, 0, 15);
-- Huesos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 5, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 5, 0, 1, 0, 10);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 5, 0, 1, 0, 15);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 5, 0, 1, 0, 7);
-- Abdomen
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 3, 0, 1, 0, 12);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 3, 0, 1, 0, 16);
-- Tracto genitourinario
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 4, 0, 1, 0, 8);
-- Próstata
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 6, 0, 1, 0, 8);
-- Sangre
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 8, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 6, 8, 0, 1, 0, 10);

-- Reglas para la asignación de medicamentos donde no se tiene en cuenta la resistencia, sensibilidad y equilibrio de este.
-- Sistema nervioso central
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 0, 0, 0, 0, 11);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 0, 0, 0, 0, 2);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 0, 0, 0, 0, 3);
-- Boca y senos paranasales
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 1, 0, 0, 0, 12);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 1, 0, 0, 0, 13);
-- Pulmones
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 2, 0, 0, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 2, 0, 0, 0, 11);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 2, 0, 0, 0, 9);
-- Tejidos blandos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 7, 0, 0, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 7, 0, 0, 0, 9);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 7, 0, 0, 0, 15);
-- Huesos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 5, 0, 0, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 5, 0, 0, 0, 9);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 5, 0, 0, 0, 15);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 5, 0, 0, 0, 7);
-- Abdomen
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 3, 0, 0, 0, 12);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 3, 0, 0, 0, 16);
-- Tracto genitourinario
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 4, 0, 0, 0, 8);
-- Próstata
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 6, 0, 0, 0, 8);
-- Sangre
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 8, 0, 0, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (1, 1, 8, 0, 0, 0, 9);

/*
	Entercoccus faecalis, gallinarum y casseliflavus (Grupo 2)
*/
-- Sensibilidad al antibiótico 13
-- Sistema nervioso central
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 0, 1, 0, 0, 17);
-- Boca y senos paranasales
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 1, 1, 0, 0, 4);
-- Pulmones
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 2, 1, 0, 0, 4);
-- Tejidos blandos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 7, 1, 0, 0, 4);
-- Huesos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 5, 1, 0, 0, 4);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 5, 1, 0, 0, 7);
-- Abdomen
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 3, 1, 0, 0, 4);
-- Tracto genitourinario
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 4, 1, 0, 0, 20);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 4, 1, 0, 0, 4);
-- Próstata
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 6, 1, 0, 0, 17);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 6, 1, 0, 0, 22);
-- Sangre
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 8, 1, 0, 0, 4);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 8, 1, 0, 0, 19);

-- Resistencia al antibiótico 13
-- Sistema nervioso central
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 0, 0, 1, 0, 10);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 0, 0, 1, 0, 11);
-- Boca y senos paranasales
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 1, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 1, 0, 1, 0, 16);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 1, 0, 1, 0, 11);
-- Pulmones
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 2, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 2, 0, 1, 0, 11);
-- Tejidos blandos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 7, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 7, 0, 1, 0, 11);
-- Huesos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 5, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 5, 0, 1, 0, 10);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 5, 0, 1, 0, 7);
-- Abdomen
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 3, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 3, 0, 1, 0, 16);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 3, 0, 1, 0, 11);
-- Tracto genitourinario
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 4, 0, 1, 0, 18);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 4, 0, 1, 0, 21);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 4, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 4, 0, 1, 0, 11);
-- Próstata
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 6, 0, 1, 0, 22);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 6, 0, 1, 0, 13);
-- Sangre
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 8, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 13, 8, 0, 1, 0, 10);

-- Reglas para la asignación de medicamentos donde no se tiene en cuenta la resistencia, sensibilidad y equilibrio de este.
-- Sistema nervioso central
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 0, 0, 1, 0, 10);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 0, 0, 1, 0, 11);
-- Boca y senos paranasales
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 1, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 1, 0, 1, 0, 16);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 1, 0, 1, 0, 11);
-- Pulmones
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 2, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 2, 0, 1, 0, 11);
-- Tejidos blandos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 7, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 7, 0, 1, 0, 11);
-- Huesos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 5, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 5, 0, 1, 0, 10);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 5, 0, 1, 0, 7);
-- Abdomen
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 3, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 3, 0, 1, 0, 16);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 3, 0, 1, 0, 11);
-- Tracto genitourinario
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 4, 0, 1, 0, 18);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 4, 0, 1, 0, 21);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 4, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 4, 0, 1, 0, 11);
-- Próstata
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 6, 0, 1, 0, 22);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 6, 0, 1, 0, 13);
-- Sangre
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 8, 0, 1, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (2, 1, 8, 0, 1, 0, 10);

/*
	Enterocuccus faecium (Grupo 3)
*/
-- Reglas para la asignación de medicamentos donde no se tiene en cuenta la resistencia, sensibilidad y equilibrio de este.
-- Sistema nervioso central
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 0, 0, 0, 0, 10);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 0, 0, 0, 0, 11);
-- Boca y senos paranasales
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 1, 0, 0, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 1, 0, 0, 0, 16);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 1, 0, 0, 0, 11);
-- Pulmones
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 2, 0, 0, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 2, 0, 0, 0, 11);
-- Tejidos blandos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 7, 0, 0, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 7, 0, 0, 0, 11);
-- Huesos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 5, 0, 0, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 5, 0, 0, 0, 10);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 5, 0, 0, 0, 7);
-- Abdomen
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 3, 0, 0, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 3, 0, 0, 0, 16);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 3, 0, 0, 0, 11);
-- Tracto genitourinario
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 4, 0, 0, 0, 18);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 4, 0, 0, 0, 21);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 4, 0, 0, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 4, 0, 0, 0, 11);
-- Próstata
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 6, 0, 0, 0, 22);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 6, 0, 0, 0, 13);
-- Sangre
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 8, 0, 0, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (3, 1, 8, 0, 0, 0, 10);

/*
	Streptococcus (Grupo 4)
*/
-- Sensibilidad al antibiótico 14 (Penicilina)
-- Sistema nervioso central
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 0, 1, 0, 0, 23);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 0, 1, 0, 0, 17);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 0, 1, 0, 0, 2);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 0, 1, 0, 0, 3); 
-- Boca y senos paranasales
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 1, 1, 0, 0, 4); 
-- Pulmones
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 2, 1, 0, 0, 4); 
-- Tejidos blandos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 7, 1, 0, 0, 4); 
-- Huesos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 5, 1, 0, 0, 4); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 5, 1, 0, 0, 7);
-- Abdomen
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 3, 1, 0, 0, 4); 
-- Tracto genitourinario
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 4, 1, 0, 0, 20); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 4, 1, 0, 0, 4); 
-- Próstata
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 6, 1, 0, 0, 23); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 6, 1, 0, 0, 17); 
-- Sangre
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 8, 1, 0, 0, 24); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 8, 1, 0, 0, 20); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 8, 1, 0, 0, 4); 
-- Resistencia al antibiótico 14 (Penicilina)
-- Sistema nervioso central
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 0, 0, 1, 0, 26);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 0, 0, 1, 0, 26);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 0, 0, 1, 0, 26);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 0, 0, 1, 0, 26); 
-- Boca y senos paranasales
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 1, 0, 1, 0, 26); 
-- Pulmones
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 2, 0, 1, 0, 26); 
-- Tejidos blandos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 7, 0, 1, 0, 26); 
-- Huesos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 5, 0, 1, 0, 26); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 5, 0, 1, 0, 26);
-- Abdomen
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 3, 0, 1, 0, 26); 
-- Tracto genitourinario
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 4, 0, 1, 0, 26); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 4, 0, 1, 0, 26); 
-- Próstata
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 6, 0, 1, 0, 26); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 6, 0, 1, 0, 26); 
-- Sangre
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 8, 0, 1, 0, 26); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 8, 0, 1, 0, 26); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 14, 8, 0, 1, 0, 26);
-- Reglas para la asignación de medicamentos donde no se tiene en cuenta la resistencia, sensibilidad y equilibrio de este.
-- Sistema nervioso central
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 0, 0, 0, 0, 2);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 0, 0, 0, 0, 3);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 0, 0, 0, 0, 10);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 0, 0, 0, 0, 11); 
-- Boca y senos paranasales
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 1, 0, 0, 0, 16); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 1, 0, 0, 0, 12); 
-- Pulmones
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 2, 0, 0, 0, 13); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 2, 0, 0, 0, 11);
-- Tejidos blandos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 7, 0, 0, 0, 13);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 7, 0, 0, 0, 15); 
-- Huesos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 5, 0, 0, 0, 13); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 5, 0, 0, 0, 10);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 5, 0, 0, 0, 12);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 5, 0, 0, 0, 7);
-- Abdomen
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 3, 0, 0, 0, 12);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 3, 0, 0, 0, 16); 
-- Tracto genitourinario
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 4, 0, 0, 0, 18); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 4, 0, 0, 0, 21);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 4, 0, 0, 0, 13);  
-- Próstata
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 6, 0, 0, 0, 22); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 6, 0, 0, 0, 2); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 6, 0, 0, 0, 3); 
-- Sangre
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 8, 0, 0, 0, 13); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (4, 1, 8, 0, 0, 0, 10); 
/*
	Streptococcus pneumoniae(Grupo 5)
*/
-- Sensibilidad al antibiótico 14 (Penicilina)
-- Sistema nervioso central
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 0, 1, 0, 0, 23);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 0, 1, 0, 0, 17);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 0, 1, 0, 0, 2);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 0, 1, 0, 0, 3); 
-- Boca y senos paranasales
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 1, 1, 0, 0, 4); 
-- Pulmones
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 2, 1, 0, 0, 4); 
-- Tejidos blandos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 7, 1, 0, 0, 4); 
-- Huesos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 5, 1, 0, 0, 4); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 5, 1, 0, 0, 7);
-- Abdomen
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 3, 1, 0, 0, 4); 
-- Tracto genitourinario
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 4, 1, 0, 0, 27); 
-- Próstata
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 6, 1, 0, 0, 27); 
-- Sangre
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 8, 1, 0, 0, 24); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 8, 1, 0, 0, 20); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 8, 1, 0, 0, 4); 
-- Equilibrio al antibiótico 14 (Penicilina)
-- Sistema nervioso central
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 0, 0, 0, 1, 23);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 0, 0, 0, 1, 17);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 0, 0, 0, 1, 2);
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 0, 0, 0, 1, 3); 
-- Boca y senos paranasales
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 1, 0, 0, 1, 4); 
-- Pulmones
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 2, 0, 0, 1, 4); 
-- Tejidos blandos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 7, 0, 0, 1, 4); 
-- Huesos
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 5, 0, 0, 1, 4); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 5, 0, 0, 1, 7);
-- Abdomen
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 3, 0, 0, 1, 4); 
-- Tracto genitourinario
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 4, 0, 0, 1, 27); 
-- Próstata
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 6, 0, 0, 1, 27); 
-- Sangre
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 8, 0, 0, 1, 24); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 8, 0, 0, 1, 20); 
INSERT INTO CPDCxA(idGrupo, idAntibiotico,idParteDelCuerpo,esSensible,esResistente,enEquilibrio,idAsignacion) VALUES (5, 14, 8, 0, 0, 1, 4); 

