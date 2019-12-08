import { Injectable } from '@angular/core';
import { Platform } from '@ionic/angular';
import { HttpClient } from '@angular/common/http';

import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';
import { SQLitePorter } from '@ionic-native/sqlite-porter/ngx';
import { BehaviorSubject } from 'rxjs';

import { HelperService } from '../services/helper.service';

@Injectable({
  providedIn: 'root'
})
export class DatabaseService {

    // export JAVA_HOME=$(/usr/libexec/java_home)
    // echo $JAVA_HOME
    // http://blog.enriqueoriol.com/2017/06/ionic-3-sqlite.html
    // https://devdactic.com/ionic-4-sqlite-queries/
    
    private database: SQLiteObject;
    private dbReady = new BehaviorSubject<boolean>(false);
  
    constructor(
      private platform:Platform, 
      private sqlitePorter: SQLitePorter,
      private sqlite:SQLite, 
      private helperServices: HelperService,
      private http: HttpClient) { 

      this.platform.ready().then(()=>{
        this.sqlite.create({
          name: 'fai.db',
          location: 'default'
        })
        .then((db:SQLiteObject)=>{
          this.database = db;
        
          // this.createDatabaseObject();

          this.createDatosDelPaciente()
          .then(()=>{
          })
          .then(()=> {
            this.createBacterias().then(()=>{
              this.insertAntibioData();
              alert('Inserto datos bacterias.')
            });
          })
          .then(() => {
            this.createAllowAccess();
          });
          
          this.dbReady.next(true);
  
        }).catch(e=> {
          alert(e.message);
        });
  
      });

    }



    createDatabaseObject() {
      this.http.get('assets/database.sql', { responseType: 'text'})
      .subscribe(sql => {
        this.sqlitePorter.importSqlToDb(this.database, sql)
          .then(result => {
              alert('Tablas creadas');
          })
          .catch(e => alert(e.message));
      });
    }

    createBacterias(){
      return this.database.executeSql(
        `
        CREATE TABLE IF NOT EXISTS Bacterias (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre VARCHAR(100) NOT NULL
      );`
      , null)
      .catch((err)=>console.log("error detected creating tables", err));
    }
    
    createDatosDelPaciente(){
      return this.database.executeSql(
        `
        CREATE TABLE IF NOT EXISTS DatosDelPaciente (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          idParteDelCuerpo INTEGER,
          fechaRegistro DATETIME,
          genero CHAR(1),
          edad INTEGER,
          peso REAL,
          creatinina REAL,
          esAlergicoAPenicilina BOOLEAN,
          requiereHemodialisis BOOLEAN,
          CAPD BOOLEAN,
          CRRT BOOLEAN,
          depuracionCreatinina DECIMAL(10,5)
          );`
      , null)
      .catch((err)=>console.log("error detected creating tables", err));
    }

    //  createTables(){
    //   return this.database.executeSql(
    //     `CREATE TABLE IF NOT EXISTS DatosDelPaciente (
    //       id INTEGER PRIMARY KEY AUTOINCREMENT,
    //       idParteDelCuerpo INTEGER,
    //       fechaRegistro DATETIME,
    //       genero CHAR(1),
    //       edad INTEGER,
    //       peso REAL,
    //       creatinina REAL,
    //       esAlergicoAPenicilina BOOLEAN,
    //       requiereHemodialisis BOOLEAN,
    //       CAPD BOOLEAN,
    //       CRRT BOOLEAN,
    //       depuracionCreatinina DECIMAL(10,5)
    //       );`
    //   , null)
    //   .catch((err)=>console.log("error detected creating tables", err));
    // }

    createAllowAccess(){
      return this.database.executeSql(
        `
        CREATE TABLE IF NOT EXISTS TokenSeguridad (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fechaRegistro DATETIME,
          dias INTEGER
          );`
      , null)
      .catch((err)=>console.log("error detected creating tables", err));
    }

