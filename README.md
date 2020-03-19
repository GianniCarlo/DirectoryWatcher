This is a Swift translation of the [Objective C version](https://github.com/hwaxxer/MHWDirectoryWatcher). Took some inspiration from [this repo](https://github.com/dagostini/DAFileMonitor/tree/blog_dispatch_sources) as well

# DirectoryWatcher
`DirectoryWatcher` is a lightweight class that uses GCD to monitor a given path for changes.
When any change to the directory occurs, `DirectoryWatcher` starts polling the monitored path, making sure that file transfers are finished before posting notifications.

## Installing

### [CocoaPods](https://cocoapods.org/) (recommended)

````ruby
# For latest release in cocoapods
pod 'DirectoryWatcher'
````

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](https://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate DirectoryWatcher into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "GianniCarlo/DirectoryWatcher" ~> 2.0.0
```

Run `carthage update` to build the framework and drag the built `DirectoryWatcher.framework` into your Xcode project.

## Usage (DirectoryWatcher)

Monitor the Documents Folder

```swift
let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let watcher = DirectoryWatcher.watch(documentsUrl)

watcher.onNewFiles = { newFiles in
  // Files have been added
}

watcher.onDeletedFiles = { deletedFiles in
  // Files have been deleted
}
```
Call `watcher.stopWatching()` and `watcher.startWatching()` to pause / resume.

## Usage (DirectoryDeepWatcher)

Monitor the Documents Folder and its subfolders

```swift
let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let watcher = DirectoryDeepWatcher.watch(documentsUrl)

watcher.onFolderNotification = { folder in
  // New changes have happened inside one folder
  // This folder could be a subfolder inside the root folder being watched
}

```


Call `watcher.stopWatching()` and `watcher.startWatching()` to pause / resume, or `watcher.restartWatching()` to discard previous listeners and place new ones in case the hierarchy has changed