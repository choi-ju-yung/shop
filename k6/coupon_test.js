import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter } from 'k6/metrics';

// 커스텀 메트릭
const successCount = new Counter('coupon_issued_success');
const failCount    = new Counter('coupon_issued_fail');

export const options = {
  // 1000명이 동시에 요청
  vus: 1000,
  iterations: 1000,  // 총 1000번 요청 (1인당 1번)
};

// 테스트 전 쿠폰 생성 (1회만 실행)
export function setup() {
  const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

  const res = http.post(`${BASE_URL}/coupon/create`,
    JSON.stringify({
      name: 'k6 테스트 쿠폰',
      totalCount: 100,
    }),
    { headers: { 'Content-Type': 'application/json' } }
  );

  console.log(`쿠폰 생성 응답: ${res.status} ${res.body}`);
  return { baseUrl: BASE_URL, couponId: 1 };
}

export default function (data) {
  const userId = __VU; // 가상 유저 ID (1~1000)

  const res = http.post(
    `${data.baseUrl}/coupon/${data.couponId}/issue`,
    null,
    {
      headers: {
        'Content-Type': 'application/json',
        // 실제 운영 테스트 시 세션 쿠키 필요
        // 'Cookie': 'JSESSIONID=xxx',
      },
    }
  );

  const ok = check(res, {
    '발급 성공 또는 품절': (r) => r.status === 200 || r.status === 400,
  });

  if (res.status === 200) {
    successCount.add(1);
  } else {
    failCount.add(1);
  }
}

export function teardown(data) {
  console.log('===== 테스트 완료 =====');
  console.log('성공(발급): successCount 확인');
  console.log('실패(품절/중복): failCount 확인');
  console.log('성공 수가 정확히 100이면 동시성 제어 성공!');
}
