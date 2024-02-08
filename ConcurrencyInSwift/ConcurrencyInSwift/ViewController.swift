//
//  ViewController.swift
//  ConcurrencyInSwift
//
//  Created by Monica Deshwal on 07/02/24.
//

import UIKit
import Foundation


class ViewController: UIViewController {
    
    let url1 = "https://source.unsplash.com/random/300x200"
    let url2 = "https://picsum.photos/id/10/2500/1667"
    
    private var name: String = "Name 1"
    private lazy var lazyName: String = "The lazy name 1"
    let semaphore = DispatchSemaphore(value: 5)
    
    private let lockQueue = DispatchQueue(label: "name.lock.queue")
    private var number = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //serialDispatchQueue()
        // concurrentDispatchQueue()
        // concurrentGlobalQueue()
        // synchronousDownloading()
        //   asynchronousDownloading()
        //        dataRaceSample1()
        //        dataRaceSample2()
        // dispatchGroup()
        //semaphoreImplementation()
        // dispatchWorkItem()
        //dispatchWorkItemExample2()
        //barrierImplementation()
        //lockImplemetation()
        // lockImplementationExample2()
        // operationQueueImplementation()
        Task {
            await mainActorImplementation()
        }
    }
    
    func serialDispatchQueue() {
        
        let serialQueue = DispatchQueue(label: "serial.queue")
        serialQueue.async {
            print("Task 1 started")
            //Do some work
            print("Task 1 finished")
        }
        
        serialQueue.async {
            print("Task 2 started")
            //Do some work
            print("Task 2 finished")
        }
    }
    
    func concurrentDispatchQueue() {
        let concurrentQueue = DispatchQueue(label: "concurrent.queue", attributes: .concurrent)
        concurrentQueue.async {
            print("Task1 started")
            sleep(2)
            //Do some work
            print("Task 1 finished")
        }
        concurrentQueue.async {
            print("Task2 started")
            // Do some work
            print("Task2 finished")
        }
    }
    
    func concurrentGlobalQueue() {
        
        let globalQueue = DispatchQueue.global(qos: .userInitiated)
        globalQueue.async {
            print("Task1 completed")
        }
        globalQueue.async {
            sleep(1)
            print("Task2 completed")
        }
        globalQueue.async {
            print("Task3 completed")
        }
    }
    
    func synchronousDownloading(){
        
        if let url = URL(string: url2)
        {
            do {
                let data = try? Data(contentsOf: url)
                let image = UIImage(data: data!)
                print("the downloaded image is \(image)")
            } catch let error {
                print("the value of error os \(error)")
            }
        }
    }
    
    func asynchronousDownloading() {
        if let url = URL(string: url2)
        {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if let data = data, let image = UIImage(data: data) {
                    print("the downloaded image is \(image)")
                } else {
                    // Handle error response
                }
            }
            task.resume()
        }
    }
    
    func dataRaceSample1() {
        DispatchQueue.global().async {
            self.name.append("added the name 2")
        }
        print(name) // Swift access race in data race
    }
    
    func dataRaceSample2() {
        DispatchQueue.global().async {
            print(self.lazyName) // Data race
        }
        print(self.lazyName)
    }
    
    func dispatchGroup() {
        
        let downloaderGroup = DispatchGroup()
        downloaderGroup.enter()
        if let url = URL(string: url2)
        {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if let data = data, let image = UIImage(data: data) {
                    print("the downloaded image is \(image)")
                    downloaderGroup.leave()
                } else {
                    downloaderGroup.leave()
                    // Handle error response
                }
            }
            task.resume()
        }
        
        downloaderGroup.enter()
        if let url = URL(string: url2)
        {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if let data = data, let image = UIImage(data: data) {
                    print("the downloaded image is \(image)")
                    downloaderGroup.leave()
                } else {
                    downloaderGroup.leave()
                    // Handle error response
                }
            }
            task.resume()
        }
        
        downloaderGroup.notify(queue: DispatchQueue.main) {
            // perform further action here
            print("All tasks completed")
        }
    }
    
    func semaphoreImplementation() {
        for i in 1...10 {
            print("check for the concurrent thread")
            sendRequest()
        }
    }
    
    func sendRequest() {
        
        semaphore.wait()
        //perform network request here
        semaphore.signal()
    }
    
    func dispatchWorkItem() {
        incrementNumber()
    }
    
    func incrementNumber() {
        var number: Int = 5
        
        let workItem = DispatchWorkItem {
            number += 5
        }
        
        workItem.notify(queue: .main) {
            print("After dispatching the item, the number is \(number)")
        }
        
        let queue = DispatchQueue.global(qos: .utility)
        queue.async(execute: workItem)
    }
    
    func dispatchWorkItemExample2() {
        // Create high-priority and low-priority queues
        let highPriorityQueue = DispatchQueue.global(qos: .userInteractive)
        let lowPriorityQueue = DispatchQueue.global(qos: .utility)
        
        // Create high-priority work item
        let highPriorityWorkItem = DispatchWorkItem(qos: .userInteractive) {
            Thread.sleep(forTimeInterval: 5)
            print("High priority task completed")
        }
        
        // Create low-priority work item
        let lowPriorityWorkItem = DispatchWorkItem(qos: .utility) {
            Thread.sleep(forTimeInterval: 5)
            print("Low priority task completed")
        }
        
        // Execute the work items asynchronously on their respective queues
        highPriorityQueue.async(execute: highPriorityWorkItem)
        highPriorityQueue.async(execute: lowPriorityWorkItem)
        lowPriorityQueue.async(execute: highPriorityWorkItem)
        lowPriorityQueue.async(execute: lowPriorityWorkItem)
    }
    
    func barrierImplementation() {
        let messenger = Messenger()
        // Executed on thread 1
        messenger.postMessages("Hello iOS")
        // Executed on thread 2
        messenger.postMessages("Hello iOS")
        // Executed on thread 3
        print(messenger.lastMessage)
    }
    
    func lockImplemetation() {
        self.lockImplemetationSerialQueue(1)
        self.lockImplemetationSerialQueue(2)
        self.lockImplemetationSerialQueue(3)
    }
    
    func lockImplemetationSerialQueue(_ num: Int) {
        lockQueue.async { [self] in
            Thread.sleep(forTimeInterval: 2)
            number = num
            print("number set value:", number)
        }
        
        lockQueue.async { [self] in
            let value = number
            DispatchQueue.global(qos: .background).async {
                print("number is", value)
            }
        }
    }
    
    func lockImplementationExample2() {
        let sharedResource = SharedResources()
        DispatchQueue.global().async {
            sharedResource.updateResource(with: 5)
        }
        
        DispatchQueue.global().async {
            let value = sharedResource.readResource()
            print("Value read from resource", value)
        }
        
        Thread.sleep(forTimeInterval: 2)
    }
    
    func operationQueueImplementation() {
        // Create an operation queue
        let operationQueue = OperationQueue()
        // set the maximum number of concurrent operation
        operationQueue.maxConcurrentOperationCount = 3
        // create and add operation to the queue
        for i in 1...5 {
            let operation = MyOperation(number: i)
            operationQueue.addOperation(operation)
        }
        //Wait for all operation to finish
        operationQueue.waitUntilAllOperationsAreFinished()
        print("All operation have finished")
    }
    
    func actorImplementation() async {
        let feeder = ChickenFeeder()
        await feeder.chickenStartsEating()
        
        //immutable property
        print(feeder.food)
        feeder.printWhatChickenAreEating()
    }
    
    func mainActorImplementation() async {
        self.fetchImage(for: URL(string: url1)!) { result in
            switch result {
            case .success(let image):
                print("Closure value of image\(image)")
            case .failure(let error):
                print("error value of image\(error)")
            }
        }
        do {
            let image = try await self.fetchImageWithActors(url: URL(string: url1)!)
            print("Closure value of image for actors\(image)")
        }catch let error {
            print("the value of error is \(error)")
        }
    }
    func fetchImage(for url: URL, completion: @escaping (Result<UIImage, ImageFetchingError>) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data
                    , let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(.failure(.imageDecodingFailed))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }.resume()
    }
    
    @MainActor
    func fetchImageWithActors(url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageFetchingError.imageDecodingFailed
        }
        return image
    }
}


