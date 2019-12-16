import { TestBed } from '@angular/core/testing';

import { GeneraldbService } from './generaldb.service';

describe('GeneraldbService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: GeneraldbService = TestBed.get(GeneraldbService);
    expect(service).toBeTruthy();
  });
});
