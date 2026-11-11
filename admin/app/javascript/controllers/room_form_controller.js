import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["isPublic", "passwordContainer", "passwordInput"]

  connect() {
    this.togglePassword()
  }

  togglePassword() {
    const isPublic = this.isPublicTarget.checked

    if (isPublic) {
      // Room is public: disable password input so it cannot be typed into or submitted
      this.passwordInputTarget.disabled = true
      this.passwordInputTarget.value = ""
      this.passwordContainerTarget.classList.add("hidden")
    } else {
      // Room is private: enable password input so user can enter an optional password
      this.passwordInputTarget.disabled = false
      this.passwordContainerTarget.classList.remove("hidden")
    }
  }
}
