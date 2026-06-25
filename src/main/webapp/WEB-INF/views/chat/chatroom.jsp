<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<title>채팅방</title>
<link rel="stylesheet" href="/css/chat/chatroom.css" />
<style>
.typing-bubble { display:flex; gap:4px; align-items:center; padding:10px 14px; }
.typing-bubble .dot {
    width:7px; height:7px; background:#aaa; border-radius:50%;
    animation: typingDot 1.2s infinite;
}
.typing-bubble .dot:nth-child(2) { animation-delay:.2s; }
.typing-bubble .dot:nth-child(3) { animation-delay:.4s; }
@keyframes typingDot {
    0%,60%,100% { transform:translateY(0); opacity:.4; }
    30%          { transform:translateY(-5px); opacity:1; }
}
</style>
</head>
<body>

<input type="hidden" id="productId"   value="${productId}">
<input type="hidden" id="targetUserNo" value="${targetUserNo}">
<input type="hidden" id="userId"       value="${sessionScope.loginUser.userNo}">
<input type="hidden" id="roomId"       value="${roomId}">

<div id="chatHeader">
    <%-- 상단: 상대방 이름 --%>
    <div class="header-top">
        <div class="header-user-dot"></div>
        <c:choose>
            <c:when test="${room.OTHER_USER_DELETED == 'Y'}">
                <span class="header-user-name withdrawn">${room.OTHER_USER_NAME}</span>
                <span class="header-withdrawn-badge">탈퇴</span>
            </c:when>
            <c:otherwise>
                <span class="header-user-name">${room.OTHER_USER_NAME}</span>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- 하단: 상품 카드 --%>
    <div class="header-product-card">
        <c:choose>
            <c:when test="${not empty room.PRODUCT_IMG}">
                <img class="header-product-img" src="${room.PRODUCT_IMG}" alt="상품 이미지"
                     onerror="this.outerHTML='<div class=\'header-product-img-placeholder\'><ion-icon name=\'bag-outline\'></ion-icon></div>'">
            </c:when>
            <c:otherwise>
                <div class="header-product-img-placeholder">
                    <ion-icon name="${room.PRODUCT_DELETED == 'Y' ? 'ban-outline' : 'bag-outline'}"></ion-icon>
                </div>
            </c:otherwise>
        </c:choose>

        <div class="header-product-info">
            <c:choose>
                <c:when test="${room.PRODUCT_DELETED == 'Y'}">
                    <div class="header-product-title deleted">${room.PRODUCT_TITLE}</div>
                    <div class="header-deleted-notice">판매자가 삭제한 상품입니다</div>
                </c:when>
                <c:otherwise>
                    <div class="header-product-title">${room.PRODUCT_TITLE}</div>
                    <div class="header-product-price">
                        <fmt:formatNumber value="${room.PRODUCT_PRICE}" pattern="#,###"/>원
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </div>
</div>

<div id="chatArea">
    <c:forEach var="msg" items="${messages}">
        <c:choose>
            <c:when test="${msg.senderNo == sessionScope.loginUser.userNo}">
                <div class="msg-wrap mine">
                    <div class="bubble">${msg.message}</div>
                    <div class="msg-meta">
                        <span class="msg-time" data-ts="${msg.sentAt}"></span>
                        <span class="read-badge ${msg.isRead == 'Y' ? 'done' : ''}">${msg.isRead == 'Y' ? '읽음' : '1'}</span>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="msg-wrap other">
                    <div class="sender-name">${msg.senderName}</div>
                    <div class="bubble">${msg.message}</div>
                    <div class="msg-meta"><span class="msg-time" data-ts="${msg.sentAt}"></span></div>
                </div>
            </c:otherwise>
        </c:choose>
    </c:forEach>
</div>

<!-- 이모티콘 피커 (inputContainer 바로 위) -->
<div id="emojiPicker">
    <div class="emoji-cats">
        <button class="emoji-cat-btn active" data-cat="face"    title="표정">😊</button>
        <button class="emoji-cat-btn"        data-cat="gesture" title="제스처">👍</button>
        <button class="emoji-cat-btn"        data-cat="heart"   title="하트">❤️</button>
        <button class="emoji-cat-btn"        data-cat="etc"     title="기타">🎉</button>
    </div>
    <div class="emoji-grid" id="emojiGrid"></div>
