import { Controller } from "@hotwired/stimulus"

// Submits the surrounding form when inputs change, debounced for text fields.
export default class extends Controller {
  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.element.requestSubmit(), 300)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
