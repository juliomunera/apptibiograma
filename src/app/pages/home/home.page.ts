import { Component } from '@angular/core';
import { Router } from "@angular/router";

import moment from 'moment'

import { ModalController } from '@ionic/angular';
import { CodePage } from '../code/code.page';

import { HomedbService } from '../../services/homedb.service';
import { HelperService } from 'src/app/services/helper.service';


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
    private db : HomedbService,
    private helperService : HelperService) { 
      
    }

  ngOnInit() {
  }

  getDiffDays(dateDb : any){
    let result = 0;

    var dateNow = new Date();
    let currentDate = this.helperService.formatDate(dateNow);

    let date1 = moment(currentDate, "YYYY-MM-DD");
    let date2 = moment(dateDb, "YYYY-MM-DD"); 

    let duration = moment.duration(date1.diff(date2));
    result = Math.abs(duration.asDays());

    return result;
  }

  addDateTime(date : any, days : number){
    let parsed = moment(date, "YYYY/MM/DD");
    let newDate = parsed.add(days, 'days').format('YYYY-MM-DD');

    return newDate;
  }

  async starAnalyze() {

    this.db.getDaysAccess()
    .then((data:any) => {

      if(data.length > 0){ 

        if (data[0].dias <= 0){
          this.presentModal();
          return;
        }

        let date = data[0].fechaRegistro;
        let diff = this.getDiffDays(date);

        var dateNow = new Date(); 
        let params = [this.helperService.formatDate(dateNow), data[0].dias - Math.abs(diff)]

        this.db.insertAllowAccess(params).then(()=> {
          this.router.navigateByUrl('/general');
          return;
        })
        .catch(e => {
          this.presentModal();
        });

      }else{
        this.presentModal();
        return;
      }

     }
    )
    .catch(e => {
      this.presentModal();
    });

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
