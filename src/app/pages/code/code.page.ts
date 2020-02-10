import { Component, OnInit } from '@angular/core';
import { ModalController, AlertController } from '@ionic/angular';

import { InAppBrowser } from '@ionic-native/in-app-browser/ngx';
import { RestapiService } from '../../services/restapi.service';
import { LoadingService } from '../../services/loading.service';

import { HelperService } from '../../services/helper.service';
import { ContextModel }  from '../../models/context.model';
import { ImportdbService, BacteriasAntibioticos } from '../../services/importdb.service';

@Component({
  selector: 'app-code',
  templateUrl: './code.page.html',
  styleUrls: ['./code.page.scss'],
})
export class CodePage implements OnInit {
  
  isHomeCalled : boolean;
  result : any;
  accessCode : String;

  bacteriasAntibioticos: BacteriasAntibioticos[] = [];

  constructor(private modalController: ModalController,
    private rest: RestapiService,
    private alertController: AlertController,
    private loadingService: LoadingService,
    private helperService : HelperService,
    public contextModel : ContextModel,
    private db : ImportdbService,
    private iab: InAppBrowser) { 

      this.contextModel.code = "";
  }

  ngOnInit() {
    this.db.getDatabaseState().subscribe(rdy => {

    });
  }

  payAccessCode(){
    this.iab.create(`http://analyticsmodels.com/project/apptibiograma/`, `_blank`);
  }

  closeModal() {
    const onClosedData: string = "";
    this.modalController.dismiss(onClosedData);
  }
  
  async validCode(){

    if(this.contextModel.code.length === 0 || this.contextModel.code.trim().length === 0){
      await this.presentAlert('Debe ingresar el código de acceso');
      return;
    }

    this.loadingService.present({
      message: 'Cargando...',
      duration: 1000
    });

    this.rest.validateAccessCode(this.contextModel.code).then(response => {

      this.result = response;
      this.loadingService.dismiss();

      if(this.result.ndias > 0){
        let days = this.result.ndias;

        var dateNow = new Date();
        let params = [this.helperService.formatDate(dateNow), days]

        this.db.insertAllowAccess(params).then(()=> {

          this.modalController.dismiss("valid");
        })
        .catch(e => {
          console.log(e.message);
        });

      }
      else{
        this.modalController.dismiss("");
        this.presentAlert(`No posee créditos: ${this.result.msg}`);
        return;
      }
    })
    .catch(error=>{

      this.loadingService.dismiss();
      this.presentAlert('Código incorrecto. Verifique la información.')
      return;
    });

    this.loadingService.dismiss();
  }

  async presentAlert(description: any) {
    const alert = await this.alertController.create({
      header: 'Información',
      message: description,
      buttons: ['Aceptar'],
    });
  
    await alert.present();
    let result = await alert.onDidDismiss();
    console.log(result);
  }

}
