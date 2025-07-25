+++
date = '2025-07-02T16:23:07+03:00'
draft = false
title = 'Guide'
+++

## Live Coding

Each cell is executed in a separate thread. To prevent data races, the shared resources are guarded by a mutex. This mutex is acquired and released automatically, so you don't have to think about it. In JODIN there are 3 different kinds of cells: _regular cell_, _looping cell_, and _composite cell_. To do live coding, you have to use _looping cells_ or _composite cells_.

---

![regular cell](../regular-cell.png)

### Regular Cell

```
…
```

- The cell's contents are executed once.
- The mutex is acquired at the start of execution and released at the end.

---

![looping cell](../looping-cell.png)

### Looping Cell

```
#+loop
…
```

- The cell's contents are executed repeatedly until a `break main` statement is executed.
- The mutex is acquired at the start of every successive execution and released at the end.
- If another cell requests to acquire the mutex while this cell is executing, it can do so at the end of current iteration ends.

---

![composite cell](../composite-cell.png)

### Composite Cell

```
…
loop: { … }
…
```

- The cell's contents are executed once.
- A mutex scope is inserted before and after every scope labeled as `loop`.
- A mutex scope is inserted inside every scope labeled as `loop`.
- If another cell requests to acquire the mutex while this cell is executing, it can do so at the beginning or end of one of the `loop` scopes.

---
