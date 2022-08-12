//
//  Service.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/21.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import RxSwift
import NMapsMap
import FirebaseMessaging
import RxCocoa

enum ServiceError: Error {
    case userFetching
    
}

class Service {

    static var shared = Service()
    
    init() {
        print("@@@@@@ Service Init @@@@@@")
    }
    deinit {
        print("@@@@@@ Service Deinit @@@@@@")
    }
    
    private let ref = Database.database().reference()
    private let bag = DisposeBag()
    
    var curUserSubject = BehaviorSubject<User>(value: User())
    
    func insertNewUser(uid: String, user: User) -> Completable {
        return Completable.create { [unowned self] completable in
            let name = user.name
            let birth = user.birth
            let gender = user.gender
            let img = user.img!
            var token = "Default"
            Messaging.messaging().token { t, error in
                guard t != nil, error == nil else { return }
                token = t!
            }
            
            self.uploadProfileImgToStorage(uid: uid, image: img)
                .subscribe(onSuccess: { [unowned self] url in
                    self.ref.child("user").child(uid).setValue(["uid": uid, "token": token, "imgURL": url.absoluteString, "name": name, "birth": birth, "gender": gender ])
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                })
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }

    func fetchUser(uid: String) -> Observable<User> {
        return Observable.create { [unowned self] emitter in
            self.ref.child("user").child(uid).observeSingleEvent(of: .value) { [unowned self] snapShot in
                let value = snapShot.value as? [String: Any]
                
                guard let urlStr = value?["imgURL"] as? String,
                      let imgURL = URL(string: urlStr),
                      let name = value?["name"] as? String,
                      let gender = value?["gender"] as? String,
                      let birth = value?["birth"] as? String else {
//                          emitter.onError(ServiceError.userFetching)
                    return
                }

                let user = User(img: nil, imgURL: imgURL, uid: uid, name: name, birth: birth, gender: gender)
                
                if let token = value?["token"] as? String {
                    user.token = token
                }
                
                if let promisePuids = value?["promisePuids"] as? [String: String] {
                    let puid = promisePuids.map { $0.key }
                    user.promisePuids = puid
                }
                
                if let postPuids = value?["postPuids"] as? [String: String] {
                    let puid = postPuids.map { $0.key }
                    user.postPuids = puid
                }
                emitter.onNext(user)

            }
            return Disposables.create {
                emitter.onCompleted()
            }
        }
    }
    
    func fetchUsers() -> Observable<[User]> {
        return Observable.create { [unowned self] emitter in
            var users = [User]()
            self.ref.child("user").observeSingleEvent(of: .value) { [unowned self] snapShot in
                for userSnapShot in snapShot.children.allObjects as! [DataSnapshot] {
                    let value = userSnapShot.value as? [String: Any]

                    guard let urlStr = value?["imgURL"] as? String,
                          let imgURL = URL(string: urlStr),
                          let uid = value?["uid"] as? String,
                          let name = value?["name"] as? String,
                          let gender = value?["gender"] as? String,
                          let birth = value?["birth"] as? String else {
                              
                        emitter.onNext(users)
                        return
                    }

                    let user = User(img: nil, imgURL: imgURL, uid: uid, name: name, birth: birth, gender: gender)
                    
                    if let token = value?["token"] as? String {
                        user.token = token
                    }
                    
                    if let promisePuids = value?["promisePuids"] as? [String: String] {
                        let puid = promisePuids.map { $0.key }
                        user.promisePuids = puid
                    }
                    if let postPuids = value?["postPuids"] as? [String: String] {
                        let puid = postPuids.map { $0.key }
                        user.postPuids = puid
                    }
                    
                    users.append(user)
                    emitter.onNext(users)
                }
            }
            return Disposables.create { emitter.onCompleted() }
        }
    }
    
    private func uploadProfileImgToStorage(uid: String, image: UIImage) -> Single<URL> {
        return Single.create { [unowned self] single in
            let ref = Storage.storage().reference()
            let dataImage = image.jpegData(compressionQuality: 0.1)!
            let imageRef = ref.child("user").child(uid).child("profileImg")
            
            imageRef.putData(dataImage, metadata: nil) { [unowned self] (storageMetaData, error) in
                guard error == nil else { return single(.error(error!)) }
                imageRef.downloadURL { [unowned self] (url, error) in
                    guard url != nil, error == nil else { return single(.error(error!)) }
                    single(.success(url!))
                }
            }
            return Disposables.create()
        }
    }
    
    private func uploadPostImgToStorage(uid: String, puid: String, image: UIImage) -> Single<URL> {
        return Single.create { [unowned self] single in
            let ref = Storage.storage().reference()
            let dataImage = image.jpegData(compressionQuality: 0.1)!
            let imageRef = ref.child("user").child(uid).child("postImg").child(puid)
            
            imageRef.putData(dataImage, metadata: nil) { [unowned self] (storageMetaData, error) in
                guard error == nil else { return single(.error(error!)) }
                imageRef.downloadURL { [unowned self] (url, error) in
                    guard url != nil, error == nil else { return single(.error(error!)) }
                    single(.success(url!))
                }
            }
            return Disposables.create()
        }
    }
    
    func uploadPost(post: Post) -> Single<String> {
        return Single.create { [unowned self] single in
            let puid = self.ref.child("post").childByAutoId().key!
            let promiseDic = ["maxPeople": post.promise.maxPeople, "hostUid": post.promise.hostUid] as [String: Any]

            self.uploadPostImgToStorage(uid: post.uid, puid: puid, image: post.img!)
                .subscribe({ [unowned self] success in
                    switch success {
                    case .success(let url):
                        self.ref.child("post").child(puid).setValue(["puid": puid, "imgURL": url.absoluteString, "place": post.place, "promiseDate": post.promiseDate, "content": post.content,  "uid": post.uid, "position": post.position, "postDate": post.postDate, "promise": promiseDic, "foodCategory": post.foodCategory])
                        self.ref.child("user").child(post.uid).child("postPuids").updateChildValues([puid: "Default"])
                        single(.success(puid))
                    case .error(let error):
                        single(.error(error))
                    }
                })
                .disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
    // Post
    
    func fetchDistancePosts(curPos: String, category: String, lastDistance: Double, fetchingCnt: UInt) -> Observable<[Post]> {
        return Observable.create { [unowned self] emitter in
            var posts = [Post]()

            self.ref.child("post").observeSingleEvent(of: .value) { [unowned self] postUidSnashot in
                var positions = [String: String]()
                
                for postsSnapShot in postUidSnashot.children.allObjects as! [DataSnapshot] {
                    let value = postsSnapShot.value as? [String: Any]
                    let puid = postsSnapShot.key
                    
                    guard let position = value?["position"] as? String else { return }
                    positions.updateValue(position, forKey: puid)
                }
                
                var distances = [String: Double]()
                positions.forEach { distances.updateValue($0.value.posToDistance(curPos: curPos), forKey: $0.key) }
                let sortedDistances = distances.sorted(by: { $0.value < $1.value })

                var remainCnt = 0
                sortedDistances.forEach({ if $0.value > lastDistance { remainCnt += 1 } })
                sortedDistances.forEach { [unowned self] dis in
                    if dis.value > lastDistance {
                        self.fetchPost(puid: dis.key)
                            .subscribe(onNext :{ [unowned self] p in
                                posts.append(p)
                                if remainCnt >= fetchingCnt { // Normal : 한번 fetching할만큼 남아있을때
                                    if posts.count == fetchingCnt {
                                        if category != "전부" {
                                            posts = posts.filter { $0.foodCategory == category }
                                            emitter.onNext(posts)
                                        } else {
                                            emitter.onNext(posts)
                                        }
                                        return
                                    }
                                } else {
                                    if posts.count == remainCnt { // Exception: 조금 남았을때
                                        if category != "전부" {
                                            posts = posts.filter { $0.foodCategory == category }
                                            emitter.onNext(posts)
                                        } else {
                                            emitter.onNext(posts)
                                        }
                                        return
                                    }
                                }
                            })
                            .disposed(by: self.bag)
                    }
                }
                
                
            }
            
            return Disposables.create { emitter.onCompleted() }
        }
    }
    
    func fetchPostDatePosts(category: String, lastDate: String, fetchingCnt: UInt) -> Observable<[Post]> {
        return Observable.create { [unowned self] emitter in
            var posts = [Post]()

            let query = self.ref.child("post").queryOrdered(byChild: "postDate").queryEnding(beforeValue: lastDate).queryLimited(toLast: fetchingCnt)
            
            query.observeSingleEvent(of: .value) { [unowned self] postsUidSnapShot in
                
                if !postsUidSnapShot.exists() { emitter.onNext([]) }
                let dbPostCnt = postsUidSnapShot.childrenCount
                
                for postSnapShot in postsUidSnapShot.children.allObjects as! [DataSnapshot] {
                    let puid = postSnapShot.key
                    self.fetchPost(puid: puid)
                        .subscribe(onNext: { [unowned self] p in

                            posts.append(p)
                            if dbPostCnt >= fetchingCnt { // Normal : 한번 fetching할만큼 남아있을때
                                if posts.count == fetchingCnt {
                                    posts.sort { $0.postDate > $1.postDate }
                                    
                                    if category != "전부" {
                                        posts = posts.filter { $0.foodCategory == category }
                                        emitter.onNext(posts)
                                    } else {
                                        emitter.onNext(posts)
                                    }
                                    return
                                }
                            } else {
                                if posts.count == dbPostCnt { // Exception: 조금 남았을때
                                    posts.sort { $0.postDate > $1.postDate }
                                    if category != "전부" {
                                        posts = posts.filter { $0.foodCategory == category }
                                        emitter.onNext(posts)
                                    } else {
                                        emitter.onNext(posts)
                                    }
                                    return
                                }
                            }
                        })
                        .disposed(by: self.bag)
                }

            }
            return Disposables.create { emitter.onCompleted() }
        }
    }
    
    func fetchPromiseDatePosts(category: String, lastDate: String, fetchingCnt: UInt) -> Observable<[Post]> {
        return Observable.create { [unowned self] emitter in
            var posts = [Post]()

            let query = self.ref.child("post").queryOrdered(byChild: "promiseDate").queryStarting(afterValue: lastDate).queryLimited(toFirst: fetchingCnt)
            
            query.observeSingleEvent(of: .value) { [unowned self] postsUidSnapShot in

                let dbPostCnt = postsUidSnapShot.childrenCount
                for postSnapShot in postsUidSnapShot.children.allObjects as! [DataSnapshot] {
                    
                    let puid = postSnapShot.key
                    self.fetchPost(puid: puid)
                        .subscribe(onNext: { [unowned self] p in
                            posts.insert(p, at: 0)
                            if dbPostCnt >= fetchingCnt { // Normal : 한번 fetching할만큼 남아있을때
                                if posts.count == fetchingCnt {
                                    posts.sort { $0.promiseDate < $1.promiseDate }
                                    if category != "전부" {
                                        posts = posts.filter { $0.foodCategory == category }
                                        emitter.onNext(posts)
                                    } else {
                                        emitter.onNext(posts)
                                    }
                                    return
                                }
                            } else {
                                if posts.count == dbPostCnt { // Exception: 조금 남았을때
                                    posts.sort { $0.promiseDate < $1.promiseDate }
                                    
                                    if category != "전부" {
                                        posts = posts.filter { $0.foodCategory == category }
                                        emitter.onNext(posts)
                                    } else {
                                        emitter.onNext(posts)
                                    }
                                    return
                                }
                            }
                        })
                        .disposed(by: self.bag)
                }

            }
            return Disposables.create { emitter.onCompleted() }
        }
    }
    
    
    
    
    func fetchInMapPosts(bounds: NMGLatLngBounds) -> Single<[MapPost]> {
        return Single.create { [unowned self] single in
            var mapPosts = [MapPost]()

            self.ref.child("post").observeSingleEvent(of: .value) { [unowned self] postUidSnashot in
                
                for postsSnapShot in postUidSnashot.children.allObjects as! [DataSnapshot] {
                    let value = postsSnapShot.value as? [String: Any]
                    let puid = postsSnapShot.key
                    
                    guard let position = value?["position"] as? String else { return }
                    let latLngArr = position.components(separatedBy: "-").map { Double($0)! }
                    let latLng = NMGLatLng(lat: latLngArr[0], lng: latLngArr[1])
                    
                    mapPosts.append(MapPost(puid: puid, latLng: latLng))
                }
                
                mapPosts = mapPosts.filter { bounds.hasPoint($0.latLng) }
                single(.success(mapPosts))
            }
            return Disposables.create()
        }
    }
    
    
    
//    func fetchPosts() -> Observable<[Post]> {
//        return Observable.create { emitter in
//            var posts = [Post]()
//
//            self.ref.child("post").queryOrdered(byChild: "postDate").queryEnding(beforeValue: self.dbLastFetchPostDate).queryLimited(toLast: self.dbPostFetchCnt).observeSingleEvent(of: .value) { postUidSnapShot in
//                for postsSnapShot in postUidSnapShot.children.allObjects as! [DataSnapshot] {
//
//                    let dbPostCnt = postUidSnapShot.childrenCount
//                    let value = postsSnapShot.value as? [String: Any]
//                    let puid = postsSnapShot.key
//
//                    guard let uid = value?["uid"] as? String,
//                          let urlStr = value?["imgURL"] as? String,
//                          let place = value?["place"] as? String,
//                          let content = value?["content"] as? String,
//                          let date = value?["date"] as? String,
//                          let position = value?["position"] as? String,
//                          let postDate = value?["postDate"] as? String else {
//                        emitter.onNext(posts)
//                        return
//                    }
//
//                    var promise = Promise(hostUid: "Default", maxPeople: -1)
//
//                    if let promiseDic = value?["promise"] as? [String: Any],
//                       let hostUid = promiseDic["hostUid"] as? String,
//                       let maxPeople = promiseDic["maxPeople"] as? Int {
//
//                        if let uids = promiseDic["uids"] as? [String: String] {
//                            var peoples = [String: String]()
//                            uids.forEach { peoples.updateValue($0.value, forKey: $0.key) }
//                            promise.peoples = peoples
//                        }
//
//                        promise.hostUid = hostUid
//                        promise.maxPeople = maxPeople
//                    }
//
//                    let postSubject = PublishSubject<Post>()
//                    let userSubject = PublishSubject<User>()
//
//                    self.fetchUser(uid: uid)
//                        .subscribe(onNext: {
//                            userSubject.onNext($0)
//                        })
//                        .disposed(by: self.bag)
//
//                    Observable.combineLatest(postSubject, userSubject)  //User 여러번 들어와서 Zip But 수정 필요
//                        .subscribe(onNext: { post, user in
//                            post.user = user
//                            posts.insert(post, at: 0)
//                            if dbPostCnt >= self.dbPostFetchCnt { // Normal : 한번 fetching할만큼 남아있을때
//                                if posts.count == self.dbPostFetchCnt {
//                                    self.dbLastFetchPostDate = posts.last!.postDate
//                                    emitter.onNext(posts)
//                                    return
//                                }
//                            } else {
//                                if posts.count == dbPostCnt { // Exception: 조금 남았을때
//                                    self.dbLastFetchPostDate = posts.last!.postDate
//                                    emitter.onNext(posts)
//                                    return
//                                }
//                            }
//                        })
//                        .disposed(by: self.bag)
//
//                    let post = Post(puid: puid, imgURL: URL(string: urlStr)!, place: place, content: content, date: date, uid: uid, position: position, postDate: postDate, promise: promise)
//                    postSubject.onNext(post)
//                }
//            }
//            return Disposables.create { emitter.onCompleted() }
//        }
//    }
    
    func fetchPost(puid: String) -> Observable<Post> {
        return Observable.create { [unowned self] emitter in
               
            self.ref.child("post").child(puid).observeSingleEvent(of: .value) { [unowned self] postSnapshot in
                let value = postSnapshot.value as? [String: Any]
                let puid = postSnapshot.key
                
                guard let uid = value?["uid"] as? String,
                      let urlStr = value?["imgURL"] as? String,
                      let place = value?["place"] as? String,
                      let content = value?["content"] as? String,
                      let promiseDate = value?["promiseDate"] as? String,
                      let position = value?["position"] as? String,
                      let postDate = value?["postDate"] as? String,
                      let foodCategory = value?["foodCategory"] as? String
                else {
                    emitter.onCompleted()
                    return
                }
                
                var promise = Promise(hostUid: "Default", maxPeople: -1)

                if let promiseDic = value?["promise"] as? [String: Any],
                   let hostUid = promiseDic["hostUid"] as? String,
                   let maxPeople = promiseDic["maxPeople"] as? Int {
                    
                    if let uids = promiseDic["uids"] as? [String: String] {
                        var peoples = [String: String]()
                        uids.forEach { peoples.updateValue($0.value, forKey: $0.key) }
                        promise.peoples = peoples
                    }

                    promise.hostUid = hostUid
                    promise.maxPeople = maxPeople
                }

//                let postSubject = PublishSubject<Post>()
//                let userSubject = PublishSubject<User>()
                
//                self.fetchUser(uid: uid)
//                    .subscribe(onNext: { [unowned self] user in
//                        userSubject.onNext(user)
//                    })
//                    .disposed(by: self.bag)
                
//                Observable.combineLatest(postSubject, userSubject)  //User 여러번 들어와서 Zip But 수정 필요
//                    .subscribe(onNext: { [unowned self] (post, user) in
//                        post.user = user
//                        emitter.onNext(post)
//                    })
//                    .disposed(by: self.bag)
                
                let post = Post(puid: puid, img: nil, imgURL: URL(string: urlStr)!, place: place, content: content, date: promiseDate, uid: uid, position: position, postDate: postDate, promise: promise, foodCategory: foodCategory)
                emitter.onNext(post)
//                postSubject.onNext(post)
            }

            return Disposables.create { emitter.onCompleted() }
        }
    }
    
    
    
    
    func promiseAdd(pUid: String, uid: String, name: String) -> Observable<Bool> {
        return Observable.create { [unowned self] emitter in
            self.ref.child("post").child(pUid).child("promise").child("uids").updateChildValues([uid: name])
            

            self.ref.child("user").child(uid).child("promisePuids").updateChildValues([pUid: "default"])
            
            emitter.onNext(true)
            return Disposables.create { emitter.onCompleted() }
        }
    }
    
    func promiseRemove(pUid: String, uid: String, name: String) -> Observable<Bool> {
        return Observable.create { [unowned self] emitter in
            self.ref.child("post").child(pUid).child("promise").child("uids").child(uid).removeValue()
            self.ref.child("user").child(uid).child("promisePuids").child(pUid).removeValue()
            emitter.onNext(true)
            return Disposables.create { emitter.onCompleted() }
        }
    }

    func getToken() -> Single<String> {
        return Single.create { single in
            Messaging.messaging().token { token, error in
                guard token != nil, error == nil  else {
                    single(.error(error!))
                    return
                }
                single(.success(token!))
            }
            return Disposables.create()
        }
    }
    
    
    
}
