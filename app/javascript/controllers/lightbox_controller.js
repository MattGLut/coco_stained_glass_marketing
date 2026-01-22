import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lightbox"
export default class extends Controller {
  static targets = ["mainImage", "thumbnail"]

  connect() {
    // Store all image URLs for easy access - get large variant URLs from data attributes
    this.imageUrls = this.thumbnailTargets.map(thumbnail => {
      return thumbnail.dataset.largeUrl
    })

    // Set initial active thumbnail
    this.setActiveThumbnail(0)
  }

  // Handle thumbnail clicks
  selectImage(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.updateMainImage(index)
    this.setActiveThumbnail(index)
  }

  // Handle main image click to open lightbox
  open(event) {
    // For now, just prevent default - you could implement lightbox functionality here
    event.preventDefault()
    // TODO: Implement lightbox modal functionality if needed
  }

  // Update the main image
  updateMainImage(index) {
    if (this.hasMainImageTarget && this.imageUrls[index]) {
      this.mainImageTarget.src = this.imageUrls[index]
      this.mainImageTarget.alt = `${this.mainImageTarget.alt.split(' - ')[0]} - Image ${index + 1}`
    }
  }

  // Update active thumbnail styling
  setActiveThumbnail(activeIndex) {
    this.thumbnailTargets.forEach((thumbnail, index) => {
      if (index === activeIndex) {
        thumbnail.classList.add('active')
      } else {
        thumbnail.classList.remove('active')
      }
    })
  }
}