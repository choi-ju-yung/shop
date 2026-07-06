<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/user/enrollmember.css"/>

<c:if test="${not empty errorMessage}">
  <script>alert("${errorMessage}");</script>
</c:if>

<div class="registSection">
  <div class="registCard">

    <div class="registHeader">
      <img src="<%=request.getContextPath()%>/images/common/logo.svg" alt="니꺼내꺼" class="brandLogoImg">
      <h2>회원가입</h2>
      <p>니꺼내꺼와 함께 안전한 중고거래를 시작하세요</p>
    </div>

    <form action="<%=request.getContextPath()%>/regist/nomalInsert" method="post"
          onsubmit="return fn_registEnrollMember();">
      <input type="hidden" id="userIp" value="${userIp}">

      <%-- 이메일 --%>
      <div class="registGroup">
        <label>이메일 <span class="req">*</span></label>
        <div class="registInputRow">
          <input class="registInput" type="email" id="email" name="email"
                 placeholder="이메일 주소 입력" autocomplete="email">
          <button type="button" class="registInlineBtn" id="authEmail">인증 전송</button>
        </div>
        <span class="registMsg" id="emailMessageId"></span>
      </div>

      <%-- 인증번호 --%>
      <div class="registGroup">
        <label>인증번호</label>
        <div class="registInputRow">
          <input class="registInput" type="text" id="cNumber"
                 placeholder="인증번호 6자리" autocomplete="off">
          <button type="button" class="registInlineBtn" id="cBtn">확인</button>
        </div>
        <span class="registMsg" id="timerMessageId"></span>
      </div>

      <%-- 아이디 --%>
      <div class="registGroup">
        <label>아이디 <span class="req">*</span></label>
        <input class="registInput" type="text" id="userId_" name="loginId"
               placeholder="영문/숫자 4~20자" autocomplete="username">
        <span class="registMsg" id="idDupMessageId"></span>
      </div>

      <%-- 비밀번호 --%>
      <div class="registGroup">
        <label>비밀번호 <span class="req">*</span></label>
        <input class="registInput" type="password" id="password" name="password"
               placeholder="8자 이상 영문+숫자+특수문자" autocomplete="new-password">
      </div>

      <%-- 비밀번호 확인 --%>
      <div class="registGroup">
        <label>비밀번호 확인 <span class="req">*</span></label>
        <input class="registInput" type="password" id="memberPwConfirm"
               placeholder="비밀번호 재입력" autocomplete="new-password">
        <span class="registMsg" id="pwMessage"></span>
      </div>

      <%-- 닉네임 --%>
      <div class="registGroup">
        <label>닉네임 <span class="req">*</span></label>
        <div class="registInputRow">
          <input class="registInput" type="text" id="nicknameId" name="nickname"
                 placeholder="2~12자 (한글/영문/숫자)" maxlength="12">
          <button type="button" class="registInlineBtn" id="nicknameDupBtn">중복확인</button>
        </div>
        <span class="registMsg" id="nicknameMessage"></span>
      </div>

      <%-- 약관 동의 --%>
      <div class="termsSection">
        <div class="termsAllRow">
          <label for="selectall">전체 동의</label>
          <input class="termsCheck" type="checkbox" id="selectall" name="selectall"
                 onclick="selectAll(this)">
        </div>
        <div class="termsRow">
          <label for="agree1">
            <span class="req-badge">필수</span> 이용약관 동의
          </label>
          <div class="termsRowRight">
            <button type="button" class="termsDetailBtn" onclick="fn_viewDetail1()">보기</button>
            <input class="termsCheck" type="checkbox" id="agree1" name="agree"
                   onclick="checkSelectAll()" required>
          </div>
        </div>
        <div class="termsRow">
          <label for="agree2">
            <span class="req-badge">필수</span> 개인정보 수집·이용 동의
          </label>
          <div class="termsRowRight">
            <button type="button" class="termsDetailBtn" onclick="fn_viewDetail2()">보기</button>
            <input class="termsCheck" type="checkbox" id="agree2" name="agree"
                   onclick="checkSelectAll()" required>
          </div>
        </div>
        <div class="termsRow">
          <label for="agree3">
            <span class="opt-badge">선택</span> 마케팅 수신 동의 (이메일)
          </label>
          <div class="termsRowRight">
            <button type="button" class="termsDetailBtn" onclick="fn_viewDetail3()">보기</button>
            <input class="termsCheck" type="checkbox" id="agree3" name="agree"
                   onclick="checkSelectAll()">
          </div>
        </div>
        <div class="termsRow">
          <label for="agree4">
            <span class="opt-badge">선택</span> 마케팅 수신 동의 (SMS)
          </label>
          <div class="termsRowRight">
            <button type="button" class="termsDetailBtn" onclick="fn_viewDetail4()">보기</button>
            <input class="termsCheck" type="checkbox" id="agree4" name="agree"
                   onclick="checkSelectAll()">
          </div>
        </div>
      </div>

      <button type="submit" class="registSubmitBtn">회원가입</button>

    </form>

    <p class="registLoginLink">
      이미 계정이 있으신가요? <a href="<%=request.getContextPath()%>/login">로그인</a>
    </p>

  </div>
</div>

<script src="<%=request.getContextPath()%>/js/user/nomalEnrollmember.js"></script>
<%@ include file="../common/footer.jsp"%>
