import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    title: String,
    tabs: Array,
    headericon: String,
  };

  connect() {
    const slideoverController =
      this.application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="slideover"]'),
        "slideover"
      );
    if (this.element.innerHTML?.trim()) {
      slideoverController.populate(
        this.titleValue,
        this.element.innerHTML,
        this.tabsValue,
        this.headericonValue
      );
      slideoverController.open();
    } else {
      slideoverController.close();
    }

    setTimeout(this.remove.bind(this), 1000);
  }

  remove() {
    this.element.remove();
  }
}
