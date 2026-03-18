-- =============================================================
-- HiFive 중고거래 플랫폼  Oracle DDL  (소스코드 전체 분석 기반)
-- 포함 항목: 시퀀스 / 테이블 / 인덱스 / 제약조건 / 샘플데이터
-- 실행 순서: ① 시퀀스 → ② 테이블 → ③ 인덱스 → ④ 샘플데이터
-- =============================================================



-- =============================================================
-- 1. 기존 객체 정리 (재실행 시 오류 방지 - 필요 시 사용)
-- =============================================================
/*
DROP TABLE EMAIL_AUTH        CASCADE CONSTRAINTS PURGE;
DROP TABLE NOTIFICATION      CASCADE CONSTRAINTS PURGE;
DROP TABLE CHAT_MESSAGE      CASCADE CONSTRAINTS PURGE;
DROP TABLE CHAT_ROOM         CASCADE CONSTRAINTS PURGE;
DROP TABLE PRODUCT_FILE      CASCADE CONSTRAINTS PURGE;
DROP TABLE PRODUCT           CASCADE CONSTRAINTS PURGE;
DROP TABLE SUBCATEGORY       CASCADE CONSTRAINTS PURGE;
DROP TABLE CATEGORY          CASCADE CONSTRAINTS PURGE;
DROP TABLE BOARD             CASCADE CONSTRAINTS PURGE;
DROP TABLE MY_USER_PAGE_TB   CASCADE CONSTRAINTS PURGE;
DROP TABLE USERS_TB          CASCADE CONSTRAINTS PURGE;

DROP SEQUENCE USERS_SEQ;
DROP SEQUENCE PRODUCT_ID_SEQ;
DROP SEQUENCE PRODUCT_FILE_SEQ;
DROP SEQUENCE SEQ_CHAT_ROOM;
DROP SEQUENCE CHAT_MESSAGE_SEQ;
DROP SEQUENCE NOTI_SEQ;
DROP SEQUENCE BOARD_SEQ;
DROP SEQUENCE CATEGORY_SEQ;
DROP SEQUENCE SUBCATEGORY_SEQ;
*/



-- =============================================================
-- 2. 시퀀스 생성
-- =============================================================

CREATE SEQUENCE USERS_SEQ
    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
-- 출처: RegistUserMapper.xml → INSERT INTO USERS_TB (USER_NO = USERS_SEQ.NEXTVAL)
--       UserMapper.xml       → registKakaoUser

CREATE SEQUENCE PRODUCT_ID_SEQ
    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
-- 출처: ProductRegistMapper.xml → insertProduct (keyProperty="productId", resultType="string")
--       ※ 시퀀스 숫자를 문자열로 변환하여 PRODUCT.PRODUCT_ID(VARCHAR2)에 저장

CREATE SEQUENCE PRODUCT_FILE_SEQ
    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
-- 출처: ProductRegistMapper.xml → insertProductFile (keyProperty="fileId")

CREATE SEQUENCE SEQ_CHAT_ROOM
    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
-- 출처: ChatMapper.xml → createRoom (ROOM_ID = SEQ_CHAT_ROOM.NEXTVAL)

CREATE SEQUENCE CHAT_MESSAGE_SEQ
    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
-- 출처: ChatMapper.xml → insertChatMessage (CHAT_MESSAGE_SEQ.NEXTVAL)

CREATE SEQUENCE NOTI_SEQ
    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
-- 출처: NotificationMapper.xml → 'NOTI' || LPAD(noti_seq.NEXTVAL, 5, '0')

CREATE SEQUENCE BOARD_SEQ
    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
-- 출처: CustomCenter.xml → getPagedBoardList / BOARD_SEQ.NEXTVAL

CREATE SEQUENCE CATEGORY_SEQ
    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
-- 출처: ProductRegistMapper.xml → 카테고리 기초데이터 INSERT

CREATE SEQUENCE SUBCATEGORY_SEQ
    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
-- 출처: ProductRegistMapper.xml → 서브카테고리 기초데이터 INSERT



-- =============================================================
-- 3. 테이블 생성
-- =============================================================

-- -----------------------------------
-- 3-1. 회원 테이블
-- 출처: UserMapper.xml, RegistUserMapper.xml, UserVO.java
-- -----------------------------------
CREATE TABLE USERS_TB (
    USER_NO        NUMBER          NOT NULL,
    LOGIN_ID       VARCHAR2(50),                           -- 일반 로그인 아이디 (소셜은 NULL)
    PASS_WD        VARCHAR2(200),                          -- BCrypt 암호화 비밀번호
    NAME           VARCHAR2(50)    NOT NULL,
    EMAIL          VARCHAR2(100),
    ROLE           VARCHAR2(20)    DEFAULT 'ROLE_USER',    -- ROLE_USER / ROLE_ADMIN
    OAUTH_PROVIDER VARCHAR2(20),                           -- kakao / null
    OAUTH_ID       VARCHAR2(100),                          -- 카카오 고유 ID
    REG_DATE       DATE            DEFAULT SYSDATE,
    CONSTRAINT PK_USERS PRIMARY KEY (USER_NO)
);
-- UserMapper.xml 쿼리 확인:
--   findByKakaoId   : WHERE OAUTH_ID = #{kakaoId} AND OAUTH_PROVIDER = 'kakao'
--   findByUserId    : WHERE LOGIN_ID = #{loginId}
--   findByUserNo    : WHERE USER_NO = #{userNo}
--   registKakaoUser : INSERT(USER_NO,NAME,EMAIL,PASS_WD,ROLE,OAUTH_PROVIDER,OAUTH_ID)
--   duplicateId     : WHERE LOGIN_ID=#{loginId} AND OAUTH_PROVIDER IS NULL AND OAUTH_ID IS NULL
--   findPwdById     : SELECT PASS_WD FROM USERS_TB WHERE LOGIN_ID = #{loginId}


