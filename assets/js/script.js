;(function () {
	const STORAGE_KEY = 'poabitdevs-theme';
	const darkClass = 'dark';
	const btn = document.getElementById('theme-toggle');

	if (!btn) return;

	function systemPrefersDark() {
		return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
	}

	function applyTheme(isDark, explicit = false) {
		const root = document.documentElement;
		if (explicit) {
			if (isDark) {
				root.classList.add('dark');
				root.classList.remove('light');
			} else {
				root.classList.add('light');
				root.classList.remove('dark');
			}
		} else {
			if (isDark) root.classList.add(darkClass);
			else root.classList.remove(darkClass);
		}

		const use = btn.querySelector('.theme-icon use');
		if (use) {
			try {
				use.setAttribute('href', '#' + (isDark ? 'moon' : 'sun'));
			} catch (e) {
				use.setAttributeNS('http://www.w3.org/1999/xlink', 'xlink:href', '#' + (isDark ? 'moon' : 'sun'));
			}
		}

		btn.setAttribute('aria-pressed', String(isDark));
	}

	function loadTheme() {
		const stored = localStorage.getItem(STORAGE_KEY);
		if (stored === 'dark') return { isDark: true, explicit: true };
		if (stored === 'light') return { isDark: false, explicit: true };
		return { isDark: systemPrefersDark(), explicit: false };
	}

	const initial = loadTheme();
	applyTheme(initial.isDark, initial.explicit);

	btn.addEventListener('click', () => {
		const isDark = document.documentElement.classList.toggle(darkClass);
		if (isDark) {
			document.documentElement.classList.remove('light');
			document.documentElement.classList.add('dark');
		} else {
			document.documentElement.classList.remove('dark');
			document.documentElement.classList.add('light');
		}
		localStorage.setItem(STORAGE_KEY, isDark ? 'dark' : 'light');
		applyTheme(isDark);

		const icon = btn.querySelector('.theme-icon');
		if (icon) {
			icon.classList.add('anim');
			setTimeout(() => icon.classList.remove('anim'), 320);
		}
	});

	if (window.matchMedia) {
		const mq = window.matchMedia('(prefers-color-scheme: dark)');
		mq.addEventListener && mq.addEventListener('change', (e) => {
			if (!localStorage.getItem(STORAGE_KEY)) applyTheme(e.matches);
		});
	}
})();