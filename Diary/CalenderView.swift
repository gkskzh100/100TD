//
//  CalenderView.swift
//  Diary
//
//  Created by 김지민 on 21/02/2019.
//  Copyright © 2019 to_kkeang. All rights reserved.
//

import UIKit

struct Colors {
    static var darkGray = #colorLiteral(red: 0.3764705882, green: 0.3647058824, blue: 0.3647058824, alpha: 1)
    static var lightPink = #colorLiteral(red: 0.9615657926, green: 0.7394291759, blue: 0.7790157199, alpha: 1)
}

struct Style {
    static var bgColor = UIColor.white
    static var monthViewLblColor = UIColor.white
    static var monthViewBtnRightColor = UIColor.white
    static var monthViewBtnLeftColor = UIColor.white
    static var activeCellLblColor = UIColor.white
    static var activeCellLblColorHighlighted = UIColor.black
    static var weekdaysLblColor = UIColor.white
    static var diaryContentLblColor = UIColor.white
    
    static func themeDark(){
        bgColor = Colors.darkGray
        monthViewLblColor = UIColor.white
        monthViewBtnRightColor = UIColor.white
        monthViewBtnLeftColor = UIColor.white
        activeCellLblColor = UIColor.white
        activeCellLblColorHighlighted = UIColor.black
        weekdaysLblColor = UIColor.white
    }
}

class CalenderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MonthViewDelegate {
    
    var numOfDaysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
    var currentMonthIndex: Int = 0
    var currentYear: Int = 0
    var presentMonthIndex = 0
    var presentYear = 0
    var todaysDate = 0
    var firstWeekDayOfMonth = 0   //(Sunday-Saturday 1-7)
    var touchDay: Int = 0
    
    let filemgr = FileManager.default
    
    var dbDateArr = [] as Array

    override init(frame: CGRect) {
        super.init(frame: frame)
        Style.themeDark()
        
        initializeView()
    }
    
    func initializeView() {
        currentMonthIndex = Calendar.current.component(.month, from: Date())// 현재 월 구함
        print("presentMonthIndex = ", presentMonthIndex,", currentMonthIndex = ", currentMonthIndex)
        currentYear = Calendar.current.component(.year, from: Date())// 현재 년 구함
        todaysDate = Calendar.current.component(.day, from: Date())// 현재 일 구함
        firstWeekDayOfMonth=getFirstWeekDay()
        
        //for leap years, make february month of 29 days
        if currentMonthIndex == 2 && currentYear % 4 == 0 {
            numOfDaysInMonth[currentMonthIndex-1] = 29
        }
        //end
        
        
        presentMonthIndex=currentMonthIndex
        presentYear=currentYear
        
        setupViews()
        
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(dateCVCell.self, forCellWithReuseIdentifier: "Cell")
        
        dbLoad()
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numOfDaysInMonth[currentMonthIndex-1] + firstWeekDayOfMonth - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! dateCVCell
        cell.backgroundColor=UIColor.clear
        if indexPath.item <= firstWeekDayOfMonth - 2 {
            cell.isHidden=true
        } else {
            let calcDate = indexPath.row-firstWeekDayOfMonth+2
            cell.isHidden=false
            cell.lbl.text="\(calcDate)"
            

            let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let dbPath = dirPaths.appendingPathComponent("diaryDb.db").path
            let fmdb = FMDatabase(path: dbPath as String)
            
            var currentDate : String!
            
            if (currentMonthIndex/10) == 0 && (calcDate/10) == 0 {
                currentDate = "\(currentYear)0\(currentMonthIndex)0\(calcDate)"
            } else if (currentMonthIndex/10) == 0 && (calcDate/10) != 0 {
                currentDate = "\(currentYear)0\(currentMonthIndex)\(calcDate)"
            } else if (currentMonthIndex/10) != 0 && (calcDate/10) == 0 {
                currentDate = "\(currentYear)\(currentMonthIndex)0\(calcDate)"
            } else if (currentMonthIndex/10) != 0 && (calcDate/10) != 0 {
                currentDate = "\(currentYear)\(currentMonthIndex)\(calcDate)"
            }
            if fmdb.open() {
                let sql = "SELECT date FROM diary WHERE date = '\(Int(currentDate!)!)'"
                let result: FMResultSet? = fmdb.executeQuery(sql, withArgumentsIn: [])
                
                while (result?.next() == true) {
                    if ((Int(currentDate!)!)%100) == (Int(cell.lbl.text!)!) {
                        cell.circle.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    }
                }
                result?.close()
                fmdb.close()
            } else {
                print("error")
            }

            
            // 오늘 날짜 표시 (글씨 색 바꾸기, 데이터 확인하기)
            if calcDate == todaysDate && currentYear == presentYear && currentMonthIndex == presentMonthIndex {
                cell.lbl.textColor = Colors.lightPink
                cell.layer.borderColor = #colorLiteral(red: 0.96034747, green: 0.7378694275, blue: 0.7793999148, alpha: 1)
                cell.layer.borderWidth = 1
                
                let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let dbPath = dirPaths.appendingPathComponent("diaryDb.db").path
                let fmdb = FMDatabase(path: dbPath as String)
                
                if fmdb.open() {
                    let sql = "SELECT content FROM diary WHERE date = '\(Int(currentDate!)!)'"
                    let result: FMResultSet? = fmdb.executeQuery(sql, withArgumentsIn: [])
                    
                    if result?.next() == true {
                        diaryView.lblDiary.text = result?.string(forColumn: "content")
                    } else {
                        diaryView.lblDiary.text = "작성된 글이 없습니다."
                    }
                    result?.close()
                    fmdb.close()
                } else {
                    print("error")
                }
            } else {
                cell.isUserInteractionEnabled=true
                cell.lbl.textColor = Style.activeCellLblColor   //white
                cell.layer.borderWidth = 0
            }
        }
        return cell
    }
    
