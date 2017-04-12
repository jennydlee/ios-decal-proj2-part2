//
//  CurrentUser.swift
//  SnapchatClonePt3
//
//  Created by SAMEER SURESH on 3/19/17.
//  Copyright © 2017 iOS Decal. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class CurrentUser {
    
    var username: String!
    var id: String!
    var readPostIDs: [String]?
    
    let dbRef = FIRDatabase.database().reference()
    
    init() {
        let currentUser = FIRAuth.auth()?.currentUser
        username = currentUser?.displayName
        id = currentUser?.uid
    }
    
    func getReadPostIDs(completion: @escaping ([String]) -> Void) {
        var postArray: [String] = []
        dbRef.child(firUsersNode).child(id!).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists()) {
                let values = snapshot.value as? [String: [String: String]]
                if let readDict = values?[firReadPostsNode] {
                    for(_, postID) in readDict {
                        postArray.append(postID)
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        completion(postArray)
    }
    
    func addNewReadPost(postID: String) {
        dbRef.child(firUsersNode).child(id!).child(firReadPostsNode).childByAutoId().setValue(postID)
        readPostIDs?.append(postID)
    }
    
}
