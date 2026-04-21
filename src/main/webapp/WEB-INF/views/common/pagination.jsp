<%-- ================================================
     공통 페이지네이션 프래그먼트
     사용 전 모델에 필요한 값:
       currentPage  - 현재 페이지 번호
       totalPages   - 전체 페이지 수
       pageBaseUrl  - 페이지 링크 앞부분 (예: "?" 또는 "?status=ALL&")
     ================================================ --%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:if test="${totalPages > 1}">
<div class="pgWrap">

  <%-- 이전 --%>
  <c:choose>
    <c:when test="${currentPage > 1}">
      <a href="${pageBaseUrl}page=${currentPage - 1}" class="pgBtn pgArrow">
        <ion-icon name="chevron-back-outline"></ion-icon>
      </a>
    </c:when>
    <c:otherwise>
      <span class="pgBtn pgArrow pgDisabled">
        <ion-icon name="chevron-back-outline"></ion-icon>
      </span>
    </c:otherwise>
  </c:choose>

  <%-- 첫 페이지 --%>
  <c:if test="${currentPage > 4}">
    <a href="${pageBaseUrl}page=1" class="pgBtn">1</a>
    <c:if test="${currentPage > 5}">
      <span class="pgEllipsis">···</span>
    </c:if>
  </c:if>

  <%-- 중간 번호 (현재 ±2) --%>
  <c:forEach begin="1" end="${totalPages}" var="p">
    <c:if test="${p >= currentPage - 2 and p <= currentPage + 2}">
      <a href="${pageBaseUrl}page=${p}"
         class="pgBtn <c:if test='${p == currentPage}'>pgActive</c:if>">${p}</a>
    </c:if>
  </c:forEach>

  <%-- 마지막 페이지 --%>
  <c:if test="${currentPage < totalPages - 3}">
    <c:if test="${currentPage < totalPages - 4}">
      <span class="pgEllipsis">···</span>
    </c:if>
    <a href="${pageBaseUrl}page=${totalPages}" class="pgBtn">${totalPages}</a>
  </c:if>

  <%-- 다음 --%>
  <c:choose>
    <c:when test="${currentPage < totalPages}">
      <a href="${pageBaseUrl}page=${currentPage + 1}" class="pgBtn pgArrow">
        <ion-icon name="chevron-forward-outline"></ion-icon>
      </a>
    </c:when>
    <c:otherwise>
      <span class="pgBtn pgArrow pgDisabled">
        <ion-icon name="chevron-forward-outline"></ion-icon>
      </span>
    </c:otherwise>
  </c:choose>

</div>
</c:if>
