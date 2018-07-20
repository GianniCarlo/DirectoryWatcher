//
//  DirectoryWatcher.swift
//  DirectoryWatcher
//
//  Created by Gianni Carlo on 7/19/18.
//  Copyright © 2018 Tortuga Power. All rights reserved.
//

import Foundation

public class DirectoryWatcher: NSObject {
    static let retryCount = 5
    static let pollInterval = 0.2
    
    var watchedPath: String
    
    private var source: DispatchSourceFileSystemObject?
    private var queue: DispatchQueue?
    private var retriesLeft: Int!
    private var directoryChanging = false
    private var callback: (() -> Void)?
    
    //init
    init(watchedPath: String) {
        self.watchedPath = watchedPath
    }
    
    public class func watch(_ url: URL, callback: @escaping @convention(block) () -> Void) -> DirectoryWatcher? {
        let path = url.path
        return DirectoryWatcher.watch(path, callback: callback)
    }
    
    public class func watch(_ path: String, callback: @escaping @convention(block) () -> Void) -> DirectoryWatcher? {
        let directoryWatcher = DirectoryWatcher(watchedPath: path)
        directoryWatcher.callback = callback
        
        guard directoryWatcher.startWatching() else {
            // Something went wrong, return nil
            return nil
        }
        
        return directoryWatcher
    }
    
    public func startWatching() -> Bool {
        // Already monitoring
        guard self.source == nil else { return false }
        
        let descriptor = open(self.watchedPath, O_EVTONLY)
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
    
    deinit {
        let _ = self.stopWatching()
        self.callback = nil
    }
}

// MARK: - Private methods
extension DirectoryWatcher {
    private func directoryMetadata(_ path: String) -> [String]? {
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: path) else {
            return nil
        }
        var directoryMetadata = [String]()
        for filename in contents {
            
            let filePath = (path as NSString).appendingPathComponent(filename)
            
            guard let fileAttributes = try? FileManager.default.attributesOfItem(atPath: filePath),
                let fileSize = fileAttributes[.size] as? Double else {
                    continue
            }
            
            let sizeString = String(Int(fileSize))
            let fileHash = filename + sizeString
            
            directoryMetadata.append(fileHash)
        }
        
        return directoryMetadata
    }
    
    private func checkChanges(after delay: TimeInterval) {
        guard let directoryMetadata = self.directoryMetadata(self.watchedPath),
            let queue = self.queue else {
                return
        }
        
        let time = DispatchTime.now() + delay
        
        queue.asyncAfter(deadline: time) { [weak self] in
            self?.pollDirectoryForChangesWith(directoryMetadata)
        }
    }
    
    private func pollDirectoryForChangesWith(_ oldMetadata: [String]){
        guard let newDirectoryMetadata = self.directoryMetadata(self.watchedPath) else {
            return
        }
        
        self.directoryChanging = newDirectoryMetadata != oldMetadata
        self.retriesLeft = self.directoryChanging
            ? DirectoryWatcher.retryCount
            : self.retriesLeft
        
        self.retriesLeft = self.retriesLeft - 1
        if self.directoryChanging || 0 < self.retriesLeft {
            // Either the directory is changing or
            // we should try again as more changes may occur
            self.checkChanges(after: DirectoryWatcher.pollInterval)
        } else {
            // Changes appear to be completed
            // Post a notification informing that the directory did change
            DispatchQueue.main.async {
                self.callback?()
            }
        }
    }
    
    private func directoryDidChange() {
        guard !self.directoryChanging else {
            return
        }
        self.directoryChanging = true
        self.retriesLeft = DirectoryWatcher.retryCount
        
        self.checkChanges(after: DirectoryWatcher.pollInterval)
    }
}
