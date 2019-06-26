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
    var date: Date!
    var noteChangeHandler: ((String?) -> ())?
    var isEditable: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblDate.text = date.dateString()
        tvNote.text = note ?? ""
        
        if isEditable == false {
            tvNote.isEditable = false
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        let newNote = tvNote.text
        if note != newNote {
            noteChangeHandler?(newNote)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    

}
