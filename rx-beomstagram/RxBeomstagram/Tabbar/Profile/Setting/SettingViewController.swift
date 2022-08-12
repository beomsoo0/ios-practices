//
//  SettingViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/24.
//
import UIKit
import SafariServices

//View
class SettingViewController: UIViewController {

    private var data = [[SettingCellModel]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        configureModels()
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        cell.textLabel?.text = data[indexPath.section][indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        data[indexPath.section][indexPath.row].handler()
    }
    
}

//View Model
extension SettingViewController {
    
    private func configureModels() {
        data.append(
            [SettingCellModel(title: "프로필 편집") { [weak self] in
            self?.didTabProfileEdit()
        },
            SettingCellModel(title: "친구 초대") { [weak self] in
            self?.didTabFriendInvite()
        },
            SettingCellModel(title: "게시물 보관") { [weak self] in
            self?.didTabSavedContents()
        }]
        )
        data.append(
            [SettingCellModel(title: "네이버") { [weak self] in
                self?.openURL(type: .naver)
        },
            SettingCellModel(title: "구글") { [weak self] in
            self?.openURL(type: .google)
        },
            SettingCellModel(title: "다음") { [weak self] in
            self?.openURL(type: .daum)
        }]
        )
        data.append(
            [SettingCellModel(title: "로그아웃") { [weak self] in
            self?.didTabLogOut()
        }]
        )
    }
    
    enum SettingURLType {
        case naver, google, daum
    }
    
    private func didTabProfileEdit() {
    }
    private func didTabFriendInvite() {
    }
    private func didTabSavedContents() {
    }
    
    private func openURL(type: SettingURLType) {
        let urlString: String
        
        switch type {
        case .naver: urlString = "https://www.naver.com/"
            
        case .google: urlString = "https://www.google.com/"
            
        case .daum: urlString = "https://www.daum.net/"
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }

    private func didTabLogOut() {
        AuthManager.shared.logOutUser { success in
            DispatchQueue.main.async {
                if success {
                    let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginVC")
                    loginVC?.modalPresentationStyle = .fullScreen
                    self.present(loginVC!, animated: true) {
                        self.navigationController?.popToRootViewController(animated: false)
                        self.tabBarController?.selectedIndex = 0
                    }
                }
                else {
                    let alert = UIAlertController(title: "로그아웃 오류", message: "로그아웃 할 수 없습니다", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
    }
}

struct SettingCellModel {
    let title: String
    let handler: () -> Void
}
