import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

/**
 * Universal TomSelect controller for both single and multi-selects.
 * Usage:
 *   <div data-controller="tom-select" data-tom-select-mode-value="single">
 *   or omit `data-tom-select-mode-value` for multi-select.
 */
export default class extends Controller {
  static targets = ["select"]
  static values = {
    mode: { type: String, default: "multi" } // "single" or "multi"
  }

  connect() {
    const isSingle = this.modeValue === "single"

    const placeholder = this.selectTarget.dataset.placeholder ||
      (isSingle ? "Select or create a list..." : "Select or create...")

    const config = {
      create: (input) => ({ value: input, text: input }),
      persist: false,
      placeholder,
      sortField: { field: "text", direction: "asc" },
      plugins: isSingle ? [] : ["remove_button"],
      maxItems: isSingle ? 1 : null,
      closeAfterSelect: isSingle
    }

    this.tomSelect = new TomSelect(this.selectTarget, config)
  }

  disconnect() {
    if (this.tomSelect) this.tomSelect.destroy()
  }
}
