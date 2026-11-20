

import Foundation
class Student {
    let name: String
    var enrolledCourse: EnrolledCourse?   

    init(name: String) {
        self.name = name
        print("[Student] \(name) created.")
    }
    deinit { print("[Student] \(name) deallocated. ✅") }
}

class EnrolledCourse {
    let title: String
    var student: Student?                 

    init(title: String) {
        self.title = title
        print("[EnrolledCourse] '\(title)' created.")
    }
    deinit { print("[EnrolledCourse] '\(title)' deallocated. ✅") }
}

func demonstrateCycle() {
    print("\n--- A: Strong Reference Cycle (Memory Leak) ---")
    var studentA: Student?       = Student(name: "Ram")
    var courseA: EnrolledCourse? = EnrolledCourse(title: "Swift Programming")

    studentA?.enrolledCourse = courseA   
    courseA?.student         = studentA  

    print("Setting both variables to nil…")
    studentA = nil   
    courseA  = nil   
    print("⚠️  No deinit messages above = Memory Leak confirmed!\n")
}



class StudentFixed {
    let name: String
    var enrolledCourse: EnrolledCourseFixed?

    init(name: String) {
        self.name = name
        print("[StudentFixed] \(name) created.")
    }
    deinit { print("[StudentFixed] \(name) deallocated. ✅") }
}

class EnrolledCourseFixed {
    let title: String
    weak var student: StudentFixed?            

    init(title: String) {
        self.title = title
        print("[EnrolledCourseFixed] '\(title)' created.")
    }
    deinit { print("[EnrolledCourseFixed] '\(title)' deallocated. ✅") }
}

func demonstrateFixedCycle() {
    print("--- B: Cycle Fixed with weak reference ---")
    var studentB: StudentFixed?       = StudentFixed(name: "Ram")
    var courseB: EnrolledCourseFixed? = EnrolledCourseFixed(title: "Swift Programming")

    studentB?.enrolledCourse = courseB   
    courseB?.student         = studentB  

    print("Setting both variables to nil…")
    studentB = nil   
    courseB  = nil   
    print("✅  Both objects deallocated correctly!\n")
}


class LectureSession {
    let topic: String
    var onComplete: (() -> Void)?   

    init(topic: String) {
        self.topic = topic
        print("[LectureSession] '\(topic)' created.")
    }
    deinit { print("[LectureSession] '\(topic)' deallocated. ✅") }

    func setupCycleHandler() {
        onComplete = {
            print("Completed lecture on: \(self.topic)") 
        }
    }

    func setupSafeHandler() {
        onComplete = { [weak self] in
            guard let self = self else { return }
            print("Completed lecture on: \(self.topic)")
        }
    }
}

func demonstrateClosureCycle() {
    print("--- C1: Closure Capture Cycle (Memory Leak) ---")
    var session1: LectureSession? = LectureSession(topic: "ARC Deep Dive")
    session1?.setupCycleHandler()
    print("Setting session1 to nil…")
    session1 = nil   
    print("⚠️  No deinit = Memory Leak from closure cycle!\n")

    print("--- C2: Closure Capture Cycle Fixed with [weak self] ---")
    var session2: LectureSession? = LectureSession(topic: "ARC Deep Dive")
    session2?.setupSafeHandler()
    print("Setting session2 to nil…")
    session2 = nil   
    print("✅  Closure cycle resolved with [weak self]!\n")
}

func runTask4() {
    print("\n========== TASK 4 ==========")
    demonstrateCycle()
    demonstrateFixedCycle()
    demonstrateClosureCycle()
}
