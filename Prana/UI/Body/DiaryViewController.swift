//
//  DiaryViewController.swift
//  Prana
//
//  Created by Guru on 6/22/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class DiaryViewController: UIViewController {

    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var tvNote: UITextView!
    
    var note: String?
    var noteChangeHandler: ((String?) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let now = Date()
        lblDate.text = now.dateString()
        tvNote.text = note ?? ""
    }
    
    @IBAction func onBack(_ sender: Any) {
        let newNote = tvNote.text
        if note != newNote {
            noteChangeHandler?(newNote)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    

}
