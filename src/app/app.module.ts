import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { RouteReuseStrategy } from '@angular/router';

import { IonicModule, IonicRouteStrategy } from '@ionic/angular';
import { SplashScreen } from '@ionic-native/splash-screen/ngx';
import { StatusBar } from '@ionic-native/status-bar/ngx';
import { AppComponent } from './app.component';
import { AppRoutingModule } from './app-routing.module';

import { CodePageModule } from './pages/code/code.module';
import { InfectionPageModule } from './pages/infection/infection.module'
import { InAppBrowser } from '@ionic-native/in-app-browser/ngx';
import { SQLitePorter } from '@ionic-native/sqlite-porter/ngx';
import { SQLite } from '@ionic-native/sqlite/ngx';
import { HttpClientModule } from '@angular/common/http';

import { BacteriumdbService } from './services/bacteriumdb.service';
import { GeneraldbService } from './services/generaldb.service';
import { HomedbService } from './services/homedb.service';
import { ImportdbService } from './services/importdb.service';

import { RestapiService } from './services/restapi.service';
import { ValidatorService } from './validators/validator.service';
import { HelperService } from './services/helper.service';
import { ContextModel } from '../app/models/context.model';
import { AntibioticsService } from './services/antibiotics.service';
import { AnalyzeService } from './services/analyze.service';

import { OperatorsModel, CustomControl } from '../app/models/operators.model';
import { ReactiveFormsModule } from '@angular/forms';


@NgModule({
  declarations: [AppComponent],
  entryComponents: [],
  imports: [
    BrowserModule, 
    IonicModule.forRoot(),
    AppRoutingModule,
    CodePageModule,
    InfectionPageModule,
    HttpClientModule,
    ReactiveFormsModule
  ],
  providers: [
    StatusBar,
    SplashScreen,
    SQLite,
    SQLitePorter,
    InAppBrowser,
    BacteriumdbService,
    GeneraldbService,
    HomedbService,
    ImportdbService,
    RestapiService,
    ValidatorService,
    HelperService,
    ContextModel,
    OperatorsModel,
    CustomControl,
    AntibioticsService,
    AnalyzeService,
    { provide: RouteReuseStrategy, useClass: IonicRouteStrategy },
    SQLite,
    SQLitePorter
  ],
  bootstrap: [AppComponent]
})
export class AppModule {}
