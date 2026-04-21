<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/product/searchResult.css" />

<%-- 검색 파라미터를 data attribute로 안전하게 전달 --%>
<div id="srData"
     data-keyword="${keyword}"
     data-category="${categoryName}"
     style="display:none;"></div>

<section>
  <div class="srContainer">

    <%-- ===================== 좌측 사이드바 ===================== --%>
    <aside class="srSidebar">

      <div class="filterBox">
        <h3 class="filterBoxTitle">카테고리</h3>
        <ul class="cateFilterList" id="cateFilterList">
          <li class="cateItem">
            <a href="#" data-cate=""
               class="cateLink mainCate <c:if test="${categoryName == '전체' || (empty categoryName && empty keyword)}">active</c:if>">
              전체
            </a>
          </li>
          <%-- AJAX로 나머지 카테고리 로드 --%>
        </ul>
      </div>

      <div class="filterBox">
        <h3 class="filterBoxTitle">가격대</h3>
        <ul class="optionList">
          <li><label class="optionLabel"><input type="radio" name="priceFilter" value="all" checked><span>전체</span></label></li>
          <li><label class="optionLabel"><input type="radio" name="priceFilter" value="0-50000"><span>5만원 이하</span></label></li>
          <li><label class="optionLabel"><input type="radio" name="priceFilter" value="50000-100000"><span>5만 ~ 10만원</span></label></li>
          <li><label class="optionLabel"><input type="radio" name="priceFilter" value="100000-300000"><span>10만 ~ 30만원</span></label></li>
          <li><label class="optionLabel"><input type="radio" name="priceFilter" value="300000-"><span>30만원 이상</span></label></li>
        </ul>
      </div>

      <div class="filterBox">
        <h3 class="filterBoxTitle">상품 상태</h3>
        <ul class="optionList">
          <li><label class="optionLabel"><input type="checkbox" class="stateCheck" value="신상"><span>신상</span></label></li>
          <li><label class="optionLabel"><input type="checkbox" class="stateCheck" value="중고"><span>중고</span></label></li>
        </ul>
      </div>

      <div class="filterBox">
        <h3 class="filterBoxTitle">거래 상태</h3>
        <ul class="optionList">
          <li><label class="optionLabel"><input type="radio" name="tradeFilter" value="all" checked><span>전체</span></label></li>
          <li><label class="optionLabel"><input type="radio" name="tradeFilter" value="SALE">
            <span class="tradeFilterBadge tradeFilterBadge--sale">판매중</span></label></li>
          <li><label class="optionLabel"><input type="radio" name="tradeFilter" value="RESERVED">
            <span class="tradeFilterBadge tradeFilterBadge--reserved">예약중</span></label></li>
          <li><label class="optionLabel"><input type="radio" name="tradeFilter" value="SOLD">
            <span class="tradeFilterBadge tradeFilterBadge--sold">거래완료</span></label></li>
        </ul>
      </div>

    </aside>

    <%-- ===================== 우측 메인 영역 ===================== --%>
    <main class="srMain">

      <%-- 검색 정보 바 --%>
      <div class="srInfoBar">
        <div class="srLabel">
          <c:choose>
            <c:when test="${not empty keyword}">
              <span class="srKeyword">"<c:out value="${keyword}"/>"</span> 검색결과
            </c:when>
            <c:when test="${not empty categoryName}">
              <span class="srKeyword"><c:out value="${categoryName}"/></span>
            </c:when>
          </c:choose>
          <span class="srCount">총 <em id="resultCount">${products.size()}</em>개</span>
        </div>
        <div class="srSortBar">
          <button class="srSortBtn active" data-sort="latest">최신순</button>
          <button class="srSortBtn" data-sort="price-asc">낮은가격순</button>
          <button class="srSortBtn" data-sort="price-desc">높은가격순</button>
        </div>
      </div>

      <%-- 상품 목록 --%>
      <div class="srProductGrid" id="productList">
        <c:choose>
          <c:when test="${empty products}">
            <div class="srNoResult">
              <ion-icon name="search-outline"></ion-icon>
              <p>검색 결과가 없습니다.</p>
              <a href="<%=request.getContextPath()%>/product/category" class="srNoResultBtn">전체 상품 보기</a>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="p" items="${products}">
              <div class="srProductCard"
                   data-price="${p.price}"
                   data-state="${p.state}"
                   data-tradestatus="${p.tradeStatus}"
                   data-id="${p.productId}">
                <c:if test="${not empty sessionScope.loginUser and p.userNo != sessionScope.loginUser.userNo}">
                  <button class="srWishBtn" data-product-id="${p.productId}" data-trade-status="${p.tradeStatus}" title="찜하기">
                    <ion-icon name="heart-outline"></ion-icon>
                  </button>
                </c:if>
                <a href="<%=request.getContextPath()%>/product/${p.productId}" class="srProductLink">
                  <div class="srProductImg">
                    <c:choose>
                      <c:when test="${not empty p.mainFilePath}">
                        <img src="<%=request.getContextPath()%>${p.mainFilePath}"
                             alt="<c:out value='${p.title}'/>"
                             onerror="this.src='<%=request.getContextPath()%>/images/common/hifiveLogo.png'">
                      </c:when>
                      <c:otherwise>
                        <img src="<%=request.getContextPath()%>/images/common/hifiveLogo.png"
                             alt="<c:out value='${p.title}'/>">
                      </c:otherwise>
                    </c:choose>
                    <c:choose>
                      <c:when test="${p.tradeStatus == 'SOLD'}">
                        <span class="srSoldDim">거래완료</span>
                      </c:when>
                      <c:when test="${p.tradeStatus == 'RESERVED'}">
                        <span class="srReservedBadge">예약중</span>
                      </c:when>
                      <c:otherwise>
                        <span class="srSaleBadge">판매중</span>
                      </c:otherwise>
                    </c:choose>
                  </div>
                  <div class="srProductInfo">
                    <p class="srProductTitle"><c:out value="${p.title}"/></p>
                    <div class="srPriceRow">
                      <strong class="srPrice"><fmt:formatNumber value="${p.price}" pattern="#,###"/>원</strong>
                      <span class="srStateBadge">${p.state}</span>
                    </div>
                    <p class="srPlace">
                      <ion-icon name="location-outline"></ion-icon>
                      <c:out value="${not empty p.place ? p.place : '지역 미설정'}"/>
                    </p>
                  </div>
                </a>
              </div>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>

    </main>
  </div>
