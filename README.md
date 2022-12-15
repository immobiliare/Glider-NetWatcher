<p align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./Documentation/assets/glider-netwatcher-dark.png" width="350">
  <img alt="logo-library" src="./Documentation/assets/glider-netwatcher-light.png" width="350">
</picture>
</p>

[![Swift](https://img.shields.io/badge/Swift-5.1_5.3_5.4_5.5_5.6_5.7-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.1_5.3_5.4_5.5_5.6_5.7-Orange?style=flat-square)
[![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux-4E4E4E.svg?colorA=28a745)](#installation)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/GliderSentry.svg?style=flat-square)](https://img.shields.io/cocoapods/v/GliderLogger.svg)

# Glider

**Glider is the logger for just about everything!**

It's designed to be:
- **SIMPLE**: with a modular & extensible architecture, fully documented
- **PERFORMANT**: you can use Glider without the worry of impacting your app performances
- **UNIVERSAL**: it supports 14+ transports to satisfy every need; you can create your transport too!

See the [project's page on GitHub for more informations](https://github.com/immobiliare/Glider).

# Glider-NetWatcher
- [Glider](#glider)
- [Glider-NetWatcher](#glider-netwatcher)
  - [Introduction](#introduction)
  - [Installation](#installation)
  - [Capture Taffic](#capture-taffic)
    - [NetWatcherDelegate](#netwatcherdelegate)
  - [Transports](#transports)
    - [NetSparseFilesTransport](#netsparsefilestransport)
    - [NetArchiveTransport](#netarchivetransport)
  - [Requirements](#requirements)
## Introduction

`NetWatcher` package is a simple, unintrusive network activity logger perfectly integrated in Glider.
Log every request your app makes, or limit to only those using a certain `URLSession` if you'd prefer. 
It also works with Alamofire and RealHTTP, if that's your thing.

- No code to write and no imports.
- Record all app traffic that uses NSURLSession.
- Log the content of all requests, responses, and headers with no hassles with SSL/HTTPS
- Find, isolate and fix bugs quickly.
- Also works with external libraries like Alamofire & RealHTTP.
- Ability to blacklist hosts from being recorded using the array ignoredHosts.
- Ability to share cURL representation of API requests

## Installation

`NetWatcher` is not part of the Glider Core; you can install it by selecting the `GliderNetWatcher` package when installing the main Glider dependency or by using the `GliderNetWatcher.podspec` if you are using CocoaPods

## Capture Taffic

If you want to capture all the network traffic inside the app, just call `captureGlobally()` method:

```swift
// Start global capture
NetWatcher.shared.captureGlobally(true)

// ...Same to stop
NetWatcher.shared.captureGlobally(false)
```

for `URLSessionConfiguration`:

```swift
let configuration = URLSessionConfiguration.default
**NetWatcher**.shared.capture(true, forSessionConfiguration: configuration)

// ...Same to stop
NetWatcher.shared.capture(false, forSessionConfiguration: configuration)
```

Most of the time you may want to capture sniffed traffics to send it to a Glider Transport service.  
`NetWatcher` is perfectly integrated: just set your custom configuration before activating the sniffer:

The following example uses the `NetArchiveTransport` transport; a transport made to store network requests/responses directly in a compact, readable SQLite3 local database (it's like `SQLiteTransport`).

```swift
// Setup the configuration
let archiveURL = URL(fileURLWithPath: ".../sniffed_network.sqlite")
let archiveConfig = NetArchiveTransport.Configuration(location: .fileURL(archiveURL))
NetWatcher.shared.setConfiguration(watcherConfig)
// Activate global sniffer
NetWatcher.shared.captureGlobally(true)
```

### NetWatcherDelegate

Sometimes you may want to avoid redirecting captured traffic inside a transport and just get notified about the event.  
In this case just set the delegate of `NetWatcher` singleton and listen for events:

```swift
class UIApplication: UIApplicationDelegate, NetWatcherDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      NetWatcher.shared.delegate = self
      NetWatcher.shared.captureGlobally(true)
      return true
  }

  func netWatcher(_ watcher: NetWatcher, didCaptureEvent event: NetworkEvent) {
      // A new event has been captured!
      print("Captured request from \(event.url)...")
  }
    
  func netWatcher(_ watcher: NetWatcher, shouldRecordRequest request: URLRequest) -> Bool {
    // implement your own logic to filter/ignore a request from being captured.
    // return ...
  }

}
```

## Transports

`NetWatcher` has two transport specifically made to store network events.  
You can, however, create your own implementation to suit your need.

### NetSparseFilesTransport

The `NetSparseFilesTransport` class is used to store network activity inside a root folder.

Each call is stored with a single textual file with the id of the network call and its creation date set to the original call date.
Inside each file you can found `<cURL command for request>\n\n<raw response data>`.

```swift
let sparseArchive = NetSparseFilesTransport.Config {
  $0.directoryURL = localFolderURL // location of the directory (will be created if not exists)
  $0.resetAtStartup = false // do not remove previously-stored data at launch
}
NetWatcher.shared.setConfiguration(sparseArchive)
```

### NetArchiveTransport

The `NetArchiveTransport` class is used to store network activity in a compact searchable archive powered by SQLite3.

```swift
let archive = NetArchiveTransport.Config {
  $0.databaseLocation = .fileURL(localDbURL)
  $0.throttledTransport = .init { t in
      t.maxEntries = 500 // maximum number of logs to store
  }
  // The maximum age of a log before it it will be removed automatically to preserve the space. Set as you needs.
  $0.lifetimeInterval = 60 * 60 // 1h
}
NetWatcher.shared.setConfiguration(archive)
```

## Requirements

Minimum requirements are:
- Swift 5.5
- iOS 13+, macOS 11+, tvOS 13.0+