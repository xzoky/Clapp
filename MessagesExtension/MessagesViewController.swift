//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Camille Kander on 2017-03-01.
//  Copyright © 2017 Camille Kander. All rights reserved.
//

import UIKit
import Messages

fileprivate let emojiIndexDefaultsKey = "emojiIndex"

class MessagesViewController: MSMessagesAppViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var skinToneControl: UISegmentedControl!
    
    var emoji: String {
        return skinToneControl.titleForSegment(at: skinToneControl.selectedSegmentIndex) ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let index = UserDefaults.standard.integer(forKey: "emojiIndex")
        if index < skinToneControl.numberOfSegments {
            skinToneControl.selectedSegmentIndex = index
        } else {
            skinToneControl.selectedSegmentIndex = 0
        }
        
        searchBar.returnKeyType = .done
        searchBar.setImage(emoji.image(), for: .search, state: .normal)
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
        if presentationStyle == .expanded {
            searchBar.becomeFirstResponder()
        }
    }
    
    override func willResignActive(with conversation: MSConversation) {
        super.willResignActive(with: conversation)
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func skinToneControlValueChanged(_ control: UISegmentedControl) {
        searchBar.setImage(emoji.image(), for: .search, state: .normal)
        UserDefaults.standard.set(control.selectedSegmentIndex, forKey: emojiIndexDefaultsKey)
    }
}

extension MessagesViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        requestPresentationStyle(.expanded)
        return presentationStyle == .expanded
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        activeConversation?.insertText(text.clappified(with: emoji), completionHandler: nil)
        searchBar.text = nil
        dismiss()
    }
}

fileprivate extension String {
    
    func clappified(with emoji: String) -> String {
        let comps = components(separatedBy: " ")
        guard comps.count > 1 else { return self }
        let claps = [String](repeating: emoji, count: comps.count - 1)
        let merged =  zip(comps, claps).flatMap { [$0, $1] }.joined(separator: " ")
        return merged + " " + comps.last!
    }
    
    func image() -> UIImage? {
        let size = CGSize(width: 13, height: 13)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        (self as NSString).draw(in: CGRect(origin: .zero, size: size), withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 10.5)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
