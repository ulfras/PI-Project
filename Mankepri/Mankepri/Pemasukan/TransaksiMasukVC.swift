//
//  UangVC.swift
//  Mankepri
//
//  Created by Maulana Frasha on 19/07/21.
//

import Foundation
import UIKit
import SQLite3
import DropDown

class TransaksiMasukVC: UIViewController, UITextFieldDelegate {
    
    //MARK:OpaquePointer Database
    var db: OpaquePointer?
    
    //MARK:memanggil frameworks dropdown
    let dropDown = DropDown()

    //MARK: - dropdown item
    @IBOutlet weak var viewKategori: UIView!
    @IBOutlet weak var tomboldropdownoutlet: UIButton!
    @IBOutlet weak var labelKategori: UILabel!
    let kategori = ["Gaji", "Hadiah", "Pinjaman", "Bonus", "Lain-Lain"]
    
    //MARK:outlet button tambah & daftar transaksi
    @IBOutlet weak var daftaroutlet: UIButton!
    @IBOutlet weak var tambahoutlet: UIButton!
    
    //MARK:TextFieldOutlet
    @IBOutlet weak var keteranganoutlet: UITextField!
    @IBOutlet weak var jumlahoutlet: UITextField!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Set up the database
        //openDB
        let fileURL = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("mankepri.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening db")
            return
        }
        
        //createTable
        let createTable = "CREATE TABLE IF NOT EXISTS transaksi (id INTEGER PRIMARY KEY AUTOINCREMENT, uang INTEGER, kategori TEXT, keterangan TEXT, tanggal TEXT, jenis TEXT)"
        
        if sqlite3_exec(db, createTable, nil, nil, nil) != SQLITE_OK {
            print("gagal")
        } else {print ("DB PEMASUKAN AMAN")}
        
        //MARK: - UI Desain
        //MARK: Batas input keterangan
        keteranganoutlet.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        keteranganoutlet.delegate = self
        
        //MARK: mengedit button tambah & daftar
        daftaroutlet.layer.cornerRadius = 20.0
        tambahoutlet.layer.cornerRadius = 20.0
        
        //MARK: memanggil func menutup keyboard ketika menekan diluar textfield
        self.hideKeyboardWhenTappedAround()
        
        //MARK: desain tombol kategori
        tomboldropdownoutlet.layer.cornerRadius = 5.0
        tomboldropdownoutlet.layer.borderWidth = 1.0
        tomboldropdownoutlet.layer.borderColor = UIColor.systemGray5.cgColor
        
        //MARK: membuat dropdown menu
        dropDown.anchorView = viewKategori
        dropDown.dataSource = kategori
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
            self.labelKategori.text = kategori[index]
            print(labelKategori.text!)
        }
        
    }//Akhir viewDidLoad
    
    //MARK: - tombol tambah
    @IBAction func tomboltambahpemasukan(_ sender: Any) {
        if (jumlahoutlet.text?.isEmpty == true) {
            peringatandata()
        } else if labelKategori.text == "Pilih kategori"  {
            peringatandata()
        } else if (keteranganoutlet.text?.isEmpty == true) {
            peringatandata()
        } else {
            peringatansimpan()
        }
    }
    
    //MARK: - tombol dropdown
    @IBAction func tomboldropdownaction(_ sender: Any) {
        dropDown.show()
    }
    
    //MARK: - Func batas text field keterangan sampai 40 karakter
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           guard let textFieldText = keteranganoutlet.text,
               let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                   return false
           }
           let substringToReplace = textFieldText[rangeOfTextToReplace]
           let count = textFieldText.count - substringToReplace.count + string.count
           return count <= 40
    }
    
    //MARK: - Alert Func
    func peringatansimpan(){
        let alert = UIAlertController(title: "Peringatan!", message: "\n Pastikan kembali data yang terinput sudah benar karena data tidak dapat dirubah setelah tersimpan.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Kembali", style: .cancel, handler: { ACTION in
        }))
        
        //MARK: Insert database didalam alert
        alert.addAction(UIAlertAction(title: "Simpan", style: .default, handler: { [self] ACTION in
            
            //MARK: Mengambil data tanggal dan merubah menjadi string
            let dateFormatter = DateFormatter(); dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateFormatter.string(from: Date())
            
            //MARK: insert variable
            let insert = "INSERT INTO transaksi (uang, kategori, keterangan, tanggal, jenis) VALUES (?, ?, ?, ?, 'CR')"
            var insertpointer: OpaquePointer?
            
            let uang = self.jumlahoutlet.text
            let kat = NSString(string: self.labelKategori.text!)
            let ket = NSString(string: self.keteranganoutlet.text!)
            let tgl = NSString(string: date)
            
            //MARK: Preparing insert
            if sqlite3_prepare(self.db, insert, -1, &insertpointer, nil) == SQLITE_OK {
                print("Prepare insert aman")
            } else {print("Gagal Prepare")}
            
            if sqlite3_bind_int(insertpointer, 1, (uang! as NSString).intValue) == SQLITE_OK{
                     print("success binding uang")
            }
            if sqlite3_bind_text(insertpointer, 2, kat.utf8String, -1, nil) == SQLITE_OK{
                print ("success binding kategori")
            }
            if sqlite3_bind_text(insertpointer, 3, ket.utf8String, -1, nil)  == SQLITE_OK{
                    print("success binding keterangan")
            }
            if sqlite3_bind_text(insertpointer, 4, tgl.utf8String, -1, nil)  == SQLITE_OK{
                    print("success binding tgl")
            }
            

            //MARK: Inserting
            if sqlite3_step(insertpointer) == SQLITE_DONE {
                print("Berhasil insert")
            } else {print("Gagal insert")}
           
           sqlite3_finalize(insertpointer)
            
            self.jumlahoutlet.text = ""
            self.labelKategori.text = "Pilih kategori"
            self.keteranganoutlet.text = ""
            
            CustomToast.show(message: "Transaksi berhasil terdata.", bgColor: .black.withAlphaComponent(0.7), textColor: .white, labelFont: .systemFont(ofSize: 18), showIn: .bottom, controller: self)
        }))
        present(alert, animated: true)
    }
    
    func peringatandata(){
        let alert = UIAlertController(title: "Peringatan!", message: "\n Data yang terinput tidak lengkap, silahkan di cek kembali", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Kembali", style: .cancel, handler: { ACTION in
        }))
        
        present(alert, animated: true)
    }
}//Akhir Class
