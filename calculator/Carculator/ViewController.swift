//
//  ViewController.swift
//  Carculator
//
//  Created by 김범수 on 2021/08/20.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    
    
    var resultNum = 0
    var tmpNum = 0
    var op = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        roundButton(zeroButton, oneButton, twoButton, threeButton, fourButton, fiveButton, sixButton, sevenButton, eightButton, nightButton, plusButton, minusButton, multiplyButton, divideButton, remainderButton, equalButton, clearButton, pointButton, signButton)
        resultLabel.text = "\(resultNum)"
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let price = Double("10005000")!
        let result = numberFormatter.string(from: NSNumber(value:price))!
        print(result)
        
    }

    
    func roundButton(_ buttons: UIButton...) {
        for button in buttons {
            if button == zeroButton {
                button.layer.cornerRadius = 40
            } else {
                button.layer.cornerRadius = 0.5 * button.bounds.size.width
            }
        }
    }
 
    func onNum(num: Int) {
        if num == 0 {
            if op == 0 {
                resultNum = resultNum == 0 ? 0 : resultNum * 10
            } else {
                tmpNum = tmpNum == 0 ? 0 : tmpNum * 10
            }
        } else {
            if op == 0 {
                resultNum = resultNum * 10 + num
            } else {
                tmpNum = tmpNum * 10 + num
            }
        }
        
        resultLabel.text = resultNum.convertNum()
    }
    
    func onOperator(button: UIButton, num: Int) {
        self.op = num
    }
    func initVal(button: UIButton?) {
        resultNum = 0
        op = 0
        tmpNum = 0
    }
    func calculate() {
        switch op {
        case 1:
            resultNum = resultNum + tmpNum
        case 2:
            resultNum = resultNum - tmpNum
        case 3:
            resultNum = resultNum * tmpNum
        case 4:
            resultNum = resultNum / tmpNum
        case 5:
            resultNum = resultNum % tmpNum
        default:
            resultNum = 0
        }
        resultLabel.text = resultNum.convertNum()

        op = 0
        tmpNum = 0
    }
    
    
    @IBAction func onZero(_ sender: Any) {
        onNum(num: 0)
    }
    @IBAction func onOne(_ sender: Any) {
        onNum(num: 1)
    }
    @IBAction func onTwo(_ sender: Any) {
        onNum(num: 2)
    }
    @IBAction func onThree(_ sender: Any) {
        onNum(num: 3)
    }
    @IBAction func onFour(_ sender: Any) {
        onNum(num: 4)
    }
    @IBAction func onFive(_ sender: Any) {
        onNum(num: 5)
    }
    @IBAction func onSix(_ sender: Any) {
        onNum(num: 6)
    }
    @IBAction func onSeven(_ sender: Any) {
        onNum(num: 7)
    }
    @IBAction func onEight(_ sender: Any) {
        onNum(num: 8)
    }
    @IBAction func onNight(_ sender: Any) {
        onNum(num: 9)
    }
    
    @IBAction func onPlus(_ sender: Any) {
        onOperator(button: plusButton, num: 1)
    }
    @IBAction func onMinus(_ sender: Any) {
        onOperator(button: minusButton, num: 2)
    }
    @IBAction func onMultyply(_ sender: Any) {
        onOperator(button: multiplyButton, num: 3)
    }
    @IBAction func onDevide(_ sender: Any) {
        onOperator(button: divideButton, num: 4)
    }
    @IBAction func onRemainder(_ sender: Any) {
        onOperator(button: remainderButton, num: 5)
    }
    @IBAction func onEqual(_ sender: Any) {
        calculate()
    }
    @IBAction func onClear(_ sender: Any) {
        resultNum = 0
        op = 0
        tmpNum = 0
        resultLabel.text = "\(resultNum)"
    }
    @IBAction func onSign(_ sender: Any) {
        resultNum = -resultNum
        resultLabel.text = "\(resultNum)"
    }
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var zeroButton: UIButton!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var nightButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var divideButton: UIButton!
    @IBOutlet weak var remainderButton: UIButton!
    @IBOutlet weak var equalButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var pointButton: UIButton!
    @IBOutlet weak var signButton: UIButton!
}

extension Int {
    func convertNum() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let price = Double("\(self)")!
        let result = numberFormatter.string(from: NSNumber(value:price))!
        return result
    }
}
