//
//  ViewController.swift
//  DirectoryWatcherExample
//
//  Created by Gianni Carlo on 11/6/18.
//  Copyright © 2018 Gianni Carlo. All rights reserved.
//

import UIKit
import DirectoryWatcher

class ViewController: UIViewController {
    var watcher: DirectoryWatcher!

    let hardcodedFilename = "test.txt"
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.watcher = DirectoryWatcher.watch(url)

        self.watcher.onNewFiles = { newFiles in
            print("==== new files: ", newFiles)
        }

        self.watcher.onDeletedFiles = { deletedFiles in
            print("==== deleted files: ", deletedFiles)

        }
    }

    @IBAction func addRandomFile(_ sender: UIButton) {
        let filename = "test\(Int.random(in: 0 ... 1000)).txt"
        let fileurl = self.documentsUrl.appendingPathComponent(filename)
        let contents = "test123"
        try! contents.write(to: fileurl, atomically: true, encoding: .utf8)
    }

    @IBAction func addHardCodedFile(_ sender: UIButton) {
        let fileurl = self.documentsUrl.appendingPathComponent(self.hardcodedFilename)
        let contents = "test123"
        try! contents.write(to: fileurl, atomically: true, encoding: .utf8)
    }

    @IBAction func deleteHardCodedFile(_ sender: UIButton) {
        let fileurl = self.documentsUrl.appendingPathComponent(self.hardcodedFilename)
        try? FileManager.default.removeItem(at: fileurl)
    }
}

