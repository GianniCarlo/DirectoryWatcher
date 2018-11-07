//
//  DirectoryWatcher.swift
//  DirectoryWatcher
//
//  Created by Gianni Carlo on 7/19/18.
//  Copyright © 2018 Tortuga Power. All rights reserved.
//

import Foundation

public class DirectoryWatcher: NSObject {
    
    var watchedUrl: URL
    
    private var source: DispatchSourceFileSystemObject?
    private var previousContents: Set<URL>
    private var queue: DispatchQueue?

    public var onNewFiles: (([URL]) -> Void)?
    public var onDeletedFiles: (([URL]) -> Void)?
    
    //init
    init(watchedUrl: URL) {
        self.watchedUrl = watchedUrl
        let contentsArray = (try? FileManager.default.contentsOfDirectory(at: watchedUrl, includingPropertiesForKeys: [], options: .skipsHiddenFiles)) ?? []
        self.previousContents = Set(contentsArray)
    }
    
    public class func watch(_ url: URL) -> DirectoryWatcher? {
        let directoryWatcher = DirectoryWatcher(watchedUrl: url)

        guard directoryWatcher.startWatching() else {
            // Something went wrong, return nil
            return nil
        }

        return directoryWatcher
    }
    
    public func startWatching() -> Bool {
        // Already monitoring
        guard self.source == nil else { return false }
        
        let descriptor = open(self.watchedUrl.path, O_EVTONLY)
        guard descriptor != -1 else { return false }
        
        self.queue = DispatchQueue.global()
        self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor, eventMask: .write, queue: self.queue)
        
        self.source?.setEventHandler {
            [weak self] in
            self?.directoryDidChange()
        }
        
        self.source?.setCancelHandler() {
            close(descriptor)
        }
        
        self.source?.resume()
        
        return true
    }
    
    public func stopWatching() -> Bool {
        guard let source = source else {
            return false
        }
        
        source.cancel()
        self.source = nil
        
        return true
    }

    private func directoryDidChange() {
        let contentsArray = (try? FileManager.default.contentsOfDirectory(at: watchedUrl, includingPropertiesForKeys: [], options: .skipsHiddenFiles)) ?? []
        let newContents = Set(contentsArray)

        let newElements = newContents.subtracting(self.previousContents)
        let deletedElements = self.previousContents.subtracting(newContents)

        self.previousContents = newContents

        if !deletedElements.isEmpty {
            self.onDeletedFiles?(Array(deletedElements))
        }

        if !newElements.isEmpty {
            self.onNewFiles?(Array(newElements))
        }
    }
    
    deinit {
        let _ = self.stopWatching()
        self.onNewFiles = nil
        self.onDeletedFiles = nil
    }
}
