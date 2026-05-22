import { useCallback, useEffect, useRef, useState } from "react";

const shots = [
  { id: "dark", label: "深色", src: "/screenshots/dark.png", alt: "CalendarPlus 菜单栏弹窗深色模式" },
  { id: "light", label: "浅色", src: "/screenshots/light.png", alt: "CalendarPlus 菜单栏弹窗浅色模式" },
  { id: "settings", label: "设置", src: "/screenshots/settings.png", alt: "CalendarPlus 设置页" },
] as const;

type ShotId = (typeof shots)[number]["id"];

function readSiteTheme(): "light" | "dark" {
  const attr = document.documentElement.getAttribute("data-theme");
  if (attr === "light" || attr === "dark") return attr;
  return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

function defaultShotForTheme(theme: "light" | "dark"): ShotId {
  return theme === "light" ? "light" : "dark";
}

export default function ScreenshotPreview() {
  const [active, setActive] = useState<ShotId>("dark");
  const tabRefs = useRef<(HTMLButtonElement | null)[]>([]);
  const current = shots.find((s) => s.id === active) ?? shots[0];

  useEffect(() => {
    setActive(defaultShotForTheme(readSiteTheme()));

    const observer = new MutationObserver(() => {
      setActive((prev) => {
        const themed = defaultShotForTheme(readSiteTheme());
        return prev === "settings" ? prev : themed;
      });
    });
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["data-theme"],
    });
    return () => observer.disconnect();
  }, []);

  const focusTab = useCallback((index: number) => {
    tabRefs.current[index]?.focus();
  }, []);

  const selectByIndex = useCallback((index: number) => {
    const shot = shots[index];
    if (shot) setActive(shot.id);
  }, []);

  const onTabKeyDown = (e: React.KeyboardEvent, index: number) => {
    let next = index;
    switch (e.key) {
      case "ArrowRight":
        next = (index + 1) % shots.length;
        break;
      case "ArrowLeft":
        next = (index - 1 + shots.length) % shots.length;
        break;
      case "Home":
        next = 0;
        break;
      case "End":
        next = shots.length - 1;
        break;
      default:
        return;
    }
    e.preventDefault();
    selectByIndex(next);
    focusTab(next);
  };

  const panelId = "screenshot-panel";

  return (
    <div>
      <div className="mb-4 flex flex-wrap justify-center gap-2" role="tablist" aria-label="截图预览">
        {shots.map((shot, index) => (
          <button
            key={shot.id}
            ref={(el) => {
              tabRefs.current[index] = el;
            }}
            type="button"
            role="tab"
            id={`tab-${shot.id}`}
            aria-selected={active === shot.id}
            aria-controls={panelId}
            tabIndex={active === shot.id ? 0 : -1}
            onClick={() => setActive(shot.id)}
            onKeyDown={(e) => onTabKeyDown(e, index)}
            className={
              active === shot.id
                ? "rounded-md bg-cp-primary px-3 py-1.5 text-sm text-cp-on-primary transition-colors"
                : "rounded-md border border-cp-divider bg-cp-elevated px-3 py-1.5 text-sm text-cp-muted transition-colors hover:text-cp-text"
            }
          >
            {shot.label}
          </button>
        ))}
      </div>
      <div
        id={panelId}
        role="tabpanel"
        aria-labelledby={`tab-${active}`}
        className="overflow-hidden rounded-xl border border-cp-divider bg-cp-elevated shadow-sm"
      >
        <img
          key={current.src}
          src={current.src}
          alt={current.alt}
          width={560}
          height={420}
          className="block h-auto w-full"
          loading="lazy"
          onError={(e) => {
            const el = e.currentTarget;
            el.style.display = "none";
            const fallback = el.nextElementSibling;
            if (fallback instanceof HTMLElement) fallback.hidden = false;
          }}
        />
        <div
          hidden
          className="flex min-h-[280px] flex-col items-center justify-center gap-2 px-6 py-12 text-center text-cp-muted"
        >
          <p className="text-sm">暂时无法加载预览图，请稍后再试或前往 GitHub 查看发布说明。</p>
        </div>
      </div>
    </div>
  );
}
