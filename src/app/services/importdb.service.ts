import { Platform } from '@ionic/angular';
import { Injectable } from '@angular/core';
import { SQLitePorter } from '@ionic-native/sqlite-porter/ngx';
import { HttpClient } from '@angular/common/http';
import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';
import { BehaviorSubject } from 'rxjs';

export interface Dev {
  id: number,
  name: string,
  skills: any[],
  img: string
}

export interface BacteriasAntibioticos {
  id: number,
  idBacteria: number,
  idAntibiotico: number,
  idPrueba: number,
  tipoControl : string,
  tipoGRAM : string
}


@Injectable({
  providedIn: 'root'
})
export class ImportdbService {

  private database: SQLiteObject;
  private dbReady: BehaviorSubject<boolean> = new BehaviorSubject(false);
 
  bacteriasAntibioticos = new BehaviorSubject([]);
  products = new BehaviorSubject([]);

  constructor(private plt: Platform, private sqlitePorter: SQLitePorter, private sqlite: SQLite, private http: HttpClient) { 
    this.plt.ready().then(() => {
      this.sqlite.create({
        name: 'fai.db',
        location: 'default'
      })
      .then((db: SQLiteObject) => {
          this.database = db;
          this.seedDatabase();
      }
      )
    });
  }

  seedDatabase() {
    this.http.get('assets/database.sql', { responseType: 'text'})
    .subscribe(sql => {
      this.sqlitePorter.importSqlToDb(this.database, sql)
        .then(_ => {
          this.dbReady.next(true);
        })
        .catch(e => { alert(e.message); });
    });
  }

  getDatabaseState() {
    return this.dbReady.asObservable();
  }

  insertAllowAccess(data : any){

    if (data[1] < 0){
      data[1] = 0;
    }

    return this.plt.ready()
    .then(()=>{
      return this.database.executeSql(`DELETE FROM TokenSeguridad;`, null)
      .catch(err => alert('Error: ' + err.message));
    })
    .then(()=>{
      return this.database.executeSql(`INSERT INTO TokenSeguridad (fechaRegistro, dias) VALUES (?, ?);`, data)
      .catch((err)=>alert('Error: ' + err.message));
    });    
  }

}
