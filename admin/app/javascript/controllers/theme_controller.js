import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sunIcon", "moonIcon"]

  connect() {
    this.boundHandleThemeChanged = this.handleThemeChanged.bind(this)
    window.addEventListener("theme:changed", this.boundHandleThemeChanged)
    this.updateUI()
  }

  disconnect() {
    window.removeEventListener("theme:changed", this.boundHandleThemeChanged)
  }

  handleThemeChanged(event) {
    this.updateUI(event.detail?.theme)
  }

  toggle() {
    const currentTheme = document.documentElement.getAttribute("data-theme") || "dark"
    const nextTheme = currentTheme === "dark" ? "light" : "dark"
    this.applyTheme(nextTheme)
  }

  applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)
    try {
      localStorage.setItem("theme", theme)
    } catch (e) {}

    window.dispatchEvent(new CustomEvent("theme:changed", { detail: { theme } }))
  }

  updateUI(theme) {
    const currentTheme = theme || document.documentElement.getAttribute("data-theme") || "dark"
    const isDark = currentTheme === "dark"

    // When dark, show sun icon (click to switch to light); when light, show moon icon (click to switch to dark)
    if (this.hasSunIconTarget) {
      this.sunIconTarget.classList.toggle("hidden", !isDark)
    }
    if (this.hasMoonIconTarget) {
      this.moonIconTarget.classList.toggle("hidden", isDark)
    }

    const title = isDark ? this.element.dataset.titleLight : this.element.dataset.titleDark
    if (title) {
      this.element.setAttribute("title", title)
      this.element.setAttribute("aria-label", title)
    }
  }
}
