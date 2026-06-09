<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/coupon/couponList.css" />

<section>
<div class="event-page">

  <div class="event-section-title">
    <ion-icon name="pricetag-outline"></ion-icon>
    진행 중인 이벤트
    <span>${fn:length(coupons)}개</span>
  </div>

  <div class="event-grid">
    <c:choose>
      <c:when test="${empty coupons}">
        <div class="event-empty">
          <ion-icon name="ticket-outline"></ion-icon>
          <p>현재 진행 중인 이벤트가 없습니다.</p>
        </div>
      </c:when>
      <c:otherwise>
        <c:forEach var="coupon" items="${coupons}">
          <c:set var="remaining"     value="${remainingCounts[coupon.couponId]}" />
          <c:set var="isExpired"     value="${coupon.endDate.before(today)}" />
          <c:set var="isUpcoming"    value="${coupon.startDate.after(today)}" />
          <c:set var="isSoldOut"     value="${remaining != null && remaining <= 0}" />
          <c:set var="alreadyIssued" value="${issuedIds.contains(coupon.couponId)}" />

          <c:set var="pct" value="0" />
          <c:if test="${coupon.totalCount > 0 && remaining != null}">
            <c:set var="pct" value="${remaining * 100 / coupon.totalCount}" />
          </c:if>

          <a class="event-card" href="<%=request.getContextPath()%>/coupon/${coupon.couponId}">
            <div class="event-card-banner">
              <ion-icon name="gift-outline"></ion-icon>
              <c:choose>
                <c:when test="${alreadyIssued}"><span class="event-card-status badge-issued">수령완료</span></c:when>
                <c:when test="${isExpired}">    <span class="event-card-status badge-expired">기간만료</span></c:when>
                <c:when test="${isUpcoming}">   <span class="event-card-status badge-upcoming">오픈예정</span></c:when>
                <c:when test="${isSoldOut}">    <span class="event-card-status badge-soldout">수량소진</span></c:when>
                <c:otherwise>                  <span class="event-card-status badge-active">진행중</span></c:otherwise>
              </c:choose>
            </div>
            <div class="event-card-body">
              <div class="event-card-name"><c:out value="${coupon.name}" /></div>
              <div class="event-card-date">
                <ion-icon name="calendar-outline"></ion-icon>
                <fmt:formatDate value="${coupon.startDate}" pattern="yyyy.MM.dd" /> ~
                <fmt:formatDate value="${coupon.endDate}"   pattern="yyyy.MM.dd" />
              </div>
              <div class="event-card-progress-track">
                <div class="event-card-progress-fill ${pct <= 20 ? 'fill-low' : ''}"
                     style="width:0%" data-width="${pct}%"></div>
              </div>
              <div class="event-card-remaining">
                <span>잔여
                  <c:choose>
                    <c:when test="${pct <= 20}"><strong class="remaining-low">${remaining}장</strong></c:when>
                    <c:otherwise><strong>${remaining}장</strong></c:otherwise>
                  </c:choose>
                  / 총 ${coupon.totalCount}장
                </span>
                <span>${pct}%</span>
              </div>
            </div>
          </a>
        </c:forEach>
      </c:otherwise>
    </c:choose>
  </div>

</div>
</section>

<script>
window.addEventListener('load', function() {
  document.querySelectorAll('.event-card-progress-fill').forEach(function(el) {
    var w = el.dataset.width;
    setTimeout(function() { el.style.width = w; }, 100);
  });
});
</script>

<%@ include file="../common/footer.jsp"%>
