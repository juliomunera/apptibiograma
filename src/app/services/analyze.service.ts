import { Platform } from '@ionic/angular';
import { Injectable } from '@angular/core';
import { SQLitePorter } from '@ionic-native/sqlite-porter/ngx';
import { HttpClient } from '@angular/common/http';
import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AnalyzeService {

  private database: SQLiteObject;
  private dbReady: BehaviorSubject<boolean> = new BehaviorSubject(false);

  constructor(private plt: Platform, 
    private sqlitePorter: SQLitePorter, 
    private sqlite: SQLite, 
    private http: HttpClient) { 

    this.plt.ready().then(() => {
      this.sqlite.create({
        name: 'fai.db',
        location: 'default'
      })
      .then((db: SQLiteObject) => {
          this.database = db;
          this.dbReady.next(true);
      })
    });
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

  getDatabaseState() {
    return this.dbReady.asObservable();
  }

  executeGramScript(bacteriumId, gram) {

    return new Promise((resolve, reject) =>{
      let folderName = (gram === '+') ? 'gramp' : 'gramn'; 

      this.http.get(`assets/${folderName}/generalrules.sql`, { responseType: 'text'})
      .subscribe(sql => {
        this.sqlitePorter.importSqlToDb(this.database, sql)
          .then(_ => {

            this.http.get(`assets/${folderName}/${bacteriumId}.sql`, { responseType: 'text'})
              .subscribe(sql => {
                this.sqlitePorter.importSqlToDb(this.database, sql)
                  .then(_ => {

                    this.dbReady.next(true);
                    resolve();

                  }).catch(e => { reject(); alert(e.message); });

                });        
          })
          .catch(e => { reject(); alert(e.message); });
      });

    });
  }


  getMedicalResult(){

    return this.isReady()
    .then(()=> {

      return this.database.executeSql("SELECT id, idParteDelCuerpo, idBacteria, idAntibiotico, idAsignacion, mensaje from EtapaUnoyEtapaDos", [])
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
        console.log(error.message);
      });
    });
  }


}
