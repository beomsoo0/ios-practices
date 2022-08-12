import UIKit


// Queue - Main, Global, Custom

// Main
DispatchQueue.main.async {
    //UIupdate
    let view = UIView()
    view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
}
// Global
DispatchQueue.global(qos: .userInteractive).async {
   // 핵중요 1순위
    
}
DispatchQueue.global(qos: .userInitiated).async {
    // 거의 바로 2순위
    
}
DispatchQueue.global(qos: .default).async {
    // 이건 굳이? 3순위
    
}
DispatchQueue.global(qos: .utility).async {
    // 시간 좀 걸리는? 사용자가 좀 기다리는 네트워킹, 큰파일... 4순위
    
}
DispatchQueue.global(qos: .background).async {
    // 당장 인식 필요 없는 것들 영상 다운, 위치 업데이트... 5순위
    
}
// Custom
let concurrentQueue = DispatchQueue(label: "concurrent", qos: .background, attributes: .concurrent)
let serialQueue = DispatchQueue(label: "serialQueue", qos: .background)

// 복합적인 상황

func downloadImageFromServer() -> UIImage
{
    return UIImage()
}
func updateUI(image: UIImage)
{
    
}

DispatchQueue.global(qos: .background).async {
    // download
    let image = downloadImageFromServer()
    
    DispatchQueue.main.async {
        // update ui
        updateUI(image: image)
    }
}

// Sync, Async

DispatchQueue.global(qos: .background).sync {
    for i in 0...5
    {
        print("😈  \(i)")
    }
}
DispatchQueue.global(qos: .userInteractive).async {
    for i in 0...5
    {
        print("😜  \(i)")
    }
}
