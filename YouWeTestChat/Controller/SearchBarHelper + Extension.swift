//
//  SearchBarHelper.swift
//  YouWeTestChat
//
//  Created by Anton Makarov on 30.08.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

//////////////////////////////////////////////
// Animation settings

extension ConversationsTableViewController {
    func fadeInAnimation(_ view: UIView) {
        struct StaticAlpha {
            static var alpha = 1.00
        }
        
        if (view is UITableView) {
            self.tableView.separatorColor = self.tableView.separatorColor?.withAlphaComponent(CGFloat(StaticAlpha.alpha))
        } else if (view is UIButton) {
            self.deleteButton.alpha = CGFloat(StaticAlpha.alpha)
        }
        
        StaticAlpha.alpha -= 0.05;
        
        if (!(StaticAlpha.alpha < 0.01)) {
            self.perform(#selector(fadeInAnimation), with: view, afterDelay: 0.05)
        } else {
            StaticAlpha.alpha = 1.00
        }
    }
}

//////////////////////////////////////////////
// Search bar logic

extension ConversationsTableViewController {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard !isSearching else {
            return
        }
        
        isFade = 1
        searchBar.showsCancelButton = true
        
        fadeInAnimation(tableView)
        fadeInAnimation(deleteButton)
        deleteButton.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        
        for subView: UIView in searchBar.subviews[0].subviews {
            if let cancelButt = subView as? UIButton{
                cancelButt.setTitleColor(UIColor.white, for: .normal)
            }
        }
        
        reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            self.isFade = 2
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.separatorColor = UIColor.lightGray
        isFade = 0
        isSearching = true
        
        updateSearchResults()
    }
    
    
    func updateSearchResults() {
        if let searchText = self.searchBar.text {
            filterSearchContact(searchText: searchText)
            reloadData()
        }
    }
    
    
    func filterSearchContact(searchText: String) {
        searchMessages = messages?.filter({ (message: Message) -> Bool in
            let nameMatch = message.friend?.name?.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return nameMatch != nil
        })
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchMessages?.removeAll()
        isSearching = false
        isFade = 0
        deleteButton.alpha = 1.0
        deleteButton.isUserInteractionEnabled = true
        
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.leftBarButtonItem = leftBarButton
        
        tableView.separatorColor = self.tableView.separatorColor?.withAlphaComponent(CGFloat(1.00))
        reloadData()
        
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
    
    public func reloadData() {
        DispatchQueue.main.async() {
            self.tableView.reloadData()
        }
    }
}
