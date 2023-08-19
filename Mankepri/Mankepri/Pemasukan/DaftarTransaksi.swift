//
//  DaftarTransaksiMasuk.swift
//  Mankepri
//
//  Created by Maulana Frasha on 08/08/21.
//

import Foundation
import SQLite3
import UIKit

class DaftarTransaksiTVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Tombol kembali ke home
    @IBOutlet weak var buttonOK: UIButton!
    
    //MARK: DB Setup
    var db: OpaquePointer?
    struct daftartransaksi{
        let uang: Int
        let kategori: String
        let keterangan: String
        let tanggal: String
        let jenis: String
    }
    var arraydata: [daftartransaksi] = []
    
    //MARK: tableviewoutlet
    @IBOutlet weak var dataTV: UITableView!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataTV.dataSource = self
        dataTV.delegate = self
        
        //MARK: - Set up the database
        //openDB
        let fileURL = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("mankepri.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening db")
            return
        }
        
        //selectDB
        let sel = "SELECT uang, kategori, keterangan, tanggal, jenis FROM transaksi;"
        var sell: OpaquePointer?
        
        if sqlite3_prepare(db, sel, -1, &sell, nil) == SQLITE_OK {
            print("prepare sel aman")
            
            while (sqlite3_step(sell) == SQLITE_ROW){
                let uang = sqlite3_column_int(sell, 0)
                guard let kategori = sqlite3_column_text(sell, 1) else {return}
                guard let keterangan = sqlite3_column_text(sell, 2) else {return}
                guard let tanggal = sqlite3_column_text(sell, 3) else {return}
                guard let jenis = sqlite3_column_text(sell, 4) else {return}
                
                let kat = String(cString: kategori)
                let ket = String(cString: keterangan)
                let tgl = String(cString: tanggal)
                let jen = String(cString: jenis)
                
                arraydata.append(daftartransaksi(uang: Int(uang), kategori: kat, keterangan: ket, tanggal: tgl, jenis: jen))

            }
        }
        //MARK: - UI Desain
        //desain tombol OK
        buttonOK.layer.cornerRadius = 20.0
      
    }
    
    //MARK: - tableViewController
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arraydata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "costumdata", for: indexPath) as! ViewCell
        
        if arraydata[indexPath.row].jenis == "DB" {
            cell.jumlahTV.textColor = UIColor(named: "ColorPengeluaran")
            cell.jumlahTV.text = "Rp\((arraydata[indexPath.row].uang).formattedWithSeparator)   DB"
            cell.jenisgambar.image = UIImage(named: "PengeluaranColor")
        }
        
        if arraydata[indexPath.row].jenis == "CR" {
            cell.jumlahTV.textColor = UIColor(named: "ColorPemasukan")
            cell.jumlahTV.text = "Rp\((arraydata[indexPath.row].uang).formattedWithSeparator)   CR"
            cell.jenisgambar.image = UIImage(named: "PemasukanColor")
        }
        
        cell.tglTV.text = "Tanggal : \(arraydata[indexPath.row].tanggal)"
        cell.kategoriTV.text = "Kategori : \(arraydata[indexPath.row].kategori)"
        cell.keteranganVC.text = "Keterangan : \(arraydata[indexPath.row].keterangan)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 172
    }
    
}

//MARK: objek didalam cell
class ViewCell: UITableViewCell {
    @IBOutlet weak var tglTV: UILabel!
    @IBOutlet weak var jumlahTV: UILabel!
    @IBOutlet weak var kategoriTV: UILabel!
    @IBOutlet weak var keteranganVC: UILabel!
    @IBOutlet weak var jenisgambar: UIImageView!
}
