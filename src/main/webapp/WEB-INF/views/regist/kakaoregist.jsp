<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/user/enrollmember.css"/>

<div class="registSection">
  <div class="registCard">

    <div class="registHeader">
      <img src="<%=request.getContextPath()%>/images/common/logo.svg" alt="니꺼내꺼" class="brandLogoImg">
      <h2>카카오 회원가입</h2>
      <p>추가 정보를 입력하고 가입을 완료하세요</p>
    </div>

    <div style="text-align:center;margin-bottom:20px;">
      <span class="kakaoBadge">
        <ion-icon name="logo-apple" style="display:none;"></ion-icon>
        🟡 카카오 계정으로 가입 중
      </span>
    </div>

    <form action="<%=request.getContextPath()%>/regist/insert" method="post"
          onsubmit="return fn_registEnrollMember();">
      <input type="hidden" id="id" name="oauthId" value="${oauthId}">

      <%-- 이메일 (카카오에서 가져온 값, 읽기전용) --%>
      <div class="registGroup">
        <label>이메일</label>
        <input class="registInput" type="email" id="email" name="email"
               value="${email}" readonly>
        <span class="registMsg ok">카카오 계정 이메일이 자동으로 입력되었습니다</span>
      </div>

      <%-- 이름 (카카오 닉네임, 읽기전용) --%>
      <div class="registGroup">
        <label>이름</label>
        <input class="registInput" type="text" id="username" name="username"
               value="${nickname}" readonly>
        <span class="registMsg ok">카카오 프로필 이름이 자동으로 입력되었습니다</span>
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

      <button type="submit" class="registSubmitBtn">가입 완료</button>

    </form>

  </div>
</div>

<script src="<%=request.getContextPath()%>/js/user/kakaoEnrollmember.js"></script>
<%@ include file="../common/footer.jsp"%>
