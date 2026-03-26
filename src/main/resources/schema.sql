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
-- 5-5. 상품 (PRODUCT) - 30건  /  USER_NO 21~32 순환 배분
-- -----------------------------------
-- PC/모바일
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 21, '아이폰 15 Pro 256GB 블랙 미개봉', '스마트폰', '서울 강남구', '미개봉', 1350000, '아이폰 15 Pro 256GB 블랙 미개봉 제품입니다. 선물용으로 구매했으나 기기변경으로 판매합니다. 박스 실링 그대로입니다.', '아이폰,iPhone,애플,Apple,스마트폰,미개봉');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 22, '갤럭시 S24 울트라 256GB 티타늄블랙', '스마트폰', '서울 송파구', '미개봉', 1280000, '갤럭시 S24 울트라 256GB 티타늄블랙 미개봉 새상품입니다. 구매 후 개통하지 않았습니다. 구성품 모두 포함.', '갤럭시,삼성,S24,울트라,스마트폰,미개봉');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 23, '맥북 에어 M2 2023 스페이스그레이 256GB', '노트북', '서울 서초구', '거의새것', 1150000, '맥북 에어 M2 2023년형입니다. 구입 후 3개월 사용했으며 외관 흠집 없습니다. 충전기 포함. 영수증 있습니다.', '맥북,MacBook,애플,노트북,M2');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 24, 'LG 그램 16 2023 i7 16GB 512GB', '노트북', '경기 수원시', '거의새것', 1050000, 'LG 그램 16 2023년형 인텔 i7 16GB RAM 512GB SSD입니다. 6개월 사용. 배터리 90% 이상 유지. 케이스 포함.', 'LG그램,노트북,그램16,울트라북');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 25, '아이패드 Pro 12.9 M2 256GB Wi-Fi', '태블릿', '서울 종로구', '거의새것', 980000, '아이패드 프로 12.9인치 M2 칩 256GB입니다. 구입 후 2개월 사용. 케이스 포함 판매합니다.', '아이패드,iPad,애플,태블릿,M2');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 26, '갤럭시 탭 S9 FE 256GB 실버 Wi-Fi', '태블릿', '광주 북구', '미개봉', 520000, '갤럭시 탭 S9 FE 256GB 실버 Wi-Fi 미개봉 새상품입니다. 구매 후 쓸 일이 없어 바로 판매합니다.', '갤럭시탭,삼성,태블릿,S9FE,미개봉');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 27, '애플워치 Series 9 45mm GPS 미드나이트', '스마트폰', '부산 수영구', '미개봉', 430000, '애플워치 시리즈 9 45mm GPS 미드나이트 미개봉입니다. 선물용으로 구매했으나 사용 안 합니다.', '애플워치,AppleWatch,스마트워치,애플');

-- 가전제품
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 28, '삼성 QLED TV 65인치 2022년형', 'TV/영상', '부산 해운대구', '사용감 있음', 620000, '삼성 QLED 65인치 TV입니다. 2022년 구매 후 이사로 판매합니다. 작동 이상 없으며 리모컨 포함입니다.', '삼성,TV,QLED,65인치,텔레비전');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 29, '소니 WH-1000XM5 노이즈캔슬링 헤드폰', 'TV/영상', '서울 강서구', '거의새것', 280000, '소니 WH-1000XM5 블루투스 헤드폰입니다. 4개월 사용하고 판매합니다. 파우치 및 케이블 포함.', '소니,헤드폰,노이즈캔슬링,WH1000XM5,블루투스');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 30, '다이슨 V15 Detect 무선청소기', '청소용품', '인천 남동구', '거의새것', 480000, '다이슨 V15 Detect 무선청소기입니다. 구입 2개월 된 제품이며 흡입력 정상입니다. 부속품 모두 포함.', '다이슨,청소기,무선청소기,Dyson,V15');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 31, '삼성 비스포크 냉장고 4도어 800L', '냉장고', '경기 성남시', '사용감 있음', 1100000, '삼성 비스포크 냉장고 4도어 800L 코타차콜입니다. 2021년 구매 후 이사로 판매합니다. 작동 이상 없음.', '삼성,비스포크,냉장고,4도어');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 32, 'LG 트롬 세탁기 21kg 화이트', '세탁기', '인천 미추홀구', '사용감 있음', 420000, 'LG 트롬 세탁기 21kg입니다. 2022년 구매 후 사용 중이었으나 이사로 판매합니다. 정상 작동 확인.', 'LG,세탁기,트롬,드럼세탁기');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 21, '다이킨 에어컨 18평형 인버터 스탠드', '에어컨', '서울 노원구', '사용감 있음', 680000, '다이킨 인버터 스탠드 에어컨 18평형입니다. 2020년 구매. 매년 청소 완료. 직거래만 가능합니다.', '다이킨,에어컨,스탠드에어컨,인버터');

