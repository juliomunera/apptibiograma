import { CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { BacteriumPage } from './bacterium.page';

describe('BacteriumPage', () => {
  let component: BacteriumPage;
  let fixture: ComponentFixture<BacteriumPage>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ BacteriumPage ],
      schemas: [CUSTOM_ELEMENTS_SCHEMA],
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(BacteriumPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
