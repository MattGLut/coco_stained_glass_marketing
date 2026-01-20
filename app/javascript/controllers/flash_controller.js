import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    // Auto-dismiss after 5 seconds
    this.autoDismissTimer = setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  dismiss() {
    clearTimeout(this.autoDismissTimer)
    
    // Animate out
    this.element.style.opacity = "0"
    this.element.style.transform = "translateX(20px)"
    
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  disconnect() {
    clearTimeout(this.autoDismissTimer)
  }
}
