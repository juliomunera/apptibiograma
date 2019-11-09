import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';

@Component({
  selector: 'app-input',
  templateUrl: './input.page.html',
  styleUrls: ['./input.page.scss'],
})
export class InputPage implements OnInit {

  textDescription : any = null;
  
  constructor(private activatedRoute: ActivatedRoute, private router: Router) { }

  ngOnInit() {
    this.textDescription = this.activatedRoute.snapshot.paramMap.get('id');
  }

  continue(){
    this.router.navigateByUrl('/bacterium');
  }

  comeBack(){
    this.router.navigateByUrl('/bacterium');
  }

}
