//
//  StorageManager.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import FirebaseStorage

public class StorageManager {
    
    static let shared = StorageManager()
    
    let ref = Storage.storage().reference()
    
    public enum StorageManagerError: Error {
        case urlUploadError
        case urlDownloadError
    }
    
    public func uploadImageToStorage(cuid: String, image: UIImage, completion: @escaping (Result<URL, StorageManagerError>) -> Void) {
        let dataImage = image.jpegData(compressionQuality: 0.1)!
        guard let uid = AuthManager.shared.currentUid() else { return }
        let imageRef = ref.child("posts").child(uid).child(cuid)
    
        // Upload Storage
        imageRef.putData(dataImage, metadata: nil) { (StorageMetadata, error) in
            guard error == nil else {
                completion(.failure(.urlUploadError))
                return
            }
            imageRef.downloadURL { (url, error) in
                guard let url = url, error == nil else {
                    completion(.failure(.urlDownloadError))
                    return
                }
                completion(.success(url))
                return
            }
        }
    }
    

}
