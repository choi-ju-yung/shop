<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<title>채팅방</title>
<link rel="stylesheet" href="/css/chat/chatroom.css" />
</head>
<body>

<input type="hidden" id="productId"   value="${productId}">
<input type="hidden" id="targetUserNo" value="${targetUserNo}">
<input type="hidden" id="userId"       value="${sessionScope.loginUser.userNo}">
<input type="hidden" id="roomId"       value="${roomId}">

<div id="chatHeader">
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
                <%-- 내 메시지 (오른쪽) --%>
                <div class="msg-row mine">
                    <div class="msg-side">
                        <c:if test="${msg.isRead != 'Y'}">
                            <span class="read-cnt">1</span>
                        </c:if>
                        <span class="msg-time" data-ts="${msg.sentAt.time}"></span>
                    </div>
                    <div class="bubble">${msg.message}</div>
                </div>
            </c:when>
            <c:otherwise>
                <%-- 상대방 메시지 (왼쪽) --%>
                <div class="msg-row other">
                    <div class="msg-col">
                        <span class="sender-name">${msg.senderName}</span>
                        <div class="msg-bubble-row">
                            <div class="bubble">${msg.message}</div>
                            <div class="msg-side">
                                <span class="msg-time" data-ts="${msg.sentAt.time}"></span>
                            </div>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </c:forEach>
</div>

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
    <div class="msg-row other" style="margin:0;">
        <div class="msg-col">
            <div class="msg-bubble-row">
                <div class="bubble typing-bubble">
                    <span class="dot"></span><span class="dot"></span><span class="dot"></span>
                </div>
            </div>
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
stompClient.debug = null;

const _seenMsgKeys = new Set();

stompClient.connect({}, function(frame) {

    localStorage.setItem('chatOpen_' + roomId, '1');
    sendReadReceipt();

    stompClient.subscribe('/user/queue/chat/', function(message) {
        const msg = JSON.parse(message.body);

        if (String(msg.roomId) !== String(roomId)) return;

        const key = msg.senderNo + '_' + msg.sentAt;
        if (_seenMsgKeys.has(key)) return;
        _seenMsgKeys.add(key);

        appendMessage(msg);

        if (msg.senderNo != userId) {
            sendReadReceipt();
        }
    });

    stompClient.subscribe('/user/queue/typing', function(message) {
        const data = JSON.parse(message.body);
        if (String(data.roomId) !== String(roomId)) return;
        const indicator = document.getElementById('typingIndicator');
        const chatArea  = document.getElementById('chatArea');
        indicator.style.display = data.typing ? 'block' : 'none';
        if (data.typing) chatArea.scrollTop = chatArea.scrollHeight;
    });

    stompClient.subscribe('/user/queue/read', function(message) {
        const data = JSON.parse(message.body);
        if (String(data.roomId) === String(roomId)) {
            document.querySelectorAll('.read-cnt').forEach(function(el) {
                el.style.display = 'none';
            });
        }
    });
});

function appendMessage(msg) {
    const chatArea = document.getElementById('chatArea');
    const wrap = document.createElement('div');
    wrap.classList.add('msg-row');

    const time = formatTime(new Date().toISOString());

    if (String(msg.senderNo) === String(userId)) {
        wrap.classList.add('mine');
        wrap.innerHTML =
            '<div class="msg-side">' +
                '<span class="read-cnt">1</span>' +
                '<span class="msg-time">' + time + '</span>' +
            '</div>' +
            '<div class="bubble">' + escapeHtml(msg.message) + '</div>';
    } else {
        wrap.classList.add('other');
        wrap.innerHTML =
            '<div class="msg-col">' +
                '<span class="sender-name">' + escapeHtml(msg.senderName || '') + '</span>' +
                '<div class="msg-bubble-row">' +
                    '<div class="bubble">' + escapeHtml(msg.message) + '</div>' +
                    '<div class="msg-side">' +
                        '<span class="msg-time">' + time + '</span>' +
                    '</div>' +
                '</div>' +
            '</div>';
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
        if (window.opener && !window.opener.closed) {
            window.opener.postMessage({ type: 'CHAT_READ', roomId: roomId }, '*');
        }
    }
}

function formatTime(ts) {
    if (!ts) return '';
    const d = new Date(ts);
    if (isNaN(d)) return '';
    const h = d.getHours();
    const m = String(d.getMinutes()).padStart(2, '0');
    const ampm = h < 12 ? '오전' : '오후';
    const h12 = h % 12 || 12;
    return ampm + ' ' + h12 + ':' + m;
}

function escapeHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
}

function insertDateSeparators() {
    const chatArea = document.getElementById('chatArea');
    const rows = chatArea.querySelectorAll('.msg-row');
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    let prevDateStr = null;

    rows.forEach(function(row) {
        const timeEl = row.querySelector('.msg-time[data-ts]');
        if (!timeEl) return;
        const ts = timeEl.getAttribute('data-ts');
        if (!ts) return;
        const d = new Date(ts);
        if (isNaN(d)) return;
        const dateStr = d.getFullYear() + '-' + d.getMonth() + '-' + d.getDate();
        if (prevDateStr !== dateStr) {
            prevDateStr = dateStr;
            const sep = document.createElement('div');
            sep.className = 'date-sep';
            sep.innerHTML = '<span class="date-sep-inner">📅 ' +
                d.getFullYear() + '년 ' + (d.getMonth() + 1) + '월 ' +
                d.getDate() + '일 ' + days[d.getDay()] + '요일</span>';
            chatArea.insertBefore(sep, row);
        }
    });
}

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

document.addEventListener('click', function() {
    var picker = document.getElementById('emojiPicker');
    picker.style.display = 'none';
    document.getElementById('emojiBtn').classList.remove('active');
});

window.addEventListener('storage', function(e) {
    if (e.key === 'shopLogout') {
        if (stompClient && stompClient.connected) stompClient.disconnect();
        var inputContainer = document.getElementById('inputContainer');
        inputContainer.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;gap:8px;padding:14px;color:#9ca3af;font-size:13px;"><ion-icon name="lock-closed-outline" style="font-size:16px;"></ion-icon>로그아웃 상태입니다. 다시 로그인해 주세요.</div>';
    }
});

window.addEventListener('beforeunload', function() {
    localStorage.removeItem('chatOpen_' + roomId);
    if (window.opener && !window.opener.closed) {
        window.opener.postMessage({ type: 'CHAT_CLOSED', roomId: roomId }, '*');
    }
});

window.addEventListener('load', function() {
    document.querySelectorAll('.msg-time[data-ts]').forEach(function(el) {
        el.textContent = formatTime(el.getAttribute('data-ts'));
    });
    insertDateSeparators();
    const chatArea = document.getElementById('chatArea');
    chatArea.scrollTop = chatArea.scrollHeight;
});
</script>
</body>
</html>
