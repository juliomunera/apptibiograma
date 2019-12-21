import { Component, OnInit } from '@angular/core';
import { Platform } from '@ionic/angular';
import { ActivatedRoute, Router } from '@angular/router';

import { BehaviorSubject } from 'rxjs';
import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';

@Component({
  selector: 'app-test',
  templateUrl: './test.page.html',
  styleUrls: ['./test.page.scss'],
})
export class TestPage implements OnInit {

  private database: SQLiteObject;
  public dataList : any[] = [];
  public general : any[] = [];
  private dbReady: BehaviorSubject<boolean> = new BehaviorSubject(false);

  constructor(private plt: Platform, 
    private activatedRoute: ActivatedRoute, private sqlite: SQLite,
    private router: Router) { 

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
              this.database.executeSql(`SELECT id, idBacteria, idAntibiotico, idPrueba, operador, valor, tipoGRAM from GRAM `, []).then(data => { 
                  if (data === undefined)
                    return;
        
                  if (data !== undefined && data !== null) {
                    for(let i=0; i<data.rows.length; i++){
                      this.dataList.push(data.rows.item(i));
                    }
                  }
        
                }).catch(e=>console.log(e.message));
            })
            .then(()=>{
              this.database.executeSql(`SELECT idParteDelCuerpo, fechaRegistro, genero, edad, peso, creatinina, esAlergicoAPenicilina, requiereHemodialisis, CAPD, CRRT, depuracionCreatinina from DatosDelPaciente `, []).then(data => { 
                  if (data === undefined)
                    return;
        
                  if (data !== undefined && data !== null) {
                    for(let i=0; i<data.rows.length; i++){
                      this.general.push(data.rows.item(i));
                    }
                  }
        
                }).catch(e=>console.log(e.message));
            }) 
            
          });
     
      }).catch(e=> console.log(e.message));
    });

  }

  ngOnInit() {

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
