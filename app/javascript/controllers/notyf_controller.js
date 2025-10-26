import { Notyf } from "notyf";
import "notyf/notyf.min.css";
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { error: Boolean };

  initialize() {
    if (window.notyf) return;

    window.notyf = new Notyf({
      duration: 5000,
      position: { x: "right", y: "top" },
      ripple: true,
      types: [
        {
          type: "success",
          background: "linear-gradient(135deg, #10b981 0%, #059669 100%)",
          icon: {
            className: "fas fa-circle-check",
            tagName: "i",
            color: "#fff"
          }
        },
        {
          type: "error",
          background: "linear-gradient(135deg, #ef4444 0%, #dc2626 100%)",
          icon: {
            className: "fas fa-circle-xmark",
            tagName: "i",
            color: "#fff"
          }
        }
      ]
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