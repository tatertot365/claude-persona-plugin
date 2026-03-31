# Software Design Principles — Quick Reference

Core principles for writing code that is correct, maintainable, and debuggable. Each entry includes a definition and concrete do/don't examples.

## SOLID

### S — Single Responsibility Principle
A class or module should have one reason to change.

**Do:** Separate data-fetching logic from formatting logic.
```python
class UserRepository:
    def get_user(self, id): ...

class UserFormatter:
    def to_json(self, user): ...
```

**Don't:** One class that queries the database, formats the response, and sends an email.
```python
class UserService:
    def get_and_notify(self, id):
        user = db.query(...)   # data access
        body = format(user)    # presentation
        send_email(body)       # side effect
```

---

### O — Open/Closed Principle
Software entities should be open for extension, closed for modification. Add new behavior by adding new code, not by editing existing code.

**Do:** Use a strategy or interface so new payment types don't require editing the processor.
```python
class Processor:
    def process(self, strategy: PaymentStrategy, amount): ...

class StripeStrategy(PaymentStrategy): ...
class PayPalStrategy(PaymentStrategy): ...
```

**Don't:** Add an `if payment_type == "paypal"` branch every time a new payment provider is needed.

---

### L — Liskov Substitution Principle
Subtypes must be substitutable for their base types without breaking the program. If `S` extends `T`, anywhere you use `T` you should be able to use `S`.

**Do:** Override methods in a way that preserves the contract (same pre/post-conditions).

**Don't:**
```python
class ReadOnlyList(list):
    def append(self, item):
        raise NotImplementedError  # violates list contract
```
Code that calls `.append()` on a `list` will break unexpectedly when handed a `ReadOnlyList`.

---

### I — Interface Segregation Principle
Clients should not be forced to depend on methods they do not use. Prefer many small, specific interfaces over one large general one.

**Do:**
```typescript
interface Printable { print(): void; }
interface Saveable  { save(): void; }
```

**Don't:**
```typescript
interface Document {
    print(): void;
    save(): void;
    fax(): void;     // most implementors don't need this
    encrypt(): void;
}
```

---

### D — Dependency Inversion Principle
High-level modules should not depend on low-level modules. Both should depend on abstractions. Abstractions should not depend on details.

**Do:** Inject a `Logger` interface; let the caller decide if it logs to stdout, a file, or a service.
```python
def process(data, logger: Logger): ...
```

**Don't:** Instantiate concrete dependencies inside high-level functions.
```python
def process(data):
    logger = FileLogger("/var/log/app.log")  # hardcoded
```

---

## YAGNI — You Aren't Gonna Need It

**Definition:** Only implement what you need now. Don't build for hypothetical future requirements.

### Common Violations
- Adding plugin/hook systems before any plugin exists
- Parameterizing something that has only ever had one value
- Writing abstract base classes for a single concrete implementation
- Building a caching layer before profiling shows a cache is needed
- Adding configuration flags for behaviors no one has asked for

### How to Recognize Over-Engineering
- "This will be useful when we need to…" (but no one has asked)
- The solution is significantly more complex than the problem
- You're writing tests for code paths that cannot currently be triggered
- There are more abstraction layers than there are use cases

**Rule of thumb:** Defer generalization. Write the simplest thing that works. Generalize only when the second real use case appears.

---

## DRY — Don't Repeat Yourself

**Definition:** Every piece of knowledge should have a single, authoritative representation in the system. Applies to logic, not just syntax.

### When Duplication Is Fine — The Three Strikes Rule
1. First time: just write it.
2. Second time: note the duplication, resist the urge to abstract.
3. Third time: now abstract.

Premature abstraction is often worse than duplication. Two similar-looking blocks that represent different concepts should stay separate — coupling them through a shared abstraction makes the code harder to change when the concepts diverge.

### DRY vs. Structural Duplication
DRY is about **knowledge**, not characters. Two functions with the same structure but different business meanings are not a DRY violation. Removing the duplication would couple unrelated concerns.

---

## Explicit over Implicit

**Definition:** Prefer code where behavior is stated directly, not inferred from convention, magic, or side effects.

### In Practice

**Naming:** A function named `process()` is implicit. `validateAndPersistOrder()` is explicit. Prefer specificity even at the cost of length.

**Error handling:** Returning `null` or `-1` on failure is implicit. Throwing a typed exception or returning a `Result<T, Error>` is explicit. The caller must acknowledge the failure case.

**Configuration:** Inferring behavior from environment variable presence is implicit. Requiring a `Config` struct to be passed explicitly makes dependencies visible and testable.

**Magic values:** Avoid unnamed numeric constants and string literals scattered through code. Name them.
```python
# Implicit
if retries > 3: ...

# Explicit
MAX_RETRIES = 3
if retries > MAX_RETRIES: ...
```

---

## Fail Fast / Fail Loudly

**Definition:** Surface errors as early and as visibly as possible. Detect invalid state at the boundary, not deep in business logic.

### Why Silent Failures Are Dangerous
- The failure point and the symptom are separated in time and space, making debugging exponentially harder.
- Silent failures allow corrupted state to propagate and persist (e.g., writing partial data to a database).
- They erode trust in the system — unexpected states appear "out of nowhere."

### Patterns for Surfacing Errors

**Validate at the boundary.** Check inputs when they enter your system (API handlers, CLI argument parsing, config loading), not ten function calls later.

**Crash on programmer error, handle user error.** A missing required config key is a programmer error — panic or throw immediately. A user submitting an invalid email is expected — return a descriptive error.

**Avoid `Optional` / nullable returns for things that must exist.** If a `getUserById` call returning `null` would be a bug, make it throw rather than letting `null` propagate silently.

**Log with context.** When an error is caught and re-thrown (or logged), always include the original error and relevant state (IDs, inputs). A bare `"something went wrong"` is a silent failure disguised as an error.

---

## Make Invalid State Unrepresentable

**Definition:** Use the type system to make it impossible to construct data that violates your domain invariants. The compiler becomes your first line of defense.

### Core Idea
If invalid state cannot be constructed, you never need to write code to handle it. Replace validation checks scattered through the codebase with types that simply cannot represent the invalid case.

### TypeScript Example

**Instead of:**
```typescript
type User = {
  status: "active" | "banned";
  banReason?: string;  // only valid when status === "banned"
};
// Nothing stops: { status: "active", banReason: "spam" }
```

**Use discriminated unions:**
```typescript
type ActiveUser = { status: "active" };
type BannedUser  = { status: "banned"; banReason: string };
type User = ActiveUser | BannedUser;
// banReason only exists on BannedUser — invalid state is unrepresentable
```

### Go Example

**Instead of:**
```go
type Connection struct {
    IsOpen bool
    Conn   net.Conn // nil when IsOpen is false — runtime panic waiting to happen
}
```

**Hide the constructor; only expose valid transitions:**
```go
type OpenConnection struct{ conn net.Conn }  // always open
type ClosedConnection struct{}               // always closed

func Open(addr string) (*OpenConnection, error) { ... }
func (c *OpenConnection) Close() *ClosedConnection { ... }
// You cannot hold an OpenConnection with a nil conn
```

### When This Isn't Possible
Not every language or situation supports full type-level enforcement. In those cases, use:
- **Smart constructors:** Make the zero value invalid; require a constructor function that validates and returns an error.
- **Newtype wrappers:** Wrap primitives (`type Email string`) and validate in the constructor so a raw unvalidated string can't be passed where an `Email` is required.
