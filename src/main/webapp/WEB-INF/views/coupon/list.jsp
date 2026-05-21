<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/coupon/couponEvent.css"/>

<div class="coupon-page">

  <%-- ===== HERO BANNER ===== --%>
  <div class="coupon-hero">
    <div class="coupon-hero-circles">
      <div class="coupon-hero-circle"></div>
      <div class="coupon-hero-circle"></div>
      <div class="coupon-hero-circle"></div>
      <div class="coupon-hero-circle"></div>
    </div>
    <div class="coupon-hero-content">
      <div class="coupon-hero-badge">LIMITED OFFER</div>
      <ion-icon name="ticket-outline" class="coupon-hero-icon"></ion-icon>
      <h1 class="coupon-hero-title">쿠폰 이벤트</h1>
      <p class="coupon-hero-sub">한정 수량 쿠폰! 지금 바로 받고 특별한 혜택을 누려보세요</p>
    </div>
  </div>

  <%-- ===== COUPON LIST ===== --%>
  <div class="coupon-content">

    <%-- 비로그인 안내 --%>
    <c:if test="${empty sessionScope.loginUser}">
      <div class="coupon-login-notice">
        <ion-icon name="information-circle-outline"></ion-icon>
        <span>쿠폰을 받으려면 <a href="<%=request.getContextPath()%>/login">로그인</a>이 필요합니다.</span>
      </div>
    </c:if>

    <div class="coupon-section-header">
      <div class="coupon-section-title">
        <ion-icon name="pricetag-outline"></ion-icon>
        진행 중인 쿠폰
        <span class="coupon-section-count">${fn:length(coupons)}개</span>
      </div>
    </div>

    <%-- 쿠폰 없음 --%>
    <c:if test="${empty coupons}">
      <div class="coupon-empty">
        <ion-icon name="ticket-outline"></ion-icon>
        <p>현재 진행 중인 쿠폰 이벤트가 없습니다.</p>
      </div>
    </c:if>

    <%-- 쿠폰 목록 --%>
    <c:forEach var="coupon" items="${coupons}">
      <c:set var="remaining"     value="${remainingCounts[coupon.couponId]}" />
      <c:set var="alreadyIssued" value="${issuedIds.contains(coupon.couponId)}" />
      <c:set var="isExpired"     value="${coupon.endDate.before(today)}" />
      <c:set var="isUpcoming"    value="${coupon.startDate.after(today)}" />
      <c:set var="isSoldOut"     value="${remaining != null && remaining <= 0}" />

      <c:choose>
        <c:when test="${alreadyIssued}"> <c:set var="ticketState" value="state-issued"   /> </c:when>
        <c:when test="${isExpired}">     <c:set var="ticketState" value="state-expired"  /> </c:when>
        <c:when test="${isUpcoming}">    <c:set var="ticketState" value="state-upcoming" /> </c:when>
        <c:when test="${isSoldOut}">     <c:set var="ticketState" value="state-soldout"  /> </c:when>
        <c:otherwise>                   <c:set var="ticketState" value="state-active"   /> </c:otherwise>
      </c:choose>

      <%-- 잔여 비율 (0~100) --%>
      <c:set var="pct" value="0" />
      <c:if test="${coupon.totalCount > 0 && remaining != null}">
        <c:set var="pct" value="${remaining * 100 / coupon.totalCount}" />
      </c:if>

      <div class="coupon-ticket ${ticketState}"
           data-coupon-id="${coupon.couponId}"
           data-state="${ticketState}">

        <%-- Left stub --%>
        <div class="coupon-stub">
          <c:choose>
            <c:when test="${alreadyIssued}">
              <ion-icon name="checkmark-circle-outline" class="coupon-stub-icon"></ion-icon>
              <span class="coupon-stub-label">수령 완료</span>
            </c:when>
            <c:when test="${isExpired}">
              <ion-icon name="ban-outline" class="coupon-stub-icon"></ion-icon>
              <span class="coupon-stub-label">기간 만료</span>
            </c:when>
            <c:when test="${isUpcoming}">
              <ion-icon name="time-outline" class="coupon-stub-icon"></ion-icon>
              <span class="coupon-stub-label">오픈 예정</span>
            </c:when>
            <c:when test="${isSoldOut}">
              <ion-icon name="alert-circle-outline" class="coupon-stub-icon"></ion-icon>
              <span class="coupon-stub-label">수량 소진</span>
            </c:when>
            <c:otherwise>
              <ion-icon name="gift-outline" class="coupon-stub-icon"></ion-icon>
              <span class="coupon-stub-label">쿠폰 받기</span>
            </c:otherwise>
          </c:choose>
          <div class="coupon-notch-top"></div>
          <div class="coupon-notch-bottom"></div>
        </div>

        <%-- Dashed divider --%>
        <div class="coupon-divider"></div>

        <%-- Right body --%>
        <div class="coupon-body">
          <div class="coupon-body-top">
            <div class="coupon-name">
              <c:out value="${coupon.name}" />
              <c:choose>
                <c:when test="${alreadyIssued}">
                  <span class="coupon-status-badge badge-issued">수령완료</span>
                </c:when>
                <c:when test="${isExpired}">
                  <span class="coupon-status-badge badge-expired">기간만료</span>
                </c:when>
                <c:when test="${isUpcoming}">
                  <span class="coupon-status-badge badge-upcoming">오픈예정</span>
                </c:when>
                <c:when test="${isSoldOut}">
                  <span class="coupon-status-badge badge-soldout">수량소진</span>
                </c:when>
                <c:otherwise>
                  <span class="coupon-status-badge badge-active">진행중</span>
                </c:otherwise>
              </c:choose>
            </div>

            <div class="coupon-valid">
              <ion-icon name="calendar-outline"></ion-icon>
              <fmt:formatDate value="${coupon.startDate}" pattern="yyyy.MM.dd" />
              &nbsp;~&nbsp;
              <fmt:formatDate value="${coupon.endDate}"   pattern="yyyy.MM.dd" />
            </div>

            <%-- Progress bar --%>
            <div class="coupon-progress-info">
              <span>
                잔여 수량
                <c:choose>
                  <c:when test="${pct <= 20}">
                    <strong class="remaining-low">${remaining}장</strong>
                  </c:when>
                  <c:otherwise>
                    <strong class="remaining-strong">${remaining}장</strong>
                  </c:otherwise>
                </c:choose>
                / 총 ${coupon.totalCount}장
              </span>
              <span>${pct}%</span>
            </div>
            <div class="coupon-progress-track">
              <div class="coupon-progress-fill ${pct <= 20 ? 'fill-low' : ''}"
                   style="width: ${pct}%"></div>
            </div>
          </div>

          <div class="coupon-body-bottom">
            <c:choose>
              <c:when test="${alreadyIssued}">
                <button class="coupon-receive-btn btn-issued" disabled>
                  <ion-icon name="checkmark-outline" style="vertical-align:middle;margin-right:4px;"></ion-icon>수령완료
                </button>
              </c:when>
              <c:when test="${isExpired || isSoldOut || isUpcoming}">
                <button class="coupon-receive-btn btn-disabled" disabled>
                  <c:choose>
                    <c:when test="${isExpired}">기간 만료</c:when>
                    <c:when test="${isSoldOut}">수량 소진</c:when>
                    <c:otherwise>오픈 예정</c:otherwise>
                  </c:choose>
                </button>
              </c:when>
              <c:otherwise>
                <button class="coupon-receive-btn" onclick="receiveCoupon(this, ${coupon.couponId})">
                  <ion-icon name="gift-outline" style="vertical-align:middle;margin-right:4px;"></ion-icon>쿠폰 받기
                </button>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>
    </c:forEach>

  </div><%-- /.coupon-content --%>
