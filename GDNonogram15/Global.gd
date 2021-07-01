extends Node2D

const solvedPatFileName = "user://saved.dat"
const settingsFileName = "user://settings.dat"

var solvedPatLoaded = false
var lvl_vscroll = 0		# レベルシーン スクロール位置
var solveMode = true
var qNumber = 0			# [#1, ...#N]
var qNum2QIX = []		# qNum (#1 ... #N) → QIX テーブル
var qix2ID = []			# qix → QID 配列
var settings = {}		# 設定辞書
var solvedPat = {}		# QID -> [data0, data1, ...] 辞書
#var solved = []			# true/false
var ans_images = []		# 解答ビットパターン配列
var quest_list = []		# ソート済み問題配列

enum {
	KEY_ID = 0,
	KEY_DIFFICULTY,
	KEY_TITLE,
	KEY_AUTHOR,
	KEY_V_CLUES,
	KEY_H_CLUES,
	}
var quest_list0 = [		# 非ソート済み問題配列
	["Q004", 1, "Albert", "mamimumemo",
	["", "", "", "", "1", "4", "3 1 1", "3 1", "3 1 1", "4", "1", "", "", "", ""],
	["", "", "", "1 1", "1 1", "1 1", "", "7", "1 1 1", "1 1 1", "1 1", "3", "", "", ""]],
	#
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
	["Q048", 3, "Germany", "vivisuke",
	["13"," 1 2"," 8 1 1"," 2 1"," 3 6 1 1"," 2 3 2"," 111 1","15","13 1"," 1 3 2"," 6 1 1"," 2 1"," 8 1 1"," 1 2","13",],
	[" 2 6 2"," 1 2 2 1"," 1 1 3 1"," 3 3 3","15"," 111 1"," 1 1 7 1 1"," 1 1 1 3 1 1 1"," 1 1 1 3 1 1 1"," 1 1 1 3 1 1 1"," 1 1 3 1 1"," 1 5 1"," 1 1 7 1 1"," 1 1 1"," 1 1 3 1 1",]],
	#
	["Q054", 3, "SACHIEL", "vivisuke",
	[" 4 3"," 1 2 3"," 1 1 7"," 1 8"," 6"," 3 7 1"," 1 1 4 5"," 1 1 4"," 1 1 4 5"," 3 7 1"," 3 2"," 1 8"," 1 1 7"," 1 2 3"," 4 3",],
	[" 3 1 1 3"," 1 9 1"," 1 2 2 1"," 1 1 1 1 1 1 1 1"," 1 3 1 1 1"," 1 4 4 1"," 5 5"," 2 5 2"," 2 2 2 2"," 2 1 1 2"," 2 2 2 2"," 3 3 3"," 3 3 3"," 2 3 2"," 1 5 1",],],
	#
	["Q055", 3, "Twin Tail", "vivisuke",
	["10"," 3 7"," 7"," 9 2"," 4 1 1 3"," 6 2 4"," 4 2 1 2"," 6 2 2"," 5 2 1 2"," 2 3 2 4"," 1 5 1 3"," 2 6 2"," 6"," 3 7","10",],
	[" 5"," 9"," 7 2","10 2"," 5 7"," 4 1 1 6"," 1 2 3 1"," 1 5 5 1"," 4 2 2 1 2"," 2 1 1 2"," 2 1 1 1 2"," 2 5 2"," 2 2 2 2"," 2 9 2"," 2 9 2",],],
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
	["Q047", 5, "Irohani", "vivisuke",
	[" 4 8"," 5 1"," 2 1 2"," 2 1 1 1 1 1"," 3 7"," 4 6"," 2 1 2"," 0"," 8"," 1 1"," 1 2 1 3"," 1 2 1 1 2"," 4 1 2 1"," 2 4 2 1"," 1 3 2 1",],
	[" 2 5"," 2 3 2"," 2 2 2"," 2 2 5"," 3 2 2 2"," 3 2"," 3"," 1 3 1"," 1 2 1 4"," 1 5 1 3"," 1 2 1 1"," 1 2 1 1"," 1 5 1 2"," 1 1 1 1 1 5"," 2 1 2",]],
	#
	["Q051", 5, "korosuke", "vivisuke",
	[" 0"," 3"," 6 1 3"," 2 7"," 1 2 1 3"," 1 1 1 2 1"," 1 2 1 1"," 1 2 1 2 1"," 1 1 1 1 1"," 1 2 1 3"," 1 1 1 3"," 4 7"," 1 5 1 1"," 3"," 0",],
	[" 3"," 5 1"," 2 2"," 2 2"," 1 2 2 1"," 1 1 1 1"," 1 1 1 1"," 1 5 1"," 3 1"," 111"," 3 1 1 1 1"," 1 3"," 3 3","10"," 3 3",],],
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
	["Q052", 6, "musume", "vivisuke",
	[" 1 2 1"," 6 2"," 6 4"," 4 2"," 9"," 5 1"," 1","11","11"," 3 1 1 2"," 3 1 4 1"," 1 1 6"," 5 3"," 5 2 1"," 1",],
	[" 0"," 2 2"," 2 2"," 2 7"," 6 2 2"," 2 2 7"," 2 2 2 2"," 2 2 7"," 2 2 2 2"," 2 1 2 2 1"," 3 2 2 1"," 3 2 2"," 2 2 6"," 2 4 3"," 0",],],
	#
	["Q056", 6, "Stag beetle", "vivisuke",
	[" 0"," 1 1"," 3 2 2"," 2 1 3"," 1 1 1 2"," 3 1 7"," 112","12"," 112"," 3 1 7"," 1 1 1 2"," 2 1 3"," 3 2 2"," 1 1"," 0",],
	[" 1 1"," 1 1"," 1 1 1 1"," 1 5 1"," 1 1 3 1 1"," 2 5 2"," 2 3 2"," 5","11"," 2 5 2"," 7"," 9"," 1 5 1"," 2 5 2"," 1 3 1",],],
	#
	["Q057", 6, "Giant-Robo", "vivisuke",
	[" 1 1 1 1 1"," 4 1 1 3"," 5 1 1 1 1 1"," 1 1 1 5 3"," 1 1 1 1 2 1"," 1 1 5 4"," 1 2 4 1"," 2 3"," 2 1"," 1 1"," 3"," 1 1 1"," 2 1"," 1 6 1 1"," 2 1 1 1",],
	[" 6 2"," 1 1 1"," 5"," 2 1"," 5 5"," 1 1 1 1 2"," 6 3 1"," 1 1 1"," 4 1 1"," 1 1 1"," 4 1 2"," 3"," 8 4"," 1 1 1 1"," 9 2",],],
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
	["Q053", 8, "Hokusai", "vivisuke",
	[" 1 1 2 1"," 2 1 2 2"," 2 4 2"," 1 3 1 2"," 1 2 2 1 2"," 1 1 1 2 1 1"," 1 1 2 1"," 1 1 1 1 1"," 1 2 2"," 1 2 2"," 2 1 2"," 1 2"," 1 3"," 1 3 1"," 1 1 2 1",],
	[" 0"," 0"," 4"," 2 1"," 2 1 1"," 2 1"," 4"," 3 2 1"," 1 1 1 1 1 2"," 6 4 1"," 2 5 1"," 1 1 1 1 3"," 2 1 2 4"," 1 2 1 5"," 2 2 1 2 2",],],
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
	["Q049", 10, "USSR", "vivisuke",
	[" 2"," 2"," 2"," 1"," 2"," 1 2"," 3 2"," 3 2"," 5 2"," 2 3 3"," 1 1 3 1"," 2 3"," 2 1 3"," 8 3"," 5 1",],
	[" 0"," 2"," 2"," 2"," 1"," 3 2"," 3 2"," 3 2"," 5 2"," 1 3 3"," 3 1"," 1 3"," 4 1 3"," 2 7 3"," 1 5 1",]],
	#
	["Q038", 11, "Tank", "vivisuke",
	[" 3"," 1 2 1"," 1 1 1 2"," 1 1 2 1"," 1 1 2 1"," 1 1 5"," 5 2 1"," 1 1 2 1"," 1 1 5"," 1 1 2 1"," 1 1 2 1"," 1 1 5"," 5 1 2"," 1 1 1"," 4 2",],
	[" 0"," 5"," 1 1"," 6 1"," 1 1"," 1 1","12"," 1 1"," 1 1"," 3 1"," 111"," 1 9 1"," 2 1 1 1 1"," 1 1 1 3","10",]],
	#
	["Q058", 11, "snails", "vivisuke",
	[" 2 6"," 4 3"," 1 2"," 4 2"," 2 5 1"," 2 2"," 9 1"," 2 2 1"," 2 1 1 1 1 1"," 1 1 1 1 1 1"," 1 1 1 2 1"," 1 2 1 1"," 2 4 3 1"," 2 2 1 1"," 7 3",],
	[" 2 2"," 2 2 5"," 1 1 2 2"," 3 2 2 2"," 1 1 1 1 2 1"," 1 1 1 1 1 1 1"," 1 1 1 1 1 1"," 1 1 1 1 1 1"," 1 1 1 1 1"," 2 2 1 2"," 1 3 1 2"," 2 7 1"," 2 3"," 3 1"," 9",],],
	#
	["Q059", 12, "Sparrow", "vivisuke",
	[" 1"," 3"," 1 4"," 4 2 1"," 5 1 1"," 6 1 1 1"," 6 3 1"," 5 1 1"," 9"," 6"," 5"," 3"," 2"," 1"," 0",],
	[" 0"," 3"," 1 3"," 7"," 7"," 1 5"," 1 5"," 1 6"," 1 6"," 1 6"," 8"," 1 3"," 2 1"," 2 2"," 2",],],
	#
	["Q039", 12, "Honey Bee", "matoya",
	[" 3"," 1 2 4"," 1 3 3"," 8 1"," 1 6 2"," 6 2 2"," 6 1 1"," 5 2 1"," 4 1 1"," 1 2 2"," 5 1 1"," 2 2 1 2"," 2 1 6"," 1 1 3 1"," 1 1",],
	[" 1"," 2 1"," 1 1"," 2 1 1 3"," 8 2"," 110"," 8 1 3"," 1 2 3 2"," 8 3"," 6 2 1"," 1 3 3"," 5 1 2"," 2 1 3"," 7"," 1",]],
	#
	["Q040", 13, "SARS-CoV-2", "matoya",
	[" 3"," 2 1 2"," 2 4 2"," 8"," 7 1"," 2 4 1"," 2 6"," 2 8"," 4 7"," 9 1"," 6 1 1"," 5 3 1"," 1 3 3 1"," 1 4 1"," 1 1",],
	[" 1"," 1 4 1"," 2 8 1"," 1 3 5 1"," 2 4"," 1 3 5"," 6 4 1"," 1 9 2"," 8 2"," 1 8"," 1 1 3 2"," 2 5 2 1"," 1 4 1"," 1 1"," 1",]],
	#
	["Q060", 16, "Kyoro-chan", "vivisuke",
	[" 0"," 4"," 2 2"," 1 2"," 2 3"," 4 2 1"," 1 1 2 1 2"," 1 3 2 1"," 9 1"," 2 1 1 2"," 2 2 2"," 6 2"," 9"," 5"," 0",],
	[" 3"," 1 3"," 3 4"," 3 1 2"," 1 5 2"," 1 3 3"," 1 7"," 1 1 4"," 1 2 2"," 2 3 2"," 4 1"," 2 2"," 1 2"," 6"," 1 1",],],
	#
	["Q046", 17, "T-Rex", "matoya",
	[" 2 1 1"," 2 1 1"," 4 1","10"," 8 1 1"," 7 1 1"," 2 5 1 1"," 2 2 2 1 2"," 5 2"," 1 3 2"," 1 1 1"," 2 2"," 4"," 4"," 3",],
	[" 1"," 4"," 3 2"," 3 1 2"," 7 3"," 7 3"," 5 6"," 7 4"," 5 3"," 1 3 2"," 1 1 1 2"," 1 4 1"," 1 1"," 1 1 2"," 1 1",]],
	#
	["Q050", 17, "Franken", "matoya",
	[" 1"," 1 3"," 6 2"," 7 2"," 4 1 1"," 2 2 3"," 2 1 1"," 2 2 1 1"," 5 1 1"," 2 1 2 3"," 4 1 1 1"," 7 2"," 6 2"," 1 3"," 3",],
	[" 9"," 9 1"," 5 1 5"," 3 1 3 1"," 2 1 2"," 2 4"," 2 2"," 2 2 2 2"," 1 1 1 1 1"," 2 1 2"," 1 1"," 1 3 1"," 1 1 1 1"," 2 2"," 5",],],
	#
	["Q061", 12, "Clionidae", "matoya",
	[" 2"," 1 1"," 1 1"," 2 1"," 1 1 3"," 2 3 3"," 1 3 3"," 7 6"," 3 7"," 1 3 1"," 1 1"," 1 1"," 1 1"," 1 1"," 2",],
	[" 1 1"," 4"," 1 2"," 1 2"," 2 5 4"," 1 2 3 2 1"," 1 3 2"," 1 1 1 2"," 2 3"," 6"," 5"," 3"," 2"," 2"," 1",],],
	#
	["Q062", 9, "King ghidorah", "matoya",
	[" 1"," 1 2 1"," 2 4"," 2 4"," 1 2 4 1"," 2 2 3 3"," 2 9","11"," 8"," 1 9"," 210"," 3 6 1"," 3 2"," 4 1"," 1 1 2",],
	[" 1"," 2 1"," 1 1 2"," 3 2 1"," 2 1 1"," 2 2 2"," 3 6 2"," 4 8","12","14"," 9"," 6 1"," 8 1"," 3 2 2"," 3 3",],],
	#
	["Q063", 21, "Godzilla ghidorah", "matoya",
	[" 1"," 2 1 1"," 4 1 3 1","14","12","10"," 110"," 1 8"," 1 4"," 1 3"," 3"," 2"," 2"," 3"," 1",],
	[" 2"," 4"," 3 1"," 5"," 3 1"," 4"," 6 1"," 5"," 6 1"," 7 1"," 7 1"," 7 1"," 8 2"," 2 2 4"," 2 2 2",],],
	#
	["Q064", 4, "sen-masao", "yoshipon",
	[" 0"," 3 8"," 5 2"," 4 1 1 1"," 3 1 1 1"," 3 1 3 1 2"," 3 1 1 1"," 3 1 1 1"," 3 1 1 2"," 3 1"," 3 1"," 4 1 1 2"," 6 1 1"," 5 2"," 8",],
	["11","13","14"," 3 4"," 1 1 3"," 1 2 3 3"," 1 1 1"," 1 1 1"," 1 1 1"," 1 1 1 1"," 1 2"," 1 6 1"," 2 2","10"," 1 1",],],
	#
	["Q065", 4, "rugby ball", "Yew",
	[" 3 3"," 6 2"," 9 1"," 4 1 4"," 6 6"," 5 1 5","11 2"," 2 1 6 1"," 4 6 2"," 3 1 4 2"," 9 3"," 7 3"," 1 5 3"," 2 6"," 3 3",],
	[" 3 3"," 6 2"," 9 1"," 4 1 4"," 6 6"," 5 1 5","14"," 2 1 6 1"," 4 6 2"," 3 1 4 2"," 9 3"," 7 3"," 1 4 3"," 2 6"," 3 3",],],
	#
	["Q066", 4, "manta", "Yew",
	[" 3 5","11"," 1 5 5"," 1 4 5","13","11"," 2 8"," 2 7"," 1 8","11","12"," 8 3"," 6 3"," 4 3"," 2 2",],
	[" 3 5","11"," 1 5 5"," 1 4 6","13","12"," 2 8"," 2 8"," 1 8","10","12"," 7 4"," 5 3"," 3 3"," 2 2",],],
	#
	["Q067", 5, "Pteranodon", "Yew",
	[" 1 1 5"," 1 1 6"," 1 1 4"," 3 4"," 4 5","10"," 1 6"," 6"," 1 8","12"," 7 2 2"," 5 1"," 3 2"," 2 1"," 1",],
	[" 5"," 4 6"," 6 4"," 3 4"," 3 2 5"," 6"," 6"," 6"," 1 8","12"," 7 2 2"," 5 1"," 3 2"," 2 1"," 1",],],
	#
	["Q068", 6, "Giant tortoise", "vivisuke",
	[" 2"," 4 4"," 1 7","11"," 4 6"," 2 1 8"," 3 1 7"," 1 5 6"," 1 1 1 3"," 1 2 2 3"," 1 1 8"," 2 2 1 3"," 2 1 1 5"," 3 1 6"," 4 5",],
	[" 5"," 2 1"," 3 3"," 1 3 2"," 2 1 1 1 1"," 3 1 2 2"," 3 2 1 1 1"," 2 3 1 2 2"," 7 5 1"," 7 1 1","13","14","14"," 3 3 3"," 3 3 3",],],
	#
	["Q069", 3, "Orima", "tanaka",
	[" 0"," 4"," 3 1 1 1"," 3 1 3 4"," 8 6"," 3 1 3 3"," 2 1 4"," 4 1 1 4"," 2 2 3 3"," 3 2 1 5"," 1 2 3 3"," 3 2 1 1"," 1 4"," 0"," 0",],
	[" 5"," 7"," 3 1 1"," 3 1 3"," 1 2 1 2"," 3 5"," 1 2"," 6"," 2 1 4"," 1 6 3"," 1 1 2 2 1"," 1 7 1","12"," 3 3"," 3 3",],],
	#
	["Q070", 3, "Christmas", "hayabusa",
	[" 1 1"," 2 2"," 6"," 8","13","14"," 8"," 7"," 3 2"," 1 1"," 0"," 1 3"," 4"," 4"," 1 3",],
	[" 0"," 1"," 2"," 4"," 5"," 7"," 8","10"," 6"," 8","10 1 1"," 2 2"," 2 4"," 2 4"," 2 4",],],
	#
	["Q071", 3, "face", "pollyanna",
	[" 0"," 0"," 9"," 2 2"," 1 2 1"," 1 2 1 1"," 1 1 1"," 1 1 1"," 1 1 1"," 1 2 1 1"," 1 2 1"," 2 2"," 9"," 0"," 0",],
	[" 0"," 0"," 9"," 2 2"," 1 1"," 1 2 2 1"," 1 2 2 1"," 1 1"," 1 1"," 1 5 1"," 1 1"," 2 2"," 9"," 0"," 0",],],
	#
	["Q072", 15, "Gonzou", "matoya",
	[" 4"," 5 2"," 5 2"," 2 1"," 2 1 1 5"," 2 1 1 1"," 2 1 1 1 1"," 2 1 1 2 1"," 2 2 1 2 1"," 2 1 1 2"," 2 1 1 5"," 2 1"," 5 3"," 5 1 2"," 4",],
	["11","13"," 2 2"," 2 2"," 2 2 3 2"," 2 3 2"," 1 1 1 1"," 1 1"," 2 5 1"," 1 1 1 1"," 1 1 3 1 1"," 1 1 2 1 1"," 2 3"," 7 1"," 1 1",],],
	#
	["Q073", 13, "Remamura", "matoya",
	[" 1 1"," 7 1 1 1"," 7 7"," 2 4 1"," 2 1 1"," 3 1 1"," 1 2"," 0"," 1 1 1 2"," 1 2 1 2"," 1 2 1 1 2"," 7 1 1 1"," 6 1 1 1"," 1 1 1 4"," 2",],
	[" 2 2"," 2 6"," 2 1 2"," 2 1 6"," 2 2 4"," 4 1 2"," 3 3 1"," 0"," 2 2"," 5 1"," 2 2 2"," 2 5"," 2 1 1 2"," 1 1 1 1 2"," 5 3",],],
	#
	["Q074", 14, "GuruGuru", "matoya",
	["13"," 1 1"," 1 9 1"," 1 1 1 1"," 1 1 5 1 1"," 1 1 1 1 1 1"," 1 1 1 1 1 1 1"," 1 1 1 1 1 1 1"," 1 1 1 3 1 1"," 1 1 1 1 1"," 1 1 7 1"," 1 1 1"," 111"," 1","12",],
	["12"," 1 1"," 1 9 1"," 1 1 1 1"," 1 1 5 1 1"," 1 1 1 1 1 1"," 1 1 1 1 1 1 1"," 1 1 1 1 1 1 1 1"," 1 1 1 1 1 1 1"," 1 1 1 1 1 1 1"," 1 1 3 1 1 1"," 1 1 1 1 1"," 1 7 1 1"," 1 1 1","11",],],
	#
	["Q075", 5, "Apple", "matoya",
	[" 0"," 4"," 8","11","12","12","10"," 210"," 310"," 212","12"," 4 5"," 2 2"," 0"," 0",],
	[" 2"," 3"," 2"," 3 3","11","11","11","10","10","11","11","11"," 9"," 9"," 2 2",],],
	#
	["Q076", 13, "ALIEN", "matoya",
	[" 0"," 1 2"," 2 1"," 1 1 1 1 1"," 2 1 4"," 2 2 5"," 3 7 1"," 3 9"," 6 4"," 4 2 2"," 4 1 3"," 4 1 3"," 2 2 1"," 1 1"," 0",],
	[" 4"," 7"," 5"," 4"," 8"," 6 3"," 1 4 1"," 1 2 1"," 1 1 3 4"," 5 1"," 1 6"," 1 2 2 2"," 6 2"," 2 2"," 2 1",],],
	#
	["Q077", 6, "sensu", "vivisuke",
	[" 1"," 3"," 5"," 6"," 6 1"," 2 2 1 1"," 2 2 1 1 1"," 2 3 1 2"," 2 2 1 1 1"," 2 2 1 1"," 6 1"," 6"," 5"," 3"," 1",],
	[" 0"," 0"," 3"," 7"," 4 4"," 4 4"," 6 6","13"," 3 3 3"," 1 1 1 1 1"," 1 1 1 1"," 1 1 1"," 1 1"," 1"," 3",],],
	#
	["Q078", 14, "wizard", "vivisuke",
	[" 0"," 0"," 2 2 1"," 3 2 1 1"," 1 4 1 1"," 1 1 2 2"," 1 4 2"," 3 1 1 2"," 2 1 4"," 1 1 3"," 1 4 2 1"," 2 1 2 1 2"," 2 8"," 2 1"," 1",],
	[" 4"," 2 2"," 2 1 1"," 3 1 1"," 2 3"," 2 3"," 5 2"," 2 1 6"," 2 1 5"," 1 6 1"," 1 1 1"," 1 1 2"," 1 1 1 2"," 1 1 1 1 1"," 1 2 1 1",],],
	#
	["Q079", 4, "witch", "vivisuke",
	[" 3 2"," 1 5 2"," 1 2 1 1"," 1 7"," 5 3"," 1 3"," 5 4"," 2 6"," 1 3 5"," 2 1 1 1 1"," 3 3 5"," 2 1 1 5"," 2 1 1 2 3"," 110 2"," 2 2 5",],
	[" 3"," 2 1"," 2 1"," 3 2 1"," 1 1 6"," 1 1 1 2 2"," 311"," 1 1 1 1 1 1"," 1 2 1 1 1 2"," 1 1 2 3"," 3 8"," 1 2 3 2 2"," 110 1"," 8 4"," 1 1 9",],],
	#
	["Q080", 5, "R2D2", "vivisuke",
	[" 0"," 0"," 2 2"," 1 7","12"," 2 1 3"," 2 2 2 1"," 1 1 1 2 2 1"," 1 1 2 1"," 1 1 3","12"," 1 7"," 2 2"," 0"," 0",],
	[" 3"," 2 1"," 2 1 1"," 1 1 1"," 9"," 1 1 1 1"," 1 1 3 1 1"," 2 3 2"," 2 2"," 2 1 2"," 2 1 2"," 2 2"," 9"," 4 4"," 1 1 1 1",],],
	#
	["Q081", 2, "Zoom", "vivisuke",
	["14"," 410"," 3 2 3"," 3 2 1 2"," 6 3","10 1","10 1 1","10 2 1","10 1 1","10 1"," 6 3"," 3 2 1 2"," 3 2 3"," 410","14",],
	["13","15","15"," 2 7 2"," 111 1","15"," 2 5 2"," 2 1 5 1 2"," 2 7 2","15"," 5 5"," 3 3 3"," 2 1 2"," 2 2"," 2 5 2",],],
	#
	["Q082", 2, "Controller", "vivisuke",
	[" 5","10"," 5 8"," 5 1 6"," 6 2 2"," 6 1"," 1 3 2"," 1 6"," 1 3 2"," 6 1"," 6 2 2"," 5 1 6"," 5 8","10"," 5",],
	[" 2 2"," 3 3"," 4 4","11"," 4 4"," 2 2 2 2"," 1 1 5 1 1"," 2 7 2"," 4 3 4"," 4 1 4"," 5 3 5","15"," 4 4"," 4 4"," 2 2",],],
	#
	["Q083", 6, "MaskedRider", "hi-kunn",
	[" 0"," 6"," 8"," 1 2 7"," 2 8 1"," 3 6 1"," 2 4 1 1"," 1 2"," 2 4 1 1"," 3 6 1"," 2 3 4 1"," 110"," 8"," 6"," 0",],
	[" 2 2"," 2 2"," 1 1"," 7"," 2 1 1 2"," 4 4"," 2 3 2 3"," 6 6"," 6 6"," 6 6"," 5 5"," 3 3"," 2 1 1 2"," 1 1 1"," 7",],],
	#
	["Q084", 7, "usagi", "AYAZOU",
	[" 0"," 0"," 5"," 5 1 2"," 1 1 1 1"," 1 3 3 1"," 1 1 1"," 8 2 1"," 5 1 1 1"," 1 1 1 1"," 1 3 3 1"," 1 1 1 2"," 8 2"," 5 6"," 0",],
	[" 0"," 4 4"," 1 2 2"," 1 2 2"," 1 1 2 1 2"," 1 1 2 1 2"," 1 1 2 1 2"," 1 2 1 2"," 1 2 2"," 1 1 1 1"," 1 2 3 1"," 1 1 1 1 1"," 1 2 1"," 2 3","10",],],
	#
	["Q085", 2, "Kuma-mon", "AYAZOU",
	["14"," 1 4 7"," 113"," 2 3 6"," 1 1 1 1 5"," 3 1 2 4"," 5 1 1 4"," 6 1 1 4"," 5 1 1 4"," 3 1 2 4"," 1 1 1 1 4"," 2 3 2 1"," 112"," 1 4 3","14",],
	[" 2 5 2"," 1 9 1"," 1 2 5 2 1"," 3 1 3 1 3"," 4 5 4"," 5 1 5"," 4 4"," 1 1 7 1 1"," 3 1 1 3"," 4 3 4"," 5 5","11 1 1","11 1 1","11 1 1","10 1 1",],],
	#
	["Q086", 6, "ping-pong", "matoya",
	[" 1"," 2 1"," 3 1 1"," 4 1 1"," 8 1","10 1","10 1","10 1"," 8 1 1"," 6 1 1"," 4 1 1"," 8 1"," 3 1"," 1 1"," 1",],
	[" 0"," 4"," 6"," 8","10","10","10"," 1 6 1"," 1 5 1"," 6 1"," 8"," 3"," 1"," 0","15",],],
	#
	["Q087", 6, "haniwa", "matoya",
	[" 0"," 3"," 1 1"," 1 1","14"," 311","15"," 2 1 8","15"," 212","14"," 1"," 1 1"," 3"," 0",],
	[" 5"," 7"," 3 1 1"," 1 1 3 1"," 3 3 1"," 7 1"," 3 3 1","11"," 1 7"," 1 7"," 1 7"," 9"," 7"," 7"," 7",],],
	#
	["Q088", 6, "whale", "matoya",
	[" 2"," 2 4"," 1 2 1"," 1 4"," 6 4"," 1 6"," 1 7"," 2 3 1"," 3"," 3"," 2"," 1 2"," 2 2"," 4 2"," 5",],
	[" 0"," 2 2"," 1 1 1"," 1 1 1"," 1 1"," 1 2"," 1 4"," 1 3"," 3 2 1","10 2"," 211","12"," 3"," 2"," 2",],],
	#
	["Q089", 3, "Peache", "ningenmame",
	[" 5 2","11"," 3 1 2 1"," 3 1 2 1"," 2 4 1 1"," 2 6 3"," 210","13","14","15","12 1","12 1","10 1","11"," 5 2",],
	[" 5"," 9"," 3 6"," 3 7"," 2 8"," 210"," 211"," 311"," 212"," 211"," 2 9"," 4 9"," 2 9 2"," 2 2 2 2"," 3 3",],],
	#
	["Q090", 13, "Tobacco & ashtray", "matoya",
	[" 3"," 4"," 3 1"," 1 2 1"," 2 3 1"," 4 3"," 2 3"," 2 1"," 2 1"," 2 1"," 2 1"," 2 1"," 2 1"," 2 4"," 2 3",],
	[" 0"," 1"," 1"," 1"," 1 2"," 1 2"," 1 1"," 2 2"," 2 4"," 1 4"," 2 1 4 2"," 2 4 2"," 2 2 2","13"," 0",],],
	#
	["Q091", 3, "gufufu", "daityatya",
	[" 0"," 0"," 1"," 2 1"," 1 1"," 1"," 1"," 1"," 1"," 1 3"," 2 1"," 1"," 0"," 0"," 0",],
	[" 0"," 0"," 0"," 0"," 3 3"," 1 1"," 0"," 0"," 0"," 0"," 0"," 8"," 1"," 1"," 0",],],
	#
	["Q092", 6, "sanjou", "zennpai",
	[" 0"," 1"," 1"," 6"," 1"," 1"," 1"," 1 2"," 1 2"," 1 2"," 1 2","10"," 1"," 1"," 0",],
	[" 0"," 1 1"," 1 1"," 1 1","13"," 1 1"," 1 1"," 1"," 1"," 1"," 2"," 2"," 2"," 2"," 1",],],

]
#var test = 123

func _ready():
	pass # Replace with function body.
