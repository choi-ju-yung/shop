<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/common/pagination.css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/chat/chatList.css" />

<section>
<div class="cl-wrap">
    <div class="cl-header">
        <ion-icon name="chatbubbles-outline"></ion-icon>
        <h2>채팅 목록</h2>
    </div>

    <div id="chat-list-container">
        <c:choose>
            <c:when test="${empty rooms}">
                <div class="cl-empty">
                    <ion-icon name="chatbubble-ellipses-outline"></ion-icon>
                    <p>진행 중인 채팅이 없습니다.</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="room" items="${rooms}">
                    <div id="chat-item-${room.roomId}"
                         class="cl-item"
                         onclick="openChatRoom('${room.productId}', '${room.otherUserNo}', '${room.roomId}')">

                        <%-- 왼쪽: 상대방 프로필 이미지 --%>
                        <div class="cl-avatar">
                            <c:choose>
                                <c:when test="${fn:startsWith(room.otherUserImg, 'http')}">
                                    <img src="${room.otherUserImg}" alt="프로필"
                                         onerror="this.outerHTML='<ion-icon name=person-circle-outline></ion-icon>'">
                                </c:when>
                                <c:when test="${not empty room.otherUserImg}">
                                    <img src="<%=request.getContextPath()%>${room.otherUserImg}" alt="프로필"
                                         onerror="this.outerHTML='<ion-icon name=person-circle-outline></ion-icon>'">
                                </c:when>
                                <c:otherwise>
                                    <ion-icon name="person-circle-outline"></ion-icon>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <%-- 가운데: 닉네임 + 마지막 메시지 --%>
                        <div class="cl-body">
                            <span class="cl-partner">
                                <c:out value="${not empty room.otherUserName ? room.otherUserName : '상대방'}"/>
                            </span>
                            <span class="cl-last-msg">
                                ${empty room.lastMessage ? '메시지 없음' : room.lastMessage}
                            </span>
                        </div>

                        <%-- 오른쪽: 시간 + (뱃지 + 썸네일) --%>
                        <div class="cl-right">
                            <span class="cl-time" data-ts="${room.lastMessageTime}"></span>
                            <div class="cl-thumb-row">
                                <c:if test="${room.unreadCount > 0}">
                                    <span class="cl-unread">${room.unreadCount}</span>
                                </c:if>
                                <div class="cl-thumb-wrap">
                                    <c:choose>
                                        <c:when test="${not empty room.productImg}">
                                            <img class="cl-thumb"
                                                 src="<%=request.getContextPath()%>${room.productImg}"
                                                 alt="상품"
                                                 onerror="this.outerHTML='<div class=cl-thumb-placeholder><ion-icon name=bag-outline></ion-icon></div>'">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="cl-thumb-placeholder">
                                                <ion-icon name="bag-outline"></ion-icon>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
    <c:if test="${not empty rooms}">
      <c:set var="pageBaseUrl" value="?"/>
      <%@ include file="../common/pagination.jsp"%>
    </c:if>
