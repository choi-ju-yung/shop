<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="../common/header.jsp"%>
<%@ include file="../mypage/myPageCategory.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/mypage/tradeHistory.css" />
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/common/pagination.css" />

<div class="tradePageWrap">
  <div class="tradePageHeader">
    <h2 class="tradePageTitle">
      <ion-icon name="bag"></ion-icon>
      구매 내역
    </h2>
  </div>

  <%-- 리뷰 완료 토스트 --%>
  <c:if test="${reviewSuccess}">
    <div class="reviewToast">
      <ion-icon name="checkmark-circle"></ion-icon> 후기가 등록되었습니다. 감사합니다!
    </div>
  </c:if>
  <c:if test="${not empty reviewError}">
    <div class="reviewToast reviewToast--err">
      <ion-icon name="close-circle"></ion-icon> <c:out value="${reviewError}"/>
    </div>
  </c:if>

  <c:choose>
    <c:when test="${empty products}">
      <div class="tradeEmpty">
        <ion-icon name="bag-outline"></ion-icon>
        <p>구매 완료된 상품이 없습니다.</p>
        <a href="<%=request.getContextPath()%>/product/category" class="tradeEmptyBtn">
          <ion-icon name="search-outline"></ion-icon> 상품 둘러보기
        </a>
      </div>
    </c:when>
    <c:otherwise>
      <c:set var="pageBaseUrl" value="?"/>
      <div class="purchaseList">
        <c:forEach var="p" items="${products}">
          <div class="purchaseItem">
            <%-- 썸네일 --%>
            <a href="<%=request.getContextPath()%>/product/${p.productId}" class="purchaseThumbLink">
              <div class="purchaseThumb">
                <c:choose>
                  <c:when test="${not empty p.mainFilePath}">
                    <img src="<%=request.getContextPath()%>${p.mainFilePath}"
                         alt="<c:out value='${p.title}'/>"
                         onerror="this.src='<%=request.getContextPath()%>/images/common/hifiveLogo.png'">
                  </c:when>
                  <c:otherwise>
                    <img src="<%=request.getContextPath()%>/images/common/hifiveLogo.png" alt="이미지 없음">
                  </c:otherwise>
                </c:choose>
                <div class="purchaseThumbDim">거래완료</div>
              </div>
            </a>

            <%-- 상품 정보 --%>
            <a href="<%=request.getContextPath()%>/product/${p.productId}" class="purchaseInfo">
              <p class="purchaseTitle"><c:out value="${p.title}"/></p>
              <p class="purchasePrice"><fmt:formatNumber value="${p.price}" pattern="#,###"/>원</p>
              <div class="purchaseMeta">
                <span class="purchaseState"><c:out value="${p.state}"/></span>
                <span class="purchasePlace">
                  <ion-icon name="location-outline"></ion-icon>
                  <c:out value="${not empty p.place ? p.place : '지역 미설정'}"/>
                </span>
              </div>
            </a>

            <%-- 리뷰 영역 --%>
            <div class="purchaseAction">
              <c:choose>
                <c:when test="${p.hasReview}">
                  <span class="reviewDone">
                    <ion-icon name="checkmark-circle"></ion-icon> 후기 작성 완료
                  </span>
                </c:when>
                <c:otherwise>
                  <a href="<%=request.getContextPath()%>/member/review/write?productId=${p.productId}"
                     class="reviewWriteBtn">
                    <ion-icon name="star-outline"></ion-icon> 후기 쓰기
                  </a>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </c:forEach>
      </div>
      <%@ include file="../common/pagination.jsp"%>
    </c:otherwise>
  </c:choose>
</div>

</section>
<%@ include file="../common/footer.jsp"%>
