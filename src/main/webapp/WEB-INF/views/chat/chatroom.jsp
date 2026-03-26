<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<title>채팅방</title>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
    font-family: 'Segoe UI', Tahoma, sans-serif;
    background: #ece5dd;
    display: flex;
    flex-direction: column;
    height: 100vh;
    overflow: hidden;
}

/* 헤더 */
#chatHeader {
    background: #075e54;
    color: white;
    padding: 12px 16px;
    display: flex;
    align-items: center;
    gap: 12px;
    flex-shrink: 0;
    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
}
.header-avatar {
    width: 40px; height: 40px;
    border-radius: 50%;
    background: #25d366;
    display: flex; align-items: center; justify-content: center;
    font-size: 20px;
}
.header-info .name { font-size: 15px; font-weight: 600; }
.header-info .status { font-size: 12px; color: #b2dfdb; }

/* 채팅 영역 */
#chatArea {
    flex: 1;
    overflow-y: auto;
    padding: 12px 16px;
    display: flex;
    flex-direction: column;
    gap: 4px;
}

/* 메시지 래퍼 */
.msg-wrap {
    display: flex;
    flex-direction: column;
    max-width: 70%;
}
.msg-wrap.mine  { align-self: flex-end;   align-items: flex-end; }
.msg-wrap.other { align-self: flex-start; align-items: flex-start; }

.sender-name {
    font-size: 11px;
    color: #667781;
    margin-bottom: 2px;
    padding: 0 4px;
}

/* 말풍선 */
.bubble {
    padding: 8px 12px;
    font-size: 14px;
    line-height: 1.5;
    word-break: break-word;
    box-shadow: 0 1px 2px rgba(0,0,0,0.12);
}
.mine  .bubble { background: #dcf8c6; border-radius: 12px 2px 12px 12px; }
.other .bubble { background: #ffffff; border-radius: 2px 12px 12px 12px; }

/* 시간 + 읽음 */
.msg-meta {
    display: flex;
    align-items: center;
    gap: 4px;
    margin-top: 3px;
    padding: 0 4px;
    font-size: 11px;
    color: #8696a0;
}
.mine .msg-meta { justify-content: flex-end; }

.read-badge {
    font-size: 11px;
    font-weight: 700;
    color: #f39c12;
}
.read-badge.done { color: #53bdeb; }

/* 입력창 */
#inputContainer {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 12px;
    background: #f0f2f5;
    border-top: 1px solid #d9dbdc;
    flex-shrink: 0;
}
#messageInput {
    flex: 1;
    padding: 10px 16px;
    border: none;
    border-radius: 24px;
    background: white;
    font-size: 14px;
    outline: none;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}
#sendBtn {
    width: 44px; height: 44px;
    border: none;
    border-radius: 50%;
    background: #075e54;
    color: white;
    font-size: 20px;
    cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    transition: background 0.2s;
}
#sendBtn:hover { background: #128c7e; }
</style>
</head>
<body>

<input type="hidden" id="productId"   value="${productId}">
<input type="hidden" id="targetUserNo" value="${targetUserNo}">
<input type="hidden" id="userId"       value="${sessionScope.loginUser.userNo}">
<input type="hidden" id="roomId"       value="${roomId}">

<div id="chatHeader">
    <div class="header-avatar">💬</div>
    <div class="header-info">
        <div class="name">상품 #${productId} 채팅</div>
        <div class="status">상대방 #${targetUserNo}</div>
    </div>
</div>

<div id="chatArea">
    <c:forEach var="msg" items="${messages}">
        <c:choose>
            <c:when test="${msg.senderNo == sessionScope.loginUser.userNo}">
                <div class="msg-wrap mine">
                    <div class="bubble">${msg.message}</div>
                    <div class="msg-meta">
                        <span>${msg.sentAt}</span>
                        <span class="read-badge ${msg.isRead == 'Y' ? 'done' : ''}">${msg.isRead == 'Y' ? '읽음' : '1'}</span>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="msg-wrap other">
                    <div class="sender-name">${msg.senderName}</div>
                    <div class="bubble">${msg.message}</div>
                    <div class="msg-meta"><span>${msg.sentAt}</span></div>
                </div>
            </c:otherwise>
        </c:choose>
    </c:forEach>
