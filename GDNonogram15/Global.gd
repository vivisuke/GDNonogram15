extends Node2D

const solvedPatFileName = "user://saved.dat"

var solvedPatLoaded = false
var lvl_vscroll = 0		# レベルシーン スクロール位置
var solveMode = true
var qNumber = 0			# [#1, ...#N]
var qix2ID = []			# qix → QID 配列
var solvedPat = {}		# QID -> [data0, data1, ...] 辞書
#var solved = []			# true/false
var ans_images = []		# 解答ビットパターン配列

enum {
	KEY_ID = 0,
	KEY_DIFFICULTY,
	KEY_TITLE,
	KEY_AUTHOR,
	KEY_V_CLUES,
	KEY_H_CLUES,
	}
var quest_list = [
	["Q001", 1, "PC Net", "matoya",
	["15", "1 1 8", "1 2 1 8", "1 2 8", "1 2 1 8",	"1 1 2 4", "8 2 3", "3 3 3 3", "3 2 8", "3 1 2 1 1",	"4 3 2 1 1", "8 2 1", "8 2 1 1", "8 1 1", "15"],
	["15", "1 9", "1 3 9", "1 3 1 5", "1 4 4",	"3 5 5", "1 2 6", "7 7", "6 2 1", "5 3 3 1",	"5 3 3 1", "6 1 1", "11 3", "9 1", "15"]],
	#
	["Q002", 1, "Uniwaro", "vivisuke",
	["15"," 1 4 1 5"," 1 4 1 6"," 1 4 1 4 1"," 1 4 1 3 2"," 1 1 2 3"," 6 1 4","15"," 6 1 1"," 1 4 1 4 1"," 1 4 1 4 1"," 1 4 1 4 1"," 1 4 1 4 1"," 6 1 1","15",],
	["15"," 1 3 2"," 5 9"," 5 9"," 5 9"," 5 9"," 1 1 1","15"," 1 1 1"," 1 4 1 4 1"," 6 1 4 1"," 5 2 4 1"," 4 3 4 1"," 3 4 1","15",]],
	#
	["Q003", 1, "UNIGLO", "Yew",
	["15"," 1 3 2"," 6 1 4 1"," 6 1 2 1 1"," 1 3 1 1","15"," 1 1 1"," 3 9 1"," 4 8 1"," 1 8"," 9 2"," 8 4 1"," 1 1 4 1"," 9 2","15",],
	["15"," 1 2 1 2 2 2"," 1 2 1 2 2 2"," 1 2 1 1 2 2"," 1 2 1 1 2 2"," 1 2 1 2 2 2"," 2 2 2 2 2","15"," 2 2 4 2"," 1 2 1 3 2 1"," 1 4 3 2 1"," 1 1 1 3 2 1"," 1 2 1 3 2 1"," 2 1 2 2","15",]],
	#
	["Q004", 2, "Albert", "mamimumemo",
	["", "", "", "", "1", "4", "3 1 1", "3 1", "3 1 1", "4", "1", "", "", "", ""],
	["", "", "", "1 1", "1 1", "1 1", "", "7", "1 1 1", "1 1 1", "1 1", "3", "", "", ""]],
	#
	["Q005", 2, "Tokyo Bay", "matoya",
	["6", "6", "7", "10", "10",	"5 2 1", "4 1", "2 4 2", "1 9", "1 9",	"2 8", "11", "10", "10", "9"],
	["15", "8 5", "7 4", "7 4", "6 5",	"5 6", "4 7", "3 7", "2 8", "3 7",	"5", "4", "2", "4", "2"]],
	#
	["Q006", 2, "Maze", "matoya",
	["15", "1 1", "1 1 5 3 1", "1 1 1 3 1 1 1", "1 1 1 1",	"5 7 1", "1 1 1", "1 6 1 4", "3 1 1 1", "1 3 2 4 1",	"1 1 3", "1 3 3 1", "1 1 4 4", "1 1 1", "13 1"],
	["113", "1 1 1 1", "4 1 3 2 1", "1 1 1 1 1 1", "1 4 1 1 2 1",	"1 1 1 1 1", "1 2 3 2 1 1", "1 2 1 3 1 1", "1 2 1 1 1", "1 1 3 1 2",	"1 2 1 1 1 1", "1 1 1 1 1 1 1", "1 4 1 2 1 1", "1 1 1 1", "15"]],
	#
	["Q007", 2, "B2 Bomber", "vivisuke",
	["15", "211", "113", "113", "11", "11", "8 2", "9", "6 2", "7 5", "7 1 1 1", "4 1 1", "4", "4 1 3", "4 3 1"],
	["15", "211", "113", "113", "11", "11", "8 2", "9", "6 2", "7", "7 2 2", "4 1 1 1", "4 2 2", "4 1 1 1", "4 2 2"]],
	#
	["Q008", 3, "Game Console", "matoya",
	["4 4", "1 4 1 4", "8 6", "1 1 1 1", "1 1 1 1",	"1 1 1 1", "1 1 1 1", "1 1 1 1", "1 1 1 1", "1 1 1 1",	"1 1 1 1", "1 1 1 1", "6 6", "3 2 3 2", "4 4"],
	["2", "1 1", "14", "3 3", "3 3",	"2 1 1", "1 3", "12", "", "13",	"1 1 3", "3 3", "3 1 1", "3 3", "13"]],
	#
	["Q009", 3, "Square and Circle", "vivisuke",
	["10", "1 1", "1 3", "1 4 2", "1 5 3",	"1 6 4", "1 6 4", "1 7 5", "1 7 5", "3 5",	"11", "11", "9", "7", "3"],
	["10", "1 1", "1 3", "1 4 2", "1 5 3",	"1 6 4", "1 6 4", "1 7 5", "1 7 5", "3 5",	"11", "11", "9", "7", "3"]],
	#
	["Q010", 3, "Giraffe (Kirin)", "matoya ",
	["1 4", "6", "4 1", "5", "4 2",	"6", "1 2 1 3", "1 3 1 2", "6", "4 2",	"5", "4 1 5", "13", "111", "1"],
	["1 1", "1 1", "9", "5", "1 1 2",	"7", "5 2", "1 1 3 2", "1 1 2", "8 2",	"5 3", "2 1 1 3", "7 3", "2 5 3", "2 3 3"]],
	#
	["Q011", 3, "Girl", "noname ",
	[" 2 1"," 1 2"," 5 4","13"," 5 5 1"," 7 1 2"," 4 2 1"," 3 2 1"," 3 2 1 1"," 4 1 3 2","13","10"," 1 3"," 2 1"," 1",],
	[" 5"," 1 8 1","14"," 5 3"," 4 2"," 4 1 2"," 2 1 1 2"," 2 3"," 7 2"," 3 2 4"," 4 4 1"," 5 5"," 1 1"," 8"," 1 1",]],
	#
	["Q012", 3, "Alphabet", "vivisuke",
	[" 3 4 2"," 4 4 4"," 1 1 1 1 1 1"," 3 2 1 2"," 0"," 4 4 4"," 4 4 4"," 1 1 1 2 1"," 1 1 1 4"," 0"," 2 4"," 4 4 4"," 1 1 1 1 4"," 1 1 1"," 0",],
	[" 2 2 3"," 2 1 3 2"," 4 2 1 2"," 2 1 3 3"," 0"," 3 4 4"," 2 1 2 2"," 2 1 3 3"," 3 4 2"," 0"," 3 2 1 2"," 2 2 1 2"," 2 1 4 2"," 3 2 1 2"," 0",]],
	#
	["Q013", 3, "Ghost", "vivisuke",
	[" 9","12","13"," 4 2 5"," 4 4","14","15","15"," 5 2 6"," 5 5","12","13","13","12"," 9",],
	[" 5"," 9","11","13","13"," 3 3 5"," 4 4 5"," 4 4 5"," 3 3 5","15","15","15","15"," 4 5 4"," 2 3 2",]],
	#
	["Q014", 3, "Sergeant", "vivisuke",
	[" 2 7"," 2 9"," 211"," 1 3 6"," 2 2 2 4"," 1 3 2 3"," 2 4 6"," 210 1"," 2 4 6"," 1 3 2 3"," 2 2 2 4"," 1 3 6"," 211"," 2 9"," 2 7",],
	[" 7"," 3 3 3"," 2 2"," 2 5 2"," 111 1","13"," 4 3 4"," 3 2 1 2 3"," 3 2 1 2 3"," 4 3 4","15","15","15"," 4 1 1 4"," 2 3 2",]],
	#
	["Q015", 3, "biscione", "Yew",
	[" 3"," 3"," 1 1 1"," 6"," 1"," 1 1"," 2 2 3"," 7 5"," 6 5 1"," 3 3 5 1"," 6 2 2 1"," 6 3 4"," 8 4"," 7 2"," 5",],
	[" 1 1 1"," 1 5"," 1 7"," 2 1 4 4"," 5 8"," 2 110"," 1 5 3"," 2 4"," 8"," 8"," 4"," 7"," 7"," 3"," 5",]],
	#
	["Q016", 3, "horse", "vivisuke",
	[" 2"," 8 5"," 8 4"," 1 1 1 1"," 1 1 1 1 4"," 1 1 1 1 3"," 1 1 1 1 2"," 7 4"," 7 3"," 1 1 1 1 1"," 1 1 1 1 4"," 1 1 1 1 3 1"," 2 1 1 2 1"," 2 1 1 8"," 1 6",],
	[" 2","14"," 2 2","13"," 2 2","13"," 2 2","13"," 2 3"," 2 2"," 2 2 2 2"," 2 1 3 2 2"," 2 2 2 2 2"," 3 2 2 2"," 2 2 3",]],
	#
	["Q042", 3, "1st Angel", "vivisuke",
	[" 5 9"," 5 8"," 4 5"," 2 1"," 1 1"," 1 3"," 1 1 2 3"," 2 2 3"," 3 2"," 3"," 3"," 3 3"," 6"," 1 5"," 2 7",],
	[" 4 7 2"," 4 5 1"," 3 4"," 3 1 1"," 2"," 0"," 1 1"," 2 2 1"," 3 2 4"," 4 2 4"," 3 3"," 3 3"," 3 3 2"," 2 4 1"," 2 5",]],
	#
	["Q044", 3, "Heart", "Runa",
	[" 7"," 9","10","11","11","11","11","11","11","11","11","11"," 2 7"," 3 5"," 7",],
	[" 3 3"," 5 5"," 6 3 2"," 7 5 1","15","15","15","15","13","11"," 9"," 7"," 5"," 3"," 1",]],
	#
	["Q017", 4, "Amabie ", "matoya ",
	["0", "1", "1 1", "1 1 1", "7 5",	"7 1 3", "4 4 3", "3 1 2 1 3", "4 4 5", "8 1 2",	"9 4", "7 1 4", "6 4", "1 1 1 1", "0"],
	["5", "7", "8 1", "3 5", "2 1 5",	"6 5", "10", "11", "1 1 1 1 1", "1 1 1 1",	"1 1 1 1 1", "9", "9", "3 2 3", "1 1 1 1"]],
	#
	["Q045", 4, "Miku", "vivisuke",
	[" 4"," 9","11"," 4 3"," 1 5 1"," 4 1 2"," 4 1 1 5"," 5 5"," 4 1 1 5"," 4 1 2"," 1 5 1"," 4 3","11"," 9"," 4",],
	[" 0"," 1 3 1"," 5"," 9","11"," 5 1 5"," 4 1 1 4"," 2 1 1 2"," 3 5 3"," 3 1 3"," 3 3 3"," 3 5 3"," 3 5 3"," 3 1 1 3"," 3 1 1 3",]],
	#
	["Q018", 5, "MINI", "matoya",
	["2 7", "1 1 1 3", "2 2 6", "1 8", "1 1 3 1 1",	"1 1 3 1 1", "1 2 1 1 1", "3 1 1 1 1", "1 1 1 1 1", "1 3 1 1",	"1 3 1 1", "1 7", "5 6", "1 1 1 3", "2 7"],
	["1", "1", "9", "1 1", "1 2 1",	"2 1 1 3", "111 1", "5 5", "1 9 1", "1 2 2 1",	"15", "1 2 2 1", "15", "3 3", "3 3"]],
	#
	["Q019", 5, "Chick", "vivisuke",
	[" 0"," 1"," 2"," 1 1"," 2 1"," 2 2 1"," 4 5"," 5 2 1"," 6 3","13 1"," 4 6 2"," 9 1"," 4"," 1"," 0",],
	[" 3"," 5"," 7"," 7"," 4 2"," 9"," 2 3"," 4 3"," 1 3"," 1 4"," 7"," 5"," 1 1"," 1 1"," 3 3",]],
	#
	["Q020", 5, "Kitten", "vivisuke",
	[" 0"," 0"," 3"," 2 2"," 7 1"," 8 3"," 210","13"," 7 6"," 8 4"," 4 2"," 1"," 1 1"," 4"," 0",],
	[" 1 1"," 2 2"," 7"," 9"," 1 2 4"," 9"," 8"," 6"," 2"," 3 1"," 3 1"," 4 1"," 5 1"," 6 1"," 9",]],
	#
	["Q021", 5, "Ponytail", "vivisuke",
	[" 3"," 3 2"," 7 2"," 3 2"," 5 2 1 1"," 6 3"," 7 2"," 8 2"," 6 1 2","10 2"," 7 3"," 3 2"," 8 1"," 7"," 0",],
	[" 0"," 5"," 8","10","13"," 310"," 1 1 9"," 1 1 2 2 2"," 1 1 1 2 2"," 1 2 2"," 2 2 2"," 2 1 2"," 3 1"," 7"," 9",]],
	#
	["Q022", 5, "Reimu", "vivisuke",
	[" 4"," 1 1 2"," 1 8 1"," 111"," 1 4 3 1"," 5 2 1 1"," 5 2 2"," 4 2 1"," 5 2 2"," 5 2 1 1"," 1 4 3 1"," 111"," 1 8 1"," 1 1 2"," 4",],
	[" 6 6"," 1 5 1"," 1 9 1"," 111 1","13"," 3 1 1 3"," 2 1 1 2"," 2 1 1 2"," 2 2"," 3 1 3","11"," 1 2 1 1 2 1"," 3 3"," 7"," 1 1",]],
	#
	["Q023", 5, "Bomb", "vivisuke",
	[" 0"," 4"," 6"," 8","10","10","13"," 2 2 7"," 1 2 4"," 1 6"," 1 4"," 1"," 2 1"," 2 1 1"," 1",],
	[" 0"," 6"," 2 2"," 1 1"," 1"," 4 1"," 6 1 1"," 5 2 1"," 7 2"," 7 2","10","10"," 8"," 6"," 4",]],
	#
	["Q043", 5, "E = mc^2", "vivisuke",
	[" 5"," 1 1 1"," 0"," 1 1"," 1 1"," 0"," 3"," 1"," 2"," 1"," 2"," 0"," 4"," 1 2 1 1"," 2 1",],
	[" 0"," 2"," 1"," 1"," 2"," 2"," 1 2"," 2 2 2 1 1"," 1 1 1 1 1"," 2 2 1 1 1 2"," 0"," 0"," 0"," 0"," 0",]],
	#
	["Q024", 6, "Fan", "matoya",
	["1 1", "1 1", "1 1", "1 1", "1 1",	"", "4", "1 1", "1 1 2 1 1", "1 3 1 1",	"1 3 1 2", "1 2 1 1 2", "1 9", "4 2", "2"],
	["4", "1 1 1 1 1", "1 1 1 2 1 1", "1 3 2", "1 3 2",	"1 1 1 1 1 2 1", "1 1 1 1", "5", "1", "1",	"1", "1", "1", "4", "6"]],
	#
	["Q025", 6, "US Flag", "matoya",
	["13"," 5 1 1"," 5 1 1"," 5 1 1"," 5 1 1"," 5 1 1"," 1 1 1 1 1"," 1 1 1 1 1"," 1 1 1 1 1"," 1 1 1 2"," 1 1 1 1 1"," 1 1 1 1 1"," 1 1 1 1 1"," 8"," 0",],
	[" 3 2"," 2 3 1"," 1 6 2"," 6 3 1"," 9 2"," 6 3 1"," 4 3 2"," 3 2 3 1"," 1 1 4 1"," 3 2 2"," 1 1"," 3"," 1"," 1"," 1",]],
	#
	["Q026", 6, "Robot Guard", "vivisuke",
	["1", "2", "2", "5 2", "4 3 3", "5 1 2 3", "5 6", "4 7", "4 2 2 3", "4 2 2 3", "3 3 3", "4 2", "2", "2", "1"],
	["5", "7", "7", "8", "4 1", "1 2 1", "1 1 2 1", "1 1", "1 1 1", "7", "7", "2", "7", "13", "15"]],
	#
	["Q027", 6, "Husky", "vivisuke",
	["6", "4 2", "5 3", "1 2 1 2 2", "1 2 2 1 2",	"2 2 2 1", "2 1 3 1", "3 5 1", "2 1 3 1", "2 2 2 1",	"1 2 2 1 2", "1 2 1 2 2", "5 3", "4 2", "6"],
	["1 1", "1 1 1 1", "1 1 1 1", "11", "4 3 4",	"2 1 2", "2 3 3 2", "2 2 2 2", "1 3 1", "1 1 1 1 1",	"1 9 1", "2 5 2", "2 3 2", "3 3", "11"]],
	#
	["Q028", 6, "Atom", "vivisuke",
	["7", "3 1", "2", "4 3", "6 1 1 1",	"6 1", "6 1", "3 3 1", "4 1 1 1", "4",	"4", "4 1", "4 1 2", "3 2", "7"],
	["1", "2", "5", "8", "10",	"6 5", "1 3 6", "2 1 4", "1 3", "1 2 2 1",	"1 1 1 1 1", "1 2 2 1", "1 2", "1 2", "1 5 2"]],
	#
	["Q029", 7, "Knight", "vivisuke",
	[" 3"," 1 1"," 1 1 1 1"," 1 1 2"," 1 3"," 2 2"," 4 4 2"," 3 9"," 3 1 8"," 4 8"," 4 2 2"," 3 1 2 3 1"," 3 3 3 1"," 4 1 2"," 5",],
	[" 4"," 6"," 8"," 2 2 2"," 1 1 1 1"," 3 1 1"," 1 1 1 1"," 1 1 1 7"," 1 110"," 1 6 1"," 2 4 2 1"," 4 3 2 1"," 5 2 1"," 5 1"," 7",]],
	#
	["Q030", 8, "Piyo", "anmas",
	[" 2"," 2 3"," 1 1 5"," 3 7"," 2 1 4"," 1 4"," 1 3"," 1 2 3"," 1 3"," 1 3"," 1 3"," 2 3"," 7 4"," 2 3"," 1 3",],
	[" 0"," 0"," 8"," 2 2"," 1 1"," 3 1 1"," 1 1 1"," 1 1 1"," 1 1"," 1 3"," 2 1"," 6 1","15","14","13",]],
	#
	["Q031", 8, "Ball", "matoya",
	[" 5"," 2 2"," 1 2"," 2 1 1"," 1 1 1 1"," 1 1 2"," 1 3 2"," 1 1 1 3"," 2 1 1 1 5"," 2 3 1 4"," 2 1 7"," 4 4"," 4"," 3"," 2",],
	[" 0"," 6"," 2 2"," 1 2"," 1 1 1"," 1 1 1"," 1 4"," 1 1 1 1"," 1 1 1 1 2"," 2 1 3 2"," 2 1 1 1 1"," 2 1 7","11"," 9"," 5",]],
	#
	["Q032", 8, "Snake", "matoya",
	[" 1"," 2 2"," 4"," 5 4","12"," 210"," 3 2 3"," 2"," 4 3","10"," 2 4"," 2"," 3 2"," 3 1"," 1",],
	[" 0"," 3"," 5"," 4 1"," 6 3"," 4 5"," 2 3 2 1"," 1 3 2 2"," 3 2 1"," 3 2 1"," 3 2 1"," 4 3 1 1"," 7 1"," 5"," 0",]],
	#
	["Q033", 8, "Glasses Fox", "Yew",
	[" 6"," 4 2"," 4 3"," 3 1 2"," 1 1 1 1"," 1 1 2 1"," 1 1 1 1"," 1 2 2"," 1 1 1 1"," 1 1 2 1"," 1 1 1 1"," 3 1 2"," 4 3"," 4 2"," 6",],
	[" 1 1"," 3 3"," 4 4"," 4 5 4"," 2 2"," 1 1"," 1 1"," 1 1"," 1 4 4 1"," 2 1 2"," 2 1 1 1 2"," 5 5"," 1 1"," 2 1 2"," 3",]],
	#
	["Q034", 8, "Dog", "vivisuke",
	[" 6 5"," 4 2 3"," 3 4"," 2 2"," 2 1 1"," 1 1 1 2"," 1 2 1 1 1"," 1 2 1 1 1"," 1 1 1 2"," 2 1 1"," 2 2"," 3 4"," 4 4"," 6 5","15",],
	["15"," 5 6"," 3 4"," 2 3"," 1 2 2 2"," 1 2"," 4 1"," 1 1 2 1 1"," 1 1 1 1"," 1 6 1"," 1 1 1 1 1 2"," 3 2 4"," 3 4"," 2 4"," 1 2 3",]],
	#
	["Q035", 8, "Roar", "vivisuke",
	[" 1"," 3 1"," 5 2"," 8"," 8"," 9"," 9"," 1 3 3"," 7 2"," 5 2 1"," 2 3 2"," 2 2"," 0"," 0"," 0",],
	[" 0"," 1"," 2"," 3"," 5"," 3 3","10","11"," 9"," 6 1"," 5 1"," 5 1"," 6 1"," 2 4"," 2",]],
	#
	["Q036", 9, "Wave", "vivisuke",
	[" 1 1 2 1 1"," 2 2 1 1 1"," 1 5 1 2"," 2 3 3 2"," 1 1 8"," 1 1 9"," 1 1 3 3"," 2 3 1"," 2 1 1"," 1 1 1"," 2 1 1 1"," 3 2"," 1 1 1 1"," 1 2"," 0",],
	[" 5"," 3 2"," 2 3"," 2"," 1 1 1 2"," 1 3 2 1 1 1"," 2 1 2 1 1"," 2 4 1 1 1"," 3 3 2 1"," 1 5 1"," 1 3 1"," 1 4 1"," 1 3"," 1 5"," 7",]],
	#
	["Q037", 10, "Panda", "matoya",
	[" 2"," 4"," 2 4 6"," 4 1 2"," 3 2 1 2"," 1 1 1 1 1"," 1 2 1 1"," 1 1 1"," 1 2 1 1 2"," 1 1 1 1 3"," 3 2 1 2"," 4 3 1"," 2 4 6"," 5"," 3",],
	[" 2 2","11"," 3 3"," 1 2 2 1"," 1 1 1 1 1 1"," 1 2 2 1"," 1 1 1"," 1 1 1 1"," 1 1"," 1 9"," 2 3"," 3 3"," 3 2 3"," 4 3 3"," 4 5",]],
	#
	["Q041", 10, "clown", "matoya",
	[" 1 4"," 1 1 6"," 1 1 1 2 2"," 1 9 1"," 1 1 1 4 2"," 2 1 1 2 2"," 3 2 1"," 4 1 1"," 3 2 1"," 2 1 1 2 2"," 1 1 1 4 2"," 1 9 1"," 1 1 1 2 2"," 1 1 6"," 1 4",],
	[" 4 4"," 1 1 1 1"," 1 1"," 3 3"," 2 1 1 1 1 2"," 3 3 3"," 1 5 1"," 3 3 3"," 5 1 5"," 2 2 2 2"," 2 4 4 2"," 2 7 2"," 2 2"," 4 4"," 7",]],
	#
	["Q038", 11, "Tank", "vivisuke",
	[" 3"," 1 2 1"," 1 1 1 2"," 1 1 2 1"," 1 1 2 1"," 1 1 5"," 5 2 1"," 1 1 2 1"," 1 1 5"," 1 1 2 1"," 1 1 2 1"," 1 1 5"," 5 1 2"," 1 1 1"," 4 2",],
	[" 0"," 5"," 1 1"," 6 1"," 1 1"," 1 1","12"," 1 1"," 1 1"," 3 1"," 111"," 1 9 1"," 2 1 1 1 1"," 1 1 1 3","10",]],
	#
	["Q039", 12, "Honey Bee", "matoya",
	[" 3"," 1 2 4"," 1 3 3"," 8 1"," 1 6 2"," 6 2 2"," 6 1 1"," 5 2 1"," 4 1 1"," 1 2 2"," 5 1 1"," 2 2 1 2"," 2 1 6"," 1 1 3 1"," 1 1",],
	[" 1"," 2 1"," 1 1"," 2 1 1 3"," 8 2"," 110"," 8 1 3"," 1 2 3 2"," 8 3"," 6 2 1"," 1 3 3"," 5 1 2"," 2 1 3"," 7"," 1",]],
	#
	["Q040", 13, "SARS-CoV-2", "matoya",
	[" 3"," 2 1 2"," 2 4 2"," 8"," 7 1"," 2 4 1"," 2 6"," 2 8"," 4 7"," 9 1"," 6 1 1"," 5 3 1"," 1 3 3 1"," 1 4 1"," 1 1",],
	[" 1"," 1 4 1"," 2 8 1"," 1 3 5 1"," 2 4"," 1 3 5"," 6 4 1"," 1 9 2"," 8 2"," 1 8"," 1 1 3 2"," 2 5 2 1"," 1 4 1"," 1 1"," 1",]],
	#
	# max: "Q045"
]
#var test = 123

func _ready():
	pass # Replace with function body.
