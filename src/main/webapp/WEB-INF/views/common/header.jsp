<%@page import="com.example.demo.user.vo.UserVO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
   pageEncoding="UTF-8"%>
   <%@ taglib prefix="c"  uri="jakarta.tags.core"%>
   <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%-- <%@page import="com.semi.category.model.vo.Category"%>
<%@page import="java.util.List"%> --%>


<!DOCTYPE html>
<html>
<head>
<script>
   //로그인한 아이디 sessionStorage에 저장하자..ㅋㅋㅋ
  <%--  var contextPath = "<%=request.getContextPath()%>";
   sessionStorage.setItem("loginId",'<%=loginMember!=null?loginMember.getId():""%>'); --%>
</script>
<meta charset="UTF-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<meta name="ctx" content="<%=request.getContextPath()%>" />
<meta name="isLoggedIn" content="${not empty sessionScope.loginUser ? 'true' : 'false'}" />
<link rel="preload" href="<%=request.getContextPath()%>/images/common/logo.svg" as="image" fetchpriority="high">
<!-- css 파일 -->
<link rel="stylesheet"
   href="<%=request.getContextPath()%>/css/default.css" />
<link rel="stylesheet"
   href="<%=request.getContextPath()%>/css/footer.css" />
<link rel="icon"
   href="<%=request.getContextPath()%>/images/common/fivicon.png"
   type="image/x-icon" />
<!-- js 파일 -->
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js" defer></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js" defer></script>
<script type="module"
   src="https://cdn.jsdelivr.net/npm/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
<script nomodule
   src="https://cdn.jsdelivr.net/npm/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
<script src="https://cdn.jsdelivr.net/npm/jquery@3.7.0/dist/jquery.min.js"></script>
<title>중고 거래 니꺼내꺼</title>
</head>
<body>

	<header>
		<div id="headerContainer">
			<div id="fixedContainer">
				
				<c:if test="${empty sessionScope.loginUser}">
				<div class="loginSerivce">
					<a href="<%=request.getContextPath()%>/login" id="login">로그인</a>
					<a href="<%=request.getContextPath()%>/regist/nomalregist" id="enroll">회원가입</a>
					<a href="<%=request.getContextPath()%>/coupon/list" id="eventBtn">쿠폰</a>
					<a href="<%=request.getContextPath()%>/board/list?notice=N"
						id="service">고객센터</a>
				</div>
				</c:if>
				<c:if test="${not empty sessionScope.loginUser}">
				<div class="loginSerivce">
				<%-- <%if(loginMember.getAuth().equals("M")){%>
					<a href="<%=request.getContextPath()%>/adminMode.do">관리자모드</a>
					<%} %> --%>
					<c:if test="${sessionScope.loginUser.role == 'ROLE_ADMIN'}">
						<a href="<%=request.getContextPath()%>/admin/adminMode">관리자모드</a>
					</c:if> 
					<a href="#"
						onclick="localStorage.removeItem('recentProducts'); location.replace('<%=request.getContextPath()%>/logout')"
						id="logout">로그아웃</a>
					<a href="<%=request.getContextPath()%>/coupon/list" id="eventBtn">쿠폰</a>
					<a href="<%=request.getContextPath()%>/board/list?notice=N"
						id="service">고객센터</a>
				</div>
 				</c:if>
   
            <div class="headerMain">
               <div class="logo">
                  <a href="<%=request.getContextPath()%>/"> <img
                     src="<%=request.getContextPath()%>/images/common/logo.svg"
                     alt="" fetchpriority="high" />
                  </a>
               </div>
               <div class="searchBar">
                  <div class="searchDetail">
                     <form id="searchForm" class="form" action="<%=request.getContextPath()%>/product/search" method="get">
                        <input name="keyword" id="searchInput" maxlength="50" type="text"
                           placeholder="상품명, #키워드 검색" onfocus="this.placeholder = ''"
                        onblur="this.placeholder = '상품명, #키워드 검색'">
                        <button type="reset" id="resetBtn">
                     <ion-icon name="close"></ion-icon>
                     </button>
                     </form>

                     <button type="submit" form="searchForm" id="submitBtn">
                        <img
                           src="<%=request.getContextPath()%>/images/common/magnifier.png"
                           alt="" />
                     </button>
                  </div>

                  <div class="searchpage">

                     <div class="searchbody">
                        <hr>
                        <div class="recentSearch">
                           <div class="allDelete off">
                              <span id="recentHead">최근 검색어</span> <span id="allDeleteBtn">모두
                                 지우기</span>
                           </div>
                           <p class="recentText"></p>
                           <ul id="recentList">

                           </ul>
                        </div>
                     </div>               
                  </div>
               </div>
               <div class="memberIcon">
                  <a href="<%=request.getContextPath()%>/member/sell"> <ion-icon
                        name="storefront-outline" class="storeIcon"></ion-icon> <span>
                        판매하기</span>
                  </a>
