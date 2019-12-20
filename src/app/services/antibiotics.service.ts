import { Injectable } from '@angular/core';
import { Platform } from '@ionic/angular';
import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';
import { BehaviorSubject } from 'rxjs';
// import OperatorsModel from '../models/operators.model';

@Injectable({
  providedIn: 'root'
})
export class AntibioticsService {

  private database: SQLiteObject ;
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

  insertData(data : any){
      
    return this.plt.ready()

      .then(()=> {
        return this.database.executeSql(`DELETE FROM GRAM;`, null)
        .catch(err => alert('Error: ' + err.message));
      })
      .then(()=> {
        
        for (let antibiotic of data.antibioticControls) {
          let params = [antibiotic.idBacteria, antibiotic.idAntibiotico, antibiotic.idPrueba,
                        antibiotic.operador, antibiotic.valor, antibiotic.tipoGRAM];
          
          this.database.executeSql(
            `INSERT INTO GRAM (idBacteria, idAntibiotico, idPrueba, operador, valor, tipoGRAM ) VALUES (?, ?, ?, ?, ?, ?)`, 
              params)
            .catch((err)=>alert(err.message));
        }

      })
      .catch(e=> alert(e.message));
  }

}


