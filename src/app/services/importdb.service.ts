import { Platform } from '@ionic/angular';
import { Injectable } from '@angular/core';
import { SQLitePorter } from '@ionic-native/sqlite-porter/ngx';
import { HttpClient } from '@angular/common/http';
import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';
import { BehaviorSubject, Observable } from 'rxjs';

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
      ).then(() => {
        this.createTrigger_TRAI_CPDCxA_CalcularCodigoReferencia().then(() => {
          this.createTrigger_TRAI_DDP_CalculoDepuracionCreatininaHombre().then(() => {
            this.createTrigger_TRAI_DDP_CalculoDepuracionCreatininaMujer().then(() => {
              console.log('Created triggers.');

              // TODO: Create UNIQUE:
              // https://www.tutorialspoint.com/sqlite/sqlite_unique.htm
            })
          })
        })
      })
      ;
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

  // getBacteriasAntibioticos(): Observable<BacteriasAntibioticos[]> {
  //   return this.bacteriasAntibioticos.asObservable();
  // }

  // loadBateriasAntibioticos(){

  //   return this.database.executeSql('SELECT * FROM CBxA', []).then(data => {
  //     let bactantibioticos: BacteriasAntibioticos[] = [];
 
  //     if (data.rows.length > 0) {
  //       for (var i = 0; i < data.rows.length; i++) {
  //         bactantibioticos.push({ 
  //           id: data.rows.item(i).id,
  //           idBacteria: data.rows.item(i).idBacteria,
  //           idAntibiotico: data.rows.item(i).idAntibiotico,
  //           idPrueba: data.rows.item(i).idPrueba,
  //           tipoControl: data.rows.item(i).tipoControl,
  //           tipoGRAM: data.rows.item(i).tipoGRAM
  //          });
  //       }

  //     }
  //     this.bacteriasAntibioticos.next(bactantibioticos);
  //   });

  // }

      
  createTrigger_TRAI_CPDCxA_CalcularCodigoReferencia(){
    return this.database.executeSql(
      `
      CREATE TRIGGER TRAI_CPDCxA_CalcularCodigoReferencia AFTER INSERT 
      ON CPDCxA 
      BEGIN
        UPDATE CPDCxA
        SET codigoReferencia = NEW.idGrupo || NEW.idAntibiotico || NEW.idParteDelCuerpo || NEW.esSensible || NEW.esResistente || NEW.enEquilibrio
        WHERE id = NEW.id;
      END;`
    , null)
    .catch((err)=>{ alert(err.message)});
  }

  createTrigger_TRAI_DDP_CalculoDepuracionCreatininaMujer(){
    return this.database.executeSql(
      `
      CREATE TRIGGER TRAI_DDP_CalculoDepuracionCreatininaMujer AFTER INSERT ON DatosDelPaciente 
      WHEN NEW.genero = 'F'
      BEGIN
        UPDATE DatosDelPaciente
        SET depuracionCreatinina = ROUND(((0.85)*(140-NEW.edad)*NEW.peso)/(72*NEW.creatinina),2)
        WHERE id = NEW.id;
      END;`
    , null)
    .catch((err)=>{ alert(err.message)});
  }

  createTrigger_TRAI_DDP_CalculoDepuracionCreatininaHombre(){
    return this.database.executeSql(
      `
      CREATE TRIGGER TRAI_DDP_CalculoDepuracionCreatininaHombre AFTER INSERT 
      ON DatosDelPaciente 
      WHEN NEW.genero = 'M'
      BEGIN
        UPDATE DatosDelPaciente
        SET depuracionCreatinina = ROUND(((1)*(140-NEW.edad)*NEW.peso)/(72*NEW.creatinina),2)
        WHERE id = NEW.id;
      END;`
    , null)
    .catch((err)=>{ alert(err.message)});
  }

}
