//
//  HomePageViewController.swift
//  CurrencyConverterKFH
//
//  Created by Muthukumaresh, Muthuvel (M.) on 01/08/23.
//

import UIKit

class HomePageViewController: UIViewController {
    @IBOutlet var homePageTableView: UITableView?
    @IBOutlet var loader: UIActivityIndicatorView?
    var viewModel = BankInfoViewModel()
    
    var bankList: [DataDetails] = [] {
        didSet {
            homePageTableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.bankDetailsDelegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Validate", style: .plain, target: self, action: #selector(validateIBanNumber))
        handleLoader(show: true)
        viewModel.fetchBankDetails()
    }
    
    @objc private func validateIBanNumber() {
        let alertController = UIAlertController(title: "Please Enter the IBAN Number to validate", message: nil, preferredStyle: .alert)
        alertController.addTextField{ (textField) in
                textField.placeholder = "AD1200012030200359100100"
                }
            let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alertController] _ in
                let answer = alertController.textFields![0]
                self.handleLoader(show: true)
                self.viewModel.verifyIBanNumber(iban: answer.text ?? "")
            }
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }
    
    private func handleLoader(show: Bool) {
        DispatchQueue.main.async {
            self.loader?.isHidden = !show
            self.homePageTableView?.isHidden = show
        }
    }

}
extension HomePageViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bankList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as UITableViewCell
        var content = cell.defaultContentConfiguration()
        content.text = bankList[indexPath.row].swiftData.name
        content.secondaryText = bankList[indexPath.row].swiftData.city
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let iBanNumber = bankList[indexPath.row].ibanData.iban else {
            return
        }
        handleLoader(show: true)
        viewModel.verifyIBanNumber(iban: iBanNumber)
        
    }
    
}

extension HomePageViewController: BankInfoDelegate {
    func sendIBanResponseStatus(status: Bool, message: String) {
        handleLoader(show: false)
        if status == true {
            //naviagtion to next screen
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)

            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyConverterViewController") as! CurrencyConverterViewController
            nextViewController.title = "CurrencyConverter"
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    func sendBankDetails(details: [DataDetails]) {
        bankList = details
        handleLoader(show: false)
    }
}

