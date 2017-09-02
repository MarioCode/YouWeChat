//
//  CoreDataOperations.swift
//  YouWeTestChat
//
//  Created by Anton Makarov on 30.08.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataHelper {
    
    let contextManager = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var messages: [Message]?
    
    
    func addRandomFriends(сhaos: Bool = false) {
        let user = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: contextManager) as! Friend
        
        if сhaos {
            user.name = randomString(length: 5)
        } else {
            repeat {
                user.name = names[Int(arc4random_uniform(UInt32(names.count)))]
            } while (someEntityExists(name: user.name!))
        }
        
        user.image = String(Int(arc4random_uniform(20)) + 1) // 1 - 20
        
        let countMessagesInChat = Int(arc4random_uniform(5)) + 1 // 1 - 5
        
        for _ in 0...countMessagesInChat {
            let phrase = phrases[Int(arc4random_uniform(UInt32(phrases.count)))]
            let time = Double(arc4random_uniform(UInt32(10 * 60 * 24))) // Last 10 days
            
            user.lastMessage = CoreDataHelper.createMessage(text: phrase, friend: user, time: time, context: contextManager)
        }
        
        let chatMessages = user.messages?.allObjects as? [Message]
        user.lastMessage = chatMessages?.sorted(by: { (msg1, msg2) -> Bool in
            msg1.date?.compare(msg2.date! as Date) == .orderedAscending
        }).last
        
        do {
            try contextManager.save()
        } catch let err {
            Logger.error(msg: err as AnyObject)
        }
    }
    
    
    func someEntityExists(name: String) -> Bool {
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Message")
        request.predicate = NSPredicate(format: "friend.name = %@", name)
        
        do {
            if (try contextManager.count(for: request)) != 0 {
                return true
            }
        } catch let err {
            Logger.error(msg: err as AnyObject)
        }
        
        return false
    }
    
    
    static func createMessage(text: String, friend: Friend, time: Double, context: NSManagedObjectContext, isSender: Bool = false) -> Message {
        var newMssage = Message()
        
        DispatchQueue.global(qos: .userInitiated).sync {
            newMssage = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
            newMssage.text = text
            newMssage.friend = friend
            newMssage.date = NSDate().addingTimeInterval(-time * 60)
            newMssage.isSender = isSender
            
            friend.lastMessage = newMssage
        }
        
        return newMssage
    }
    
    
    func fetchFriends() -> [Friend]? {
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Friend")
        
        do {
            return try(contextManager.fetch(request)) as? [Friend]
        } catch let err {
            Logger.error(msg: err as AnyObject)
        }
        
        return nil
    }
    
    
    func loadData() -> [Message]? {
        
        if let friends = fetchFriends() {
            messages = [Message]()
            
            for friend in friends {
                let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Message")
                request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                request.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
                request.fetchLimit = 1
                
                do {
                    let fetchMessages = try(contextManager.fetch(request)) as? [Message]
                    messages?.append(contentsOf: fetchMessages!)
                } catch let err {
                    Logger.error(msg: err as AnyObject)
                }
            }
            
            messages = messages?.sorted(by: { (msg1, msg2) -> Bool in
                msg1.friend?.lastMessage!.date?.compare((msg2.friend?.lastMessage?.date!)! as Date) == .orderedDescending
            })
            
            return messages
        }
        
        return nil
    }
    
    
    func clearData() {
        do {
            let entityNames = ["Friend", "Message"]
            
            for entityName in entityNames {
                let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                let objects = try(contextManager.fetch(request)) as? [NSManagedObject]
                
                for object in objects! {
                    contextManager.delete(object)
                }
            }
            
            try contextManager.save()
            
        } catch let err {
            Logger.error(msg: err as AnyObject)
        }
    }
    
    //////////////////////////////////////////////
    // Generate random string for user name
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
}
