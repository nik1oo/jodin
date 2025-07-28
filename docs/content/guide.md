+++
date = '2025-07-02T16:23:07+03:00'
draft = false
title = 'Guide'
+++

## Live Coding

Cells are executed in separate threads and their shared resources are guarded by a mutex. To make synchronization easier, JODIN allows you to specify how a cell should be executed using special tags and labels. The acquisition and release of the mutex is then done automatically.

The next section describes 3 different kinds of cells which you can construct In JODIN using it's synchronization features: _regular cell_, _looping cell_, and _composite cell_. The _regular cell_ does nothing special, but the _looping cell_ and the _composite_ cell allow you to do live coding.

---

## Cell Types

![regular cell](../regular-cell.png)

### Regular Cell

Use the regular cell when you want to execute something once, without allowing other cells to insert themselves in-between.

```
…
```

- The cell's contents are executed once.
- The mutex is acquired at the start of execution and released at the end.

---

![looping cell](../looping-cell.png)

### Looping Cell

Use a looping cell when you want to execute something repeatedly, while allowing other cells to insert themselves in-between iterations. To create a _looping cell_ add the `#+loop` tag at the top.

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

Use the composite cell when you want to execute something with a complex control-flow and you want to enable other cells to insert themselves at the bounds of certain scopes. To create a _composite cell_ add an `#+comp` tag at the top and designate separate critical sections by attaching to them a `loop` label.

```
#+comp
…
__comp__: { … }
…
```

- The cell's contents are executed once.
- A mutex scope is inserted before and after every scope labeled as `loop`.
- A mutex scope is inserted inside every scope labeled as `loop`.
- If another cell requests to acquire the mutex while this cell is executing, it can do so at the beginning or end of one of the `loop` scopes.

---
