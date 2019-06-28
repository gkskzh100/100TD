//
//  ViewController.swift
//  Diary
//
//  Created by 김지민 on 21/02/2019.
//  Copyright © 2019 to_kkeang. All rights reserved.
//

import UIKit



class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbLoad()
        
        self.navigationController?.navigationBar.isTranslucent=false
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3764705882, green: 0.3647058824, blue: 0.3647058824, alpha: 1)
        self.view.backgroundColor=Style.bgColor
        
        view.addSubview(calenderView)
        calenderView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive=true
        calenderView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive=true
        calenderView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive=true
        calenderView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive=true
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        calenderView.diaryView.addGestureRecognizer(singleTapGestureRecognizer)
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        calenderView.myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.calenderView.myCollectionView.reloadData()
    }
    
    /* 다이어리 터치 반응 메소드 */
    @objc func MyTapMethod(sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "DiaryView", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "DiaryViewID") as! DiaryController
        
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        nextViewController.selectDay = calenderView.touchDay
        nextViewController.selectMonth = calenderView.currentMonthIndex
        nextViewController.selectYear = calenderView.currentYear
    print(":",nextViewController.selectYear,".",nextViewController.selectMonth,".",nextViewController.selectDay)
        
    }

    
    let calenderView: CalenderView = {
        let v = CalenderView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    /* 파일여부 체크 */
    func dbLoad() {
        let filemgr = FileManager.default
        let dirpaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dbPath = dirpaths.appendingPathComponent("diaryDb.db").path
        
        if !filemgr.fileExists(atPath: dbPath) {
            print("db없음")
            if filemgr.createFile(atPath: dbPath, contents: nil, attributes: nil) {
                print("생성완료")
                let fmdb = FMDatabase(path: dbPath as String)
                
                if fmdb.open() {
                    let sql_stmt = "create table if not exists diary (date text primary key, color text, content text)"
                    if !fmdb.executeStatements(sql_stmt) {
                        print("error")
                    }
                    fmdb.close()
                }
            }
        } else {
            print("db있음")
        }
    }
}

