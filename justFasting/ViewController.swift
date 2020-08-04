//
//  ViewController.swift
//  justFasting
//
//  Created by Cameron Krischel on 2/8/19.
//  Copyright © 2019 Cameron Krischel. All rights reserved.
//

import UIKit
import QuartzCore

let defaults = UserDefaults.standard
// TODO: MAKE SLIGHTLY TINY ROUNDED CORNERS FOR MORE AESTHETIC APP
class ViewController: UIViewController
{
    let menuLayer = CAGradientLayer()   // Gradient shapelayer for popup menus when editing/cancelling/deleting
    var dur1 = UILabel(),
        dur2 = UILabel(),
        dur3 = UILabel(),
        dur4 = UILabel(),
        dur5 = UILabel(),
        dur6 = UILabel(),
        dur7 = UILabel()
    var layerArray = [CALayer]()
    var pageNumber = 0, fastNumber = 0, fastNum = 0, currentMode = 0
    var editOld = UILabel()
    var buttonsArray = [UIButton](),
        saveStartArray = [UIButton](),
        saveStopArray = [UIButton]()
    let screenSize: CGRect = UIScreen.main.bounds   // Screen size so we can get width and height
    var screenWidth = CGFloat(0)
    var screenHeight = CGFloat(0)
    lazy var barWidth = Int(screenWidth*0.108695652)   // Sets width of bars on graph
    let timestamp = NSDate().timeIntervalSince1970  // Lets us make calculations for date/time
    var time = [0]  // Simple variable for incrementing
    var timer = Timer(), timer2 = Timer()   // Timer for time calculations
    var hours = 0, minutes = 0, seconds = 0 // Hr, min, sec for display
    //=====================================Stores data=====================================//
    var fastLog         = ["","","","","","","","","","","","","",""],
        rawFastLog      = ["","","","","","","","","","","","","",""],
        fastGraph       = [-1,-1,-1,-1,-1,-1,-1]
    var currentlyFasting = ["0"]
    var currentDate = NSDate()
    var saveDate = [0]
    var trueGoal = [82800]
    var myGoal = 2
    lazy var bottomHeight = Int(screenHeight*0.747282609)  // Sets top and bottom heights of the graph
    lazy var topHeight = Int(screenHeight*0.366847826) // just a placeholder, will be changed
    let copyFastGraph = defaults.array(forKey: "savedGraph")  as? [Int] ?? [Int](),
        copyFastLog = defaults.stringArray(forKey: "savedLog") ?? [String](),
        copyRawFastLog = defaults.stringArray(forKey: "savedRawLog") ?? [String](),
        copyCurrentlyFasting = defaults.stringArray(forKey: "savedBool") ?? [String](),
        copySaveDate = defaults.array(forKey: "savedDate")  as? [Int] ?? [Int](),
        copyTrueGoal = defaults.array(forKey: "savedGoal")  as? [Int] ?? [Int](),
        copyTime = defaults.array(forKey: "savedTime")  as? [Int] ?? [Int]()
    //=====================================Colors=====================================//
    let lightRed = UIColor(red: 255/255.0, green: 104/255.0, blue: 104/255.0, alpha: 1),
        lightBlue = UIColor(red: 113/255.0, green: 175/255.0, blue: 255/255.0, alpha: 1),
        darkRed = UIColor(red: 196/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1),
        darkBlue = UIColor(red: 0/255.0, green: 74/255.0, blue: 255/255.0, alpha: 1),
        topColor = UIColor(red: 214/255.0, green: 103/255.0, blue: 118/255.0, alpha: 1),
        bottomColor = UIColor(red: 254/255.0, green: 111/255.0, blue: 74/255.0, alpha: 1),
        beige = UIColor(red: 231/255.0, green: 228/255.0, blue: 156/255.0, alpha: 1),
        topRec = UIColor(red: 142/255.0, green: 203/255.0, blue: 209/255.0, alpha: 1),
        lowRec = UIColor(red: 229/255.0, green: 227/255.0, blue: 156/255.0, alpha: 1),
        topLine = UIColor(red: 213/255.0, green: 213/255.0, blue: 213/255.0, alpha: 1),
        lowLine = UIColor(red: 150/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1),
        topMenu = UIColor(red: 142/255.0, green: 203/255.0, blue: 209/255.0, alpha: 1),
        bottomMenu = UIColor(red: 229/255.0, green: 227/255.0, blue: 156/255.0, alpha: 1)
    //=====================================outlets and actions=====================================//
    @IBOutlet weak var csvLabel: UIButton!
    @IBAction func exportCSV(_ sender: Any)
    {
        let fileName = "myFasts.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Time Started,Fast Duration\n"
        if(rawFastLog.count > 0)
        {
            for i in 0...(rawFastLog.count - 1)
            {
                csvText.append(contentsOf: rawFastLog[i] + "\n")
                print("CSV: " + String(i))
            }
            do
            {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                if let popOver = vc.popoverPresentationController
                {
                    popOver.sourceView = self.view
                    popOver.sourceRect = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight/8)
                }
                vc.excludedActivityTypes = [
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.postToTencentWeibo,
                    UIActivity.ActivityType.postToTwitter,
                    UIActivity.ActivityType.postToFacebook,
                    UIActivity.ActivityType.openInIBooks
                ]
                present(vc, animated: true, completion: nil)
                print("Created CSV")
            }
            catch
            {
                print("Failed to create file")
                print("\(error)")
            }
        }
        else
        {
            print("No Data to Export")
        }
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var editStartPickerLabel: UIDatePicker!
    @IBOutlet weak var cancelStartLabel: UIButton!
    @IBAction func cancelNewStart(_ sender: Any)
    {
        pickDateLabel.sendActions(for: .touchUpInside)
    }
    @IBOutlet weak var saveNewStartLabel: UIButton!
    @IBAction func saveNewStart(_ sender: Any)
    {
        if(Int(datePicker.date.timeIntervalSince1970) <= Int(NSDate().timeIntervalSince1970))
        {
            saveDate[0] = Int(datePicker.date.timeIntervalSince1970)    // If current time is selected, it shifts to nearest second
            defaults.set(saveDate,          forKey: "savedDate")
            datePicker.isHidden = true
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = true
            }
            datePicker.date = NSDate() as Date
            saveNewStartLabel.isHidden = true
            cancelStartLabel.isHidden = true
            editOld.isHidden = true
            menuLayer.isHidden = true
            displayGoal()
        }
    }
    @IBOutlet weak var pickDateLabel: UIButton!
    @IBAction func pickDate(_ sender: Any)
    {
        if(datePicker.isHidden == true)
        {
            datePicker.date = NSDate(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(time[0])) as Date
            datePicker.isHidden = false
            editOld.isHidden = false
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            menuLayer.isHidden = false
            CATransaction.commit()
            
            editOld.text = "Edit Current Fast Start Time"
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = false
            }
            saveNewStartLabel.isHidden = false
            cancelStartLabel.isHidden = false
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = false
            }
        }
        else if(datePicker.isHidden == false)
        {
            datePicker.isHidden = true
            editOld.isHidden = true
            menuLayer.isHidden = true
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = true
            }
            
            saveNewStartLabel.isHidden = true
            cancelStartLabel.isHidden = true
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = true
            }
        }
    }
    @IBOutlet weak var cancelDelete: UIButton!
    @IBOutlet weak var confirmDelete: UIButton!
    @IBAction func cancelDeleteAction(_ sender: Any)
    {
        print("Fast Number: " + String(fastNumber + 7*pageNumber))
        cancelDelete.isHidden = true
        confirmDelete.isHidden = true
        editOld.isHidden = true
        menuLayer.isHidden = true
        menuLayer.frame = CGRect(x: 0, y: Int(screenHeight*0.5), width: Int(screenWidth), height: Int(screenHeight*0.5))
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
    }
    @IBAction func confirmDeleteAction(_ sender: Any)
    {
        print("Fast Number: " + String(fastNumber + 7 * pageNumber))
        if(fastLog[fastNumber + 7*pageNumber] == "")
        {
            print("empty fast")
        }
        else
        {
            fastGraph.remove(at: fastNumber + 7*pageNumber)
            fastLog.remove(at: fastNumber + 7*pageNumber)
            rawFastLog.remove(at: fastNumber + 7*pageNumber)
            fastLog.append("")
            rawFastLog.append("")
            fastGraph.append(-1)
            defaults.set(fastGraph,         forKey: "savedGraph")
            defaults.set(fastLog,           forKey: "savedLog")
            defaults.set(rawFastLog,        forKey: "savedRawLog")
            displayLog()
            displayGraph()
        }
        cancelDelete.isHidden = true
        confirmDelete.isHidden = true
        editOld.isHidden = true
        menuLayer.isHidden = true
        menuLayer.frame = CGRect(x: 0, y: Int(screenHeight*0.5), width: Int(screenWidth), height: Int(screenHeight*0.5))
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var confirmLabel: UIButton!
    @IBOutlet weak var cancelLabel: UIButton!
    @IBAction func confirmEnd(_ sender: Any)
    {
        myButton.isUserInteractionEnabled = true
        myButton.sendActions(for: .touchUpInside)
        menuLayer.isHidden = true
        confirmLabel.isHidden = true
        cancelLabel.isHidden = true
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
    }
    @IBAction func cancelEnd(_ sender: Any)
    {
        myButton.isUserInteractionEnabled = true
        currentMode = 0
        myButton.setTitle("Stop Fast", for: [])
        menuLayer.isHidden = true
        confirmLabel.isHidden = true
        cancelLabel.isHidden = true
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var fast1: UILabel!
    @IBOutlet weak var fast2: UILabel!
    @IBOutlet weak var fast3: UILabel!
    @IBOutlet weak var fast4: UILabel!
    @IBOutlet weak var fast5: UILabel!
    @IBOutlet weak var fast6: UILabel!
    @IBOutlet weak var fast7: UILabel!
    @IBOutlet weak var sevenFasts: UILabel!
    @IBOutlet weak var supr: UILabel!
    @IBOutlet weak var goalLine: UILabel!
    @IBOutlet weak var started: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var editStartLabel: UILabel!
    @IBOutlet weak var editStopLabel: UILabel!
    @IBOutlet weak var editDeleteLabel: UILabel!
    @IBOutlet weak var currentFast: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var toggleLabel: UIButton!
    @IBAction func toggleMode(_ sender: Any)
    {
        if(timerLabel.isHidden)
        {
            timerLabel.isHidden = false
            remainingLabel.isHidden = true
        }
        else
        {
            timerLabel.isHidden = true
            remainingLabel.isHidden = false
            currentFast.text = "REMAINING TIME"
        }
    }
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var startActual: UILabel!
    @IBOutlet weak var goalActual: UILabel!
    @IBOutlet weak var setGoal: UILabel!
    @IBOutlet weak var fastSlideName: UISlider!
    @IBAction func fastSlider(_ sender: UISlider)
    {
        trueGoal[0] = Int(sender.value)*3600
        defaults.set(trueGoal,          forKey: "savedGoal")
        displayGraph()
    }
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var myButton: UIButton!
    @IBAction func start(_ sender: UIButton)    // When the start button is pushed
    {
        defaults.set(saveDate,           forKey: "savedDate")
        currentFast.text = "ELAPSED TIME"
        if(currentlyFasting[0] == "0")  // If we are not currently fasting
        {
            timer2.invalidate()
            pickDateLabel.isHidden = false
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.action), userInfo: nil, repeats: true)
            sender.setTitle("Stop Fast", for: [])
            currentlyFasting[0] = "1"
            defaults.set(fastGraph,         forKey: "savedGraph")
            defaults.set(fastLog,           forKey: "savedLog")
            defaults.set(rawFastLog,        forKey: "savedRawLog")
            defaults.set(currentlyFasting,  forKey: "savedBool")
            if(saveDate[0] == 0)
            {
                saveDate[0] = Int(NSDate().timeIntervalSince1970)
            }
            defaults.set(trueGoal,          forKey: "savedGoal")
            defaults.set(saveDate,          forKey: "savedDate")
            defaults.set(time,              forKey: "savedTime")
        }
        else if(currentlyFasting[0] == "1") // If we are currently fasting
        {
            if(currentMode != 2)
            {
                currentMode += 1
                sender.setTitle("End Fast?", for: [])
                cancelLabel.isHidden = false
                confirmLabel.isHidden = false
                myButton.isUserInteractionEnabled = false
                for i in 0...buttonsArray.count-1
                {
                    buttonsArray[i].isUserInteractionEnabled = false
                }
            }
            if(currentMode == 2)
            {
                currentMode = 0
                myButton.isUserInteractionEnabled = true
                pickDateLabel.isHidden = true
                datePicker.isHidden = true
                for i in 0...buttonsArray.count-1
                {
                    buttonsArray[i].isUserInteractionEnabled = true
                }
                datePicker.date = NSDate() as Date
                saveNewStartLabel.isHidden = true
                cancelStartLabel.isHidden = true
                timer2 = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateStartTime), userInfo: nil, repeats: true)
                defaults.set(trueGoal,          forKey: "savedGoal")
                fastSlideName.setValue(Float(trueGoal[0]/3600), animated: false)
                updateGraph()
                updateLog()
                displayLog()
                displayGraph()
                timer.invalidate()
                time[0] = 0
                
                let hours = Int(time[0]) / 3600
                let minutes = Int(time[0]) / 60 % 60
                let seconds = Int(time[0]) % 60
                let token = setGoal.text!.components(separatedBy: " ")
                let hoursRemaining = Int(Int(token[0])!*3600 - time[0]) / 3600
                let minutesRemaining = Int(Int(token[0])!*3600 - time[0]) / 60 % 60
                let secondsRemaining = Int(Int(token[0])!*3600 - time[0]) % 60
                
                timerLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
                remainingLabel.text = String(format:"%02i:%02i:%02i", hoursRemaining, minutesRemaining, secondsRemaining)
                sender.setTitle("Start Fast", for: [])
                currentlyFasting[0] = "0"
                defaults.set(fastGraph,         forKey: "savedGraph")
                defaults.set(fastLog,           forKey: "savedLog")
                defaults.set(rawFastLog,        forKey: "savedRawLog")
                defaults.set(currentlyFasting,  forKey: "savedBool")
                saveDate[0] = 0
                defaults.set(saveDate,          forKey: "savedDate")
                defaults.set(time,              forKey: "savedTime")
            }
        }
    }
    //=====================================My Functions=====================================//
    @objc func editFast(_ sender: UIButton)
    {
        editStart(sender)
    }
    @objc func editStart(_ sender: UIButton)
    {
        fastNumber = Int((sender.frame.minY-screenHeight*0.787)+1) / Int(screenHeight*0.0298913043 + 1.0)
        if(fastLog[fastNumber + 7*pageNumber] != "" && rawFastLog[fastNumber + 7*pageNumber] != "")
        {
            let rawDateFormatter2 = DateFormatter()
            rawDateFormatter2.locale = Locale(identifier: "en_US_POSIX")
            rawDateFormatter2.dateFormat = "yyyyMMdd hh:mm:ss a"
            rawDateFormatter2.amSymbol = "AM"
            rawDateFormatter2.pmSymbol = "PM"
            
//            let unparsedLog = fastLog[fastNumber + 7*pageNumber]
            let unparsedRawLog = rawFastLog[fastNumber + 7*pageNumber]
            
            let delimiter = ","
            let token = unparsedRawLog.components(separatedBy: delimiter)
            
            let delimiter2 = "   "
            let displayToken = fastLog[fastNumber + 7*pageNumber].components(separatedBy: delimiter2)
            
            let myDate = rawDateFormatter2.date(from: String(token[0]))
            
            let startDate = Int((myDate?.timeIntervalSince1970)!)
//            let endDate = startDate + Int(token[1])!
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "EE, M/dd, h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
//            let endDateString: String = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(endDate)))

            let durDelimiter = ","
            let rawDurationString = rawFastLog[fastNumber + 7*pageNumber].components(separatedBy: durDelimiter)
            
            let rawDuration = Int(rawDurationString[1])
            let hours = rawDuration! / 3600
            let minutes = rawDuration! / 60 % 60
            let seconds = rawDuration! % 60
            if(hours<1)
            {
                editOld.text = "Start Date: " + "\(displayToken[0])" + "\nDuration: " + "\(minutes)" + "min " + "\(seconds)" + "sec"
            }
            else
            {
                editOld.text = "Start Date: " + "\(displayToken[0])" + "\nDuration: " + "\(hours)" + "hr " + "\(minutes)" + "min "
            }
            editStartPickerLabel.isHidden = false
            saveStartArray[0].isHidden = false
            saveStartArray[1].isHidden = false
            editOld.isHidden = false
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            menuLayer.isHidden = false
            CATransaction.commit()
            editStartPickerLabel.setDate(myDate!, animated: false)
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = false
            }
        }
    }
    @objc func editStop(_ sender: UIButton)
    {
        fastNumber = Int((sender.frame.minY-screenHeight*0.787)+1) / Int(screenHeight*0.0298913043 + 1.0)
        if(fastLog[fastNumber + 7*pageNumber] != "" && rawFastLog[fastNumber + 7*pageNumber] != "")
        {
            let rawDateFormatter2 = DateFormatter()
            rawDateFormatter2.locale = Locale(identifier: "en_US_POSIX")
            rawDateFormatter2.dateFormat = "yyyyMMdd hh:mm:ss a"
            rawDateFormatter2.amSymbol = "AM"
            rawDateFormatter2.pmSymbol = "PM"
            
//            let unparsedLog = fastLog[fastNumber + 7*pageNumber]
            let unparsedRawLog = rawFastLog[fastNumber + 7*pageNumber]
            
            let delimiter = ","
            let token = unparsedRawLog.components(separatedBy: delimiter)
            
            let delimiter2 = "   "
//            let displayToken = fastLog[fastNumber + 7*pageNumber].components(separatedBy: delimiter2)
            
            let myDate = rawDateFormatter2.date(from: String(token[0]))
            
            //print(unparsedRawLog)
            let startDate = Int((myDate?.timeIntervalSince1970)!)
            let endDate = startDate + Int(token[1])!
            //print("End Date: " + "\(endDate)")
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "EE, M/dd, h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            
            // New date value based on datePicker
            let endDateString: String = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(endDate)))
            let endDateActual = Date(timeIntervalSince1970: TimeInterval(endDate))
            
            let durDelimiter = ","
            let rawDurationString = rawFastLog[fastNumber + 7*pageNumber].components(separatedBy: durDelimiter)
            
            let rawDuration = Int(rawDurationString[1])
            let hours = rawDuration! / 3600
            let minutes = rawDuration! / 60 % 60
            let seconds = rawDuration! % 60
            if(hours<1)
            {
                editOld.text = "End Date: " + "\(endDateString)" + "\nDuration: " + "\(minutes)" + "min " + "\(seconds)" + "sec"
            }
            else
            {
                editOld.text = "End Date: " + "\(endDateString)" + "\nDuration: " + "\(hours)" + "hr " + "\(minutes)" + "min "
            }
            editStartPickerLabel.isHidden = false
            saveStartArray[1].isHidden = false
            saveStopArray[0].isHidden = false
            editOld.isHidden = false
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            menuLayer.isHidden = false
            CATransaction.commit()
            
            editStartPickerLabel.setDate(endDateActual, animated: false)
            for i in 0...buttonsArray.count-1
            {
                buttonsArray[i].isUserInteractionEnabled = false
            }
        }
    }
    @objc func editDelete(_ sender: UIButton)
    {
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = false
        }
        fastNumber = Int((sender.frame.minY-screenHeight*0.787)+1) / Int(screenHeight*0.0298913043 + 1.0)
        if(editOld.isHidden == true)
        {
            editOld.isHidden = false
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            menuLayer.frame = CGRect(x: 0, y: Int(screenHeight*0.5), width: Int(screenWidth), height: Int(screenHeight + screenWidth)/6)
            menuLayer.isHidden = false
            CATransaction.commit()
            
            cancelDelete.isHidden = false
            confirmDelete.isHidden = false
            if(fastLog[fastNumber + 7*pageNumber] == "")
            {
                editOld.text = "Fast is empty."
            }
            else
            {
                editOld.text = "Delete this fast?\n" + "\(fastLog[fastNumber + 7*pageNumber])"
            }
        }
        else
        {
            editOld.isHidden = true
            menuLayer.isHidden = true
            cancelDelete.isHidden = true
            confirmDelete.isHidden = true
        }
    }
    @objc func scrollDown()
    {
        if(fastLog[(pageNumber+1)*7] != "")
        {
            pageNumber += 1
        }
        sevenFasts.text = "FASTS " + String(7*pageNumber+1) + " - " + String(7*pageNumber+7)
        displayLog()
        displayGraph()
    }
    @objc func scrollUp()
    {
        if(pageNumber > 0)
        {
            pageNumber -= 1
        }
        sevenFasts.text = "FASTS " + String(7*pageNumber+1) + " - " + String(7*pageNumber+7)
        displayLog()
        displayGraph()
    }
    @objc func saveOldStart()
    {
        let myNewDate = editStartPickerLabel.date                         // GOOD
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EE, M/dd, h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        // New date value based on datePicker
        let newDateString: String = dateFormatter.string(from: myNewDate)    // GOOD
        // Getting the original duration value
        let delimiter2 = "Duration: "
        let displayToken = editOld.text!.components(separatedBy: delimiter2)
        let myDuration = displayToken[1]
        let durationToken = myDuration.components(separatedBy: " ")
        let fixedDuration = durationToken[0] + durationToken[1] // Getting the original duration in the proper units of time
        let delimiter4 = " "
        let twoHalves = myDuration.components(separatedBy: delimiter4)
        let firstHalf = twoHalves[0]
        let secondHalf = twoHalves[1]
        let rawDurationString = rawFastLog[fastNumber + 7*pageNumber].components(separatedBy: ",")
        let myOldDuration = Int(rawDurationString[1])                 // GOOD
        
        // Getting the *complete* original date value from raw fast because formatted fast doesn't have all the data
        let myOldRawFastLog = rawFastLog[fastNumber + 7*pageNumber]
        let rawDelimiter = ","
        let oldRawDate = myOldRawFastLog.components(separatedBy: rawDelimiter)

        let rawDateFormatter2 = DateFormatter()
        rawDateFormatter2.locale = Locale(identifier: "en_US_POSIX")
        rawDateFormatter2.dateFormat = "yyyyMMdd hh:mm:ss a"
        rawDateFormatter2.amSymbol = "AM"
        rawDateFormatter2.pmSymbol = "PM"

        let myOldDate = rawDateFormatter2.date(from: oldRawDate[0])     // GOOD?
        let myNewDuration = myOldDate!.timeIntervalSince1970 - (myNewDate.timeIntervalSince1970) + Double(myOldDuration!)
        let myNewHours = Int(myNewDuration) / 3600
        let myNewMinutes = Int(myNewDuration) / 60 % 60
        let myNewSeconds = Int(myNewDuration) % 60
        var myNewDurationString = ""
        if(myNewHours<1)
        {
            myNewDurationString =  "\(myNewMinutes)" + "min " + "\(myNewSeconds)" + "sec"
        }
        else
        {
            myNewDurationString = "\(myNewHours)" + "hr " + "\(myNewMinutes)" + "min "
        }
        let completeString = newDateString + "   " + String(myNewDurationString)//newDuration
      
        fastLog.remove(at: fastNumber + 7*pageNumber)
        fastLog.insert(completeString, at: fastNumber + 7*pageNumber)
        defaults.set(fastLog, forKey: "savedLog")
        
        let rawDateFormatterCommit = DateFormatter()
        rawDateFormatterCommit.locale = Locale(identifier: "en_US_POSIX")
        rawDateFormatterCommit.dateFormat = "yyyyMMdd hh:mm:ss a"
        rawDateFormatterCommit.amSymbol = "AM"
        rawDateFormatterCommit.pmSymbol = "PM"
        
        let currentRawDateStringCommit: String = rawDateFormatterCommit.string(from: myNewDate)
        rawFastLog.remove(at: fastNumber + 7*pageNumber)
        rawFastLog.insert("\(currentRawDateStringCommit)" + "," + "\(Int(myNewDuration))", at: fastNumber + 7*pageNumber)
        defaults.set(rawFastLog, forKey: "savedRawLog")
        fastGraph[fastNumber + 7*pageNumber] = Int(myNewDuration)
        defaults.set(fastGraph,         forKey: "savedGraph")
        displayLog()
        displayGraph()
        editStartPickerLabel.isHidden = true
        saveStartArray[0].isHidden = true
        saveStartArray[1].isHidden = true
        saveStopArray[0].isHidden = true
        editOld.isHidden = true
        menuLayer.isHidden = true
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
    }
    @objc func saveOldEnd()
    {
        let dateFormatter = DateFormatter() // Old Start Date  // GOOD
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EE, M/dd, h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        let rawDateFormatterCommit = DateFormatter()
        rawDateFormatterCommit.locale = Locale(identifier: "en_US_POSIX")
        rawDateFormatterCommit.dateFormat = "yyyyMMdd hh:mm:ss a"
        rawDateFormatterCommit.amSymbol = "AM"
        rawDateFormatterCommit.pmSymbol = "PM"
//        let ogStart = fastLog[fastNumber + 7*pageNumber].components(separatedBy: "   ")
        let ogRawStart = rawFastLog[fastNumber + 7*pageNumber].components(separatedBy: ",")
        let myOldStart = rawDateFormatterCommit.date(from: String(ogRawStart[0]))
        let myNewEnd = editStartPickerLabel.date
        let myNewDuration = myNewEnd.timeIntervalSince1970 - myOldStart!.timeIntervalSince1970
        let myNewHours = Int(myNewDuration) / 3600
        let myNewMinutes = Int(myNewDuration) / 60 % 60
        let myNewSeconds = Int(myNewDuration) % 60
        var myNewDurationString = ""
        if(myNewHours<1)
        {
            myNewDurationString =  "\(myNewMinutes)" + "min " + "\(myNewSeconds)" + "sec"
        }
        else
        {
            myNewDurationString = "\(myNewHours)" + "hr " + "\(myNewMinutes)" + "min "
        }
        let completeString = dateFormatter.string(from: myOldStart!) + "   " + String(myNewDurationString)
        fastLog.remove(at: fastNumber + 7*pageNumber)
        fastLog.insert(completeString, at: fastNumber + 7*pageNumber)
        defaults.set(fastLog, forKey: "savedLog")
        let currentRawDateStringCommit: String = rawDateFormatterCommit.string(from: myOldStart!)
        rawFastLog.remove(at: fastNumber + 7*pageNumber)
        rawFastLog.insert("\(currentRawDateStringCommit)" + "," + "\(Int(myNewDuration))", at: fastNumber + 7*pageNumber)
        defaults.set(rawFastLog, forKey: "savedRawLog")
        fastGraph[fastNumber + 7*pageNumber] = Int(myNewDuration)
        defaults.set(fastGraph,         forKey: "savedGraph")
        displayLog()
        displayGraph()
        editStartPickerLabel.isHidden = true
        saveStartArray[0].isHidden = true
        saveStartArray[1].isHidden = true
        saveStopArray[0].isHidden = true
        editOld.isHidden = true
        menuLayer.isHidden = true
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
    }
    @objc func cancelOldStart()
    {
        editStartPickerLabel.isHidden = true
        saveStartArray[0].isHidden = true
        saveStartArray[1].isHidden = true
        saveStopArray[0].isHidden = true
        editOld.isHidden = true
        menuLayer.isHidden = true
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
    }
    @objc func updateLog()
    {
        let hours = Int(time[0]) / 3600
        let minutes = Int(time[0]) / 60 % 60
        let seconds = Int(time[0]) % 60
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // TODO: fix incorrect spacing if the hour is 1 digit as opposed to 2
        // ex: 2:15 as opposed to 12:15 is spaced differently
        // Possible solution: 7 extra text boxes, split info.
        
        dateFormatter.dateFormat = "EE, M/dd, h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        let currentDateString: String = dateFormatter.string(from: date-TimeInterval(time[0]))
        if(hours<1)
        {
            fastLog.insert("\(currentDateString)" + "   " + "\(minutes)" + "min " + "\(seconds)" + "sec", at: 0)
        }
        else
        {
            fastLog.insert("\(currentDateString)" + "   " + "\(hours)" + "hr " + "\(minutes)" + "min ", at: 0)
        }// TODO FIX THE MIN
        let rawDateFormatter = DateFormatter()
        rawDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        rawDateFormatter.dateFormat = "yyyyMMdd hh:mm:ss a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        let currentRawDateString: String = rawDateFormatter.string(from: date-TimeInterval(time[0]))
        rawFastLog.insert("\(currentRawDateString)" + "," + "\(time[0])", at: 0)
    }
    @objc func updateGraph()
    {
        fastGraph.insert(Int(time[0]), at: 0)
    }
    @objc func displayLog()
    {
        fast1.text = fastLog[0 + 7*pageNumber].components(separatedBy: "   ").first
        fast2.text = fastLog[1 + 7*pageNumber].components(separatedBy: "   ").first
        fast3.text = fastLog[2 + 7*pageNumber].components(separatedBy: "   ").first
        fast4.text = fastLog[3 + 7*pageNumber].components(separatedBy: "   ").first
        fast5.text = fastLog[4 + 7*pageNumber].components(separatedBy: "   ").first
        fast6.text = fastLog[5 + 7*pageNumber].components(separatedBy: "   ").first
        fast7.text = fastLog[6 + 7*pageNumber].components(separatedBy: "   ").first
        dur1.text = fastLog[0 + 7*pageNumber].components(separatedBy: "   ").last
        dur2.text = fastLog[1 + 7*pageNumber].components(separatedBy: "   ").last
        dur3.text = fastLog[2 + 7*pageNumber].components(separatedBy: "   ").last
        dur4.text = fastLog[3 + 7*pageNumber].components(separatedBy: "   ").last
        dur5.text = fastLog[4 + 7*pageNumber].components(separatedBy: "   ").last
        dur6.text = fastLog[5 + 7*pageNumber].components(separatedBy: "   ").last
        dur7.text = fastLog[6 + 7*pageNumber].components(separatedBy: "   ").last
    }
    @objc func displayGraph()
    {
        if(layerArray.count > 0)    // Clear rectangle layers to stop lag
        {
            for _ in 0...layerArray.count-1
            {
                layerArray[0].removeFromSuperlayer()
                layerArray.remove(at: 0)
            }
        }
        topHeight = bottomHeight-Int(screenHeight*0.244565217)
        let diffHeight = bottomHeight - topHeight
        let xPos = Int(screenWidth*0.0458937198) + barWidth%5   // Gap from edges both sides
        
        // Draws beige bar under red portion//POP//
        drawBlankRect(myXPos: 7, myYPos: Int(screenHeight*0.283967391), myHeight: 7, myWidth: Int(screenWidth*0.966183575), myColor: beige)
        for k in 0..<7  // Draws lines between previous entries
        {
            drawBlankRect(myXPos: xPos-2, myYPos: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*k, myHeight: 1, myWidth: Int(screenWidth) - 2*(xPos-2), myColor: topLine)
        }
        // Draws lines next to 7 Fasts label
        drawBlankRect(myXPos: Int(sevenFasts.center.x*0.1), myYPos: Int(sevenFasts.center.y + 1), myHeight: 1, myWidth: Int(screenWidth*0.289855072), myColor: topLine)
        drawBlankRect(myXPos: Int(sevenFasts.center.x*1.32), myYPos: Int(sevenFasts.center.y + 1), myHeight: 1, myWidth: Int(screenWidth*0.289855072), myColor: topLine)
        myGoal = trueGoal[0]     // Sets maximum height of a bar
        for i in 0..<7//fastGraph.count
        {
            if(fastGraph[i + 7*pageNumber] > myGoal)    // If the bar is greater than goal, it adjusts all the bars accordingly.
            {
                myGoal = fastGraph[i + 7*pageNumber]
            }
        }
        let barSpace = (Int(screenWidth)-2*xPos - 7*barWidth)/6 // Calculates spacing between bars so it looks nice
        for j in 0..<7  // Draws bars and adjusts based on highest bar so it all stays proportional, including the goal line
        {
            drawRect(myXPos: Int(screenWidth)-xPos-barWidth*(j+1)-barSpace*j, myHeight: diffHeight*fastGraph[j + 7*pageNumber]/myGoal)
        }
        if(myGoal>trueGoal[0])
        {
            drawBlankRect(myXPos: xPos+2, myYPos: Int(bottomHeight-diffHeight*(trueGoal[0])/(myGoal)), myHeight: 1, myWidth: Int(screenWidth - CGFloat(2*(xPos+1))), myColor: lowLine)
            goalLine.center.y = CGFloat(bottomHeight - diffHeight*(trueGoal[0])/(myGoal) - Int(screenHeight*0.0203804348/2))
        }
        else
        {
            drawBlankRect(myXPos: xPos+2, myYPos: topHeight, myHeight: 1, myWidth: Int(screenWidth - CGFloat(2*(xPos+1))), myColor: lowLine)
            goalLine.center.y = CGFloat(topHeight-Int(screenHeight*0.0203804348/2))
        }
        goalLine.center.x = screenWidth*0.839190822
        displayGoal()
    }
    @objc func displayGoal()
    {
        setGoal.text = String(Int(trueGoal[0]/3600)) + " HR FAST"
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        startActual.text = formatter.string(from: Date(timeIntervalSince1970: Double(saveDate[0])))
        goalActual.text = formatter.string(from: Date(timeIntervalSince1970: Double(saveDate[0]))+Double(trueGoal[0]))
        let hours = Int(trueGoal[0]) / 3600
        let minutes = Int(trueGoal[0]) / 60 % 60
        if(hours<1)
        {
            if(minutes<1)
            {
                goalLabel.text = "GOAL:" + "\(trueGoal[0])" + "SEC"
                goalLine.text = "GOAL:" + "\(trueGoal[0])" + "SEC"
            }
            else
            {
                goalLabel.text = "GOAL:" + "\(trueGoal[0] / 60)" + "MIN"
                goalLine.text = "GOAL:" + "\(trueGoal[0] / 60)" + "MIN"
            }
        }
        else
        {
            if(hours == 1)
            {
                goalLabel.text = "GOAL:" + "\(trueGoal[0] / 3600)" + "HR"
                goalLine.text = "GOAL:" + "\(trueGoal[0] / 3600)" + "HR"
            }
            else
            {
                goalLabel.text = "GOAL:" + "\(trueGoal[0] / 3600)" + "HRS"
                goalLine.text = "GOAL:" + "\(trueGoal[0] / 3600)" + "HRS"
            }
        }
    }
    @objc func action()
    {
        if(saveDate.count > 0)
        {
            if(saveDate[0] != 0)
            {
                time[0] = Int(NSDate().timeIntervalSince1970) - saveDate[0]
            }
        }
        if(datePicker.date > NSDate() as Date)
        {
            datePicker.date = NSDate() as Date
        }
        displayLog()
        defaults.set(time,              forKey: "savedTime")
        defaults.set(fastGraph,         forKey: "savedGraph")
        defaults.set(fastLog,           forKey: "savedLog")
        defaults.set(rawFastLog,        forKey: "savedRawLog")
        defaults.set(currentlyFasting,  forKey: "savedBool")
        defaults.set(trueGoal,          forKey: "savedGoal")
        let hours = Int(time[0]) / 3600
        let minutes = Int(time[0]) / 60 % 60
        let seconds = Int(time[0]) % 60
        timerLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        
        let token = setGoal.text!.components(separatedBy: " ")
        let hoursRem = Int(Int(token[0])!*3600 - time[0]) / 3600
        let minutesRem = Int(Int(token[0])!*3600 - time[0]) / 60 % 60
        let secondsRem = Int(Int(token[0])!*3600 - time[0]) % 60
        remainingLabel.text = String(format:"%02i:%02i:%02i", hoursRem, minutesRem, secondsRem)
    }
    @objc func updateStartTime()
    {
        if(currentlyFasting[0] == "0")
        {
            saveDate[0] = Int(NSDate().timeIntervalSince1970)
            defaults.set(saveDate,          forKey: "savedDate")
            displayGoal()
            if(rawFastLog[0] != "")
            {
                let rawDateFormatter2 = DateFormatter()
                rawDateFormatter2.locale = Locale(identifier: "en_US_POSIX")
                rawDateFormatter2.dateFormat = "yyyyMMdd hh:mm:ss a"
                rawDateFormatter2.amSymbol = "AM"
                rawDateFormatter2.pmSymbol = "PM"
                
                let unparsedRawLog = rawFastLog[0]
                let delimiter = ","
                let token = unparsedRawLog.components(separatedBy: delimiter)
                let myDate = rawDateFormatter2.date(from: String(token[0]))
                let startDate = Int((myDate?.timeIntervalSince1970)!)
                let endDate = startDate + Int(token[1])!
                
                let previousEndDate = Date(timeIntervalSince1970: TimeInterval(endDate))
                let currentDate = NSDate()
                let timeSinceLastFast = currentDate.timeIntervalSince1970 - previousEndDate.timeIntervalSince1970
                
                let hours = Int(timeSinceLastFast) / 3600
                let minutes = Int(timeSinceLastFast) / 60 % 60
                let seconds = Int(timeSinceLastFast) % 60
                
                timerLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
                if(!timerLabel.isHidden)
                {
                    currentFast.text = "TIME SINCE LAST FAST"
                }
            }
            else
            {
                let hours = Int(0) / 3600
                let minutes = Int(0) / 60 % 60
                let seconds = Int(0) % 60
                timerLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
                
                if(!timerLabel.isHidden)
                {
                    currentFast.text = "ELAPSED TIME"
                }
                else
                {
                    currentFast.text = "REMAINING TIME"
                }
            }
        }
        else
        {
            if(!timerLabel.isHidden)
            {
                currentFast.text = "ELAPSED TIME"
            }
            else
            {
                currentFast.text = "REMAINING TIME"
            }
        }
    }
    //=====================================viewDidLoad()=====================================//
    override func viewDidLoad()
    {
        super.viewDidLoad()

        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        self.view.backgroundColor = UIColor.black
        menuLayer.frame = CGRect(x: 0, y: Int(screenHeight*0.5), width: Int(screenWidth), height: Int(screenHeight*0.5))
        menuLayer.colors = [topMenu.cgColor, bottomMenu.cgColor]
        view.layer.insertSublayer(menuLayer, at: 0)
        menuLayer.zPosition = 2
        menuLayer.isHidden = true
        for i in 0...6  // Edit Start Buttons
        {
            let button = UIButton(frame: CGRect(x: screenWidth*42/64, y: (CGFloat(screenHeight*0.0298913043))*CGFloat(i) + screenHeight*0.787, width: screenWidth/16, height: screenHeight*0.025))
            button.backgroundColor = UIColor.clear
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
            button.setTitle("✎", for: .normal)
            button.setTitleColor(UIColor.blue, for: .normal)
            button.addTarget(self, action: #selector(editStart), for: .touchUpInside)
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.baselineAdjustment = .alignCenters
            button.titleLabel?.font = UIFont(name: ((button.titleLabel?.font.fontName)!), size: button.frame.height)
            self.view.addSubview(button)
            self.buttonsArray.append(button)
        }
        for i in 0...6  // Edit Stop Buttons
        {
            let button = UIButton(frame: CGRect(x: screenWidth*49.5/64, y: (CGFloat(screenHeight*0.0298913043))*CGFloat(i) + screenHeight*0.787, width: screenWidth/16, height: screenHeight*0.025))
            button.backgroundColor = UIColor.clear
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
            button.setTitle("✎", for: .normal)
            button.setTitleColor(UIColor.red, for: .normal)
            button.addTarget(self, action: #selector(editStop), for: .touchUpInside)
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.baselineAdjustment = .alignCenters
            button.titleLabel?.font = UIFont(name: ((button.titleLabel?.font.fontName)!), size: button.frame.height)
            self.view.addSubview(button)
            self.buttonsArray.append(button)
        }
        for i in 0...6  // Delete Buttons
        {
            let button = UIButton(frame: CGRect(x: screenWidth*57/64, y: (CGFloat(screenHeight*0.0298913043))*CGFloat(i) + screenHeight*0.787, width: screenWidth/16, height: screenHeight*0.025))
            button.backgroundColor = UIColor.clear
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
            button.setTitle("✕", for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(editDelete), for: .touchUpInside)
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.baselineAdjustment = .alignCenters
            button.titleLabel?.font = UIFont(name: ((button.titleLabel?.font.fontName)!), size: button.frame.height)
            self.view.addSubview(button)
            self.buttonsArray.append(button)
        }
        for i in 0...1  // Makes Green left/right arrows to page through past fasts
        {
            let size = CGFloat(1.5)
            if(i == 0)
            {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth*0.0416666667*size, height: screenHeight*0.025*size))
                button.backgroundColor = UIColor.white
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.black.cgColor
                button.setTitle("→", for: .normal)
                button.addTarget(self, action: #selector(scrollUp), for: .touchUpInside)
                button.setTitleColor(UIColor.green, for: .normal)
                button.layer.cornerRadius = 5
                button.center.x = screenWidth*0.952898551-(screenWidth*0.0416666667*size)/2
                button.center.y = screenHeight*0.456521739
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.baselineAdjustment = .alignCenters
                button.titleLabel?.font = UIFont(name: ((button.titleLabel?.font.fontName)!), size: button.frame.height)
                self.view.addSubview(button)
                self.buttonsArray.append(button)
            }
            else
            {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth*0.0416666667*size, height: screenHeight*0.025*size-1))
                button.backgroundColor = UIColor.white
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.black.cgColor
                button.setTitle("←", for: .normal)
                button.addTarget(self, action: #selector(scrollDown), for: .touchUpInside)
                button.setTitleColor(UIColor.green, for: .normal)
                button.layer.cornerRadius = 5
                button.center.x = screenWidth*0.0471014495+(screenWidth*0.0416666667*size)/2
                button.center.y = screenHeight*0.456521739
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.baselineAdjustment = .alignCenters
                button.titleLabel?.font = UIFont(name: ((button.titleLabel?.font.fontName)!), size: button.frame.height)
                self.view.addSubview(button)
                self.buttonsArray.append(button)
            }
        }
        // Finished
        let saveOldStartLabel = UIButton(frame: CGRect(x: screenWidth*3/4, y: screenHeight*4/6, width: screenWidth*1/4, height: screenHeight*1/12))
        saveOldStartLabel.isHidden = true
        saveOldStartLabel.backgroundColor = .clear
        saveOldStartLabel.setTitleColor(UIColor.black, for: .normal)
        saveOldStartLabel.setTitle("✓", for: .normal)
        saveOldStartLabel.layer.zPosition = 2
        saveOldStartLabel.addTarget(self, action: #selector(saveOldStart), for: .touchUpInside)
        saveOldStartLabel.titleLabel?.textAlignment = .center
        saveOldStartLabel.titleLabel?.baselineAdjustment = .alignCenters
        saveOldStartLabel.titleLabel?.font = UIFont(name: (saveOldStartLabel.titleLabel?.font.fontName)!, size: saveOldStartLabel.frame.width)
        self.view.addSubview(saveOldStartLabel)
        self.saveStartArray.append(saveOldStartLabel)
        // Finished
        let cancelOldStartLabel = UIButton(frame: CGRect(x: screenWidth*3/4, y: screenHeight*11/12, width: screenWidth*1/4, height: screenHeight*1/12))
        cancelOldStartLabel.isHidden = true
        cancelOldStartLabel.backgroundColor = .clear
        cancelOldStartLabel.setTitleColor(UIColor.black, for: .normal)
        cancelOldStartLabel.setTitle("✕", for: .normal)
        cancelOldStartLabel.layer.zPosition = 2
        cancelOldStartLabel.addTarget(self, action: #selector(cancelOldStart), for: .touchUpInside)
        cancelOldStartLabel.titleLabel?.textAlignment = .center
        cancelOldStartLabel.titleLabel?.baselineAdjustment = .alignCenters
        cancelOldStartLabel.titleLabel?.font = UIFont(name: (cancelOldStartLabel.titleLabel?.font.fontName)!, size: cancelOldStartLabel.frame.width)
        self.view.addSubview(cancelOldStartLabel)
        self.saveStartArray.append(cancelOldStartLabel)
        // Finished
        let saveOldStopLabel = UIButton(frame: CGRect(x: screenWidth*3/4, y: screenHeight*4/6, width: screenWidth*1/4, height: screenHeight*1/12))
        saveOldStopLabel.isHidden = true
        saveOldStopLabel.backgroundColor = .clear
        saveOldStopLabel.setTitleColor(UIColor.black, for: .normal)
        saveOldStopLabel.setTitle("✓", for: .normal)
        saveOldStopLabel.layer.zPosition = 2
        saveOldStopLabel.addTarget(self, action: #selector(saveOldEnd), for: .touchUpInside)
        saveOldStopLabel.titleLabel?.textAlignment = .center
        saveOldStopLabel.titleLabel?.baselineAdjustment = .alignCenters
        saveOldStopLabel.titleLabel?.font = UIFont(name: (saveOldStopLabel.titleLabel?.font.fontName)!, size: saveOldStopLabel.frame.width)
        self.view.addSubview(saveOldStopLabel)
        self.saveStopArray.append(saveOldStopLabel)
        // Hides picker so it isn't open when you initialize the app
        editStartPickerLabel.isHidden = true
        currentMode = 0
        cancelLabel.isHidden = true
        confirmLabel.isHidden = true
        datePicker.isHidden = true
        for i in 0...buttonsArray.count-1
        {
            buttonsArray[i].isUserInteractionEnabled = true
        }
        datePicker.backgroundColor = .clear
        datePicker.setValue(UIColor.black, forKey: "textColor")
        datePicker.frame = CGRect(x: 0, y: screenHeight*2/3, width: screenWidth, height: screenHeight*1/3)
        datePicker.layer.zPosition = 2
        pickDateLabel.isHidden = true
        editStartPickerLabel.backgroundColor = .clear
        editStartPickerLabel.setValue(UIColor.black, forKey: "textColor")
        editStartPickerLabel.frame = CGRect(x: 0, y: screenHeight*2/3, width: screenWidth, height: screenHeight*1/3)
        editStartPickerLabel.layer.zPosition = 2
        editStartPickerLabel.isHidden = true
        // Finished
        editOld.backgroundColor = .clear
        editOld.setValue(UIColor.black, forKey: "textColor")
        editOld.frame = CGRect(x: 0, y: screenHeight*3/6, width: screenWidth, height: screenHeight*1/6)
        editOld.layer.zPosition = 2
        editOld.text = "Edit Start Date"
        editOld.font = .systemFont(ofSize: editOld.frame.height/3)
        editOld.isHidden = true
        editOld.textAlignment = .center
        editOld.numberOfLines = 3
        editOld.adjustsFontSizeToFitWidth = true
        self.view.addSubview(editOld)
        // Finished
        saveNewStartLabel.isHidden = true
        saveNewStartLabel.backgroundColor = .clear
        saveNewStartLabel.setTitleColor(UIColor.black, for: .normal)
        saveNewStartLabel.frame = CGRect(x: screenWidth*3/4, y: screenHeight*4/6, width: screenWidth*1/4, height: screenHeight*1/12)
        saveNewStartLabel.layer.zPosition = 2
        saveNewStartLabel.setTitle("✓", for: .normal)
        saveNewStartLabel.titleLabel?.textAlignment = .center
        saveNewStartLabel.titleLabel?.baselineAdjustment = .alignCenters
        saveNewStartLabel.titleLabel?.font = UIFont(name: (saveNewStartLabel.titleLabel?.font.fontName)!, size: saveNewStartLabel.frame.width)
        // Finished
        cancelStartLabel.isHidden = true
        cancelStartLabel.backgroundColor = .clear
        cancelStartLabel.setTitleColor(UIColor.black, for: .normal)
        cancelStartLabel.frame = CGRect(x: screenWidth*3/4, y: screenHeight*11/12, width: screenWidth*1/4, height: screenHeight*1/12)
        cancelStartLabel.layer.zPosition = 2
        cancelStartLabel.setTitle("✕", for: .normal)
        cancelStartLabel.titleLabel?.textAlignment = .center
        cancelStartLabel.titleLabel?.baselineAdjustment = .alignCenters
        cancelStartLabel.titleLabel?.font = UIFont(name: (cancelStartLabel.titleLabel?.font.fontName)!, size: cancelStartLabel.frame.width)
        //=============================================Positions all elements==========================================//
        // Finished
        csvLabel.frame = CGRect(x: screenWidth*3/4, y: 0, width: round(screenWidth*0.2), height: round(screenHeight*0.02))
        csvLabel.center.x = screenWidth*7/8
        csvLabel.center.y = screenHeight*0.046875
        csvLabel.titleLabel?.textAlignment = .center
        csvLabel.titleLabel?.baselineAdjustment = .alignCenters
        csvLabel.titleLabel?.font = UIFont(name: ((csvLabel.titleLabel?.font.fontName)!), size: csvLabel.frame.height)
        // Finished
        supr.frame = CGRect(x: 0, y: 0, width: round(screenWidth*0.09178743961), height: round(screenHeight*0.0285326087))
        supr.center.x = screenWidth/2
        supr.center.y = screenHeight/24
        supr.textAlignment = .center
        supr.baselineAdjustment = .alignCenters
        supr.font = UIFont(name: (supr.font.fontName), size: supr.frame.height*0.75)
        // Finished
        currentFast.frame = CGRect(x: 0, y: 0, width: round(screenWidth*0.5), height: round(screenHeight*0.025))
        currentFast.center.x = screenWidth/2
        currentFast.center.y = screenHeight/8
        currentFast.textAlignment = .center
        currentFast.baselineAdjustment = .alignCenters
        currentFast.font = UIFont(name: (currentFast.font.fontName), size: currentFast.frame.height*0.8)
        // Finished
        timerLabel.frame = CGRect(x: 0, y: 0, width: round(screenWidth*0.6), height: round(screenHeight*0.058))
        timerLabel.center.x = screenWidth/2
        timerLabel.center.y = screenHeight*0.179347826
        timerLabel.textAlignment = .center
        timerLabel.baselineAdjustment = .alignCenters
        timerLabel.font = UIFont(name: (fast1.font.fontName), size: timerLabel.frame.height)
        // Finished
        remainingLabel.frame = CGRect(x: 0, y: 0, width: round(screenWidth*0.6), height: round(screenHeight*0.058))
        remainingLabel.center.x = timerLabel.center.x
        remainingLabel.center.y = timerLabel.center.y
        remainingLabel.textAlignment = .center
        remainingLabel.baselineAdjustment = .alignCenters
        remainingLabel.font = UIFont(name: (fast1.font.fontName), size: remainingLabel.frame.height)
        remainingLabel.isHidden = true
        // Finished
        toggleLabel.frame = CGRect(x: 0, y: 0, width: timerLabel.frame.width, height: timerLabel.frame.height)
        toggleLabel.center.x = timerLabel.center.x
        toggleLabel.center.y = timerLabel.center.y
        toggleLabel.titleLabel?.textAlignment = .center
        toggleLabel.titleLabel?.baselineAdjustment = .alignCenters
        // Finished
        startLabel.frame = CGRect(x: round(screenWidth*0.02057971), y: round(screenHeight*0.205), width: round(screenWidth*0.225), height: round(screenHeight*0.0203804348))
        startLabel.textAlignment = .left
        startLabel.baselineAdjustment = .alignCenters
        startLabel.font = UIFont(name: (startLabel.font.fontName), size: startLabel.frame.height)
        // Finished
        startActual.frame = CGRect(x: round(screenWidth*0.02057971), y: round(screenHeight*0.231657609), width: round(screenWidth*0.23), height: round(screenHeight*0.0366847826))
        startActual.textAlignment = .left
        startActual.baselineAdjustment = .alignCenters
        startActual.font = UIFont(name: (startActual.font.fontName), size: startActual.frame.height*0.85)
        // Finished
        goalLabel.frame = CGRect(x: round(screenWidth*(0.72942029)), y: round(screenHeight*0.205), width: round(screenWidth*0.25), height: round(screenHeight*0.0203804348))
        goalLabel.textAlignment = .right
        goalLabel.baselineAdjustment = .alignCenters
        goalLabel.font = UIFont(name: (goalLabel.font.fontName), size: goalLabel.frame.height)
        // Finished
        goalActual.frame = CGRect(x: round(screenWidth*0.74942029), y: round(screenHeight*0.231657609), width: round(screenWidth*0.23), height: round(screenHeight*0.0366847826))
        goalActual.textAlignment = .right
        goalActual.baselineAdjustment = .alignCenters
        goalActual.font = UIFont(name: (goalActual.font.fontName), size: goalActual.frame.height*0.85)
        // Finished
        pickDateLabel.frame = CGRect(x: round(startActual.frame.maxX), y: startActual.frame.minY - startActual.frame.height*0.1, width: startActual.frame.height*1.2, height: startActual.frame.height*1.2)
        pickDateLabel.titleLabel?.textAlignment = .center
        pickDateLabel.titleLabel?.baselineAdjustment = .alignCenters
        pickDateLabel.titleLabel?.font = UIFont(name: ((pickDateLabel.titleLabel?.font.fontName)!), size: pickDateLabel.frame.height)
        self.buttonsArray.append(pickDateLabel)
        // Finished
        setGoal.frame = CGRect(x: round(screenWidth*0.75442029), y: round(screenHeight*0.231657609), width: round(screenWidth*0.3), height: round(screenHeight*0.04))
        setGoal.center.x = screenWidth/2
        setGoal.center.y = screenHeight*0.236413043
        setGoal.textAlignment = .center
        setGoal.baselineAdjustment = .alignCenters
        setGoal.font = UIFont(name: (setGoal.font.fontName), size: setGoal.frame.height*0.8)
        // Finished
        fastSlideName.frame = CGRect(x: round(screenWidth*0.75442029), y: round(screenHeight*0.231657609), width: round(screenWidth*0.285024155), height: round(screenHeight*0.0407608696))
        fastSlideName.center.x = round(screenWidth/2)
        fastSlideName.center.y = round(screenHeight*0.328804347)
        // Finished
        buttonLabel.frame = CGRect(x: 0, y: 0, width: round(screenWidth*0.905797101), height: round(screenHeight*0.0774456522))
        buttonLabel.center.x = round(screenWidth/2)
        buttonLabel.center.y = round(screenHeight*0.388586957)
        buttonLabel.layer.borderWidth = 1.0
        buttonLabel.layer.borderColor = UIColor.black.cgColor
        buttonLabel.layer.masksToBounds = true
        buttonLabel.backgroundColor = beige
        buttonLabel.layer.cornerRadius = 0
        // Finished
        myButton.setTitle("Start Fast", for: .normal)
        myButton.titleLabel?.textAlignment = .center
        myButton.titleLabel?.font = UIFont(name: (myButton.titleLabel?.font.fontName)!, size: myButton.frame.height*0.75)
        self.buttonsArray.append(myButton)
        // Finished
        cancelLabel.setTitle("✕", for: .normal)
        cancelLabel.layer.zPosition = 2
        cancelLabel.backgroundColor = .clear
        cancelLabel.frame = CGRect(x: 0, y: 0, width: buttonLabel.frame.height*1.1, height: buttonLabel.frame.height*1.1)
        cancelLabel.center.x = screenWidth*1.5/10
        cancelLabel.center.y = buttonLabel.center.y
        cancelLabel.titleLabel?.textAlignment = .center
        cancelLabel.titleLabel?.baselineAdjustment = .alignCenters
        cancelLabel.titleLabel?.font = UIFont(name: (saveOldStartLabel.titleLabel?.font.fontName)!, size: cancelLabel.frame.height)
        // Finished
        confirmLabel.setTitle("✓", for: .normal)
        confirmLabel.layer.zPosition = 2
        confirmLabel.backgroundColor = .clear
        confirmLabel.frame = CGRect(x: 0, y: 0, width: buttonLabel.frame.height*1.2, height: buttonLabel.frame.height*1.2)
        confirmLabel.center.x = screenWidth*8.5/10
        confirmLabel.center.y = buttonLabel.center.y
        confirmLabel.titleLabel?.textAlignment = .center
        confirmLabel.titleLabel?.baselineAdjustment = .alignCenters
        confirmLabel.titleLabel?.font = UIFont(name: (saveOldStartLabel.titleLabel?.font.fontName)!, size: confirmLabel.frame.height)
        // Finished
        cancelDelete.setTitle("✕", for: .normal)
        cancelDelete.layer.zPosition = 2
        cancelDelete.backgroundColor = .clear
        cancelDelete.frame = CGRect(x: 0, y: screenHeight*4/6, width: screenWidth*1/4, height: screenHeight*1/12)
        cancelDelete.center.x = screenWidth/4
        cancelDelete.center.y = screenHeight*4/6 + screenWidth/12
        cancelDelete.setTitleColor(UIColor.black, for: .normal)
        cancelDelete.isHidden = true
        cancelDelete.titleLabel?.textAlignment = .center
        cancelDelete.titleLabel?.baselineAdjustment = .alignCenters
        cancelDelete.titleLabel?.font = UIFont(name: (cancelDelete.titleLabel?.font.fontName)!, size: cancelDelete.frame.width)
        // Finished
        confirmDelete.setTitle("✓", for: .normal)
        confirmDelete.layer.zPosition = 2
        confirmDelete.backgroundColor = .clear
        confirmDelete.frame = CGRect(x: 0, y: screenHeight*4/6, width: screenWidth*1/4, height: screenHeight*1/12)
        confirmDelete.center.x = screenWidth*3/4
        confirmDelete.center.y = screenHeight*4/6 + screenWidth/12
        confirmDelete.setTitleColor(UIColor.black, for: .normal)
        confirmDelete.isHidden = true
        confirmDelete.titleLabel?.textAlignment = .center
        confirmDelete.titleLabel?.baselineAdjustment = .alignCenters
        confirmDelete.titleLabel?.font = UIFont(name: (confirmDelete.titleLabel?.font.fontName)!, size: confirmDelete.frame.width)
        // Finished
        sevenFasts.frame = CGRect(x: 0, y: 0, width: round(screenWidth*0.3), height: round(screenHeight*0.025))
        sevenFasts.center.x = screenWidth/2
        sevenFasts.center.y = screenHeight*0.456521739
        sevenFasts.text = "FASTS " + String(7*pageNumber+1) + " - " + String(7*pageNumber+7)
        sevenFasts.textAlignment = .center
        sevenFasts.baselineAdjustment = .alignCenters
        sevenFasts.font = UIFont(name: (sevenFasts.font.fontName), size: sevenFasts.frame.height*0.775)
        // Finished
        goalLine.frame = CGRect(x: 0, y: 0, width: round(screenWidth*0.18115942), height: round(screenHeight*0.0203804348))
        goalLine.textAlignment = .center
        goalLine.baselineAdjustment = .alignCenters
        goalLine.font = UIFont(name: (goalLabel.font.fontName), size: goalLine.frame.height*0.8)
        // Finished
        started.frame = CGRect(x: 0, y: 0, width: round(screenWidth*0.171497585), height: round(screenHeight*0.0203804348))
        started.center.x = screenWidth*2.125/16
        started.center.y = screenHeight*0.77
        started.textAlignment = .center
        started.baselineAdjustment = .alignCenters
        started.font = UIFont(name: (started.font.fontName), size: started.frame.height*0.8)
        // Finished
        let xPos = Int(screenWidth*0.0458937198) + barWidth%5
        duration.frame = CGRect(x: 0, y: 0, width: round(screenWidth*0.147342995), height: round(screenHeight*0.0203804348))
        duration.center.x = CGFloat(xPos-2 + Int(screenWidth*0.55*0.65)) + round(screenWidth*0.147342995)/2
        duration.center.y = started.center.y
        duration.textAlignment = .center
        duration.baselineAdjustment = .alignCenters
        duration.font = UIFont(name: (duration.font.fontName), size: duration.frame.height*0.8)
        // Finished
        editStartLabel.frame = CGRect(x: 0, y: 0, width: round(screenWidth*0.0917874396), height: round(screenHeight*0.0203804348))
        editStartLabel.center.x = screenWidth*44/64
        editStartLabel.center.y = started.center.y
        editStartLabel.textAlignment = .center
        editStartLabel.baselineAdjustment = .alignCenters
        editStartLabel.font = UIFont(name: (duration.font.fontName), size: editStartLabel.frame.height*0.8)
        // Finished
        editStopLabel.frame = CGRect(x: 0, y: 0, width: round(screenWidth*0.077294686), height: round(screenHeight*0.0203804348))
        editStopLabel.center.x = screenWidth*51.5/64
        editStopLabel.center.y = started.center.y
        editStopLabel.textAlignment = .center
        editStopLabel.baselineAdjustment = .alignCenters
        editStopLabel.font = UIFont(name: (duration.font.fontName), size: editStopLabel.frame.height*0.8)
        // Finished
        editDeleteLabel.frame = CGRect(x: 0, y: 0, width: round(screenWidth*0.106280193), height: round(screenHeight*0.0203804348))
        editDeleteLabel.center.x = screenWidth*59/64
        editDeleteLabel.center.y = started.center.y
        editDeleteLabel.textAlignment = .center
        editDeleteLabel.baselineAdjustment = .alignCenters
        editDeleteLabel.font = UIFont(name: (duration.font.fontName), size: editDeleteLabel.frame.height*0.8)
        // Finished
        fast1.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*0, width: Int(screenWidth*0.55*0.65), height: (Int(screenHeight*0.0298913043)+1))
        fast1.textAlignment = .left
        fast1.baselineAdjustment = .alignCenters
        fast1.font = UIFont(name: fast1.font.fontName, size: fast1.frame.height*0.54)
        // Finished
        fast2.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*1, width: Int(screenWidth*0.55*0.65), height: (Int(screenHeight*0.0298913043)+1))
        fast2.textAlignment = .left
        fast2.baselineAdjustment = .alignCenters
        fast2.font = UIFont(name: fast2.font.fontName, size: fast2.frame.height*0.54)
        // Finished
        fast3.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*2, width: Int(screenWidth*0.55*0.65), height: (Int(screenHeight*0.0298913043)+1))
        fast3.textAlignment = .left
        fast3.baselineAdjustment = .alignCenters
        fast3.font = UIFont(name: fast3.font.fontName, size: fast3.frame.height*0.54)
        // Finished
        fast4.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*3, width: Int(screenWidth*0.55*0.65), height: (Int(screenHeight*0.0298913043)+1))
        fast4.textAlignment = .left
        fast4.baselineAdjustment = .alignCenters
        fast4.font = UIFont(name: fast4.font.fontName, size: fast4.frame.height*0.54)
        // Finished
        fast5.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*4, width: Int(screenWidth*0.55*0.65), height: (Int(screenHeight*0.0298913043)+1))
        fast5.textAlignment = .left
        fast5.baselineAdjustment = .alignCenters
        fast5.font = UIFont(name: fast5.font.fontName, size: fast5.frame.height*0.54)
        // Finished
        fast6.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*5, width: Int(screenWidth*0.55*0.65), height: (Int(screenHeight*0.0298913043)+1))
        fast6.textAlignment = .left
        fast6.baselineAdjustment = .alignCenters
        fast6.font = UIFont(name: fast6.font.fontName, size: fast6.frame.height*0.54)
        // Finished
        fast7.frame = CGRect(x: xPos-2, y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*6, width: Int(screenWidth*0.55*0.65), height: (Int(screenHeight*0.0298913043)+1))
        fast7.textAlignment = .left
        fast7.baselineAdjustment = .alignCenters
        fast7.font = UIFont(name: fast7.font.fontName, size: fast7.frame.height*0.54)
        // Finished
        dur1.frame = CGRect(x: xPos-2 + Int(screenWidth*0.55*0.65), y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*0, width: Int(screenWidth*0.55*0.4), height: (Int(screenHeight*0.0298913043)+1))
        dur1.textAlignment = .left
        dur1.baselineAdjustment = .alignCenters
        dur1.font = UIFont(name: fast1.font.fontName, size: dur1.frame.height*0.54)
        self.view.addSubview(dur1)
        // Finished
        dur2.frame = CGRect(x: xPos-2 + Int(screenWidth*0.55*0.65), y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*1, width: Int(screenWidth*0.55*0.4), height: (Int(screenHeight*0.0298913043)+1))
        dur2.textAlignment = .left
        dur2.baselineAdjustment = .alignCenters
        dur2.font = UIFont(name: fast1.font.fontName, size: dur2.frame.height*0.54)
        self.view.addSubview(dur2)
        // Finished
        dur3.frame = CGRect(x: xPos-2 + Int(screenWidth*0.55*0.65), y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*2, width: Int(screenWidth*0.55*0.4), height: (Int(screenHeight*0.0298913043)+1))
        dur3.textAlignment = .left
        dur3.baselineAdjustment = .alignCenters
        dur3.font = UIFont(name: fast1.font.fontName, size: dur3.frame.height*0.54)
        self.view.addSubview(dur3)
        // Finished
        dur4.frame = CGRect(x: xPos-2 + Int(screenWidth*0.55*0.65), y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*3, width: Int(screenWidth*0.55*0.4), height: (Int(screenHeight*0.0298913043)+1))
        dur4.textAlignment = .left
        dur4.baselineAdjustment = .alignCenters
        dur4.font = UIFont(name: fast1.font.fontName, size: dur4.frame.height*0.54)
        self.view.addSubview(dur4)
        // Finished
        dur5.frame = CGRect(x: xPos-2 + Int(screenWidth*0.55*0.65), y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*4, width: Int(screenWidth*0.55*0.4), height: (Int(screenHeight*0.0298913043)+1))
        dur5.textAlignment = .left
        dur5.baselineAdjustment = .alignCenters
        dur5.font = UIFont(name: fast1.font.fontName, size: dur5.frame.height*0.54)
        self.view.addSubview(dur5)
        // Finished
        dur6.frame = CGRect(x: xPos-2 + Int(screenWidth*0.55*0.65), y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*5, width: Int(screenWidth*0.55*0.4), height: (Int(screenHeight*0.0298913043)+1))
        dur6.textAlignment = .left
        dur6.baselineAdjustment = .alignCenters
        dur6.font = UIFont(name: fast1.font.fontName, size: dur6.frame.height*0.54)
        self.view.addSubview(dur6)
        // Finished
        dur7.frame = CGRect(x: xPos-2 + Int(screenWidth*0.55*0.65), y: Int(started.center.y) + Int(screenHeight*0.0163043478) + 1 + (Int(screenHeight*0.0298913043)+1)*6, width: Int(screenWidth*0.55*0.4), height: (Int(screenHeight*0.0298913043)+1))
        dur7.textAlignment = .left
        dur7.baselineAdjustment = .alignCenters
        dur7.font = UIFont(name: fast1.font.fontName, size: dur7.frame.height*0.54)
        self.view.addSubview(dur7)
        // If the NSDefaults aren't empty, copy them
        if(copyCurrentlyFasting.count != 0)
        {
            currentlyFasting = copyCurrentlyFasting
        }
        if(copyFastGraph.count != 0)
        {
            fastGraph = copyFastGraph
        }
        if(copyFastLog.count != 0)
        {
            fastLog = copyFastLog
        }
        if(copyRawFastLog.count != 0)
        {
            rawFastLog = copyRawFastLog
        }
        if(copySaveDate.count != 0)
        {
            saveDate = copySaveDate
        }
        if(copyTime.count != 0)
        {
            time = copyTime
        }
        if(copyTrueGoal.count != 0)
        {
            trueGoal = copyTrueGoal
        }
        if(currentlyFasting[0] == "1")
        {
            if(saveDate.count > 0)
            {
                if(saveDate[0] != 0)
                {
                    time[0] = Int(NSDate().timeIntervalSince1970) - saveDate[0]
                }
            }
            currentlyFasting[0] = "0"
            defaults.set(fastGraph,         forKey: "savedGraph")
            defaults.set(fastLog,           forKey: "savedLog")
            defaults.set(rawFastLog,        forKey: "savedRawLog")
            defaults.set(currentlyFasting,  forKey: "savedBool")
            myButton.sendActions(for: .touchUpInside)
        }
        let tempHr = Int(time[0]) / 3600
        let tempMin = Int(time[0]) / 60 % 60
        let tempSec = Int(time[0]) % 60
        let token = setGoal.text!.components(separatedBy: " ")
        let remainHr = Int(Int(token[0])!*3600 - time[0]) / 3600
        let remainMin = Int(Int(token[0])!*3600 - time[0]) / 60 % 60
        let remainSec = Int(Int(token[0])!*3600 - time[0]) % 60
        timerLabel.text = String(format:"%02i:%02i:%02i", tempHr, tempMin, tempSec)
        remainingLabel.text = String(format:"%02i:%02i:%02i", remainHr, remainMin, remainSec)
        fastSlideName.setValue(Float(trueGoal[0]/3600), animated: false)
        displayGraph()
        displayLog()
        let layer2 = CAGradientLayer()  //derp
        layer2.frame = CGRect(x: 0, y: 0, width: Int(screenWidth), height: Int(screenHeight*0.304347826))
        layer2.maskedCorners = []//[.layerMaxXMinYCorner, .layerMinXMinYCorner]
        layer2.cornerRadius = layer2.frame.width/32
        layer2.colors = [topColor.cgColor, bottomColor.cgColor]
        view.layer.insertSublayer(layer2, at: 0)
        layer2.zPosition = -1
        let layer3 = CAGradientLayer()  //derp
        layer3.frame = CGRect(x: 0.0, y: layer2.frame.maxY, width: screenWidth, height: screenHeight - layer2.frame.height)
        layer3.maskedCorners = []//[.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        layer3.cornerRadius = layer2.frame.width/32
        layer3.colors = [UIColor.white.cgColor, UIColor.white.cgColor]
        view.layer.insertSublayer(layer3, at: 0)
        layer3.zPosition = -1
        // Makes sure start time is always up to date
        timer2 = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateStartTime), userInfo: nil, repeats: true)
    }
    //=====================================Rect Functions=====================================//
    func drawRect(myXPos: Int, myHeight: Int)
    {
        var tempHeight = myHeight
        if(tempHeight < 0)
        {
            tempHeight = 0
        }
        let rectangle = UIBezierPath.init()
        let width = 25
        let height = tempHeight
        let xPos = myXPos
        let yPos = bottomHeight
        rectangle.move(to: CGPoint.init(x: xPos, y: yPos))
        rectangle.addLine(to: CGPoint.init(x: xPos+width, y: yPos))
        rectangle.addLine(to: CGPoint.init(x: xPos+width, y: yPos-height))
        rectangle.addLine(to: CGPoint.init(x: xPos, y: yPos-height))
        rectangle.close()
        let layer2 = CAGradientLayer()
        layer2.frame = CGRect(x: xPos, y: yPos-height, width: barWidth, height: height)
        layer2.colors = [topRec.cgColor, lowRec.cgColor]
        layer2.zPosition = -1
        view.layer.addSublayer(layer2)
        layerArray.append(layer2)
    }
    func drawBlankRect(myXPos: Int, myYPos: Int, myHeight: Int, myWidth: Int, myColor: UIColor)
    {
        var tempHeight = myHeight
        if(tempHeight<0)
        {
            tempHeight = 0
        }
        let rectangle = UIBezierPath.init()
        let width = myWidth
        let height = tempHeight
        let xPos = myXPos
        let yPos = myYPos
        rectangle.move(to: CGPoint.init(x: xPos, y: yPos))
        rectangle.addLine(to: CGPoint.init(x: xPos+width, y: yPos))
        rectangle.addLine(to: CGPoint.init(x: xPos+width, y: yPos-height))
        rectangle.addLine(to: CGPoint.init(x: xPos, y: yPos-height))
        rectangle.close()
        let rec = CAShapeLayer.init()
        rec.path = rectangle.cgPath
//        self.view.backgroundColor = UIColor.white
        rec.fillColor = myColor.cgColor
        self.view.layer.addSublayer(rec)
        rec.zPosition = -1
        layerArray.append(rec)
    }
}
