import { Component, OnInit } from '@angular/core';
import { ModalController, NavParams } from '@ionic/angular';

import { InAppBrowser } from '@ionic-native/in-app-browser/ngx';

@Component({
  selector: 'app-code',
  templateUrl: './code.page.html',
  styleUrls: ['./code.page.scss'],
})
export class CodePage implements OnInit {
  
  isHomeCalled:boolean;

  constructor(private modalController: ModalController,
    private navParams: NavParams,
    private iab: InAppBrowser) { }

  ngOnInit() {
    // this.isHomeCalled = this.navParams.data.isHomeCall;
  }
  payAccessCode(){
    this.iab.create(`https://www.google.com`, `_blank`);
  }

  async closeModal() {
    const onClosedData: string = "";
    await this.modalController.dismiss(onClosedData);
  }
  
  async validCode(){
    const onClosedData: string = "valid";
    await this.modalController.dismiss(onClosedData);
  }

}
