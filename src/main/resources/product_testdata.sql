-- =============================================================
-- 상품 테스트 데이터 INSERT 스크립트
-- 실행 전제: USERS_TB에 USER_NO 21~32 존재
-- 실행 순서: SQL Developer 또는 Oracle 클라이언트에서 직접 실행
-- =============================================================

-- 1. 기존 상품 데이터 초기화
DELETE FROM PRODUCT_FILE;
DELETE FROM PRODUCT;

-- 2. 시퀀스 리셋
DROP SEQUENCE PRODUCT_ID_SEQ;
CREATE SEQUENCE PRODUCT_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

DROP SEQUENCE PRODUCT_FILE_SEQ;
CREATE SEQUENCE PRODUCT_FILE_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;


-- =============================================================
-- 3. 상품 30건 (USER_NO 21~32 순환 배분)
-- =============================================================

-- ── PC/모바일 ──
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 21, '아이폰 15 Pro 256GB 블랙 미개봉',           '스마트폰', '서울 강남구',   '신상',     1350000, '아이폰 15 Pro 256GB 블랙 미개봉 제품입니다. 선물용으로 구매했으나 기기변경으로 판매합니다. 박스 실링 그대로입니다.',                     '아이폰,iPhone,애플,Apple,스마트폰,미개봉');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 22, '갤럭시 S24 울트라 256GB 티타늄블랙',        '스마트폰', '서울 송파구',   '신상',     1280000, '갤럭시 S24 울트라 256GB 티타늄블랙 미개봉 새상품입니다. 구매 후 개통하지 않았습니다. 구성품 모두 포함.',                                  '갤럭시,삼성,S24,울트라,스마트폰,미개봉');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 23, '맥북 에어 M2 2023 스페이스그레이 256GB',    '노트북',   '서울 서초구',   '거의새것',   1150000, '맥북 에어 M2 2023년형입니다. 구입 후 3개월 사용했으며 외관 흠집 없습니다. 충전기 포함. 영수증 있습니다.',                                 '맥북,MacBook,애플,노트북,M2');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 24, 'LG 그램 16 2023 i7 16GB 512GB',             '노트북',   '경기 수원시',   '거의새것',   1050000, 'LG 그램 16 2023년형 인텔 i7 16GB RAM 512GB SSD입니다. 6개월 사용. 배터리 90% 이상 유지. 케이스 포함.',                                    'LG그램,노트북,그램16,울트라북');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 25, '아이패드 Pro 12.9 M2 256GB Wi-Fi',          '태블릿',   '서울 종로구',   '거의새것',    980000, '아이패드 프로 12.9인치 M2 칩 256GB입니다. 구입 후 2개월 사용. 케이스 포함 판매합니다.',                                                   '아이패드,iPad,애플,태블릿,M2');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 26, '갤럭시 탭 S9 FE 256GB 실버 Wi-Fi',         '태블릿',   '광주 북구',     '신상',      520000, '갤럭시 탭 S9 FE 256GB 실버 Wi-Fi 미개봉 새상품입니다. 구매 후 쓸 일이 없어 바로 판매합니다.',                                               '갤럭시탭,삼성,태블릿,S9FE,미개봉');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 27, '애플워치 Series 9 45mm GPS 미드나이트',     '스마트폰', '부산 수영구',   '신상',      430000, '애플워치 시리즈 9 45mm GPS 미드나이트 미개봉입니다. 선물용으로 구매했으나 사용 안 합니다.',                                                 '애플워치,AppleWatch,스마트워치,애플');

