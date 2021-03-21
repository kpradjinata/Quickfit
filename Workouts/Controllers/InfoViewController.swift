//
//  InfoViewController.swift
//  Workouts
//
//  Created by Kevin Pradjinata on 3/20/21.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var back: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.isTranslucent = false
        back.layer.cornerRadius = 15

        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
