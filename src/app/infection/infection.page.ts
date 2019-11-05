import { Component, OnInit } from '@angular/core';
import { Router } from "@angular/router";
import { ModalController } from '@ionic/angular';

@Component({
  selector: 'app-infection',
  templateUrl: './infection.page.html',
  styleUrls: ['./infection.page.scss'],
})
export class InfectionPage implements OnInit {

  isSelected : boolean = false;
  selectedText : any = '';

  constructor(private router: Router, public modalController: ModalController) { }

  ngOnInit() {
  }

    selectRegion(area){
    this.isSelected = true;
    this.selectedText = area;
  }

  async continue() {
    let onClosedData: string = this.selectedText;

    if (onClosedData === ""){
      onClosedData = "Seleccionar";
    }

    await this.modalController.dismiss(onClosedData);
  }
}