-- ── 가전제품 ──
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 28, '삼성 QLED TV 65인치 2022년형',              'TV/영상',  '부산 해운대구', '중고', 620000, '삼성 QLED 65인치 TV입니다. 2022년 구매 후 이사로 판매합니다. 작동 이상 없으며 리모컨 포함입니다.',                                          '삼성,TV,QLED,65인치,텔레비전');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 29, '소니 WH-1000XM5 노이즈캔슬링 헤드폰 블랙', 'TV/영상',  '서울 강서구',   '거의새것',    280000, '소니 WH-1000XM5 블루투스 헤드폰입니다. 4개월 사용하고 판매합니다. 파우치 및 케이블 포함.',                                                 '소니,헤드폰,노이즈캔슬링,WH1000XM5,블루투스');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 30, '다이슨 V15 Detect 무선청소기',              '청소용품', '인천 남동구',   '거의새것',    480000, '다이슨 V15 Detect 무선청소기입니다. 구입 2개월 된 제품이며 흡입력 정상입니다. 부속품 모두 포함.',                                            '다이슨,청소기,무선청소기,Dyson,V15');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 31, '삼성 비스포크 냉장고 4도어 800L 코타차콜', '냉장고',   '경기 성남시',   '중고', 1100000,'삼성 비스포크 냉장고 4도어 800L 코타차콜입니다. 2021년 구매 후 이사로 판매합니다. 작동 이상 없음.',                                           '삼성,비스포크,냉장고,4도어');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 32, 'LG 트롬 세탁기 21kg 화이트',               '세탁기',   '인천 미추홀구', '중고', 420000, 'LG 트롬 세탁기 21kg입니다. 2022년 구매 후 사용 중이었으나 이사로 판매합니다. 정상 작동 확인.',                                              'LG,세탁기,트롬,드럼세탁기');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 21, '다이킨 에어컨 18평형 인버터 스탠드',       '에어컨',   '서울 노원구',   '중고', 680000, '다이킨 인버터 스탠드 에어컨 18평형입니다. 2020년 구매. 매년 청소 완료. 직거래만 가능합니다.',                                               '다이킨,에어컨,스탠드에어컨,인버터');

-- ── 패션의류/잡화 ──
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 22, '나이키 에어포스1 화이트 270mm',             '신발',     '경기 성남시',   '거의새것',     75000, '나이키 에어포스1 로우 화이트 270mm입니다. 총 2회 착용 후 보관 중입니다. 박스 포함 판매합니다.',                                               '나이키,Nike,에어포스,운동화,스니커즈');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 23, '아디다스 삼바 OG 260mm 화이트블랙',         '신발',     '서울 영등포구', '거의새것',     88000, '아디다스 삼바 OG 화이트블랙 260mm입니다. 3회 착용 후 보관 중입니다. 박스 있습니다.',                                                       '아디다스,삼바,Samba,스니커즈,신발');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 24, '뉴발란스 992 그레이 275mm',                 '신발',     '경기 고양시',   '중고',  65000, '뉴발란스 992 그레이 275mm 판매합니다. 자주 착용했으나 상태 양호합니다. 박스 없음.',                                                         '뉴발란스,NewBalance,992,운동화');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 25, '나이키 테크 플리스 집업 후디 M 블랙',       '남성의류', '대전 서구',     '거의새것',     95000, '나이키 테크 플리스 집업 후디 M사이즈 블랙입니다. 작년 겨울 구입 후 2회 착용했습니다.',                                                      '나이키,테크플리스,후디,집업,남성의류');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 26, '나이키 바람막이 집업 재킷 M사이즈',         '남성의류', '대구 중구',     '거의새것',     42000, '나이키 바람막이 집업 재킷 M사이즈입니다. 작년에 구매 후 2회 착용했습니다. 세탁 완료 후 판매합니다.',                                           '나이키,바람막이,재킷,남성의류,아우터');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 27, '구찌 GG 숄더백 미니 오피디아',              '가방',     '서울 강남구',   '중고', 650000, '구찌 오피디아 GG 미니 숄더백입니다. 1년 정도 사용하였으며 정품입니다. 보증카드 및 더스트백 포함.',                                             '구찌,Gucci,가방,숄더백,명품');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 28, '롤렉스 서브마리너 데이트 블랙다이얼',       '시계/주얼리','서울 서초구', '중고', 12500000,'롤렉스 서브마리너 데이트 블랙다이얼 2019년형입니다. 풀박스 풀페이퍼 있습니다. 정품 보증.',                                                  '롤렉스,Rolex,서브마리너,시계,명품시계');

