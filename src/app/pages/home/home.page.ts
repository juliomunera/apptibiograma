import { Component } from '@angular/core';
import { Router } from "@angular/router";

import { ModalController } from '@ionic/angular';
import { CodePage } from '../code/code.page';
import { Platform } from '@ionic/angular';

import { RestapiService } from '../../services/restapi.service';
import { LoadingService } from '../../services/loading.service';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {

  dataReturned:any;
  result:any;

  constructor(private router: Router, 
    public modalController: ModalController,
    private rest: RestapiService,
    private platform : Platform,
    private loadingService: LoadingService) { 

      this.platform.ready().then(() => {
        // this.splashScreen.hide();
        // this.statusBar.styleDefault();        
      });
    }

    ngOnInit() {

      this.loadingService.present({
        message: 'Cargando...',
        duration: 1000
      });

      this.rest.addUser().then(response=> {
        this.result = response;
        this.loadingService.dismiss();
        console.log(this.result);
      })
      .catch(error=>{
        this.loadingService.dismiss();
        alert(error);
      })

      // this.db.addList('New item1 list')
      // .then((response)=> {
        
      // })

      // this.db.getLists()
      // .then((data:any) => {
      //    alert(data.length);
      //   }
      // )

    }

  async presentModal() {
    const modal = await this.modalController.create({
      component: CodePage,
      componentProps: {
        "isHomeCall": true
      }
    });
 
    modal.onDidDismiss().then((dataReturned) => {
      if (dataReturned !== null) {
        this.dataReturned = dataReturned.data;
        
        if(this.dataReturned !== undefined && this.dataReturned.length > 0) {
          this.router.navigateByUrl('/general');
        }
      }
    });
 
    return await modal.present();
  }

  showLegalText(){
    this.router.navigateByUrl('/legal');
  }

}
