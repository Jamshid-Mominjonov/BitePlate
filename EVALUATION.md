# EVALUATION — BitePlate SRMS

A short technical evaluation of the design choices in the prototype. (Pass + Merit only were
required; this note is included because it strengthens the portfolio.)

## Were the chosen patterns the best fit?

For the most part, yes. **Strategy** is the textbook answer to runtime-swappable pricing and needed
no compromise. **Command** fit the kitchen queue because the brief explicitly required undo, which
falls out naturally once each action is an object that captures its previous state. **Decorator**
was the right call for meal customisation — the alternative (a subclass per combination) does not
scale. The one choice I would revisit is **Singleton**: it satisfies the "one global log"
requirement but, as noted below, it trades testability for convenience, and an injected single
instance would achieve the same goal with fewer downsides.

Alternatives considered: an **Abstract Factory** instead of plain Factory Method (deferred until a
branch needs a whole family of related objects); the **Visitor** pattern for reporting (rejected as
heavier machinery than the simple records justify); and a **State** class hierarchy for the order
lifecycle (I used guarded enum transitions instead, which are lighter for five states).

## Trade-offs of the Singleton implementation

My `OrderHistoryLog` is an eager Dart singleton (a private constructor with a static `instance`).
The benefits are simplicity and a guaranteed single point of truth. The costs are:

- **Testability.** Because the instance is global and persists across the program, tests can leak
  state into one another. I mitigated this with a `resetForTesting()` hook, but the cleaner solution
  is dependency injection — pass the log into the services so each test gets a fresh instance.
- **Thread/isolate safety.** Dart is single-threaded per isolate, so there is no classic race on
  the instance within one isolate. However, if the backend spawned multiple isolates, each would get
  its own copy of the "singleton", silently breaking the global-log guarantee. A shared store
  (database or a single owning isolate) would be required.

## Scaling to 50 restaurants on one central database

Several decisions would change:

- The **Singleton in-memory log** would have to become a repository backed by a shared database;
  the `Iterator` abstraction already isolates the reporting code from this change, so reports would
  largely survive intact.
- **Identity** would need a branch dimension — order IDs, table numbers and staff IDs must be
  unique per location, so records would carry a `restaurantId`.
- The **Factory** layer would graduate to an **Abstract Factory** per branch to serve
  location-specific menus from shared core code.
- The current synchronous, in-process services would move behind an asynchronous, transactional
  data layer, and the REST API would need authentication and per-branch authorisation rather than
  the prototype's open endpoints.
