import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class RestapiService {

  apiUrl : any = 'https://jsonplaceholder.typicode.com';
  validateCodeUrl : any = 'http://apptibiograma.analyticsmodels.com/validecode.php?token=zTa5RzNLKQQDp8XBMdKu2Vu7Xp3dDYuP&codigo=';

  constructor(private http: HttpClient) { }

  validateAccessCode(code : any) {

    return new Promise((resolve, reject) => {

      this.http.post(this.validateCodeUrl + code, null)
        .subscribe(res => { 
          console.log(res);
            resolve(res);
        }, (err) => {
          console.log(err);
            reject(err);
        });
    });
  }

}
