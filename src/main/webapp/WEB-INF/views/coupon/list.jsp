<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ include file="../common/header.jsp"%>
<style>
.event-page { max-width: 1100px; margin: 0 auto; padding-bottom: 80px; }

.event-section-title {
  font-size: 18px;
  font-weight: 700;
  color: #1a1a1a;
  margin-bottom: 24px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.event-section-title span {
  background: #e6faf4;
  color: #20c997;
  font-size: 13px;
  font-weight: 700;
  padding: 2px 10px;
  border-radius: 20px;
}

.event-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}
@media (max-width: 900px) { .event-grid { grid-template-columns: repeat(2,1fr); } }
@media (max-width: 560px) { .event-grid { grid-template-columns: 1fr; } }

.event-card {
  border-radius: 16px;
  background: #fff;
  border: 1.5px solid #e5e7eb;
  overflow: hidden;
  cursor: pointer;
  transition: transform .18s, box-shadow .18s;
  text-decoration: none;
  display: block;
  color: inherit;
}
.event-card:hover { transform: translateY(-4px); box-shadow: 0 12px 32px rgba(0,0,0,.1); }

.event-card-banner {
  height: 110px;
  background: linear-gradient(135deg, #134e4a, #20c997);
  display: flex; align-items: center; justify-content: center;
  position: relative;
}
.event-card-banner ion-icon { font-size: 48px; color: rgba(255,255,255,.85); }
.event-card-status {
  position: absolute; top: 12px; right: 12px;
  font-size: 11px; font-weight: 700; padding: 3px 10px;
  border-radius: 20px;
}
.badge-active   { background: #d1fae5; color: #065f46; }
.badge-issued   { background: #e0e7ff; color: #3730a3; }
.badge-soldout  { background: #fee2e2; color: #991b1b; }
.badge-expired  { background: #f3f4f6; color: #6b7280; }
.badge-upcoming { background: #fef3c7; color: #92400e; }

.event-card-body { padding: 18px 20px 20px; }
.event-card-name {
  font-size: 15px; font-weight: 700; color: #1a1a1a;
  margin-bottom: 8px;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.event-card-date {
  font-size: 12px; color: #6b7280;
  display: flex; align-items: center; gap: 4px;
  margin-bottom: 14px;
}
.event-card-progress-track {
  height: 6px; background: #e5e7eb; border-radius: 4px; overflow: hidden;
}
.event-card-progress-fill {
  height: 100%; background: #20c997; border-radius: 4px;
  transition: width .6s ease;
}
.event-card-progress-fill.fill-low { background: #f87171; }
.event-card-remaining {
  display: flex; justify-content: space-between;
  font-size: 12px; color: #6b7280; margin-top: 6px;
}
.remaining-low { color: #ef4444; font-weight: 700; }

.event-empty {
  grid-column: 1/-1; text-align: center; padding: 80px 0;
  color: #9ca3af;
}
.event-empty ion-icon { font-size: 48px; display: block; margin-bottom: 12px; }
</style>

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
