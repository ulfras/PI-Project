//
//  ViewController.swift
//  Mankepri
//
//  Created by Maulana Frasha on 18/07/21.
//

import UIKit
import SQLite3
import LocalAuthentication

class MenuUtamaVC: UIViewController {
    
    
    //MARK: - variabel
    //outlet
    @IBOutlet weak var welcomeoutlet: UILabel!
    @IBOutlet weak var jumlahtabungan: UILabel!
    @IBOutlet weak var jumlahpemasukan: UILabel!
    @IBOutlet weak var jumlahpengeluaran: UILabel!
    @IBOutlet weak var sisaanggaran: UILabel!
    @IBOutlet weak var jumlahanggaran: UILabel!
    
    //var total pemasukan
    var totpemuang: Int = 0
    var totpenguang: Int = 0
    var tottabungan: Int = 0
    var totanggaran: Int = 0
    var sisanggaran: Int = 0
    
    //dbconnector
    var db: OpaquePointer?
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Database Use
        //MARK: openDB
        let fileURL = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("mankepri.sqlite")
      
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening db")
            return
        }
        
        //MARK: - selectDB
        //MARK: select pemasukan
        let totpem = "SELECT sum(uang) FROM transaksi WHERE jenis LIKE 'CR';"
        var dbtotpem: OpaquePointer?
        
        if sqlite3_prepare(db, totpem, -1, &dbtotpem, nil) == SQLITE_OK {
            print("prepare select totpem aman")
            if sqlite3_step(dbtotpem) == SQLITE_ROW {
                  let pem = sqlite3_column_int(dbtotpem, 0)
                
                totpemuang = Int(pem)
            }
        }
        jumlahpemasukan.text = "\(totpemuang.formattedWithSeparator)"
        sqlite3_finalize(dbtotpem)
        
        //MARK: select pengeluaran
        let totpeng = "SELECT sum(uang) FROM transaksi WHERE jenis LIKE 'DB';"
        var dbtotpeng: OpaquePointer?
        
        if sqlite3_prepare(db, totpeng, -1, &dbtotpeng, nil) == SQLITE_OK {
            print("prepare select totpeng aman")
            if sqlite3_step(dbtotpeng) == SQLITE_ROW {
                  let peng = sqlite3_column_int(dbtotpeng, 0)
                
                totpenguang = Int(peng)
            }
        }
        sqlite3_finalize(dbtotpeng)
        jumlahpengeluaran.text = "\(totpenguang.formattedWithSeparator)"

        tottabungan = totpemuang - totpenguang
        jumlahtabungan.text = "\(tottabungan.formattedWithSeparator)"
        
        //MARK: - select nama pengguna
        let selectpertama = "SELECT nama FROM pengguna"
        var selectpointerpertama: OpaquePointer?
        
        if sqlite3_prepare(self.db, selectpertama, -1, &selectpointerpertama, nil) != SQLITE_OK {
            print("gagal prepare get nama")
        }
        if sqlite3_step(selectpointerpertama) == SQLITE_ROW {
            print("Berhasil select")
            guard let selectnama = sqlite3_column_text(selectpointerpertama, 0) else {return}
            let nama = String(cString: selectnama)
            welcomeoutlet.text = "Selamat Datang, \(nama)"
        }
            sqlite3_finalize(selectpointerpertama)
        
        
        //select anggaran
        let selectotang = "SELECT sum(uang) FROM anggaran;"
        var dbtotang: OpaquePointer?
        
        if sqlite3_prepare(db, selectotang, -1, &dbtotang, nil) == SQLITE_OK {
            print("prepare select totpeng aman")
            if sqlite3_step(dbtotang) == SQLITE_ROW {
                  let ang = sqlite3_column_int(dbtotang, 0)
                
                totanggaran = Int(ang)
            }
        }
        sqlite3_finalize(dbtotang)
        jumlahanggaran.text = totanggaran.formattedWithSeparator
        sisanggaran = totanggaran - totpenguang
        sisaanggaran.text = "IDR \(sisanggaran.formattedWithSeparator)"
        
    }// end of viewDidLoad

    
}// end of ViewController Class



// MARK: - Hide keyboard and number formatter. DONT TOUCH IT
extension UIViewController{
    func hideKeyboardWhenTappedAround() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }
    @objc func dismissKeyboard() {
            view.endEditing(true)
        }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter
    }()
}

extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self) ?? "" }
}

    

    


