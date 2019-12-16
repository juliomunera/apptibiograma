import { Injectable } from '@angular/core';
import { Platform } from '@ionic/angular';
import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';
import { BehaviorSubject, Observable } from 'rxjs';


@Injectable({
  providedIn: 'root'
})
export class BacteriumdbService {

  private database: SQLiteObject;
  private dbReady: BehaviorSubject<boolean> = new BehaviorSubject(false);

  public bacteriumsList : any[] = [];
  gramType : any;

  constructor(private plt: Platform, private sqlite: SQLite) { 
    
    this.plt.ready().then(() => {
      this.sqlite.create({
        name: 'fai.db',
        location: 'default'
      })
      .then((db: SQLiteObject) => {
          this.database = db;
          this.dbReady.next(true);
      });
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
    });
  }

  ngOnInit() {
  
  }

  // return ;
   async getBacteriumList(){

    return this.isReady()
    .then(()=>{
      this.database.executeSql('SELECT id, nombre from Bacterias', []).then(data => { 
        alert('Ejecuto sentencia=> ');

          let lists = [];
          if (data === undefined)
            return lists;

          if (data !== undefined && data !== null) {
            for(let i=0; i<data.rows.length; i++){
              lists.push(data.rows.item(i));
            }
          }

          alert(lists.length);
          return lists;
        })
    }).catch(e=>alert(e.message));
 
  }

  

  // getBacteriums(gramTypeParam){
  //   this.gramType = gramTypeParam;


  // }


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

  // return this.database.executeSql("SELECT id, nombre from Bacterias ", [])
  // async loadBacteriums(){
  //   return this.plt.ready()
  //   .then(()=>{

      
  //       return this.database.executeSql('SELECT id, nombre from Bacterias', []).then(data => {

  //         alert('Consulto las bacterias');

  //         let lists = [];
  //         // if (data === undefined)
  //         //   return lists;

  //         // if (data !== undefined && data !== null) {
  //         //   for(let i=0; i<data.rows.length; i++){
  //         //     lists.push(data.rows.item(i));
  //         //   }
  //         // }
  //         return lists;

  //     }).catch(error=> alert(error.message));

  //   }).catch(e=>alert(e.message));
  // }

  // retrieveAllBacteriums() : Promise{

  // }


}
