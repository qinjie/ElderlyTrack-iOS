//
//  FAQController.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 10/3/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit

class FAQController: UITableViewController {
    
    var faqs = FAQ.FAQFromBundle()
    
    let moreInfoText = "Select For More Info >"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        setup()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(forName: .UIContentSizeCategoryDidChange, object: .none, queue: OperationQueue.main) { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    private func setup(){
        tableView.register(UINib(nibName: "FAQTableViewCell",bundle: nil), forCellReuseIdentifier: "cell")
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return faqs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as!FAQTableViewCell
        let faq = faqs[indexPath.row]
        
        cell.questionLabel.text = faq.question
        cell.answerLabel.text = faq.answer
        
        switch indexPath.item{
        case 0:
            cell.backgroundColor = UIColor(red: 0.85, green: 0.93, blue: 0.95, alpha: 1.0)
            cell.questionLabel.textColor = UIColor(red: 0.01, green: 0.18, blue: 0.25, alpha: 1.0)
        case 1:
            cell.backgroundColor = UIColor(red: 0.58, green: 0.86, blue: 0.85, alpha: 1.0)
            cell.questionLabel.textColor = UIColor(red: 0.01, green: 0.18, blue: 0.25, alpha: 1.0)
        case 2:
            cell.backgroundColor = UIColor(red: 0.1, green: 0.65, blue: 0.72, alpha: 1.0)
            cell.questionLabel.textColor = UIColor.white
        case 3:
            cell.backgroundColor = UIColor(red: 0.01, green: 0.18, blue: 0.25, alpha: 1.0)
            cell.questionLabel.textColor = UIColor.white
        default:
            cell.backgroundColor = UIColor.white
            cell.questionLabel.textColor = UIColor.white
        }
        
        cell.questionLabel.textAlignment = .center
        cell.answerLabel.textColor = cell.questionLabel.textColor
        cell.answerLabel.backgroundColor = cell.backgroundColor
        cell.selectionStyle = .none
        
        cell.answerLabel.text = faq.isExpanded ? faq.answer : faq.answer
        cell.answerLabel.isHidden = faq.isExpanded ? false : true
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FAQTableViewCell else {return}
        
        var faq = faqs[indexPath.row]
        
        faq.isExpanded = !faq.isExpanded
        faqs[indexPath.row] = faq
        
        cell.answerLabel.text = faq.isExpanded ? faq.answer : faq.answer
        cell.answerLabel.isHidden = faq.isExpanded ? false : true
        
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
