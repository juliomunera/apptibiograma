

export class ContextModel {
  sexType : String;
  yearsOld: number;
  name: string;
  weight : number;
  creatinina : number;
  alergiaPenicilina : boolean;
  hemodialisis : boolean;
  capd : boolean;
  crrt : boolean;
  depuracionCreatinina : number;
  infectionLocation : number;
  code: String;
}

export interface Deserializable {
    deserialize(input: any): this;
  }

export default ContextModel;