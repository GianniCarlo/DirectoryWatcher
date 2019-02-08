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
    @IBOutlet weak var textView: UITextView!

    var watcher: DirectoryWatcher!

    let hardcodedFilename = "test.txt"
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.watcher = DirectoryWatcher.watch(url)

        self.watcher.onNewFiles = { newFiles in
            let log = "==== new files \(newFiles.count): \n\(newFiles.description)"
            print(log)
            self.updateLogs(log)
        }

        self.watcher.onDeletedFiles = { deletedFiles in
            let log = "==== deleted files: \n\(deletedFiles.description)"
            print(log)
            self.updateLogs(log)
        }
    }

    func updateLogs(_ text: String) {
        self.textView.text = "\n\(text)\n" + self.textView.text
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