    /* 선택했을때 배경 분홍색*/
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell=collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor=Colors.lightPink
        let lbl = cell?.subviews[1] as! UILabel
        lbl.textColor=UIColor.white
        
        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dbPath = dirPaths.appendingPathComponent("diaryDb.db").path
        let fmdb = FMDatabase(path: dbPath as String)
        
        var saveDate : String!
        
        if (currentMonthIndex/10) == 0 && (Int(lbl.text!)!/10) == 0 {
            saveDate = "\(currentYear)0\(currentMonthIndex)0\(Int(lbl.text!)!)"
        } else if (currentMonthIndex/10) == 0 && (Int(lbl.text!)!/10) != 0 {
            saveDate = "\(currentYear)0\(currentMonthIndex)\(Int(lbl.text!)!)"
        } else if (currentMonthIndex/10) != 0 && (Int(lbl.text!)!/10) == 0 {
            saveDate = "\(currentYear)\(currentMonthIndex)0\(Int(lbl.text!)!)"
        } else if (currentMonthIndex/10) != 0 && (Int(lbl.text!)!/10) != 0 {
            saveDate = "\(currentYear)\(currentMonthIndex)\(Int(lbl.text!)!)"
        }

        if fmdb.open() {
            let sql = "SELECT content FROM diary WHERE date = '\(Int(saveDate!)!)'"
            let result: FMResultSet? = fmdb.executeQuery(sql, withArgumentsIn: [])

            if result?.next() == true {
                diaryView.lblDiary.text = result?.string(forColumn: "content")
            } else {
                diaryView.lblDiary.text = "작성된 글이 없습니다."
            }
            result?.close()
            fmdb.close()
        } else {
            print("error")
        }
    
