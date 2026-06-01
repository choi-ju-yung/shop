<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="../common/header.jsp"%>
<style>
.detail-page { max-width: 640px; margin: 0 auto; padding: 40px 20px 80px; }

.detail-back {
  display: inline-flex; align-items: center; gap: 6px;
  font-size: 14px; color: #6b7280; text-decoration: none;
  margin-bottom: 28px;
  transition: color .15s;
}
.detail-back:hover { color: #20c997; }

.detail-card {
  background: #fff;
  border-radius: 20px;
  border: 1.5px solid #e5e7eb;
  overflow: hidden;
  box-shadow: 0 4px 24px rgba(0,0,0,.06);
}

.detail-banner {
  background: linear-gradient(135deg, #134e4a, #20c997);
  padding: 56px 40px;
  text-align: center;
  position: relative;
}
.detail-banner ion-icon { font-size: 64px; color: rgba(255,255,255,.9); display: block; margin: 0 auto 16px; }
.detail-banner h2 { font-size: 24px; font-weight: 800; color: #fff; }
.detail-status-badge {
  display: inline-block; margin-top: 12px;
  font-size: 12px; font-weight: 700; padding: 4px 14px; border-radius: 20px;
}
.badge-active   { background: #d1fae5; color: #065f46; }
.badge-issued   { background: #e0e7ff; color: #3730a3; }
.badge-soldout  { background: #fee2e2; color: #991b1b; }
.badge-expired  { background: rgba(255,255,255,.2); color: #fff; }
.badge-upcoming { background: #fef3c7; color: #92400e; }

.detail-body { padding: 32px 32px 36px; }

.detail-info-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: 14px 0; border-bottom: 1px solid #f3f4f6;
  font-size: 14px;
}
.detail-info-row:last-of-type { border-bottom: none; }
.detail-info-label { color: #6b7280; display: flex; align-items: center; gap: 6px; }
.detail-info-value { font-weight: 600; color: #1a1a1a; }
.remaining-low { color: #ef4444; }

.detail-progress-wrap { margin: 20px 0 28px; }
.detail-progress-label {
  display: flex; justify-content: space-between;
  font-size: 13px; color: #6b7280; margin-bottom: 8px;
}
.detail-progress-track {
  height: 10px; background: #e5e7eb; border-radius: 6px; overflow: hidden;
}
.detail-progress-fill {
  height: 100%; background: #20c997; border-radius: 6px;
  transition: width .7s ease;
}
.detail-progress-fill.fill-low { background: #f87171; }

.detail-btn {
  width: 100%; padding: 16px;
  font-size: 16px; font-weight: 700; font-family: inherit;
  border: none; border-radius: 12px; cursor: pointer;
  display: flex; align-items: center; justify-content: center; gap: 8px;
  transition: background .18s;
}
.detail-btn-active   { background: #20c997; color: #fff; }
.detail-btn-active:hover { background: #17a589; }
.detail-btn-disabled { background: #f3f4f6; color: #9ca3af; cursor: not-allowed; }
.detail-btn-issued   { background: #e0e7ff; color: #3730a3; cursor: not-allowed; }

.detail-login-notice {
  background: #f0fdf4; border: 1.5px solid #6ee7b7;
  border-radius: 10px; padding: 14px 16px;
  font-size: 13px; color: #065f46;
  display: flex; align-items: center; gap: 8px;
  margin-bottom: 16px;
}

.coupon-toast {
  position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%) translateY(20px);
  background: #1a1a1a; color: #fff;
  padding: 12px 24px; border-radius: 50px;
  font-size: 14px; font-weight: 600;
  display: flex; align-items: center; gap: 8px;
  opacity: 0; transition: all .3s; pointer-events: none; z-index: 9999;
}
.toast-success { background: #059669; }
.toast-error   { background: #dc2626; }
.toast-show    { opacity: 1; transform: translateX(-50%) translateY(0); }

.coupon-modal-overlay {
  display: none; position: fixed; inset: 0;
  background: rgba(0,0,0,.5); z-index: 9998;
  align-items: center; justify-content: center;
}
.coupon-modal-overlay.modal-show { display: flex; }
.coupon-modal {
  background: #fff; border-radius: 20px; padding: 40px 32px;
  text-align: center; max-width: 340px; width: 90%;
}
.coupon-modal-icon { font-size: 48px; color: #20c997; display: block; margin-bottom: 12px; }
.coupon-modal-title { font-size: 18px; font-weight: 700; margin-bottom: 8px; }
.coupon-modal-desc  { font-size: 14px; color: #6b7280; margin-bottom: 24px; }
.coupon-modal-actions { display: flex; gap: 10px; }
.coupon-modal-btn-primary {
  flex: 1; padding: 12px; background: #20c997; color: #fff;
  border: none; border-radius: 10px; font-size: 14px; font-weight: 700;
  cursor: pointer; font-family: inherit;
}
.coupon-modal-btn-cancel {
  flex: 1; padding: 12px; background: #f3f4f6; color: #374151;
  border: none; border-radius: 10px; font-size: 14px; font-weight: 600;
  cursor: pointer; font-family: inherit;
}
</style>

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
