import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Platform } from '@ionic/angular';

import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';
import { BehaviorSubject } from 'rxjs';

@Component({
  selector: 'app-summary',
  templateUrl: './summary.page.html',
  styleUrls: ['./summary.page.scss'],
})
export class SummaryPage implements OnInit {

  // data : any;
  // dosis : any;

  private database: SQLiteObject;
  private dbReady: BehaviorSubject<boolean> = new BehaviorSubject(false);
  public  lists = [];
  public  listsDosis = [];
  public textDescription : String;

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
        }
        )
      });

      this.textDescription = this.activatedRoute.snapshot.paramMap.get('name');

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
              SELECT idParteDelCuerpo, idBacteria, idAntibiotico, idAsignacion, mensaje from EtapaUnoyEtapaDos
              `, []).then(data => { 
                  if (data === undefined)
                    return;

                  if (data === undefined)
                    return this.lists;

                  if (data !== undefined && data !== null) {
                    for(let i=0; i<data.rows.length; i++){
                      this.lists.push(data.rows.item(i));
                    }
                  }

                  this.database.executeSql(`SELECT id, idAsignacion, mensaje FROM InterpretacionGRAMEtapa3`, [])
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
    this.router.navigateByUrl('/general');
  }

  comeBack(){
    this.router.navigateByUrl('/input');
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

  getSummaryInfo(){

    return this.plt.ready()
    .then(()=> {

      // return this.database.executeSql("SELECT id, idParteDelCuerpo, idBacteria, idAntibiotico, idAsignacion, mensaje from EtapaUnoyEtapaDos", [])
      // .then((data)=>{

      //   let lists = [];
      //   if (data === undefined)
      //     return lists;

      //   if (data !== undefined && data !== null) {
      //     for(let i=0; i<data.rows.length; i++){
      //       lists.push(data.rows.item(i));
      //     }
      //   }
      //   return lists;
      // })
      // .catch(error => {
      //   console.log(error.message);
      // });
      
    });


  }
  
}