-- -----------------------------------
-- 3-2. 마이페이지 테이블
-- 출처: MyPageMapper.xml, RegistUserMapper.xml, MyPage.java
-- -----------------------------------
CREATE TABLE MY_USER_PAGE_TB (
    USER_NO     NUMBER          NOT NULL,
    PROFILE_IMG VARCHAR2(200)   DEFAULT 'default_profile.png',
    INTRODUCE   VARCHAR2(500)   DEFAULT '안녕하세요!',
    TEMPERATURE NUMBER(4, 1)    DEFAULT 36.5,
    CONSTRAINT PK_MYPAGE      PRIMARY KEY (USER_NO),
    CONSTRAINT FK_MYPAGE_USER FOREIGN KEY (USER_NO) REFERENCES USERS_TB(USER_NO) ON DELETE CASCADE
);
-- RegistUserMapper.xml nomalInsertUserPage: INSERT(USER_NO,PROFILE_IMG,INTRODUCE,TEMPERATURE) VALUES(#{userNo},DEFAULT,DEFAULT,DEFAULT)
-- MyPageMapper.xml findByMyPage: SELECT * FROM MY_USER_PAGE_TB WHERE USER_NO = #{userNo}


-- -----------------------------------
-- 3-3. 카테고리 테이블
-- 출처: ProductRegistMapper.xml, Category.java, SubCategory.java
-- -----------------------------------
CREATE TABLE CATEGORY (
    CATEGORY_ID   NUMBER        NOT NULL,
    CATEGORY_NAME VARCHAR2(50)  NOT NULL,
    CONSTRAINT PK_CATEGORY PRIMARY KEY (CATEGORY_ID)
);
-- ProductRegistMapper.xml selectAll: SELECT CATEGORY_NAME FROM CATEGORY
-- ProductRegistMapper.xml selectAllCategories: SELECT C.CATEGORY_NAME, S.SUB_CATEGORY_NAME FROM CATEGORY C LEFT JOIN SUBCATEGORY S

CREATE TABLE SUBCATEGORY (
    SUB_CATEGORY_ID    NUMBER        NOT NULL,
    SUB_CATEGORY_NAME  VARCHAR2(50)  NOT NULL,
    PARENT_CATEGORY_ID NUMBER        NOT NULL,
    CONSTRAINT PK_SUBCATEGORY           PRIMARY KEY (SUB_CATEGORY_ID),
    CONSTRAINT FK_SUBCATEGORY_CATEGORY  FOREIGN KEY (PARENT_CATEGORY_ID) REFERENCES CATEGORY(CATEGORY_ID)
);
-- ProductRegistMapper.xml selectSubCate: SELECT S.SUB_CATEGORY_NAME FROM SUBCATEGORY S JOIN CATEGORY C ON S.PARENT_CATEGORY_ID = C.CATEGORY_ID WHERE C.CATEGORY_NAME = #{categoryName}


-- -----------------------------------
-- 3-4. 상품 테이블
-- 출처: ProductRegistMapper.xml, Product.java
-- -----------------------------------
CREATE TABLE PRODUCT (
    PRODUCT_ID          VARCHAR2(20)    NOT NULL,    -- PRODUCT_ID_SEQ.NEXTVAL 를 문자열로 저장
    USER_NO             NUMBER          NOT NULL,
    PRODUCT_TITLE       VARCHAR2(200)   NOT NULL,
    SUB_CATEGORY_NAME   VARCHAR2(50),
    PRODUCT_PLACE       VARCHAR2(100),
    PRODUCT_STATE       VARCHAR2(20),                -- 미개봉 / 사용감 있음 등
    PRODUCT_PRICE       NUMBER          DEFAULT 0,
    PRODUCT_EXPLANATION VARCHAR2(2000),
    PRODUCT_KEYWORD     VARCHAR2(200),
    CONSTRAINT PK_PRODUCT      PRIMARY KEY (PRODUCT_ID),
    CONSTRAINT FK_PRODUCT_USER FOREIGN KEY (USER_NO) REFERENCES USERS_TB(USER_NO)
);
-- ProductRegistMapper.xml insertProduct: INSERT(product_id,user_no,product_title,sub_category_name,product_place,product_state,product_price,product_explanation,product_keyword)
-- ProductRegistMapper.xml selectMainProducts: SELECT P.PRODUCT_ID,P.USER_NO,P.PRODUCT_TITLE,P.PRODUCT_STATE,P.PRODUCT_PRICE,P.SUB_CATEGORY_NAME,P.PRODUCT_PLACE ... FETCH FIRST 16 ROWS ONLY
-- ProductRegistMapper.xml searchProducts: WHERE UPPER(P.PRODUCT_TITLE) LIKE UPPER('%'||#{keyword}||'%') OR UPPER(P.PRODUCT_KEYWORD) LIKE ...
-- ProductRegistMapper.xml selectProductsByCategory: WHERE P.SUB_CATEGORY_NAME=#{category} OR EXISTS(SELECT 1 FROM SUBCATEGORY S JOIN CATEGORY C ...)


-- -----------------------------------
-- 3-5. 상품 이미지 파일 테이블
-- 출처: ProductRegistMapper.xml, ProductFile.java
-- -----------------------------------
CREATE TABLE PRODUCT_FILE (
    FILE_ID       NUMBER          NOT NULL,
    PRODUCT_ID    VARCHAR2(20)    NOT NULL,
    ORIGINAL_NAME VARCHAR2(200),
    SAVED_NAME    VARCHAR2(200),
    FILE_PATH     VARCHAR2(500),
    IS_MAIN       NUMBER(1)       DEFAULT 0,         -- 1=대표이미지, 0=일반
    CONSTRAINT PK_PRODUCT_FILE PRIMARY KEY (FILE_ID),
    CONSTRAINT FK_PFILE_PRODUCT FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCT(PRODUCT_ID) ON DELETE CASCADE
);
-- ProductRegistMapper.xml insertProductFile: INSERT(file_id,product_id,original_name,saved_name,file_path,is_main)
-- ProductRegistMapper.xml selectProductFilesById: SELECT FILE_ID,PRODUCT_ID,ORIGINAL_NAME,SAVED_NAME,FILE_PATH,IS_MAIN FROM PRODUCT_FILE WHERE PRODUCT_ID=#{productId} ORDER BY IS_MAIN DESC, FILE_ID ASC


-- -----------------------------------
-- 3-6. 채팅방 테이블
-- 출처: ChatMapper.xml, ChatRoom.java, ChatController.java
-- -----------------------------------
CREATE TABLE CHAT_ROOM (
    ROOM_ID    NUMBER   NOT NULL,
    PRODUCT_ID NUMBER   NOT NULL,    -- ChatController: @RequestParam int productId (PRODUCT.PRODUCT_ID 와 타입 불일치로 FK 없음)
    SELLER_NO  NUMBER   NOT NULL,
    BUYER_NO   NUMBER   NOT NULL,
    CREATED_AT DATE     DEFAULT SYSDATE,
    CONSTRAINT PK_CHAT_ROOM   PRIMARY KEY (ROOM_ID),
    CONSTRAINT FK_ROOM_SELLER FOREIGN KEY (SELLER_NO) REFERENCES USERS_TB(USER_NO),
    CONSTRAINT FK_ROOM_BUYER  FOREIGN KEY (BUYER_NO)  REFERENCES USERS_TB(USER_NO)
);
-- ChatMapper.xml createRoom: INSERT(ROOM_ID,PRODUCT_ID,SELLER_NO,BUYER_NO,CREATED_AT) VALUES(SEQ_CHAT_ROOM.NEXTVAL,...)
-- ChatMapper.xml findRoomByParticipants: WHERE PRODUCT_ID=#{productId} AND ((SELLER_NO=#{senderUserNo} AND BUYER_NO=#{receiverUserNo}) OR ...)
-- ChatMapper.xml getUserChatRooms: SELECT R.ROOM_ID,R.PRODUCT_ID,R.SELLER_NO,R.BUYER_NO,R.CREATED_AT FROM CHAT_ROOM R WHERE SELLER_NO=#{userNo} OR BUYER_NO=#{userNo}


-- -----------------------------------
-- 3-7. 채팅 메시지 테이블
-- 출처: ChatMapper.xml, ChatMessage.java
-- -----------------------------------
CREATE TABLE CHAT_MESSAGE (
    MSG_ID      NUMBER          NOT NULL,
    ROOM_ID     NUMBER          NOT NULL,
    SENDER_NO   NUMBER          NOT NULL,
    MESSAGE     VARCHAR2(2000),
    SENT_AT     TIMESTAMP       DEFAULT SYSTIMESTAMP,
    IS_READ     VARCHAR2(1)     DEFAULT 'N',         -- Y / N
    RECEIVER_NO NUMBER          NOT NULL,
    CONSTRAINT PK_CHAT_MESSAGE PRIMARY KEY (MSG_ID),
    CONSTRAINT FK_MSG_ROOM     FOREIGN KEY (ROOM_ID)     REFERENCES CHAT_ROOM(ROOM_ID) ON DELETE CASCADE,
    CONSTRAINT FK_MSG_SENDER   FOREIGN KEY (SENDER_NO)   REFERENCES USERS_TB(USER_NO),
    CONSTRAINT FK_MSG_RECEIVER FOREIGN KEY (RECEIVER_NO) REFERENCES USERS_TB(USER_NO)
);
-- ChatMapper.xml insertChatMessage:
--   INSERT INTO CHAT_MESSAGE VALUES(CHAT_MESSAGE_SEQ.NEXTVAL,#{roomId},#{senderNo},#{message},SYSDATE,default,#{receiverNo})
--   컬럼 순서: MSG_ID, ROOM_ID, SENDER_NO, MESSAGE, SENT_AT, IS_READ, RECEIVER_NO
-- ChatMapper.xml getChatMessagesByRoomId: SELECT M.ROOM_ID,M.SENDER_NO,U.NAME AS SENDER_NAME,M.MESSAGE,M.SENT_AT FROM CHAT_MESSAGE M JOIN USERS_TB U ON M.SENDER_NO=U.USER_NO
-- ChatMapper.xml markMessagesAsRead: UPDATE CHAT_MESSAGE SET IS_READ='Y' WHERE ROOM_ID=#{roomId} AND RECEIVER_NO=#{userNo} AND IS_READ='N'
-- ChatMapper.xml getUnreadMessageCount: SELECT COUNT(*) FROM CHAT_MESSAGE WHERE ROOM_ID=#{roomId} AND SENDER_NO=#{userNo} AND IS_READ='N'


-- -----------------------------------
-- 3-8. 알림 테이블
-- 출처: NotificationMapper.xml, Notification.java
-- -----------------------------------
CREATE TABLE NOTIFICATION (
    NOTI_ID           VARCHAR2(10)    NOT NULL,   -- 'NOTI00001' 형식: 'NOTI'||LPAD(NOTI_SEQ.NEXTVAL,5,'0')
    USER_NO           NUMBER          NOT NULL,
    NOTI_MESSAGE      VARCHAR2(500),
    NOTI_URL          VARCHAR2(200),
    IS_READ           VARCHAR2(1)     DEFAULT 'N',
    CREATED_AT        TIMESTAMP       DEFAULT SYSTIMESTAMP,
    NOTIFICATION_TYPE VARCHAR2(20),               -- MESSAGE / SYSTEM 등
    CONSTRAINT PK_NOTIFICATION PRIMARY KEY (NOTI_ID),
    CONSTRAINT FK_NOTI_USER    FOREIGN KEY (USER_NO) REFERENCES USERS_TB(USER_NO) ON DELETE CASCADE
);
-- NotificationMapper.xml insertNotification: INSERT(NOTI_ID,USER_NO,NOTI_MESSAGE,NOTI_URL,NOTIFICATION_TYPE)
-- NotificationMapper.xml selectNoReadNotiByN: SELECT COUNT(*) FROM NOTIFICATION WHERE USER_NO=#{userNo} AND IS_READ='N'
-- NotificationMapper.xml selectNoReadNotiByNFromM: ... AND NOTIFICATION_TYPE='MESSAGE'


-- -----------------------------------
-- 3-9. 게시판 테이블
-- 출처: CustomCenter.xml, Board.java
-- -----------------------------------
CREATE TABLE BOARD (
    BOARD_NO                 NUMBER          NOT NULL,
    BOARD_WRITER             VARCHAR2(50),
    BOARD_TITLE              VARCHAR2(200)   NOT NULL,
    BOARD_CONTENT            VARCHAR2(2000),
    BOARD_DATE               DATE            DEFAULT SYSDATE,
    BOARD_CATEGORY           VARCHAR2(50),
    NOTICE_YN                VARCHAR2(1)     DEFAULT 'N',   -- Y=공지, N=일반
    BOARD_ORIGINAL_FILE_NAME VARCHAR2(200),
    BOARD_RENAMED_FILE_NAME  VARCHAR2(200),
    CONSTRAINT PK_BOARD PRIMARY KEY (BOARD_NO)
);
-- CustomCenter.xml getPagedBoardList: SELECT * FROM BOARD WHERE NOTICE_YN=#{notice} [AND BOARD_CATEGORY=#{category}] ORDER BY BOARD_NO DESC
-- CustomCenter.xml getBoardListByCategory: SELECT * FROM BOARD WHERE BOARD_CATEGORY=#{category}
-- Board.java 필드: boardNo,boardWriter,boardTitle,boardContent,boardDate,boardCategory,noticeYn,boardOriginalFileName,boardRenamedFileName,rnum


-- -----------------------------------
-- 3-10. 이메일 인증 테이블
-- 출처: EmailMapper.xml, AuthNumber.java
-- -----------------------------------
CREATE TABLE EMAIL_AUTH (
    EMAIL       VARCHAR2(100)   NOT NULL,
    AUTH_CODE   VARCHAR2(10)    NOT NULL,
    CREATE_TIME TIMESTAMP       DEFAULT SYSTIMESTAMP,
    IS_VERIFIED VARCHAR2(1)     DEFAULT 'N',
    REQUEST_IP  VARCHAR2(50),
    CONSTRAINT PK_EMAIL_AUTH PRIMARY KEY (EMAIL)
);
-- EmailMapper.xml createAuthNumber: MERGE INTO email_auth ON (email=#{email})
--   MATCHED: UPDATE SET auth_code=#{authCode}, create_time=SYSTIMESTAMP, is_verified='N'
--   NOT MATCHED: INSERT(email,auth_code,create_time,is_verified,request_ip)
-- EmailMapper.xml compareAuthNumber: WHERE email=#{email} AND auth_code=#{authCode} AND is_verified='N' AND create_time >= SYSTIMESTAMP - INTERVAL '5' MINUTE



-- =============================================================
-- 4. 인덱스 생성  (조회 성능 최적화)
-- =============================================================

-- USERS_TB
CREATE INDEX IDX_USERS_LOGIN_ID  ON USERS_TB (LOGIN_ID);          -- findByUserId, duplicateId
CREATE INDEX IDX_USERS_EMAIL     ON USERS_TB (EMAIL);              -- emailDupCheck
CREATE INDEX IDX_USERS_OAUTH     ON USERS_TB (OAUTH_ID, OAUTH_PROVIDER); -- findByKakaoId

-- PRODUCT
CREATE INDEX IDX_PRODUCT_USER_NO      ON PRODUCT (USER_NO);        -- 판매자별 상품 조회
CREATE INDEX IDX_PRODUCT_SUB_CATE     ON PRODUCT (SUB_CATEGORY_NAME); -- selectProductsByCategory
CREATE INDEX IDX_PRODUCT_TITLE        ON PRODUCT (PRODUCT_TITLE);  -- searchProducts LIKE 검색

-- PRODUCT_FILE
CREATE INDEX IDX_PFILE_PRODUCT_ID ON PRODUCT_FILE (PRODUCT_ID);   -- selectProductFilesById
CREATE INDEX IDX_PFILE_IS_MAIN    ON PRODUCT_FILE (PRODUCT_ID, IS_MAIN); -- 대표이미지 조회

-- CHAT_ROOM
CREATE INDEX IDX_CHATROOM_SELLER   ON CHAT_ROOM (SELLER_NO);       -- getUserChatRooms
CREATE INDEX IDX_CHATROOM_BUYER    ON CHAT_ROOM (BUYER_NO);        -- getUserChatRooms
CREATE INDEX IDX_CHATROOM_PRODUCT  ON CHAT_ROOM (PRODUCT_ID);      -- findRoomByParticipants

-- CHAT_MESSAGE
CREATE INDEX IDX_CHATMSG_ROOM_ID   ON CHAT_MESSAGE (ROOM_ID);      -- getChatMessagesByRoomId, getMessages
CREATE INDEX IDX_CHATMSG_RECEIVER  ON CHAT_MESSAGE (RECEIVER_NO, IS_READ); -- markMessagesAsRead
CREATE INDEX IDX_CHATMSG_SENT_AT   ON CHAT_MESSAGE (ROOM_ID, SENT_AT);     -- 시간순 정렬

-- NOTIFICATION
CREATE INDEX IDX_NOTI_USER_READ    ON NOTIFICATION (USER_NO, IS_READ);  -- selectNoReadNotiByN
CREATE INDEX IDX_NOTI_TYPE         ON NOTIFICATION (USER_NO, NOTIFICATION_TYPE); -- selectNoReadNotiByNFromM

-- BOARD
CREATE INDEX IDX_BOARD_NOTICE      ON BOARD (NOTICE_YN, BOARD_NO);    -- getPagedBoardList 페이징
CREATE INDEX IDX_BOARD_CATEGORY    ON BOARD (BOARD_CATEGORY);         -- getBoardListByCategory

-- EMAIL_AUTH
CREATE INDEX IDX_EMAIL_AUTH_TIME   ON EMAIL_AUTH (EMAIL, CREATE_TIME); -- compareAuthNumber



-- =============================================================
-- 5. 샘플 데이터 INSERT
-- =============================================================

-- -----------------------------------
-- 5-1. 회원 (USERS_TB) - 10건
-- 비밀번호: 'hifive1234' BCrypt 해시 (ROLE_ADMIN은 'admin1234')
-- -----------------------------------
INSERT INTO USERS_TB (USER_NO, LOGIN_ID, PASS_WD, NAME, EMAIL, ROLE, REG_DATE)
VALUES (USERS_SEQ.NEXTVAL, 'hong01',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhy',
        '홍길동', 'hong01@email.com', 'ROLE_USER', SYSDATE);

INSERT INTO USERS_TB (USER_NO, LOGIN_ID, PASS_WD, NAME, EMAIL, ROLE, REG_DATE)
VALUES (USERS_SEQ.NEXTVAL, 'kim02',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhy',
        '김철수', 'kim02@email.com', 'ROLE_USER', SYSDATE);

INSERT INTO USERS_TB (USER_NO, LOGIN_ID, PASS_WD, NAME, EMAIL, ROLE, REG_DATE)
VALUES (USERS_SEQ.NEXTVAL, 'lee03',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhy',
        '이영희', 'lee03@email.com', 'ROLE_USER', SYSDATE);

-- 카카오 소셜 로그인 회원 (LOGIN_ID, PASS_WD 없음)
INSERT INTO USERS_TB (USER_NO, NAME, EMAIL, ROLE, OAUTH_PROVIDER, OAUTH_ID, REG_DATE)
VALUES (USERS_SEQ.NEXTVAL, '박민준', 'park04@kakao.com', 'ROLE_USER', 'kakao', '3012345678', SYSDATE);

INSERT INTO USERS_TB (USER_NO, LOGIN_ID, PASS_WD, NAME, EMAIL, ROLE, REG_DATE)
VALUES (USERS_SEQ.NEXTVAL, 'choi05',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhy',
        '최수진', 'choi05@email.com', 'ROLE_USER', SYSDATE);

INSERT INTO USERS_TB (USER_NO, LOGIN_ID, PASS_WD, NAME, EMAIL, ROLE, REG_DATE)
VALUES (USERS_SEQ.NEXTVAL, 'jung06',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhy',
        '정대현', 'jung06@email.com', 'ROLE_USER', SYSDATE);

-- 카카오 소셜 로그인 회원
INSERT INTO USERS_TB (USER_NO, NAME, EMAIL, ROLE, OAUTH_PROVIDER, OAUTH_ID, REG_DATE)
VALUES (USERS_SEQ.NEXTVAL, '강지원', 'kang07@kakao.com', 'ROLE_USER', 'kakao', '3087654321', SYSDATE);

INSERT INTO USERS_TB (USER_NO, LOGIN_ID, PASS_WD, NAME, EMAIL, ROLE, REG_DATE)
VALUES (USERS_SEQ.NEXTVAL, 'yoon08',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhy',
        '윤서연', 'yoon08@email.com', 'ROLE_USER', SYSDATE);

INSERT INTO USERS_TB (USER_NO, LOGIN_ID, PASS_WD, NAME, EMAIL, ROLE, REG_DATE)
VALUES (USERS_SEQ.NEXTVAL, 'lim09',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhy',
        '임태양', 'lim09@email.com', 'ROLE_USER', SYSDATE);

-- 관리자 계정 (비밀번호: admin1234)
INSERT INTO USERS_TB (USER_NO, LOGIN_ID, PASS_WD, NAME, EMAIL, ROLE, REG_DATE)
VALUES (USERS_SEQ.NEXTVAL, 'admin',
        '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW',
        '관리자', 'admin@hifive.com', 'ROLE_ADMIN', SYSDATE);


-- -----------------------------------
-- 5-2. 마이페이지 (MY_USER_PAGE_TB) - 10건
-- USER_NO 1~10 에 대응
-- -----------------------------------
INSERT INTO MY_USER_PAGE_TB (USER_NO, PROFILE_IMG, INTRODUCE, TEMPERATURE)
VALUES (1, 'default_profile.png', '안녕하세요, 홍길동입니다. 깔끔하게 거래해요!', 36.5);

INSERT INTO MY_USER_PAGE_TB (USER_NO, PROFILE_IMG, INTRODUCE, TEMPERATURE)
VALUES (2, 'default_profile.png', '빠른 거래 선호합니다. 잘 부탁드려요.', 37.2);

INSERT INTO MY_USER_PAGE_TB (USER_NO, PROFILE_IMG, INTRODUCE, TEMPERATURE)
VALUES (3, 'default_profile.png', '친절한 거래 환경 만들어가겠습니다 :)', 38.0);

INSERT INTO MY_USER_PAGE_TB (USER_NO, PROFILE_IMG, INTRODUCE, TEMPERATURE)
VALUES (4, 'default_profile.png', '카카오로 로그인한 박민준입니다.', 36.5);

INSERT INTO MY_USER_PAGE_TB (USER_NO, PROFILE_IMG, INTRODUCE, TEMPERATURE)
VALUES (5, 'default_profile.png', '좋은 물건 좋은 가격에 드립니다!', 37.8);

INSERT INTO MY_USER_PAGE_TB (USER_NO, PROFILE_IMG, INTRODUCE, TEMPERATURE)
VALUES (6, 'default_profile.png', '성실하게 거래합니다. 연락주세요.', 36.5);

INSERT INTO MY_USER_PAGE_TB (USER_NO, PROFILE_IMG, INTRODUCE, TEMPERATURE)
VALUES (7, 'default_profile.png', '강지원입니다. 소통 잘해요!', 39.0);

INSERT INTO MY_USER_PAGE_TB (USER_NO, PROFILE_IMG, INTRODUCE, TEMPERATURE)
VALUES (8, 'default_profile.png', '믿을 수 있는 판매자가 되겠습니다.', 36.5);

INSERT INTO MY_USER_PAGE_TB (USER_NO, PROFILE_IMG, INTRODUCE, TEMPERATURE)
VALUES (9, 'default_profile.png', '직거래 선호합니다. 서울 강남 근처.', 36.8);

INSERT INTO MY_USER_PAGE_TB (USER_NO, PROFILE_IMG, INTRODUCE, TEMPERATURE)
VALUES (10, 'default_profile.png', 'HiFive 관리자 계정입니다.', 40.0);


-- -----------------------------------
-- 5-3. 카테고리 (CATEGORY) - 9건 (서비스 기본 데이터)
-- -----------------------------------
INSERT INTO CATEGORY (CATEGORY_ID, CATEGORY_NAME) VALUES (CATEGORY_SEQ.NEXTVAL, '패션의류');     -- 1
INSERT INTO CATEGORY (CATEGORY_ID, CATEGORY_NAME) VALUES (CATEGORY_SEQ.NEXTVAL, '패션잡화');     -- 2
INSERT INTO CATEGORY (CATEGORY_ID, CATEGORY_NAME) VALUES (CATEGORY_SEQ.NEXTVAL, '가전제품');     -- 3
INSERT INTO CATEGORY (CATEGORY_ID, CATEGORY_NAME) VALUES (CATEGORY_SEQ.NEXTVAL, 'PC/모바일');    -- 4
INSERT INTO CATEGORY (CATEGORY_ID, CATEGORY_NAME) VALUES (CATEGORY_SEQ.NEXTVAL, '가구/인테리어'); -- 5
INSERT INTO CATEGORY (CATEGORY_ID, CATEGORY_NAME) VALUES (CATEGORY_SEQ.NEXTVAL, '리빙/생활');    -- 6
INSERT INTO CATEGORY (CATEGORY_ID, CATEGORY_NAME) VALUES (CATEGORY_SEQ.NEXTVAL, '스포츠/레저');  -- 7
INSERT INTO CATEGORY (CATEGORY_ID, CATEGORY_NAME) VALUES (CATEGORY_SEQ.NEXTVAL, '도서/음반/문구'); -- 8
INSERT INTO CATEGORY (CATEGORY_ID, CATEGORY_NAME) VALUES (CATEGORY_SEQ.NEXTVAL, '차량/오토바이'); -- 9


-- -----------------------------------
-- 5-4. 서브카테고리 (SUBCATEGORY) - 33건
-- -----------------------------------
-- 패션의류 (1)
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '남성의류',    1);   --  1
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '여성의류',    1);   --  2
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '아동의류',    1);   --  3
-- 패션잡화 (2)
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '가방',        2);   --  4
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '신발',        2);   --  5
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '시계/주얼리',  2);  --  6
-- 가전제품 (3)
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, 'TV/영상',     3);   --  7
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '냉장고',      3);   --  8
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '세탁기',      3);   --  9
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '에어컨',      3);   -- 10
-- PC/모바일 (4)
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '스마트폰',    4);   -- 11
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '노트북',      4);   -- 12
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '태블릿',      4);   -- 13
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '데스크탑',    4);   -- 14
-- 가구/인테리어 (5)
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '소파/침대',   5);   -- 15
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '책상/의자',   5);   -- 16
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '수납/정리',   5);   -- 17
-- 리빙/생활 (6)
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '주방용품',    6);   -- 18
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '욕실용품',    6);   -- 19
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '청소용품',    6);   -- 20
-- 스포츠/레저 (7)
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '헬스/요가',   7);   -- 21
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '자전거',      7);   -- 22
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '캠핑',        7);   -- 23
-- 도서/음반/문구 (8)
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '도서',        8);   -- 24
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, 'CD/DVD',      8);   -- 25
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '문구/오피스', 8);   -- 26
-- 차량/오토바이 (9)
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '승용차',      9);   -- 27
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, 'SUV',         9);   -- 28
INSERT INTO SUBCATEGORY VALUES (SUBCATEGORY_SEQ.NEXTVAL, '오토바이',    9);   -- 29


