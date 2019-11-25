import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ValidatorService {

  constructor() { }

  validateInteger(itemValue : any){
    return Number.isInteger(itemValue);
  }

  validateLimit(itemValue: Number, minValue: Number, maxValue: Number){
    let result = false;

    console.log(Number.isFinite(1));

    if(itemValue >= minValue && itemValue <= maxValue)
      result = true;

    return result;
  }

  validateIsDecimal(itemValue : any){
      let result : Number;

      if (((Number.parseInt(itemValue.toString())) % itemValue) === 0)
        return false;
      else
        return true;
  }

}
