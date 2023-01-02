
import UIKit

class KivaLoanTableViewController: UITableViewController {
    
    let kivaLoanURL = "https://api.kivaws.org/v1/loans/newest.json"
    var loans = [Loan2]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 92.0
        tableView.rowHeight = UITableView.automaticDimension
        
        getLatestLoans()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows
        return loans.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! KivaLoanTableViewCell

        // Configure the cell...
        cell.nameLabel.text = loans[indexPath.row].name
        cell.countryLabel.text = loans[indexPath.row].country
        cell.useLabel.text = loans[indexPath.row].use
        cell.amountLabel.text = "$\(loans[indexPath.row].amount)"
        return cell
    }
    
    func getLatestLoans() {
        guard let loanUrl = URL(string: kivaLoanURL) else {
            return
        }
        
        let request = URLRequest(url: loanUrl)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, request, error) -> Void in
            if let error = error {
                print(error)
                return
            }
            
            // parse JSON data
            if let data = data {
                self.loans = self.parseJsonData(data: data)
                
                // reload table view in MAIN THREAD
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
        })
        
        // to initiate data task
        task.resume()
    }

    func parseJsonData(data: Data) -> [Loan2] {
        var loans = [Loan2]()
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
            
            // parse JSON data
            let jsonLoans = jsonResult?["loans"] as! [AnyObject]
            for jsonLoan in jsonLoans {
                let loan = Loan2()
                loan.name = jsonLoan["name"] as! String
                loan.amount = jsonLoan["loan_amount"] as! Int
                loan.use = jsonLoan["use"] as! String
                let location = jsonLoan["location"] as! [String:AnyObject]
                loan.country = location["country"] as! String
                loans.append(loan)
            }
        } catch {
            print(error)
        }
        return loans
    }
}
