//
//  HomeViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import UIKit
import RxSwift
import Kingfisher

class HomeViewController: UIViewController, ViewModelBindType {
    
    // IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    
    // Property
    let bag = DisposeBag()
    var viewModel: HomeViewModel!
    
    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = UIRefreshControl()
        tableView.rx.setDelegate(self).disposed(by: bag)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // Binding
    func bindViewModel() {
        // fetching
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        
        let reLoad = tableView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .map { _ in () } ?? Observable.just(())
        
        Observable.merge([firstLoad, reLoad])
            .bind(to: viewModel.fetching)
            .disposed(by: bag)
        
        // Refetching
        tableView.rx.contentOffset
            .map { [unowned self] in self.isNearTheBottomEdge($0, self.tableView) }
            .distinctUntilChanged()
            .filter { $0 == true }
            .map { _ in () }
            .bind(to: viewModel.reFetching)
            .disposed(by: bag)

        // TableView
        viewModel.postsSubject
            .bind(to: tableView.rx.items(cellIdentifier: "HomeTableViewCell", cellType: HomeTableViewCell.self)) { [unowned self] (idx, post, cell) in
                // Post
                if let imgURL = post.imgURL {
                    cell.postImgView.kf.setImage(with: imgURL, placeholder: nil, options: [.transition(.fade(0.7))])
                } else if let img = post.img {
                    cell.postImgView.image = img
                }
                cell.postTitleLabel.text = post.place
                cell.postCategoryLabel.text = "종류 : \(post.foodCategory)"
                cell.postPromiseDateLabel.text = "날짜 : \(post.promiseDate_relative)"
                
                cell.postStatusLabel.text = "\(post.promise.curNum) / \(post.promise.maxPeople)"
                if post.promise.curNum == post.promise.maxPeople {
                    cell.postStatusLabel.textColor = .systemGray
                } else{
                    cell.postStatusLabel.textColor = .systemOrange
                }
                
                var dis = 0.0 // ditance 수정 필요
                self.viewModel.curUserSubject
                    .subscribe(onNext: { [unowned self] in
                        dis = post.calDistance(curUserPos: $0.curPosition ?? "0-0")
                    })
                    .disposed(by: bag)
                cell.postDistanceLabel.text = "거리 : \(String(format: "%.2fkm", dis))"

                // UI
                cell.postImgView.layer.cornerRadius = 8

            }
            .disposed(by: bag)
        
        // Scroll
        viewModel.scrolling
            .filter { [unowned self] _ in self.tableView.contentSize.height != 0 }
            .subscribe(onNext: { [unowned self] idx in
                self.tableView.scrollToRow(at: IndexPath(row: idx, section: 0), at: .bottom, animated: true)
            })
            .disposed(by: bag)
        
        // Activating
        viewModel.activating
            .distinctUntilChanged()
            .map { !$0 }
            .subscribe(onNext: { [unowned self] finished in
                if finished {
                    self.tableView.refreshControl?.endRefreshing()
                }
            })
            .disposed(by: bag)
        
        // Pushing
        tableView.rx.itemSelected
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .withLatestFrom(Observable.combineLatest(tableView.rx.itemSelected, viewModel.postsSubject))
            .subscribe(onNext: { [unowned self] (indexPath, posts) in
                self.viewModel.pushPostVC(post: posts[indexPath.row], homeVM: self.viewModel).execute()
            })
            .disposed(by: bag)

        addBtn.rx.action = viewModel.pushAddPostVC(homeVM: viewModel)
        menuBtn.rx.action = viewModel.pushSortVC(homeVM: viewModel)
    }

    // Table View Bottom Edge Detection
    func isNearTheBottomEdge(_ contentOffset: CGPoint, _ tableView: UITableView) -> Bool {
        if tableView.contentSize.height == 0 { return false }
        return contentOffset.y + tableView.frame.size.height > tableView.contentSize.height
    }

    deinit {
        print("@@@@@@ HomeViewController Deinit @@@@@@")
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return CGFloat(120.0)
    }

}

// TableViewCell
class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var postImgView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDistanceLabel: UILabel!
    @IBOutlet weak var postPromiseDateLabel: UILabel!
    @IBOutlet weak var postStatusLabel: UILabel!
    @IBOutlet weak var postCategoryLabel: UILabel!
    
}


