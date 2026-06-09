// main.js

// ===================== 배너 슬라이더 =====================
(function () { // 즉시 실행함수(IIFE) 
    var ctx = document.querySelector('meta[name="ctx"]')
                ? document.querySelector('meta[name="ctx"]').content
                : '';

    $.ajax({
        url: ctx + '/banner/list',
        type: 'GET',
        dataType: 'json',
        success: function (banners) {
            if (!banners || banners.length === 0) return;

            var $slide = $('#bannerSlide');
            var $dots  = $('#slideDots');

            banners.forEach(function (banner, i) {
                var href = banner.linkUrl ? banner.linkUrl : '#';
                $slide.append(
                    '<li><a href="' + href + '">' +
                    '<img src="' + ctx + banner.imageUrl + '" alt="배너" loading="lazy" />' +
                    '</a></li>'
                );
                $dots.append(
                    '<span class="dot' + (i === 0 ? ' active' : '') + '" data-index="' + i + '"></span>'
                );
            });

            initSlider();
        },
        error: function () {
            // 배너 로드 실패 시 슬라이드 영역 숨김
            $('.slideContainer').hide();
        }
    });

    function initSlider() { 
        var $slide   = $('#bannerSlide');
        var $dots    = $('.dot');
        var $prevBtn = $('.prevBtn');
        var $nextBtn = $('.nextBtn');
        var items    = $slide.find('li');
        var total    = items.length;
        var current  = 0;
        var autoTimer;

		
		// moveTo, next, prev 3개다 바깥 스코프의 변수인 current를 참조해야해서 내부에다 메소드 생성 -> 클로저를 형성하고 있다
        function moveTo(index) { 
            var width = items.eq(0).find('img')[0].offsetWidth || 1280;
            $slide.css('transform', 'translateX(' + (-width * index) + 'px)');
            current = index;
            $dots.removeClass('active');
            $dots.eq(index).addClass('active');
        }

        function next() { moveTo(current >= total - 1 ? 0 : current + 1); }
        function prev() { moveTo(current <= 0 ? total - 1 : current - 1); }

        function startAuto() { autoTimer = setInterval(next, 4000); }
        function resetAuto()  { clearInterval(autoTimer); startAuto(); }

        $nextBtn.on('click', function () { next(); resetAuto(); });
        $prevBtn.on('click', function () { prev(); resetAuto(); });

        $(document).on('click', '.dot', function () {
            moveTo($(this).data('index'));
            resetAuto();
        });

        startAuto();
    }
})();
// =========================================================
