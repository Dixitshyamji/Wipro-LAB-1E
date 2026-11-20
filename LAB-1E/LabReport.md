# LAB-1E: Classes, Structs, ARC, and Memory
**Author:** Shyam Ji Dixit  
**Due:** Friday, 6 November  
**Language:** Swift 5.9+

---

## Objective

Compare value and reference types and observe ownership behaviour in Swift.

---

## Task 1 — Modelling Course (struct) and CourseManager (class)

A `Course` is modelled as a **struct** because:
- Each course is a self-contained value with no identity beyond its data.
- Sharing is unnecessary; copies are cheap and safe.

A `CourseManager` is modelled as a **class** because:
- It maintains a mutable, shared list of courses.
- Multiple parts of the program may need to observe and mutate the *same* list.
- Reference semantics make it trivial to pass one manager around and have all callers see the same state.

---

## Task 2 — Observed Value/Reference Behaviour

### Struct (Value Type)

```swift
var original = Course(title: "Swift Programming", ...)
var copy = original        // full copy of the value
copy.title = "Advanced Swift"
// original.title is still "Swift Programming" ✅
```

**Observation:** Modifying `copy` had **no effect** on `original`. The assignment operator created a completely independent value. This is **value semantics**.

### Class (Reference Type)

```swift
let original = MutableCourse(title: "Swift Programming", ...)
let reference = original   // copies the pointer, NOT the object
reference.title = "Advanced Swift"
// original.title is now "Advanced Swift" ⚠️
```

**Observation:** Both `original` and `reference` point to the **same heap object**. Mutating through one variable is immediately visible through the other. This is **reference semantics**.

| Aspect | Struct (Value) | Class (Reference) |
|---|---|---|
| Assignment | Full copy | Shared pointer |
| Mutation effect | Local only | Visible everywhere |
| Equality check | `==` by value | `===` by identity |
| Lifetime | Stack or inline heap | ARC-managed heap |

---

## Task 3 — weak vs. unowned in Teacher/Classroom

The relationship:

```
Classroom ──(strong)──► Teacher slot
Teacher   ──(weak)────► Classroom
```

**Why `weak` on `Teacher.classroom`?**  
A `Teacher` can exist without a `Classroom` (unassigned staff). Using `weak var classroom: Classroom?` means the reference is optional and automatically set to `nil` when the `Classroom` is deallocated, preventing a crash.

**Why NOT `unowned`?**  
`unowned` asserts that the referenced object *always* outlives the referencing object. That is not guaranteed here—a Classroom can be released while a Teacher instance still exists.

**Result:** When `room = nil` is executed, the `Classroom` is deallocated and `teacher.classroom` becomes `nil` safely.

---

## Task 4 — Strong Reference Cycle and the Fix

### The Problem (Retain Cycle)

```
Student ──(strong)──► EnrolledCourse
EnrolledCourse ──(strong)──► Student
```

When both local variables are set to `nil`, each object's reference count drops to **1** (not 0), because they still hold each other. Neither `deinit` fires → **memory leak**.

### Fix 1 — `weak` on the back-reference

```swift
class EnrolledCourseFixed {
    weak var student: StudentFixed?   // breaks the cycle
}
```

Now when `studentB = nil`, the Student's RC drops to 0 → `deinit` fires → EnrolledCourse's strong reference to Student is gone → EnrolledCourse RC also drops to 0 → `deinit` fires. ✅

### Fix 2 — `[weak self]` in a closure capture list

```swift
// ❌ Cycle: closure captures self strongly
onComplete = { print(self.topic) }

// ✅ Fixed: weak self in capture list
onComplete = { [weak self] in
    guard let self = self else { return }
    print(self.topic)
}
```

A stored closure (`onComplete`) creates a strong reference back to the enclosing object. The `[weak self]` capture list breaks that cycle.

---

## Task 5 — Value/Reference Semantics and ARC Ownership

### The Stack/Heap Misconception

> ❌ Common misconception: "Structs are on the stack, classes are on the heap."

The truth: **value semantics** is a *language guarantee* about copy behaviour, not a statement about physical memory location. A struct **can** be heap-allocated when:

- Captured by an escaping closure.
- Stored as a property of a class instance.
- Too large for the compiler to place in registers or the stack frame.

Swift's compiler decides allocation; the programmer reasons about *ownership* and *copy semantics*.

### Copy-on-Write (CoW)

Swift standard-library types (Array, String, Dictionary) use value semantics via **Copy-on-Write**: the heap buffer is shared until a mutation is about to occur, at which point a fresh copy is made. This avoids unnecessary copies while preserving value semantics.

### ARC — How It Works

| Reference kind | Increments RC? | Becomes nil on dealloc? |
|---|---|---|
| `strong` (default) | ✅ Yes | — |
| `weak` | ❌ No | ✅ Yes (optional) |
| `unowned` | ❌ No | ❌ Crashes if accessed |

ARC inserts `retain`/`release` calls at compile time. When RC reaches 0, `deinit` is called and the memory is freed. The programmer's responsibility is to avoid retain cycles by using `weak` or `unowned` for back-references or closure captures.

---

## How the Retain Cycle Was Prevented

| Scenario | Technique | Explanation |
|---|---|---|
| Object ↔ Object cycle | `weak var` | Back-reference (child → parent) made weak so parent's RC drops to 0 when local var is set to nil |
| Closure cycle | `[weak self]` | Capture list prevents the closure from holding a strong reference to its enclosing instance |

---

## Conclusion

Swift's type system provides predictable ownership semantics:
- **Value types** (struct, enum) copy on assignment — safe to share by default.
- **Reference types** (class) share identity — powerful but require careful ownership design.
- **ARC** manages class-instance lifetimes automatically; developers must break retain cycles manually using `weak` and `unowned`.
- **Stack vs. heap** is an optimisation detail; the semantic guarantee (copy vs. share) is what matters when designing Swift APIs.
