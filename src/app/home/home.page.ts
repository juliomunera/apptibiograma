import { Component } from '@angular/core';
import { Router } from "@angular/router";
import { ModalController } from '@ionic/angular';
import { CodePage } from '../code/code.page';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {

  dataReturned:any;

  constructor(private router: Router, public modalController: ModalController) { }

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