-- -----------------------------------
-- 5-5. 상품 (PRODUCT) - 10건
-- PRODUCT_ID: PRODUCT_ID_SEQ.NEXTVAL 를 TO_CHAR로 문자 변환
-- ProductRegistMapper.xml insertProduct selectKey: resultType="string"
-- -----------------------------------
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 1, '아이폰 15 Pro 256GB 블랙 미개봉', '스마트폰', '서울 강남구', '미개봉', 1350000,
        '아이폰 15 Pro 256GB 블랙 미개봉 제품입니다. 선물용으로 구매했으나 기기변경으로 판매합니다. 박스 실링 그대로입니다.',
        '아이폰,iPhone,애플,Apple,스마트폰,미개봉');

INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 2, '맥북 에어 M2 2023 스페이스그레이 256GB', '노트북', '서울 서초구', '거의새것', 1150000,
        '맥북 에어 M2 2023년형입니다. 구입 후 3개월 사용했으며 외관 흠집 없습니다. 충전기 포함. 영수증 있습니다.',
        '맥북,MacBook,애플,노트북,M2');

INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 3, '나이키 에어포스1 화이트 270mm', '신발', '경기 성남시', '거의새것', 75000,
        '나이키 에어포스1 로우 화이트 270mm입니다. 총 2회 착용 후 보관 중입니다. 박스 포함 판매합니다.',
        '나이키,Nike,에어포스,운동화,스니커즈');

INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 4, '삼성 QLED TV 65인치 2022년형', 'TV/영상', '부산 해운대구', '사용감 있음', 620000,
        '삼성 QLED 65인치 TV입니다. 2022년 구매 후 이사로 판매합니다. 작동 이상 없으며 리모컨 포함입니다.',
        '삼성,TV,QLED,65인치,텔레비전');

INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 5, '다이슨 V15 Detect 무선청소기', '청소용품', '인천 남동구', '거의새것', 480000,
        '다이슨 V15 Detect 무선청소기입니다. 구입 2개월 된 제품이며 흡입력 정상입니다. 부속품 모두 포함.',
        '다이슨,청소기,무선청소기,Dyson,V15');

INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 6, '해리포터 전집 양장본 1~7권 세트', '도서', '대전 유성구', '사용감 있음', 35000,
        '해리포터 전집 1권부터 7권까지 완전 세트입니다. 전체적으로 깨끗하며 일부 모서리 살짝 눌린 자국 있습니다.',
        '해리포터,전집,소설,도서,책');

INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 7, '이케아 KALLAX 책장 4x4 화이트', '수납/정리', '서울 마포구', '사용감 있음', 55000,
        '이케아 KALLAX 4x4 칸 책장 화이트입니다. 이사 정리로 판매합니다. 분해 가능하며 직접 가져가실 분만 구매 가능합니다.',
        '이케아,KALLAX,책장,수납,인테리어');

INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 8, '갤럭시 탭 S9 FE 256GB 실버 Wi-Fi', '태블릿', '광주 북구', '미개봉', 520000,
        '갤럭시 탭 S9 FE 256GB 실버 Wi-Fi 미개봉 새상품입니다. 구매 후 쓸 일이 없어 바로 판매합니다.',
        '갤럭시탭,삼성,태블릿,S9FE,미개봉');

INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 9, '나이키 바람막이 집업 재킷 M사이즈', '남성의류', '대구 중구', '거의새것', 42000,
        '나이키 바람막이 집업 재킷 M사이즈입니다. 작년에 구매 후 2회 착용했습니다. 세탁 완료 후 판매합니다.',
        '나이키,바람막이,재킷,남성의류,아우터');

INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 1, '캠핑 체어 헬리녹스 스타일 경량 의자', '캠핑', '경기 용인시', '거의새것', 28000,
        '경량 폴딩 캠핑 체어입니다. 헬리녹스와 유사한 스타일이며 무게 900g입니다. 2회 사용 후 보관 중입니다.',
        '캠핑의자,경량의자,캠핑,폴딩체어,아웃도어');


-- -----------------------------------
-- 5-6. 상품 이미지 (PRODUCT_FILE) - 10건
-- PRODUCT_ID VARCHAR2 이므로 문자열 '1'~'10'으로 참조
-- -----------------------------------
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN)
VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '1', 'iphone15pro_main.jpg', 'a1b2c3d4-1111-aaaa-bbbb-000000000001.jpg', '/upload/productRegist/a1b2c3d4-1111-aaaa-bbbb-000000000001.jpg', 1);

INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN)
VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '2', 'macbook_air_m2_main.jpg', 'a1b2c3d4-2222-aaaa-bbbb-000000000002.jpg', '/upload/productRegist/a1b2c3d4-2222-aaaa-bbbb-000000000002.jpg', 1);

INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN)
VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '2', 'macbook_air_m2_side.jpg', 'a1b2c3d4-2222-aaaa-bbbb-000000000003.jpg', '/upload/productRegist/a1b2c3d4-2222-aaaa-bbbb-000000000003.jpg', 0);

INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN)
VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '3', 'airforce1_white_main.jpg', 'a1b2c3d4-3333-aaaa-bbbb-000000000004.jpg', '/upload/productRegist/a1b2c3d4-3333-aaaa-bbbb-000000000004.jpg', 1);

INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN)
VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '4', 'samsung_tv_65_main.jpg', 'a1b2c3d4-4444-aaaa-bbbb-000000000005.jpg', '/upload/productRegist/a1b2c3d4-4444-aaaa-bbbb-000000000005.jpg', 1);

INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN)
VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '5', 'dyson_v15_main.jpg', 'a1b2c3d4-5555-aaaa-bbbb-000000000006.jpg', '/upload/productRegist/a1b2c3d4-5555-aaaa-bbbb-000000000006.jpg', 1);

INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN)
VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '6', 'harrypotter_books.jpg', 'a1b2c3d4-6666-aaaa-bbbb-000000000007.jpg', '/upload/productRegist/a1b2c3d4-6666-aaaa-bbbb-000000000007.jpg', 1);

INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN)
VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '7', 'ikea_kallax_main.jpg', 'a1b2c3d4-7777-aaaa-bbbb-000000000008.jpg', '/upload/productRegist/a1b2c3d4-7777-aaaa-bbbb-000000000008.jpg', 1);

INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN)
VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '8', 'galaxy_tab_s9fe_main.jpg', 'a1b2c3d4-8888-aaaa-bbbb-000000000009.jpg', '/upload/productRegist/a1b2c3d4-8888-aaaa-bbbb-000000000009.jpg', 1);

INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN)
VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '9', 'nike_jacket_main.jpg', 'a1b2c3d4-9999-aaaa-bbbb-000000000010.jpg', '/upload/productRegist/a1b2c3d4-9999-aaaa-bbbb-000000000010.jpg', 1);

INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN)
VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '10', 'camping_chair_main.jpg', 'a1b2c3d4-aaaa-aaaa-bbbb-000000000011.jpg', '/upload/productRegist/a1b2c3d4-aaaa-aaaa-bbbb-000000000011.jpg', 1);


-- -----------------------------------
-- 5-7. 채팅방 (CHAT_ROOM) - 5건
-- PRODUCT_ID: ChatController @RequestParam int productId 기준 (숫자)
-- -----------------------------------
INSERT INTO CHAT_ROOM (ROOM_ID, PRODUCT_ID, SELLER_NO, BUYER_NO, CREATED_AT)
VALUES (SEQ_CHAT_ROOM.NEXTVAL, 1, 1, 2, SYSDATE);          -- 아이폰 문의 (홍길동↔김철수)

