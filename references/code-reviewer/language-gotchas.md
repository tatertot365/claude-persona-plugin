# Language-Specific Gotchas

Common mistakes that trip up developers in each language. Each entry includes the name of the gotcha, a minimal code example showing the mistake, and the correct fix.

---

## Go

### 1. Nil pointer through a non-nil interface

An interface value is nil only when both its type and value are nil. A typed pointer that is nil stored in an interface is **not** a nil interface — the nil check passes and then the method call panics.

```go
// Mistake
type Logger interface{ Log(string) }
type FileLogger struct{}
func (f *FileLogger) Log(s string) { fmt.Println(s) }

func getLogger() Logger {
    var fl *FileLogger // nil pointer
    return fl           // returns non-nil interface wrapping a nil *FileLogger
}

func main() {
    l := getLogger()
    if l != nil {       // true — interface is not nil
        l.Log("hello")  // PANIC: nil pointer dereference
    }
}

// Fix: return untyped nil
func getLogger() Logger {
    return nil
}
```

### 2. Goroutine closure captures loop variable (Go < 1.22)

In Go versions before 1.22, loop variables are shared across iterations. A goroutine that closes over the loop variable sees the final value, not the value at the time the goroutine was launched.

```go
// Mistake (Go < 1.22)
for _, v := range []int{1, 2, 3} {
    go func() {
        fmt.Println(v) // prints 3, 3, 3
    }()
}

// Fix: pass the value as an argument
for _, v := range []int{1, 2, 3} {
    v := v // shadow with a new variable, or pass as arg
    go func() {
        fmt.Println(v)
    }()
}
// Note: Go 1.22+ fixes loop variable semantics — each iteration gets its own variable.
```

### 3. Ignoring the second return value from a map lookup

A map lookup returns the zero value for the value type when the key is absent. Without the `ok` sentinel, you cannot distinguish "key not found" from "key present with zero value."

```go
// Mistake
m := map[string]int{"a": 0}
val := m["b"]   // 0 — but is "b" absent, or stored as 0?
fmt.Println(val + 1) // silently wrong

// Fix
val, ok := m["b"]
if !ok {
    // handle missing key
}
```

### 4. Defer in a loop

`defer` runs when the **function** returns, not when the loop iteration ends. Deferring a resource close inside a loop keeps all resources open until the outer function exits.

```go
// Mistake
for _, path := range paths {
    f, _ := os.Open(path)
    defer f.Close() // all files stay open until end of function
    process(f)
}

// Fix: wrap in a helper function
for _, path := range paths {
    func() {
        f, _ := os.Open(path)
        defer f.Close() // closes at end of this anonymous func
        process(f)
    }()
}
```

### 5. Appending to a slice shared by multiple variables

`append` may or may not allocate a new backing array. If the slice has capacity left, it modifies the existing array, mutating the data visible through other slice headers sharing the same backing array.

```go
// Mistake
a := make([]int, 3, 6)
b := a[:3]
b = append(b, 99)
fmt.Println(a[3]) // may print 99 — unexpected mutation

// Fix: use a full-slice expression to limit capacity, forcing append to allocate
b := a[:3:3]       // cap == len, so append always allocates new array
b = append(b, 99)
```

### 6. Unmarshalling JSON numbers into `interface{}`

When unmarshalling JSON into an `interface{}`, the `encoding/json` package represents numbers as `float64`, not `int`. Integer precision is lost for values > 2^53.

```go
// Mistake
var v interface{}
json.Unmarshal([]byte(`{"id": 9007199254740993}`), &v)
m := v.(map[string]interface{})
fmt.Println(m["id"]) // 9007199254740992 — precision lost

// Fix: use json.Number or a typed struct
dec := json.NewDecoder(bytes.NewReader(data))
dec.UseNumber()
```

---

## Python

### 1. Mutable default argument

Default argument values are evaluated once at function definition time, not on each call. A mutable default (list, dict, set) is shared across all calls that use the default.

