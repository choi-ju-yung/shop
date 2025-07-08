<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
<%@ include file="../common/header.jsp"%>
    <style>
        .chat-room { margin-bottom: 10px; cursor: pointer; }
        .notification { color: red; font-weight: bold; }
    </style>
    <section>
    <title>채팅 목록</title>
    <h2>내 채팅 목록</h2>
    <div id="chat-list-container">
    <c:forEach var="room" items="${rooms}">
        <div id="chat-item-${room.roomId}" class="chat-room" onclick="openChatRoom('${room.productId}', '${room.otherUserNo}', '${room.roomId}')">
            상품번호 ${room.productId} - 마지막 메세지: ${room.lastMessage}
            <c:if test="${room.unreadCount > 0}">
                <span class="notification">(${room.unreadCount})</span>
            </c:if>
        </div>
    </c:forEach>
	</section>
    <script>
    document.addEventListener('DOMContentLoaded', function() {

        function openChatRoom(productId, targetUserNo, roomId) {
            const popup = window.open('', 'chatPopup', 'width=500,height=600');
            if (!popup || popup.closed || typeof popup.closed === 'undefined') {
                alert("팝업이 차단되었습니다. 팝업 차단을 해제해주세요.");
                return;
            }

            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '/room';
            form.target = 'chatPopup';

            const fields = [
                { name: 'productId', value: productId },
                { name: 'targetUserNo', value: targetUserNo },
                { name: 'roomId', value: roomId }
            ];

            fields.forEach(field => {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = field.name;
                input.value = field.value;
                form.appendChild(input);
            });
            
            const payload = {
                    roomId: roomId,
                    userNo: userNo
            };
            stompClient.send("/app/chat/read", {}, JSON.stringify(payload)); // 채팅리스트에서 각 채팅방눌렀을때 읽음처리
            
            document.body.appendChild(form);
            form.submit();
            document.body.removeChild(form);
        }

        window.openChatRoom = openChatRoom; // 전역에 등록 필수!

        // STOMP 연결도 여기에
        let socket = new SockJS('/ws');
        let stompClient = Stomp.over(socket);
        let userNo = '${sessionScope.loginUser.userNo}'; // 로그인 유저 번호

        stompClient.connect({}, function(frame) {
            stompClient.subscribe('/topic/chat-list/' + userNo, function(message) {
                const data = JSON.parse(message.body);
                updateChatListItem(data);
            });
        });

        function updateChatListItem(data) {
            const container = document.getElementById("chat-list-container");
            let item = document.getElementById("chat-item-" + data.roomId);
            data.lastMessage = data.lastMessage ?? ""  // 메시지가 없는상태에서 메시지리스트 null 값 방지
            let html = 
                "상품번호 " + data.productId + " - 마지막 메세지: " + data.lastMessage +
                (data.unreadCount > 0 ? " <span class=\"notification\">(" + data.unreadCount + ")</span>" : "");

            if (item) {
                item.innerHTML = html;
            } else {
                const newItem = document.createElement("div");
                newItem.id = "chat-item-" + data.roomId;
                newItem.className = "chat-room";
                newItem.setAttribute("onclick", "openChatRoom('" + data.productId + "', '" + data.otherUserNo + "', '" + data.roomId + "')");
                newItem.innerHTML = html;
                container.prepend(newItem);
            }
        }
    });
    
    
    </script>
    
    <%@ include file="../common/footer.jsp"%>
