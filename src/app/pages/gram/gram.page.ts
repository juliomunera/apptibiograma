import { Component, OnInit } from '@angular/core';
import { Router } from "@angular/router";

@Component({
  selector: 'app-gram',
  templateUrl: './gram.page.html',
  styleUrls: ['./gram.page.scss'],
})
export class GramPage implements OnInit {

  constructor(private router: Router) { }

  ngOnInit() {
  }

  openGram(isGramPositive){

    this.router.navigate(['/bacterium', { gramType: isGramPositive }]);
    // this.router.navigateByUrl('/bacterium');
  }
}