-- 패션의류/잡화
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 22, '나이키 에어포스1 화이트 270mm', '신발', '경기 성남시', '거의새것', 75000, '나이키 에어포스1 로우 화이트 270mm입니다. 총 2회 착용 후 보관 중입니다. 박스 포함 판매합니다.', '나이키,Nike,에어포스,운동화,스니커즈');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 23, '아디다스 삼바 OG 260mm 화이트블랙', '신발', '서울 영등포구', '거의새것', 88000, '아디다스 삼바 OG 화이트블랙 260mm입니다. 3회 착용 후 보관 중입니다. 박스 있습니다.', '아디다스,삼바,Samba,스니커즈,신발');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 24, '뉴발란스 992 그레이 275mm', '신발', '경기 고양시', '사용감 있음', 65000, '뉴발란스 992 그레이 275mm 판매합니다. 자주 착용했으나 상태 양호합니다. 박스 없음.', '뉴발란스,NewBalance,992,운동화');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 25, '나이키 테크 플리스 집업 후디 M 블랙', '남성의류', '대전 서구', '거의새것', 95000, '나이키 테크 플리스 집업 후디 M사이즈 블랙입니다. 작년 겨울 구입 후 2회 착용했습니다.', '나이키,테크플리스,후디,집업,남성의류');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 26, '나이키 바람막이 집업 재킷 M사이즈', '남성의류', '대구 중구', '거의새것', 42000, '나이키 바람막이 집업 재킷 M사이즈입니다. 작년에 구매 후 2회 착용했습니다. 세탁 완료 후 판매합니다.', '나이키,바람막이,재킷,남성의류,아우터');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 27, '구찌 GG 숄더백 미니 오피디아', '가방', '서울 강남구', '사용감 있음', 650000, '구찌 오피디아 GG 미니 숄더백입니다. 1년 정도 사용하였으며 정품입니다. 보증카드 및 더스트백 포함.', '구찌,Gucci,가방,숄더백,명품');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 28, '롤렉스 서브마리너 데이트 블랙다이얼', '시계/주얼리', '서울 서초구', '사용감 있음', 12500000, '롤렉스 서브마리너 데이트 블랙다이얼 2019년형입니다. 풀박스 풀페이퍼 있습니다. 정품 보증.', '롤렉스,Rolex,서브마리너,시계,명품시계');

-- 가구/인테리어
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 29, '이케아 KALLAX 책장 4x4 화이트', '수납/정리', '서울 마포구', '사용감 있음', 55000, '이케아 KALLAX 4x4 칸 책장 화이트입니다. 이사 정리로 판매합니다. 분해 가능하며 직접 가져가실 분만 구매 가능합니다.', '이케아,KALLAX,책장,수납,인테리어');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 30, '한샘 소파 3인용 패브릭 그레이', '소파/침대', '서울 강동구', '사용감 있음', 180000, '한샘 3인용 패브릭 소파 그레이입니다. 이사로 판매합니다. 직접 가져가실 분만 구매 가능합니다.', '소파,한샘,3인용소파,패브릭소파');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 31, '시디즈 T50 에어 의자 블랙 메쉬', '책상/의자', '경기 화성시', '거의새것', 320000, '시디즈 T50 에어 의자 블랙 메쉬입니다. 1년 이내 구매. 재택근무 종료로 판매합니다. 상태 매우 좋음.', '시디즈,T50,의자,사무용의자,메쉬의자');

