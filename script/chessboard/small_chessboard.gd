extends TextureRect
class_name SmallChessboard

var disabled = false

var occupier: int = 0

var cells: Array = [[], [], []]

var state_textures: Array = [
    preload("res://asset/image/texture/chessboard/small_chessboard_disable.png"),
    preload("res://asset/image/texture/chessboard/small_chessboard_enable.png")
]

signal small_chessboard_occupied(position: Vector2)

func _ready():
    for r in $VBoxContainer.get_children():
        for c in r.get_children():
            cells[r.get_index()].append(c)
            c.cell_occupied.connect(_on_cell_occupied)
    disabled = false

func _process(_delta):
    if disabled:
        # set texture
        texture = state_textures[0]
        # disable all cells
        for r in cells:
            for c in r:
                c.disabled = true
    else:
        # if all cells are occupied or a player is won, disable all cells
        if is_full() or occupier != 0:
            disabled = true
            return
        # set texture
        texture = state_textures[1]
        # enable all cells
        for r in cells:
            for c in r:
                c.disabled = false # enable cell

func _on_cell_occupied(_cell_position: Vector2):
    var winner = check_winner()
    if winner != 0: # check if there is a winner
        occupier = winner # set winner
        match winner:
            1:
                $Icon_X.visible = true
                $Icon_X.play("appear")
            2:
                $Icon_O.visible = true
                $Icon_O.play("appear")
        small_chessboard_occupied.emit( # emit signal
            Vector2(position.x / 88, get_parent().position.y / 88)
        )
    if is_full(): # check if all cells are occupied
        disabled = true

func is_full() -> bool:
    for r in cells:
        for c in r:
            if c.occupier == 0:
                return false
    return true

func check_winner() -> int:
    # get cell_occupiers
    var cell_occupiers: Array = [[], [], []]
    for r in cells.size():
        for c in cells[r]:
            cell_occupiers[r].append(c.occupier)

    # row
    for i in 3:
        if cell_occupiers[i][0] != 0 \
        and cell_occupiers[i][0] == cell_occupiers[i][1] \
        and cell_occupiers[i][1] == cell_occupiers[i][2]:
            return cell_occupiers[i][0]

    # column
    for j in 3:
        if cell_occupiers[0][j] != 0 \
        and cell_occupiers[0][j] == cell_occupiers[1][j] \
        and cell_occupiers[1][j] == cell_occupiers[2][j]:
            return cell_occupiers[0][j]

    # left-up to right-down diagonal
    if cell_occupiers[0][0] != 0 \
    and cell_occupiers[0][0] == cell_occupiers[1][1] \
    and cell_occupiers[1][1] == cell_occupiers[2][2]:
        return cell_occupiers[0][0]

    # right-up to left-down diagonal
    if cell_occupiers[0][2] != 0 \
    and cell_occupiers[0][2] == cell_occupiers[1][1] \
    and cell_occupiers[1][1] == cell_occupiers[2][0]:
        return cell_occupiers[0][2]

    return 0