        touchDay = Int(lbl.text!)!
        print("선택한 날짜 :",currentYear,".",currentMonthIndex,".",touchDay)
    }
    
    /* 다른거 선택했을때 배경, 텍스트 색 원상복귀 */
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell=collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor=UIColor.clear
        let lbl = cell?.subviews[1] as! UILabel
        
        if Int(lbl.text!) == todaysDate {   //todaysDate면 lightPink
            lbl.textColor = Colors.lightPink
            cell?.layer.borderColor = #colorLiteral(red: 0.96034747, green: 0.7378694275, blue: 0.7793999148, alpha: 1)
            cell?.layer.borderWidth = 1
        } else {
            lbl.textColor = Style.activeCellLblColor    //white
        }
    }
    
    /* 달력 테이블 크기 설정 */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/7 - 8
        let height: CGFloat = 40
        return CGSize(width: width, height: height)
    }
    
    /* 달력 세로 간격 설정 */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    /* 달력 가로 간격 설정 */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func getFirstWeekDay() -> Int {
        let day = ("\(currentYear)-\(currentMonthIndex)-01".date?.firstDayOfTheMonth.weekday)!
        return day
    }
    
    func didChangeMonth(monthIndex: Int, year: Int) {
        currentMonthIndex=monthIndex+1
        print("presentMonthIndex = ", presentMonthIndex, ", currentMonthIndex = ", currentMonthIndex)
        currentYear = year
        
        //for leap year, make february month of 29 days
        if monthIndex == 1 {
            if currentYear % 4 == 0 {
                numOfDaysInMonth[monthIndex] = 29
            } else {
                numOfDaysInMonth[monthIndex] = 28
            }
        }
        //end
        
        firstWeekDayOfMonth=getFirstWeekDay()
        
        myCollectionView.reloadData()
        
        monthView.btnLeft.isEnabled = true
    }
    
    
    func dbLoad() {
        let dirpaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dbPath = dirpaths.appendingPathComponent("diaryDb.db").path
        
        if !filemgr.fileExists(atPath: dbPath) {
            print("db없음")
        } else {
            print("db있음")
        }
    }
    
    
    
    func setupViews() {
        addSubview(monthView)
        monthView.topAnchor.constraint(equalTo: topAnchor).isActive=true
        monthView.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        monthView.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        monthView.heightAnchor.constraint(equalToConstant: 35).isActive=true
        monthView.delegate=self
        
        addSubview(weekdaysView)
        weekdaysView.topAnchor.constraint(equalTo: monthView.bottomAnchor).isActive=true
        weekdaysView.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        weekdaysView.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        weekdaysView.heightAnchor.constraint(equalToConstant: 30).isActive=true
        
        addSubview(myCollectionView)
        myCollectionView.topAnchor.constraint(equalTo: weekdaysView.bottomAnchor, constant: 0).isActive=true
        myCollectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive=true
        myCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive=true
        myCollectionView.heightAnchor.constraint(equalToConstant: 300).isActive=true
        
        addSubview(diaryView)
        diaryView.topAnchor.constraint(equalTo: myCollectionView.bottomAnchor).isActive=true
        diaryView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive=true
        diaryView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive=true
        diaryView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        
    }
    
    let monthView: MonthView = {
        let v=MonthView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let weekdaysView: WeekdaysView = {
        let v=WeekdaysView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let myCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let myCollectionView=UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        myCollectionView.showsHorizontalScrollIndicator = false
        myCollectionView.translatesAutoresizingMaskIntoConstraints=false
        myCollectionView.backgroundColor=UIColor.clear
        myCollectionView.allowsMultipleSelection=false
        return myCollectionView
    }()
    
    let diaryView: DiaryView = {
        let v=DiaryView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class dateCVCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor=UIColor.clear
        layer.cornerRadius=5
        layer.masksToBounds=true
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(lbl)
        lbl.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive=true
        lbl.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        lbl.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        
        addSubview(circle)
        circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        circle.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 7).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 7).isActive = true
        
    }
    
    let lbl: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.textAlignment = .center
        label.font=UIFont.systemFont(ofSize: 16)
        label.textColor=Colors.darkGray
        label.translatesAutoresizingMaskIntoConstraints=false
        return label
    }()
    
    let circle : UIView = {
        let circle = UIView()
        circle.layer.cornerRadius = 5
        circle.translatesAutoresizingMaskIntoConstraints=false
        
        return circle
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        circle.backgroundColor = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//get first day of the month
extension Date {
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    var firstDayOfTheMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
    }
}

//get date from string
extension String {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var date: Date? {
        return String.dateFormatter.date(from: self)
    }
}


