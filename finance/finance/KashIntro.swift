//
//  KashIntro.swift
//  finance
//
//  Created by Emmett Shaughnessy on 4/19/22.
//

import UIKit

class KashIntro: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        runTimer(5)
    }
    
    
    
    //MARK: Timer
    func runTimer(_ totalTime: Int = 10){
        
        print("Timer Started")
        var timeLeft = totalTime
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            
            //This code runs every second
            print("Time Left: \(timeLeft)")
            timeLeft -= 1
            
            if timeLeft == 0 {
                //This code runs when the timer is up
                self.performSegue(withIdentifier: "moveToMain", sender: nil)
                timer.invalidate()
            }
            
        }//End of Timer
    }//End of restartTimer()
    
}
