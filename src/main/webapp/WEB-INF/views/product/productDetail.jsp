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
                   onerror="this.src='<%=request.getContextPath()%>/images/common/hifiveLogo.png'">
            </c:when>
            <c:otherwise>
              <img id="mainImg"
                   src="<%=request.getContextPath()%>/images/common/hifiveLogo.png"
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
                     onerror="this.src='<%=request.getContextPath()%>/images/common/hifiveLogo.png'">
              </div>
            </c:forEach>
          </div>
        </c:if>
      </div>

      <%-- 상품 정보 패널 --%>
      <div class="pdInfoPanel">

        <%-- 카테고리 브레드크럼 --%>
        <div class="pdBreadcrumb">
          <a href="<%=request.getContextPath()%>/product/category">전체</a>
          <span>&gt;</span>
          <a href="<%=request.getContextPath()%>/product/category?name=${product.subCate}">
            <c:out value="${product.subCate}"/>
          </a>
        </div>

        <%-- 상품명 --%>
        <h1 class="pdTitle"><c:out value="${product.title}"/></h1>

        <%-- 가격 + 상태 뱃지 --%>
        <div class="pdPriceRow">
          <span class="pdPrice"><fmt:formatNumber value="${product.price}" pattern="#,###"/>원</span>
          <span class="pdStateBadge pdState-${product.state}">
            <c:if test="${product.state == '신상'}">NEW </c:if><c:out value="${product.state}"/>
          </span>
          <%-- 거래 상태 뱃지 --%>
          <c:choose>
            <c:when test="${product.tradeStatus == 'RESERVED'}">
              <span class="pdTradeBadge pdTrade-RESERVED">예약중</span>
            </c:when>
            <c:when test="${product.tradeStatus == 'SOLD'}">
              <span class="pdTradeBadge pdTrade-SOLD">거래완료</span>
            </c:when>
          </c:choose>
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
        <a href="<%=request.getContextPath()%>/user/profile/${encodedSellerNo}" class="pdSellerBox pdSellerBox--link">
          <div class="pdSellerAvatar">
            <c:choose>
              <c:when test="${not empty product.sellerProfileImg}">
                <img src="<%=request.getContextPath()%>/upload/profile/${product.sellerProfileImg}"
                     alt="프로필"
                     onerror="this.src='<%=request.getContextPath()%>/images/profile/default_profile.png'">
              </c:when>
              <c:otherwise>
                <img src="<%=request.getContextPath()%>/images/profile/default_profile.png" alt="프로필">
              </c:otherwise>
            </c:choose>
          </div>
          <div class="pdSellerInfo">
            <p class="pdSellerName"><c:out value="${product.sellerName}"/></p>
            <p class="pdSellerSub">프로필 보기</p>
          </div>
        </a>

        <%-- 태그 --%>
        <c:if test="${not empty product.tag}">
          <div class="pdTags">
            <c:forTokens var="tag" items="${product.tag}" delims=",">
              <span class="pdTag"><c:out value="${tag.trim()}"/></span>
            </c:forTokens>
          </div>
        </c:if>

        <%-- 액션 버튼 --%>
        <div class="pdActions">
          <c:choose>
            <%-- 판매자 본인 --%>
            <c:when test="${isSeller}">
              <%-- 거래 상태 변경 드롭다운 (거래완료 시 비활성) --%>
              <div class="pdTradeStatusWrap">
                <c:choose>
                  <c:when test="${product.tradeStatus == 'SOLD'}">
                    <span class="pdTradeBadge pdTrade-SOLD">거래완료</span>
                  </c:when>
                  <c:otherwise>
                    <select id="tradeStatusSelect" class="pdTradeStatusSelect">
                      <option value="SALE"     ${product.tradeStatus == 'SALE'     ? 'selected' : ''}>판매중</option>
                      <option value="RESERVED" ${product.tradeStatus == 'RESERVED' ? 'selected' : ''}>예약중</option>
                      <option value="SOLD"     ${product.tradeStatus == 'SOLD'     ? 'selected' : ''}>거래완료</option>
                    </select>
                    <button class="pdBtnStatus" onclick="changeTradeStatus()">
                      <ion-icon name="checkmark-circle-outline"></ion-icon> 상태변경
                    </button>
                  </c:otherwise>
                </c:choose>
              </div>
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
              <button class="pdBtnSecondary" id="wishBtn" onclick="toggleWish()">
                <ion-icon name="heart-outline" id="wishIcon"></ion-icon>
                <span id="wishText">찜하기</span>
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

    <%-- ===================== 추천 상품 ===================== --%>
    <c:if test="${not empty relatedProducts}">
    <div class="pdRelatedSection">
      <h2 class="pdSectionTitle">
        <ion-icon name="grid-outline"></ion-icon> 비슷한 상품
      </h2>
      <div class="pdRelatedGrid">
        <c:forEach var="r" items="${relatedProducts}">
          <a href="<%=request.getContextPath()%>/product/${r.productId}" class="pdRelatedCard">
            <div class="pdRelatedImg">
              <c:choose>
                <c:when test="${not empty r.mainFilePath}">
                  <img src="<%=request.getContextPath()%>${r.mainFilePath}"
                       alt="<c:out value='${r.title}'/>"
                       onerror="this.src='<%=request.getContextPath()%>/images/common/hifiveLogo.png'">
                </c:when>
                <c:otherwise>
                  <img src="<%=request.getContextPath()%>/images/common/hifiveLogo.png" alt="이미지 없음">
                </c:otherwise>
              </c:choose>
            </div>
            <div class="pdRelatedInfo">
              <p class="pdRelatedTitle"><c:out value="${r.title}"/></p>
              <p class="pdRelatedPrice"><fmt:formatNumber value="${r.price}" pattern="#,###"/>원</p>
              <p class="pdRelatedPlace"><c:out value="${not empty r.place ? r.place : '지역 미설정'}"/></p>
            </div>
          </a>
        </c:forEach>
      </div>
    </div>
    </c:if>

  </div>
