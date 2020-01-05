import { Component, OnInit } from '@angular/core';
import { Platform } from '@ionic/angular';
import { ActivatedRoute, Router } from '@angular/router';
import { AlertController } from '@ionic/angular';

import { BehaviorSubject } from 'rxjs';
import { SQLite, SQLiteObject } from '@ionic-native/sqlite/ngx';
import { OperatorsModel, CustomControl } from '../../models/operators.model';
import { ValidatorService } from '../../validators/validator.service';
import { AntibioticsService } from '../../services/antibiotics.service';
import { AnalyzeService } from '../../services/analyze.service';

@Component({
  selector: 'app-input',
  templateUrl: './input.page.html',
  styleUrls: ['./input.page.scss'],
})
export class InputPage implements OnInit {

  public bacteriumId : String = '';
  public textDescription : String = '';
  private database: SQLiteObject;
  public count : number;

  private dbReady: BehaviorSubject<boolean> = new BehaviorSubject(false);
  
  constructor(private plt: Platform, 
    private activatedRoute: ActivatedRoute, 
    private sqlite: SQLite,
    private alertController: AlertController,
    private validatorService: ValidatorService,
    private antibioticsService : AntibioticsService,
    public context : OperatorsModel, public controlModel : CustomControl,
    public analyzeService : AnalyzeService,
    private router: Router) { 
      this.count = 0;
  }

  ngOnInit() {

    this.context.antibioticControls = [];
    this.context.testControls = [];
    
    this.plt.ready().then(() => {
      this.sqlite.create({
        name: 'fai.db',
        location: 'default'
      })
      .then((db: SQLiteObject) => {
          this.database = db;
          this.dbReady.next(true);
          
          this.bacteriumId = this.activatedRoute.snapshot.paramMap.get('id');
          this.textDescription = this.activatedRoute.snapshot.paramMap.get('name');

          this.plt.ready().then(() => {
            this.isReady()
            .then(()=>{

              this.database.executeSql(
              `
              SELECT * FROM AntibioticosPruebas WHERE idBacteria = ?
              `, [this.bacteriumId]).then(data => { 
                  if (data === undefined)
                    return;

                  if (data !== undefined && data !== null) {
                    for(let i=0; i<data.rows.length; i++){
               
                      let ctrl : CustomControl;
                      ctrl = new CustomControl();
                      ctrl.id = i;
                      ctrl.name = data.rows.item(i).nombre;
                      ctrl.idBacteria = data.rows.item(i).idBacteria;
                      ctrl.idAntibiotico = data.rows.item(i).id;
                      ctrl.idPrueba = data.rows.item(i).idPrueba;
                      ctrl.valor = 0;

                      if(data.rows.item(i).tipoControl==='INPUT TEXT'){
                        ctrl.operador = "<=";
                        ctrl.tipoGRAM = "+";

                        this.context.antibioticControls.push(ctrl);
                      }else {

                        this.context.testControls.push(ctrl);
                      }

                      this.count = i;              
                      ctrl = null;
                    }
                  }
        
                }).catch(e=>alert(e.message));
            }) 
            
          });
     
      });
    });

  }

  continue(){

    for(var a = 0; a < this.context.antibioticControls.length; a ++){
      if(this.context.antibioticControls[a].valor === undefined || this.context.antibioticControls[a].valor.toString().length === 0){
        this.presentAlertMultipleButtons('Debe ingresar un valor para ' + this.context.antibioticControls[a].name);
        return;
      }
  
      if(!this.validatorService.validateIsDecimal(this.context.antibioticControls[a].valor)){
        this.presentAlertMultipleButtons('El valor de '+ this.context.antibioticControls[a].name + ' debe ser numérico.');
        return;
      }
    }

    this.antibioticsService.insertData(this.context).then(() => {

      this.analyzeService.executeGramScript(this.bacteriumId, '+')
          .then(_ => {
            // this.presentAlertMultipleButtons('Análisis realizado satisfactoriamente.');

            this.router.navigate(['/summary', { name : this.textDescription }]);
            // this.router.navigateByUrl('/summary');
          })
          .catch(e => {
            alert(e.message);
          });

    });

  }

  comeBack(){
    this.router.navigateByUrl('/bacterium');
  }

  async presentAlertMultipleButtons(description: any) {
    const alert = await this.alertController.create({
      header: 'Información',
      message: description,
      buttons: ['Aceptar' ]
    });

    await alert.present();
  }

  private isReady(){
    return new Promise((resolve, reject) =>{
      if(this.dbReady.getValue()){
        resolve();
      }
      else{
        this.dbReady.subscribe((ready)=>{
          if(ready){ 
            resolve(); 
          }
        });
      }  
    });
  }

}
