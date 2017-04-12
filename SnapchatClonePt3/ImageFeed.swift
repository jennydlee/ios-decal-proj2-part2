//
//  imageFeed.swift
//  snapChatProject
//
//  Created by Akilesh Bapu on 2/27/17.
//  Copyright © 2017 org.iosdecal. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase


var threads: [String: [Post]] = ["Memes": [], "Dog Spots": [], "Random": []]


let threadNames = ["Memes", "Dog Spots", "Random"]


func getPostFromIndexPath(indexPath: IndexPath) -> Post? {
    let sectionName = threadNames[indexPath.section]
    if let postsArray = threads[sectionName] {
        return postsArray[indexPath.row]
    }
    print("No post at index \(indexPath.row)")
    return nil
}

func addPostToThread(post: Post) {
    threads[post.thread]!.append(post)
}

func clearThreads() {
    threads = ["Memes": [], "Dog Spots": [], "Random": []]
}


func addPost(postImage: UIImage, thread: String, username: String) {
    let dbRef = FIRDatabase.database().reference()
    let data = UIImageJPEGRepresentation(postImage, 1.0)! 
    let path = "\(firStorageImagesPath)/\(UUID().uuidString)"
    let date = DateFormatter()
    date.dateFormat = dateFormat
    let dict = ["imagePath": path,
                   "thread": thread,
                   "username": username,
                   "date": date.string(from: Date())]
    dbRef.child(firPostsNode).childByAutoId().setValue(dict)
    store(data: data, toPath: path)
    
}


func store(data: Data, toPath path: String) {
    let storageRef = FIRStorage.storage().reference()
    storageRef.child(path).put(data, metadata: nil) { (metadata, error) in
        if let err = error {
            print(err)
        }
    }
}

func getPosts(user: CurrentUser, completion: @escaping ([Post]?) -> Void) {
    let dbRef = FIRDatabase.database().reference()
    var postArray: [Post] = []
    dbRef.child(firPostsNode).observeSingleEvent(of: .value, with: {(snapshot) in
        if(snapshot.exists()) {
            let values = snapshot.value as? [String: AnyObject]
            user.getReadPostIDs(completion: { (readPosts) in
                for (key, val) in values! {
                    var username : String?
                    var imagePath : String?
                    var thread : String?
                    var date : String?
                    let read = readPosts.contains(key)
                    if let uservalue = val.value(forKey: "username") as? String {
                        username = uservalue
                    }
                    if let pathvalue = val.value(forKey: "imagePath") as? String {
                        imagePath = pathvalue
                    }
                    if let threadvalue = val.value(forKey: "thread") as? String {
                        thread = threadvalue
                    }
                    if let datevalue = val.value(forKey: "date") as? String {
                        date = datevalue
                    }
                    let newpobj = Post(id: key,
                                       username: username!,
                                       postImagePath: imagePath!,
                                       thread: thread!,
                                       dateString: date!,
                                       read: read)
                    postArray.append(newpobj)
                }
            })
        }
        completion(postArray)
    })
}

func getDataFromPath(path: String, completion: @escaping (Data?) -> Void) {
    let storageRef = FIRStorage.storage().reference()
    storageRef.child(path).data(withMaxSize: 5 * 1024 * 1024) { (data, error) in
        if let error = error {
            print(error)
        }
        if let data = data {
            completion(data)
        } else {
            completion(nil)
        }
    }
}


