

import Foundation
struct Course {
    var title: String
    var code: String
    var credits: Int
    var instructor: String

    init(title: String, code: String, credits: Int, instructor: String) {
        self.title      = title
        self.code       = code
        self.credits    = credits
        self.instructor = instructor
    }

    func describe() {
        print("[Course] \(code) – \(title) | \(credits) credits | Instructor: \(instructor)")
    }
}

class CourseManager {
    var courses: [Course] = []

    func addCourse(_ course: Course) {
        courses.append(course)
        print("[CourseManager] Added '\(course.title)'")
    }

    func removeCourse(withCode code: String) {
        courses.removeAll { $0.code == code }
        print("[CourseManager] Removed course with code '\(code)'")
    }

    func listCourses() {
        print("\n--- Enrolled Courses ---")
        guard !courses.isEmpty else { print("  (none)"); return }
        courses.forEach { $0.describe() }
        print("------------------------\n")
    }
}

func runTask1() {
    print("========== TASK 1 ==========")

    let swift      = Course(title: "Swift Programming", code: "CS101", credits: 3, instructor: "Alice")
    let algorithms = Course(title: "Algorithms",        code: "CS201", credits: 4, instructor: "Bob")
    let database   = Course(title: "Databases",         code: "CS301", credits: 3, instructor: "Carol")

    let manager = CourseManager()
    manager.addCourse(swift)
    manager.addCourse(algorithms)
    manager.addCourse(database)
    manager.listCourses()

    manager.removeCourse(withCode: "CS201")
    manager.listCourses()
}