</div>

<div id="typingIndicator" style="display:none; padding:4px 12px;">
    <div class="msg-wrap other" style="margin:0;">
        <div class="bubble typing-bubble">
            <span class="dot"></span><span class="dot"></span><span class="dot"></span>
        </div>
    </div>
</div>

<div id="inputContainer">
    <button id="emojiBtn" title="이모티콘">😊</button>
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

const _seenMsgKeys = new Set();

stompClient.connect({}, function(frame) {

    // 1) 팝업 열림 등록 + 입장 시 즉시 읽음 처리
    localStorage.setItem('chatOpen_' + roomId, '1');
    sendReadReceipt();

    // 2) 메시지 수신
    stompClient.subscribe('/user/queue/chat/', function(message) {
        const msg = JSON.parse(message.body);

        // 8080/8081 양쪽 Redis 구독자가 각각 전송할 수 있어 중복 방어
        const key = msg.senderNo + '_' + msg.sentAt;
        if (_seenMsgKeys.has(key)) return;
        _seenMsgKeys.add(key);

        appendMessage(msg);

        // 상대방 메시지가 오면 → 바로 읽음 처리 (내가 보고 있으므로)
        if (msg.senderNo != userId) {
            sendReadReceipt();
        }
    });

    // 3) 타이핑 상태 수신 → ... 인디케이터 표시/숨김
    stompClient.subscribe('/user/queue/typing', function(message) {
        const data = JSON.parse(message.body);
        if (String(data.roomId) !== String(roomId)) return;
        const indicator = document.getElementById('typingIndicator');
        const chatArea  = document.getElementById('chatArea');
        indicator.style.display = data.typing ? 'block' : 'none';
        if (data.typing) chatArea.scrollTop = chatArea.scrollHeight;
    });

    // 4) 읽음 확인 수신 → 내 메시지 "읽음"으로 업데이트
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
    clearTimeout(_typingTimer);
    _isTyping = false;
    sendTyping(false);
    input.value = '';
    input.focus();
}

let _typingTimer = null;
let _isTyping = false;
function sendTyping(isTyping) {
    if (stompClient && stompClient.connected) {
        stompClient.send('/app/chat/typing/' + roomId, {}, JSON.stringify({
            senderNo:   parseInt(userId),
            receiverNo: parseInt(targetUserNo),
            typing:     isTyping
        }));
    }
}

function sendReadReceipt() {
    if (stompClient && stompClient.connected) {
        stompClient.send('/app/chat/read', {}, JSON.stringify({
            roomId:      roomId,
            userNo:      userId,
            otherUserNo: targetUserNo
        }));
        // 부모 창에 읽음 처리 완료 신호
        if (window.opener && !window.opener.closed) {
            window.opener.postMessage({ type: 'CHAT_READ', roomId: roomId }, '*');
        }
    }
}

function formatTimestamp(ts) {
    if (!ts) return '';
    const d = new Date(ts);
    if (isNaN(d)) return '';
    const yyyy = d.getFullYear();
    const MM   = String(d.getMonth() + 1).padStart(2, '0');
    const dd   = String(d.getDate()).padStart(2, '0');
    const HH   = String(d.getHours()).padStart(2, '0');
    const mm   = String(d.getMinutes()).padStart(2, '0');
    return yyyy + '.' + MM + '.' + dd + ' ' + HH + ':' + mm;
}

function escapeHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
}

// 엔터 전송
document.getElementById('messageInput').addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && !e.isComposing) sendMessage();
});

document.getElementById('messageInput').addEventListener('input', function() {
    if (this.value.length === 0) {
        clearTimeout(_typingTimer);
        if (_isTyping) { _isTyping = false; sendTyping(false); }
    } else if (!_isTyping) {
        _isTyping = true;
        sendTyping(true);
    }
});

