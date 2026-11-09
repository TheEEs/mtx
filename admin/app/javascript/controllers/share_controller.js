import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    title: String,
    text: String,
    url: String
  }

  connect() {
    // Chỉ hiển thị nút chia sẻ trên các trình duyệt hỗ trợ Web Share API (navigator.share)
    if (this.isShareSupported) {
      this.element.classList.remove("hidden")
    }
  }

  get isShareSupported() {
    return typeof navigator !== "undefined" && typeof navigator.share === "function"
  }

  async share(event) {
    event?.preventDefault()

    if (!this.isShareSupported) return

    const shareData = {
      title: this.titleValue || document.title,
      text: this.textValue || "",
      url: this.urlValue || window.location.href
    }

    // Kiểm tra tính tương thích của dữ liệu trước khi gọi share nếu navigator.canShare khả dụng
    if (typeof navigator.canShare === "function" && !navigator.canShare(shareData)) {
      console.warn("Dữ liệu chia sẻ không được hỗ trợ bởi navigator.canShare:", shareData)
      return
    }

    try {
      await navigator.share(shareData)
    } catch (error) {
      // AbortError xảy ra khi người dùng chủ động đóng hộp thoại chia sẻ của hệ điều hành
      if (error.name !== "AbortError") {
        console.error("Lỗi khi chia sẻ qua Web Share API:", error)
      }
    }
  }
}
