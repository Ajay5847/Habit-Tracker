import { Notyf } from "notyf";
import "notyf/notyf.min.css";
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { error: Boolean };

  initialize() {
    if (window.notyf) return;

    window.notyf = new Notyf({
      duration: 5000,
    });
  }

  connect() {
    if (this.element.innerHTML.trim().length === 0) return;

    const notyfData = {
      message: this.element.innerHTML,
      dismissible: true,
    };

    notyfData.type = this.errorValue ? "error" : "success";
    if (window.notyf.notifications.notifications.length < 1)
      window.notyf.open(notyfData);
  }

  disconnect() {
    window.notyf = null;
  }
}