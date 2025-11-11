import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'Hallo Project SSO udh aktif cui, bisa ke /api/docs untuk liat dokumentasi API';
  }
}