INSERT INTO CHAT_ROOM (ROOM_ID, PRODUCT_ID, SELLER_NO, BUYER_NO, CREATED_AT)
VALUES (SEQ_CHAT_ROOM.NEXTVAL, 2, 2, 3, SYSDATE);          -- 맥북 문의 (김철수↔이영희)

INSERT INTO CHAT_ROOM (ROOM_ID, PRODUCT_ID, SELLER_NO, BUYER_NO, CREATED_AT)
VALUES (SEQ_CHAT_ROOM.NEXTVAL, 3, 3, 4, SYSDATE);          -- 나이키 문의 (이영희↔박민준)

INSERT INTO CHAT_ROOM (ROOM_ID, PRODUCT_ID, SELLER_NO, BUYER_NO, CREATED_AT)
VALUES (SEQ_CHAT_ROOM.NEXTVAL, 4, 4, 5, SYSDATE);          -- 삼성TV 문의 (박민준↔최수진)

INSERT INTO CHAT_ROOM (ROOM_ID, PRODUCT_ID, SELLER_NO, BUYER_NO, CREATED_AT)
VALUES (SEQ_CHAT_ROOM.NEXTVAL, 5, 5, 6, SYSDATE);          -- 다이슨 문의 (최수진↔정대현)


-- -----------------------------------
-- 5-8. 채팅 메시지 (CHAT_MESSAGE) - 10건
-- ChatMapper.xml insertChatMessage 컬럼 순서:
--   MSG_ID, ROOM_ID, SENDER_NO, MESSAGE, SENT_AT, IS_READ, RECEIVER_NO
-- -----------------------------------
INSERT INTO CHAT_MESSAGE VALUES (CHAT_MESSAGE_SEQ.NEXTVAL, 1, 2, '안녕하세요! 아이폰 15 Pro 아직 있나요?', SYSTIMESTAMP, 'Y', 1);
INSERT INTO CHAT_MESSAGE VALUES (CHAT_MESSAGE_SEQ.NEXTVAL, 1, 1, '네, 아직 있습니다! 언제 거래 가능하세요?', SYSTIMESTAMP, 'Y', 2);
INSERT INTO CHAT_MESSAGE VALUES (CHAT_MESSAGE_SEQ.NEXTVAL, 1, 2, '이번 주 주말에 강남역 근처 가능할까요?', SYSTIMESTAMP, 'N', 1);

INSERT INTO CHAT_MESSAGE VALUES (CHAT_MESSAGE_SEQ.NEXTVAL, 2, 3, '맥북 에어 상태 어떤가요? 사진 더 있으신가요?', SYSTIMESTAMP, 'Y', 2);
INSERT INTO CHAT_MESSAGE VALUES (CHAT_MESSAGE_SEQ.NEXTVAL, 2, 2, '상태 정말 좋습니다! 추가 사진 보내드릴게요.', SYSTIMESTAMP, 'Y', 3);
INSERT INTO CHAT_MESSAGE VALUES (CHAT_MESSAGE_SEQ.NEXTVAL, 2, 3, '가격 조금 더 내려주실 수 있나요?', SYSTIMESTAMP, 'N', 2);

INSERT INTO CHAT_MESSAGE VALUES (CHAT_MESSAGE_SEQ.NEXTVAL, 3, 4, '나이키 신발 사이즈 270mm 맞죠?', SYSTIMESTAMP, 'Y', 3);
INSERT INTO CHAT_MESSAGE VALUES (CHAT_MESSAGE_SEQ.NEXTVAL, 3, 3, '네 270mm 맞아요! 박스도 있습니다.', SYSTIMESTAMP, 'N', 4);

INSERT INTO CHAT_MESSAGE VALUES (CHAT_MESSAGE_SEQ.NEXTVAL, 4, 5, 'TV 직거래 가능하신가요? 부산 사직동 근처입니다.', SYSTIMESTAMP, 'Y', 4);
INSERT INTO CHAT_MESSAGE VALUES (CHAT_MESSAGE_SEQ.NEXTVAL, 4, 4, '직거래 가능합니다. 주말 오전 어떠세요?', SYSTIMESTAMP, 'N', 5);


-- -----------------------------------
-- 5-9. 알림 (NOTIFICATION) - 10건
-- NOTI_ID: 'NOTI'||LPAD(NOTI_SEQ.NEXTVAL,5,'0') → 'NOTI00001' 형식
-- -----------------------------------
INSERT INTO NOTIFICATION (NOTI_ID, USER_NO, NOTI_MESSAGE, NOTI_URL, IS_READ, CREATED_AT, NOTIFICATION_TYPE)
VALUES ('NOTI' || LPAD(NOTI_SEQ.NEXTVAL,5,'0'), 1, '김철수님이 아이폰 15 Pro에 대해 채팅을 요청했습니다.', '/chatList', 'N', SYSTIMESTAMP, 'MESSAGE');

INSERT INTO NOTIFICATION (NOTI_ID, USER_NO, NOTI_MESSAGE, NOTI_URL, IS_READ, CREATED_AT, NOTIFICATION_TYPE)
VALUES ('NOTI' || LPAD(NOTI_SEQ.NEXTVAL,5,'0'), 2, '이영희님이 맥북 에어에 대해 채팅을 요청했습니다.', '/chatList', 'N', SYSTIMESTAMP, 'MESSAGE');

INSERT INTO NOTIFICATION (NOTI_ID, USER_NO, NOTI_MESSAGE, NOTI_URL, IS_READ, CREATED_AT, NOTIFICATION_TYPE)
VALUES ('NOTI' || LPAD(NOTI_SEQ.NEXTVAL,5,'0'), 3, '박민준님이 나이키 신발에 대해 채팅을 요청했습니다.', '/chatList', 'N', SYSTIMESTAMP, 'MESSAGE');

INSERT INTO NOTIFICATION (NOTI_ID, USER_NO, NOTI_MESSAGE, NOTI_URL, IS_READ, CREATED_AT, NOTIFICATION_TYPE)
VALUES ('NOTI' || LPAD(NOTI_SEQ.NEXTVAL,5,'0'), 4, '최수진님이 삼성 TV에 대해 채팅을 요청했습니다.', '/chatList', 'Y', SYSTIMESTAMP, 'MESSAGE');

INSERT INTO NOTIFICATION (NOTI_ID, USER_NO, NOTI_MESSAGE, NOTI_URL, IS_READ, CREATED_AT, NOTIFICATION_TYPE)
VALUES ('NOTI' || LPAD(NOTI_SEQ.NEXTVAL,5,'0'), 5, '정대현님이 다이슨 청소기에 대해 채팅을 요청했습니다.', '/chatList', 'N', SYSTIMESTAMP, 'MESSAGE');

INSERT INTO NOTIFICATION (NOTI_ID, USER_NO, NOTI_MESSAGE, NOTI_URL, IS_READ, CREATED_AT, NOTIFICATION_TYPE)
VALUES ('NOTI' || LPAD(NOTI_SEQ.NEXTVAL,5,'0'), 1, '새로운 메시지가 도착했습니다.', '/chatList', 'N', SYSTIMESTAMP, 'MESSAGE');

