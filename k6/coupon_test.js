/**
 * 쿠폰 동시성 부하테스트
 *
 * 목표 : 1000명이 동시에 100장짜리 쿠폰을 요청 → 정확히 100장만 발급되어야 함
 * 실행 : k6 run coupon_test.js
 *        BASE_URL / COUPON_SLOTS / TOTAL_VUS 환경변수로 재정의 가능
 *          k6 run -e COUPON_SLOTS=50 -e TOTAL_VUS=500 coupon_test.js
 *
 * 선행 조건 :
 *   1) 서버 기동 (Redis·Kafka·Oracle 포함)
 *   2) coupon_testdata.sql 실행 완료 (k6test0001~1000 계정 존재)
 *   3) admin 계정 존재 (loginId=admin / password=hifive1234)
 */

import http    from 'k6/http';
import { check } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';

// k6 v2.0.0에서 Secure 쿠키는 response.cookies에 포함되지 않으므로 헤더 직접 파싱
function extractJsessionid(res) {
    // 헤더 키가 대소문자 다를 수 있으므로 전체 탐색
    let raw = null;
    for (const key of Object.keys(res.headers)) {
        if (key.toLowerCase() === 'set-cookie') {
            raw = res.headers[key];
            break;
        }
    }
    if (!raw) return null;
    const cookies = Array.isArray(raw) ? raw : [raw];
    for (const c of cookies) {
        const m = c.match(/JSESSIONID=([^;]+)/);
        if (m) return m[1];
    }
    return null;
}

// ── 커스텀 메트릭 ────────────────────────────────────────────────────
const issued   = new Counter('coupon_issued');       // 발급 성공
const rejected = new Counter('coupon_rejected');     // 중복·품절 (정상 거부)
const errored  = new Counter('coupon_error');        // 401·500 등 비정상
const latency  = new Trend('coupon_issue_ms', true); // 발급 API 지연

// ── 파라미터 ─────────────────────────────────────────────────────────
const BASE_URL     = __ENV.BASE_URL     || 'http://localhost:8080';
const COUPON_SLOTS = parseInt(__ENV.COUPON_SLOTS || '100');
const TOTAL_VUS    = parseInt(__ENV.TOTAL_VUS    || '300');

// ── k6 옵션 ──────────────────────────────────────────────────────────
export const options = {
    scenarios: {
        coupon_rush: {
            executor:    'shared-iterations',
            vus:         TOTAL_VUS,
            iterations:  TOTAL_VUS,
            maxDuration: '30s',
        },
    },

    thresholds: {
        // 발급 건수는 쿠폰 수량을 절대 초과하면 안 됨 (동시성 검증 핵심)
        'coupon_issued':   [`count <= ${COUPON_SLOTS}`],
        // 인증 실패 0건 (테스트 데이터 정상 여부 확인)
        'coupon_error':    ['count == 0'],
        // HTTP 에러율 1% 미만
        'http_req_failed': ['rate < 0.01'],
    },
};

// ── setup : 쿠폰 1개 생성 (k6test0001 계정) ──────────────────────────
export function setup() {
    // 1) 로그인
    const loginRes = http.post(
        `${BASE_URL}/processLogin`,
        'loginId=k6test0001&password=hifive1234',
        {
            headers:   { 'Content-Type': 'application/x-www-form-urlencoded' },
            redirects: 0,
        }
    );

    console.log(`[setup] 로그인 응답 status=${loginRes.status}`);
    console.log(`[setup] Location=${loginRes.headers['Location']}`);
    console.log(`[setup] Set-Cookie=${loginRes.headers['Set-Cookie'] || loginRes.headers['set-cookie'] || 'NONE'}`);

    const loginOk = loginRes.status === 302 || loginRes.status === 200;
    if (!loginOk) {
        console.error(`[setup] 로그인 실패: HTTP ${loginRes.status}`);
        console.error(`        응답: ${loginRes.body}`);
        return null;
    }

    const jsessionid = extractJsessionid(loginRes);
    if (!jsessionid) {
        console.error('[setup] JSESSIONID를 가져올 수 없습니다.');
        return null;
    }
    console.log(`[setup] admin 로그인 성공 (${loginRes.status})`);

    // 2) 쿠폰 생성 (JSESSIONID 헤더에 직접 주입)
    const today     = new Date().toISOString().slice(0, 10);
    const nextMonth = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);

    const createRes = http.post(
        `${BASE_URL}/coupon/create`,
        JSON.stringify({
            name:       `[k6] 동시성 테스트 쿠폰 ${COUPON_SLOTS}장 - ${today}`,
            totalCount: COUPON_SLOTS,
            startDate:  today,
            endDate:    nextMonth,
        }),
        {
            headers: {
                'Content-Type': 'application/json',
                'Cookie': `JSESSIONID=${jsessionid}`,
            }
        }
    );

    if (createRes.status !== 200) {
        console.error(`[setup] 쿠폰 생성 실패: HTTP ${createRes.status}`);
        console.error(`        응답: ${createRes.body}`);
        return null;
    }

    const body     = JSON.parse(createRes.body);
    const couponId = body.couponId;

    if (!couponId) {
        console.error('[setup] couponId를 파싱할 수 없습니다. 응답: ' + createRes.body);
        return null;
    }

    console.log(`[setup] ✅ 쿠폰 생성 완료`);
    console.log(`        couponId = ${couponId}`);
    console.log(`        수량     = ${COUPON_SLOTS}장`);
    console.log(`        유효기간 = ${today} ~ ${nextMonth}`);
    console.log(`[setup] 🚀 ${TOTAL_VUS}명 동시 요청 시작`);

    return { baseUrl: BASE_URL, couponId: couponId };
}

