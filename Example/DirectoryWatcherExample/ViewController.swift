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
	var deepWatcher: DirectoryDeepWatcher!

    let hardcodedFilename = "test.txt"
	let hardcodedFoldername = "MyFolder"

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
		
		self.deepWatcher = DirectoryDeepWatcher.watch(url)
		
		self.deepWatcher.onFolderNotification = { folder in
			let log = "==== folder notification: \n\(folder.description)"
            print(log)
            self.updateLogs(log)
		}
    }

    func updateLogs(_ text: String) {
		DispatchQueue.main.async {
			self.textView.text = "\n\(text)\n" + self.textView.text
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
	
	@IBAction func createFolder(_ sender: UIButton) {
		let subfoldername = "Subfolder"
		let filename = "test\(Int.random(in: 0 ... 1000)).txt"
		
		let folder = self.documentsUrl
			.appendingPathComponent(self.hardcodedFoldername, isDirectory: true)
		let subfolder = self.documentsUrl
			.appendingPathComponent(self.hardcodedFoldername, isDirectory: true)
			.appendingPathComponent(subfoldername, isDirectory: true)
		
		let fileurl1 = folder
			.appendingPathComponent(filename)
        let contents = "test123"
		try! FileManager.default.createDirectory(atPath: folder.path, withIntermediateDirectories: true, attributes: nil)
        try! contents.write(to: fileurl1, atomically: true, encoding: .utf8)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			print("========= first callback")
			let fileurl2 = subfolder
				.appendingPathComponent(filename)
			try! FileManager.default.createDirectory(atPath: subfolder.path, withIntermediateDirectories: true, attributes: nil)
			try! contents.write(to: fileurl2, atomically: true, encoding: .utf8)
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				print("========= second callback")
				let subfoldername2 = "Subfolder2"
				
				let subfolder2 = subfolder
					.appendingPathComponent(subfoldername2)
				try! FileManager.default.createDirectory(atPath: subfolder2.path, withIntermediateDirectories: true, attributes: nil)
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
					print("========= third callback")
					let fileurl3 = subfolder2
						.appendingPathComponent(filename)
					try! contents.write(to: fileurl3, atomically: true, encoding: .utf8)
				}
			}
		}
	}
}

