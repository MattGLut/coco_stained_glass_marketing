import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "toggle"]

  connect() {
    this.isOpen = false
  }

  toggle() {
    this.isOpen = !this.isOpen
    this.menuTarget.classList.toggle("is-open", this.isOpen)
    this.toggleTarget.setAttribute("aria-expanded", this.isOpen)
    
    // Prevent body scroll when menu is open
    document.body.style.overflow = this.isOpen ? "hidden" : ""
  }

  // Close menu when clicking outside
  closeOnClickOutside(event) {
    if (this.isOpen && !this.element.contains(event.target)) {
      this.close()
    }
  }

  // Close menu when pressing Escape
  closeOnEscape(event) {
    if (this.isOpen && event.key === "Escape") {
      this.close()
    }
  }

  close() {
    this.isOpen = false
    this.menuTarget.classList.remove("is-open")
    this.toggleTarget.setAttribute("aria-expanded", "false")
    document.body.style.overflow = ""
  }

  disconnect() {
    document.body.style.overflow = ""
  }
}
