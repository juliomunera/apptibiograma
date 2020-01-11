import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRoute } from "@angular/router";

@Component({
  selector: 'app-gram',
  templateUrl: './gram.page.html',
  styleUrls: ['./gram.page.scss'],
})
export class GramPage implements OnInit {
  bodyName : String = '';

  constructor(private router: Router, private activatedRoute: ActivatedRoute,) { 
    this.bodyName = this.activatedRoute.snapshot.paramMap.get('bodyName');
  }

  ngOnInit() {
  }

  openGram(isGramPositive){

    this.router.navigate(['/bacterium', { gramType: isGramPositive, bodyName : this.bodyName }]);
    // this.router.navigateByUrl('/bacterium');
  }
}
