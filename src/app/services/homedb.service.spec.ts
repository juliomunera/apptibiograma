import { TestBed } from '@angular/core/testing';

import { HomedbService } from './homedb.service';

describe('HomedbService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: HomedbService = TestBed.get(HomedbService);
    expect(service).toBeTruthy();
  });
});
