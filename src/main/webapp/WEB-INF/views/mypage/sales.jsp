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
      <ion-icon name="pricetag"></ion-icon>
      판매 내역
    </h2>

    <%-- 상태 탭 --%>
    <div class="tradeTabs">
      <a href="?status=ALL"      class="tradeTab ${currentStatus == 'ALL'      ? 'active' : ''}">전체</a>
      <a href="?status=SALE"     class="tradeTab ${currentStatus == 'SALE'     ? 'active' : ''}">판매중</a>
      <a href="?status=RESERVED" class="tradeTab ${currentStatus == 'RESERVED' ? 'active' : ''}">예약중</a>
      <a href="?status=SOLD"     class="tradeTab ${currentStatus == 'SOLD'     ? 'active' : ''}">거래완료</a>
    </div>
  </div>

  <c:choose>
    <c:when test="${empty products}">
      <div class="tradeEmpty">
        <ion-icon name="storefront-outline"></ion-icon>
        <p>등록된 판매 상품이 없습니다.</p>
        <a href="<%=request.getContextPath()%>/member/sell" class="tradeEmptyBtn">
          <ion-icon name="add-circle-outline"></ion-icon> 상품 등록하기
        </a>
      </div>
    </c:when>
    <c:otherwise>
      <c:set var="pageBaseUrl" value="?status=${currentStatus}&amp;"/>
      <div class="tradeGrid">
        <c:forEach var="p" items="${products}">
          <div class="tradeCard">

            <%-- 거래 상태 뱃지 --%>
            <div class="tradeCardBadgeWrap">
              <c:choose>
                <c:when test="${p.tradeStatus == 'RESERVED'}">
                  <span class="tradeStatusBadge badge-reserved">예약중</span>
                </c:when>
                <c:when test="${p.tradeStatus == 'SOLD'}">
                  <span class="tradeStatusBadge badge-sold">거래완료</span>
                </c:when>
                <c:otherwise>
                  <span class="tradeStatusBadge badge-sale">판매중</span>
                </c:otherwise>
              </c:choose>
            </div>

            <%-- 상품 링크 --%>
            <a href="<%=request.getContextPath()%>/product/${p.productId}" class="tradeCardLink">
              <div class="tradeCardImg ${p.tradeStatus == 'SOLD' ? 'sold-overlay' : ''}">
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
                <c:if test="${p.tradeStatus == 'SOLD'}">
                  <div class="soldDim">거래완료</div>
                </c:if>
              </div>
              <div class="tradeCardInfo">
                <p class="tradeCardTitle"><c:out value="${p.title}"/></p>
                <p class="tradeCardPrice"><fmt:formatNumber value="${p.price}" pattern="#,###"/>원</p>
                <div class="tradeCardMeta">
                  <span class="tradeCardState"><c:out value="${p.state}"/></span>
                  <span><c:out value="${not empty p.place ? p.place : '지역 미설정'}"/></span>
                </div>
              </div>
            </a>

            <%-- 상태 변경 버튼 --%>
            <div class="tradeCardActions">
              <c:choose>
                <c:when test="${p.tradeStatus == 'SALE'}">
                  <button class="tradeBtn btn-reserve" onclick="quickStatus('${p.productId}', 'RESERVED')">예약</button>
                  <button class="tradeBtn btn-sold"    onclick="openBuyerModal('${p.productId}')">완료</button>
                </c:when>
                <c:when test="${p.tradeStatus == 'RESERVED'}">
                  <button class="tradeBtn btn-cancel"  onclick="quickStatus('${p.productId}', 'SALE')">예약취소</button>
                  <button class="tradeBtn btn-sold"    onclick="openBuyerModal('${p.productId}')">완료</button>
                </c:when>
                <c:when test="${p.tradeStatus == 'SOLD'}">
                  <div class="tradeDoneMsg">
                    <ion-icon name="checkmark-done-circle-outline"></ion-icon>
                    거래가 성공적으로 완료됐어요
                  </div>
                </c:when>
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

