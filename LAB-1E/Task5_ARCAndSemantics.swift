import Foundation

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


struct Counter {
    var count: Int = 0
    mutating func increment() { count += 1 }
}

func capturedOnHeap() -> () -> Int {
    var c = Counter()     
    return {
        c.increment()
        return c.count
    }
}


func demonstrateCoW() {
    print("\n--- Copy-on-Write (Array) ---")
    var a = [1, 2, 3]
    var b = a               

    b.append(4)

    print("a: \(a)")        
    print("b: \(b)")        
    print("Array uses value semantics via CoW even though it uses heap storage. ✅")
}


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
    var ref1: Document? = Document(name: "Lab Report")  
    var ref2: Document? = ref1                           
    var ref3: Document? = ref1                           

    print("Three strong references held.")
    ref1 = nil; print("ref1 set to nil (RC = 2)")
    ref2 = nil; print("ref2 set to nil (RC = 1)")
    ref3 = nil; print("ref3 set to nil (RC = 0) → deinit called:")
}



func runTask5() {
    print("\n========== TASK 5 ==========")

    let counter = capturedOnHeap()
    print("Counter (struct captured on heap): \(counter()), \(counter()), \(counter())")

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
