import { TestBed } from '@angular/core/testing';

import { AntibioticsService } from './antibiotics.service';

describe('AntibioticsService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: AntibioticsService = TestBed.get(AntibioticsService);
    expect(service).toBeTruthy();
  });
});
