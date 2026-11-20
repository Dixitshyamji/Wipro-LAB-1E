import Foundation
class Teacher {
    let name: String
    let employeeID: String
    weak var classroom: Classroom?    

    init(name: String, employeeID: String) {
        self.name       = name
        self.employeeID = employeeID
        print("[Teacher] \(name) (ID: \(employeeID)) created.")
    }

    deinit {
        print("[Teacher] \(name) deallocated. ✅")
    }

    func introduce() {
        if let room = classroom {
            print("I am \(name), teaching in \(room.roomNumber).")
        } else {
            print("I am \(name), currently unassigned to a classroom.")
        }
    }
}

class Classroom {
    let roomNumber: String
    let capacity: Int
    var assignedTeacher: Teacher?       

    init(roomNumber: String, capacity: Int) {
        self.roomNumber = roomNumber
        self.capacity   = capacity
        print("[Classroom] Room \(roomNumber) (capacity: \(capacity)) created.")
    }

    deinit {
        print("[Classroom] Room \(roomNumber) deallocated. ✅")
    }

    func assignTeacher(_ teacher: Teacher) {
        assignedTeacher = teacher
        teacher.classroom = self        
        print("[Classroom] Assigned \(teacher.name) to room \(roomNumber).")
    }

    func describe() {
        let teacherName = assignedTeacher?.name ?? "No teacher"
        print("[Classroom] Room \(roomNumber) | Capacity: \(capacity) | Teacher: \(teacherName)")
    }
}


func runTask3() {
    print("\n========== TASK 3 ==========")

    var teacher: Teacher?   = Teacher(name: "Prof. Dixit", employeeID: "T-001")
    var room: Classroom?    = Classroom(roomNumber: "A-101", capacity: 30)

    room?.assignTeacher(teacher!)
    teacher?.introduce()
    room?.describe()

    print("\n[Releasing Classroom…]")
    room = nil              
    teacher?.introduce()   

    print("\n[Releasing Teacher…]")
    teacher = nil          
}
