import { Component, OnInit } from '@angular/core';
import { Platform } from '@ionic/angular';
import { ActivatedRoute, Router } from '@angular/router';

import { BehaviorSubject } from 'rxjs';
import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';

@Component({
  selector: 'app-bacterium',
  templateUrl: './bacterium.page.html',
  styleUrls: ['./bacterium.page.scss'],
})
export class BacteriumPage implements OnInit {

  private database: SQLiteObject;
  public bacteriumsList : any[] = [];
  private bodyName : String = '';
  private gramType : String = '';
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
          
          this.gramType = this.activatedRoute.snapshot.paramMap.get('gramType');
          this.bodyName = this.activatedRoute.snapshot.paramMap.get('bodyName');

          this.plt.ready().then(() => {
            this.isReady()
            .then(()=>{
              this.database.executeSql(`SELECT id, nombre from Bacterias WHERE nombre <> 'NA'`, []).then(data => { 

                  if (data === undefined)
                    return;
        
                  if (data !== undefined && data !== null) {
                    for(let i=0; i<data.rows.length; i++){
                      this.bacteriumsList.push(data.rows.item(i));
                    }
                  }
        
                }).catch(e=>alert(e.message));
            }) 
            
          });
     
      });
    });

  }

  ngOnInit() {
    // 
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

  itemSelected(itemSelected){

    this.router.navigate(['/input', { id: itemSelected.id, name : itemSelected.nombre, bodyName : this.bodyName, gramType : this.gramType }]);
  }

  continue(){
    
  }
}
