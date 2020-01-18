import { Injectable } from '@angular/core';
import { LoadingController } from '@ionic/angular';

@Injectable({
  providedIn: 'root'
})
export class LoadingService {
  constructor(public loadingController: LoadingController) {
  }

  async present(options: object) {
    await this.dismiss();

    await this.loadingController
      .create(options)
      .then(res => {
        res.present();
      });
  }

  async dismiss() {
    while (await this.loadingController.getTop() !== undefined) {
      await this.loadingController.dismiss();
    }
  }
}