</div>

<div id="inputContainer">
    <input type="text" id="messageInput" placeholder="메시지를 입력하세요">
    <button id="sendBtn" onclick="sendMessage()">&#10148;</button>
</div>

<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1.5.2/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
<script>
const productId    = document.getElementById('productId').value;
const targetUserNo = document.getElementById('targetUserNo').value;
const userId       = document.getElementById('userId').value;
const roomId       = document.getElementById('roomId').value;

const sock = new SockJS('/ws');
const stompClient = Stomp.over(sock);
stompClient.debug = null; // 콘솔 노이즈 제거

stompClient.connect({}, function(frame) {

    // 1) 채팅방 진입 즉시 읽음 처리
    sendReadReceipt();

    // 2) 메시지 수신
    stompClient.subscribe('/user/queue/chat/', function(message) {
        const msg = JSON.parse(message.body);
        appendMessage(msg);

        // 상대방 메시지가 오면 → 바로 읽음 처리 (내가 보고 있으므로)
        if (msg.senderNo != userId) {
            sendReadReceipt();
        }
    });

    // 3) 읽음 확인 수신 → 내 메시지 "읽음"으로 업데이트
    stompClient.subscribe('/user/queue/read', function(message) {
        const data = JSON.parse(message.body);
        if (String(data.roomId) === String(roomId)) {
            document.querySelectorAll('.read-badge').forEach(function(el) {
                el.textContent = '읽음';
                el.classList.add('done');
            });
        }
    });
});

function appendMessage(msg) {
    const chatArea = document.getElementById('chatArea');
    const wrap = document.createElement('div');
    wrap.classList.add('msg-wrap');

    const time = formatTimestamp(msg.sentAt);

    if (String(msg.senderNo) === String(userId)) {
        wrap.classList.add('mine');
        wrap.innerHTML =
            '<div class="bubble">' + escapeHtml(msg.message) + '</div>' +
            '<div class="msg-meta">' +
                '<span>' + time + '</span>' +
                '<span class="read-badge">1</span>' +
            '</div>';
    } else {
        wrap.classList.add('other');
        wrap.innerHTML =
            '<div class="sender-name">' + escapeHtml(msg.senderName || '') + '</div>' +
            '<div class="bubble">' + escapeHtml(msg.message) + '</div>' +
            '<div class="msg-meta"><span>' + time + '</span></div>';
    }

    chatArea.appendChild(wrap);
    chatArea.scrollTop = chatArea.scrollHeight;
}

function sendMessage() {
    const input = document.getElementById('messageInput');
    const message = input.value.trim();
    if (!message) return;

    stompClient.send('/app/chat/send/' + roomId, {}, JSON.stringify({
        roomId:     roomId,
        senderNo:   userId,
        message:    message,
        receiverNo: targetUserNo
    }));
    input.value = '';
    input.focus();
}

function sendReadReceipt() {
    if (stompClient && stompClient.connected) {
        stompClient.send('/app/chat/read', {}, JSON.stringify({
            roomId:      roomId,
            userNo:      userId,
            otherUserNo: targetUserNo
        }));
    }
}

function formatTimestamp(ts) {
    if (!ts) return '';
    const d = new Date(ts);
    if (isNaN(d)) return '';
    const HH = String(d.getHours()).padStart(2, '0');
    const mm = String(d.getMinutes()).padStart(2, '0');
    return HH + ':' + mm;
}

function escapeHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
}

// 엔터 전송
document.getElementById('messageInput').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') sendMessage();
});

// 초기 스크롤 아래로
window.addEventListener('load', function() {
    const chatArea = document.getElementById('chatArea');
    chatArea.scrollTop = chatArea.scrollHeight;
});
</script>
</body>
</html>
