import { Injectable } from '@angular/core';
import { Platform } from '@ionic/angular';
import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class GeneraldbService {

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

  insertGeneralData(data : any){
      
    return this.plt.ready()
      .then(()=> {
        return this.database.executeSql(`DELETE FROM DatosDelPaciente;`, null)
        .catch(err => alert('Error: ' + err.message));
      })
      .then(()=> {

        return this.database.executeSql(
          `INSERT INTO DatosDelPaciente (idParteDelCuerpo, fechaRegistro, genero, 
            edad, peso, creatinina, esAlergicoAPenicilina, 
            requiereHemodialisis, CAPD, CRRT, depuracionCreatinina) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
        , data)
        .catch((err)=>alert(err.message));
      })
      .catch(e=> alert(e.message));
  }

}