<%-- 구매자 선택 모달 (SOLD 처리 시) --%>
<div id="buyerModal" class="buyerModalOverlay" style="display:none;">
  <div class="buyerModalBox">
    <div class="buyerModalHeader">
      <div class="buyerModalHeaderIcon"><ion-icon name="checkmark-done-outline"></ion-icon></div>
      <div>
        <h3 class="buyerModalTitle">거래완료 처리</h3>
        <p class="buyerModalDesc">거래한 상대방을 선택해주세요</p>
      </div>
    </div>
    <ul id="buyerList" class="buyerList"></ul>
    <div class="buyerModalFooter">
      <button class="buyerModalCancel" onclick="closeBuyerModal()">취소</button>
      <button class="buyerModalConfirm" id="buyerConfirmBtn" onclick="confirmSold()" disabled>
        <ion-icon name="checkmark-circle-outline"></ion-icon> 거래완료 처리
      </button>
    </div>
  </div>
</div>

<script>
(function () {
  var ctx = '<%=request.getContextPath()%>';
  var currentProductId = null;
  var selectedBuyerNo  = null;

  window.quickStatus = function (productId, status) {
    var labels = { SALE: '판매중', RESERVED: '예약중' };
    if (!confirm('\'' + labels[status] + '\'(으)로 변경하시겠습니까?')) return;
    $.ajax({
      url: ctx + '/member/product/' + productId + '/status',
      method: 'PATCH',
      data: { tradeStatus: status },
      success: function () { location.reload(); },
      error:   function (xhr) { alert(xhr.responseText || '오류가 발생했습니다.'); }
    });
  };

  window.openBuyerModal = function (productId) {
    currentProductId = productId;
    selectedBuyerNo  = null;
    document.getElementById('buyerConfirmBtn').disabled = true;

    $.ajax({
      url: ctx + '/member/product/' + productId + '/buyers',
      success: function (buyers) {
        var list = document.getElementById('buyerList');
        list.innerHTML = '';
        if (buyers.length === 0) {
          list.innerHTML = '<li class="buyerEmpty"><ion-icon name="person-outline"></ion-icon>채팅한 상대방이 없습니다.</li>';
        } else {
          buyers.forEach(function (b) {
            var li = document.createElement('li');
            li.className = 'buyerItem';
            li.dataset.buyerNo = b.BUYER_NO;
            li.innerHTML =
              '<ion-icon name="person-circle-outline"></ion-icon>' +
              '<span class="buyerItemName">' + b.BUYER_NAME + '</span>' +
              '<span class="buyerItemCheck"><ion-icon name="checkmark-circle"></ion-icon></span>';
            li.addEventListener('click', function () {
              document.querySelectorAll('.buyerItem').forEach(function (el) {
                el.classList.remove('selected');
              });
              li.classList.add('selected');
              selectedBuyerNo = b.BUYER_NO;
              document.getElementById('buyerConfirmBtn').disabled = false;
            });
            list.appendChild(li);
          });
        }
        document.getElementById('buyerModal').style.display = 'flex';
      },
      error: function () {
        document.getElementById('buyerList').innerHTML = '<li class="buyerEmpty">채팅 내역을 불러오지 못했습니다.</li>';
        document.getElementById('buyerModal').style.display = 'flex';
      }
    });
  };

  window.closeBuyerModal = function () {
    document.getElementById('buyerModal').style.display = 'none';
    currentProductId = null;
    selectedBuyerNo  = null;
  };

  window.confirmSold = function () {
    if (!currentProductId || !selectedBuyerNo) return;
    var btn = document.getElementById('buyerConfirmBtn');
    btn.disabled = true;
    btn.innerHTML = '<ion-icon name="hourglass-outline"></ion-icon> 처리 중...';
    $.ajax({
      url: ctx + '/member/product/' + currentProductId + '/status',
      method: 'PATCH',
      data: { tradeStatus: 'SOLD', buyerNo: selectedBuyerNo },
      success: function () { location.reload(); },
      error: function (xhr) {
        btn.disabled = false;
        btn.innerHTML = '<ion-icon name="checkmark-circle-outline"></ion-icon> 거래완료 처리';
        alert(xhr.responseText || '오류가 발생했습니다.');
      }
    });
  };

  document.getElementById('buyerModal').addEventListener('click', function (e) {
    if (e.target === this) closeBuyerModal();
  });
})();
</script>

<%@ include file="../common/footer.jsp"%>
