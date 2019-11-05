import { CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { InfectionPage } from './infection.page';

describe('InfectionPage', () => {
  let component: InfectionPage;
  let fixture: ComponentFixture<InfectionPage>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ InfectionPage ],
      schemas: [CUSTOM_ELEMENTS_SCHEMA],
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(InfectionPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
