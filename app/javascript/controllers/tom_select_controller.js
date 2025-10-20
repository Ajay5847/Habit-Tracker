import { Controller } from "@hotwired/stimulus";
import TomSelect from "tom-select";

export default class extends Controller {
  static targets = ["select"];

  connect() {
    this.tomSelect = new TomSelect(this.selectTarget, {
      plugins: ['remove_button'],
      maxItems: null, // unlimited selections
      placeholder: 'Select tags...',
      closeAfterSelect: false
    });
  }

  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy();
    }
  }
}