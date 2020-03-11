import { Component } from '@angular/core';

import { Platform } from '@ionic/angular';
import { SplashScreen } from '@ionic-native/splash-screen/ngx';
import { StatusBar } from '@ionic-native/status-bar/ngx';

@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  styleUrls: ['app.component.scss']
})
export class AppComponent {
  public appPages = [
    {
      title: 'Inicio',
      url: '/home',
      icon: 'home'
    }
    ,{
      title: 'Legal',
      url: '/legal',
      icon: 'book'
    }
    ,{
      title: 'Acerca de',
      url: '/about',
      icon: 'person'
    }
    ,{
      title: 'Contáctenos',
      url: '/contact',
      icon: 'mail'
    }
    // ,{
    //   title: 'Test',
    //   url: '/test',
    //   icon: 'home'
    // }
  ];

  constructor(
    private platform: Platform,
    private splashScreen: SplashScreen,
    private statusBar: StatusBar
  ) {
    this.initializeApp();
  }

  initializeApp() {
    this.platform.ready().then(() => {
      this.statusBar.styleDefault();
      this.splashScreen.hide();
    });
  }
}