    insertGeneralData(data : any){
    
      return this.isReady()
      .then(()=> {
        return this.database.executeSql(
          `INSERT INTO DatosDelPaciente (idParteDelCuerpo, fechaRegistro, genero, 
            edad, peso, creatinina, esAlergicoAPenicilina, 
            requiereHemodialisis, CAPD, CRRT, depuracionCreatinina) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
        , data)
        .catch((err)=>alert('Error: ' + err.message));
      });
    }
  
    // private createTables(){
    //   return this.database.executeSql(
    //     `CREATE TABLE IF NOT EXISTS list (
    //       id INTEGER PRIMARY KEY AUTOINCREMENT,
    //       name TEXT
    //     );`
    //   , null)
    //   .then(()=>{
    //     return this.database.executeSql(
    //     `CREATE TABLE IF NOT EXISTS todo (
    //       id INTEGER PRIMARY KEY AUTOINCREMENT,
    //       description TEXT,
    //       isImportant INTEGER,
    //       isDone INTEGER,
    //       listId INTEGER,
    //       FOREIGN KEY(listId) REFERENCES list(id)
    //       );`,null )
    //   }).catch((err)=>console.log("error detected creating tables", err));
    // }

    private isReady(){
      return new Promise((resolve, reject) =>{
        if(this.dbReady.getValue()){
          resolve();
        }
        else{
          this.dbReady.subscribe((ready)=>{
            if(ready){ 
              resolve(); 
            }
          });
        }  
      })
    }
  
    getLists(){

      return this.isReady()
      .then(()=> {

        return this.database.executeSql("SELECT * from DatosDelPaciente", [])
        .then((data)=>{

          let lists = [];
          if (data === undefined)
            return lists;

          if (data !== undefined && data !== null) {
            for(let i=0; i<data.rows.length; i++){
              lists.push(data.rows.item(i));
            }
          }
          return lists;
        })
        .catch(error => {
          alert(error.message);
        });

      });
    }

    getBacterias(){

      return this.isReady()
      .then(()=> {

        return this.database.executeSql("SELECT * from Bacterias", [])
        .then((data)=>{

          let lists = [];
          if (data === undefined)
            return lists;

          if (data !== undefined && data !== null) {
            for(let i=0; i<data.rows.length; i++){
              lists.push(data.rows.item(i));
            }
          }
          return lists;
        })
        .catch(error => {
          alert(error.message);
        });
      });
    }

    getDaysAccess(){

      return this.isReady()
      .then(()=> {

        return this.database.executeSql("SELECT id, fechaRegistro, dias from TokenSeguridad ORDER BY ROWID ASC LIMIT 1", [])
        .then((data)=>{

          let lists = [];
          if (data === undefined)
            return lists;

          if (data !== undefined && data !== null) {
            for(let i=0; i<data.rows.length; i++){
              lists.push(data.rows.item(i));
            }
          }
          return lists;
        })
        .catch(error => {
          alert(error.message);
        });
      });
    }

    insertAllowAccess(data : any){

      if (data[1] < 0){
        data[1] = 0;
      }

      return this.isReady()
      .then(()=>{
        return this.database.executeSql(`DELETE FROM TokenSeguridad;`, null)
        .catch(err => alert('Error: ' + err.message));
      })
      .then(()=>{
        return this.database.executeSql(`INSERT INTO TokenSeguridad (fechaRegistro, dias) VALUES (?, ?);`, data)
        .catch((err)=>alert('Error: ' + err.message));
      });    
    }

    addList(name:string){
      return this.isReady()
      .then(()=>{
        return this.database.executeSql(`INSERT INTO list(name) VALUES ('${name}');`, null).then((result)=>{
          if(result.insertId){
            return this.getList(result.insertId);
          }
        })
      });    
    }

    insertAntibioData(){
      return this.isReady()
      .then(()=>{
        return this.database.executeSql(` 
        INSERT INTO Bacterias(nombre) VALUES ('Staphylococcus aureus');  
        INSERT INTO Bacterias(nombre) VALUES ('Staphylococcus epidermidis');
        INSERT INTO Bacterias(nombre) VALUES ('Staphylococcus haemolyticus');
        INSERT INTO Bacterias(nombre) VALUES ('Staphylococcus warneri');
        INSERT INTO Bacterias(nombre) VALUES ('Staphylococcus lugdunensis');
        INSERT INTO Bacterias(nombre) VALUES ('Enterococcus faecalis');
        INSERT INTO Bacterias(nombre) VALUES ('Enterococcus faecium');
        INSERT INTO Bacterias(nombre) VALUES ('Enterococcus gallinarum');
        INSERT INTO Bacterias(nombre) VALUES ('Enterococcus casseliflavus');
        INSERT INTO Bacterias(nombre) VALUES ('Streptococcus viridans');
        INSERT INTO Bacterias(nombre) VALUES ('Streptococcus mitis');
        INSERT INTO Bacterias(nombre) VALUES ('Streptococcus mutans');
        INSERT INTO Bacterias(nombre) VALUES ('Streptococcus salivarius');
        INSERT INTO Bacterias(nombre) VALUES ('Streptococcus pyogenes');
        INSERT INTO Bacterias(nombre) VALUES ('Streptococcus agalactiae');
        INSERT INTO Bacterias(nombre) VALUES ('Streptococcus dysgalactiae');
        INSERT INTO Bacterias(nombre) VALUES ('Streptococcus pneumoniae');
        `, null).then((result)=>{
          if(result.insertId){
            return this.getList(result.insertId);
          }
        })
      });    
    }

    getList(id:number){ }

    deleteList(id:number){ }
  
    getTodosFromList(listId:number){ }

    addTodo(description:string, isImportant:boolean, isDone:boolean, listId:number){ }

    modifyTodo(description:string, isImportant:boolean, isDone:boolean, id:number){ }

    removeTodo(id:number){ }
  
}
