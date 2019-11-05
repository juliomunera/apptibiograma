import { CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { GramPage } from './gram.page';

describe('GramPage', () => {
  let component: GramPage;
  let fixture: ComponentFixture<GramPage>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ GramPage ],
      schemas: [CUSTOM_ELEMENTS_SCHEMA],
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(GramPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
