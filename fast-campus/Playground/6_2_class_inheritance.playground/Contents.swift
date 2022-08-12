import UIKit

// 처음 주어진 코드
//struct Grade {
//    var letter: Character
//    var points: Double
//    var credits: Double
//}
//
//class Person {
//    var firstName: String
//    var lastName: String
//
//    init(firstName: String, lastName: String) {
//        self.firstName = firstName
//        self.lastName = lastName
//    }
//
//    func printMyName() {
//        print("My name is \(firstName) \(lastName)")
//    }
//}
//
//class Student {
//    var grades: [Grade] = []
//
//    var firstName: String
//    var lastName: String
//
//    init(firstName: String, lastName: String) {
//        self.firstName = firstName
//        self.lastName = lastName
//    }
//
//    func printMyName() {
//        print("My name is \(firstName) \(lastName)")
//    }
//}


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
}


let jay = Person(firstName: "Jay", lastName: "Lee")
let jason = Student(firstName: "Jasson", lastName: "Lee")

jay.firstName
jason.firstName

jay.printMyName()
jason.printMyName()

let math = Grade(letter: "B", points: 8.5, credits: 3)
let history = Grade(letter: "A", points: 10.0, credits: 3)

jason.grades.append(math)
jason.grades.append(history)
//jay.grades

jason.grades.count

class StudentAthlete: Student
{
    var minimumTrainingTime: Int = 2
    var trainedTime: Int = 0
    
    func train()
    {
        trainedTime += 1
    }
}

class FootballPlayer: StudentAthlete
{
    var footballTeam = "FC Swift"
    
    override func train()
    {
        trainedTime += 2
    }
}

// Person > Student > Athelete > Football Player

var athlete1 = StudentAthlete(firstName: "Yeona", lastName: "Kim")
var athlete2 = FootballPlayer(firstName: "Heungmin", lastName: "Son")

athlete1.printMyName()
athlete2.printMyName()

athlete1.grades.append(math)
athlete2.grades.append(math)

athlete1.minimumTrainingTime
athlete2.minimumTrainingTime

athlete1.train()
athlete2.train()

athlete1.trainedTime
athlete2.trainedTime

athlete1 = athlete2 as StudentAthlete

athlete1.train()
athlete2.train()

athlete1.trainedTime
athlete2.trainedTime

athlete1.printMyName()
athlete2.printMyName()

//athlete1.footballTeam
athlete2.footballTeam

if let son = athlete1 as? FootballPlayer
{
    print("--> \(son.footballTeam)")
}
