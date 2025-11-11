import { Controller } from "@hotwired/stimulus";
import { enter, leave } from "el-transition";

export default class extends Controller {
  static targets = [
    "modal",
    "overlay",
    "panel",
    "title",
    "tabs",
    "headericon",
    "body",
  ];

  connect() {
    this.opened = false;
    this.overlayTarget.addEventListener("mousedown", (ev) => {
      if (ev.target === ev.currentTarget) this.close.bind(this)();
    });
  }

  disconnect() {
    this.close();
  }

  populate(title, body, tabs, headericon) {
    this.titleTarget.innerHTML = title;
    this.bodyTarget.innerHTML = body;
    this.headericonTarget.classList.add(`ph-${headericon}`);
    this.populateTabs(tabs);
  }

  populateTabs(tabs) {
    if (tabs.length == 0) {
      this.tabsTarget.classList.add("hidden");
    } else {
      this.tabsTarget.innerHTML = "";
      tabs.forEach((tab) => {
        const link = document.createElement("a");
        link.href = tab.href;
        link.innerHTML = tab.text;
        link.classList.add("modal-tabs-tab");
        if (tab.active) link.classList.add("modal-tabs-tab--active");
        link.dataset.method = "get";
        link.dataset.controller = "turbo-hack";
        this.tabsTarget.insertAdjacentElement("beforeEnd", link);
      });
      this.tabsTarget.classList.remove("hidden");
    }
  }

  open() {
    if (this.opened) return;

    this.show();
    enter(this.overlayTarget);
    enter(this.panelTarget);

    document.querySelector("body").style.overflowY = "hidden";

    window.closeModal = this.close.bind(this);

    this.opened = true;
  }

  close() {
    if (!this.opened) return;

    leave(this.overlayTarget);
    leave(this.panelTarget);

    document.querySelector("body").style.overflowY = "auto";

    this.modalTarget.scrollTop = 0;

    setTimeout(this.hide.bind(this), 1000);

    this.opened = false;
  }

  show() {
    this.element.classList.remove("hidden");
  }

  hide() {
    this.element.classList.add("hidden");
  }
}
