//
//  MyMembersCell.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/13/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

protocol MemberCellDelegate {
    
    func didTappedAccept(friend: FriendList, friend2: FriendList)
    func didTappedMore(friend: FriendList, friend2: FriendList)
    
}

class MyMembersCell: UITableViewCell {

    @IBOutlet weak var profilePicture: customUIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    
    var delegate: MemberCellDelegate?
    var friend: FriendList?
    var addedFriend: FriendList?
    
    func configureCell(profilePicture: UIImage, buttonTitle: String, friendList: FriendList?, addedFriend: FriendList?) {
        
        self.profilePicture.image = profilePicture
        self.emailLabel.text = friendList?.email
        self.acceptButton.setTitle(buttonTitle, for: .normal)
        self.friend = friendList
        self.addedFriend = addedFriend
    }
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        if let friend = friend, let friend2 = addedFriend {
            delegate?.didTappedAccept(friend: friend, friend2: friend2)
        }
        
        
    }
    
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        if let friend = friend, let friend2 = addedFriend {
            delegate?.didTappedMore(friend: friend, friend2: friend2)
        }
        
    }
    
    
    

}
