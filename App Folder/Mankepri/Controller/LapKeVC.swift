//
//  LapKeVC.swift
//  Mankepri
//
//  Created by Maulana Frasha on 19/07/21.
//

import Foundation
import UIKit
import SQLite3
import Charts

class LapKeVC: UIViewController {
    
    //MARK: - Outlet
    //outlet pie chart
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var tanggaloutlet: UILabel!
    
    //outlet pemasukan, pengeluaran, selisih
    @IBOutlet weak var totpemoutlet: UILabel!
    @IBOutlet weak var totpengoutlet: UILabel!
    @IBOutlet weak var selisih: UILabel!
    
    //outlet pemasukan terbesar
    @IBOutlet weak var pemuangmaks: UILabel!
    @IBOutlet weak var katpemmaks: UILabel!
    @IBOutlet weak var ketpemmaks: UILabel!
    
    //outlet pengeluaran terbesar
    @IBOutlet weak var penguangmaks: UILabel!
    @IBOutlet weak var katpengmaks: UILabel!
    @IBOutlet weak var ketpengmaks: UILabel!
    
    
    //MARK: - Variabel
    //db
    var db: OpaquePointer?
    
    //var data
    var totpemuang: Int = 0
    var totpenguang: Int = 0
    var pemterbes: Int = 0
    var pengterbes: Int = 0
    var totpempersen: Double = 0
    var totpengpersen: Double = 0
    
    var pemungmaks: Int = 0
    var pemkatmaks: String = ""
    var pemketmaks: String = ""
    
    var pengungmaks: Int = 0
    var pengkatmaks: String = ""
    var pengketmaks: String = ""
    
    var tanggal: String = ""
    
    //var piechart
    var totpemuangpie = PieChartDataEntry(value: 0)
    var totpenguangpie = PieChartDataEntry(value: 0)
    
    var total = [PieChartDataEntry]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - DB
        //connect
        let fileURL = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("mankepri.sqlite")
      
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening db")
            return
        }
        
        //select pemasukan
        let totpem = "SELECT sum(uang) FROM transaksi WHERE jenis LIKE 'CR';"
        var dbtotpem: OpaquePointer?
        
        if sqlite3_prepare(db, totpem, -1, &dbtotpem, nil) == SQLITE_OK {
            print("prepare select totpem aman")
            if sqlite3_step(dbtotpem) == SQLITE_ROW {
                  let pem = sqlite3_column_int(dbtotpem, 0)
                
                totpemuang = Int(pem)
            }
        }
        sqlite3_finalize(dbtotpem)
        totpemoutlet.text = totpemuang.formattedWithSeparator
        
        //select pengeluaran
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
        totpengoutlet.text = totpenguang.formattedWithSeparator
        
        selisih.text = (totpemuang - totpenguang).formattedWithSeparator
        
        let pengkali: Double = 100.00
        let pembagi: Double = Double(totpemuang) + Double(totpenguang)
       
        //Piechart value pemasukan dan pengeluaran
        totpempersen = Double(totpemuang) / Double(pembagi) * Double(pengkali)
        
        totpengpersen = Double(totpenguang) / Double(pembagi) * Double(pengkali)
        
        //MARK: - Piechart
        pieChart.chartDescription?.text = "Data dalam persen (%)"
        pieChart.chartDescription?.font = .systemFont(ofSize: 12.0, weight: UIFont.Weight.regular)
        
        totpemuangpie.value = Double(totpempersen)
        totpemuangpie.label = "Pemasukan"
        
        totpenguangpie.value = Double(totpengpersen)
        totpenguangpie.label = "Pengeluaran"
         
        total = [totpemuangpie, totpenguangpie]
        updatechart()
        
        
        //MARK: - select tanggal
        let dateFormatter = DateFormatter(); dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        
        //select tanggal pemasukan
        let seltgl = "SELECT MIN(id), tanggal FROM transaksi;"
        var dbseltgl: OpaquePointer?
        
        if sqlite3_prepare(db, seltgl, -1, &dbseltgl, nil) == SQLITE_OK {
            print("prepare select totpem aman")
            if sqlite3_step(dbseltgl) == SQLITE_ROW {
                guard let tgl = sqlite3_column_text(dbseltgl, 1) else {return}
                tanggal = String(cString: tgl)
            }
        }
        sqlite3_finalize(dbseltgl)
        
        tanggaloutlet.text = "\(tanggal) sampai \(date)"
        
        
        //pemasukan terbesar
        var dbpemmaks: OpaquePointer?
        let pemmaks = "SELECT MAX(uang), kategori, keterangan FROM transaksi WHERE jenis LIKE 'CR';"
        
        if sqlite3_prepare(db, pemmaks, -1, &dbpemmaks, nil) == SQLITE_OK{
            print("\nPrepare select pemmaks aman")
        }
        if sqlite3_step(dbpemmaks) == SQLITE_ROW {
            let uang = sqlite3_column_int(dbpemmaks, 0)
            guard let kat = sqlite3_column_text(dbpemmaks, 1) else {return}
            guard let ket = sqlite3_column_text(dbpemmaks, 2) else {return}
            
            let kategorimaks = String(cString: kat)
            let keteranganmaks = String(cString: ket)
            
            pemungmaks = Int(uang)
            pemkatmaks = kategorimaks
            pemketmaks = keteranganmaks
        }
        
        pemuangmaks.text = "Jumlah : \(pemungmaks.formattedWithSeparator)"
        katpemmaks.text = "Kategori : \(pemkatmaks)"
        ketpemmaks.lineBreakMode = .byWordWrapping
        ketpemmaks.numberOfLines = 0
        ketpemmaks.text = "Keterangan tambahan :\n\(pemketmaks)"
        
        //pengeluaran terbesar
        var dbpengmaks: OpaquePointer?
        let pengmaks = "SELECT MAX(uang), kategori, keterangan FROM transaksi WHERE jenis LIKE 'DB';"
        
        if sqlite3_prepare(db, pengmaks, -1, &dbpengmaks, nil) == SQLITE_OK{
            print("\nPrepare select pemmaks aman")
        }
        if sqlite3_step(dbpengmaks) == SQLITE_ROW {
            let uang = sqlite3_column_int(dbpengmaks, 0)
            guard let kat = sqlite3_column_text(dbpengmaks, 1) else {return}
            guard let ket = sqlite3_column_text(dbpengmaks, 2) else {return}
            
            let kategorimaks = String(cString: kat)
            let keteranganmaks = String(cString: ket)
            
            pengungmaks = Int(uang)
            pengkatmaks = kategorimaks
            pengketmaks = keteranganmaks
        }
        
        penguangmaks.text = "Jumlah : \(pengungmaks.formattedWithSeparator)"
        katpengmaks.text = "Kategori : \(pengkatmaks)"
        ketpengmaks.lineBreakMode = .byWordWrapping
        ketpengmaks.numberOfLines = 0
        ketpengmaks.text = "Keterangan tambahan :\n\(pengketmaks)"
        
    }//end viewDidLoad
    
    
    func updatechart(){
        let chartDataSet = PieChartDataSet(entries: total, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let colors = [UIColor(named: "ColorPemasukan"), UIColor(named: "ColorPengeluaran")]
        chartDataSet.colors = colors as! [NSUIColor]
        
        pieChart.data = chartData
    }

}//end class
