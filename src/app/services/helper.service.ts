import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class HelperService {

  constructor() { }

  formatDate(date) {
    var d = new Date(date),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

    if (month.length < 2) 
        month = '0' + month;
    if (day.length < 2) 
        day = '0' + day;

    return [year, month, day].join('-');
  }

  infectionLocationType(value : String){
    let result = null;

    switch (value) {
      case 'Sistema nervioso':
        result = 0;
          break;
      case 'Boca, senos, paranasales y cuello':
        result = 1;
          break;
      case 'Pulmones y vía aérea':
        result = 2;
          break;
      case 'Abdomen':
        result = 3;  
          break;
      case 'Tracto genito urinario':
        result = 4; 
          break;
      case 'Huesos':
        result = 5;
          break;
      case 'Prostata':
        result = 6; 
          break;
      case 'Tejidos blandos':
        result = 7;
        break;
      case 'Sangre':
        result = 8;
        break;
  }

    return result;
  }

}
