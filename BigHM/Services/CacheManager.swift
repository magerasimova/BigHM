//
//  CacheManager.swift
//  BigHM
//
//  Created by Майя Герасимова on 05.01.2021.
//

import UIKit

class CacheManager {
    private init() {}
    
    static let shared = CacheManager()
    
    private let imagesLimit = 40
    private let fileManager = FileManager.default
    
    
    //MARK:- Cache Image
    ///Completion is executed on background thread
    func cacheImage(_ image: UIImage?, with id: Int, completion: ((Bool) -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async { [self] in
            guard let image = image,
                  let data = image.pngData()
            else {
                completion?(false)
                return
            }
            
            let imageUrl = getCachesDirectory().appendingPathComponent("\(id)")
            
            guard !fileManager.fileExists(atPath: imageUrl.path) else {
                completion?(true)
                return
            }
            
            var savedPaths = getCachedImagePaths()
            while savedPaths.count >= imagesLimit {
                _ = tryDeleteImage(path: savedPaths.first!)
                savedPaths.remove(at: savedPaths.startIndex)
            }
                    
            do {
                try data.write(to: imageUrl)
                print(imageUrl)
                completion?(true)
            }
            catch {
                print(error)
                completion?(false)
            }
        }
    }
    
    //MARK:- Get Image
    func getImage(with id: Int, completion: @escaping (UIImage?) -> Void) {
        let imageUrl = getCachesDirectory().appendingPathComponent("\(id)")
        DispatchQueue.global(qos: .userInteractive).async {
            let image = self.getImage(from: imageUrl.path)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func getImage(from path: String) -> UIImage? {
       // print(path)
        if let data = fileManager.contents(atPath: path),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
    
    func getCachedImages(completion: @escaping ([UIImage], [String]) -> Void) {
        DispatchQueue.global().async { [self] in
            var images = [UIImage]()
            let imagePaths = getCachedImagePaths()
            var id = [String]()
            for path in imagePaths {
                if let image = getImage(from: path) {
                    images.append(image)
                    let sPath = String(path)
                    id.append(sPath.components(separatedBy: "/").last ?? "0")
                    print(sPath.components(separatedBy: "/").last ?? "0")
                }
            }
            DispatchQueue.main.async {
                completion(images, id)
            }
        }
        
    }
    
    //MARK:- Delete Image
    func tryDeleteImage(id: Int) -> Bool {
        let imageUrl = getCachesDirectory().appendingPathComponent("\(id)")
        return tryDeleteImage(path: imageUrl.path)
    }
    
    func tryDeleteImage(path: String) -> Bool {
        do {
            try fileManager.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
    //MARK:- Private
    private func getCachedImagePaths() -> [String] {
        do {
            let paths = try fileManager.contentsOfDirectory(atPath: getCachesDirectory().path)
            return paths.map { getCachesDirectory().appendingPathComponent($0).path }
        }
        catch {
            return []
        }
    }
    
    private func getCachesDirectory() -> URL {
        let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("CachedImages")
        
        if !fileManager.fileExists(atPath: url.path) {
            try! fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        return url
    }
        
}
