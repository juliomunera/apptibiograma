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
    }).catch(e=>alert(e.message));
 
  }

}