<%--                   <%
                  if (loginMember != null) {
                  %> --%>
                  <a
                     href="<%=request.getContextPath()%>/member/mypage">
                     <ion-icon name="person-outline" class="myIcon"></ion-icon> 내정보
                  </a> <a href="<%=request.getContextPath()%>/member/wishlist"> <ion-icon name="heart-outline" class="heartIcon"></ion-icon>
                     찜한상품
                  </a>
                  <a href="<%=request.getContextPath()%>/member/chat" id="chatBell" style="position:relative;">
                    <ion-icon name="mail-outline" class="heartIconr"></ion-icon>
                    채팅
                    <span id="chat-badge" style="
                      display:none; position:absolute; top:-2px; left:14px;
                      background:#ff4d6d; color:#fff; font-size:10px; font-weight:700;
                      min-width:16px; height:16px; line-height:16px; text-align:center;
                      border-radius:8px; padding:0 4px; white-space:nowrap; pointer-events:none;">0</span>
                  </a>
                  <a href="<%=request.getContextPath()%>/member/notilist" id="notiBell" style="position:relative;">
                    <ion-icon name="notifications-outline" style="font-size:27px; color:#20c997; padding-right:4px;"></ion-icon>
                    알림
                    <span id="noti-badge" style="
                      display:none; position:absolute; top:-2px; left:14px;
                      background:#ff4d6d; color:#fff; font-size:10px; font-weight:700;
                      min-width:16px; height:16px; line-height:16px; text-align:center;
                      border-radius:8px; padding:0 4px; white-space:nowrap; pointer-events:none;">0</span>
                  </a>
                  <div id="toast-container"></div>
<%--                   <%
                  } else {
                  %>
                  <a href="<%=request.getContextPath()%>/productRegist.do"> <ion-icon
                        name="person-outline" class="myIcon"></ion-icon> 내정보
                  </a> <a href="<%=request.getContextPath()%>/productRegist.do"> <ion-icon
                        name="heart-outline" class="heartIcon"></ion-icon> 찜한상품
                  </a>
                  <%
                  }
                  %> --%>
               </div>
            </div>
            <div class="categoryNrank">
                <input type="checkbox" id="menuIcon" /> <label for="menuIcon"
                  class="headercategorybtn"> <span></span> <span></span> <span></span>
               </label>
               <div id="menuList">
                  <ul>
                   </ul>
               </div> 
               
               
               <p>카테고리</p>
               
            </div>

         </div>
         <hr width="1280px" color="#eeeeee" noshade />
      </div>

      <div id="itemBox">
         <div id="rpHeader">
            <span class="rpIcon"><ion-icon name="time-outline"></ion-icon></span>
            <span class="rpLabel">최근 본 상품</span>
            <span class="rpBadge" id="rpBadge">0</span>
         </div>
         <div id="recently"></div>
         <div id="rpFooter" style="display:none;">
            <button id="rpClearBtn" onclick="clearRecentProducts()">기록 지우기</button>
         </div>
      </div>
   </header>
   <script>

   /* ── 전역 함수 정의 (jQuery 로드 전에 정의되어도 안전) ── */

   function updateNotiBadge(count) {
       const badge = document.getElementById('noti-badge');
       if (!badge) return;
       if (count > 0) {
           badge.style.display = 'inline-block';
           badge.textContent = count > 99 ? '99+' : count;
       } else {
           badge.style.display = 'none';
           badge.textContent = '0';
       }
   }

   function updateChatBadge(count) {
       const badge = document.getElementById('chat-badge');
       if (!badge) return;
       if (count > 0) {
           badge.style.display = 'inline-block';
           badge.textContent = count > 99 ? '99+' : count;
       } else {
           badge.style.display = 'none';
           badge.textContent = '0';
       }
   }

   function createToast(message) {
       const toast = document.createElement('div');
       toast.innerHTML =
           '<div style="display:flex;align-items:center;gap:10px;">' +
               '<div style="width:36px;height:36px;border-radius:50%;background:#ecfdf5;display:flex;align-items:center;justify-content:center;flex-shrink:0;">' +
                   '<svg width="18" height="18" viewBox="0 0 24 24" fill="#20c997"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>' +
               '</div>' +
               '<div style="flex:1;min-width:0;">' +
                   '<div style="font-size:11px;color:#6b7280;margin-bottom:2px;">찜 알림</div>' +
                   '<div style="font-size:13px;color:#111827;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + message + '</div>' +
               '</div>' +
           '</div>';
       var p = toast.style;
       p.setProperty('position',      'fixed',                              'important');
       p.setProperty('bottom',        '28px',                               'important');
       p.setProperty('right',         '24px',                               'important');
       p.setProperty('display',       'inline-block',                       'important');
       p.setProperty('background',    '#ffffff',                            'important');
       p.setProperty('border-radius', '14px',                               'important');
       p.setProperty('border',        '1px solid rgba(0,0,0,0.08)',         'important');
       p.setProperty('padding',       '14px 16px',                          'important');
       p.setProperty('width',         '280px',                              'important');
       p.setProperty('height',        'auto',                               'important');
       p.setProperty('min-height',    '0',                                  'important');
       p.setProperty('box-shadow',    '0 8px 30px rgba(0,0,0,0.18)',        'important');
       p.setProperty('z-index',       '100000',                             'important');
       p.setProperty('opacity',       '0',                                  'important');
       p.setProperty('transition',    'opacity .25s,transform .25s',        'important');
       p.setProperty('transform',     'translateY(12px)',                   'important');
       document.body.appendChild(toast);
       requestAnimationFrame(function() {
           p.setProperty('opacity',   '1',                'important');
           p.setProperty('transform', 'translateY(0)',    'important');
       });
       setTimeout(function() {
           p.setProperty('opacity',   '0',                 'important');
           p.setProperty('transform', 'translateY(12px)',  'important');
           setTimeout(function() { toast.remove(); }, 260);
       }, 3500);
   }

   function changePage(pageNo) {
       $.ajax({
           url: "<%=request.getContextPath()%>/categoryproductlist.do",
           type: "GET",
           data: { 'cPage': pageNo, 'numPerpage': 32 },
           dataType: "html",
           success: function(data) { $("section").html(data); }
       });
   }

   function HeaderCategoryMenu() {
       $.ajax({
           url: "<%=request.getContextPath()%>/product/categories",
           dataType: 'json',
           success: function(data) {
               var ctx = "<%=request.getContextPath()%>";
               var $ul = $("#menuList>ul");
               $ul.html("<li><a href='" + ctx + "/product/category' id='category0'>전체</a></li>");

               var categories = {};
               data.forEach(function(row) {
                   var cat = row['CATEGORY_NAME'] || row['category_name'];
                   var sub = row['SUB_CATEGORY_NAME'] || row['sub_category_name'];
                   if (!categories[cat]) categories[cat] = [];
                   if (sub) categories[cat].push(sub);
               });

               var idx = 1;
               Object.keys(categories).forEach(function(catName) {
                   var $li = $("<li>").addClass("has-sub");
                   var $a = $("<a>").attr("href", ctx + "/product/category?name=" + encodeURIComponent(catName))
                                    .attr("id", "category" + idx)
                                    .text(catName);
                   $li.append($a);

                   var subs = categories[catName];
                   if (subs && subs.length > 0) {
                       var $subUl = $("<ul>").addClass("sub-menu");
                       subs.forEach(function(subName) {
                           var $subLi = $("<li>");
                           var $subA = $("<a>").attr("href", ctx + "/product/category?name=" + encodeURIComponent(subName))
                                              .text(subName);
                           $subLi.append($subA);
                           $subUl.append($subLi);
                       });
                       $li.append($subUl);
                   }

                   $ul.append($li);
                   idx++;
               });
           },
           error: function() {}
       });
   }

   function makeCategoryHeader(name, index) {
       categoryname = "CATEGORY_NAME = '" + name + "'";
       const $li = $("<li>");
       const $a = $("<a>").attr("href", "<%=request.getContextPath()%>/getproduct.do?categoryname="+categoryname).attr("id", "category" + (index + 1)).text(name);
       $li.append($a);
       $("#menuList>ul").append($li);
   }

   function makeCatetorySub(subcateList, index) {
       const $div=$("<div>").attr({"id":"sideMenu-category"+(index+1),"class":"sideMenu"});
       const $ul=$("<ul>");
       subcateList.forEach(sub=>{
           subcategoryname = "SUBCATEGORY_NAME = '" + sub.subCategory.subcategoryName +"'";
           const $a = $("<a>").attr("href", "<%=request.getContextPath()%>/getproduct.do?subcategroyname="+subcategoryname).text(sub.subCategory.subcategoryName);
           const $li = $("<li>").append($a);
           $ul.append($li);
       });
       $div.html($ul);
       $("div#menuList").after($div);
   }

   /* ── defer 스크립트(jQuery, SockJS, Stomp) 로드 후 DOMContentLoaded에서 초기화 ── */
   document.addEventListener('DOMContentLoaded', function() {
       HeaderCategoryMenu();

       <c:if test="${not empty sessionScope.loginUser}">
       var ctx = document.querySelector('meta[name="ctx"]').getAttribute('content');

       let socket = new SockJS('/ws');
       let stompClient = Stomp.over(socket);
       stompClient.debug = null;

       $.ajax({
           url: ctx + '/member/notification/count',
           success: function(res) {
               updateNotiBadge(res.wishCount);
               updateChatBadge(res.chatCount);
           }
       });

       stompClient.connect({}, function () {
           stompClient.subscribe("/user/queue/notify", function (message) {
               const data = JSON.parse(message.body);
               if (data.type === 'MESSAGE') {
                   updateChatBadge((parseInt(document.getElementById('chat-badge').textContent) || 0) + 1);
               } else {
                   updateNotiBadge(data.noReadCnt);
                   createToast(data.notiMessage);
               }
           });

           // 읽음 처리 후 서버가 Redis 기준으로 즉시 푸시 (DB async 지연 없음)
           stompClient.subscribe("/user/queue/badgecount", function (message) {
               const data = JSON.parse(message.body);
               if (data.chatCount !== undefined) updateChatBadge(data.chatCount);
           });
       }, function(error) {
           console.warn('WebSocket 연결 실패:', error);
       });

       document.getElementById('notiBell').addEventListener('click', function() {
           $.ajax({
               url: ctx + '/member/notification/read',
               type: 'POST',
               success: function() { updateNotiBadge(0); }
           });
       });
       </c:if>
   });

</script>
   <script src="<%=request.getContextPath()%>/js/common/header.js"></script>