import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lightbox"
export default class extends Controller {
  static targets = ["mainImage", "thumbnail"]

  connect() {
    // Store all image URLs for easy access - get large variant URLs from data attributes
    this.imageUrls = this.thumbnailTargets.map(thumbnail => {
      return thumbnail.dataset.largeUrl
    })

    // If no thumbnails, get URL from main image
    if (this.imageUrls.length === 0 && this.hasMainImageTarget) {
      this.imageUrls = [this.mainImageTarget.src]
    }

    this.currentIndex = 0
    this.modal = null

    // Set initial active thumbnail
    if (this.thumbnailTargets.length > 0) {
      this.setActiveThumbnail(0)
    }

    // Bind keyboard handler
    this.handleKeydown = this.handleKeydown.bind(this)
  }

  disconnect() {
    this.close()
  }

  // Handle thumbnail clicks
  selectImage(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.currentIndex = index
    this.updateMainImage(index)
    this.setActiveThumbnail(index)
  }

  // Handle main image click to open lightbox
  open(event) {
    event.preventDefault()
    this.createModal()
    this.showImage(this.currentIndex)
    document.addEventListener('keydown', this.handleKeydown)
    document.body.style.overflow = 'hidden'
  }

  // Close the lightbox
  close() {
    if (this.modal) {
      this.modal.classList.add('lightbox-modal--closing')
      setTimeout(() => {
        this.modal?.remove()
        this.modal = null
      }, 200)
      document.removeEventListener('keydown', this.handleKeydown)
      document.body.style.overflow = ''
    }
  }

  // Navigate to previous image
  previous(event) {
    event?.stopPropagation()
    if (this.imageUrls.length > 1) {
      this.currentIndex = (this.currentIndex - 1 + this.imageUrls.length) % this.imageUrls.length
      this.showImage(this.currentIndex)
      this.updateMainImage(this.currentIndex)
      this.setActiveThumbnail(this.currentIndex)
    }
  }

  // Navigate to next image
  next(event) {
    event?.stopPropagation()
    if (this.imageUrls.length > 1) {
      this.currentIndex = (this.currentIndex + 1) % this.imageUrls.length
      this.showImage(this.currentIndex)
      this.updateMainImage(this.currentIndex)
      this.setActiveThumbnail(this.currentIndex)
    }
  }

  // Handle keyboard navigation
  handleKeydown(event) {
    switch (event.key) {
      case 'Escape':
        this.close()
        break
      case 'ArrowLeft':
        this.previous()
        break
      case 'ArrowRight':
        this.next()
        break
    }
  }

  // Create the modal element
  createModal() {
    this.modal = document.createElement('div')
    this.modal.className = 'lightbox-modal'
    this.modal.innerHTML = `
      <div class="lightbox-overlay"></div>
      <button class="lightbox-close" aria-label="Close lightbox">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="18" y1="6" x2="6" y2="18"></line>
          <line x1="6" y1="6" x2="18" y2="18"></line>
        </svg>
      </button>
      ${this.imageUrls.length > 1 ? `
        <button class="lightbox-nav lightbox-nav--prev" aria-label="Previous image">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="15 18 9 12 15 6"></polyline>
          </svg>
        </button>
        <button class="lightbox-nav lightbox-nav--next" aria-label="Next image">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="9 18 15 12 9 6"></polyline>
          </svg>
        </button>
      ` : ''}
      <div class="lightbox-content">
        <img class="lightbox-image" src="" alt="Lightbox image">
      </div>
      ${this.imageUrls.length > 1 ? `
        <div class="lightbox-counter">
          <span class="lightbox-current">1</span> / <span class="lightbox-total">${this.imageUrls.length}</span>
        </div>
      ` : ''}
    `
    document.body.appendChild(this.modal)

    // Manually attach event listeners since modal is outside controller scope
    this.modal.querySelector('.lightbox-overlay').addEventListener('click', () => this.close())
    this.modal.querySelector('.lightbox-close').addEventListener('click', () => this.close())
    
    if (this.imageUrls.length > 1) {
      this.modal.querySelector('.lightbox-nav--prev').addEventListener('click', (e) => this.previous(e))
      this.modal.querySelector('.lightbox-nav--next').addEventListener('click', (e) => this.next(e))
    }

    // Trigger animation
    requestAnimationFrame(() => {
      this.modal.classList.add('lightbox-modal--open')
    })
  }

  // Show specific image in the modal
  showImage(index) {
    if (!this.modal) return

    const img = this.modal.querySelector('.lightbox-image')
    const counter = this.modal.querySelector('.lightbox-current')

    // Add loading state
    img.classList.add('lightbox-image--loading')

    img.onload = () => {
      img.classList.remove('lightbox-image--loading')
    }

    img.src = this.imageUrls[index]
    img.alt = `Image ${index + 1} of ${this.imageUrls.length}`

    if (counter) {
      counter.textContent = index + 1
    }
  }

  // Update the main image
  updateMainImage(index) {
    if (this.hasMainImageTarget && this.imageUrls[index]) {
      this.mainImageTarget.src = this.imageUrls[index]
      const baseAlt = this.mainImageTarget.alt.split(' - ')[0]
      this.mainImageTarget.alt = `${baseAlt} - Image ${index + 1}`
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