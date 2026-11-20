// ============================================================
// Task 4: Demonstrate a strong reference cycle, then fix it.
// ============================================================

import Foundation

// ─────────────────────────────────────────────────────────────
// PART A — Strong Reference Cycle (THE PROBLEM)
// ─────────────────────────────────────────────────────────────

// Scenario 1: Cycle between two class instances
class Student {
    let name: String
    var enrolledCourse: EnrolledCourse?   // strong ➜ Student ──► EnrolledCourse

    init(name: String) {
        self.name = name
        print("[Student] \(name) created.")
    }
    deinit { print("[Student] \(name) deallocated. ✅") }
}

class EnrolledCourse {
    let title: String
    var student: Student?                 // strong ➜ EnrolledCourse ──► Student (CYCLE!)

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

    studentA?.enrolledCourse = courseA   // Student → EnrolledCourse (RC = 2 on course)
    courseA?.student         = studentA  // EnrolledCourse → Student (RC = 2 on student)

    print("Setting both variables to nil…")
    studentA = nil   // RC of Student drops to 1 (EnrolledCourse still holds it)
    courseA  = nil   // RC of EnrolledCourse drops to 1 (Student still holds it)
    // ⚠️ Neither deinit fires — MEMORY LEAK
    print("⚠️  No deinit messages above = Memory Leak confirmed!\n")
}

// ─────────────────────────────────────────────────────────────
// PART B — Fixed with weak reference
// ─────────────────────────────────────────────────────────────

class StudentFixed {
    let name: String
    var enrolledCourse: EnrolledCourseFixed?   // strong

    init(name: String) {
        self.name = name
        print("[StudentFixed] \(name) created.")
    }
    deinit { print("[StudentFixed] \(name) deallocated. ✅") }
}

class EnrolledCourseFixed {
    let title: String
    weak var student: StudentFixed?            // ⬅ weak — breaks the cycle

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

    studentB?.enrolledCourse = courseB   // strong
    courseB?.student         = studentB  // weak — does NOT bump RC

    print("Setting both variables to nil…")
    studentB = nil   // RC of StudentFixed drops to 0 → deinit fires
    courseB  = nil   // RC of EnrolledCourseFixed drops to 0 → deinit fires
    // ✅ Both deinits fire — no leak
    print("✅  Both objects deallocated correctly!\n")
}

// ─────────────────────────────────────────────────────────────
// PART C — Closure Capture Cycle (another common pattern)
// ─────────────────────────────────────────────────────────────

class LectureSession {
    let topic: String
    var onComplete: (() -> Void)?   // stored closure

    init(topic: String) {
        self.topic = topic
        print("[LectureSession] '\(topic)' created.")
    }
    deinit { print("[LectureSession] '\(topic)' deallocated. ✅") }

    // ❌ PROBLEM: closure captures self strongly → cycle
    func setupCycleHandler() {
        onComplete = {
            print("Completed lecture on: \(self.topic)")  // implicit strong capture
        }
    }

    // ✅ FIX: capture list [weak self]
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
    session1 = nil   // ⚠️ No deinit — cycle prevents deallocation
    print("⚠️  No deinit = Memory Leak from closure cycle!\n")

    print("--- C2: Closure Capture Cycle Fixed with [weak self] ---")
    var session2: LectureSession? = LectureSession(topic: "ARC Deep Dive")
    session2?.setupSafeHandler()
    print("Setting session2 to nil…")
    session2 = nil   // ✅ Deinit fires
    print("✅  Closure cycle resolved with [weak self]!\n")
}

// MARK: - Demo
func runTask4() {
    print("\n========== TASK 4 ==========")
    demonstrateCycle()
    demonstrateFixedCycle()
    demonstrateClosureCycle()
}
