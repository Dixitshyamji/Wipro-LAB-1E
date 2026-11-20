import Foundation
func demonstrateStructCopy() {
    print("\n--- Struct (Value Type) Copy Demo ---")

    var original = Course(title: "Swift Programming", code: "CS101", credits: 3, instructor: "Alice")
    var copy = original             

    copy.title      = "Advanced Swift"
    copy.instructor = "Dave"

    print("Original → title: \(original.title), instructor: \(original.instructor)")
    print("Copy     → title: \(copy.title), instructor: \(copy.instructor)")
    print("Observation: Modifying the copy did NOT affect the original. ✅")
}
class MutableCourse {
    var title: String
    var code: String
    var credits: Int

    init(title: String, code: String, credits: Int) {
        self.title   = title
        self.code    = code
        self.credits = credits
    }

    func describe() {
        print("[MutableCourse] \(code) – \(title) | \(credits) credits")
    }
}

func demonstrateClassCopy() {
    print("\n--- Class (Reference Type) Copy Demo ---")

    let original = MutableCourse(title: "Swift Programming", code: "CS101", credits: 3)
    let reference = original        

    reference.title   = "Advanced Swift"
    reference.credits = 5

    print("Original → title: \(original.title), credits: \(original.credits)")
    print("Reference→ title: \(reference.title), credits: \(reference.credits)")
    print("Observation: Modifying via 'reference' ALSO changed 'original'. ⚠️")
    print("             They are the SAME object in memory.")
    print("  original === reference: \(original === reference)")
}

func runTask2() {
    print("\n========== TASK 2 ==========")
    demonstrateStructCopy()
    demonstrateClassCopy()

    print("""

Summary of Differences
─────────────────────────────────────────────────────
│  Aspect           │  Struct (Value)  │ Class (Reference)  │
│  Assignment       │  Full copy       │ Shared pointer     │
│  Mutation effect  │  Local only      │ Visible everywhere │
│  Equality check   │  By value (==)   │ By identity (===)  │
│  Memory           │  Usually stack   │ Heap (ARC managed) │
─────────────────────────────────────────────────────
""")
}