</section>

<%-- 채팅방 생성 폼 (숨김) --%>
<form id="chatForm" method="post" action="<%=request.getContextPath()%>/member/chat/room" style="display:none;">
  <input type="hidden" name="productId"   id="chatProductId"   value="${product.productId}">
  <input type="hidden" name="targetUserNo" id="chatTargetUserNo" value="${product.userNo}">
  <input type="hidden" name="roomId"      id="chatRoomId"      value="">
</form>

<script>
(function () {
  var ctx = '<%=request.getContextPath()%>';
  var productId  = '${product.productId}';
  var sellerNo   = ${product.userNo};
  var isLoggedIn = ${not empty sessionScope.loginUser};
  var isSeller   = ${isSeller};

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
      url: ctx + '/member/chat/room/enter',
      type: 'POST',
      data: { productId: productId, targetUserNo: sellerNo },
      success: function (roomId) {
        var popupName = 'chatPopup_' + roomId;
        var popup = window.open('', popupName, 'width=500,height=640,resizable=yes');
        if (!popup || popup.closed) {
          alert('팝업이 차단되었습니다. 팝업 차단을 해제해주세요.');
          return;
        }
        var form = document.getElementById('chatForm');
        document.getElementById('chatRoomId').value = roomId;
        form.target = popupName;
        form.submit();
      },
      error: function (xhr) {
        if (xhr.status === 403 && xhr.responseText === 'NICKNAME_REQUIRED') {
          location.href = ctx + '/member/mypage/settings?require=nickname';
        } else {
          alert('채팅방을 생성하지 못했습니다. 다시 시도해주세요.');
        }
      }
    });
  };

  /* ── 상품 삭제 ── */
  window.confirmDelete = function (productId) {
    if (!confirm('정말 삭제하시겠습니까?')) return;
    $.ajax({
      url: ctx + '/member/product/delete/' + productId,
      method: 'DELETE',
      success: function () {
        alert('삭제되었습니다.');
        location.href = ctx + '/product/category';
      },
      error: function (xhr) {
        alert(xhr.responseText || '삭제 중 오류가 발생했습니다.');
      }
    });
  };

  /* ── 거래 상태 변경 ── */
  window.changeTradeStatus = function () {
    var status = document.getElementById('tradeStatusSelect').value;
    if (status === 'SOLD') {
      // 채팅한 구매자 목록 조회 후 모달 표시
      $.ajax({
        url: ctx + '/member/product/' + productId + '/buyers',
        success: function (buyers) {
          showBuyerModal(buyers, function (buyerNo) {
            doStatusUpdate(status, buyerNo);
          });
        },
        error: function () {
          // 채팅 기록이 없어도 거래완료 처리 가능
          if (confirm('채팅 내역이 없습니다. 구매자 없이 거래완료 처리하시겠습니까?')) {
            doStatusUpdate(status, null);
          }
        }
      });
    } else {
      if (!confirm('거래 상태를 변경하시겠습니까?')) return;
      doStatusUpdate(status, null);
    }
  };

  function doStatusUpdate(status, buyerNo) {
    var data = { tradeStatus: status };
    if (buyerNo) data.buyerNo = buyerNo;
    $.ajax({
      url: ctx + '/member/product/' + productId + '/status',
      method: 'PATCH',
      data: data,
      success: function () {
        alert('거래 상태가 변경되었습니다.');
        location.reload();
      },
      error: function (xhr) {
        alert(xhr.responseText || '상태 변경 중 오류가 발생했습니다.');
      }
    });
  }

  function showBuyerModal(buyers, callback) {
    var existing = document.getElementById('buyerModal');
    if (existing) existing.remove();

    var selectedBuyerNo = null;

    var buyerListHtml = '';
    if (buyers.length === 0) {
      buyerListHtml =
        '<div class="bmEmpty">' +
          '<ion-icon name="person-outline"></ion-icon>' +
          '<p>채팅한 상대방이 없습니다.</p>' +
        '</div>';
    } else {
      buyerListHtml = '<ul class="bmList">';
      buyers.forEach(function(b) {
        buyerListHtml +=
          '<li class="bmItem" data-buyer-no="' + b.BUYER_NO + '">' +
            '<ion-icon name="person-circle-outline"></ion-icon>' +
            '<span>' + b.BUYER_NAME + '</span>' +
          '</li>';
      });
      buyerListHtml += '</ul>';
    }

    var html =
      '<div id="buyerModal" class="bmOverlay">' +
        '<div class="bmCard">' +
          '<div class="bmHeader">' +
            '<div class="bmIconWrap"><ion-icon name="checkmark-done-outline"></ion-icon></div>' +
            '<div>' +
              '<p class="bmTitle">거래완료 처리</p>' +
              '<p class="bmSub">거래한 상대방을 선택해주세요</p>' +
            '</div>' +
          '</div>' +
          '<div class="bmBody">' + buyerListHtml + '</div>' +
          '<div class="bmFooter">' +
            '<button class="bmBtnCancel" id="bmCancel">취소</button>' +
            '<button class="bmBtnConfirm" id="bmConfirm" disabled>' +
              '<ion-icon name="checkmark-circle-outline"></ion-icon> 거래완료 처리' +
            '</button>' +
          '</div>' +
        '</div>' +
      '</div>';

    document.body.insertAdjacentHTML('beforeend', html);

    document.getElementById('bmCancel').addEventListener('click', function() {
      document.getElementById('buyerModal').remove();
    });

    document.getElementById('bmConfirm').addEventListener('click', function() {
      document.getElementById('buyerModal').remove();
      callback(selectedBuyerNo);
    });

    document.querySelectorAll('.bmItem').forEach(function(li) {
      li.addEventListener('click', function() {
        document.querySelectorAll('.bmItem').forEach(function(el) { el.classList.remove('bmItem--selected'); });
        li.classList.add('bmItem--selected');
        selectedBuyerNo = li.dataset.buyerNo;
        document.getElementById('bmConfirm').disabled = false;
      });
    });
  }

  /* ── 찜하기 ── */
  // 로그인 상태이고 본인 상품이 아닐 때만 찜 여부 확인
  if (isLoggedIn && !isSeller) {
    $.ajax({
      url: ctx + '/member/wish/status',
      data: { productId: productId },
      success: function (res) { setWishState(res.wished); }
    });
  }

  function setWishState(wished) {
    var icon = document.getElementById('wishIcon');
    var text = document.getElementById('wishText');
    var btn  = document.getElementById('wishBtn');
    if (wished) {
      icon.setAttribute('name', 'heart');
      icon.style.color = '#ff4d6d';
      text.textContent = '찜됨';
      btn.style.borderColor = '#ff4d6d';
      btn.style.color = '#ff4d6d';
    } else {
      icon.setAttribute('name', 'heart-outline');
      icon.style.color = '';
      text.textContent = '찜하기';
      btn.style.borderColor = '';
      btn.style.color = '';
    }
  }

  window.toggleWish = function () {
    if ('${product.tradeStatus}' === 'SOLD') {
      alert('이미 판매된 상품입니다.');
      return;
    }
    $.ajax({
      url: ctx + '/member/wish/toggle',
      type: 'POST',
      data: { productId: productId },
      success: function (res) { setWishState(res.wished); },
      error: function () { alert('로그인이 필요하거나 오류가 발생했습니다.'); }
    });
  };
})();
</script>