-- 스포츠/레저
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 32, '요넥스 나노플렉스 700 배드민턴 라켓', '헬스/요가', '서울 마포구', '거의새것', 85000, '요넥스 나노플렉스 700 배드민턴 라켓입니다. 5회 미만 사용. 가방과 함께 판매합니다.', '배드민턴,요넥스,라켓,스포츠');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 21, '트렉 마린 5 로드바이크 2022 52사이즈', '자전거', '경기 과천시', '사용감 있음', 780000, '트렉 마린 5 로드바이크 2022년형 52사이즈입니다. 1년 사용. 기어 변속 정상. 타이어 교체 완료.', '자전거,로드바이크,트렉,Trek,사이클');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 22, '캠핑 체어 헬리녹스 스타일 경량 의자', '캠핑', '경기 용인시', '거의새것', 28000, '경량 폴딩 캠핑 체어입니다. 헬리녹스와 유사한 스타일이며 무게 900g입니다. 2회 사용 후 보관 중입니다.', '캠핑의자,경량의자,캠핑,폴딩체어,아웃도어');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 23, '코베아 쉘터 텐트 4인용 감성캠핑', '캠핑', '경기 양평군', '거의새것', 95000, '코베아 쉘터 텐트 4인용입니다. 2회 사용 후 보관 중입니다. 팩, 로프 모두 포함. 세탁 완료.', '텐트,캠핑,코베아,쉘터,4인용텐트');

-- 도서/음반
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 24, '해리포터 전집 양장본 1~7권 세트', '도서', '대전 유성구', '사용감 있음', 35000, '해리포터 전집 1권부터 7권까지 완전 세트입니다. 전체적으로 깨끗하며 일부 모서리 살짝 눌린 자국 있습니다.', '해리포터,전집,소설,도서,책');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 25, '2025 SQLD 자격증 교재 + 기출문제집 세트', '도서', '서울 관악구', '사용감 있음', 18000, 'SQLD 자격증 교재와 기출문제집 세트입니다. 필기 후 합격하여 판매합니다. 깔끔하게 사용했습니다.', 'SQLD,자격증,교재,도서,IT자격증');
INSERT INTO PRODUCT (PRODUCT_ID, USER_NO, PRODUCT_TITLE, SUB_CATEGORY_NAME, PRODUCT_PLACE, PRODUCT_STATE, PRODUCT_PRICE, PRODUCT_EXPLANATION, PRODUCT_KEYWORD)
VALUES (TO_CHAR(PRODUCT_ID_SEQ.NEXTVAL), 26, '방탄소년단 BTS Proof Standard Edition', 'CD/DVD', '광주 광산구', '미개봉', 22000, 'BTS Proof Standard Edition 미개봉 앨범입니다. 구매 후 미개봉 보관 중이던 제품입니다.', 'BTS,방탄소년단,Proof,앨범,CD');