// ── default : VU별 로그인 → 쿠폰 발급 요청 ──────────────────────────
export default function (data) {
    if (!data || !data.couponId) {
        console.error('setup 데이터 없음 - 테스트 스킵');
        return;
    }

    // __VU : 1 ~ TOTAL_VUS (k6test0001 ~ k6test1000)
    const loginId = `k6test${String(__VU).padStart(4, '0')}`;

    // ── 1) 로그인 ──────────────────────────────────────────────────
    const loginRes = http.post(
        `${data.baseUrl}/processLogin`,
        `loginId=${loginId}&password=hifive1234`,
        {
            headers:   { 'Content-Type': 'application/x-www-form-urlencoded' },
            redirects: 0,  // 302 에서 멈추고 JSESSIONID 쿠키 jar에 저장
        }
    );

    const loginOk = check(loginRes, {
        '로그인 성공': (r) => r.status === 302 || r.status === 200,
    });

    if (!loginOk) {
        console.warn(`[VU${__VU}][${loginId}] 로그인 실패: HTTP ${loginRes.status}`);
        errored.add(1);
        return;
    }

    const jsessionid = extractJsessionid(loginRes);
    if (!jsessionid) {
        console.warn(`[VU${__VU}][${loginId}] JSESSIONID 없음`);
        errored.add(1);
        return;
    }

    // ── 2) 쿠폰 발급 (JSESSIONID 헤더에 직접 주입) ───────────────
    const start    = Date.now();
    const issueRes = http.post(
        `${data.baseUrl}/coupon/${data.couponId}/issue`,
        null,
        {
            headers: {
                'Content-Type': 'application/json',
                'Cookie': `JSESSIONID=${jsessionid}`,
            }
        }
    );
    latency.add(Date.now() - start);

    check(issueRes, {
        '정상 응답 (200 or 400)': (r) => r.status === 200 || r.status === 400,
    });

    if (issueRes.status === 200) {
        issued.add(1);
    } else if (issueRes.status === 400) {
        rejected.add(1);   // 중복 발급 or 품절 → 정상 거부
    } else {
        console.warn(`[VU${__VU}][${loginId}] 예상치 못한 응답: HTTP ${issueRes.status}`);
        console.warn(`  body: ${issueRes.body}`);
        errored.add(1);
    }
}

// ── teardown : 결과 요약 출력 ─────────────────────────────────────────
export function teardown(data) {
    if (!data) {
        console.error('[teardown] setup 실패로 테스트가 정상 실행되지 않았습니다.');
        return;
    }

    console.log('\n');
    console.log('╔══════════════════════════════════════════════╗');
    console.log('║          쿠폰 동시성 테스트 결과 요약          ║');
    console.log('╠══════════════════════════════════════════════╣');
    console.log(`║  쿠폰 ID   : ${String(data.couponId).padEnd(31)}║`);
    console.log(`║  쿠폰 수량 : ${String(COUPON_SLOTS + '장').padEnd(31)}║`);
    console.log(`║  동시 요청 : ${String(TOTAL_VUS + '명').padEnd(31)}║`);
    console.log('╠══════════════════════════════════════════════╣');
    console.log('║  k6 Summary에서 확인:                         ║');
    console.log(`║  coupon_issued   ← 정확히 ${String(COUPON_SLOTS + '이면').padEnd(16)}OK ║`);
    console.log(`║  coupon_rejected ← 나머지 ${String((TOTAL_VUS - COUPON_SLOTS) + '이면').padEnd(15)}OK ║`);
    console.log('║  coupon_error    ← 0 이면 인증 정상           ║');
    console.log('╚══════════════════════════════════════════════╝');
}
