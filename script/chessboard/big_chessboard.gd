extends TextureRect
class_name BigChessboard

var small_chessboards = [[], [], []]

signal win(winner: int)

func _ready():
    for r in $VBoxContainer.get_children():
        for c in r.get_children():
            small_chessboards[r.get_index()].append(c)
            c.small_chessboard_occupied.connect(_on_small_chessboard_occupied)
            for sub_r in c.cells:
                for sub_c in sub_r:
                    sub_c.cell_occupied.connect(_on_cell_occupied)

func _process(_delta):
    var all_disabled = true
    for r in small_chessboards:
        for c in r:
            if not c.disabled and all_disabled:
                all_disabled = false
    if all_disabled:
        for r in small_chessboards:
            for c in r:
                c.disabled = false

func _on_small_chessboard_occupied(_small_chessboard_position: Vector2):
    var winner = check_winner()
    if winner != 0:
        win.emit(winner)

func _on_cell_occupied(cell_position: Vector2):
    var small_chessboard_position: Vector2
    for r in small_chessboards:
        for c in r:
            small_chessboard_position = Vector2(
                c.position.x / 88,
                c.get_parent().position.y / 88
            )
            if small_chessboard_position == cell_position:
                c.disabled = false
            else:
                c.disabled = true

func check_winner() -> int:
    # get small_chessboard_occupiers
    var small_chessboard_occupiers: Array = [[], [], []]
    for r in small_chessboards.size():
        for c in small_chessboards[r]:
            small_chessboard_occupiers[r].append(c.occupier)

    # row
    for i in 3:
        if small_chessboard_occupiers[i][0] != 0 \
        and small_chessboard_occupiers[i][0] == small_chessboard_occupiers[i][1] \
        and small_chessboard_occupiers[i][1] == small_chessboard_occupiers[i][2]:
            return small_chessboard_occupiers[i][0]

    # column
    for j in 3:
        if small_chessboard_occupiers[0][j] != 0 \
        and small_chessboard_occupiers[0][j] == small_chessboard_occupiers[1][j] \
        and small_chessboard_occupiers[1][j] == small_chessboard_occupiers[2][j]:
            return small_chessboard_occupiers[0][j]

    # left-up to right-down diagonal
    if small_chessboard_occupiers[0][0] != 0 \
    and small_chessboard_occupiers[0][0] == small_chessboard_occupiers[1][1] \
    and small_chessboard_occupiers[1][1] == small_chessboard_occupiers[2][2]:
        return small_chessboard_occupiers[0][0]

    # right-up to left-down diagonal
    if small_chessboard_occupiers[0][2] != 0 \
    and small_chessboard_occupiers[0][2] == small_chessboard_occupiers[1][1] \
    and small_chessboard_occupiers[1][1] == small_chessboard_occupiers[2][0]:
        return small_chessboard_occupiers[0][2]

    return 0
