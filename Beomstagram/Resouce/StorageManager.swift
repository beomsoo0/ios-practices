//
//  StorageManager.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/04.
//

import FirebaseStorage

public class StorageManager {
    
    static let shared = StorageManager()
    
    let ref = Storage.storage().reference()
    
    public enum StorageManagerError: Error {
        case urlUploadError
        case urlDownloadError
    }
    
    public func uploadImageToStorage(cuid: String, uid: String, image: UIImage, completion: @escaping (Result<URL, StorageManagerError>) -> Void) {
        
        let dataImage = image.jpegData(compressionQuality: 0.1)!
        let imageRef = ref.child(uid).child("contents").child(cuid)
        
        // Upload Storage
        imageRef.putData(dataImage, metadata: nil) { (StorageMetadata, error) in
            if error != nil {
                completion(.failure(.urlUploadError))
                return
            }
            imageRef.downloadURL { (url, error) in
                guard let url = url, error != nil else {
                    completion(.failure(.urlDownloadError))
                    return
                }
                completion(.success(url))
                return
            }
        }
    }
    
//    public func downloadImage(url: String, completion: @escaping (Result<URL, StorageManagerError> -> Void)) {
//        guard let url = url, error == nil else {
//            completion(.failure(<#T##Error#>))
//            return
//        }
//        completion(.success(url))
//        return
//    }
    
}
