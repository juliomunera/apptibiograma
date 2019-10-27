import { CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { BodyPage } from './body.page';

describe('BodyPage', () => {
  let component: BodyPage;
  let fixture: ComponentFixture<BodyPage>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ BodyPage ],
      schemas: [CUSTOM_ELEMENTS_SCHEMA],
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(BodyPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
