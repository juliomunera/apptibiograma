import { Component, OnInit } from '@angular/core';
import { Router } from "@angular/router";
import { ModalController, AlertController } from '@ionic/angular';

import { InfectionPage } from '../infection/infection.page'
import { ContextModel }  from '../../models/context.model';

import { ValidatorService } from '../../validators/validator.service';

@Component({
  selector: 'app-general',
  templateUrl: './general.page.html',
  styleUrls: ['./general.page.scss'],
})
export class GeneralPage implements OnInit {
  dataReturned : any = "Seleccionar";

  // https://www.joshmorony.com/advanced-forms-validation-in-ionic-2/

  constructor(private router: Router, 
              private modalController: ModalController,
              private validatorService: ValidatorService,
              private alertController: AlertController,
              private contextModel : ContextModel) {

    // this.contextModel.sexType = 'F';
    // this.contextModel.yearsOld = 3;
    // this.contextModel.weight = 20.3;
    // this.contextModel.creatinina = 1.7;
    // this.contextModel.alergiaPenicilina = true;
    // this.contextModel.hemodialisis = false;
    // this.contextModel.capd = true;
    // this.contextModel.crrt = true;
    // this.contextModel.depuracionCreatinina = 4.5;

    this.contextModel.name = 'Seleccionar';

    console.log(this.contextModel);
  }

  ngOnInit() {
  }

  getLocation(){
    this.router.navigateByUrl('/body');
  }

  async presentModal() {
    const modal = await this.modalController.create({
      component: InfectionPage,
      componentProps: this.contextModel
    });
 
    modal.onDidDismiss().then((dataReturned) => {
      if (dataReturned !== null) {
        this.contextModel.name = dataReturned.data;
        // this.dataReturned = dataReturned.data;
      }
    });
 
    return await modal.present();
  }

  continue(){

    if(this.contextModel.sexType === '' || this.contextModel.sexType === undefined){
      this.presentAlertMultipleButtons('Debe seleccionar el sexo de paciente');
      return;
    }

    if(this.validatorService.validateIsDecimal(this.contextModel.yearsOld) === true){
      this.presentAlertMultipleButtons('El valor de la edad debe ser entero');
      return;
    }

    if(!this.validatorService.validateLimit(this.contextModel.yearsOld, 0, 120)){
      this.presentAlertMultipleButtons('El valor de la edad es incorrecto. Debe estar entre 0 y 120 años');
      return;
    }

    // if(this.validatorService.validateIsDecimal(this.contextModel.weight) === true){
    //   this.presentAlertMultipleButtons('El valor del peso debe ser entero');
    //   return;
    // }

    // if(Number.isInteger(this.contextModel.creatinina) === true){
    //   this.presentAlertMultipleButtons('El valor de la creatinina es incorrecto');
    //   return;
    // }

    this.router.navigateByUrl('/gram');
  }

  async presentAlertMultipleButtons(description: any) {
    const alert = await this.alertController.create({
      header: 'Información',
      message: description,
      buttons: ['Aceptar' ]
    });

    await alert.present();
  }

}
