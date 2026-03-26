<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
<%@ include file="../common/header.jsp"%>

<style>
.chat-list-wrapper {
    max-width: 640px;
    margin: 30px auto;
    font-family: 'Segoe UI', Tahoma, sans-serif;
}
.chat-list-title {
    font-size: 22px;
    font-weight: 700;
    color: #075e54;
    padding: 0 0 16px 0;
    border-bottom: 2px solid #075e54;
    margin-bottom: 0;
}
#chat-list-container {
    background: #fff;
    border-radius: 0 0 12px 12px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    overflow: hidden;
}
.chat-room-item {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 14px 18px;
    cursor: pointer;
    border-bottom: 1px solid #f0f2f5;
    transition: background 0.15s;
    text-decoration: none;
    color: inherit;
}
.chat-room-item:hover { background: #f7f8fa; }
.chat-room-item:last-child { border-bottom: none; }

.room-avatar {
    width: 48px; height: 48px;
    border-radius: 50%;
    background: linear-gradient(135deg, #075e54, #25d366);
    display: flex; align-items: center; justify-content: center;
    font-size: 22px;
    flex-shrink: 0;
    color: white;
}

.room-body { flex: 1; min-width: 0; }
.room-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 3px;
}
.room-product {
    font-size: 14px;
    font-weight: 600;
    color: #111;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.room-time {
    font-size: 11px;
    color: #8696a0;
    flex-shrink: 0;
    margin-left: 8px;
}
.room-bottom {
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.room-last-msg {
    font-size: 13px;
    color: #667781;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 320px;
}
.unread-badge {
    background: #25d366;
    color: white;
    font-size: 11px;
    font-weight: 700;
    border-radius: 50%;
    min-width: 20px;
    height: 20px;
    display: flex; align-items: center; justify-content: center;
    padding: 0 5px;
    flex-shrink: 0;
    margin-left: 8px;
}
.chat-empty {
    text-align: center;
    padding: 60px 0;
    color: #8696a0;
    font-size: 15px;
}
</style>

<section>
<div class="chat-list-wrapper">
    <div class="chat-list-title">💬 채팅 목록</div>
    <div id="chat-list-container">
        <c:choose>
            <c:when test="${empty rooms}">
                <div class="chat-empty">진행 중인 채팅이 없습니다.</div>
            </c:when>
            <c:otherwise>
                <c:forEach var="room" items="${rooms}">
                    <div id="chat-item-${room.roomId}"
                         class="chat-room-item"
                         onclick="openChatRoom('${room.productId}', '${room.otherUserNo}', '${room.roomId}')">
                        <div class="room-avatar">🛍️</div>
                        <div class="room-body">
                            <div class="room-top">
                                <span class="room-product">상품 #${room.productId}</span>
                                <span class="room-time">${room.lastMessageTime}</span>
                            </div>
                            <div class="room-bottom">
                                <span class="room-last-msg">${empty room.lastMessage ? '메시지 없음' : room.lastMessage}</span>
                                <c:if test="${room.unreadCount > 0}">
                                    <span class="unread-badge">${room.unreadCount}</span>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</div>
</section>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const userNo = '${sessionScope.loginUser.userNo}';
    let stompClient = null;

    // STOMP 연결
    const socket = new SockJS('/ws');
    stompClient = Stomp.over(socket);
    stompClient.debug = null;

    stompClient.connect({}, function(frame) {
        stompClient.subscribe('/topic/chat-list/' + userNo, function(message) {
            const data = JSON.parse(message.body);
            updateChatListItem(data);
        });
    });

    // 채팅방 열기
    window.openChatRoom = function(productId, targetUserNo, roomId) {
        // 읽음 처리 (chatList에서 클릭 시)
        if (stompClient && stompClient.connected) {
            stompClient.send('/app/chat/read', {}, JSON.stringify({
                roomId:      roomId,
                userNo:      userNo,
                otherUserNo: String(targetUserNo)
            }));
        }

        const popup = window.open('', 'chatPopup_' + roomId, 'width=500,height=640,resizable=yes');
        if (!popup || popup.closed) {
            alert('팝업이 차단되었습니다. 팝업 차단을 해제해주세요.');
            return;
        }

        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '/room';
        form.target = 'chatPopup_' + roomId;

        [
            { name: 'productId',    value: productId },
            { name: 'targetUserNo', value: targetUserNo },
            { name: 'roomId',       value: roomId }
        ].forEach(function(f) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = f.name;
            input.value = f.value;
            form.appendChild(input);
        });

        document.body.appendChild(form);
        form.submit();
        document.body.removeChild(form);
    };

    // 채팅 목록 실시간 업데이트
    function updateChatListItem(data) {
        const container = document.getElementById('chat-list-container');

        // 빈 상태 메시지 제거
        const empty = container.querySelector('.chat-empty');
        if (empty) empty.remove();

        const lastMsg = data.lastMessage || '메시지 없음';
        const unreadHtml = (data.unreadCount > 0)
            ? '<span class="unread-badge">' + data.unreadCount + '</span>'
            : '';

        const innerHtml =
            '<div class="room-avatar">🛍️</div>' +
            '<div class="room-body">' +
                '<div class="room-top">' +
                    '<span class="room-product">상품 #' + data.productId + '</span>' +
                '</div>' +
                '<div class="room-bottom">' +
                    '<span class="room-last-msg">' + lastMsg + '</span>' +
                    unreadHtml +
                '</div>' +
            '</div>';

        let item = document.getElementById('chat-item-' + data.roomId);
        if (item) {
            item.innerHTML = innerHtml;
            container.prepend(item); // 맨 위로 이동
        } else {
            const newItem = document.createElement('div');
            newItem.id = 'chat-item-' + data.roomId;
            newItem.className = 'chat-room-item';
            newItem.setAttribute('onclick',
                "openChatRoom('" + data.productId + "','" + data.otherUserNo + "','" + data.roomId + "')");
            newItem.innerHTML = innerHtml;
            container.prepend(newItem);
        }
    }
});
</script>

<%@ include file="../common/footer.jsp"%>
