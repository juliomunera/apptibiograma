import { Injectable } from '@angular/core';
import { Platform } from '@ionic/angular';
import { HttpClient } from '@angular/common/http';

import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';
import { SQLitePorter } from '@ionic-native/sqlite-porter/ngx';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class DatabaseService {

    // export JAVA_HOME=$(/usr/libexec/java_home)
    // echo $JAVA_HOME
    // http://blog.enriqueoriol.com/2017/06/ionic-3-sqlite.html
    
    private database: SQLiteObject;
    private dbReady = new BehaviorSubject<boolean>(false);
  
    constructor(
      private platform:Platform, 
      private sqlitePorter: SQLitePorter,
      private sqlite:SQLite, 
      private http: HttpClient) { 

      this.platform.ready().then(()=>{
        this.sqlite.create({
          name: 'fai.db',
          location: 'default'
        })
        .then((db:SQLiteObject)=>{
          this.database = db;
  
          this.createTables().then(()=>{
            this.dbReady.next(true);
          });
        })
  
      });

    }

    createDatabaseObject() {
      this.http.get('assets/database.sql', { responseType: 'text'})
      .subscribe(sql => {
        this.sqlitePorter.importSqlToDb(this.database, sql)
          .then(result => {

          })
          .catch(e => console.error(e));
      });
    }

  
    private createTables(){
      return this.database.executeSql(
        `CREATE TABLE IF NOT EXISTS list (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT
        );`
      , null)
      .then(()=>{
        return this.database.executeSql(
        `CREATE TABLE IF NOT EXISTS todo (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT,
          isImportant INTEGER,
          isDone INTEGER,
          listId INTEGER,
          FOREIGN KEY(listId) REFERENCES list(id)
          );`,null )
      }).catch((err)=>console.log("error detected creating tables", err));
    }

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
      .then(()=>{
        return this.database.executeSql("SELECT * from list", [])
        .then((data)=>{
          let lists = [];
          for(let i=0; i<data.rows.length; i++){
            lists.push(data.rows.item(i));
          }
          return lists;
        })
      })
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

    getList(id:number){ }

    deleteList(id:number){ }
  
    getTodosFromList(listId:number){ }

    addTodo(description:string, isImportant:boolean, isDone:boolean, listId:number){ }

    modifyTodo(description:string, isImportant:boolean, isDone:boolean, id:number){ }

    removeTodo(id:number){ }
  
}
