<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!DOCTYPE html>
<html>
<head>
<title>채팅방</title>
<style>
@import url("https://cdn.jsdelivr.net/gh/projectnoonnu/noonfonts_20-04@2.1/NEXON Lv2 Gothic.woff");
* { box-sizing: border-box; margin: 0; padding: 0; font-family: 'NEXON Lv2 Gothic', 'Segoe UI', sans-serif; }

body {
    background: #f5f7fa;
    display: flex;
    flex-direction: column;
    height: 100vh;
    overflow: hidden;
}

/* ── 헤더 ── */
#chatHeader {
    background: #fff;
    border-bottom: 1px solid #e9ecef;
    padding: 0 14px;
    flex-shrink: 0;
    box-shadow: 0 1px 6px rgba(0,0,0,0.06);
}

/* 상단: 상대방 이름 바 */
.header-top {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 0 8px;
    border-bottom: 1px solid #f3f4f6;
}

.header-user-dot {
    width: 8px; height: 8px;
    border-radius: 50%;
    background: #20c997;
    flex-shrink: 0;
}

.header-user-name {
    font-size: 15px;
    font-weight: 700;
    color: #111827;
    flex: 1;
}

.header-user-name.withdrawn {
    color: #9ca3af;
    font-style: italic;
}

.header-withdrawn-badge {
    font-size: 10px;
    background: #f3f4f6;
    color: #6b7280;
    border-radius: 4px;
    padding: 2px 6px;
    font-weight: 600;
}

/* 하단: 상품 카드 */
.header-product-card {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 8px 0 10px;
}

.header-product-img {
    width: 44px; height: 44px;
    border-radius: 8px;
    object-fit: cover;
    flex-shrink: 0;
    border: 1px solid #e5e7eb;
}

.header-product-img-placeholder {
    width: 44px; height: 44px;
    border-radius: 8px;
    background: #f0fdf9;
    border: 1px solid #d1fae5;
    display: flex; align-items: center; justify-content: center;
    font-size: 20px;
    flex-shrink: 0;
    color: #20c997;
}

.header-product-info { flex: 1; min-width: 0; }

.header-product-title {
    font-size: 13px;
    font-weight: 600;
    color: #1f2937;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    margin-bottom: 2px;
}

