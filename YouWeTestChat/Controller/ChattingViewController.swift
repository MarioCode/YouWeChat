//
//  ChattingViewController.swift
//  YouWeTestChat
//
//  Created by Anton Makarov on 30.08.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import JSQMessagesViewController


class ChattingViewController: JSQMessagesViewController {
    
    lazy var managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var JSQMessages = [JSQMessage] ()
    var chatMessages: [Message]?
    var myImage : Int?
    
    var friend: Friend? {
        didSet {
            navigationItem.title = friend?.name
            chatMessages = friend?.messages?.allObjects as? [Message]
            
            chatMessages = chatMessages?.sorted(by: { (msg1, msg2) -> Bool in
                msg1.date?.compare(msg2.date! as Date) == .orderedAscending
            })
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "randomMsg"), style: .plain, target: self, action: #selector(self.simulateMessage))
        
        self.senderId = "To"
        self.senderDisplayName = "Anton" // required value, but not used in fact
        
        
        DispatchQueue.global(qos: .default).async {
            self.observeMessages()
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        setBackground()
    }
    
    
    func observeMessages() {
        for msg in chatMessages! {
            if msg.isSender {
                JSQMessages.append(JSQMessage(senderId: "To", displayName: senderDisplayName, text: msg.text))
            } else {
                JSQMessages.append(JSQMessage(senderId: "From", displayName: senderDisplayName, text: msg.text))
            }
        }
        
        finishReceivingMessage()
    }
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        _ = CoreDataHelper.createMessage(text: text, friend: friend!, time: 0, context: managedContext, isSender: true)
        
        do {
            try managedContext.save()
        } catch let err {
            Logger.error(msg: err as AnyObject)
        }
        
        JSQMessages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        collectionView.reloadData()
        
        finishSendingMessage()
    }
    
    
    func simulateMessage() {
        let phrase = phrases[Int(arc4random_uniform(UInt32(phrases.count)))]
        
        _ = CoreDataHelper.createMessage(text: phrase, friend: friend!, time: 0, context: managedContext)
        
        do {
            try managedContext.save()
        } catch let err {
            Logger.error(msg: err as AnyObject)
        }
        
        JSQMessages.append(JSQMessage(senderId: "From", displayName: senderDisplayName, text: phrase))
        collectionView.reloadData()
    }
    
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Упс!", message: "\nЧат только для текстовых сообщений. \nФайлы как нибудь потом...", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ладно", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return JSQMessages[indexPath.item]
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        guard JSQMessages[indexPath.item].senderId == senderId else {
            return outgoingBubbleImageView
        }
        
        return incomingBubbleImageView
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return JSQMessages.count
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message: JSQMessage = self.JSQMessages[indexPath.item]
        return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView?.textColor = UIColor.black
        
        if JSQMessages[indexPath.item].senderId == "To" {
            cell.avatarImageView.image = UIImage(named: String(describing: myImage!))
        } else {
            cell.avatarImageView.image = UIImage(named: (friend?.image)!)
        }
        
        cell.avatarImageView.clipsToBounds = true;
        cell.avatarImageView.layer.cornerRadius = 15;
        cell.avatarImageView.isHidden = false;
        
        return cell
    }
    
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor(red: 242.0/255, green: 250.0/255, blue: 223.0/255, alpha: 1.0))
    }
    
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor(red: 1, green: 1, blue: 1, alpha: 1.0))
    }
    
    
    func setBackground() {
        let image = UIImage(named: "background.png")
        let imgBackground:UIImageView = UIImageView(frame: self.view.bounds)
        imgBackground.image = image
        imgBackground.contentMode = UIViewContentMode.scaleAspectFill
        imgBackground.clipsToBounds = true
        self.collectionView?.backgroundView = imgBackground
    }
}
