+++
date = '2025-07-02T16:23:07+03:00'
draft = false
title = 'Guide'
+++

Typically when you execute a cell the kernel will wait for the cell thread to finish before displaying its output and allowing you to execute another cell. This is _synchronous execution_ and it is the default. Jodin also supports _asynchronous execution_ where you can execute a cell and leave its thread running for as long as it wants to or until you terminate it from another cell.

To make a cell execute asynchronously, add the `#+async` directive at the top. To prevent race-conditions, this cell won't be allowed to access external variables in its root scope, and any variables declared there will not be exported to other cells.

```
#+async
…
```

In order for this cell to interact with other cells, you need to declare at least one scope with the `sync` label.

```
#+async
…
sync: {
	…
}
…
```

Every Jodin session has a `Ticket_Mutex` called `__data_mutex__`, which is acquired at the beginning of the cell and released at the end, to allow the synchonous cells to share the same memory as asynchronous cells. In asynchronous cells the `__data_mutex__` is acquired at the beginning of every `sync` scope and released at it's end.

So if an asynchronous cell with a `sync` loop is running, and you execute a synchronous cell, the asynchronous cell will halt at the end of the current iteration until the synchronous cell is executed.

---

## Examples

There are several notebooks in the `examples` folder of the Jodin repository which show how this feature can be used for live coding.

- The `glfw.ipynb` notebook shows how you can update the contents of a GLFW window live.
- The `miniaudio.ipynb` notebook shows how you can live-program sound.