```python
# Mistake
def add_item(item, lst=[]):
    lst.append(item)
    return lst

add_item(1)  # [1]
add_item(2)  # [1, 2] — unexpected, same list object

# Fix: use None as sentinel
def add_item(item, lst=None):
    if lst is None:
        lst = []
    lst.append(item)
    return lst
```

### 2. Late-binding closures

Closures capture variables by reference, not by value. In a loop, all closures share the same variable — they all see the final loop value when called.

```python
# Mistake
funcs = [lambda: i for i in range(3)]
[f() for f in funcs]  # [2, 2, 2]

# Fix: capture the value at definition time with a default argument
funcs = [lambda i=i: i for i in range(3)]
[f() for f in funcs]  # [0, 1, 2]
```

### 3. `is` vs `==` for value equality

`is` tests object identity (same object in memory). CPython caches small integers (-5 to 256) and interned strings, making `is` appear to work for them — but this is an implementation detail, not a guarantee.

```python
# Mistake
a = 1000
b = 1000
a is b  # False in CPython — two separate objects
# But:
x = 256; y = 256
x is y  # True due to caching — misleadingly works

# Fix: always use == for value comparison
a == b  # True, correct
```

### 4. Bare `except` swallows `KeyboardInterrupt` and `SystemExit`

`except:` with no type catches everything, including `BaseException` subclasses like `KeyboardInterrupt` and `SystemExit`, making the program unable to be interrupted.

```python
# Mistake
try:
    risky_operation()
except:
    pass  # swallows Ctrl-C, sys.exit(), etc.

# Fix: catch specific exceptions or at least Exception
try:
    risky_operation()
except Exception as e:
    log(e)
```

### 5. Modifying a list while iterating over it

Removing elements from a list during iteration skips elements because the index advances past the shifted items.

```python
# Mistake
items = [1, 2, 3, 4]
for item in items:
    if item % 2 == 0:
        items.remove(item)
# items is [1, 3, 4] — 4 was skipped

# Fix: iterate over a copy, or use a list comprehension
items = [item for item in items if item % 2 != 0]
```

### 6. Floating-point equality

IEEE 754 arithmetic produces rounding errors. Direct equality comparison of floats fails for values that should be equal.

```python
# Mistake
0.1 + 0.2 == 0.3  # False

# Fix: use math.isclose or round to a tolerance
import math
math.isclose(0.1 + 0.2, 0.3)  # True
```

---

## TypeScript / JavaScript

### 1. `==` type coercion

The loose equality operator `==` coerces operands to a common type before comparing, producing counterintuitive results.

```javascript
// Mistake
0 == ""      // true
0 == "0"     // true
"" == "0"    // false (!)
null == undefined  // true
false == "0" // true

// Fix: always use === (strict equality)
0 === ""     // false
null === undefined  // false
```

### 2. `typeof null === "object"`

`null` is not an object, but `typeof null` returns `"object"` — a historical JavaScript bug. Code that checks for an object type and then uses the value can dereference null.

```javascript
// Mistake
function processConfig(config) {
    if (typeof config === "object") {
        return config.value; // throws if config is null
    }
}

// Fix: check for null explicitly
if (config !== null && typeof config === "object") { ... }
// Or in TypeScript: use optional chaining
return config?.value;
```

### 3. `for...in` on arrays

`for...in` iterates over all **enumerable properties** of an object, including inherited ones and any properties added to `Array.prototype`. It also yields string keys, not numeric indices.

```javascript
// Mistake
const arr = [10, 20, 30];
for (const i in arr) {
    console.log(i);     // "0", "1", "2" — strings, not numbers
    console.log(arr[i]); // works by accident due to coercion
}
// If someone did Array.prototype.custom = ..., it shows up too

// Fix: use for...of or forEach for arrays
for (const val of arr) { console.log(val); }
```

### 4. Floating-point arithmetic

Same IEEE 754 issue as Python, but especially common in JavaScript because there is no integer type.

