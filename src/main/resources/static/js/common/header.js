// header.js

(function() {
    var RECENT_KEY = 'recentProducts';
    var RECENT_SHOW = 5;
    var ctx        = document.querySelector('meta[name="ctx"]').getAttribute('content');
    var isLoggedIn = document.querySelector('meta[name="isLoggedIn"]').getAttribute('content') === 'true';

    /* 비로그인이면 기록 지우고 박스 숨김 */
    if (!isLoggedIn) {
        localStorage.removeItem(RECENT_KEY);
        var box = document.getElementById('itemBox');
        if (box) box.style.display = 'none';
        return;
    }

    function getList() {
        try { return JSON.parse(localStorage.getItem(RECENT_KEY)) || []; }
        catch(e) { return []; }
    }

    function render() {
        var list      = getList().slice(0, RECENT_SHOW);
        var recentEl  = document.getElementById('recently');
        var badgeEl   = document.getElementById('rpBadge');
        var footerEl  = document.getElementById('rpFooter');
        if (!recentEl) return;

        var total = getList().length;
        if (badgeEl) badgeEl.textContent = Math.min(total, RECENT_SHOW);

        if (list.length === 0) {
            recentEl.innerHTML =
                '<p class="rpEmpty">' +
                    '<ion-icon class="rpEmptyIcon" name="bag-outline"></ion-icon>' +
                    '아직 본 상품이<br>없어요' +
                '</p>';
            if (footerEl) footerEl.style.display = 'none';
            return;
        }

        if (footerEl) footerEl.style.display = 'block';

        var html = '';
        list.forEach(function(p, idx) {
            var imgSrc   = p.imgSrc || (ctx + '/images/common/hifiveLogo.png');
            var ts       = p.tradeStatus || 'SALE';
            var sold     = ts === 'SOLD';
            var reserved = ts === 'RESERVED';

            var overlay = sold
                ? '<span class="rpSoldDim">거래완료</span>'
                : reserved
                    ? '<span class="rpReservedBadge">예약중</span>'
                    : '';

            html +=
                '<a href="' + ctx + '/product/' + p.productId + '" class="rpItem" ' +
                    'style="animation-delay:' + (idx * 0.05) + 's" ' +
                    'title="' + p.title + '">' +
                    '<div class="rpThumb">' +
                        '<img src="' + imgSrc + '" alt="' + p.title + '"' +
                             ' onerror="this.src=\'' + ctx + '/images/common/hifiveLogo.png\'">' +
                        overlay +
                    '</div>' +
                    '<p class="rpTitle">' + p.title + '</p>' +
                '</a>';
        });
        recentEl.innerHTML = html;
    }

    /* productDetail.jsp에서 저장 직후 호출해서 즉시 갱신 */
    window.renderRecentProducts = render;

    window.clearRecentProducts = function() {
        localStorage.removeItem(RECENT_KEY);
        render();
    };

    render();
})();
