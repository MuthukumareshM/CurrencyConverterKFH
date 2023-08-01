//
//  CurrencyConverterViewController.swift
//  CurrencyConverterKFH
//
//  Created by Muthukumaresh, Muthuvel (M.) on 01/08/23.
//

import UIKit

class CurrencyConverterViewController: UIViewController {
    @IBOutlet var currencyRatesTableView: UITableView?
    @IBOutlet var loader: UIActivityIndicatorView?
    @IBOutlet var successLabel: UILabel?
    
    var currencyArray: [CurrencyRatesModel] = []
    
    var viewModel = CurrencyRatesViewModel()
    
    var currencyRatesList: [String: Double] = [:] {
        didSet {
            currencyRatesTableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchCurrencyDelegate = self
        successLabel?.text = "Iban validated successfully"
        // Do any additional setup after loading the view.
        viewModel.fetchCurrentCurrencyRates()
    }
    
    private func handleLoader(show: Bool) {
        DispatchQueue.main.async {
            self.loader?.isHidden = !show
            self.successLabel?.isHidden = !show
            self.currencyRatesTableView?.isHidden = show
        }
    }
}

extension CurrencyConverterViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let noteLabel = UILabel.init(frame: CGRect.init(x: 20, y: -15, width: tableView.frame.size.width, height: 45))
        noteLabel.textColor = UIColor.red
        noteLabel.font = UIFont.systemFont(ofSize: 11.0)
        noteLabel.textAlignment = .left
        noteLabel.text = "*Current price of 1 KWD with other countries"
        
        let countryLabel = UILabel.init(frame: CGRect.init(x: 20, y: 5, width: tableView.frame.size.width, height: 45))
        countryLabel.textColor = UIColor.black
        countryLabel.font = UIFont.systemFont(ofSize: 13.0)
        countryLabel.textAlignment = .left
        countryLabel.text = "Country"
        
        let label = UILabel.init(frame: CGRect.init(x: tableView.frame.size.width - 100, y: 5, width: tableView.frame.size.width, height: 45))
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textAlignment = .left
        label.text = "Current Price"
        
        let frame = tableView.frame
        let height:CGFloat = 250
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: height))  // create custom view
        headerView.backgroundColor  = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.00)
        headerView.addSubview(countryLabel)
        headerView.addSubview(label)
        headerView.addSubview(noteLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyRatesList.keys.map({ $0 }).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as UITableViewCell
        cell = UITableViewCell(style: .value2, reuseIdentifier: "currencyCell")
        var content = cell.defaultContentConfiguration()
        content.text = currencyRatesList.keys.map({ $0 })[indexPath.row]
        content.secondaryText = String(currencyRatesList.values.map({ $0 })[indexPath.row])
        cell.contentConfiguration = content
        return cell
    }
}

extension CurrencyConverterViewController: currencyRateDetailsDelegate {
    func sendCurrencyListAndRateDetails(details: [String : Double]) {
        currencyRatesList = details
        successLabel?.isHidden = false
        handleLoader(show: false)
    }
}
