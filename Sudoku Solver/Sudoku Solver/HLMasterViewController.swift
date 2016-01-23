//
//  HLMasterViewController.swift
//  Sudoku Solver
//
//  Created by Matthew Homer on 1/23/16.
//  Copyright © 2016 Homer Labs. All rights reserved.
//

import UIKit

class HLMasterViewController: UITableViewController {

    let titles : [String]
    
/*    override init(style: UITableViewStyle)  {
        titles = ["123", "321"]
        super.init(style: style)
    }   */

    required init?(coder aDecoder: NSCoder) {
        titles = ["Overview", "Find Sets"]
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HLCell", forIndexPath: indexPath)

        cell.textLabel?.text = titles[indexPath.row]

        return cell
    }
    

/*    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