-- ── 가구/인테리어 ──
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 29, '이케아 KALLAX 책장 4x4 화이트',             '수납/정리', '서울 마포구',  '중고',  55000, '이케아 KALLAX 4x4 칸 책장 화이트입니다. 이사 정리로 판매합니다. 분해 가능하며 직접 가져가실 분만 구매 가능합니다.',                          '이케아,KALLAX,책장,수납,인테리어');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 30, '한샘 소파 3인용 패브릭 그레이',             '소파/침대', '서울 강동구',  '중고', 180000, '한샘 3인용 패브릭 소파 그레이입니다. 이사로 판매합니다. 직접 가져가실 분만 구매 가능합니다.',                                               '소파,한샘,3인용소파,패브릭소파');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 31, '시디즈 T50 에어 의자 블랙 메쉬',            '책상/의자', '경기 화성시',  '거의새것',    320000, '시디즈 T50 에어 의자 블랙 메쉬입니다. 1년 이내 구매. 재택근무 종료로 판매합니다. 상태 매우 좋음.',                                           '시디즈,T50,의자,사무용의자,메쉬의자');

-- ── 스포츠/레저 ──
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 32, '요넥스 나노플렉스 700 배드민턴 라켓',       '헬스/요가', '서울 마포구',  '거의새것',     85000, '요넥스 나노플렉스 700 배드민턴 라켓입니다. 5회 미만 사용. 가방과 함께 판매합니다.',                                                         '배드민턴,요넥스,라켓,스포츠');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 21, '트렉 마린 5 로드바이크 2022 52사이즈',      '자전거',   '경기 과천시',   '중고', 780000, '트렉 마린 5 로드바이크 2022년형 52사이즈입니다. 1년 사용. 기어 변속 정상. 타이어 교체 완료.',                                                '자전거,로드바이크,트렉,Trek,사이클');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 22, '캠핑 체어 헬리녹스 스타일 경량 의자',       '캠핑',     '경기 용인시',   '거의새것',     28000, '경량 폴딩 캠핑 체어입니다. 헬리녹스와 유사한 스타일이며 무게 900g입니다. 2회 사용 후 보관 중입니다.',                                          '캠핑의자,경량의자,캠핑,폴딩체어,아웃도어');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 23, '코베아 쉘터 텐트 4인용 감성캠핑',           '캠핑',     '경기 양평군',   '거의새것',     95000, '코베아 쉘터 텐트 4인용입니다. 2회 사용 후 보관 중입니다. 팩, 로프 모두 포함. 세탁 완료.',                                                   '텐트,캠핑,코베아,쉘터,4인용텐트');

-- ── 도서/음반 ──
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 24, '해리포터 전집 양장본 1~7권 세트',           '도서',     '대전 유성구',   '중고',  35000, '해리포터 전집 1권부터 7권까지 완전 세트입니다. 전체적으로 깨끗하며 일부 모서리 살짝 눌린 자국 있습니다.',                                     '해리포터,전집,소설,도서,책');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 25, '2025 SQLD 자격증 교재 + 기출문제집 세트',   '도서',     '서울 관악구',   '중고',  18000, 'SQLD 자격증 교재와 기출문제집 세트입니다. 필기 후 합격하여 판매합니다. 깔끔하게 사용했습니다.',                                               'SQLD,자격증,교재,도서,IT자격증');
INSERT INTO PRODUCT VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 26, '방탄소년단 BTS Proof Standard Edition',      'CD/DVD',   '광주 광산구',   '신상',       22000, 'BTS Proof Standard Edition 미개봉 앨범입니다. 구매 후 미개봉 보관 중이던 제품입니다.',                                                       'BTS,방탄소년단,Proof,앨범,CD');


