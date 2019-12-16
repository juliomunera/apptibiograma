import { TestBed } from '@angular/core/testing';

import { ImportdbService } from './importdb.service';

describe('ImportdbService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: ImportdbService = TestBed.get(ImportdbService);
    expect(service).toBeTruthy();
  });
});
