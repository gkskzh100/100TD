//
//  DiaryView.swift
//  Diary
//
//  Created by 김지민 on 01/03/2019.
//  Copyright © 2019 to_kkeang. All rights reserved.
//

import UIKit

class DiaryView: UIView {


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear

        setUpView()
    }

    func setUpView() {
        addSubview(myScrollView)
        myScrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        myScrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        myScrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        myScrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        addSubview(lblDiary)
        lblDiary.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        lblDiary.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true


    }

    let myScrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.layer.borderColor = #colorLiteral(red: 0.96034747, green: 0.7378694275, blue: 0.7793999148, alpha: 1)
        scrollView.layer.cornerRadius = 8
        scrollView.layer.borderWidth = 1
        return scrollView
    }()

    let lblDiary : UILabel = {
        let lbl = UILabel()
        lbl.textColor = Style.diaryContentLblColor
        lbl.textAlignment = .left
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.numberOfLines = 0   // 출력가능한 라인 수 제한없음
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
