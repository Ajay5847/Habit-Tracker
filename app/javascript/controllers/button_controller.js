import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "ping"
  connect() {
    super.connect()
    this.send("hello", { from: "web" }, () => {
      console.log("Native replied to ping ✅")
    })
  }
}
