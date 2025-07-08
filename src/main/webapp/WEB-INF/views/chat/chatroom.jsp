<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>채팅방</title>
    <style>
        #chatArea {
            height: 400px;
            overflow-y: auto;
            border: 1px solid #ddd;
            padding: 10px;
            background: #f9f9f9;
        }

        .chat-message {
            margin: 5px 0;
            padding: 8px 12px;
            border-radius: 15px;
            max-width: 70%;
            display: inline-block;
            clear: both;
            word-wrap: break-word;
        }

        .my-message {
            background-color: #d1e7dd;
            float: right;
            text-align: right;
        }

        .other-message {
            background-color: #e2e3e5;
            float: left;
        }

        #inputContainer {
            margin-top: 10px;
        }

        #messageInput {
            width: 80%;
        }

        button {
            width: 18%;
        }
    </style>
</head>
<body>
    <h2>채팅방 - 상품 ${productId} / 상대방 ${targetUserNo}</h2>
    
    <input type="hidden" id="productId" value="${productId}">
    <input type="hidden" id="targetUserNo" value="${targetUserNo}">
    <input type="hidden" id="userId" value="${sessionScope.loginUser.userNo}">
    <input type="hidden" id="roomId" value="${roomId}">

    <div id="chatArea">
    	<c:forEach var="msg" items="${messages}">
        <div class="chat-message ${msg.senderNo == sessionScope.loginUser.userNo ? 'my-message' : 'other-message'}">
            <div><strong>${msg.senderName}</strong></div>
            <div>${msg.message}</div>
            <div style="font-size: 0.8em; color: gray;">${msg.sentAt}</div>
        </div>
       </c:forEach>
    </div>

    <div id="inputContainer">
        <input type="text" id="messageInput" placeholder="메시지를 입력하세요" onkeydown="if(event.key==='Enter') sendMessage();">
        <button onclick="sendMessage()">전송</button>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1.5.2/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>

    <script>
        const sock = new SockJS('/ws');
        const stompClient = Stomp.over(sock);

        const productId = document.getElementById('productId').value;
        const targetUserNo = document.getElementById('targetUserNo').value;
        const userId = document.getElementById('userId').value;
        const roomId = document.getElementById('roomId').value;

        stompClient.connect({}, function(frame) {
            console.log("WebSocket 연결됨:", frame);

            // 채팅 메시지 수신 시 화면에 출력
            stompClient.subscribe('/user/queue/chat/', function(message) {
                const msg = JSON.parse(message.body);

                const chatArea = document.getElementById('chatArea');
                const messageDiv = document.createElement('div');
                messageDiv.classList.add('chat-message');

                if (msg.senderNo == userId) {
                    messageDiv.classList.add('my-message');
                } else {
                    messageDiv.classList.add('other-message');
                }

                messageDiv.innerHTML =
                    '<div><strong>' + msg.senderName + '</strong></div>' +
                    '<div>' + msg.message + '</div>' +
                    '<div style="font-size: 0.8em; color: gray;">' + formatTimestamp(msg.sentAt) + '</div>';
                    
                chatArea.appendChild(messageDiv);
                chatArea.scrollTop = chatArea.scrollHeight;
            });

        });

        // 메시지 전송
        function sendMessage() {
            const message = document.getElementById('messageInput').value.trim();
            if (message === "") return;

            stompClient.send('/app/chat/send/' + roomId, {}, 
                JSON.stringify({ roomId: roomId, senderNo: userId, message: message, receiverNo : targetUserNo }));
            document.getElementById('messageInput').value = '';
        }

        function formatTimestamp(timestamp) {
            const date = new Date(timestamp);
            const yyyy = date.getFullYear();
            const MM = (date.getMonth() + 1).toString().padStart(2, '0');
            const dd = date.getDate().toString().padStart(2, '0');
            const HH = date.getHours().toString().padStart(2, '0');
            const mm = date.getMinutes().toString().padStart(2, '0');
            const ss = date.getSeconds().toString().padStart(2, '0');
            return yyyy + '-' + MM + '-' + dd + ' ' + HH + ':' + mm + ':' + ss + '.0';
        }

        // 📌 디바운스 방식의 읽음 처리
        let readTimeout = null;

        function debounceReadReceipt() {
            clearTimeout(readTimeout);
            readTimeout = setTimeout(sendReadReceipt, 300); // 300ms 후 실행
        }

        function sendReadReceipt() {
            if (stompClient && stompClient.connected) {
                const payload = {
                    roomId: roomId,
                    userNo: userId
                };
                stompClient.send("/app/chat/read", {}, JSON.stringify(payload));
                console.log("읽음 처리 전송");
            }
        }

        // ✅ 이벤트 리스너 등록
        document.addEventListener("DOMContentLoaded", function () {
            const chatArea = document.getElementById("chatArea");
            const messageInput = document.getElementById("messageInput");
			
            chatArea.scrollTop = chatArea.scrollHeight; // 입장시 스크롤 아래로 이동

            // 1. 채팅창 클릭
            chatArea.addEventListener("click", debounceReadReceipt);

            // 2. 입력창 클릭
            messageInput.addEventListener("click", debounceReadReceipt);

            // 3. 키보드 입력
            messageInput.addEventListener("keydown", debounceReadReceipt);

            // 4. 창 포커스 얻을 때
            window.addEventListener("focus", debounceReadReceipt);
        });
    </script>
    </script>
</body>
</html>
