//
//  SideMenuNavigationViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/11.
//

import UIKit
import SideMenu
class SideMenuNavigationViewController: SideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //메뉴 나오는 스타일
        self.presentationStyle = .menuSlideIn
        
        //가로 크기 50퍼
        self.menuWidth = self.view.frame.width * 0.5
        
        //메뉴 왼쪽에서 나오기
        self.leftSide = false
        
        //상단 상태바 보이도록 설정 0 ( 0~1 default 1 )
        self.statusBarEndAlpha = 0.0
        
        
        //보여지는 속도
        self.presentDuration = 1.0
        //사라지는 속도
        self.dismissDuration = 1.0
        
    }


}