-- -----------------------------------
-- 5-6. 상품 이미지 (PRODUCT_FILE) - 상품 1~30, 각 2~3장
-- -----------------------------------
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '1',  'iphone15_front.jpg',   'uuid-01-a.jpg', '/upload/productRegist/uuid-01-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '1',  'iphone15_back.jpg',    'uuid-01-b.jpg', '/upload/productRegist/uuid-01-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '1',  'iphone15_box.jpg',     'uuid-01-c.jpg', '/upload/productRegist/uuid-01-c.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '2',  'galaxy_s24_front.jpg', 'uuid-02-a.jpg', '/upload/productRegist/uuid-02-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '2',  'galaxy_s24_back.jpg',  'uuid-02-b.jpg', '/upload/productRegist/uuid-02-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '2',  'galaxy_s24_box.jpg',   'uuid-02-c.jpg', '/upload/productRegist/uuid-02-c.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '3',  'macbook_top.jpg',      'uuid-03-a.jpg', '/upload/productRegist/uuid-03-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '3',  'macbook_open.jpg',     'uuid-03-b.jpg', '/upload/productRegist/uuid-03-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '4',  'gram_main.jpg',        'uuid-04-a.jpg', '/upload/productRegist/uuid-04-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '4',  'gram_side.jpg',        'uuid-04-b.jpg', '/upload/productRegist/uuid-04-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '4',  'gram_port.jpg',        'uuid-04-c.jpg', '/upload/productRegist/uuid-04-c.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '5',  'ipad_main.jpg',        'uuid-05-a.jpg', '/upload/productRegist/uuid-05-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '5',  'ipad_side.jpg',        'uuid-05-b.jpg', '/upload/productRegist/uuid-05-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '6',  'tab_s9_main.jpg',      'uuid-06-a.jpg', '/upload/productRegist/uuid-06-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '6',  'tab_s9_box.jpg',       'uuid-06-b.jpg', '/upload/productRegist/uuid-06-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '7',  'watch_front.jpg',      'uuid-07-a.jpg', '/upload/productRegist/uuid-07-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '7',  'watch_band.jpg',       'uuid-07-b.jpg', '/upload/productRegist/uuid-07-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '8',  'tv_front.jpg',         'uuid-08-a.jpg', '/upload/productRegist/uuid-08-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '8',  'tv_side.jpg',          'uuid-08-b.jpg', '/upload/productRegist/uuid-08-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '8',  'tv_remote.jpg',        'uuid-08-c.jpg', '/upload/productRegist/uuid-08-c.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '9',  'sony_main.jpg',        'uuid-09-a.jpg', '/upload/productRegist/uuid-09-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '9',  'sony_case.jpg',        'uuid-09-b.jpg', '/upload/productRegist/uuid-09-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '10', 'dyson_main.jpg',       'uuid-10-a.jpg', '/upload/productRegist/uuid-10-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '10', 'dyson_parts.jpg',      'uuid-10-b.jpg', '/upload/productRegist/uuid-10-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '10', 'dyson_filter.jpg',     'uuid-10-c.jpg', '/upload/productRegist/uuid-10-c.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '11', 'fridge_main.jpg',      'uuid-11-a.jpg', '/upload/productRegist/uuid-11-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '11', 'fridge_open.jpg',      'uuid-11-b.jpg', '/upload/productRegist/uuid-11-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '12', 'washer_main.jpg',      'uuid-12-a.jpg', '/upload/productRegist/uuid-12-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '12', 'washer_inside.jpg',    'uuid-12-b.jpg', '/upload/productRegist/uuid-12-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '13', 'aircon_main.jpg',      'uuid-13-a.jpg', '/upload/productRegist/uuid-13-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '13', 'aircon_remote.jpg',    'uuid-13-b.jpg', '/upload/productRegist/uuid-13-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '14', 'af1_main.jpg',         'uuid-14-a.jpg', '/upload/productRegist/uuid-14-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '14', 'af1_side.jpg',         'uuid-14-b.jpg', '/upload/productRegist/uuid-14-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '14', 'af1_box.jpg',          'uuid-14-c.jpg', '/upload/productRegist/uuid-14-c.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '15', 'samba_main.jpg',       'uuid-15-a.jpg', '/upload/productRegist/uuid-15-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '15', 'samba_side.jpg',       'uuid-15-b.jpg', '/upload/productRegist/uuid-15-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '16', 'nb992_main.jpg',       'uuid-16-a.jpg', '/upload/productRegist/uuid-16-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '16', 'nb992_top.jpg',        'uuid-16-b.jpg', '/upload/productRegist/uuid-16-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '17', 'techfleece_front.jpg', 'uuid-17-a.jpg', '/upload/productRegist/uuid-17-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '17', 'techfleece_back.jpg',  'uuid-17-b.jpg', '/upload/productRegist/uuid-17-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '17', 'techfleece_tag.jpg',   'uuid-17-c.jpg', '/upload/productRegist/uuid-17-c.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '18', 'jacket_front.jpg',     'uuid-18-a.jpg', '/upload/productRegist/uuid-18-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '18', 'jacket_back.jpg',      'uuid-18-b.jpg', '/upload/productRegist/uuid-18-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '19', 'gucci_main.jpg',       'uuid-19-a.jpg', '/upload/productRegist/uuid-19-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '19', 'gucci_inside.jpg',     'uuid-19-b.jpg', '/upload/productRegist/uuid-19-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '19', 'gucci_dust.jpg',       'uuid-19-c.jpg', '/upload/productRegist/uuid-19-c.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '20', 'rolex_main.jpg',       'uuid-20-a.jpg', '/upload/productRegist/uuid-20-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '20', 'rolex_dial.jpg',       'uuid-20-b.jpg', '/upload/productRegist/uuid-20-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '20', 'rolex_box.jpg',        'uuid-20-c.jpg', '/upload/productRegist/uuid-20-c.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '21', 'kallax_main.jpg',      'uuid-21-a.jpg', '/upload/productRegist/uuid-21-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '21', 'kallax_detail.jpg',    'uuid-21-b.jpg', '/upload/productRegist/uuid-21-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '22', 'sofa_main.jpg',        'uuid-22-a.jpg', '/upload/productRegist/uuid-22-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '22', 'sofa_angle.jpg',       'uuid-22-b.jpg', '/upload/productRegist/uuid-22-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '22', 'sofa_fabric.jpg',      'uuid-22-c.jpg', '/upload/productRegist/uuid-22-c.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '23', 'sidiz_main.jpg',       'uuid-23-a.jpg', '/upload/productRegist/uuid-23-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '23', 'sidiz_side.jpg',       'uuid-23-b.jpg', '/upload/productRegist/uuid-23-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '24', 'racket_main.jpg',      'uuid-24-a.jpg', '/upload/productRegist/uuid-24-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '24', 'racket_bag.jpg',       'uuid-24-b.jpg', '/upload/productRegist/uuid-24-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '25', 'bike_main.jpg',        'uuid-25-a.jpg', '/upload/productRegist/uuid-25-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '25', 'bike_gear.jpg',        'uuid-25-b.jpg', '/upload/productRegist/uuid-25-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '25', 'bike_wheel.jpg',       'uuid-25-c.jpg', '/upload/productRegist/uuid-25-c.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '26', 'chair_main.jpg',       'uuid-26-a.jpg', '/upload/productRegist/uuid-26-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '26', 'chair_fold.jpg',       'uuid-26-b.jpg', '/upload/productRegist/uuid-26-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '27', 'tent_main.jpg',        'uuid-27-a.jpg', '/upload/productRegist/uuid-27-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '27', 'tent_inside.jpg',      'uuid-27-b.jpg', '/upload/productRegist/uuid-27-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '27', 'tent_pack.jpg',        'uuid-27-c.jpg', '/upload/productRegist/uuid-27-c.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '28', 'hp_books_main.jpg',    'uuid-28-a.jpg', '/upload/productRegist/uuid-28-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '28', 'hp_books_spine.jpg',   'uuid-28-b.jpg', '/upload/productRegist/uuid-28-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '29', 'sqld_main.jpg',        'uuid-29-a.jpg', '/upload/productRegist/uuid-29-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '29', 'sqld_inside.jpg',      'uuid-29-b.jpg', '/upload/productRegist/uuid-29-b.jpg', 0);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '30', 'bts_proof_main.jpg',   'uuid-30-a.jpg', '/upload/productRegist/uuid-30-a.jpg', 1);
INSERT INTO PRODUCT_FILE (FILE_ID, PRODUCT_ID, ORIGINAL_NAME, SAVED_NAME, FILE_PATH, IS_MAIN) VALUES (PRODUCT_FILE_SEQ.NEXTVAL, '30', 'bts_proof_cd.jpg',     'uuid-30-b.jpg', '/upload/productRegist/uuid-30-b.jpg', 0);


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
