import { Component, OnInit } from '@angular/core';
import { Router } from "@angular/router";
import { ModalController } from '@ionic/angular';

import { ContextModel }  from '../../models/context.model';
import { IonContent } from '@ionic/angular';

@Component({
  selector: 'app-infection',
  templateUrl: './infection.page.html',
  styleUrls: ['./infection.page.scss'],
})
export class InfectionPage implements OnInit {

  isSelected : boolean = false;
  selectedText : any = '';

  constructor(
    private router: Router, 
    public modalController: ModalController,
    private contextModel : ContextModel) { }

  ngOnInit() {
  }

  async selectRegion(area){
    this.isSelected = true;
    this.selectedText = area;

    this.contextModel.name = this.selectedText;
    if (this.contextModel.name === ""){
      this.contextModel.name = "Seleccionar";
    }

    await this.modalController.dismiss(this.contextModel.name);

  }

  async continue() {
    this.contextModel.name = this.selectedText;

    if (this.contextModel.name === ""){
      this.contextModel.name = "Seleccionar";
    }

    await this.modalController.dismiss(this.contextModel.name);
  }

  logScrollStart(){
    alert("logScrollStart : When Scroll Starts");
  }
 
  logScrolling(){
    alert("logScrolling : When Scrolling");
  }
 
  logScrollEnd(){
    alert("logScrollEnd : When Scroll Ends");
  }
 

}