.header-product-title.deleted { color: #9ca3af; font-style: italic; }

.header-product-price {
    font-size: 13px;
    font-weight: 700;
    color: #20c997;
}

.header-deleted-notice {
    font-size: 11px;
    color: #ef4444;
    margin-top: 1px;
}

/* 거래 상태 뱃지 */
.header-trade-badge {
    display: inline-flex;
    align-items: center;
    padding: 3px 9px;
    border-radius: 20px;
    font-size: 11px;
    font-weight: 700;
    flex-shrink: 0;
}

.header-trade-badge--sale     { background: #ecfdf5; color: #059669; border: 1px solid #6ee7b7; }
.header-trade-badge--reserved { background: #fffbeb; color: #d97706; border: 1px solid #fcd34d; }
.header-trade-badge--sold     { background: #f3f4f6; color: #6b7280; border: 1px solid #d1d5db; }

/* ── 채팅 영역 ── */
#chatArea {
    flex: 1;
    overflow-y: auto;
    padding: 16px 14px;
    display: flex;
    flex-direction: column;
    gap: 4px;
    background: #f5f7fa;
}

#chatArea::-webkit-scrollbar { width: 4px; }
#chatArea::-webkit-scrollbar-thumb { background: #d1fae5; border-radius: 4px; }

/* ── 메시지 래퍼 ── */
.msg-wrap {
    display: flex;
    flex-direction: column;
    max-width: 72%;
}
.msg-wrap.mine  { align-self: flex-end;   align-items: flex-end; }
.msg-wrap.other { align-self: flex-start; align-items: flex-start; }

.sender-name {
    font-size: 11px;
    color: #9ca3af;
    margin-bottom: 3px;
    padding: 0 4px;
}

/* 말풍선 */
.bubble {
    padding: 9px 13px;
    font-size: 14px;
    line-height: 1.55;
    word-break: break-word;
}

.mine  .bubble {
    background: #20c997;
    color: #fff;
    border-radius: 16px 4px 16px 16px;
    box-shadow: 0 2px 6px rgba(32,201,151,0.25);
}

.other .bubble {
    background: #fff;
    color: #1f2937;
    border-radius: 4px 16px 16px 16px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.08);
}

/* 시간 + 읽음 */
.msg-meta {
    display: flex;
    align-items: center;
    gap: 4px;
    margin-top: 3px;
    padding: 0 4px;
    font-size: 10px;
    color: #9ca3af;
}
.mine .msg-meta { justify-content: flex-end; }

.read-badge { font-size: 10px; font-weight: 700; color: #20c997; }
.read-badge.done { color: #9ca3af; }

/* ── 입력창 ── */
#inputContainer {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 12px;
    background: #fff;
    border-top: 1px solid #e9ecef;
    flex-shrink: 0;
}

#messageInput {
    flex: 1;
    padding: 10px 16px;
    border: 1.5px solid #e5e7eb;
    border-radius: 24px;
    background: #f9fafb;
    font-size: 14px;
    font-family: inherit;
    outline: none;
    transition: border-color 0.2s;
}

#messageInput:focus {
    border-color: #20c997;
    background: #fff;
}

#sendBtn {
    width: 42px; height: 42px;
    border: none;
    border-radius: 50%;
    background: linear-gradient(135deg, #20c997, #12b886);
    color: #fff;
    font-size: 18px;
    cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    transition: opacity 0.2s, box-shadow 0.2s;
    box-shadow: 0 2px 8px rgba(32,201,151,0.3);
}

#sendBtn:hover {
    opacity: 0.88;
    box-shadow: 0 4px 12px rgba(32,201,151,0.4);
}

/* ── 이모티콘 버튼 ── */
#emojiBtn {
    width: 36px; height: 36px;
    border: none;
    background: none;
    font-size: 22px;
    cursor: pointer;
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    transition: background 0.15s;
    line-height: 1;
}
#emojiBtn:hover  { background: #f0fdf9; }
#emojiBtn.active { background: #d1fae5; }

/* ── 이모티콘 피커 패널 ── */
#emojiPicker {
    display: none;
    background: #fff;
    border-top: 1px solid #e9ecef;
    flex-shrink: 0;
}

.emoji-cats {
    display: flex;
    border-bottom: 1px solid #f3f4f6;
    padding: 0 6px;
}

.emoji-cat-btn {
    flex: 1;
    padding: 8px 2px;
    border: none;
    background: none;
    font-size: 18px;
    cursor: pointer;
    border-bottom: 2px solid transparent;
    transition: border-color 0.15s;
    line-height: 1;
}
.emoji-cat-btn.active { border-bottom-color: #20c997; }
.emoji-cat-btn:hover  { background: #f9fafb; }

.emoji-grid {
    display: grid;
    grid-template-columns: repeat(8, 1fr);
    padding: 6px 8px;
    max-height: 180px;
    overflow-y: auto;
    gap: 2px;
}
.emoji-grid::-webkit-scrollbar { width: 4px; }
.emoji-grid::-webkit-scrollbar-thumb { background: #d1fae5; border-radius: 4px; }

.emoji-item {
    font-size: 22px;
    padding: 5px;
    cursor: pointer;
    border-radius: 8px;
    text-align: center;
    border: none;
    background: none;
    line-height: 1;
    transition: background 0.1s;
}
.emoji-item:hover { background: #f0fdf9; }
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

stompClient.connect({}, function(frame) {

    // 1) 채팅방 진입 즉시 읽음 처리 + 팝업 열림 등록
    sendReadReceipt();
    localStorage.setItem('chatOpen_' + roomId, '1');

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
    if (e.key === 'Enter') sendMessage();
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