-- =============================================================
-- 4. 상품 이미지 (PRODUCT_FILE) - 상품당 2~3장
--    실제 파일 없음 → onerror 시 기본 로고 표시
-- =============================================================

-- 상품 1 (아이폰 15 Pro)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '1',  'iphone15_front.jpg',   'uuid-01-a.jpg', '/upload/productRegist/uuid-01-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '1',  'iphone15_back.jpg',    'uuid-01-b.jpg', '/upload/productRegist/uuid-01-b.jpg', 0);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '1',  'iphone15_box.jpg',     'uuid-01-c.jpg', '/upload/productRegist/uuid-01-c.jpg', 0);

-- 상품 2 (갤럭시 S24 울트라)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '2',  'galaxy_s24_front.jpg', 'uuid-02-a.jpg', '/upload/productRegist/uuid-02-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '2',  'galaxy_s24_back.jpg',  'uuid-02-b.jpg', '/upload/productRegist/uuid-02-b.jpg', 0);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '2',  'galaxy_s24_box.jpg',   'uuid-02-c.jpg', '/upload/productRegist/uuid-02-c.jpg', 0);

-- 상품 3 (맥북 에어 M2)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '3',  'macbook_top.jpg',      'uuid-03-a.jpg', '/upload/productRegist/uuid-03-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '3',  'macbook_open.jpg',     'uuid-03-b.jpg', '/upload/productRegist/uuid-03-b.jpg', 0);

-- 상품 4 (LG 그램 16)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '4',  'gram_main.jpg',        'uuid-04-a.jpg', '/upload/productRegist/uuid-04-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '4',  'gram_side.jpg',        'uuid-04-b.jpg', '/upload/productRegist/uuid-04-b.jpg', 0);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '4',  'gram_port.jpg',        'uuid-04-c.jpg', '/upload/productRegist/uuid-04-c.jpg', 0);

-- 상품 5 (아이패드 Pro)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '5',  'ipad_main.jpg',        'uuid-05-a.jpg', '/upload/productRegist/uuid-05-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '5',  'ipad_side.jpg',        'uuid-05-b.jpg', '/upload/productRegist/uuid-05-b.jpg', 0);

-- 상품 6 (갤럭시 탭 S9 FE)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '6',  'tab_s9_main.jpg',      'uuid-06-a.jpg', '/upload/productRegist/uuid-06-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '6',  'tab_s9_box.jpg',       'uuid-06-b.jpg', '/upload/productRegist/uuid-06-b.jpg', 0);

-- 상품 7 (애플워치 S9)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '7',  'watch_front.jpg',      'uuid-07-a.jpg', '/upload/productRegist/uuid-07-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '7',  'watch_band.jpg',       'uuid-07-b.jpg', '/upload/productRegist/uuid-07-b.jpg', 0);

-- 상품 8 (삼성 QLED TV)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '8',  'tv_front.jpg',         'uuid-08-a.jpg', '/upload/productRegist/uuid-08-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '8',  'tv_side.jpg',          'uuid-08-b.jpg', '/upload/productRegist/uuid-08-b.jpg', 0);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '8',  'tv_remote.jpg',        'uuid-08-c.jpg', '/upload/productRegist/uuid-08-c.jpg', 0);

-- 상품 9 (소니 헤드폰)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '9',  'sony_main.jpg',        'uuid-09-a.jpg', '/upload/productRegist/uuid-09-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '9',  'sony_case.jpg',        'uuid-09-b.jpg', '/upload/productRegist/uuid-09-b.jpg', 0);

-- 상품 10 (다이슨 V15)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '10', 'dyson_main.jpg',       'uuid-10-a.jpg', '/upload/productRegist/uuid-10-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '10', 'dyson_parts.jpg',      'uuid-10-b.jpg', '/upload/productRegist/uuid-10-b.jpg', 0);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '10', 'dyson_filter.jpg',     'uuid-10-c.jpg', '/upload/productRegist/uuid-10-c.jpg', 0);

