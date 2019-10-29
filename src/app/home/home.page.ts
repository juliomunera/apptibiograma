import { Component } from '@angular/core';
import { Router } from "@angular/router";
import { ModalController } from '@ionic/angular';
import { LegalPage } from '../legal/legal.page'

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage {

  constructor(private router: Router, public modalController: ModalController) { }

  async presentModal() {
    const modal = await this.modalController.create({
      component: LegalPage
    });
    return await modal.present();
  }

  showLegalText(){
    this.router.navigateByUrl('/legal');
  }
}
