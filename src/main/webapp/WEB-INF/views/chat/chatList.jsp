<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ include file="../common/header.jsp"%>
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/css/common/pagination.css" />
<link rel="stylesheet"
	href="<%=request.getContextPath()%>/css/chat/chatList.css" />

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
						<div id="chat-item-${room.roomId}" class="cl-item"
							onclick="openChatRoom('${room.productId}', '${room.otherUserNo}', '${room.roomId}')">

							<%-- 왼쪽: 상품 썸네일 + 프로필 미니 --%>
							<div class="cl-media">
								<c:choose>
									<c:when test="${not empty room.productImg}">
										<img class="cl-product-thumb"
											src="<%=request.getContextPath()%>${room.productImg}"
											alt="상품" onerror="this.outerHTML='<div class=\'cl-product-thumb-placeholder\'><ion-icon name=\'bag-outline\'></ion-icon></div>'">
									</c:when>
									<c:otherwise>
										<div class="cl-product-thumb-placeholder">
											<ion-icon name="bag-outline"></ion-icon>
										</div>
									</c:otherwise>
								</c:choose>

								<div class="cl-profile-mini">
									<c:choose>
										<c:when test="${fn:startsWith(room.otherUserImg, 'http')}">
											<img src="${room.otherUserImg}" alt="프로필"
												onerror="this.outerHTML='<ion-icon name=person-circle-outline></ion-icon>'">
										</c:when>
										<c:when test="${not empty room.otherUserImg}">
											<img src="<%=request.getContextPath()%>${room.otherUserImg}"
												alt="프로필"
												onerror="this.outerHTML='<ion-icon name=person-circle-outline></ion-icon>'">
										</c:when>
										<c:otherwise>
											<ion-icon name="person-circle-outline"></ion-icon>
										</c:otherwise>
									</c:choose>
								</div>
							</div>

							<%-- 가운데: 닉네임 + 마지막 메시지 --%>
							<div class="cl-body">
								<span class="cl-partner">
									<c:out value="${not empty room.otherUserName ? room.otherUserName : '상대방'}" />
								</span>
								<span class="cl-last-msg">
									${empty room.lastMessage ? '메시지 없음' : room.lastMessage}
								</span>
							</div>

							<%-- 오른쪽: 시간(위) + 미읽음 뱃지(아래) --%>
							<div class="cl-right">
								<span class="cl-time" data-ts="${room.lastMessageTime}"></span>
								<c:if test="${room.unreadCount > 0}">
									<span class="cl-unread">${room.unreadCount}</span>
								</c:if>
							</div>

						</div>
					</c:forEach>
				</c:otherwise>
			</c:choose>
		</div>
		<c:if test="${not empty rooms}">
			<c:set var="pageBaseUrl" value="?" />
			<%@ include file="../common/pagination.jsp"%>
		</c:if>
	</div>
</section>

