/**
 * 채팅 DB vs Redis write-behind 성능 비교
 *
 * 실행 (RPS 조절):
 *   k6 run --out influxdb=http://서버IP:8086/k6 -e RPS=100 bench/k6_bench.js
 *   k6 run --out influxdb=http://서버IP:8086/k6 -e RPS=300 bench/k6_bench.js
 *   k6 run --out influxdb=http://서버IP:8086/k6 -e RPS=500 bench/k6_bench.js
 */

import http from 'k6/http';
import { sleep } from 'k6';

const HOST   = __ENV.HOST   || 'https://juyoungshop.duckdns.org';
const RPS    = parseInt(__ENV.RPS || '100');
const PARAMS = 'roomId=4&senderNo=15&receiverNo=16';

export const options = {
  scenarios: {
    db_scenario: {
      executor:          'constant-arrival-rate',
      rate:              RPS,
      timeUnit:          '1s',
      duration:          '60s',
      preAllocatedVUs:   Math.min(RPS * 2, 500),
      maxVUs:            Math.min(RPS * 4, 1000),
      exec:              'runDb',
    },
    redis_scenario: {
      executor:          'constant-arrival-rate',
      rate:              RPS,
      timeUnit:          '1s',
      duration:          '60s',
      preAllocatedVUs:   Math.min(RPS * 2, 500),
      maxVUs:            Math.min(RPS * 4, 1000),
      exec:              'runRedis',
    },
  },
  thresholds: {},
};

const params = { insecureSkipTLSVerify: true };

export function runDb() {
  http.post(`${HOST}/test/bench/chat/db?${PARAMS}`, null, {
    ...params,
    tags: { name: 'db' },
  });
}

export function runRedis() {
  http.post(`${HOST}/test/bench/chat/redis?${PARAMS}`, null, {
    ...params,
    tags: { name: 'redis' },
  });
}
