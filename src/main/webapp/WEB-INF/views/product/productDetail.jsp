<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/product/productDetail.css" />

<section>
  <div class="pdContainer">

    <%-- ===================== 상단 : 이미지 + 상품정보 ===================== --%>
    <div class="pdTopArea">

      <%-- 이미지 갤러리 --%>
      <div class="pdGallery">
        <div class="pdMainImg">
          <c:choose>
            <c:when test="${not empty product.mainFilePath}">
              <img id="mainImg"
                   src="<%=request.getContextPath()%>${product.mainFilePath}"
                   alt="<c:out value='${product.title}'/>"
                   onerror="this.src='<%=request.getContextPath()%>/css/images/common/hifiveLogo.png'">
            </c:when>
            <c:otherwise>
              <img id="mainImg"
                   src="<%=request.getContextPath()%>/css/images/common/hifiveLogo.png"
                   alt="이미지 없음">
            </c:otherwise>
          </c:choose>
        </div>

        <%-- 썸네일 목록 --%>
        <c:if test="${not empty product.productFiles}">
          <div class="pdThumbs">
            <c:forEach var="f" items="${product.productFiles}">
              <div class="${f.main ? 'pdThumb active' : 'pdThumb'}"
                   data-src="${f.filePath}">
                <img src="<%=request.getContextPath()%>${f.filePath}"
                     alt="상품 이미지"
                     onerror="this.src='<%=request.getContextPath()%>/css/images/common/hifiveLogo.png'">
              </div>
            </c:forEach>
          </div>
        </c:if>
      </div>

      <%-- 상품 정보 패널 --%>
      <div class="pdInfoPanel">

        <%-- 카테고리 브레드크럼 --%>
        <div class="pdBreadcrumb">
          <a href="<%=request.getContextPath()%>/user/category">전체</a>
          <span>&gt;</span>
          <a href="<%=request.getContextPath()%>/user/category?name=${product.subCate}">
            <c:out value="${product.subCate}"/>
          </a>
        </div>

        <%-- 상품명 --%>
        <h1 class="pdTitle"><c:out value="${product.title}"/></h1>

        <%-- 가격 + 상태 뱃지 --%>
        <div class="pdPriceRow">
          <span class="pdPrice"><fmt:formatNumber value="${product.price}" pattern="#,###"/>원</span>
          <span class="pdStateBadge pdState-${product.state}">
            <c:if test="${product.state == '미개봉'}">NEW </c:if><c:out value="${product.state}"/>
          </span>
        </div>

        <hr class="pdDivider">

        <%-- 거래 정보 --%>
        <ul class="pdMetaList">
          <li>
            <ion-icon name="location-outline"></ion-icon>
            <span class="pdMetaLabel">거래지역</span>
            <span class="pdMetaValue"><c:out value="${not empty product.place ? product.place : '미설정'}"/></span>
          </li>
          <li>
            <ion-icon name="grid-outline"></ion-icon>
            <span class="pdMetaLabel">카테고리</span>
            <span class="pdMetaValue"><c:out value="${product.subCate}"/></span>
          </li>
          <li>
            <ion-icon name="cube-outline"></ion-icon>
            <span class="pdMetaLabel">상품상태</span>
            <span class="pdMetaValue"><c:out value="${product.state}"/></span>
          </li>
        </ul>

        <hr class="pdDivider">

        <%-- 판매자 정보 --%>
        <div class="pdSellerBox">
          <div class="pdSellerAvatar">
            <ion-icon name="person-circle-outline"></ion-icon>
          </div>
          <div class="pdSellerInfo">
            <p class="pdSellerName"><c:out value="${product.sellerName}"/></p>
            <p class="pdSellerSub">판매자</p>
          </div>
        </div>

        <%-- 태그 --%>
        <c:if test="${not empty product.tag}">
          <div class="pdTags">
            <c:forTokens var="tag" items="${product.tag}" delims=",">
              <span class="pdTag">#<c:out value="${tag.trim()}"/></span>
            </c:forTokens>
          </div>
        </c:if>

        <%-- 액션 버튼 --%>
        <div class="pdActions">
          <c:choose>
            <%-- 판매자 본인 --%>
            <c:when test="${isSeller}">
              <button class="pdBtnSecondary" onclick="alert('수정 기능 준비 중입니다.')">
                <ion-icon name="create-outline"></ion-icon> 수정하기
              </button>
              <button class="pdBtnDanger" onclick="confirmDelete('${product.productId}')">
                <ion-icon name="trash-outline"></ion-icon> 삭제하기
              </button>
            </c:when>
            <%-- 로그인된 구매자 --%>
            <c:when test="${not empty sessionScope.loginUser}">
              <button class="pdBtnPrimary" onclick="startChat()">
                <ion-icon name="chatbubble-outline"></ion-icon> 채팅하기
              </button>
              <button class="pdBtnSecondary" onclick="alert('찜 기능 준비 중입니다.')">
                <ion-icon name="heart-outline"></ion-icon> 찜하기
              </button>
            </c:when>
            <%-- 비로그인 --%>
            <c:otherwise>
              <a href="<%=request.getContextPath()%>/login" class="pdBtnPrimary">
                <ion-icon name="log-in-outline"></ion-icon> 로그인 후 채팅
              </a>
            </c:otherwise>
          </c:choose>
        </div>

      </div>
    </div>

    <%-- ===================== 하단 : 상품 설명 ===================== --%>
    <div class="pdDescSection">
      <h2 class="pdSectionTitle">상품 설명</h2>
      <div class="pdDesc">
        <c:choose>
          <c:when test="${not empty product.explanation}">
            <c:out value="${product.explanation}"/>
          </c:when>
          <c:otherwise>
            <span style="color:#aaa;">등록된 상품 설명이 없습니다.</span>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <%-- 뒤로가기 --%>
    <div class="pdBackRow">
      <button class="pdBackBtn" onclick="history.back()">
        <ion-icon name="arrow-back-outline"></ion-icon> 목록으로
      </button>
    </div>

  </div>