INSERT INTO NOTIFICATION (NOTI_ID, USER_NO, NOTI_MESSAGE, NOTI_URL, IS_READ, CREATED_AT, NOTIFICATION_TYPE)
VALUES ('NOTI' || LPAD(NOTI_SEQ.NEXTVAL,5,'0'), 2, '거래가 완료되었습니다. 후기를 남겨주세요!', '/user/myPage/myPageMain', 'Y', SYSTIMESTAMP, 'SYSTEM');

INSERT INTO NOTIFICATION (NOTI_ID, USER_NO, NOTI_MESSAGE, NOTI_URL, IS_READ, CREATED_AT, NOTIFICATION_TYPE)
VALUES ('NOTI' || LPAD(NOTI_SEQ.NEXTVAL,5,'0'), 6, '홍길동님이 캠핑 체어에 대해 채팅을 요청했습니다.', '/chatList', 'N', SYSTIMESTAMP, 'MESSAGE');

INSERT INTO NOTIFICATION (NOTI_ID, USER_NO, NOTI_MESSAGE, NOTI_URL, IS_READ, CREATED_AT, NOTIFICATION_TYPE)
VALUES ('NOTI' || LPAD(NOTI_SEQ.NEXTVAL,5,'0'), 3, 'HiFive 서비스 점검 안내 (03/20 02:00~04:00)', '/user/boardList?notice=Y', 'N', SYSTIMESTAMP, 'SYSTEM');

INSERT INTO NOTIFICATION (NOTI_ID, USER_NO, NOTI_MESSAGE, NOTI_URL, IS_READ, CREATED_AT, NOTIFICATION_TYPE)
VALUES ('NOTI' || LPAD(NOTI_SEQ.NEXTVAL,5,'0'), 9, '관심 상품이 가격 인하되었습니다!', '/user/product/4', 'N', SYSTIMESTAMP, 'SYSTEM');


-- -----------------------------------
-- 5-10. 게시판 (BOARD) - 10건
-- 출처: CustomCenter.xml, Board.java (boardNo,boardWriter,boardTitle,boardContent,boardDate,boardCategory,noticeYn)
-- -----------------------------------
INSERT INTO BOARD (BOARD_NO, BOARD_WRITER, BOARD_TITLE, BOARD_CONTENT, BOARD_CATEGORY, NOTICE_YN)
VALUES (BOARD_SEQ.NEXTVAL, '관리자', '[공지] HiFive 서비스 이용 안내',
        'HiFive 중고거래 서비스에 오신 것을 환영합니다. 안전한 거래를 위한 이용 규칙을 꼭 확인해 주세요.',
        '공지', 'Y');

INSERT INTO BOARD (BOARD_NO, BOARD_WRITER, BOARD_TITLE, BOARD_CONTENT, BOARD_CATEGORY, NOTICE_YN)
VALUES (BOARD_SEQ.NEXTVAL, '관리자', '[공지] 개인정보 처리방침 개정 안내',
        '2026년 3월 1일부로 개인정보 처리방침이 일부 개정되었습니다. 주요 변경 사항을 확인해 주세요.',
        '공지', 'Y');

INSERT INTO BOARD (BOARD_NO, BOARD_WRITER, BOARD_TITLE, BOARD_CONTENT, BOARD_CATEGORY, NOTICE_YN)
VALUES (BOARD_SEQ.NEXTVAL, '관리자', '[공지] 서비스 점검 안내 (3/20)',
        '3월 20일 새벽 2시부터 4시까지 서비스 점검이 있을 예정입니다. 이용에 불편을 드려 죄송합니다.',
        '공지', 'Y');

INSERT INTO BOARD (BOARD_NO, BOARD_WRITER, BOARD_TITLE, BOARD_CONTENT, BOARD_CATEGORY, NOTICE_YN)
VALUES (BOARD_SEQ.NEXTVAL, '홍길동', '사기 거래 의심 신고합니다',
        '특정 유저가 입금 후 잠수를 탔습니다. 거래 전 주의 부탁드립니다. 자세한 내용은 고객센터에 문의해 주세요.',
        '신고', 'N');

INSERT INTO BOARD (BOARD_NO, BOARD_WRITER, BOARD_TITLE, BOARD_CONTENT, BOARD_CATEGORY, NOTICE_YN)
VALUES (BOARD_SEQ.NEXTVAL, '김철수', '안전 결제 서비스가 없나요?',
        '직거래가 걱정되는데 에스크로 같은 안전 결제 서비스를 추가해 주시면 좋겠습니다.',
        '건의', 'N');

INSERT INTO BOARD (BOARD_NO, BOARD_WRITER, BOARD_TITLE, BOARD_CONTENT, BOARD_CATEGORY, NOTICE_YN)
VALUES (BOARD_SEQ.NEXTVAL, '이영희', '이미지 업로드가 안 됩니다',
        '상품 등록 시 이미지를 업로드하려 하는데 계속 오류가 납니다. 확인 부탁드립니다.',
        '문의', 'N');

INSERT INTO BOARD (BOARD_NO, BOARD_WRITER, BOARD_TITLE, BOARD_CONTENT, BOARD_CATEGORY, NOTICE_YN)
VALUES (BOARD_SEQ.NEXTVAL, '관리자', '[공지] 비매너 유저 제재 기준 안내',
        '반복적인 노쇼, 사기 행위 등 비매너 행동 시 계정이 제재될 수 있습니다. 건전한 거래 문화를 만들어 주세요.',
        '공지', 'Y');

INSERT INTO BOARD (BOARD_NO, BOARD_WRITER, BOARD_TITLE, BOARD_CONTENT, BOARD_CATEGORY, NOTICE_YN)
VALUES (BOARD_SEQ.NEXTVAL, '최수진', '카카오 로그인 오류 문의',
        '카카오 로그인 후 프로필 페이지로 이동이 안 됩니다. 새로고침해도 동일합니다.',
        '문의', 'N');

INSERT INTO BOARD (BOARD_NO, BOARD_WRITER, BOARD_TITLE, BOARD_CONTENT, BOARD_CATEGORY, NOTICE_YN)
VALUES (BOARD_SEQ.NEXTVAL, '정대현', '판매 완료 표시 기능 요청',
        '상품을 판매 완료 처리하는 기능이 있으면 좋겠습니다. 현재는 삭제밖에 안 되는 것 같아요.',
        '건의', 'N');

INSERT INTO BOARD (BOARD_NO, BOARD_WRITER, BOARD_TITLE, BOARD_CONTENT, BOARD_CATEGORY, NOTICE_YN)
VALUES (BOARD_SEQ.NEXTVAL, '강지원', '검색이 잘 안 됩니다',
        '상품명으로 검색했을 때 결과가 나오지 않는 경우가 있습니다. 검색 기능을 개선해 주세요.',
        '문의', 'N');


COMMIT;
