import { Component, OnInit } from '@angular/core';
import { Router } from "@angular/router";
import { ModalController } from '@ionic/angular';
import { InfectionPage } from '../infection/infection.page'

@Component({
  selector: 'app-general',
  templateUrl: './general.page.html',
  styleUrls: ['./general.page.scss'],
})
export class GeneralPage implements OnInit {
  dataReturned : any = "Seleccionar";

  constructor(private router: Router, public modalController: ModalController) { }

  ngOnInit() {
  }

  getLocation(){
    this.router.navigateByUrl('/body');
  }

  async presentModal() {
    const modal = await this.modalController.create({
      component: InfectionPage,
      componentProps: {
        "isHomeCall": true
      }
    });
 
    modal.onDidDismiss().then((dataReturned) => {
      if (dataReturned !== null) {
        this.dataReturned = dataReturned.data;
      }
    });
 
    return await modal.present();
  }

  continue(){
    this.router.navigateByUrl('/gram');
  }

}
