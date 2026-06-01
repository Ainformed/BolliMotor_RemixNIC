/* ============================================================
   BOLLI MOTOR — temalogikk (delt)
   Settes i <head> slik at lagret tema brukes før første maling.
   Fargen er låst (klassisk blå på hvit). Kun lys/mørk kan byttes.
   ============================================================ */
(function () {
    var root = document.documentElement;
    var savedTheme;
    try { savedTheme = localStorage.getItem('bm-theme'); } catch (e) {}

    // Låst merkevare — fargevelgeren er fjernet for besøkende.
    root.setAttribute('data-theme',   savedTheme === 'dark' ? 'dark' : 'light');
    root.setAttribute('data-palette', 'blue');
    root.setAttribute('data-surface', 'warm');

    function ready(fn) {
        if (document.readyState !== 'loading') fn();
        else document.addEventListener('DOMContentLoaded', fn);
    }

    ready(function () {
        var darkBtn = document.getElementById('darkToggle');

        function syncDarkIcon() {
            if (!darkBtn) return;
            var isDark = root.getAttribute('data-theme') === 'dark';
            darkBtn.innerHTML = isDark
                ? '<i class="fa-solid fa-sun"></i>'
                : '<i class="fa-solid fa-moon"></i>';
            darkBtn.setAttribute('aria-label', isDark ? 'Bytt til lyst tema' : 'Bytt til mørkt tema');
        }

        syncDarkIcon();

        if (darkBtn) {
            darkBtn.addEventListener('click', function () {
                var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
                root.setAttribute('data-theme', next);
                try { localStorage.setItem('bm-theme', next); } catch (e) {}
                syncDarkIcon();
            });
        }
    });
})();
