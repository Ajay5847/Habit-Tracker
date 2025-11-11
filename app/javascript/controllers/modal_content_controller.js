import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    title: String,
    tabs: Array,
    headericon: String,
  };

  connect() {
    const modalController =
      this.application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="modal"]'),
        "modal"
      );
    if (this.element.innerHTML?.trim()) {
      modalController.populate(
        this.titleValue,
        this.element.innerHTML,
        this.tabsValue,
        this.headericonValue
      );
      modalController.open();
    } else {
      modalController.close();
    }

    setTimeout(this.remove.bind(this), 1000);
  }

  remove() {
    this.element.remove();
  }
}