```javascript
// Mistake
0.1 + 0.2 === 0.3  // false (result is 0.30000000000000004)
// Critical in financial calculations

// Fix: use integer arithmetic (store cents, not dollars) or a library like decimal.js
const result = Math.abs(0.1 + 0.2 - 0.3) < Number.EPSILON; // true
```

### 5. `async` function returns a Promise — `await` it

Calling an `async` function without `await` gives you a Promise, not the resolved value. The error is silent if the Promise rejects and there is no `.catch()` or rejection handler.

```javascript
// Mistake
async function fetchUser(id) { return await db.find(id); }

function handler(req) {
    const user = fetchUser(req.id); // Promise object, not User
    if (user.name === "admin") { ... } // always false
}

// Fix: await the call (inside an async function) or chain .then/.catch
async function handler(req) {
    const user = await fetchUser(req.id);
    if (user.name === "admin") { ... }
}
```

### 6. `this` context lost in callbacks

When a method is passed as a callback, it loses its `this` binding. The function runs with `this` as `undefined` (strict mode) or the global object.

```javascript
// Mistake
class Timer {
    constructor() { this.count = 0; }
    tick() { this.count++; }
    start() { setInterval(this.tick, 1000); } // this is undefined in tick
}

// Fix: use an arrow function or bind
start() { setInterval(() => this.tick(), 1000); }
// or
start() { setInterval(this.tick.bind(this), 1000); }
```

---

## Rust

### 1. `String` vs `&str` — cloning when borrowing would work

New Rust developers often `.clone()` everywhere to satisfy the borrow checker rather than taking a reference. This is correct but wasteful; many APIs accept `&str` where `String` is passed.

```rust
// Mistake
fn greet(name: String) {
    println!("Hello, {}", name);
}
let s = String::from("Alice");
greet(s.clone()); // unnecessary allocation
// After this, s is still usable — but .clone() was unneeded

// Fix: accept &str; String coerces to &str automatically
fn greet(name: &str) {
    println!("Hello, {}", name);
}
greet(&s); // or just greet("Alice")
```

### 2. Panicking with `.unwrap()` on user-controlled input

`.unwrap()` panics on `None` or `Err`. Using it on values derived from user input, network data, or file I/O makes the program crash rather than handle the failure.

```rust
// Mistake
let port: u16 = env::var("PORT").unwrap().parse().unwrap();
// panics if PORT is unset or not a valid u16

// Fix: propagate errors properly
let port: u16 = env::var("PORT")
    .map_err(|_| "PORT env var not set")?
    .parse()
    .map_err(|_| "PORT must be a number")?;
```

### 3. Iterator invalidation via index after `retain` / collection mutation

Rust prevents iterator invalidation at compile time for most patterns, but manually tracking indices after mutating a `Vec` is still a logical error.

```rust
// Mistake
let mut v = vec![1, 2, 3, 4, 5];
let mut i = 0;
while i < v.len() {
    if v[i] % 2 == 0 {
        v.remove(i); // shifts elements; next element is skipped
    } else {
        i += 1;
    }
}

// Fix: use retain, which handles this correctly
v.retain(|&x| x % 2 != 0);
```

### 4. Integer overflow in debug vs. release builds

