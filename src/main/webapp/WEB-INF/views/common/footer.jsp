<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/footer.css"/>

<footer class="site-footer">

  <%-- 상단 링크 바 --%>
  <div class="footer-top">
    <div class="footer-top-inner">
      <a href="#" class="highlight">공지사항</a>
      <a href="#">이용약관</a>
      <a href="#">개인정보처리방침</a>
      <a href="#">청소년보호정책</a>
      <a href="#">분쟁처리절차</a>
      <a href="#">게시글 수집 및 이용 안내</a>
    </div>
  </div>

  <%-- 본문 --%>
  <div class="footer-body">

    <%-- 브랜드 + 사업자 정보 --%>
    <div class="footer-brand">
      <a class="footer-logo" href="<%=request.getContextPath()%>/main">
        <img src="<%=request.getContextPath()%>/images/common/logo.svg"
             onerror="this.style.display='none'"
             alt="니꺼내꺼">
        <span class="footer-logo-text">니꺼내꺼</span>
      </a>
      <p class="footer-desc">
        이웃 간의 신뢰를 기반으로 한 중고 거래 플랫폼.<br>
        안전하고 따뜻한 거래 문화를 만들어갑니다.
      </p>
      <div class="footer-biz">
        <div>
          <span>상호명 : 니꺼내꺼</span>
          <span class="sep">|</span>
          <span>대표 : 최지영</span>
          <span class="sep">|</span>
          <span>사업자등록번호 : 000-00-00000</span>
        </div>
        <div>
          <span>통신판매업 신고번호 : 제2026-서울-00000호</span>
        </div>
        <div>
          <span>주소 : 서울특별시 강남구 테헤란로 123</span>
        </div>
        <div>
          <span>이메일 : support@nikeona.kr</span>
          <span class="sep">|</span>
          <span>대표번호 : 1588-0000</span>
        </div>
        <div style="margin-top:6px;font-size:11.5px;color:#444;line-height:1.6;">
          니꺼내꺼는 통신판매중개자로서 거래 당사자가 아니며, 판매회원과 구매회원 간의 거래 정보 및 거래에 관여하지 않고 어떠한 의무와 책임도 부담하지 않습니다.
        </div>
      </div>
    </div>

    <%-- 고객센터 + 소셜 --%>
    <div class="footer-right">
      <div>
        <div class="footer-cs-title">고객센터</div>
        <div class="footer-cs-time">운영시간 : 09~18시 (주말/공휴일 제외)</div>
        <div class="footer-cs-btns">
          <a href="#" class="btn-primary">
            <ion-icon name="chatbubble-ellipses-outline"></ion-icon>
            1:1 문의
          </a>
          <a href="#" class="btn-outline">
            <ion-icon name="help-circle-outline"></ion-icon>
            자주 묻는 질문
          </a>
          <a href="#" class="btn-outline">
            <ion-icon name="megaphone-outline"></ion-icon>
            공지사항
          </a>
        </div>
      </div>
      <div>
        <div class="footer-cs-title" style="margin-bottom:10px;">SNS</div>
        <div class="footer-social">
          <a href="https://github.com/choijuyung" target="_blank" title="GitHub">
            <ion-icon name="logo-github"></ion-icon>
          </a>
          <a href="#" title="Instagram">
            <ion-icon name="logo-instagram"></ion-icon>
          </a>
          <a href="#" title="YouTube">
            <ion-icon name="logo-youtube"></ion-icon>
          </a>
        </div>
      </div>
    </div>

  </div>

  <%-- 카피라이트 --%>
  <div class="footer-bottom">
    <strong>© 2026 니꺼내꺼.</strong> All rights reserved. &nbsp;|&nbsp; Designed &amp; Developed by <strong>choijuyung</strong>
  </div>

</footer>

</body>
</html>