<c:if test="${not empty sessionScope.loginUser}">
<script>
/* ── 최근 본 상품 localStorage 저장 (로그인 시에만) ── */
(function() {
    var RECENT_KEY = 'recentProducts';
    var RECENT_MAX = 8;
    var ctx   = document.querySelector('meta[name="ctx"]').getAttribute('content');
    var imgPath = '${not empty product.mainFilePath ? product.mainFilePath : ""}';
    var item  = {
        productId:   ${product.productId},
        title:       '${product.title}'.replace(/'/g, "&#39;"),
        price:       ${product.price},
        state:       '${product.state}',
        place:       '${not empty product.place ? product.place : "지역 미설정"}',
        tradeStatus: '${product.tradeStatus}',
        imgSrc:      imgPath ? ctx + imgPath : ctx + '/images/common/hifiveLogo.png'
    };
    try {
        var list = JSON.parse(localStorage.getItem(RECENT_KEY)) || [];
        list = list.filter(function(p) { return p.productId !== item.productId; });
        list.unshift(item);
        if (list.length > RECENT_MAX) list = list.slice(0, RECENT_MAX);
        localStorage.setItem(RECENT_KEY, JSON.stringify(list));
        /* 저장 직후 사이드바 즉시 갱신 */
        if (typeof window.renderRecentProducts === 'function') {
            window.renderRecentProducts();
        }
    } catch(e) {}
})();
</script>
</c:if>

<%@ include file="../common/footer.jsp"%>
