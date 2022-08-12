//
//  ViewController.swift
//  StopWatch
//
//  Created by 김범수 on 2021/08/19.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Variables
    let mainStopWatch: StopWatch = StopWatch()
    let lapStopWatch: StopWatch = StopWatch()
    var isPlay: Bool = false
    var laps: [String] = []
    
    // MARK: - UI Components
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var lapTimerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var lapButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - UI functions
    func updateTimer(stopwatch: StopWatch, label: UILabel) {
        stopwatch.counter += 0.035
        
        var minute: String
        if stopwatch.counter / 60 < 10 {
            minute = "0\((Int)(stopwatch.counter / 60))"
        } else {
            minute = "\((Int)(stopwatch.counter / 60))"
        }
        
        var second: String
        if stopwatch.counter.truncatingRemainder(dividingBy: 60) < 10 {
            second = "0" + String(format: "%0.2f", stopwatch.counter.truncatingRemainder(dividingBy: 60))
        } else {
            second = String(format: "%0.2f", stopwatch.counter.truncatingRemainder(dividingBy: 60))
        }
        
        label.text = minute + ":" + second
    }
    
    func resetTimer(stopwatch: StopWatch, label: UILabel) {
        stopwatch.timer.invalidate()
        stopwatch.counter = 0.0
        label.text = "00:00:00"
    }

    // MARK: - Actions
    @IBAction func onStart(_ sender: UIButton) {
        if !isPlay {
            mainStopWatch.timer = Timer.scheduledTimer(withTimeInterval: 0.035, repeats: true, block: {_ in
                self.updateTimer(stopwatch: self.mainStopWatch, label: self.timerLabel)
            })
            lapStopWatch.timer = Timer.scheduledTimer(withTimeInterval: 0.035, repeats: true, block: {_ in
                self.updateTimer(stopwatch: self.lapStopWatch, label: self.lapTimerLabel)
            })

            RunLoop.current.add(mainStopWatch.timer, forMode: RunLoop.Mode.common)
            RunLoop.current.add(lapStopWatch.timer, forMode: RunLoop.Mode.common)
            
            isPlay = true
            startButton.isSelected = true
            lapButton.isSelected = false
        } else {
            mainStopWatch.timer.invalidate()
            lapStopWatch.timer.invalidate()
            isPlay = false
            startButton.isSelected = false
            lapButton.isSelected = true
        }
    }
    
    @IBAction func onLap(_ sender: Any) {
        if !isPlay {
            resetTimer(stopwatch: mainStopWatch, label: timerLabel)
            resetTimer(stopwatch: lapStopWatch, label: lapTimerLabel)
            laps.removeAll()
            tableView.reloadData()
        } else {
            if let timeLabel = timerLabel.text {
                laps.append(timeLabel)
                tableView.reloadData()
                
                lapStopWatch.counter = 0.0
                resetTimer(stopwatch: lapStopWatch, label: lapTimerLabel)
                lapStopWatch.timer = Timer.scheduledTimer(withTimeInterval: 0.035, repeats: true, block: {_ in
                    self.updateTimer(stopwatch: self.lapStopWatch, label: self.lapTimerLabel)
                })
                RunLoop.current.add(lapStopWatch.timer, forMode: RunLoop.Mode.common)
            }

        }
    }
    
}

// MARK: - TableView DataSource / Delegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return laps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let lapCell = tableView.dequeueReusableCell(withIdentifier: "LapCell", for: indexPath) as? LapCell else { return UITableViewCell() }
        
        lapCell.lapCountLabel.text = "Lap \(laps.count - indexPath.row - 1)"
        lapCell.lapTimeLabel.text = laps[laps.count - indexPath.row - 1]
        
        return lapCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

class LapCell: UITableViewCell {
    
    @IBOutlet weak var lapCountLabel
        : UILabel!
    @IBOutlet weak var lapTimeLabel: UILabel!
}