In debug builds, Rust panics on integer overflow. In release builds, it wraps silently (two's complement). Code that happens to work in debug can produce wrong results in production.

```rust
// Mistake
fn compute(a: u32, b: u32) -> u32 {
    a + b  // wraps in release if sum > u32::MAX
}

// Fix: use checked, saturating, or wrapping arithmetic explicitly
a.checked_add(b).expect("overflow")
a.saturating_add(b)
a.wrapping_add(b)  // only if wrapping semantics are intentional
```

### 5. Holding a `MutexGuard` across an `.await`

A `MutexGuard` from `std::sync::Mutex` is not `Send`. Holding it across an `.await` point means it may be held while the task is moved between threads, causing a compile error or — with async-aware mutexes used improperly — deadlocks.

```rust
// Mistake
async fn update(state: Arc<Mutex<State>>) {
    let guard = state.lock().unwrap();
    do_async_thing().await; // guard still held across await — compile error or deadlock
    guard.value = 1;
}

// Fix: either drop the guard before awaiting, or use tokio::sync::Mutex
async fn update(state: Arc<tokio::sync::Mutex<State>>) {
    let mut guard = state.lock().await;
    guard.value = 1;
    // drop guard before next await, or use tokio::sync::Mutex which is Send
}
```

---

## Java

### 1. `NullPointerException` from autoboxing an uninitialized `Integer`

When a `null` `Integer` (or other boxed type) is auto-unboxed — e.g., assigned to an `int`, used in arithmetic, or as a switch expression — the JVM throws `NullPointerException`.

```java
// Mistake
Map<String, Integer> counts = new HashMap<>();
int total = counts.get("missing"); // NPE: auto-unbox of null Integer

// Fix: use getOrDefault, or check for null before unboxing
int total = counts.getOrDefault("missing", 0);
```

### 2. `==` compares boxed type identity, not value

`==` on boxed types (`Integer`, `Long`, etc.) compares object references. The JVM caches values in the range -128 to 127, making `==` appear to work for small numbers — then fail unexpectedly for larger ones.

```java
// Mistake
Integer a = 200;
Integer b = 200;
System.out.println(a == b);   // false — two different objects
// but:
Integer x = 100; Integer y = 100;
System.out.println(x == y);   // true — due to cache (misleading!)

// Fix: always use .equals() for value comparison
System.out.println(a.equals(b)); // true
```

### 3. Breaking the `equals`/`hashCode` contract

If you override `equals` without overriding `hashCode` (or vice versa), objects that are logically equal will not behave correctly in `HashMap`, `HashSet`, or any hash-based collection.

```java
// Mistake
public class Point {
    int x, y;
    @Override
    public boolean equals(Object o) {
        Point p = (Point) o;
        return x == p.x && y == p.y;
    }
    // hashCode not overridden — default uses object identity
}
Set<Point> set = new HashSet<>();
set.add(new Point(1, 2));
set.contains(new Point(1, 2)); // false — different hash buckets!

// Fix: always override both, or use @EqualsAndHashCode (Lombok) or records
@Override
public int hashCode() { return Objects.hash(x, y); }
```

### 4. Swallowing checked exceptions

Catching a checked exception and doing nothing (or logging without rethrowing) hides failures and makes debugging extremely difficult. This is especially common in boilerplate-heavy code.

```java
// Mistake
try {
    connection.close();
} catch (SQLException e) {
    // intentionally ignored
}

// Fix: at minimum log it; better to wrap and rethrow or propagate
} catch (SQLException e) {
    log.warn("Failed to close connection", e);
    throw new RuntimeException("Connection close failed", e);
}
```

### 5. `String` concatenation in a loop

`String` is immutable. Each `+=` in a loop allocates a new `String` object, making the operation O(n²) in the number of iterations.

```java
// Mistake
String result = "";
for (String item : items) {
    result += item + ", "; // O(n^2) allocations
}

// Fix: use StringBuilder
StringBuilder sb = new StringBuilder();
for (String item : items) {
    sb.append(item).append(", ");
}
String result = sb.toString();
// Or: String.join(", ", items)
```

### 6. Using `Calendar` / `Date` for new code

`java.util.Date` and `Calendar` are mutable, not thread-safe, and have a confusing API (months are 0-indexed, years are 1900-offset). The `java.time` package (Java 8+) supersedes them entirely.

```java
// Mistake
Date now = new Date();
Calendar cal = Calendar.getInstance();
cal.setTime(now);
cal.add(Calendar.DAY_OF_MONTH, 7); // verbose and error-prone

// Fix: use java.time
LocalDate next = LocalDate.now().plusDays(7);
ZonedDateTime zdt = ZonedDateTime.now(ZoneId.of("UTC")).plusDays(7);
```
