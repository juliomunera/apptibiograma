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
import { DatabaseService } from './services/database.service';
import { RestapiService } from './services/restapi.service';
import { ValidatorService } from './validators/validator.service';

import { ContextModel } from '../app/models/context.model';

// https://github.com/AndrewJBateman/ionic-angular-sqlite/tree/master/src/app

@NgModule({
  declarations: [AppComponent],
  entryComponents: [],
  imports: [
    BrowserModule, 
    IonicModule.forRoot(),
    AppRoutingModule,
    CodePageModule,
    InfectionPageModule,
    HttpClientModule
  ],
  providers: [
    StatusBar,
    SplashScreen,
    SQLite,
    SQLitePorter,
    InAppBrowser,
    DatabaseService,
    RestapiService,
    ValidatorService,
    ContextModel,
    { provide: RouteReuseStrategy, useClass: IonicRouteStrategy }
  ],
  bootstrap: [AppComponent]
})
export class AppModule {}