enum ImageFetchingError: Error {
    case imageDecodingFailed
}

actor ChickenFeeder {
    let food = "worms"
    var numberOfEatingChickens: Int = 0
    func chickenStartsEating() {
        numberOfEatingChickens += 1
    }
    func chickensStopEating() {
        numberOfEatingChickens -= 1
    }
}
extension ChickenFeeder {
    nonisolated func printWhatChickenAreEating() {
        print("Chicken are eating \(food)")
    }
}
class MyOperation: Operation {
    let number: Int
    init(number: Int) {
        self.number = number
    }
    override func main() {
        print("Operation \(number) is executing")
        // simulate some work
        Thread.sleep(forTimeInterval: TimeInterval.random(in: 0.0...1))
        print("Operation \(number) finished")
    }
}
class SharedResources {
    private var resource: Int = 0
    private var lock = NSLock()
    
    func updateResource(with value: Int) {
        lock.lock()
        defer { lock.unlock()}
        print("Updating resource with value:", value)
        resource += value
    }
    
    func readResource() -> Int {
        lock.lock()
        defer { lock.unlock()}
        print("Readoing resource with value:", resource)
        return resource
    }
}

final class Messenger {
    private var messages: [String] = []
    
    private var queue = DispatchQueue(label: "message.queue", attributes: .concurrent)
    
    var lastMessage: String? {
        return queue.sync {
            messages.last
        }
    }
    func postMessages(_ newMessage: String) {
        queue.sync(flags: .barrier) {
            print("Entered in the block of brrier")
            sleep(10)
            messages.append(newMessage)
        }
    }
}

actor BankAccountActor {
    
    enum BankError: Error {
        case insufficientFunds
    }
    
    var balance: Double
    
    init(initialDeposit: Double) {
        self.balance = initialDeposit
    }
    
    func transfer(amount: Double, to toAccount: isolated BankAccountActor) async throws {
        
        guard await balance >= amount else {
            throw BankError.insufficientFunds
        }
        self.balance -= amount
        toAccount.deposit(amount: amount)
    }
    
    func deposit(amount: Double) {
        balance = balance + amount
    }
}
