//
//  ConversationsViewCell.swift
//  YouWeTestChat
//
//  Created by Anton Makarov on 30.08.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class ConversationsViewCell: UITableViewCell {
    
    @IBOutlet weak var chatImage: UIImageView!
    @IBOutlet weak var chatNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var lastMsgTimeLabel: UILabel!
    @IBOutlet weak var fadeInOut: UILabel!
    
    var lastMsgTime: NSDate? {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "H:mm"
            
            let elapsedTimeInSeconds = NSDate().timeIntervalSince(lastMsgTime! as Date)
            let secondInDays: TimeInterval = 60 * 60 * 24
            
            if elapsedTimeInSeconds > secondInDays * 7 {
                dateFormatter.dateFormat = "dd.MM.yy"
            } else if elapsedTimeInSeconds > secondInDays {
                dateFormatter.dateFormat = "EEEE"
            }
            
            self.lastMsgTimeLabel.text = dateFormatter.string(for: lastMsgTime)?.capitalized
        }
    }
    
    var lastMsg: Message? {
        didSet {
            var youText = ""
            var cellText = ""
            var myMutableString = NSMutableAttributedString()
            let youColor = UIColor(red: 80/255.0, green: 114/255.0, blue: 153/255.0, alpha: 100.0/100.0)
            
            if (lastMsg?.isSender)! {
                youText = "Вы: "
            }
            
            cellText = youText + (lastMsg?.text)!
            
            myMutableString = NSMutableAttributedString(string: cellText, attributes: [NSFontAttributeName:UIFont(name: self.lastMessageLabel.font.fontName, size: 15.0)!])
            
            // blue pointer to the fact that you are is sender
            if youText != "" {
                myMutableString.addAttribute(NSForegroundColorAttributeName, value: youColor, range: NSRange(location:0, length:3))
            }
            
            self.lastMessageLabel.text = cellText
            self.lastMessageLabel.attributedText = myMutableString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