</section>

<script>
(function () {
  var ctx = '<%=request.getContextPath()%>';
  var isLoggedIn    = ${ not empty sessionScope.loginUser ? 'true' : 'false' };
  var loginUserNo   = ${ not empty sessionScope.loginUser ? sessionScope.loginUser.userNo : 0 };
  var srData = document.getElementById('srData');
  var currentKeyword = srData.dataset.keyword || '';
  var currentCate = srData.dataset.category || '';

  /* ── 최초 진입 시 쿼리스트링 제거 (URL 정리) ── */
  history.replaceState(null, '', ctx + '/product/category');

  /* ── 카테고리 사이드바 로드 ── */
  $.ajax({
    url: ctx + '/product/categories',
    type: 'GET',
    dataType: 'json',
    success: function (data) {
      var catMap = {};
      var catOrder = [];
      data.forEach(function (item) {
        var cname = item.CATEGORY_NAME;
        if (!catMap[cname]) { catMap[cname] = []; catOrder.push(cname); }
        if (item.SUB_CATEGORY_NAME) catMap[cname].push(item.SUB_CATEGORY_NAME);
      });

      var html = '';
      catOrder.forEach(function (cname) {
        var isMainActive = (currentCate === cname) ? ' active' : '';
        var isOpen = (currentCate === cname || catMap[cname].indexOf(currentCate) !== -1);
        html += '<li class="cateItem">';
        html += '<a href="#" data-cate="' + cname + '"'
              + ' class="cateLink mainCate' + isMainActive + '">' + cname + '</a>';
        if (catMap[cname].length > 0) {
          html += '<ul class="subCateList' + (isOpen ? ' open' : '') + '">';
          catMap[cname].forEach(function (sname) {
            var isSubActive = (currentCate === sname) ? ' active' : '';
            html += '<li><a href="#" data-cate="' + sname + '"'
                  + ' class="cateLink subCate' + isSubActive + '">' + sname + '</a></li>';
          });
          html += '</ul>';
        }
        html += '</li>';
      });
      $('#cateFilterList').append(html);
    }
  });

  /* ── 카테고리 클릭 AJAX ── */
  $(document).on('click', '.cateLink', function (e) {
    e.preventDefault();
    var cate = $(this).data('cate') || '';

    $('.cateLink').removeClass('active');
    $(this).addClass('active');

    currentCate = cate;
    currentKeyword = '';

    /* URL 업데이트 (페이지 이동 없이) */
    history.pushState(null, '', ctx + '/product/category');

    /* 레이블 업데이트 */
    var label = cate || '전체';
    $('.srLabel').html(
      '<span class="srKeyword">' + label + '</span>' +
      ' <span class="srCount">총 <em id="resultCount">0</em>개</span>'
    );

    $('#productList').html('<p style="padding:20px;color:#999;">불러오는 중...</p>');

    $.ajax({
      url: ctx + '/product/category/products',
      type: 'GET',
      dataType: 'json',
      data: cate ? { name: cate } : {},
      success: function (products) {
        renderProducts(products);
        applyFilter();
      },
      error: function () {
        $('#productList').html('<p style="padding:20px;color:#f00;">상품 목록을 불러오지 못했습니다.</p>');
      }
    });
  });

  /* ── 정렬 ── */
  $(document).on('click', '.srSortBtn', function () {
    $('.srSortBtn').removeClass('active');
    $(this).addClass('active');
    applyFilter();
  });

  /* ── 가격 필터 ── */
  $(document).on('change', 'input[name="priceFilter"]', function () {
    applyFilter();
  });

  /* ── 상품 상태 필터 ── */
  $(document).on('change', '.stateCheck', function () { applyFilter(); });

  /* ── 거래 상태 필터 ── */
  $(document).on('change', 'input[name="tradeFilter"]', function () { applyFilter(); });

  /* ── 상품 목록 HTML 렌더링 ── */
  function renderProducts(products) {
    if (!products || products.length === 0) {
      $('#productList').html(
        '<div class="srNoResult">' +
        '<ion-icon name="search-outline"></ion-icon>' +
        '<p>검색 결과가 없습니다.</p>' +
        '<a href="' + ctx + '/product/category" class="srNoResultBtn">전체 상품 보기</a>' +
        '</div>'
      );
      return;
    }
    var html = '';
    products.forEach(function (p) {
      var ts     = p.tradeStatus || 'SALE';
      var imgSrc = p.mainFilePath ? ctx + p.mainFilePath : ctx + '/images/common/hifiveLogo.png';
      var badge  = ts === 'SOLD'     ? '<span class="srSoldDim">거래완료</span>'
                 : ts === 'RESERVED' ? '<span class="srReservedBadge">예약중</span>'
                 : '<span class="srSaleBadge">판매중</span>';
      var price  = p.price ? p.price.toLocaleString() + '원' : '0원';
      var place  = p.place || '지역 미설정';
      var isMyProduct = isLoggedIn && (p.userNo == loginUserNo);
      var wishBtn = (isLoggedIn && !isMyProduct)
        ? '<button class="srWishBtn" data-product-id="' + p.productId + '" data-trade-status="' + ts + '" title="찜하기"><ion-icon name="heart-outline"></ion-icon></button>'
        : '';
      html +=
        '<div class="srProductCard" data-price="' + p.price + '" data-state="' + p.state + '" data-tradestatus="' + ts + '" data-id="' + p.productId + '">' +
        wishBtn +
        '<a href="' + ctx + '/product/' + p.productId + '" class="srProductLink">' +
        '<div class="srProductImg">' +
        '<img src="' + imgSrc + '" alt="' + p.title + '" onerror="this.src=\'' + ctx + '/images/common/hifiveLogo.png\'">' +
        badge +
        '</div>' +
        '<div class="srProductInfo">' +
        '<p class="srProductTitle">' + p.title + '</p>' +
        '<div class="srPriceRow">' +
        '<strong class="srPrice">' + price + '</strong>' +
        '<span class="srStateBadge">' + p.state + '</span>' +
        '</div>' +
        '<p class="srPlace"><ion-icon name="location-outline"></ion-icon> ' + place + '</p>' +
        '</div>' +
        '</a>' +
        '</div>';
    });
    $('#productList').html(html);
    loadWishStatuses();
  }

  /* ── 찜 상태 일괄 조회 및 버튼 반영 ── */
  function loadWishStatuses() {
    if (!isLoggedIn) return;
    document.querySelectorAll('.srWishBtn').forEach(function (btn) {
      var productId = btn.dataset.productId;
      $.ajax({
        url: ctx + '/member/wish/status',
        data: { productId: productId },
        success: function (res) { applyWishState(btn, res.wished); }
      });
    });
  }

  function applyWishState(btn, wished) {
    var icon = btn.querySelector('ion-icon');
    if (wished) {
      icon.setAttribute('name', 'heart');
      btn.classList.add('srWishBtn--active');
    } else {
      icon.setAttribute('name', 'heart-outline');
      btn.classList.remove('srWishBtn--active');
    }
  }

  /* ── 찜 버튼 클릭 (이벤트 위임) ── */
  $(document).on('click', '.srWishBtn', function (e) {
    e.preventDefault();
    e.stopPropagation();
    if ($(this).data('trade-status') === 'SOLD') {
      alert('이미 판매된 상품입니다.');
      return;
    }
    var btn = this;
    var productId = btn.dataset.productId;
    $.ajax({
      url: ctx + '/member/wish/toggle',
      type: 'POST',
      data: { productId: productId },
      success: function (res) { applyWishState(btn, res.wished); },
      error: function () { alert('로그인이 필요합니다.'); }
    });
  });

  /* ── 페이지 최초 로드 시 찜 상태 반영 ── */
  loadWishStatuses();

  function applyFilter() {
    var sort = $('.srSortBtn.active').data('sort') || 'latest';
    var priceVal = $('input[name="priceFilter"]:checked').val();
    var tradeVal = $('input[name="tradeFilter"]:checked').val();
    var selectedStates = [];
    $('.stateCheck:checked').each(function () { selectedStates.push($(this).val()); });

    var $grid = $('#productList');
    var cards = $grid.find('.srProductCard').toArray();
    var visible = 0;

    cards.forEach(function (card) {
      var $c = $(card);
      var price = parseInt($c.data('price')) || 0;
      var state = ($c.data('state') || '').toString();
      var tradeStatus = ($c.data('tradestatus') || 'SALE').toString();

      /* 가격 범위 */
      var priceOk = true;
      if (priceVal && priceVal !== 'all') {
        var parts = priceVal.split('-');
        var min = parseInt(parts[0]) || 0;
        var max = parts[1] !== '' ? parseInt(parts[1]) : Infinity;
        priceOk = (price >= min && price <= max);
      }

      /* 상품 상태 */
      var stateOk = selectedStates.length === 0 || selectedStates.indexOf(state) !== -1;

      /* 거래 상태 */
      var tradeOk = !tradeVal || tradeVal === 'all' || tradeStatus === tradeVal;

      if (priceOk && stateOk && tradeOk) { $c.show(); visible++; } else { $c.hide(); }
    });

    /* 정렬 (보이는 카드 기준) */
    var visible_cards = $grid.find('.srProductCard:visible').toArray();
    visible_cards.sort(function (a, b) {
      var $a = $(a), $b = $(b);
      if (sort === 'price-asc')  return parseInt($a.data('price')) - parseInt($b.data('price'));
      if (sort === 'price-desc') return parseInt($b.data('price')) - parseInt($a.data('price'));
      /* latest: PRODUCT_ID DESC (NUMBER 기반 내림차순) */
      return parseInt($b.data('id')) - parseInt($a.data('id'));
    });
    visible_cards.forEach(function (c) { $grid.append(c); });

    $('#resultCount').text(visible);
  }

})();
</script>

<%@ include file="../common/footer.jsp"%>