</div>
</section>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const ctx    = document.querySelector('meta[name="ctx"]').getAttribute('content');
    const userNo = '${sessionScope.loginUser.userNo}';

    /* 시간 포맷: YYYY.MM.DD HH:MM */
    function fmtTime(ts) {
        if (!ts) return '';
        var d = new Date(ts);
        if (isNaN(d)) return '';
        return d.getFullYear() + '.' +
               String(d.getMonth()+1).padStart(2,'0') + '.' +
               String(d.getDate()).padStart(2,'0') + ' ' +
               String(d.getHours()).padStart(2,'0') + ':' +
               String(d.getMinutes()).padStart(2,'0');
    }

    document.querySelectorAll('.cl-time[data-ts]').forEach(function(el) {
        el.textContent = fmtTime(el.getAttribute('data-ts'));
    });

    /* localStorage 기반 팝업 열림 여부 확인 (페이지 새로고침 후에도 유지) */
    function isPopupOpen(roomId) {
        return localStorage.getItem('chatOpen_' + roomId) === '1';
    }

    /* WebSocket */
    let stompClient = null;
    const socket = new SockJS('/ws');
    stompClient = Stomp.over(socket);
    stompClient.debug = null;

    stompClient.connect({}, function() {
        stompClient.subscribe('/topic/chat-list/' + userNo, function(message) {
            updateChatListItem(JSON.parse(message.body));
        });
    });

    window.openChatRoom = function(productId, targetUserNo, roomId) {
        /* 미읽음 뱃지 로컬에서 즉시 제거 */
        var item = document.getElementById('chat-item-' + roomId);
        if (item) {
            var badge = item.querySelector('.cl-unread');
            if (badge) badge.remove();
        }

        if (stompClient && stompClient.connected) {
            stompClient.send('/app/chat/read', {}, JSON.stringify({
                roomId: roomId, userNo: userNo, otherUserNo: String(targetUserNo)
            }));
        }
        /* 열린 채팅방으로 등록 */
        localStorage.setItem('chatOpen_' + roomId, '1');

        const popup = window.open('', 'chatPopup_' + roomId, 'width=460,height=660,resizable=yes');
        if (!popup || popup.closed) { alert('팝업이 차단되었습니다. 팝업 차단을 해제해주세요.'); return; }
        const form = document.createElement('form');
        form.method = 'POST'; form.action = '/member/chat/room'; form.target = 'chatPopup_' + roomId;
        [
            { name: 'productId',    value: productId },
            { name: 'targetUserNo', value: targetUserNo },
            { name: 'roomId',       value: roomId }
        ].forEach(function(f) {
            const input = document.createElement('input');
            input.type = 'hidden'; input.name = f.name; input.value = f.value;
            form.appendChild(input);
        });
        document.body.appendChild(form);
        form.submit();
        document.body.removeChild(form);
    };

    function updateChatListItem(data) {
        const container  = document.getElementById('chat-list-container');
        const existingItem = document.getElementById('chat-item-' + data.roomId);

        /* ── 새 메시지가 없는 경우(읽음처리 등) → 미읽음 뱃지만 갱신, 나머지 그대로 ── */
        if (!data.lastMessage) {
            if (existingItem) {
                const row = existingItem.querySelector('.cl-thumb-row');
                if (row) {
                    const oldBadge = row.querySelector('.cl-unread');
                    if (oldBadge) oldBadge.remove();
                    if (data.unreadCount > 0 && !isPopupOpen(String(data.roomId))) {
                        const badge = document.createElement('span');
                        badge.className = 'cl-unread';
                        badge.textContent = data.unreadCount;
                        row.insertBefore(badge, row.firstChild);
                    }
                }
            }
            return;
        }

        /* ── 새 메시지가 있는 경우 → 전체 갱신 + 맨 위로 ── */
        const empty = container.querySelector('.cl-empty');
        if (empty) empty.remove();

        const unreadHtml = (data.unreadCount > 0 && !isPopupOpen(String(data.roomId)))
            ? '<span class="cl-unread">' + data.unreadCount + '</span>' : '';
        const now = fmtTime(new Date().toISOString());

        /* 기존 아이템에서 닉네임 + 썸네일 보존 */
        let existingThumb = '<div class="cl-thumb-placeholder"><ion-icon name="bag-outline"></ion-icon></div>';
        let existingName  = data.otherUserName || '';
        if (existingItem) {
            const tw = existingItem.querySelector('.cl-thumb-wrap');
            if (tw) {
                const img = tw.querySelector('img.cl-thumb');
                if (img) existingThumb = '<img class="cl-thumb" src="' + img.src + '" alt="상품">';
            }
            const partnerEl = existingItem.querySelector('.cl-partner');
            if (partnerEl && partnerEl.textContent.trim()) {
                existingName = partnerEl.textContent.trim();
            }
        }
        if (!existingName) existingName = '상대방';

        const innerHtml =
            '<div class="cl-avatar"><ion-icon name="person-circle-outline"></ion-icon></div>' +
            '<div class="cl-body">' +
                '<span class="cl-partner">' + existingName + '</span>' +
                '<span class="cl-last-msg">' + data.lastMessage + '</span>' +
            '</div>' +
            '<div class="cl-right">' +
                '<span class="cl-time">' + now + '</span>' +
                '<div class="cl-thumb-row">' +
                    unreadHtml +
                    '<div class="cl-thumb-wrap">' + existingThumb + '</div>' +
                '</div>' +
            '</div>';

        if (existingItem) {
            existingItem.innerHTML = innerHtml;
            container.prepend(existingItem);
        } else {
            const newItem = document.createElement('div');
            newItem.id        = 'chat-item-' + data.roomId;
            newItem.className = 'cl-item';
            newItem.setAttribute('onclick',
                "openChatRoom('" + data.productId + "','" + data.otherUserNo + "','" + data.roomId + "')");
            newItem.innerHTML = innerHtml;
            container.prepend(newItem);
        }
    }

    /* ── 채팅방 팝업 → 부모 창 postMessage 수신 ── */
    window.addEventListener('message', function(e) {
        if (!e.data) return;
        var rid = String(e.data.roomId);

        if (e.data.type === 'CHAT_READ') {
            // 1) 뱃지 즉시 제거
            var item = document.getElementById('chat-item-' + rid);
            if (item) {
                var badge = item.querySelector('.cl-unread');
                if (badge) badge.remove();
            }
            // 2) 헤더 채팅 뱃지 카운트 갱신
            $.ajax({
                url: ctx + '/member/notification/count',
                success: function(data) {
                    if (typeof updateChatBadge === 'function') updateChatBadge(data.noReadMCnt);
                    if (typeof updateBadge     === 'function') updateBadge(data.noReadCnt);
                }
            });
        }

        if (e.data.type === 'CHAT_CLOSED') {
            localStorage.removeItem('chatOpen_' + rid);
        }
    });
});
</script>

<%@ include file="../common/footer.jsp"%>
