//
//  DiaryController.swift
//  Diary
//
//  Created by 김지민 on 09/03/2019.
//  Copyright © 2019 to_kkeang. All rights reserved.
//

import UIKit


class DiaryController: UIViewController,UITextViewDelegate {
    
    var selectDay: Int = 0
    var selectMonth: Int = 0
    var selectYear: Int = 0
    
    let filemgr = FileManager.default
    
    @IBOutlet weak var diaryDateLbl: UILabel!
    @IBOutlet weak var diaryTxt: UITextView!
    
    //되는건가요?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Colors.darkGray
        diaryDateLbl.textColor = UIColor.white
        
        
        if(selectDay == 0) {
            selectDay = Calendar.current.component(.day, from: Date())
        }
        
        if (selectMonth/10) == 0 && (selectDay/10) == 0 {
            diaryDateLbl.text = "\(selectYear). 0\(selectMonth). 0\(selectDay)"
        } else if (selectMonth/10) == 0 && (selectDay/10) != 0 {
            diaryDateLbl.text = "\(selectYear). 0\(selectMonth). \(selectDay)"
        } else if (selectMonth/10) != 0 && (selectDay/10) == 0 {
            diaryDateLbl.text = "\(selectYear). \(selectMonth). 0\(selectDay)"
        } else if (selectMonth/10) != 0 && (selectDay/10) != 0 {
            diaryDateLbl.text = "\(selectYear). \(selectMonth). \(selectDay)"
        }
        
        let colorBtnView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        colorBtnView.backgroundColor = UIColor.white
        colorBtnView.layer.cornerRadius = 5
        let colorBtn = UIButton(frame: CGRect(x: -15, y: 0, width: 30, height: 20))
        colorBtn.addTarget(self, action: #selector(rightBarColorBtnAction), for: .touchUpInside)
        colorBtnView.addSubview(colorBtn)
        
        let rightBarColorBtn = UIBarButtonItem(customView: colorBtnView)
        let rightBarSaveBtn = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(rightBarBtnAction))
        
        self.navigationItem.rightBarButtonItems = [rightBarColorBtn, rightBarSaveBtn]
        self.navigationItem.rightBarButtonItem = rightBarSaveBtn
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.diaryTxt.layer.borderWidth = 1.0
        self.diaryTxt.layer.borderColor = #colorLiteral(red: 0.96034747, green: 0.7378694275, blue: 0.7793999148, alpha: 1)
        self.diaryTxt.layer.cornerRadius = 10
        
        diaryTxt.delegate = self
        
        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dbPath = dirPaths.appendingPathComponent("diaryDb.db").path
        let fmdb = FMDatabase(path: dbPath as String)
        var currentDate : String!
        
        if (selectMonth/10) == 0 && (selectDay/10) == 0 {
            currentDate = "\(selectYear)0\(selectMonth)0\(selectDay)"
        } else if (selectMonth/10) == 0 && (selectDay/10) != 0 {
            currentDate = "\(selectYear)0\(selectMonth)\(selectDay)"
        } else if (selectMonth/10) != 0 && (selectDay/10) == 0 {
            currentDate = "\(selectYear)\(selectMonth)\(selectDay)"
        } else if (selectMonth/10) != 0 && (selectDay/10) != 0 {
            currentDate = "\(selectYear)\(selectMonth)\(selectDay)"
        }
        
        if fmdb.open() {
            let sql = "SELECT content FROM diary WHERE date = '\(Int(currentDate!)!)'"
            let result: FMResultSet? = fmdb.executeQuery(sql, withArgumentsIn: [])
            
            if result?.next() == true {
                diaryTxt.text = result?.string(forColumn: "content")
            } else {
                textViewDidEndEditing(diaryTxt)
            }
            result?.close()
            fmdb.close()
        } else {
            print("error")
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text.isEmpty) {
            textView.text = "내용을 입력해주세요."
            textView.textColor = UIColor.lightGray
        }
        textView.resignFirstResponder() //키보드숨기기
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.textColor == UIColor.lightGray) {
            textView.text = nil
            textView.textColor = UIColor.white
        }
        textView.becomeFirstResponder() //텍스트필드에 포커스
    }
    @objc func rightBarColorBtnAction(sender: UIBarButtonItem) {
        
    }
    
    /* Save Btn */
    @objc func rightBarBtnAction(sender:UIBarButtonItem) {
        let filemgr = FileManager.default
        let dirpaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dbPath = dirpaths.appendingPathComponent("diaryDb.db").path
        
        let fmdb = FMDatabase(path: dbPath as String)
        
        if fmdb.open() {
            
            var saveDate : String!
            if (selectMonth/10) == 0 && (selectDay/10) == 0 {
                saveDate = "\(selectYear)0\(selectMonth)0\(selectDay)"
            } else if (selectMonth/10) == 0 && (selectDay/10) != 0 {
                saveDate = "\(selectYear)0\(selectMonth)\(selectDay)"
            } else if (selectMonth/10) != 0 && (selectDay/10) == 0 {
                saveDate = "\(selectYear)\(selectMonth)0\(selectDay)"
            } else if (selectMonth/10) != 0 && (selectDay/10) != 0 {
                saveDate = "\(selectYear)\(selectMonth)\(selectDay)"
            }
            
            let selectSQL = "SELECT * FROM diary WHERE date = '\(Int(saveDate!)!)'"
            let resultSelect: FMResultSet? = fmdb.executeQuery(selectSQL, withArgumentsIn: [])
            
            if resultSelect?.next() == true {
                print("있으니까 updqte")
                let updateSQL = "UPDATE diary SET content='\(diaryTxt.text!)' WHERE date = '\(Int(saveDate!)!)'"
                let resultUpdate = fmdb.executeUpdate(updateSQL, withArgumentsIn: [])
                
                if resultUpdate {
                    print("update success")
                } else {
                    print("upate error")
                }
            } else {
                print("없으니까 insert")
                let insertSQL = "INSERT INTO diary (date, color, content) VALUES ('\(saveDate!)','white','\(diaryTxt.text!)')"
                let resultInsert = fmdb.executeUpdate(insertSQL, withArgumentsIn: [])
                if resultInsert {
                    print("insert success")
                } else {
                    print("insert error")
                }

            }
            fmdb.close()
            
            navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
