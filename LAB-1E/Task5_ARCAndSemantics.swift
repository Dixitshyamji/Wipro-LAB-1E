// ============================================================
// Task 5: Explain value/reference semantics and ARC ownership.
//         Demonstrates that value types do NOT always live on
//         the stack — the type system, not memory location,
//         defines value semantics.
// ============================================================

import Foundation

// MARK: - Value Semantics vs Reference Semantics (Conceptual)

/*
 ═══════════════════════════════════════════════════════════════
  VALUE SEMANTICS
 ═══════════════════════════════════════════════════════════════
  • Defined by: each copy of a value is independent.
  • Swift types with value semantics: struct, enum, tuple,
    and standard-library types (Array, Dictionary, String).
  • Copy-on-Write (CoW): Swift collection types use a heap
    buffer internally, but behave as if they copy immediately.
    The copy is deferred until a mutation is performed.
  • Key insight: a struct CAN be allocated on the HEAP when:
      – It is captured by a closure (escaping).
      – It is stored inside a class instance.
      – It contains reference-type properties.
    "Value type" means copy-semantics, NOT "lives on the stack".
 ═══════════════════════════════════════════════════════════════
  REFERENCE SEMANTICS
 ═══════════════════════════════════════════════════════════════
  • Defined by: all variables that hold the same object share
    one piece of heap memory.
  • Swift types with reference semantics: class, actor,
    closures (function references).
  • Assignment copies the pointer, not the data.
 ═══════════════════════════════════════════════════════════════
  ARC — AUTOMATIC REFERENCE COUNTING
 ═══════════════════════════════════════════════════════════════
  ARC tracks the number of "strong" references to each
  heap-allocated class instance.

    strong  – default; increments RC; object lives as long as
              any strong reference exists.
    weak    – optional; does NOT increment RC; set to nil
              automatically when the object is deallocated.
              Use when the referenced object can outlive or
              be released independently.
    unowned – non-optional; does NOT increment RC; crashes if
              accessed after object is deallocated.
              Use only when the referenced object is guaranteed
              to outlive the reference holder.

  Retain Cycle: two (or more) objects hold strong references
  to each other → RC never reaches 0 → memory leak.
  Fix: break the cycle with weak or unowned on one side.
 ═══════════════════════════════════════════════════════════════
*/

// MARK: - Demonstration: Struct on the Heap

// A struct captured by an escaping closure is heap-allocated
struct Counter {
    var count: Int = 0
    mutating func increment() { count += 1 }
}

func capturedOnHeap() -> () -> Int {
    var c = Counter()       // c is a struct, but…
    return {
        c.increment()       // …the closure captures c → c lives on the heap
        return c.count
    }
}

// MARK: - Demonstration: Copy-on-Write with Array

func demonstrateCoW() {
    print("\n--- Copy-on-Write (Array) ---")
    var a = [1, 2, 3]
    var b = a               // No heap copy yet — both share the same buffer

    // The moment b is mutated, Swift makes a fresh copy of the buffer
    b.append(4)

    print("a: \(a)")        // [1, 2, 3] — unchanged
    print("b: \(b)")        // [1, 2, 3, 4] — independent after CoW
    print("Array uses value semantics via CoW even though it uses heap storage. ✅")
}

// MARK: - Demonstration: ARC ownership in action

class Document {
    let name: String
    init(name: String) {
        self.name = name
        print("[Document] '\(name)' created (RC = 1 after assignment).")
    }
    deinit { print("[Document] '\(name)' deallocated — RC reached 0.") }
}

func demonstrateARC() {
    print("\n--- ARC Ownership ---")
    var ref1: Document? = Document(name: "Lab Report")  // RC = 1
    var ref2: Document? = ref1                           // RC = 2
    var ref3: Document? = ref1                           // RC = 3

    print("Three strong references held.")
    ref1 = nil; print("ref1 set to nil (RC = 2)")
    ref2 = nil; print("ref2 set to nil (RC = 1)")
    ref3 = nil; print("ref3 set to nil (RC = 0) → deinit called:")
}

// MARK: - Main entry point

func runTask5() {
    print("\n========== TASK 5 ==========")

    let counter = capturedOnHeap()
    print("Counter (struct captured on heap): \(counter()), \(counter()), \(counter())")
    // Outputs: 1, 2, 3 — struct mutation persists because it lives on the heap

    demonstrateCoW()
    demonstrateARC()

    print("""
\nKey Takeaways
─────────────────────────────────────────────────────────────
1. "Value type" ≠ "stack allocated". Semantics (copy or share)
   is a language guarantee; physical location is an optimisation.
2. ARC automates memory management for heap objects; you must
   still reason about ownership to avoid retain cycles.
3. Use weak for back-references or optional relationships;
   use unowned only when the target is guaranteed to outlive
   the referencing object.
4. Copy-on-Write lets standard-library value types (Array,
   String, Dictionary) avoid unnecessary heap copies.
─────────────────────────────────────────────────────────────
""")
}