</div><%-- /.coupon-page --%>

<%-- ===== TOAST ===== --%>
<div id="couponToast" class="coupon-toast toast-success">
  <ion-icon name="checkmark-circle-outline"></ion-icon>
  <span id="couponToastMsg"></span>
</div>

<%-- ===== LOGIN MODAL ===== --%>
<div id="couponModalOverlay" class="coupon-modal-overlay" onclick="closeLoginModal(event)">
  <div class="coupon-modal">
    <ion-icon name="lock-closed-outline" class="coupon-modal-icon"></ion-icon>
    <div class="coupon-modal-title">로그인이 필요해요</div>
    <div class="coupon-modal-desc">쿠폰을 받으려면 로그인 후 이용해주세요.</div>
    <div class="coupon-modal-actions">
      <button class="coupon-modal-btn-primary"
              onclick="location.href='<%=request.getContextPath()%>/login'">
        로그인하기
      </button>
      <button class="coupon-modal-btn-cancel" onclick="closeLoginModal()">취소</button>
    </div>
  </div>
</div>

<script>
(function () {
    var ctx     = '<%=request.getContextPath()%>';
    var loggedIn = ${ not empty sessionScope.loginUser ? 'true' : 'false' };

    /* ── 진행바 애니메이션 (DOM 로드 후 실행) ── */
    window.addEventListener('load', function () {
        document.querySelectorAll('.coupon-progress-fill').forEach(function (el) {
            var w = el.style.width;
            el.style.width = '0%';
            setTimeout(function () { el.style.width = w; }, 120);
        });
    });

    /* ── 쿠폰 받기 ── */
    window.receiveCoupon = function (btn, couponId) {
        if (!loggedIn) {
            document.getElementById('couponModalOverlay').classList.add('modal-show');
            return;
        }

        btn.disabled = true;
        btn.innerHTML = '<ion-icon name="hourglass-outline" style="vertical-align:middle;margin-right:4px;"></ion-icon>처리중...';

        $.ajax({
            url : ctx + '/coupon/' + couponId + '/issue',
            type: 'POST',
            success: function (res) {
                btn.classList.add('btn-success', 'btn-issued');
                btn.innerHTML = '<ion-icon name="checkmark-outline" style="vertical-align:middle;margin-right:4px;"></ion-icon>수령완료';
                var ticket = btn.closest('.coupon-ticket');
                ticket.classList.remove('state-active');
                ticket.classList.add('state-issued');
                ticket.querySelector('.coupon-stub').innerHTML =
                    '<ion-icon name="checkmark-circle-outline" class="coupon-stub-icon"></ion-icon>' +
                    '<span class="coupon-stub-label">수령 완료</span>';
                showToast('success', '쿠폰이 발급되었습니다!');
            },
            error: function (xhr) {
                btn.disabled = false;
                btn.innerHTML = '<ion-icon name="gift-outline" style="vertical-align:middle;margin-right:4px;"></ion-icon>쿠폰 받기';
                var msg = (xhr.responseJSON && xhr.responseJSON.message)
                    ? xhr.responseJSON.message
                    : '쿠폰 발급에 실패했습니다.';
                showToast('error', msg);
            }
        });
    };

    /* ── 토스트 ── */
    function showToast(type, message) {
        var toast = document.getElementById('couponToast');
        var msgEl = document.getElementById('couponToastMsg');
        toast.className = 'coupon-toast toast-' + type;
        msgEl.textContent = message;
        toast.querySelector('ion-icon').setAttribute(
            'name', type === 'success' ? 'checkmark-circle-outline' : 'close-circle-outline'
        );
        toast.classList.add('toast-show');
        setTimeout(function () { toast.classList.remove('toast-show'); }, 3000);
    }

    /* ── 로그인 모달 닫기 ── */
    window.closeLoginModal = function (e) {
        if (!e || e.target === document.getElementById('couponModalOverlay')) {
            document.getElementById('couponModalOverlay').classList.remove('modal-show');
        }
    };
})();
</script>

<%@ include file="../common/footer.jsp"%>
