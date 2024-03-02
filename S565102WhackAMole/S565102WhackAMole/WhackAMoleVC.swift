//
//  WhackAHoleVC.swift
//  S565102WhackAHole
//
//  Created by Alasakani Prem Rakesh on 2/16/24.
//

import UIKit
import AudioToolbox
import Lottie


class WhackAMoleVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        timerSV.layer.cornerRadius = 5.0
        highScoreSV.layer.cornerRadius = 5.0
        scoreSV.layer.cornerRadius = 5.0
        timerSV.layer.borderWidth = 2.0
        highScoreSV.layer.borderWidth = 2.0
        scoreSV.layer.borderWidth = 2.0
        timerSV.layer.borderColor = UIColor.black.cgColor
        highScoreSV.layer.borderColor = UIColor.black.cgColor
        scoreSV.layer.borderColor = UIColor.black.cgColor
        
        for button in gameBtnCLCTN {
            button.layer.cornerRadius = 5.0
            button.layer.borderWidth = 2.0
            button.layer.borderColor = UIColor.black.cgColor
            button.contentVerticalAlignment = .fill
            button.contentHorizontalAlignment = .fill
            button.imageView?.contentMode = .scaleToFill
            button.isEnabled=false
//            button.isUserInteractionEnabled=false
            }
        if let highScore = UserDefaults.standard.object(forKey: "highScore") as? Int {
         highScoreLBL.text = "\(highScore)"
           } else {
               highScoreLBL.text = "0"
           }
    }
    var timer: Timer?
    var score = 0
    var moleWhackedCount = 0
    var moleCount = 0
    var explosionCount = 0
    var bombCount = 0
    var remainingTime=60
    @IBOutlet var gameBtnCLCTN: [UIButton]!
    
    @IBOutlet weak var launchLAV: LottieAnimationView!{
        didSet{
            launchLAV.animation = LottieAnimation.named("Launch")
            launchLAV.alpha = 1.0
            launchLAV.loopMode = .playOnce
            launchLAV.play{ [weak self] _ in
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut]){
                    self?.launchLAV.alpha = 0.0
                }
                
            }
        }
    }
    @IBOutlet weak var timerLBL: UILabel!
    @IBOutlet weak var highScoreLBL: UILabel!
    @IBOutlet weak var scoreLBL: UILabel!
    @IBOutlet weak var startBTN: UIButton!
    @IBOutlet weak var timerSV: UIStackView!
    @IBOutlet weak var highScoreSV: UIStackView!
    @IBOutlet weak var scoreSV: UIStackView!
    @IBAction func onClickGameBTN(_ sender: UIButton) {
        if sender.currentImage == UIImage(named: "mole") {
               sender.setImage(UIImage(named: "moleHit"), for: .normal)
               score += 10
               moleWhackedCount += 1
               scoreLBL.text = "\(score)"
               playSystemSound(soundID: 1001)
           } else if sender.currentImage == UIImage(named: "bomb") {
               sender.setImage(UIImage(named: "blast"), for: .normal)
               score -= 5
               explosionCount += 1
               scoreLBL.text = "\(score)"
               playSystemSound(soundID: 1322)
           }
           sender.isUserInteractionEnabled = true
    }
    @IBAction func onStart(_ sender: UIButton) {
        start();
    }
    @IBAction func onReset(_ sender: UIButton) {
        reset();
    }
    
    func start(){
        startBTN.setTitle(" ", for: .normal)
        startBTN.isUserInteractionEnabled = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
         self?.updateGame()
            }
            updateGame()
    }
    func reset() {
        playSystemSound(soundID: 1152)
        startBTN.setTitle("Start", for: .normal)
        score = 0
        moleWhackedCount = 0
        moleCount = 0
        explosionCount = 0
        bombCount = 0
        remainingTime=60
        
        for button in gameBtnCLCTN {
            button.setImage(UIImage(named: "hole"),for: .normal)
            button.isEnabled=false
            }
        startBTN.isUserInteractionEnabled=true
        timer?.invalidate()
        timer = nil
        timerLBL.text = "01:00"
        scoreLBL.text="0"
    }
    func updateGame() {
            if remainingTime > 0 {
                    remainingTime -= 1
                    timerLBL.text = String(format: "%02d:%02d", remainingTime / 60, remainingTime % 60)
                let randomButtonIndex = Int.random(in: 0..<gameBtnCLCTN.count)
                let button = gameBtnCLCTN[randomButtonIndex]
                button.isEnabled = true
                let randomNumber = Int.random(in: 1...100)
                if isPrime(number: randomNumber) {
                    button.setImage(UIImage(named: "bomb"), for: .normal)
                    bombCount += 1
                    
                } else {
                    button.setImage(UIImage(named: "mole"), for: .normal)
                    moleCount += 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if button.currentImage == UIImage(named: "mole") || button.currentImage == UIImage(named: "bomb") || button.currentImage == UIImage(named: "blast")  || button.currentImage == UIImage(named: "moleHit"){
                        button.setImage(UIImage(named: "hole"), for: .normal)
                        button.isEnabled = false
                    }
                    if self.score > UserDefaults.standard.integer(forKey: "highScore") {
                        UserDefaults.standard.set(self.score, forKey: "highScore")
                        self.highScoreLBL.text = "\(self.score)"
                        }
                }
                
                

                

            } else {
                timer?.invalidate()
                timer = nil
                remainingTime = 0
                let alert = UIAlertController(title: "Time's Up! ⏱️", message: "Your score is \(score).\nYou have tapped on the mole \(moleWhackedCount) times out of \(moleCount).\nYou have tapped on the bomb \(explosionCount) times out of \(bombCount).", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                reset()
                }
        }
//
    func isPrime(number: Int) -> Bool {
        if number <= 1 {
            return false
        }
        if number <= 3 {
            return true
        }
        if number % 2 == 0 || number % 3 == 0 {
            return false
        }
        var i = 5
        while i * i <= number {
            if number % i == 0 || number % (i + 2) == 0 {
                return false
            }
            i += 6
        }
        return true
    }
    func playSystemSound(soundID: SystemSoundID) {
            AudioServicesPlaySystemSound(soundID)
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
