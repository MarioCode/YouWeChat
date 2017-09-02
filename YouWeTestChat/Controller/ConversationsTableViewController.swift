//
//  ConversationsTableViewController.swift
//  YouWeTestChat
//
//  Created by Anton Makarov on 30.08.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ConversationsTableViewController: UITableViewController, UISearchBarDelegate {
    
    var messages: [Message]?
    var searchMessages: [Message]?
    var myImageNumber: Int?
    let coreData = CoreDataHelper()
    var indicator = UIActivityIndicatorView()
    var isSearching = false
    
    // isFade has three positions of animation: Off, On, and In process
    var isFade: Int = 0
    
    var leftBarButton: UIBarButtonItem!
    var rightBarButton: UIBarButtonItem!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting buttons ( + Random User and + Random Message)
        rightBarButton = UIBarButtonItem(image: UIImage(named: "randomMsg"), style: .plain, target: self, action: #selector(self.simulateMessage))
        leftBarButton = UIBarButtonItem(image: UIImage(named: "adduser"), style: .plain, target: self, action: #selector(self.addRandomFriends))
        
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        self.refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        self.refreshControl?.backgroundColor = UIColor(red: 105/255.0, green: 134/255.0, blue: 167/255.0, alpha: 100.0/100.0)
        self.refreshControl?.tintColor = UIColor.white
        
        searchBar.delegate = self
        myImageNumber = Int(arc4random_uniform(20)) + 1
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        messages = coreData.loadData()
        
        if messages?.count != 0 {
            deleteButton.isHidden = false
        }
        
        reloadData()
    }
    
    //////////////////////////////////////////////
    // Random people filling during refresh
    
    func refresh(sender:AnyObject) {
        let count = 50
        
        DispatchQueue.global(qos: .default).sync {
            self.coreData.clearData()

            for _ in 0...count {
                self.coreData.addRandomFriends(сhaos: true)
            }
            
            self.messages = self.coreData.loadData()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.deleteButton.isHidden = false
            }
        }
    }
    
    //////////////////////////////////////////////
    // Add a new user (dialogue) in a common contact list
    
    func addRandomFriends() {
        // If there are many dialogs and the list of names ends
        if (Double((messages?.count)!) / Double(names.count)) >= 0.75 {
            
            let alert = UIAlertController(title: "Красивые имена на исходе!", message: "\nОстановить добавление или добавить кракозябру?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Остановить", style: UIAlertActionStyle.cancel, handler: {
                action in
                return
            }))
            
            alert.addAction(UIAlertAction(title: "Добавить кракозябру", style: UIAlertActionStyle.default , handler: { action in
                self.addUserToCD(сhaos: true)
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        addUserToCD()
        
        // If the user list was empty (-> deleteButton.isHidden)
        deleteButton.isHidden = false
    }
    
    func addUserToCD(сhaos: Bool = false) {
        DispatchQueue.global(qos: .default).async {
            self.coreData.addRandomFriends(сhaos: сhaos)
            self.messages = self.coreData.loadData()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //////////////////////////////////////////////
    // Removing users and data from CoreData
    
    @IBAction func deleteAllChats(_ sender: Any) {
        
        let alert = UIAlertController(title: "Внимание!", message: "\nВы хотите очистить историю переписки. \nПодтвердите действие!", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertActionStyle.cancel, handler: {
            action in
            return
        }))
        
        alert.addAction(UIAlertAction(title: "Очистить", style: UIAlertActionStyle.default , handler: { action in
            
            // can be used utulity for small data size
            DispatchQueue.global(qos: .default).sync {
                self.coreData.clearData()
                self.messages?.removeAll()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.deleteButton.isHidden = true
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //////////////////////////////////////////////
    // Simulating an incoming message in a random chat
    
    func simulateMessage() {
        
        // If the list of dialogs is empty, show aler message
        guard !(messages?.isEmpty)! else {
            let alert = UIAlertController(title: "Ошибка!", message: "\nСписок диалогов пуст...", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ладно", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        // Getting random message and chat
        let phrase = phrases[Int(arc4random_uniform(UInt32(phrases.count)))]
        let randomChat = Int(arc4random_uniform(UInt32((messages?.count)!)))
        
        if let friend = messages?[randomChat].friend {
            let msg = CoreDataHelper.createMessage(text: phrase, friend: friend, time: 0, context: coreData.contextManager)
            
            do {
                try coreData.contextManager.save()
            } catch let err {
                Logger.error(msg: err as AnyObject)
            }
            
            messages?[randomChat].friend?.messages?.adding(msg as Message)
            messages = messages?.sorted(by: { (msg1, msg2) -> Bool in
                msg1.friend?.lastMessage!.date?.compare((msg2.friend?.lastMessage?.date!)! as Date) == .orderedDescending
            })
            
            reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //If the search is activated, download data from searching list
        // otherwise from the main list
        
        if isSearching {
            if let count = searchMessages?.count {
                return count
            }
        } else {
            if let count = messages?.count {
                return count
            }
        }
        
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ConversationsViewCell
        
        if let message = (isSearching) ? searchMessages?[indexPath.row] : messages?[indexPath.row] {
            cell.chatImage.image = UIImage(named: (message.friend?.image)!)
            cell.chatNameLabel.text = message.friend?.name
            cell.lastMsg = message.friend?.lastMessage
            cell.lastMsgTime = message.friend?.lastMessage?.date
            cell.isUserInteractionEnabled = true
        }
        
        // Set fade animation.
        cell.fadeInOut.alpha = 0
        
        if isFade == 1 {
            cell.isUserInteractionEnabled = false
            cell.fadeInOut.alpha = 0
            UIView.animate(withDuration: 1.5, animations: { cell.fadeInOut.alpha = 1 })
        } else if isFade == 2 {
            cell.isUserInteractionEnabled = false
            cell.fadeInOut.alpha = 1
        }
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! ChattingViewController
                destinationController.friend = (isSearching) ? searchMessages?[indexPath.item].friend : messages?[indexPath.item].friend
                destinationController.myImage = myImageNumber
            }
            
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }
}

