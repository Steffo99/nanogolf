extends Node
class_name LevelPlaylist


## The [GolfLevel]s that should be sequentially loaded on the [LevelManager].
@export var levels: Array[PackedScene] = []


## Emitted when the playlist has advanced to a new level, but before it is returned by [method advanced].
signal advanced(level: PackedScene)


## The index of the current level in [field levels].
var idx: int = -1


## Advances to the next level in the playlist and returns it as a [PackedScene].
##
## Returns null when the playlist is complete.
func advance() -> PackedScene:
	idx += 1
	if idx >= len(levels):
		return null
	var level = levels[idx]
	advanced.emit(level)
	return level
