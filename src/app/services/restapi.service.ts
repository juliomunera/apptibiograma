import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
// import 'rxjs/add/operator/retry';
// import 'rxjs/add/operator/timeout';
// import 'rxjs/add/operator/delay';

@Injectable({
  providedIn: 'root'
})
export class RestapiService {

  apiUrl : any = 'https://jsonplaceholder.typicode.com';

  constructor(private http: HttpClient) { }

  callRestApi() {
    let data = {
        "id": 15232,
        "name": "Julio Munera",
        "username": "Bret",
        "email": "Sincere@april.biz",
        "address": {
          "street": "Kulas Light",
          "suite": "Apt. 556",
          "city": "Gwenborough",
          "zipcode": "92998-3874",
          "geo": {
            "lat": "-37.3159",
            "lng": "81.1496"
            }
          }
      }

    return new Promise((resolve, reject) => {
      this.http.post(this.apiUrl + '/users', JSON.stringify(data), 
      {
        headers : new HttpHeaders().set('Autorization', 'my-token')
      }) 
        .subscribe(res => {
            resolve(res);
        }, (err) => {
            alert(err);
            reject(err);
        });
    });

  }
}
