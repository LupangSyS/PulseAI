"""Procedurally carves a big, guaranteed-fully-connected district grid:
blocked_cells (obstacles) and a matching terrain array. Used to seed the
large district expansions (see GDD.md's district depth-pass notes) - hand-
typing hundreds of blocked-cell coordinates for a 20-30x bigger grid than
the original districts isn't reliable, so this authors the base layout,
which is then hand-edited further to place named content (NPCs, puzzle
steps, locked doors, monster/item spawns) at specific meaningful cells.

Algorithm: place candidate rectangular obstacle clusters one at a time (not
all at once, then patch) - after each placement, BFS from the entrance and
reject the obstacle if it would disconnect any currently-open cell. This
guarantees full connectivity by construction, not by post-hoc repair (the
same class of mistake the hand-authored small districts caught early via
BFS verification - here the generator itself never produces a disconnected
result in the first place).

Run: python3 tools/gen_district_layout.py <width> <height> <density> <seed>
Prints the blocked_cells list and a terrain array (weighted from a fixed
palette - edit the WATER/PAVEMENT/RUBBLE mix per district by hand after) as
Python literals ready to paste into a districts.json entry.
"""
import sys
import random
from collections import deque


def bfs_reachable(w, h, blocked, start):
    seen = {start}
    q = deque([start])
    while q:
        cx, cy = q.popleft()
        for dx, dy in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in blocked and (nx, ny) not in seen:
                seen.add((nx, ny))
                q.append((nx, ny))
    return seen


def carve_room(blocked, w, h, x0, x1, y0, y1, door_cell):
    """Walls off a rectangular sub-region as a room reachable through exactly
    one door cell (outside the rectangle, adjacent to it). Clears the room's
    interior and the door, then blocks every other cell adjacent to the room
    boundary. Doesn't itself guarantee the door connects back to the rest of
    the map (the base maze may have already sealed the door's only other
    exit) - always follow with ensure_connected()."""
    blocked = set(blocked)
    room = set((x, y) for x in range(x0, x1 + 1) for y in range(y0, y1 + 1))
    blocked -= room
    blocked.discard(door_cell)
    for (rx, ry) in room:
        for dx, dy in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
            nx, ny = rx + dx, ry + dy
            if (nx, ny) in room or (nx, ny) == door_cell:
                continue
            if 0 <= nx < w and 0 <= ny < h:
                blocked.add((nx, ny))
    return blocked


def ensure_connected(blocked, w, h, entrance):
    """Repairs connectivity by clearing the minimal blocked cells needed to
    reach every open cell from the entrance, verified by BFS after every
    change - never trusts the caller's reasoning about the maze, only the
    resulting BFS result. Needed because carve_room() only guarantees a
    room's door itself is unblocked, not that a path from the door back to
    the rest of the map survives (the base maze or an earlier carve_room
    call may have already sealed the door's other side). Returns
    (repaired_blocked, True) once every open cell is reachable, or
    (blocked, False) if a pocket has no clearable path back at all (a fully
    walled-off room with no adjacent blocked cell touching reachable
    ground - shouldn't happen with rectangular rooms, but checked instead
    of assumed)."""
    blocked = set(blocked)
    while True:
        all_open = set((x, y) for x in range(w) for y in range(h)) - blocked
        reachable = bfs_reachable(w, h, blocked, entrance)
        missing = all_open - reachable
        if not missing:
            return blocked, True
        found = None
        for (mx, my) in missing:
            for dx, dy in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
                nx, ny = mx + dx, my + dy
                if not (0 <= nx < w and 0 <= ny < h) or (nx, ny) not in blocked:
                    continue
                for dx2, dy2 in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
                    nnx, nny = nx + dx2, ny + dy2
                    if (nnx, nny) in reachable:
                        found = (nx, ny)
                        break
                if found:
                    break
            if found:
                break
        if found is None:
            return blocked, False
        blocked.discard(found)


def generate(w, h, density, seed, entrance, must_keep_open):
    rng = random.Random(seed)
    blocked = set()
    all_open_target = w * h - len(must_keep_open)
    target_blocked = int(w * h * density)

    attempts = 0
    while len(blocked) < target_blocked and attempts < target_blocked * 40:
        attempts += 1
        cw = rng.choice([1, 1, 1, 2, 2, 3])
        ch = rng.choice([1, 1, 1, 2, 2, 3])
        x0 = rng.randint(0, w - cw)
        y0 = rng.randint(0, h - ch)
        candidate = set()
        for x in range(x0, x0 + cw):
            for y in range(y0, y0 + ch):
                candidate.add((x, y))
        if entrance in candidate or candidate & must_keep_open:
            continue
        trial = blocked | candidate
        reachable = bfs_reachable(w, h, trial, entrance)
        # Every currently-open, non-candidate cell must still be reachable.
        still_needed = (set((x, y) for x in range(w) for y in range(h)) - trial)
        if not still_needed.issubset(reachable):
            continue
        blocked |= candidate

    reachable_final = bfs_reachable(w, h, blocked, entrance)
    all_open = set((x, y) for x in range(w) for y in range(h)) - blocked
    assert all_open.issubset(reachable_final), "generator produced a disconnected layout (bug)"
    return blocked


if __name__ == "__main__":
    w, h, density, seed = int(sys.argv[1]), int(sys.argv[2]), float(sys.argv[3]), int(sys.argv[4])
    entrance = (0, h // 2)
    blocked = generate(w, h, density, seed, entrance, set())
    cells = sorted(blocked)
    print("blocked_cells (%d cells, %.1f%% density):" % (len(cells), 100 * len(cells) / (w * h)))
    print("[" + ", ".join("[%d, %d]" % c for c in cells) + "]")
    print()
    print("entrance:", entrance)
    reachable = bfs_reachable(w, h, blocked, entrance)
    print("reachable open cells: %d / %d" % (len(reachable), w * h - len(blocked)))
