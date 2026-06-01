-- =====================================================================
-- JMeter 쿠폰 동시성 테스트 전체 셋업 (DDL + 데이터 한 방에)
--
-- 실행 방법 (SQL Developer / DBeaver)
--   F5 또는 전체 선택 후 실행
--
-- 포함 내용
--   1) COUPON, USER_COUPON 테이블 + 시퀀스 생성 (이미 있으면 무시)
--   2) 6월 선착순 이벤트 쿠폰 1000장 (현재 진행 중)
--   3) JMeter 테스트 유저 2000명 (k6test0001 ~ k6test2000, 비밀번호: admin1234)
--
-- JMeter 실행
--   로컬:
--     jmeter -n -t jmeter/coupon_test.jmx -l jmeter/result.jtl -e -o jmeter/report/
--   운영:
--     jmeter -n -t jmeter/coupon_test.jmx -JBASE_HOST=운영서버주소 -JBASE_PORT=443 -JBASE_SCHEME=https -l jmeter/result.jtl -e -o jmeter/report/
--
-- 정리 쿼리 (재실행 전 필요 시)
--   DELETE FROM USER_COUPON;
--   DELETE FROM COUPON;
--   DELETE FROM MY_USER_PAGE WHERE USER_NO IN (SELECT USER_NO FROM USERS WHERE LOGIN_ID LIKE 'k6test%');
--   DELETE FROM USERS WHERE LOGIN_ID LIKE 'k6test%';
--   COMMIT;
-- =====================================================================


-- =====================================================================
-- STEP 1: 시퀀스 생성 (이미 있으면 무시)
-- =====================================================================
BEGIN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE COUPON_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE USER_COUPON_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/


-- =====================================================================
-- STEP 2: 테이블 생성 (이미 있으면 무시)
-- =====================================================================
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE COUPON (
            COUPON_ID       NUMBER          PRIMARY KEY,
            NAME            VARCHAR2(100)   NOT NULL,
            TOTAL_COUNT     NUMBER          NOT NULL,
            REMAINING_COUNT NUMBER          NOT NULL,
            START_DATE      DATE,
            END_DATE        DATE,
            CREATED_AT      DATE DEFAULT SYSDATE
        )
    ';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE USER_COUPON (
            USER_COUPON_ID  NUMBER  PRIMARY KEY,
            USER_ID         NUMBER  NOT NULL,
            COUPON_ID       NUMBER  NOT NULL,
            ISSUED_AT       DATE    DEFAULT SYSDATE,
            CONSTRAINT UK_USER_COUPON UNIQUE (USER_ID, COUPON_ID),
            CONSTRAINT FK_UC_USER    FOREIGN KEY (USER_ID)   REFERENCES USERS(USER_NO),
            CONSTRAINT FK_UC_COUPON  FOREIGN KEY (COUPON_ID) REFERENCES COUPON(COUPON_ID)
        )
    ';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/


-- =====================================================================
-- STEP 3: 1000장 이벤트 쿠폰 (현재 진행 중)
-- =====================================================================
INSERT INTO COUPON (COUPON_ID, NAME, TOTAL_COUNT, REMAINING_COUNT, START_DATE, END_DATE)
VALUES (
    COUPON_SEQ.NEXTVAL,
    '6월 선착순 이벤트 쿠폰',
    1000, 1000,
    SYSDATE,
    ADD_MONTHS(SYSDATE, 1)
);

COMMIT;


-- =====================================================================
-- STEP 4: JMeter 테스트 유저 2000명 (k6test0001 ~ k6test2000)
--         비밀번호: admin1234
-- =====================================================================
BEGIN
    FOR i IN 1..2000 LOOP
        BEGIN
            INSERT INTO USERS (USER_NO, LOGIN_ID, PASS_WD, NAME, EMAIL, ROLE, REG_DATE)
            VALUES (
                USERS_SEQ.NEXTVAL,
                'k6test' || LPAD(TO_CHAR(i), 4, '0'),
                '$2a$10$hp3l293QvOyZgyHG3aCqCOweOWwi.DAv0KurS9A148vbH2GYi2NKO',
                'JMeter테스터' || TO_CHAR(i),
                'k6test' || LPAD(TO_CHAR(i), 4, '0') || '@loadtest.com',
                'ROLE_USER',
                SYSDATE
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;  -- 이미 있으면 스킵
        END;
    END LOOP;
    COMMIT;
END;
/

INSERT INTO MY_USER_PAGE (USER_NO, PROFILE_IMG, INTRODUCE, TEMPERATURE)
SELECT USER_NO, 'default_profile.png', 'JMeter 부하테스트 전용 계정', 36.5
FROM   USERS
WHERE  LOGIN_ID LIKE 'k6test%'
AND    USER_NO NOT IN (SELECT USER_NO FROM MY_USER_PAGE);

COMMIT;


-- =====================================================================
-- 확인 쿼리
-- =====================================================================
SELECT COUPON_ID, NAME, TOTAL_COUNT, REMAINING_COUNT, START_DATE, END_DATE
FROM   COUPON
WHERE  NAME = '6월 선착순 이벤트 쿠폰';
-- REMAINING_COUNT = 1000 확인

SELECT COUNT(*) AS TOTAL_TEST_USERS
FROM   USERS
WHERE  LOGIN_ID LIKE 'k6test%';
-- 2000 확인
