extends Node2D

enum {
	KEY_DIFFICULTY,
	KEY_TITLE,
	KEY_AUTHOR,
	KEY_V_CLUES,
	KEY_H_CLUES,
	}
var quest_list = [
	[1, "PC Net", "matoya",
	["15", "1 1 8", "1 2 1 8", "1 2 8", "1 2 1 8",	"1 1 2 4", "8 2 3", "3 3 3 3", "3 2 8", "3 1 2 1 1",	"4 3 2 1 1", "8 2 1", "8 2 1 1", "8 1 1", "15"],
	["15", "1 9", "1 3 9", "1 3 1 5", "1 4 4",	"3 5 5", "1 2 6", "7 7", "6 2 1", "5 3 3 1",	"5 3 3 1", "6 1 1", "11 3", "9 1", "15"]],
	#
	[2, "Albert", "mamimumemo",
	["", "", "", "", "1", "4", "3 1 1", "3 1", "3 1 1", "4", "1", "", "", "", ""],
	["", "", "", "1 1", "1 1", "1 1", "", "7", "1 1 1", "1 1 1", "1 1", "3", "", "", ""]],
	#
	[2, "Tokyo Bay", "matoya",
	["6", "6", "7", "10", "10",	"5 2 1", "4 1", "2 4 2", "1 9", "1 9",	"2 8", "11", "10", "10", "9"],
	["15", "8 5", "7 4", "7 4", "6 5",	"5 6", "4 7", "3 7", "2 8", "3 7",	"5", "4", "2", "4", "2"]],
	#
	[2, "Maze", "matoya",
	["15", "1 1", "1 1 5 3 1", "1 1 1 3 1 1 1", "1 1 1 1",	"5 7 1", "1 1 1", "1 6 1 4", "3 1 1 1", "1 3 2 4 1",	"1 1 3", "1 3 3 1", "1 1 4 4", "1 1 1", "13 1"],
	["113", "1 1 1 1", "4 1 3 2 1", "1 1 1 1 1 1", "1 4 1 1 2 1",	"1 1 1 1 1", "1 2 3 2 1 1", "1 2 1 3 1 1", "1 2 1 1 1", "1 1 3 1 2",	"1 2 1 1 1 1", "1 1 1 1 1 1 1", "1 4 1 2 1 1", "1 1 1 1", "15"]],
	#
	[2, "B2 Bomber", "vivisuke",
	["15", "211", "113", "113", "11", "11", "8 2", "9", "6 2", "7 5", "7 1 1 1", "4 1 1", "4", "4 1 3", "4 3 1"],
	["15", "211", "113", "113", "11", "11", "8 2", "9", "6 2", "7", "7 2 2", "4 1 1 1", "4 2 2", "4 1 1 1", "4 2 2"]],
	#
	[3, "Game Console", "matoya",
	["4 4", "1 4 1 4", "8 6", "1 1 1 1", "1 1 1 1",	"1 1 1 1", "1 1 1 1", "1 1 1 1", "1 1 1 1", "1 1 1 1",	"1 1 1 1", "1 1 1 1", "6 6", "3 2 3 2", "4 4"],
	["2", "1 1", "14", "3 3", "3 3",	"2 1 1", "1 3", "12", "", "13",	"1 1 3", "3 3", "3 1 1", "3 3", "13"]],
	#
	[3, "Square and Circle", "vivisuke",
	["10", "1 1", "1 3", "1 4 2", "1 5 3",	"1 6 4", "1 6 4", "1 7 5", "1 7 5", "3 5",	"11", "11", "9", "7", "3"],
	["10", "1 1", "1 3", "1 4 2", "1 5 3",	"1 6 4", "1 6 4", "1 7 5", "1 7 5", "3 5",	"11", "11", "9", "7", "3"]],
	#
	[3, "Giraffe (Kirin)", "matoya ",
	["1 4", "6", "4 1", "5", "4 2",	"6", "1 2 1 3", "1 3 1 2", "6", "4 2",	"5", "4 1 5", "13", "111", "1"],
	["1 1", "1 1", "9", "5", "1 1 2",	"7", "5 2", "1 1 3 2", "1 1 2", "8 2",	"5 3", "2 1 1 3", "7 3", "2 5 3", "2 3 3"]],
	#
	[4, "Amabie ", "matoya ",
	["0", "1", "1 1", "1 1 1", "7 5",	"7 1 3", "4 4 3", "3 1 2 1 3", "4 4 5", "8 1 2",	"9 4", "7 1 4", "6 4", "1 1 1 1", "0"],
	["5", "7", "8 1", "3 5", "2 1 5",	"6 5", "10", "11", "1 1 1 1 1", "1 1 1 1",	"1 1 1 1 1", "9", "9", "3 2 3", "1 1 1 1"]],
	#
	[5, "MINI", "matoya",
	["2 7", "1 1 1 3", "2 2 6", "1 8", "1 1 3 1 1",	"1 1 3 1 1", "1 2 1 1 1", "3 1 1 1 1", "1 1 1 1 1", "1 3 1 1",	"1 3 1 1", "1 7", "5 6", "1 1 1 3", "2 7"],
	["1", "1", "9", "1 1", "1 2 1",	"2 1 1 3", "111 1", "5 5", "1 9 1", "1 2 2 1",	"15", "1 2 2 1", "15", "3 3", "3 3"]],
	#
	[6, "Fan", "matoya",
	["1 1", "1 1", "1 1", "1 1", "1 1",	"", "4", "1 1", "1 1 2 1 1", "1 3 1 1",	"1 3 1 2", "1 2 1 1 2", "1 9", "4 2", "2"],
	["4", "1 1 1 1 1", "1 1 1 2 1 1", "1 3 2", "1 3 2",	"1 1 1 1 1 2 1", "1 1 1 1", "5", "1", "1",	"1", "1", "1", "4", "6"]],
	#
	[6, "Robot Guard", "vivisuke",
	["1", "2", "2", "5 2", "4 3 3", "5 1 2 3", "5 6", "4 7", "4 2 2 3", "4 2 2 3", "3 3 3", "4 2", "2", "2", "1"],
	["5", "7", "7", "8", "4 1", "1 2 1", "1 1 2 1", "1 1", "1 1 1", "7", "7", "2", "7", "13", "15"]],
	#
]
var qNumber = 0			# [#1, ...#N]
var solved = []			# true/false
var ans_images = []		# 解答ビットパターン配列
#var test = 123

func _ready():
	pass # Replace with function body.
