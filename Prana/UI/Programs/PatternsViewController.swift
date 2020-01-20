//
//  PatternsViewController.swift
//  Prana
//
//  Created by Luccas on 5/10/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class PatternsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var selectedId: Int = 0 {
        didSet {
            savedPattern.type = selectedId
            collectionView.reloadData()
        }
    }
    
    var savedPattern: SavedPattern!
    var changeListener: ((SavedPattern) -> Void)?
    var isVT: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true

        selectedId = savedPattern.type
        
        // Do any additional setup after loading the view.
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.changeListener?(self.savedPattern)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onHelp(_ sender: Any) {
        let alert = UIAlertController(style: .actionSheet)
        
        let text: [AttributedTextBlock] = [
            .header2("Slow Your Breathing"),
            .normal("Dynamic pattern changes to gradually slow your breathing. It starts off by measuring your current respiration rate, and then starts the pattern at that rate."),
            .header2("Focus"),
            .normal("Inhalation and exhalation times are equal for very consistent breathing to support concentration. BPM numbers indicate breaths per minute. Slower patterns may be more challenging and have a greater effect."),
            .header2("Relax"),
            .normal("Exhalation times are extended relative to inhalation to support a calming effect via your parasympathetic nervous system response. BPM numbers indicate breaths per minute. Slower patterns may be more challenging and have a greater effect."),
            .header2("Sleep and Anxiety"),
            .normal("These patterns include an interval of breath holding (called Retention) between your inhalation and exhalation. Exhalation times are also extended relative to inhalation to support a calming effect via your parasympathetic nervous system response. The number in the pattern name (like 4-7-8) indicates the time for each stage of your breath: inhalation, retention, and exhalation."),
            .header2("Meditation"),
            .normal("Patterns change in a cycle, with inhalation and exhalation times steadily increasing, or just exhalation time."),
            .header2("Custom"),
            .normal("Define your own breathing pattern by specifying inhalation, retention, exhalation, and time between breath parameters. Also you can create your own customized Slowing pattern."),
        ]
        
        alert.addTextViewer(text: .attributedText(text))
        alert.addAction(title: "OK", style: .cancel)
        alert.show()
    }
    
    func shouldGoCustom() {
        if selectedId == 16 {
            let vc = Utils.getStoryboardWithIdentifier(identifier: "CustomPatternViewController") as! CustomPatternViewController
            vc.subType = savedPattern.sub
            vc.startResp = savedPattern.startResp
            vc.minimumResp = savedPattern.minResp
            vc.ratio = savedPattern.ratio
            vc.inhalationTime = savedPattern.inhalationTime
            vc.exhalationTime = savedPattern.exhalationTime
            vc.retentionTime = savedPattern.retentionTime
            vc.timeBetweenBreaths = savedPattern.timeBetweenBreaths
            vc.isVT = self.isVT
            
            vc.settingChangeListener = { [weak self] (p1, p2, p3, p4, p5, p6, p7, p8) in
                self?.savedPattern.sub = p1
                self?.savedPattern.startResp = p2
                self?.savedPattern.minResp = p3
                self?.savedPattern.ratio = p4
                
                self?.savedPattern.inhalationTime = p5
                self?.savedPattern.exhalationTime = p6
                self?.savedPattern.retentionTime = p7
                self?.savedPattern.timeBetweenBreaths = p8
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PatternsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 17
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PatternCell", for: indexPath as IndexPath) as! PatternCell
        
        let (title, imagePath) = patterns[indexPath.row]
        cell.lblTitle.text = title
        cell.imageView.image = UIImage(named: imagePath)
        cell.button.setImage(UIImage(named: imagePath), for: .normal)
        cell.isSelected = indexPath.row == selectedId ? true : false
        cell.indexPath = indexPath
        cell.clickListener = { [weak self] (idpath) in
            guard let self = self else { return }
            self.selectedId = idpath.row
            self.shouldGoCustom()
        }
        
        if isVT {
            cell.isDisabled = false
        }
        else {
            let (_, disabled) = patternNames[indexPath.row]
            cell.isDisabled = disabled
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)) / 4
        
        let itemHeight = (collectionView.frame.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)) / 5
        
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let (_, disabled) = patternNames[indexPath.row]
        if disabled {
            collectionView.reloadData()
            return
        }
        
        self.selectedId = indexPath.row
        
        shouldGoCustom()
        
        print("selected")
    }
    
}
