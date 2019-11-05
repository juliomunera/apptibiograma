import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-bacterium',
  templateUrl: './bacterium.page.html',
  styleUrls: ['./bacterium.page.scss'],
})
export class BacteriumPage implements OnInit {

  constructor() { }

  ngOnInit() {
  }

  selectOption(text){
    alert(text);
  }
}
