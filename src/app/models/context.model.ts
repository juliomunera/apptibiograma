

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
}

export interface Deserializable {
    deserialize(input: any): this;
  }

export default ContextModel;