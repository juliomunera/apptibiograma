import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Platform } from '@ionic/angular';

import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';
import { BehaviorSubject, iif } from 'rxjs';

@Component({
  selector: 'app-summary',
  templateUrl: './summary.page.html',
  styleUrls: ['./summary.page.scss'],
})
export class SummaryPage implements OnInit {

  private database: SQLiteObject;
  private dbReady: BehaviorSubject<boolean> = new BehaviorSubject(false);
  public  lists = [];
  public  listsDosis = [];
  public textDescription : String;
  private bodyName : String = '';
  public countMsgTest : number = 0;
  public bacteriumId : String = '';
  private gramType : String = '';

  constructor(private router: Router,
    private plt: Platform, 
    private sqlite: SQLite, 
    private activatedRoute: ActivatedRoute, 
    
    ) {

      this.plt.ready().then(() => {
        this.sqlite.create({
          name: 'fai.db',
          location: 'default'
        })
        .then((db: SQLiteObject) => {
            this.database = db;

            this.database.executeSql(`SELECT total FROM validarTestMsg`, [])
            .then(total => {
      
                if (total !== undefined){
                  if(total.rows.item(0).total > 0) {
                    this.countMsgTest = Number(total.rows.item(0).total);
                  }
                }
            })
            .catch(e => {
              alert(e.message);                    
            });

        })
      });

      this.textDescription = this.activatedRoute.snapshot.paramMap.get('name');
      this.bodyName = this.activatedRoute.snapshot.paramMap.get('bodyName');
      this.bacteriumId = this.activatedRoute.snapshot.paramMap.get('id');
      this.gramType = this.activatedRoute.snapshot.paramMap.get('gramType');
    }

  ngOnInit() {
   
    this.plt.ready().then(() => {
      this.sqlite.create({
        name: 'fai.db',
        location: 'default'
      })
      .then((db: SQLiteObject) => {
          this.database = db;
          this.dbReady.next(true);
          
          this.plt.ready().then(() => {
            this.isReady()
            .then(()=>{

              this.database.executeSql(
              `
              SELECT idParteDelCuerpo, idBacteria, idAntibiotico, idAsignacion, mensaje, 0 as "flag" from EtapaUnoyEtapaDos
              `, []).then(data => { 
                  if (data === undefined)
                    return;

                  if (data === undefined)
                    return this.lists;

                  if (data !== undefined && data !== null) {
                    for(let i=0; i<data.rows.length; i++){
                      this.lists.push(data.rows.item(i));

                      if(data.rows.item(i).mensaje.indexOf('test') >= 0 || data.rows.item(i).mensaje.indexOf('descartar bacteriemia') >= 0)
                        this.lists[i].flag = 1;
                    }
                  }

                  this.database.executeSql(`
                    SELECT e3.id, e3.idAsignacion, e3.mensaje, a.comentariosTratamiento
                    FROM InterpretacionGRAMEtapa3 e3 INNER JOIN Asignaciones a ON e3.idAsignacion = a.id`, [])
                  .then(dosis => {
                      if (dosis === undefined)
                        return;

                      if (dosis === undefined)
                        return this.listsDosis;

                      if (dosis !== undefined && dosis !== null) {
                        for(let i=0; i<dosis.rows.length; i++){
                          this.listsDosis.push(dosis.rows.item(i));
                        }
                      }

                  })
                  .catch(e => {
                    alert(e.message);                    
                  })
        
                }).catch(e=>alert(e.message));
            });
            
          });
     
      });
    });

  }

  finish(){
    this.router.navigate(['/general', { refresh: '1' }]);
  }

  comeBack(){
    this.router.navigate(['/input', { id : this.bacteriumId, name : this.textDescription, bodyName : this.bodyName, gramType : this.gramType }]);
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
  
}
