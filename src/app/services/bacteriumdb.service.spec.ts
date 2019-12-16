import { TestBed } from '@angular/core/testing';

import { BacteriumdbService } from './bacteriumdb.service';

describe('BacteriumdbService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: BacteriumdbService = TestBed.get(BacteriumdbService);
    expect(service).toBeTruthy();
  });
});
