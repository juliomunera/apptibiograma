import { Component, OnInit } from '@angular/core';
import { Router } from "@angular/router";

@Component({
  selector: 'app-bacterium',
  templateUrl: './bacterium.page.html',
  styleUrls: ['./bacterium.page.scss'],
})
export class BacteriumPage implements OnInit {

  constructor(private router: Router) { }

  ngOnInit() {
  }

  selectOption(_id){
    this.router.navigate(['/input', { id: _id }]);
  }

  continue(){
    alert('In construction...')
  }
}
