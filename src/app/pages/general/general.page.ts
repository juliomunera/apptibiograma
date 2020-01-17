import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRoute } from "@angular/router";
import { ModalController, AlertController } from '@ionic/angular';

import { InfectionPage } from '../infection/infection.page'
import { ContextModel }  from '../../models/context.model';

import { ValidatorService } from '../../validators/validator.service';
import { GeneraldbService } from '../../services/generaldb.service';
import { HelperService } from '../../services/helper.service';

@Component({
  selector: 'app-general',
  templateUrl: './general.page.html',
  styleUrls: ['./general.page.scss'],
})
export class GeneralPage implements OnInit {
  
  dataReturned : any = "Seleccionar";
  refresh : string = '';

  constructor(private router: Router, 
              private activatedRoute: ActivatedRoute,
              private modalController: ModalController,
              private validatorService: ValidatorService,
              private alertController: AlertController,
              private db : GeneraldbService,
              private helperService : HelperService,
              public contextModel : ContextModel) {

    this.contextModel.name = 'Seleccionar';
    this.contextModel.depuracionCreatinina = this.getCreatinineDebug();
  }
  
  clearInputData(){
    
    this.refresh = this.activatedRoute.snapshot.paramMap.get('refresh');

    if(this.refresh !== undefined && this.refresh !== ''){
      this.contextModel.name = 'Seleccionar';
      this.contextModel.depuracionCreatinina = 0;
      this.contextModel.sexType = undefined;
      this.contextModel.yearsOld = undefined;
      this.contextModel.weight = undefined;
      this.contextModel.alergiaPenicilina = false;
      this.contextModel.creatinina = undefined;
      this.contextModel.hemodialisis = false;
      this.contextModel.capd = false;
      this.contextModel.crrt = false;
    }
  }

  ngOnInit() {

  }

  ionViewWillEnter() {
    if(this.contextModel.depuracionCreatinina > 0){
    let debugCreatinine = (((this.contextModel.sexType === 'F')?0.85:1) * (140 - this.contextModel.yearsOld)*this.contextModel.weight)/(72*this.contextModel.creatinina);

    if (debugCreatinine === NaN)
      debugCreatinine = 0;
    else
      this.contextModel.depuracionCreatinina = Number(debugCreatinine.toFixed(2));
    }
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
        this.contextModel.infectionLocation = dataReturned.data;
      }
    });
 
    return await modal.present();
  }

  continue(){

    if(this.contextModel.sexType === '' || this.contextModel.sexType === undefined){
      this.presentAlertMultipleButtons('Debe seleccionar el sexo de paciente');
      return;
    }

    if(this.validatorService.validateIsInteger(this.contextModel.yearsOld) === true){
      this.presentAlertMultipleButtons('El valor de la edad debe ser entero');
      return;
    }

    if(!this.validatorService.validateLimit(this.contextModel.yearsOld, 0, 120)){
      this.presentAlertMultipleButtons('El valor de la edad es incorrecto. Debe estar entre 0 y 120 años');
      return;
    }

    if(!this.validatorService.validateLimit(this.contextModel.weight, 0, 10000)){
      this.presentAlertMultipleButtons('El valor del peso debe ser mayor o igual a cero');
      return;
    }

    if(!this.validatorService.validateLimit(this.contextModel.creatinina, 0, 10000)){
      this.presentAlertMultipleButtons('El valor de la creatinina debe ser mayor o igual a cero');
      return;
    }

    if(this.contextModel.infectionLocation === undefined || this.contextModel.infectionLocation.toString().trim().length === 0 || this.contextModel.name === 'Seleccionar'){
      this.presentAlertMultipleButtons('Debe seleccionar la ubicación de la infección');
      return;
    }

    var dateNow = new Date();

    let params = [this.helperService.infectionLocationType(this.contextModel.name), this.helperService.formatDate(dateNow), 
                  this.contextModel.sexType, this.contextModel.yearsOld, this.contextModel.weight, this.contextModel.creatinina,
                (this.contextModel.alergiaPenicilina?1:0), (this.contextModel.hemodialisis?1:0), (this.contextModel.capd?1:0),
                (this.contextModel.crrt?1:0), this.contextModel.depuracionCreatinina];

    this.db.insertGeneralData(params).then(()=> {
      // this.router.navigateByUrl('/gram');

      this.router.navigate(['/gram', { bodyName : this.contextModel.name }]);
    })
    .catch(e => {
      alert(e.message);
    });
  }

  getCreatinineDebug(){
    let debugCreatinine = 0;

    if(this.contextModel.sexType === undefined || this.contextModel.sexType === '')
      return 0;

    if(this.contextModel.yearsOld === undefined || this.contextModel.yearsOld === 0)
      return 0;  
   
    if(this.contextModel.weight === undefined || this.contextModel.weight === 0)
      return 0;

    if(this.contextModel.creatinina === undefined || this.contextModel.creatinina === 0)
      return 0;

    debugCreatinine = (((this.contextModel.sexType === 'F')?0.85:1) * (140 - this.contextModel.yearsOld)*this.contextModel.weight)/(72*this.contextModel.creatinina);
    
    if (debugCreatinine === NaN)
      debugCreatinine = 0;
    else
      this.contextModel.depuracionCreatinina = Number(debugCreatinine.toFixed(2));

    return debugCreatinine;
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