/* ── 이모티콘 피커 ── */
var EMOJIS = {
    face: [
        '😀','😃','😄','😁','😆','😅','🤣','😂','🙂','😊','😇','🥰','😍','🤩','😘',
        '😋','😛','😜','🤪','😎','🥺','😢','😭','😤','😡','🤬','🤔','😴','🥳','🤗',
        '😬','🙄','😐','😑','🫠','🥴','😳','😱','😨','😰','😮','🤐','😷','🤒','🤕'
    ],
    gesture: [
        '👍','👎','👊','✊','🤛','🤜','🤞','✌️','🤟','👌','🤌','🤏','👈','👉','👆',
        '👇','☝️','👋','✋','🖐️','🤚','🫶','🤝','🙏','💪','👏','🙌','🫰','🤲','👐'
    ],
    heart: [
        '❤️','🧡','💛','💚','💙','💜','🖤','🤍','🤎','💔','❤️‍🔥','💕','💞','💓',
        '💗','💖','💘','💝','💌','💋','😍','🥰','😘','💑','👫','👬','👭'
    ],
    etc: [
        '🎉','🎊','🎈','🎁','🔥','✨','💫','⭐','🌟','💥','💯','✅','❌','⚡','🌈',
        '🍀','🌸','🌺','🍕','🍔','☕','🧋','🏆','🎮','🎵','🎶','📱','💻','📷','📚',
        '🐶','🐱','🐻','🐼','🐨','🦊','🐸','🐧','🌍','🚀','🎸','🎤','🎧','🎬','🃏'
    ]
};

var currentCat = 'face';

function renderEmojis(cat) {
    var grid = document.getElementById('emojiGrid');
    grid.innerHTML = '';
    EMOJIS[cat].forEach(function(emoji) {
        var btn = document.createElement('button');
        btn.className = 'emoji-item';
        btn.textContent = emoji;
        btn.addEventListener('click', function(e) {
            e.stopPropagation();
            insertEmoji(emoji);
        });
        grid.appendChild(btn);
    });
}

function toggleEmojiPicker(e) {
    e.stopPropagation();
    var picker = document.getElementById('emojiPicker');
    var emojiBtn = document.getElementById('emojiBtn');
    var isOpen = picker.style.display === 'block';
    picker.style.display = isOpen ? 'none' : 'block';
    emojiBtn.classList.toggle('active', !isOpen);
    if (!isOpen) renderEmojis(currentCat);
}

function insertEmoji(emoji) {
    var input = document.getElementById('messageInput');
    var start = input.selectionStart || 0;
    var end   = input.selectionEnd   || 0;
    input.value = input.value.slice(0, start) + emoji + input.value.slice(end);
    input.selectionStart = input.selectionEnd = start + emoji.length;
    input.focus();
}

document.getElementById('emojiBtn').addEventListener('click', toggleEmojiPicker);

document.querySelectorAll('.emoji-cat-btn').forEach(function(btn) {
    btn.addEventListener('click', function(e) {
        e.stopPropagation();
        document.querySelectorAll('.emoji-cat-btn').forEach(function(b) { b.classList.remove('active'); });
        this.classList.add('active');
        currentCat = this.dataset.cat;
        renderEmojis(currentCat);
    });
});

// 피커 외부 클릭 시 닫기
document.addEventListener('click', function() {
    var picker = document.getElementById('emojiPicker');
    picker.style.display = 'none';
    document.getElementById('emojiBtn').classList.remove('active');
});

// 다른 탭에서 로그아웃하면 채팅 입력 비활성화
window.addEventListener('storage', function(e) {
    if (e.key === 'shopLogout') {
        if (stompClient && stompClient.connected) stompClient.disconnect();
        var inputContainer = document.getElementById('inputContainer');
        inputContainer.innerHTML = '<p style="color:#999;text-align:center;padding:12px;margin:0;">로그아웃되어 메시지를 보낼 수 없습니다.</p>';
    }
});

// 팝업 닫힐 때 localStorage 정리 + 부모 창에 알림
window.addEventListener('beforeunload', function() {
    localStorage.removeItem('chatOpen_' + roomId);
    if (window.opener && !window.opener.closed) {
        window.opener.postMessage({ type: 'CHAT_CLOSED', roomId: roomId }, '*');
    }
});

// 초기 시간 포맷 + 스크롤 아래로
window.addEventListener('load', function() {
    document.querySelectorAll('.msg-time[data-ts]').forEach(function(el) {
        el.textContent = formatTimestamp(el.getAttribute('data-ts'));
    });
    const chatArea = document.getElementById('chatArea');
    chatArea.scrollTop = chatArea.scrollHeight;
});
</script>
</body>
</html>
