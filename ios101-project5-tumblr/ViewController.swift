//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TumblrCell", for: indexPath) as! TumblrCell
        let post = posts[indexPath.row]
        //cell.textLabel?.text = "Row \(indexPath.row)"
        
        if let photo = post.photos.first {
            let url = photo.originalSize.url
            // Load the photo in the image view via Nuke library...
            Nuke.loadImage(with: url, into: cell.posterImageView)
        }
        cell.feedLabel.text = post.summary
        
        return cell
    }
    

    @IBOutlet weak var tableView: UITableView!
  
    private var posts: [Post] = []
    private var refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        // Add refresh control to the table view
        tableView.addSubview(refreshControl)
        
        // Add target-action pair to call fetchPosts method when refresh control is triggered
        refreshControl.addTarget(self, action: #selector(fetchPosts), for: .valueChanged)
                
        fetchPosts()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        let selectedPost = posts[selectedIndexPath.row]
        guard let detailViewController = segue.destination as? DetailViewController else { return }
        detailViewController.post = selectedPost
    }


    @objc func fetchPosts() {
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        //url to fetch post from a different blog
        //let url = URL(string: "https://api.tumblr.com/v2/blog/techcrunch/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in

                    let posts = blog.response.posts


                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                    
                    self?.posts = posts
                    self?.tableView.reloadData()
                    
                    // End refreshing process
                    self?.refreshControl.endRefreshing()
                }
                

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
    
}
