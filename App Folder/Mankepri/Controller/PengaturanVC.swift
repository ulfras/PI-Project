//
//  PengaturanVC.swift
//  Mankepri
//
//  Created by Maulana Frasha on 19/07/21.
//

import Foundation
import UIKit
import SQLite3

class PengaturanVC: UIViewController {
    
    //MARK: - variabel
    //MARK: outlet
    @IBOutlet weak var kembali: UIButton!
    @IBOutlet weak var namapenggunaoutlet: UILabel!
    @IBOutlet weak var switchBiometric: UISwitch!
    
    var namapengguna:String = ""
    
    //MARK: DB Connector
    var db: OpaquePointer?

    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: - UI Desain
        //desain tombol Kembali
        kembali.layer.cornerRadius = 20.0
        
        //MARK: - Switch
        switchBiometric.isOn =  UserDefaults.standard.bool(forKey: "switchState")
        
        //MARK: - Set up the database
        //openDB
        let fileURL = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("mankepri.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening db")
            return
        }
        
        //createTable
        let createTable = "CREATE TABLE IF NOT EXISTS pengguna (id INTEGER PRIMARY KEY AUTOINCREMENT, nama TEXT)"
        
        if sqlite3_exec(db, createTable, nil, nil, nil) != SQLITE_OK {
            print("gagal")
        } else {print ("DB PENGGUNA AMAN")}
        
        //MARK: Insert pertamakali
        if namapenggunaoutlet.text == "p" {
            let insertnamapertama = "INSERT INTO pengguna (nama) VALUES (?)"
            var insertnamapointerpertama: OpaquePointer?
            let nama: NSString = "Pengguna"
            
            if sqlite3_prepare(self.db, insertnamapertama, -1, &insertnamapointerpertama, nil) != SQLITE_OK {
                print("Prepare insert nama pengguna gagal")
            }
            
            if sqlite3_bind_text(insertnamapointerpertama, 1, nama.utf8String, -1, nil) != SQLITE_OK{
                print ("gagal binding")
            }
            
            if sqlite3_step(insertnamapointerpertama) == SQLITE_DONE{
                print("Berhasil insert pertama kali")
            } else {print("Gagal Insert 1")}
            sqlite3_finalize(insertnamapointerpertama)
            namapenggunaoutlet.text = "peng"
        }
        
        //MARK: Select pertama kali
        if namapenggunaoutlet.text == "peng" {
        let selectpertama = "SELECT nama FROM pengguna"
        var selectpointerpertama: OpaquePointer?
        
        if sqlite3_prepare(db, selectpertama, -1, &selectpointerpertama, nil) != SQLITE_OK {
            print("gagal prepare get nama")
        }
        if sqlite3_step(selectpointerpertama) == SQLITE_ROW {
            print("Berhasil select pertama kali")
            guard let selectnama = sqlite3_column_text(selectpointerpertama, 0) else {return}
            let nama = String(cString: selectnama)
            namapengguna = nama
        }
            namapenggunaoutlet.text = namapengguna
            sqlite3_finalize(selectpointerpertama)
        }
        
    }//Akhir viewDidLoad
    
    
    //MARK: -
    @IBAction func saveSwitchPressed(_ sender: UISwitch) {
           UserDefaults.standard.set(sender.isOn, forKey: "switchState")
       }
    
    //MARK: - Ganti nama button, func dan alert
    @IBAction func gantinama(_ sender: Any) {
        gantinamaalert()
    }
    
    func gantinamaalert(){
        let ac = UIAlertController(title: "Ubah Nama?", message: "\nMaks. 15 huruf.", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: { ACTION in
        }))
        ac.addTextField(configurationHandler: { textField in
            textField.textAlignment = .center
        })
        
        ac.addAction(UIAlertAction(title: "Submit", style: .default) { ACTION in
            let answer = ac.textFields![0]
            let namapengguna = answer.text ?? "Default"
            
            //Prepare insert nama pengguna
            let insertnama = "UPDATE pengguna SET nama = '\(namapengguna)' WHERE id = 1;"
            var insertnamapointer: OpaquePointer?
            
            if sqlite3_prepare(self.db, insertnama, -1, &insertnamapointer, nil) != SQLITE_OK {
                print("Prepare insert nama pengguna gagal")
            }
            //Inserting
            if sqlite3_step(insertnamapointer) != SQLITE_DONE{
                print("Gagal Insert")
            } else { print("Berhasil update")}
            
            sqlite3_finalize(insertnamapointer)
            
            //MARK: Select setelah ubah nama
            let selectpertama = "SELECT nama FROM pengguna"
            var selectpointerpertama: OpaquePointer?
            
            if sqlite3_prepare(self.db, selectpertama, -1, &selectpointerpertama, nil) != SQLITE_OK {
                print("gagal prepare get nama")
            }
            if sqlite3_step(selectpointerpertama) == SQLITE_ROW {
                print("Berhasil select")
                guard let selectnama = sqlite3_column_text(selectpointerpertama, 0) else {return}
                let nama = String(cString: selectnama)
                self.namapengguna = nama
            }
            self.namapenggunaoutlet.text = namapengguna
                sqlite3_finalize(selectpointerpertama)
            
            CustomToast.show(message: "Nama berhasil dirubah.", bgColor: .black.withAlphaComponent(0.7), textColor: .white, labelFont: .systemFont(ofSize: 18), showIn: .bottom, controller: self)
            })
            
        present(ac, animated: true)
    }

}//Akhir Class
