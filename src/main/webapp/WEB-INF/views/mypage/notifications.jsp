<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ include file="../common/header.jsp"%>
<%@ include file="../mypage/myPageCategory.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/mypage/notifications.css" />
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/common/pagination.css" />

<div class="notiPageWrap">
  <h2 class="notiPageTitle">
    <ion-icon name="notifications"></ion-icon>
    알림
  </h2>

  <%-- 미읽음 채팅 요약 --%>
  <c:if test="${unreadChatCount > 0}">
    <a href="<%=request.getContextPath()%>/member/chat" class="notiChatSummary">
      <ion-icon name="chatbubbles-outline"></ion-icon>
      <div class="notiChatSummaryText">
        <strong>읽지 않은 채팅 ${unreadChatCount}건</strong>
        <span>채팅 목록에서 확인하세요</span>
      </div>
      <ion-icon name="chevron-forward-outline" style="margin-left:auto; color:#aaa; font-size:18px;"></ion-icon>
    </a>
  </c:if>

  <%-- WISH 알림 목록 --%>
  <c:choose>
    <c:when test="${empty notifications}">
      <div class="notiEmpty">
        <ion-icon name="notifications-off-outline"></ion-icon>
        <p>새로운 알림이 없습니다.</p>
      </div>
    </c:when>
    <c:otherwise>
      <c:set var="pageBaseUrl" value="?"/>
      <div class="notiList">
        <c:forEach var="n" items="${notifications}">
          <a href="<%=request.getContextPath()%>${n.notiUrl}"
             class="notiItem ${n.isRead == 'N' ? 'notiItem--unread' : ''}">
            <div class="notiItemIcon">
              <c:choose>
                <c:when test="${n.notificationType == 'WISH'}">
                  <ion-icon name="heart"></ion-icon>
                </c:when>
                <c:otherwise>
                  <ion-icon name="notifications-outline"></ion-icon>
                </c:otherwise>
              </c:choose>
            </div>
            <div class="notiItemBody">
              <p class="notiItemMsg"><c:out value="${n.notiMessage}"/></p>
              <span class="notiItemTime"><fmt:formatDate value="${n.createdAt}" pattern="yyyy-MM-dd HH:mm"/></span>
            </div>
            <c:if test="${n.isRead == 'N'}">
              <div class="notiUnreadDot"></div>
            </c:if>
          </a>
        </c:forEach>
      </div>
      <%@ include file="../common/pagination.jsp"%>
    </c:otherwise>
  </c:choose>
</div>

</section>
<%@ include file="../common/footer.jsp"%>
