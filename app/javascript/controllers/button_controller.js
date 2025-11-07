import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "button"

  connect() {
    super.connect()
    const el = this.bridgeElement
    const title = el.bridgeAttribute("title")

    this.send("connect", { title }, () => {
      this.element.click()
    })
  }
}