-- 상품 11 (삼성 비스포크 냉장고)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '11', 'fridge_main.jpg',      'uuid-11-a.jpg', '/upload/productRegist/uuid-11-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '11', 'fridge_open.jpg',      'uuid-11-b.jpg', '/upload/productRegist/uuid-11-b.jpg', 0);

-- 상품 12 (LG 트롬 세탁기)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '12', 'washer_main.jpg',      'uuid-12-a.jpg', '/upload/productRegist/uuid-12-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '12', 'washer_inside.jpg',    'uuid-12-b.jpg', '/upload/productRegist/uuid-12-b.jpg', 0);

-- 상품 13 (다이킨 에어컨)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '13', 'aircon_main.jpg',      'uuid-13-a.jpg', '/upload/productRegist/uuid-13-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '13', 'aircon_remote.jpg',    'uuid-13-b.jpg', '/upload/productRegist/uuid-13-b.jpg', 0);

-- 상품 14 (나이키 에어포스1)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '14', 'af1_main.jpg',         'uuid-14-a.jpg', '/upload/productRegist/uuid-14-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '14', 'af1_side.jpg',         'uuid-14-b.jpg', '/upload/productRegist/uuid-14-b.jpg', 0);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '14', 'af1_box.jpg',          'uuid-14-c.jpg', '/upload/productRegist/uuid-14-c.jpg', 0);

-- 상품 15 (아디다스 삼바)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '15', 'samba_main.jpg',       'uuid-15-a.jpg', '/upload/productRegist/uuid-15-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '15', 'samba_side.jpg',       'uuid-15-b.jpg', '/upload/productRegist/uuid-15-b.jpg', 0);

-- 상품 16 (뉴발란스 992)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '16', 'nb992_main.jpg',       'uuid-16-a.jpg', '/upload/productRegist/uuid-16-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '16', 'nb992_top.jpg',        'uuid-16-b.jpg', '/upload/productRegist/uuid-16-b.jpg', 0);

-- 상품 17 (나이키 테크 플리스)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '17', 'techfleece_front.jpg', 'uuid-17-a.jpg', '/upload/productRegist/uuid-17-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '17', 'techfleece_back.jpg',  'uuid-17-b.jpg', '/upload/productRegist/uuid-17-b.jpg', 0);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '17', 'techfleece_tag.jpg',   'uuid-17-c.jpg', '/upload/productRegist/uuid-17-c.jpg', 0);

-- 상품 18 (나이키 바람막이)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '18', 'jacket_front.jpg',     'uuid-18-a.jpg', '/upload/productRegist/uuid-18-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '18', 'jacket_back.jpg',      'uuid-18-b.jpg', '/upload/productRegist/uuid-18-b.jpg', 0);

-- 상품 19 (구찌 가방)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '19', 'gucci_main.jpg',       'uuid-19-a.jpg', '/upload/productRegist/uuid-19-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '19', 'gucci_inside.jpg',     'uuid-19-b.jpg', '/upload/productRegist/uuid-19-b.jpg', 0);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '19', 'gucci_dust.jpg',       'uuid-19-c.jpg', '/upload/productRegist/uuid-19-c.jpg', 0);

-- 상품 20 (롤렉스)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '20', 'rolex_main.jpg',       'uuid-20-a.jpg', '/upload/productRegist/uuid-20-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '20', 'rolex_dial.jpg',       'uuid-20-b.jpg', '/upload/productRegist/uuid-20-b.jpg', 0);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '20', 'rolex_box.jpg',        'uuid-20-c.jpg', '/upload/productRegist/uuid-20-c.jpg', 0);

-- 상품 21 (이케아 KALLAX)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '21', 'kallax_main.jpg',      'uuid-21-a.jpg', '/upload/productRegist/uuid-21-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '21', 'kallax_detail.jpg',    'uuid-21-b.jpg', '/upload/productRegist/uuid-21-b.jpg', 0);

