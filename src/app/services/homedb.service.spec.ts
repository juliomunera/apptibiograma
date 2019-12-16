import { TestBed } from '@angular/core/testing';

import { HomeService } from './homedb.service';

describe('HomedbService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: HomeService = TestBed.get(HomeService);
    expect(service).toBeTruthy();
  });
});
