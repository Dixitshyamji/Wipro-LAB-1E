// ============================================================
// Task 3: Two related reference types — Teacher & Classroom
//         Using weak/unowned only where ownership makes sense.
// ============================================================

import Foundation

// MARK: - Teacher (Reference Type)
/// A Teacher owns no Classroom — it only knows which one it teaches in.
/// Using `weak` avoids a strong retain cycle between Teacher and Classroom.
class Teacher {
    let name: String
    let employeeID: String
    weak var classroom: Classroom?      // ⬅ weak: Teacher does NOT own the Classroom

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

// MARK: - Classroom (Reference Type)
/// A Classroom strongly owns its assigned Teacher.
/// It is the "primary owner" in this relationship.
class Classroom {
    let roomNumber: String
    let capacity: Int
    var assignedTeacher: Teacher?       // ⬅ strong (default): Classroom OWNS the Teacher slot

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
        teacher.classroom = self        // back-reference — MUST be weak to avoid cycle
        print("[Classroom] Assigned \(teacher.name) to room \(roomNumber).")
    }

    func describe() {
        let teacherName = assignedTeacher?.name ?? "No teacher"
        print("[Classroom] Room \(roomNumber) | Capacity: \(capacity) | Teacher: \(teacherName)")
    }
}

// MARK: - Ownership Decision Rationale
/*
 ┌──────────────────────────────────────────────────────────────┐
 │  Ownership Decision                                          │
 │  Classroom ──(strong)──► Teacher slot                        │
 │  Teacher   ──(weak)────► Classroom                           │
 │                                                              │
 │  Why weak on Teacher.classroom?                              │
 │  • The Classroom logically owns the assignment, not the other│
 │    way around. If we used strong on both sides,              │
 │    neither object could ever be freed (retain cycle).        │
 │                                                              │
 │  Why NOT unowned?                                            │
 │  • A Teacher CAN exist without a Classroom (unassigned).     │
 │  • unowned would crash if the Classroom were deallocated     │
 │    while the Teacher still referenced it.                    │
 │  • weak + optional safely handles that case.                 │
 └──────────────────────────────────────────────────────────────┘
*/

// MARK: - Demo
func runTask3() {
    print("\n========== TASK 3 ==========")

    var teacher: Teacher?   = Teacher(name: "Prof. Dixit", employeeID: "T-001")
    var room: Classroom?    = Classroom(roomNumber: "A-101", capacity: 30)

    room?.assignTeacher(teacher!)
    teacher?.introduce()
    room?.describe()

    print("\n[Releasing Classroom…]")
    room = nil              // Classroom deallocated; Teacher.classroom becomes nil automatically
    teacher?.introduce()   // Safe — weak reference is now nil

    print("\n[Releasing Teacher…]")
    teacher = nil           // Teacher deallocated
}