-- 상품 22 (한샘 소파)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '22', 'sofa_main.jpg',        'uuid-22-a.jpg', '/upload/productRegist/uuid-22-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '22', 'sofa_angle.jpg',       'uuid-22-b.jpg', '/upload/productRegist/uuid-22-b.jpg', 0);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '22', 'sofa_fabric.jpg',      'uuid-22-c.jpg', '/upload/productRegist/uuid-22-c.jpg', 0);

-- 상품 23 (시디즈 의자)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '23', 'sidiz_main.jpg',       'uuid-23-a.jpg', '/upload/productRegist/uuid-23-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '23', 'sidiz_side.jpg',       'uuid-23-b.jpg', '/upload/productRegist/uuid-23-b.jpg', 0);

-- 상품 24 (요넥스 라켓)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '24', 'racket_main.jpg',      'uuid-24-a.jpg', '/upload/productRegist/uuid-24-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '24', 'racket_bag.jpg',       'uuid-24-b.jpg', '/upload/productRegist/uuid-24-b.jpg', 0);

-- 상품 25 (트렉 로드바이크)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '25', 'bike_main.jpg',        'uuid-25-a.jpg', '/upload/productRegist/uuid-25-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '25', 'bike_gear.jpg',        'uuid-25-b.jpg', '/upload/productRegist/uuid-25-b.jpg', 0);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '25', 'bike_wheel.jpg',       'uuid-25-c.jpg', '/upload/productRegist/uuid-25-c.jpg', 0);

-- 상품 26 (캠핑 체어)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '26', 'chair_main.jpg',       'uuid-26-a.jpg', '/upload/productRegist/uuid-26-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '26', 'chair_fold.jpg',       'uuid-26-b.jpg', '/upload/productRegist/uuid-26-b.jpg', 0);

-- 상품 27 (코베아 텐트)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '27', 'tent_main.jpg',        'uuid-27-a.jpg', '/upload/productRegist/uuid-27-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '27', 'tent_inside.jpg',      'uuid-27-b.jpg', '/upload/productRegist/uuid-27-b.jpg', 0);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '27', 'tent_pack.jpg',        'uuid-27-c.jpg', '/upload/productRegist/uuid-27-c.jpg', 0);

-- 상품 28 (해리포터 전집)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '28', 'hp_books_main.jpg',    'uuid-28-a.jpg', '/upload/productRegist/uuid-28-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '28', 'hp_books_spine.jpg',   'uuid-28-b.jpg', '/upload/productRegist/uuid-28-b.jpg', 0);

-- 상품 29 (SQLD 교재)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '29', 'sqld_main.jpg',        'uuid-29-a.jpg', '/upload/productRegist/uuid-29-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '29', 'sqld_inside.jpg',      'uuid-29-b.jpg', '/upload/productRegist/uuid-29-b.jpg', 0);

-- 상품 30 (BTS 앨범)
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '30', 'bts_proof_main.jpg',   'uuid-30-a.jpg', '/upload/productRegist/uuid-30-a.jpg', 1);
INSERT INTO PRODUCT_FILE VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '30', 'bts_proof_cd.jpg',     'uuid-30-b.jpg', '/upload/productRegist/uuid-30-b.jpg', 0);


-- =============================================================
-- 5. 시퀀스를 현재 최대값 이후로 설정 (앱 신규 등록 시 충돌 방지)
--    PRODUCT_ID '30' 다음 → 31부터 시작
--    PRODUCT_FILE 71건 다음 → 72부터 시작
-- =============================================================
DROP SEQUENCE PRODUCT_ID_SEQ;
CREATE SEQUENCE PRODUCT_ID_SEQ START WITH 31 INCREMENT BY 1 NOCACHE NOCYCLE;

DROP SEQUENCE PRODUCT_FILE_SEQ;
CREATE SEQUENCE PRODUCT_FILE_SEQ START WITH 72 INCREMENT BY 1 NOCACHE NOCYCLE;


COMMIT;
