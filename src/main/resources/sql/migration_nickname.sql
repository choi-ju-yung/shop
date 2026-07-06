-- =============================================================
-- NAME 컬럼 제거 마이그레이션
-- 기존 DB에 직접 실행하세요
-- =============================================================

-- 1. USERS 테이블 NAME 컬럼 삭제
ALTER TABLE USERS DROP COLUMN NAME;

-- 2. WITHDRAWN_USERS 테이블 NAME 컬럼 삭제
ALTER TABLE WITHDRAWN_USERS DROP COLUMN NAME;

COMMIT;
