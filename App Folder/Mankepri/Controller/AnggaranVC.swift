//
//  AnggaranVC.swift
//  Mankepri
//
//  Created by Maulana Frasha on 19/07/21.
//

import Foundation
import UIKit
import SQLite3

class AnggaranVC: UIViewController {
    //dbconnector
    var db: OpaquePointer?
    //var total
    var totpenguang: Int = 0
    var totanggaran: Int = 0
    var sisaanggaran: Int = 0
    
    //MARK: - variabel
    //outlet
    @IBOutlet weak var sisaanggaranoutlet: UILabel!
    @IBOutlet weak var totalanggaranoutlet: UILabel!
    @IBOutlet weak var pengeluaranoutlet: UILabel!
    
    @IBOutlet weak var tombolaturoutlet: UIButton!
    
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
        
        //createTable
        let createTable = "CREATE TABLE IF NOT EXISTS anggaran (id INTEGER PRIMARY KEY AUTOINCREMENT, uang INTEGER)"
        
        if sqlite3_exec(db, createTable, nil, nil, nil) != SQLITE_OK {
            print("gagal")
        } else {print ("DB ANGGARAN AMAN")}
        
        //MARK: select anggaran
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
        totalanggaranoutlet.text = "\(totanggaran.formattedWithSeparator)"
        
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
        
        pengeluaranoutlet.text = "\(totpenguang.formattedWithSeparator)"

        sisaanggaran = totanggaran - totpenguang
        sisaanggaranoutlet.text = "\(sisaanggaran.formattedWithSeparator)"
        
        //MARK: - UI Desain
        //tombol atur anggaran
        tombolaturoutlet.layer.cornerRadius = 20.0
        
    }//Akhir viewDidLoad
    @IBAction func aturanggaranaction(_ sender: Any) {
        aturanggaranalert()
    }
    
    func aturanggaranalert(){
        let ac = UIAlertController(title: "Atur Anggaran", message: "\nMasukan jumlah anggaran yang diinginkan", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: {ACTION in}))
        ac.addTextField(configurationHandler: { textField in
            textField.keyboardType = .numberPad
            textField.placeholder = "Jumlah anggaran"
            textField.textAlignment = .center
        })
        ac.addAction(UIAlertAction(title: "Buat", style: .default, handler: { ACTION in
            let answer = ac.textFields![0]
            let inputanggaran = answer.text ?? "Default"
            
            //MARK: var insert anggaran
            let uang = inputanggaran
            let insertanggaran = "INSERT INTO anggaran (uang) VALUES (\(uang))"
            var insertanggaranpointer: OpaquePointer?
            
            if sqlite3_prepare(self.db, insertanggaran, -1, &insertanggaranpointer, nil) != SQLITE_OK {
                print("gagal insert anggaran")
            }
            //inserting
            if sqlite3_step(insertanggaranpointer) == SQLITE_DONE {
                print("berhasil insert anggaran")
            }
            
            //select ulang anggaran
            let selectotang = "SELECT sum(uang) FROM anggaran;"
            var dbtotang: OpaquePointer?
            
            if sqlite3_prepare(self.db, selectotang, -1, &dbtotang, nil) == SQLITE_OK {
                print("prepare select totpeng aman")
                if sqlite3_step(dbtotang) == SQLITE_ROW {
                      let ang = sqlite3_column_int(dbtotang, 0)
                    
                    self.totanggaran = Int(ang)
                }
            }
            sqlite3_finalize(dbtotang)
            self.totalanggaranoutlet.text = "\(self.totanggaran.formattedWithSeparator)"
            
            self.sisaanggaran = self.totanggaran - self.totpenguang
            self.sisaanggaranoutlet.text = "\(self.sisaanggaran.formattedWithSeparator)"
            
            CustomToast.show(message: "Anggaran berhasil ditambah.", bgColor: .black.withAlphaComponent(0.7), textColor: .white, labelFont: .systemFont(ofSize: 18), showIn: .bottom, controller: self)

        }))
        
        present(ac, animated: true)
    }
    
    
    
}//Akhir class
