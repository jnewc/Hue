# Hue

A Philips Hue client library written in Swift.

## Usage

Example:

```swift
let hue = Hue(bridgeURL: "https://...", username: "A1B2C3...")
let subscription = hue.lights().sink { lights in
  // Do something with lights
}
```

See [docs](https://jnewc.github.io/Hue/docs/) for other APIs.
