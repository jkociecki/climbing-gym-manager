import SwiftUI
import Supabase
import Storage

class StorageManager {
    static let shared = StorageManager()
    
    private let api_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhhd2ZzbGNueGplcmZsbHBicmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQyMTAzNjcsImV4cCI6MjA0OTc4NjM2N30.hAAMQQ9YeNCwopa3UzUCaJ8NlHrxNfS2zJTnrljIp3k"
    
    private let secret = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhhd2ZzbGNueGplcmZsbHBicmlxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNDIxMDM2NywiZXhwIjoyMDQ5Nzg2MzY3fQ.d-D_XtvsFMyslLw99s-TJLoPmAvLWUXCR0wThGsNFsg"
    
    private lazy var storage: SupabaseStorageClient = {
        let configuration = StorageClientConfiguration(
            url: URL(string: "https://hawfslcnxjerfllpbriq.supabase.co/storage/v1")!,
            headers: [
                "Authorization": "Bearer \(secret)",
                "api_key": api_key
            ]
        )
        return SupabaseStorageClient(configuration: configuration)
    }()
    
    private init() {}
    
    func uploadFileForCurrentUser(photoData: Data) async throws {
        let fileName = "profile_photo.jpg"
        if let current_user_uid = AuthManager.shared.client.auth.currentSession?.user.id{
        let path = "\(current_user_uid)/\(fileName)"
            
            try await storage
                .from("profilePictures")
                .upload(path,
                        data: photoData,
                        options: FileOptions(
                            cacheControl: "3600",
                            contentType: "image/jpg",
                            upsert: true
                        ))
        }

    }
    
    func fetchUserProfilePicture(user_uid: String) async throws -> Data?{
        let path = "\(user_uid)/profile_photo.jpg"
        do{
            let response = try await storage.from("profilePictures")
                                        .download(path: path)
            return response
        }catch{
            print("Profile photo not found for user \(user_uid). Returning default photo.")
            return nil
        }
    }
}
