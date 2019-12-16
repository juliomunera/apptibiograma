import { Injectable } from '@angular/core';
import { Platform } from '@ionic/angular';
import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class HomedbService {

  private database: SQLiteObject;
  private dbReady: BehaviorSubject<boolean> = new BehaviorSubject(false);

  constructor(private plt: Platform, private sqlite: SQLite) { 
    this.plt.ready().then(() => {
      this.sqlite.create({
        name: 'fai.db',
        location: 'default'
      })
      .then((db: SQLiteObject) => {
          this.database = db;
      });
    });
  }

  getDaysAccess(){

    return this.plt.ready()
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
