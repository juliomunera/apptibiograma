
export class CustomControl {
    id : number;
    name : String;
    idBacteria : number;
    idAntibiotico : number;
    idPrueba : number;
    operador : String;
    valor : number;
    tipoGRAM : String;
}

export class OperatorsModel {
    name: string;
    antibioticControls : CustomControl[];
    testControls : CustomControl[];
  }
  
  export interface Deserializable {
      deserialize(input: any): this;
    }
  
  export default OperatorsModel;