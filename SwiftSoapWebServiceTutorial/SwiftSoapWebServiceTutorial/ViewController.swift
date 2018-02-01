//
//  ViewController.swift
//  SwiftSoapWebServiceTutorial
//
//
//  Created by Esat Gözcü on 31.01.2018.
//  Copyright © 2018 Esat Gözcü. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate,XMLParserDelegate {
    
    var mutableData: NSMutableData = NSMutableData()
    var currentElementName: String = ""
    
    @IBOutlet weak var tcText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var surnameText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // Test Et butonuna tıklandığında..
    @IBAction func button(_ sender: Any) {
    
        // İsim ve soyisimin bütün harflerinin büyük olması gerekiyor.
        // O yüzden uppercased() kullanıyoruz.
        let tcString = self.tcText.text
        let nameString = self.nameText.text?.uppercased(with: Locale(identifier: "tr"))
        let surnameString = self.surnameText.text?.uppercased(with: Locale(identifier: "tr"))
        let yearString = self.yearText.text
        
        // Web servisimizdeki SoapMessage kısmını kopyalayıp kendi verilerimizle birleştiriyoruz.
        // Eğer Soap 1.2 kısmı kullanılacak ise o kısımdaki SoapMessage kopyalanmalıdır.
        let soapMessage =
        "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><TCKimlikNoDogrula xmlns='http://tckimlik.nvi.gov.tr/WS'><TCKimlikNo>\(tcString!)</TCKimlikNo><Ad>\(nameString!)</Ad><Soyad>\(surnameString!)</Soyad><DogumYili>\(yearString!)</DogumYili></TCKimlikNoDogrula></soap:Body></soap:Envelope>"
        
        // Web servisin URL'si.
        let urlString = "https://tckimlik.nvi.gov.tr/Service/KPSPublic.asmx"
        
        // URL'yi oluşturuyoruz.
        let url = URL(string:urlString)
        
        // URL ile sorgumuzu bağlıyoruz.
        let theRequest = NSMutableURLRequest(url:url!)
        
        // Soap mesajının uzunluğunu hesaplıyoruz.
        let msLength = soapMessage.count
        
        // Web servis sayfasında soapMessage kısmının üstündeki verileri giriyoruz.
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.addValue(String(msLength), forHTTPHeaderField: "Content-Length")
        theRequest.httpMethod="POST"
        theRequest.httpBody = soapMessage.data(using: String.Encoding.utf8,allowLossyConversion: false)
        let connection = NSURLConnection(request: theRequest as URLRequest,delegate:self,startImmediately:true)
        connection?.start()
        
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElementName == "TCKimlikNoDogrulaResult"{
            // Dönen sonuç true dönerse..
            if string == "true"
            {
                // AlertDialog oluşturup bilgi veriyoruz.
                let alert = UIAlertController(title: "Sonuç", message: "Sisteme Kayıtlı Kullanıcı Bulundu !!", preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
                // Dönen sonuç false dönerse..
            else{
                // AlertDialog oluşturup bilgi veriyoruz.
                let alert = UIAlertController(title: "Sonuç", message: "Sisteme Kayıtlı Kullanıcı Bulunamadı !!", preferredStyle: UIAlertControllerStyle.alert)
                let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    // Gerekli fonksiyonlarımızı yazıyoruz..
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        mutableData = NSMutableData()
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElementName = elementName
    }
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        print("connection error\(error)")
    }
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        self.mutableData.append(data)
    }
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        let xmlParser = XMLParser(data: mutableData as Data)
        xmlParser.delegate = self
        xmlParser.parse()
        xmlParser.shouldResolveExternalEntities = true
    }
}


