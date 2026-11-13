// Loaded synchronously in <head> so the theme is set before first paint.
(() => {
    const key = "theme";
    const media = window.matchMedia("(prefers-color-scheme: dark)");

    const stored = () => {
        try { return localStorage.getItem(key) || "auto"; } catch { return "auto"; }
    };

    const apply = (mode) => {
        const dark = mode === "dark" || (mode === "auto" && media.matches);
        document.documentElement.setAttribute("data-bs-theme", dark ? "dark" : "light");
        document.querySelectorAll(".theme-switch [data-theme-value]").forEach((button) => {
            const active = button.dataset.themeValue === mode;
            button.classList.toggle("active", active);
            button.setAttribute("aria-pressed", active);
        });
    };

    apply(stored());
    media.addEventListener("change", () => { if (stored() === "auto") apply("auto"); });

    document.addEventListener("DOMContentLoaded", () => {
        apply(stored());
        // Indicator jumps to the stored choice without sliding; transitions only on clicks.
        requestAnimationFrame(() => requestAnimationFrame(() =>
            document.documentElement.classList.add("theme-ready")));
        document.querySelectorAll(".theme-switch [data-theme-value]").forEach((button) => {
            button.addEventListener("click", () => {
                const mode = button.dataset.themeValue;
                try {
                    if (mode === "auto") localStorage.removeItem(key); else localStorage.setItem(key, mode);
                } catch {}
                apply(mode);
            });
        });
    });
})();