<script>
	document.addEventListener('DOMContentLoaded', function() {
		const ctx = document.querySelector('meta[name="ctx"]').getAttribute('content');
		const userNo = '${sessionScope.loginUser.userNo}';

		function fmtTime(ts) {
			if (!ts) return '';
			var d = new Date(ts);
			if (isNaN(d)) return '';
			var now = new Date();

			var isToday = d.getFullYear() === now.getFullYear()
					&& d.getMonth() === now.getMonth()
					&& d.getDate() === now.getDate();
			if (isToday) {
				var h = d.getHours();
				var m = String(d.getMinutes()).padStart(2, '0');
				var ampm = h < 12 ? '오전' : '오후';
				var h12 = h % 12 || 12;
				return ampm + ' ' + h12 + ':' + m;
			}

			var diffMs = now - d;
			var diffMin = Math.floor(diffMs / 60000);
			var diffHour = Math.floor(diffMs / 3600000);
			var diffDay = Math.floor(diffMs / 86400000);
			var diffWeek = Math.floor(diffDay / 7);
			var diffMonth = Math.floor(diffDay / 30);
			var diffYear = Math.floor(diffDay / 365);

			if (diffMin < 1)   return '방금 전';
			if (diffMin < 60)  return diffMin + '분 전';
			if (diffHour < 24) return diffHour + '시간 전';
			if (diffDay < 7)   return diffDay + '일 전';
			if (diffWeek < 5)  return diffWeek + '주 전';
			if (diffMonth < 12) return diffMonth + '달 전';
			return diffYear + '년 전';
		}

		document.querySelectorAll('.cl-time[data-ts]').forEach(function(el) {
			el.textContent = fmtTime(el.getAttribute('data-ts'));
		});

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
			var item = document.getElementById('chat-item-' + roomId);
			if (item) {
				var badge = item.querySelector('.cl-unread');
				if (badge) badge.remove();
			}

			if (stompClient && stompClient.connected) {
				stompClient.send('/app/chat/read', {}, JSON.stringify({
					roomId: roomId,
					userNo: userNo,
					otherUserNo: String(targetUserNo)
				}));
			}
			localStorage.setItem('chatOpen_' + roomId, '1');

			const popup = window.open('', 'chatPopup_' + roomId, 'width=460,height=660,resizable=yes');
			if (!popup || popup.closed) {
				alert('팝업이 차단되었습니다. 팝업 차단을 해제해주세요.');
				return;
			}
			const form = document.createElement('form');
			form.method = 'POST';
			form.action = '/member/chat/room';
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

		function buildItemHtml(data, existingItem) {
			var productThumbHtml = '<div class="cl-product-thumb-placeholder"><ion-icon name="bag-outline"></ion-icon></div>';
			var profileMiniHtml  = '<ion-icon name="person-circle-outline"></ion-icon>';
			var partnerName = data.otherUserName || '';

			if (existingItem) {
				var thumb = existingItem.querySelector('.cl-product-thumb');
				if (thumb)
					productThumbHtml = '<img class="cl-product-thumb" src="' + thumb.src + '" alt="상품" onerror="this.style.display=\'none\'">';
				var profileMini = existingItem.querySelector('.cl-profile-mini');
				if (profileMini)
					profileMiniHtml = profileMini.innerHTML;
				if (!partnerName) {
					var partnerEl = existingItem.querySelector('.cl-partner');
					if (partnerEl) partnerName = partnerEl.textContent.trim();
				}
			}
			if (!partnerName) partnerName = '상대방';

			var unreadHtml = '';
			var displayCount;
			if (data.unreadCount === -2) {
				var curBadge = existingItem ? existingItem.querySelector('.cl-unread') : null;
				displayCount = curBadge ? (parseInt(curBadge.textContent) || 0) : 0;
			} else {
				displayCount = isPopupOpen(String(data.roomId)) ? 0 : data.unreadCount;
			}
			if (displayCount > 0)
				unreadHtml = '<span class="cl-unread">' + displayCount + '</span>';

			return '<div class="cl-media">'
					+ productThumbHtml
					+ '<div class="cl-profile-mini">' + profileMiniHtml + '</div>'
					+ '</div>'
					+ '<div class="cl-body">'
					+ '<span class="cl-partner">' + partnerName + '</span>'
					+ '<span class="cl-last-msg">' + (data.lastMessage || '') + '</span>'
					+ '</div>'
					+ '<div class="cl-right">'
					+ '<span class="cl-time">' + fmtTime(new Date().toISOString()) + '</span>'
					+ unreadHtml
					+ '</div>';
		}

		function updateChatListItem(data) {
			const container   = document.getElementById('chat-list-container');
			const existingItem = document.getElementById('chat-item-' + data.roomId);

			if (!data.lastMessage) {
				if (existingItem) {
					var rightArea = existingItem.querySelector('.cl-right');
					if (rightArea) {
						var timeEl = rightArea.querySelector('.cl-time');
						var timeText = timeEl ? timeEl.textContent : '';
						rightArea.innerHTML = '<span class="cl-time">' + timeText + '</span>';
						if (data.unreadCount > 0 && !isPopupOpen(String(data.roomId))) {
							rightArea.innerHTML += '<span class="cl-unread">' + data.unreadCount + '</span>';
						}
					}
				}
				return;
			}

			const empty = container.querySelector('.cl-empty');
			if (empty) empty.remove();

			const innerHTML = buildItemHtml(data, existingItem);

			if (existingItem) {
				existingItem.innerHTML = innerHTML;
				container.prepend(existingItem);
			} else {
				const newItem = document.createElement('div');
				newItem.id = 'chat-item-' + data.roomId;
				newItem.className = 'cl-item';
				newItem.setAttribute('onclick',
						"openChatRoom('" + data.productId + "','" + data.otherUserNo + "','" + data.roomId + "')");
				newItem.innerHTML = innerHTML;
				container.prepend(newItem);
			}
		}

		window.addEventListener('message', function(e) {
			if (!e.data) return;
			var rid = String(e.data.roomId);

			if (e.data.type === 'CHAT_READ') {
				var item = document.getElementById('chat-item-' + rid);
				if (item) {
					var badge = item.querySelector('.cl-unread');
					if (badge) badge.remove();
				}
			}
			if (e.data.type === 'CHAT_CLOSED') {
				localStorage.removeItem('chatOpen_' + rid);
			}
		});
	});
</script>

<%@ include file="../common/footer.jsp"%>
