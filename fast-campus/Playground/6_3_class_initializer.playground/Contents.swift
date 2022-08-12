import UIKit

struct Grade {
    var letter: Character
    var points: Double
    var credits: Double
}

class Person {
    var firstName: String
    var lastName: String

    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }

    func printMyName() {
        print("My name is \(firstName) \(lastName)")
    }
}

class Student: Person {
    var grades: [Grade] = []
    
    override init(firstName: String, lastName: String)
    {
        super.init(firstName: firstName, lastName: lastName)
    }
    convenience init(student: Student)
    {
        self.init(firstName: student.firstName, lastName: student.lastName)
    }
}

// 학생인데 운동선수
class StudentAthlete: Student {
    var minimumTrainingTime: Int = 2
    var trainedTime: Int = 0
    var sports: [String]
    
    init(firstName: String, lastName: String, sports: [String])
    {
        self.sports = sports
        super.init(firstName: firstName, lastName: lastName)
    }
    
    convenience init(name: String)
    {
        self.init(firstName: name, lastName: "", sports: [])
    }
    
    func train() {
        trainedTime += 1
    }
}

class FootballPlayer: StudentAthlete {
    var footballTeam = "FC Swift"

    override func train() {
        trainedTime += 2
    }
}

let student1 = Student(firstName: "Beomsoo", lastName: "Kime")
let student2 = StudentAthlete(firstName: "Heung", lastName: "Son", sports: ["Football"])

let student3 = StudentAthlete(name: "Mike")

let student1_1 = Student(student: student1)
student1_1.printMyName()