</section>

<%-- 채팅방 생성 폼 (숨김) --%>
<form id="chatForm" method="post" action="<%=request.getContextPath()%>/room" style="display:none;">
  <input type="hidden" name="productId"   id="chatProductId"   value="${product.productId}">
  <input type="hidden" name="targetUserNo" id="chatTargetUserNo" value="${product.userNo}">
  <input type="hidden" name="roomId"      id="chatRoomId"      value="">
</form>

<script>
(function () {
  var ctx = '<%=request.getContextPath()%>';
  var productId  = '${product.productId}';
  var sellerNo   = ${product.userNo};

  /* ── 이미지 갤러리 전환 ── */
  document.querySelectorAll('.pdThumb').forEach(function (thumbEl) {
    thumbEl.addEventListener('click', function () {
      var src = ctx + thumbEl.dataset.src;
      document.getElementById('mainImg').src = src;
      document.querySelectorAll('.pdThumb').forEach(function (t) { t.classList.remove('active'); });
      thumbEl.classList.add('active');
    });
  });

  /* ── 채팅하기 ── */
  window.startChat = function () {
    $.ajax({
      url: ctx + '/chatRoomUtil',
      type: 'POST',
      data: { productId: productId, targetUserNo: sellerNo },
      success: function (roomId) {
        $('#chatRoomId').val(roomId);
        $('#chatForm').submit();
      },
      error: function () {
        alert('채팅방을 생성하지 못했습니다. 다시 시도해주세요.');
      }
    });
  };

  /* ── 상품 삭제 ── */
  window.confirmDelete = function (pid) {
    if (confirm('정말 삭제하시겠습니까?')) {
      alert('삭제 기능 준비 중입니다.');
    }
  };
})();
</script>

<%@ include file="../common/footer.jsp"%>
