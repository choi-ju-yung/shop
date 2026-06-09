<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/coupon/couponDetail.css" />

<section>
<div class="detail-page">

  <a class="detail-back" href="<%=request.getContextPath()%>/coupon/list">
    <ion-icon name="arrow-back-outline"></ion-icon> 이벤트 목록으로
  </a>

  <c:set var="isExpired"  value="${coupon.endDate.before(today)}" />
  <c:set var="isUpcoming" value="${coupon.startDate.after(today)}" />
  <c:set var="isSoldOut"  value="${remaining != null && remaining <= 0}" />
  <c:set var="pct"        value="0" />
  <c:if test="${coupon.totalCount > 0 && remaining != null}">
    <c:set var="pct" value="${remaining * 100 / coupon.totalCount}" />
  </c:if>

  <div class="detail-card">
    <div class="detail-banner">
      <ion-icon name="gift-outline"></ion-icon>
      <h2><c:out value="${coupon.name}" /></h2>
      <c:choose>
        <c:when test="${alreadyIssued}"> <span class="detail-status-badge badge-issued">수령완료</span> </c:when>
        <c:when test="${isExpired}">     <span class="detail-status-badge badge-expired">기간만료</span> </c:when>
        <c:when test="${isUpcoming}">    <span class="detail-status-badge badge-upcoming">오픈예정</span> </c:when>
        <c:when test="${isSoldOut}">     <span class="detail-status-badge badge-soldout">수량소진</span> </c:when>
        <c:otherwise>                   <span class="detail-status-badge badge-active">진행중</span> </c:otherwise>
      </c:choose>
    </div>

    <div class="detail-body">

      <div class="detail-info-row">
        <span class="detail-info-label"><ion-icon name="calendar-outline"></ion-icon> 이벤트 기간</span>
        <span class="detail-info-value">
          <fmt:formatDate value="${coupon.startDate}" pattern="yyyy.MM.dd" /> ~
          <fmt:formatDate value="${coupon.endDate}"   pattern="yyyy.MM.dd" />
        </span>
      </div>
      <div class="detail-info-row">
        <span class="detail-info-label"><ion-icon name="people-outline"></ion-icon> 총 수량</span>
        <span class="detail-info-value">${coupon.totalCount}장</span>
      </div>
      <div class="detail-info-row">
        <span class="detail-info-label"><ion-icon name="ticket-outline"></ion-icon> 잔여 수량</span>
        <span class="detail-info-value ${pct <= 20 ? 'remaining-low' : ''}">${remaining}장</span>
      </div>

      <div class="detail-progress-wrap">
        <div class="detail-progress-label">
          <span>잔여 수량</span>
          <span>${pct}%</span>
        </div>
        <div class="detail-progress-track">
          <div class="detail-progress-fill ${pct <= 20 ? 'fill-low' : ''}"
               style="width:0%" data-width="${pct}%"></div>
        </div>
      </div>

      <c:if test="${empty sessionScope.loginUser}">
        <div class="detail-login-notice">
          <ion-icon name="information-circle-outline"></ion-icon>
          쿠폰을 받으려면 <a href="<%=request.getContextPath()%>/login" style="color:#059669;font-weight:700;">로그인</a>이 필요합니다.
        </div>
      </c:if>

      <c:choose>
        <c:when test="${alreadyIssued}">
          <button class="detail-btn detail-btn-issued" disabled>
            <ion-icon name="checkmark-outline"></ion-icon> 수령 완료
          </button>
        </c:when>
        <c:when test="${isExpired}">
          <button class="detail-btn detail-btn-disabled" disabled>기간 만료</button>
        </c:when>
        <c:when test="${isUpcoming}">
          <button class="detail-btn detail-btn-disabled" disabled>오픈 예정</button>
        </c:when>
        <c:when test="${isSoldOut}">
          <button class="detail-btn detail-btn-disabled" disabled>수량 소진</button>
        </c:when>
        <c:otherwise>
          <button class="detail-btn detail-btn-active" id="receiveBtn"
                  onclick="receiveCoupon(${coupon.couponId})">
            <ion-icon name="gift-outline"></ion-icon> 쿠폰 받기
          </button>
        </c:otherwise>
      </c:choose>

    </div>
  </div>
</div>
</section>

<div id="couponToast" class="coupon-toast">
  <ion-icon name="checkmark-circle-outline"></ion-icon>
  <span id="couponToastMsg"></span>
</div>

<div id="couponModalOverlay" class="coupon-modal-overlay" onclick="closeLoginModal(event)">
  <div class="coupon-modal">
    <ion-icon name="lock-closed-outline" class="coupon-modal-icon"></ion-icon>
    <div class="coupon-modal-title">로그인이 필요해요</div>
    <div class="coupon-modal-desc">쿠폰을 받으려면 로그인 후 이용해주세요.</div>
    <div class="coupon-modal-actions">
      <button class="coupon-modal-btn-primary"
              onclick="location.href='<%=request.getContextPath()%>/login'">로그인하기</button>
      <button class="coupon-modal-btn-cancel" onclick="closeLoginModal()">취소</button>
    </div>
  </div>
</div>

<script>
(function() {
  var ctx      = '<%=request.getContextPath()%>';
  var loggedIn = ${ not empty sessionScope.loginUser ? 'true' : 'false' };

  window.addEventListener('load', function() {
    var fill = document.querySelector('.detail-progress-fill');
    if (fill) setTimeout(function() { fill.style.width = fill.dataset.width; }, 120);
  });

  window.receiveCoupon = function(couponId) {
    if (!loggedIn) {
      document.getElementById('couponModalOverlay').classList.add('modal-show');
      return;
    }
    var btn = document.getElementById('receiveBtn');
    btn.disabled = true;
    btn.innerHTML = '<ion-icon name="hourglass-outline"></ion-icon> 처리중...';

    $.ajax({
      url : ctx + '/coupon/' + couponId + '/issue',
      type: 'POST',
      success: function() {
        btn.className = 'detail-btn detail-btn-issued';
        btn.innerHTML = '<ion-icon name="checkmark-outline"></ion-icon> 수령 완료';
        showToast('success', '쿠폰이 발급되었습니다!');
      },
      error: function(xhr) {
        btn.disabled = false;
        btn.innerHTML = '<ion-icon name="gift-outline"></ion-icon> 쿠폰 받기';
        var msg = xhr.responseJSON ? xhr.responseJSON.message : '쿠폰 발급에 실패했습니다.';
        showToast('error', msg);
      }
    });
  };

  function showToast(type, message) {
    var toast = document.getElementById('couponToast');
    toast.className = 'coupon-toast toast-' + type;
    document.getElementById('couponToastMsg').textContent = message;
    toast.querySelector('ion-icon').setAttribute('name',
      type === 'success' ? 'checkmark-circle-outline' : 'close-circle-outline');
    toast.classList.add('toast-show');
    setTimeout(function() { toast.classList.remove('toast-show'); }, 3000);
  }

  window.closeLoginModal = function(e) {
    if (!e || e.target === document.getElementById('couponModalOverlay')) {
      document.getElementById('couponModalOverlay').classList.remove('modal-show');
    }
  };
})();
</script>

<%@ include file="../common/footer.jsp"%>
