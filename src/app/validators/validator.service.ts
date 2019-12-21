import { Injectable } from '@angular/core';
import { isNumber } from 'util';

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

  validateIsInteger(itemValue : any){
      if (itemValue === undefined && itemValue === null)
        return false;

      if (((Number.parseInt(itemValue)) % itemValue) === 0)
        return false;
      else
        return true;
  }

  validateIsDecimal(itemValue : any){

    if ((undefined === itemValue) || (null === itemValue)) {
      return false;
    }
    if (typeof itemValue == 'number') {
        return true;
    }
    return !isNaN(itemValue - 0);
  }

}
