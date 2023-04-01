script_name('Binder for CO by Belka')

local squadsize = 15.0
local inicfg = require 'inicfg'
local regex = require 'rex_pcre'
local bass = require "lib.bass"
local memory = require 'memory'
local vkeys = require 'vkeys'
local imgui = require 'imgui'
local encoding = require 'encoding'
local ffi = require 'ffi'
local ev = require 'lib.samp.events'
local pie = require 'imgui_piemenu'
local rkeys = require 'rkeys'
local lfs = require 'lfs'
local dlstatus = require('moonloader').download_status
imgui.ToggleButton = require('imgui_addons').ToggleButton
encoding.default = 'CP1251'
u8 = encoding.UTF8
local V = 2.91

ffi.cdef[[
int SendMessageA(int, int, int, int);
unsigned int GetModuleHandleA(const char* lpModuleName);
short GetKeyState(int nVirtKey);
bool GetKeyboardLayoutNameA(char* pwszKLID);
int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
]]

----- ЗАГРУЖАЕМ КОНФИГ 
local def_ini = {
		HotKey = {
			[1] = "0", [2] = "0", [3] = "0", [4] = "0", [5] = "0", [6] = "0", [7] = "0", [8] = "0", [9] = "0", [10] = "0", -- 1 рация, 2 - угон матика, 3 меню докладов, 4 контекстная клавиша, 5 спросить паспорт, 6 отдалитесь от грузовика, 7 немедленно остановитесь, 8 покиньте зону, 9 работает дельта, 10 меню клист
			[11] = "0", [12] = "0", [13] = "0", [14] = "0", [15] = "0", [16] = "0", [17] = "0", [18] = "0", [19] = "0", [20] = "0", -- 11 лечение, 12 удостоверение, 13 - /lock, 14 - внимание на точку, 15 не используется, 16 - не используется, 17 - не используется, 18 - не используется, 19 поиск игрока в members, 20 здравия желаю т.,
			[21] = "0", [22] = "0", [23] = "0", [24] = "0", [25] = "0", [26] = "0", [27] = "0", [28] = "0", [29] = "0", [30] = "0", -- 21 свой квадрат в рацию, 22 быстрое снятие клитса, 23 меню поставок, 24 - не используется, 25 чс, 26 здравия желаю, 27-30 юсербинды
			[31] = "0", [32] = "0", [33] = "0", [34] = "0", [35] = "0", [36] = "0", [37] = "0", [38] = "0", [39] = "0", [40] = "0", -- 31-37 юсербинды, 38-40 - не используется
			[41] = "0", [42] = "0", [43] = "0", [44] = "0", [45] = "0", [46] = "0", [47] = "0", [48] = "0", [49] = "0", [50] = "0", -- 41 зажатие клавиши движения, 42 рандомная фраза, 43 настройка оверлея, 44 - piemenu
			[51] = "0", [52] = "0" -- 45-51 - выбор оружия, 52 - стоп-кран
		},

		Commands = {
				[1] = "ob", [2] = "sopr", [3] = "zgruz", [4] = "rgruz", [5] = "bgruz", [6] = "kv", [7] = "e", [8] = "", [9] = "r", [10] = "pr",
				[11] = "hey", [12] = "gr", [13] = "hit", [14] = "cl", [15] = "rk", [16] = "memb", [17] = "chs", [18] = "mp", [19] = "z", [20] = "mem1",
				[21] = "sw", [22] = "st", [23] = "mask", [24] = "", [25] = "afk", [26] = "", [27] = "mcall", [28] = "showp", [29] = ""
		},

		UserBinder = {
				[1] = "", [2] = "", [3] = "", [4] = "", [5] = "", [6] = "", [7] = "", [8] = "", [9] = "", [10] = "",
				[11] = "",
		},

		UserCBinder = {
				[1] = "", [2] = "", [3] = "", [4] = "", [5] = "", [6] = "", [7] = "", [8] = "", [9] = "", [10] = "",
				[11] = "", [12] = "", [13] = "", [14] = ""
		},

		UserCBinderC = {
				[1] = "", [2] = "", [3] = "", [4] = "", [5] = "", [6] = "", [7] = "", [8] = "", [9] = "", [10] = "",
				[11] = "", [12] = "", [13] = "", [14] = ""
		},

		UserPieMenuNames = {[1] = "", [2] = "", [3] = "", [4] = "", [5] = "", [6] = "", [7] = "", [8] = "", [9] = "", [10] = ""},

		UserPieMenuActions = {[1] = "", [2] = "", [3] = "", [4] = "", [5] = "", [6] = "", [7] = "", [8] = "", [9] = "", [10] = ""},

		UserClist = {
				[1] = "повязку №1", [2] = "повязку №2", [3] = "повязку №3", [4] = "повязку №4",
				[5] = "повязку №5", [6] = "повязку №6", [7] = "повязку №7", [8] = "повязку №8", [9] = "повязку №9",
				[10] = "повязку №10", [11] = "повязку №11", [12] = "кевларовую каску \"С.О.П.Т.\"", [13] = "повязку №13", [14] = "повязку №14",
				[15] = "повязку №15", [16] = "повязку №16", [17] = "повязку №17", [18] = "повязку №18", [19] = "повязку №19",
				[20] = "повязку №20", [21] = "повязку №21", [22] = "повязку №22", [23] = "повязку №23", [24] = "повязку №24",
				[25] = "повязку №25", [26] = "повязку №26", [27] = "повязку №27", [28] = "повязку №28", [29] = "повязку №29",
				[30] = "повязку №30", [31] = "повязку №31", [32] = "повязку №32", [33] = "повязку №33"
		},
		
		UserGun = {
			[1] = "тактический пистолет \"SD Pistol\"", [2] = "пистолет \"Desert Eagle\"", [3] = "дробовик \"Shotgun\"", [4] = "пистолет-пулемет \"HK MP-5\"",
			[5] = "штурмовую винтовку \"M4A1\"", [6] = "штурмовую винтовку \"AK-47\"", [7] = "снайперскую винтовку \"Country Rifle\""
		},

		bools = {
				[1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0, [7] = 0, [8] = 0, [9] = 0, [10] = 0, -- 1 не используется, 2 - отыгровка проверки на ЧС, 3 - воинское приветствие в "Здравия желаю", 4 - 10 ентер в юсер биндер
				[11] = 0, [12] = 0, [13] = 0, [14] = 0, [15] = 0, [16] = 0, [17] = 0, [18] = 0, [19] = 0, [20] = 0, -- 11 - 14 - ентер в юсер биндере, 15 - варнинг на грибы, 16-17 не испольщуюся, 18 братт дигл в автоБП, 19 - брать шот в автобп, 20 - брать смг в автобп
				[21] = 0, [22] = 0, [23] = 0, [24] = 0, [25] = 0, [26] = 0, [27] = 0, [28] = 0, [29] = 0, [30] = 0, -- 21 - брать м4 в автобп, 22 - брать рифлу в автобп, 23 - брать парашют в автобп, 24 - отыгрывать взятие со склада, 25 - разрешить overlay, 26 - тек. район, 27 - свой ник и id, 28 - инфа о тек. автомобиле, 29 - РК, 30 - АФК,
				[31] = 0, [32] = 0, [33] = 0, [34] = 0, [35] = 0, [36] = 0, [37] = 0, [38] = 0, [39] = 0, [40] = 0, -- 31 - о таргете, 32 - ХП и бронь, 33 - тех информация, 34 - дата и время, 35 - супермемберс, 36 - ХП тачек, 37 - раскладка, 38 - дамаг информер, 39 - подсветка ника в рации, 40 - включить варнинг на упоминание тебя в рации
				[41] = 0, [42] = 0, [43] = 0, [44] = 0, [45] = 0, [46] = 0, [47] = 0, [48] = 0, [49] = 0, [50] = 0, -- 41 - подсветка сквада, 42 - синхронизация цвета с водителем, 43 - заменить +500, 44 - информация о нанесенном уроне, 45 - лифт, 46 - телепорт в комнате БК, 47 - пропускать переодевание, 48 пропускать карм, 49 автоматом покупать защиту, 50 - автоматом покупать ремки/защиту, 
				[51] = 0, [52] = 0, [53] = 0, [54] = 0, [55] = 0, [56] = 0, [57] = 0, [58] = 0, [59] = 0, [60] = 0, -- 51 - принимать предложения механиков, 52 - показывать историю тычек, 53 - автоматическая заправка на АЗС, 54 - таймер смерти в квадрате, 55 - /q информер, 56 - использовать перенос слов в чате, 57 - автоматический предохранитель, 58 - включить счетчик фонда отряда, 59 - автоканистра, 60 - оружие на кнопки
				[61] = 0, [62] = 0, [63] = 0, [64] = 0, [65] = 0, [66] = 0, [67] = 0, [68] = 0, [69] = 0, [70] = 0, -- 61 - инвентарь, 62 - чекер квартир, 63 - дамаг информер по машине, 64 - панель состояния, 65 - индикатор направления обстрела
				[71] = 0, [72] = 0, [73] = 0, [74] = 0, [75] = 0, [76] = 0, [77] = 0, [78] = 0, [79] = 0, [80] = 0
		},

		rphr = {
				[1] = "", [2] = "", [3] = "", [4] = "", [5] = "", [6] = "", [7] = "", [8] = "", [9] = "", [10] = ""
		},

		warnings = {
				[1] = "", [2] = "", [3] = "", [4] = ""
		},

		ovCoords = {
				["show_timeX"] = 1551, ["show_timeY"] = 18,
				["show_placeX"] = 48, ["show_placeY"] = 796,
				["show_nameX"] = 48, ["show_nameY"] = 1020,
				["show_vehX"] = 1163, ["show_vehY"] = 1024,
				["show_targetImageX"] = 998, ["show_targetImageY"] = 332,
				["show_hpX"] = 1628, ["show_hpY"] = 85,
				["crosCarX"] = 800, ["crosCarY"] = 600,
				["show_rkX"] = 326, ["show_rkY"] = 822,
				["show_afkX"] = 326, ["show_afkY"] = 852,
				["show_tecinfoX"] = 1135, ["show_tecinfoY"] = 668,
				["show_squadX"] = 50, ["show_squadY"] = 500,
				["show_500X"] = 1620, ["show_500Y"] = 780,
				["show_dindX"] = 326, ["show_dindY"] = 952,
				["show_damX"] = 200, ["show_damY"] = 200,
				["show_dam2X"] = 250, ["show_dam2Y"] = 200,
				["show_deathX"] = 326, ["show_deathY"] = 792,
				["show_moneyX"] = 1574, ["show_moneyY"] = 28,
				["show_vehdamagetX"] = 1200, ["show_vehdamagetY"] = 800,
				["show_vehdamagemX"] = 600, ["show_vehdamagemY"] = 800,
				["show_panelX"] = 1135, ["show_panelY"] = 868,
		},

		Settings = {["dinf1"] = 0, ["dinf2"] = 0, ["PlayerRank"] = "", ["PlayerSecondName"] = "", ["UserSex"] = 0, ["PlayerFirstName"] = "", ["PlayerU"] = "С.О.П.Т.", ["tag"] = "|| С.О.П.Т. ||", ["useclist"] = "12", ["timep"] = "0"},
		
		plus500 = {[1] = "FF00FF", [2] = "54", [3] = "times"},

		fondset = {[1] = "b30000", [2] = "00FF00"},

		dial = {[1] = "10000", [2] = "5000", [3] = "3000", [4] = "3000"},
}

local def_ini2 = {
	Settings = {["dinf1"] = 0, ["dinf2"] = 0},
}

local def_ini3 = {
	day_info = {["today"] = os.date("%a"), ["online"] = 0, ["afk"] = 0, ["full"] = 0 },

	week_info = {["week"] = 1, ["online"] = 0, ["afk"] = 0, ["full"] = 0},

	online = {[0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0},

	tec_info = {[1] = "0", [2] = "0", [3] = "0", [4] = "0", [5] = "0", [6] = "0", [7] = "0"}, -- информация для панели состояний 1 - время приобретения последней защиты от ран, 2 - количество ремок, 3 - наличие канистры (0 - нет), 4 - наличие нарко (0 - нет), 5 - маты (0 - нет), 6 - ключи (0 - нет), 7 - набор для взлома (0 нет)
}


local access = {["alevel"] = -1, ["isglory"] = false, ["state"] = -1, ["key"] = "", ["saccess"] = false, ["backup"] = false}
local def_bl = {nicks = {}}
local blarr = inicfg.load(def_bl, "bl")
local config_ini = inicfg.load(def_ini, "config") -- загружаем ини
local online_ini = inicfg.load(def_ini3, "online.ini") -- загружаем ини
local dinf_ini = inicfg.load(def_ini2, "dinf.ini") -- загружаем ини

if os.remove("" .. thisScript().directory .. "\\config\\config.ini") == nil then 
	access.backup = true
else
	inicfg.save(config_ini, "config")
end
-- Настроки персонажа
local PlayerU = config_ini.Settings.PlayerU
local tag = config_ini.Settings.tag == "" and "" or "" .. config_ini.Settings.tag .. " "
local RP = config_ini.Settings.UserSex == 1 and "a" or ""
local useclist = config_ini.Settings.useclist


----- ТЕХНИЧЕСКИЕ ПЕРЕМЕННЫЕ
-- Раздел модераторов
local skipresponse = -1
local pedskol = 0
-- Imgui
local guis = {["mainw"] = imgui.ImBool(false), ["updatestatus"] = {["status"] = imgui.ImBool(false), ["wn"] = {}}}
local maintabs = {
		tab_main_binds = {
				["status"] = true, ["first"] = true, ["clistparams"] = false, ["gunparams"] = imgui.ImBool(false),
		},

		tab_user_binds = {
				["status"] = false, ["hk"] = true, ["cmd"] = false, ["pie"] = false
		},

		tab_bbot = {
				["status"] = false
		},

		tab_commands = {
				["status"] = false, ["first"] = true, ["second"] = false, ["help"] = imgui.ImBool(false), ["money"] = imgui.ImBool(false)
		},

		tab_overlay = {
				["status"] = false
		},

		tab_settings = {
				["status"] = false
		},

		user_keys = {
				["status"] = imgui.ImBool(false)
		},

		rphr = {
				["status"] = imgui.ImBool(false)
		},

		auto_bp = {
				["status"] = imgui.ImBool(false)
		},

		warnings = {
				["status"] = imgui.ImBool(false)
		},
		
		pl500 = {
				["status"] = imgui.ImBool(false)
		},
		
		squad = {
				["status"] = imgui.ImBool(false)
		},

		tab_skipd = {
			["status"] = imgui.ImBool(false)
		},

		tab_weap = {
			["status"] = imgui.ImBool(false)
		},
		
}
local suspendkeys = 2 -- 0 хоткеи включены, 1 -- хоткеи выключены -- 2 хоткеи необходимо включить
local guibuffers = {
		clistparams = {
				["clist1"] = imgui.ImBuffer(u8(config_ini.UserClist[1]), 256), ["clist2"] = imgui.ImBuffer(u8(config_ini.UserClist[2]), 256), ["clist3"] = imgui.ImBuffer(u8(config_ini.UserClist[3]), 256),
				["clist4"] = imgui.ImBuffer(u8(config_ini.UserClist[4]), 256), ["clist5"] = imgui.ImBuffer(u8(config_ini.UserClist[5]), 256), ["clist6"] = imgui.ImBuffer(u8(config_ini.UserClist[6]), 256),
				["clist7"] = imgui.ImBuffer(u8(config_ini.UserClist[7]), 256), ["clist8"] = imgui.ImBuffer(u8(config_ini.UserClist[8]), 256), ["clist9"] = imgui.ImBuffer(u8(config_ini.UserClist[9]), 256),
				["clist10"] = imgui.ImBuffer(u8(config_ini.UserClist[10]), 256), ["clist11"] = imgui.ImBuffer(u8(config_ini.UserClist[11]), 256), ["clist12"] = imgui.ImBuffer(u8(config_ini.UserClist[12]), 256),
				["clist13"] = imgui.ImBuffer(u8(config_ini.UserClist[13]), 256), ["clist14"] = imgui.ImBuffer(u8(config_ini.UserClist[14]), 256), ["clist15"] = imgui.ImBuffer(u8(config_ini.UserClist[15]), 256),
				["clist16"] = imgui.ImBuffer(u8(config_ini.UserClist[16]), 256), ["clist17"] = imgui.ImBuffer(u8(config_ini.UserClist[17]), 256), ["clist18"] = imgui.ImBuffer(u8(config_ini.UserClist[18]), 256),
				["clist19"] = imgui.ImBuffer(u8(config_ini.UserClist[19]), 256), ["clist20"] = imgui.ImBuffer(u8(config_ini.UserClist[20]), 256), ["clist21"] = imgui.ImBuffer(u8(config_ini.UserClist[21]), 256),
				["clist22"] = imgui.ImBuffer(u8(config_ini.UserClist[22]), 256), ["clist23"] = imgui.ImBuffer(u8(config_ini.UserClist[23]), 256), ["clist24"] = imgui.ImBuffer(u8(config_ini.UserClist[24]), 256),
				["clist25"] = imgui.ImBuffer(u8(config_ini.UserClist[25]), 256), ["clist26"] = imgui.ImBuffer(u8(config_ini.UserClist[26]), 256), ["clist27"] = imgui.ImBuffer(u8(config_ini.UserClist[27]), 256),
				["clist28"] = imgui.ImBuffer(u8(config_ini.UserClist[28]), 256), ["clist29"] = imgui.ImBuffer(u8(config_ini.UserClist[29]), 256), ["clist30"] = imgui.ImBuffer(u8(config_ini.UserClist[30]), 256),
				["clist31"] = imgui.ImBuffer(u8(config_ini.UserClist[31]), 256), ["clist32"] = imgui.ImBuffer(u8(config_ini.UserClist[32]), 256), ["clist33"] = imgui.ImBuffer(u8(config_ini.UserClist[33]), 256)
		},
		
		gunparams = {
			["gun1"] = imgui.ImBuffer(u8(config_ini.UserGun[1]), 256), ["gun2"] = imgui.ImBuffer(u8(config_ini.UserGun[2]), 256), ["gun3"] = imgui.ImBuffer(u8(config_ini.UserGun[3]), 256),
			["gun4"] = imgui.ImBuffer(u8(config_ini.UserGun[4]), 256), ["gun5"] = imgui.ImBuffer(u8(config_ini.UserGun[5]), 256), ["gun6"] = imgui.ImBuffer(u8(config_ini.UserGun[6]), 256),
			["gun7"] = imgui.ImBuffer(u8(config_ini.UserGun[7]), 256)
		},

		ubinds = {
				["bind1"] = imgui.ImBuffer(u8(config_ini.UserBinder[1]), 512), ["bind2"] = imgui.ImBuffer(u8(config_ini.UserBinder[2]), 512), ["bind3"] = imgui.ImBuffer(u8(config_ini.UserBinder[3]), 512),
				["bind4"] = imgui.ImBuffer(u8(config_ini.UserBinder[4]), 512), ["bind5"] = imgui.ImBuffer(u8(config_ini.UserBinder[5]), 512), ["bind6"] = imgui.ImBuffer(u8(config_ini.UserBinder[6]), 512),
				["bind7"] = imgui.ImBuffer(u8(config_ini.UserBinder[7]), 512), ["bind8"] = imgui.ImBuffer(u8(config_ini.UserBinder[8]), 512), ["bind9"] = imgui.ImBuffer(u8(config_ini.UserBinder[9]), 512),
				["bind10"] = imgui.ImBuffer(u8(config_ini.UserBinder[10]), 512), ["bind11"] = imgui.ImBuffer(u8(config_ini.UserBinder[11]), 512)
		},

		ucbinds = {
				["bind1"] = imgui.ImBuffer(u8(config_ini.UserCBinder[1]), 512), ["bind2"] = imgui.ImBuffer(u8(config_ini.UserCBinder[2]), 512), ["bind3"] = imgui.ImBuffer(u8(config_ini.UserCBinder[3]), 512),
				["bind4"] = imgui.ImBuffer(u8(config_ini.UserCBinder[4]), 512), ["bind5"] = imgui.ImBuffer(u8(config_ini.UserCBinder[5]), 512), ["bind6"] = imgui.ImBuffer(u8(config_ini.UserCBinder[6]), 512),
				["bind7"] = imgui.ImBuffer(u8(config_ini.UserCBinder[7]), 512), ["bind8"] = imgui.ImBuffer(u8(config_ini.UserCBinder[8]), 512), ["bind9"] = imgui.ImBuffer(u8(config_ini.UserCBinder[9]), 512),
				["bind10"] = imgui.ImBuffer(u8(config_ini.UserCBinder[10]), 512),["bind11"] = imgui.ImBuffer(u8(config_ini.UserCBinder[11]), 512), ["bind12"] = imgui.ImBuffer(u8(config_ini.UserCBinder[12]), 512),
				["bind13"] = imgui.ImBuffer(u8(config_ini.UserCBinder[13]), 512), ["bind14"] = imgui.ImBuffer(u8(config_ini.UserCBinder[14]), 512)
		},

		ucbindsc = {
				["bind1"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[1]), 512), ["bind2"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[2]), 512), ["bind3"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[3]), 512),
				["bind4"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[4]), 512), ["bind5"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[5]), 512), ["bind6"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[6]), 512),
				["bind7"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[7]), 512), ["bind8"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[8]), 512), ["bind9"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[9]), 512),
				["bind10"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[10]), 512), ["bind11"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[11]), 512), ["bind12"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[12]), 512),
				["bind13"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[13]), 512), ["bind14"] = imgui.ImBuffer(u8(config_ini.UserCBinderC[14]), 512)
		},

		rphr = {
				["bind1"] = imgui.ImBuffer(u8(config_ini.rphr[1]), 256), ["bind2"] = imgui.ImBuffer(u8(config_ini.rphr[2]), 256), ["bind3"] = imgui.ImBuffer(u8(config_ini.rphr[3]), 256),
				["bind4"] = imgui.ImBuffer(u8(config_ini.rphr[4]), 256), ["bind5"] = imgui.ImBuffer(u8(config_ini.rphr[5]), 256), ["bind6"] = imgui.ImBuffer(u8(config_ini.rphr[6]), 256),
				["bind7"] = imgui.ImBuffer(u8(config_ini.rphr[7]), 256), ["bind8"] = imgui.ImBuffer(u8(config_ini.rphr[8]), 256), ["bind9"] = imgui.ImBuffer(u8(config_ini.rphr[9]), 256),
				["bind10"] = imgui.ImBuffer(u8(config_ini.rphr[10]), 256)
		},

		settings = {
				["fname"] = imgui.ImBuffer(u8(config_ini.Settings.PlayerFirstName), 256), ["sname"] = imgui.ImBuffer(u8(config_ini.Settings.PlayerSecondName), 256), 
				["rank"] = imgui.ImBuffer(u8(config_ini.Settings.PlayerRank), 256), ["PlayerU"] = imgui.ImBuffer(u8(config_ini.Settings.PlayerU), 256),
				["useclist"] = imgui.ImBuffer(u8(config_ini.Settings.useclist), 256), ["tag"] = imgui.ImBuffer(u8(config_ini.Settings.tag), 256), ["timep"] = imgui.ImBuffer(u8(config_ini.Settings.timep), 256), 
		},

		commands = {
				["command1"] = imgui.ImBuffer(u8(config_ini.Commands[1]), 256), ["command2"] = imgui.ImBuffer(u8(config_ini.Commands[2]), 256), ["command3"] = imgui.ImBuffer(u8(config_ini.Commands[3]), 256),
				["command4"] = imgui.ImBuffer(u8(config_ini.Commands[4]), 256), ["command5"] = imgui.ImBuffer(u8(config_ini.Commands[5]), 256), ["command6"] = imgui.ImBuffer(u8(config_ini.Commands[6]), 256),
				["command7"] = imgui.ImBuffer(u8(config_ini.Commands[7]), 256), ["command8"] = imgui.ImBuffer(u8(config_ini.Commands[8]), 256), ["command9"] = imgui.ImBuffer(u8(config_ini.Commands[9]), 256),
				["command10"] = imgui.ImBuffer(u8(config_ini.Commands[10]), 256), ["command11"] = imgui.ImBuffer(u8(config_ini.Commands[11]), 256), ["command12"] = imgui.ImBuffer(u8(config_ini.Commands[12]), 256),
				["command13"] = imgui.ImBuffer(u8(config_ini.Commands[13]), 256), ["command14"] = imgui.ImBuffer(u8(config_ini.Commands[14]), 256), ["command15"] = imgui.ImBuffer(u8(config_ini.Commands[15]), 256),
				["command16"] = imgui.ImBuffer(u8(config_ini.Commands[16]), 256), ["command17"] = imgui.ImBuffer(u8(config_ini.Commands[17]), 256), ["command18"] = imgui.ImBuffer(u8(config_ini.Commands[18]), 256),
				["command19"] = imgui.ImBuffer(u8(config_ini.Commands[19]), 256), ["command20"] = imgui.ImBuffer(u8(config_ini.Commands[20]), 256), ["command21"] = imgui.ImBuffer(u8(config_ini.Commands[21]), 256),
				["command22"] = imgui.ImBuffer(u8(config_ini.Commands[22]), 256), ["command23"] = imgui.ImBuffer(u8(config_ini.Commands[23]), 256), ["command24"] = imgui.ImBuffer(u8(config_ini.Commands[24]), 256),
				["command25"] = imgui.ImBuffer(u8(config_ini.Commands[25]), 256), ["command26"] = imgui.ImBuffer(u8(config_ini.Commands[26]), 256), ["command27"] = imgui.ImBuffer(u8(config_ini.Commands[27]), 256),
				["command28"] = imgui.ImBuffer(u8(config_ini.Commands[28]), 256), ["command29"] = imgui.ImBuffer(u8(config_ini.Commands[29]), 256)
		},

		warnings = {
			["war1"] = imgui.ImBuffer(u8(config_ini.warnings[1]), 256),
			["war2"] = imgui.ImBuffer(u8(config_ini.warnings[2]), 256),
			["war3"] = imgui.ImBuffer(u8(config_ini.warnings[3]), 256),
			["war4"] = imgui.ImBuffer(u8(config_ini.warnings[4]), 256),
		},

		UserPieMenu = {
				names = {
						["name1"] = imgui.ImBuffer(u8(config_ini.UserPieMenuNames[1]), 256), ["name2"] = imgui.ImBuffer(u8(config_ini.UserPieMenuNames[2]), 256), ["name3"] = imgui.ImBuffer(u8(config_ini.UserPieMenuNames[3]), 256),
						["name4"] = imgui.ImBuffer(u8(config_ini.UserPieMenuNames[4]), 256), ["name5"] = imgui.ImBuffer(u8(config_ini.UserPieMenuNames[5]), 256), ["name6"] = imgui.ImBuffer(u8(config_ini.UserPieMenuNames[6]), 256),
						["name7"] = imgui.ImBuffer(u8(config_ini.UserPieMenuNames[7]), 256), ["name8"] = imgui.ImBuffer(u8(config_ini.UserPieMenuNames[8]), 256), ["name9"] = imgui.ImBuffer(u8(config_ini.UserPieMenuNames[9]), 256),
						["name10"] = imgui.ImBuffer(u8(config_ini.UserPieMenuNames[10]), 256)
				},

				actions = {
						["action1"] = imgui.ImBuffer(u8(config_ini.UserPieMenuActions[1]), 256), ["action2"] = imgui.ImBuffer(u8(config_ini.UserPieMenuActions[2]), 256), ["action3"] = imgui.ImBuffer(u8(config_ini.UserPieMenuActions[3]), 256),
						["action4"] = imgui.ImBuffer(u8(config_ini.UserPieMenuActions[4]), 256), ["action5"] = imgui.ImBuffer(u8(config_ini.UserPieMenuActions[5]), 256), ["action6"] = imgui.ImBuffer(u8(config_ini.UserPieMenuActions[6]), 256),
						["action7"] = imgui.ImBuffer(u8(config_ini.UserPieMenuActions[7]), 256), ["action8"] = imgui.ImBuffer(u8(config_ini.UserPieMenuActions[8]), 256), ["action9"] = imgui.ImBuffer(u8(config_ini.UserPieMenuActions[9]), 256),
						["action10"] = imgui.ImBuffer(u8(config_ini.UserPieMenuActions[10]), 256)
				}
		},
		
		plus500 = {
			["plus500color"] = imgui.ImBuffer(u8(config_ini.plus500[1]), 256), ["plus500size"] = imgui.ImBuffer(u8(config_ini.plus500[2]), 256), ["plus500font"] = imgui.ImBuffer(u8(config_ini.plus500[3]), 256),

		},
		
		fond = {
			["fondcolor"] = imgui.ImBuffer(u8(config_ini.fondset[1]), 256), ["mycolor"] = imgui.ImBuffer(u8(config_ini.fondset[2]), 256), 
		},

		dial = {
			["med"] = imgui.ImBuffer(u8(config_ini.dial[1]), 256), ["rem"] = imgui.ImBuffer(u8(config_ini.dial[2]), 256), ["meh"] = imgui.ImBuffer(u8(config_ini.dial[3]), 256), ["azs"] = imgui.ImBuffer(u8(config_ini.dial[4]), 256),
		}
}

local togglebools = {
		tab_main_binds = {
				first = {
				
				},

				clistparams = {
						[1] = config_ini.bools[2] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
						[2] = config_ini.bools[3] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				}
		},

		tab_user_binds = {
				hk = {
					[1] = config_ini.bools[4] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
					[2] = config_ini.bools[5] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
					[3] = config_ini.bools[6] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
					[4] = config_ini.bools[7] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
					[5] = config_ini.bools[8] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
					[6] = config_ini.bools[9] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
					[7] = config_ini.bools[10] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
					[8] = config_ini.bools[11] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
					[9] = config_ini.bools[12] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
					[10] = config_ini.bools[13] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
					[11] = config_ini.bools[14] == 1 and imgui.ImBool(true) or imgui.ImBool(false)
				},

				cmd = {

				}
		},

		tab_bbot = {
			[1] = config_ini.bools[39] == 1 and imgui.ImBool(true) or imgui.ImBool(false), 
			[2] = config_ini.bools[40] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[3] = config_ini.bools[42] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[4] = config_ini.bools[55] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[5] = config_ini.bools[56] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[6] = config_ini.bools[15] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[7] = config_ini.bools[57] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[8] = config_ini.bools[59] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[9] = config_ini.bools[60] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[10] = config_ini.bools[62] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
		},

		tab_commands = {

		},

		tab_settings = {
			[1] = config_ini.Settings.UserSex == 1 and imgui.ImBool(true) or imgui.ImBool(false),
		},

		user_keys = {

		},

		rphr = {

		},

		auto_bp = {
				[1] = config_ini.bools[18] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[2] = config_ini.bools[19] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[3] = config_ini.bools[20] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[4] = config_ini.bools[21] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[5] = config_ini.bools[22] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[6] = config_ini.bools[23] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[7] = config_ini.bools[24] == 1 and imgui.ImBool(true) or imgui.ImBool(false)
		},

		tab_overlay = {
				[1] = config_ini.bools[25] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[2] = config_ini.bools[26] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[3] = config_ini.bools[27] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[4] = config_ini.bools[28] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[5] = config_ini.bools[29] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[6] = config_ini.bools[30] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[7] = config_ini.bools[31] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[8] = config_ini.bools[32] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[9] = config_ini.bools[33] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[10] = config_ini.bools[34] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[11] = config_ini.bools[35] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[12] = config_ini.bools[36] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[13] = config_ini.bools[37] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[14] = config_ini.bools[38] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[15] = config_ini.bools[41] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[16] = config_ini.bools[43] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[17] = config_ini.bools[44] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[18] = config_ini.bools[52] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[19] = config_ini.bools[54] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[20] = config_ini.bools[63] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[21] = config_ini.bools[64] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
				[22] = config_ini.bools[65] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
		},

		tab_skipd = {
			[1] = config_ini.bools[45] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[2] = config_ini.bools[46] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[3] = config_ini.bools[47] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[4] = config_ini.bools[48] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[5] = config_ini.bools[49] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[6] = config_ini.bools[50] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[7] = config_ini.bools[51] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[8] = config_ini.bools[53] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
			[9] = config_ini.bools[61] == 1 and imgui.ImBool(true) or imgui.ImBool(false),
		},

		tab_moder = {
			[1] = config_ini.bools[58] == 1 and imgui.ImBool(true) or imgui.ImBool(false)
		},
}
-- Оверлей
-- Активация
local show = {
		show_time = imgui.ImBool(true),
		show_place = imgui.ImBool(true),
		show_name = imgui.ImBool(true),
		show_veh = imgui.ImBool(true),
		show_target = imgui.ImBool(true),
		show_hp = imgui.ImBool(true),
		show_rk = imgui.ImBool(true),
		show_death = imgui.ImBool(true),
		show_tecinfo = imgui.ImBool(true),
		show_afk = imgui.ImBool(true),
		show_carhp  = imgui.ImBool(true),
		show_anticrash = imgui.ImBool(true),
		show_squad = imgui.ImBool(true),
		show_500 = {["time500"] = 0, ["mult500"] = 1, ["bool500"] = imgui.ImBool(false)},
		show_dmind = {["bool"] = imgui.ImBool(true), ["damind"] = {["a_index"] = 0, ["shots"] = {[1] = 0, [23] = 0, [24] = 0, [25] = 0, [29] = 0, [30] = 0, [31] = 0, [33] = 0}, ["hits"] = {[1] = 0, [23] = 0, [24] = 0, [25] = 0, [29] = 0, [30] = 0, [31] = 0, [33] = 0}, ["damage"] = {[1] = 0, [23] = 0, [24] = 0, [25] = 0, [29] = 0, [30] = 0, [31] = 0, [33] = 0}}},
		othervars = {["saccess"] = false},
		show_dam = imgui.ImBool(true),
		show_fond = imgui.ImBool(true),
		rand = 0,
		show_mem1 = imgui.ImBool(false),
		show_otm = imgui.ImBool(false),
		otm_arr = {},
		show_lek = imgui.ImBool(false),
		lek_arr = {},
		show_weap = imgui.ImBool(false),
		show_vehdm = imgui.ImBool(true),
		show_vehdt = imgui.ImBool(true),
		vehinformer = {
			[1] = {}, 
			[2] = {},
			arr = {[23] = 40, [24] = 140, [25] = 150, [29] = 25, [30] = 30, [31] = 30, [33] = 75},
			carhp = 0,
			hp = 0,
		},
		show_panel = imgui.ImBool(true)
	}
-- Координаты оверлея
local SetModeCond = 4 -- Вот эту штуку  преврати в 0 если хочешь чтобы ты мог двигать элементы мышкой. Если не хочешь оставь 4.
local SetMode = false -- булев происходит ли настройка в данный момент
-- Дамаг информер
local wasset = false
local damagereg = regex.new("([A-Z]+[a-z]+)\\_([A-Z]+[a-z]+) \\- (Desert Eagle|Rifle|Shotgun|M4|AK47|SDPistol|SMG|Fist) (\\+|\\-)(\\d+\\.\\d+)( - KILL)?")
local dinf = {
	[1] = {
		[1] = dinf_ini.Settings.dinf1 == 1 and true or false,
		[2] = false,
		["id"] = {[1] = -1, [2] = -1, [3] = -1},
		["nick"] = {[1] = "", [2] = "", [3] = ""},
		["clist"] = {[1] = "", [2] = "", [3] = ""},
		["weapon"] = {[1] = "", [2] = "", [3] = ""},
		["damage"] = {[1] = 0, [2] = 0, [3] = 0},
		["kill"] = {[1] = false, [2] = false, [3] = false},
	},

	[2] = {
		[1] = dinf_ini.Settings.dinf2 == 1 and true or false,
		[2] = false,
		["id"] = {[1] = -1, [2] = -1, [3] = -1},
		["nick"] = {[1] = "", [2] = "", [3] = ""},
		["clist"] = {[1] = "", [2] = "", [3] = ""},
		["weapon"] = {[1] = "", [2] = "", [3] = ""},
		["damage"] = {[1] = 0, [2] = 0, [3] = 0},
		["kill"] = {[1] = false, [2] = false, [3] = false},
	},
}

local give = {}
local A_Indexp = 0
while true do A_Indexp = A_Indexp + 1 if A_Indexp == 11 then A_Indexp = nil break end give[A_Indexp] = {["Status"] = imgui.ImBool(false), ["Damage"] = 0, ["x"] = 0, ["y"] = 0, ["z"] = 0, ["index"] = 0} end
local take = {}
local A_Indexp = 0
while true do A_Indexp = A_Indexp + 1 if A_Indexp == 1001 then A_Indexp = nil break end take[A_Indexp] = {["Status"] = imgui.ImBool(false), ["Dagame"] = 0, ["WeaponID"] = 0, ["index"] = 0} end
local indicator1 = {["Status"] = imgui.ImBool(false), ["Angle"] = 0, ["x"] = 0, ["y"] = 0, ["index"] = 0}
local indicator2 = {["Status"] = imgui.ImBool(false), ["Angle"] = 0, ["x"] = 0, ["y"] = 0, ["index"] = 0}
local indicator3 = {["Status"] = imgui.ImBool(false), ["Angle"] = 0, ["x"] = 0, ["y"] = 0, ["index"] = 0}
local BulletsHistory = {}
local lastDamage = 0
local lastHit = 0
local hittex1 = nil
local hittex2 = nil
local hittex3 = nil
local hitimage = nil
-- Оверлей
local mem1 = {[1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}}
local SetModeFirstShow = false
local images = {
 	-- статистика нанесенного урона
	[1] = nil,
	[2] = nil,
	[3] = nil,
	[4] = nil,
	[5] = nil,
	[6] = nil, 
	-- меню выбора оружия
	[7] = nil,
	[8] = nil,
	[9] = nil,
	[10] = nil,
	[11] = nil,
	[12] = nil,
	[13] = nil,
	[14] = nil,
	---
	[15] = nil, -- квадратный прицел
	--- панель состояния
	[16] = nil, -- шприц зеленый
	[17] = nil, -- шприц желтый
	[18] = nil, -- шприц красный
	[19] = nil, -- канистра зеленая
	[20] = nil, -- канистра красная
	[21] = nil, -- автозажатие
	[22] = nil, -- сирена
	[23] = nil, -- ремка зеленая
	[24] = nil, -- ремка красная
	[25] = doesFileExist(getWorkingDirectory() .. '\\Pictures\\sync.png') and imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\sync.png') or nil, -- синхра cкорости
	[26] = nil, -- нарко
	[27] = nil, -- маты
	[28] = nil, -- ключи
	[29] = nil, -- набор для взлома
	-------
	[30] = nil, -- направление обстрела
	------
	[33] = nil, -- анмиация фокуса
	[34] = nil, -- указатель на фокус1
	[35] = nil, -- указатель на фокус2
	-- 300 + id фокуса * 1 (прямая видимость) или 2 (за преграддой) - указатель на фокус по ID указателя и статусу видимости
	-------
}

local vehtypes = {
	["helis"] = {[488] = "News Maverick", [487] = "Maverick", [497] = "Police Maverick", [548] = "Cargobob"},
	["planes"] = {[460] = "Skimmer", [476] = "Rustler", [512] = "Cropduster", [513] = "Stuntplane", [593] = "Dodo"},
	["boats"] = {[430] = "Predator", [446] = "Squalo", [452] = "Speeder", [453] = "Reefer", [454] = "Tropic", [472] = "Coastgaurd", [473] = "Dinghy", [484] = "Marquis", [493] = "Jetmax", [595] = "Launch"},
	["motos"] = {[522] = "NRG-500", [463] = "Freeway", [461] = "PCJ-600", [581] = "BF-400", [521] = "FCR-900", [468] = "Sanchez", [462] = "Faggio"},
}
	
local crosimage = nil
local showcmcimage = nil
local crosMode = false
local pCros = false
local NeedtoLoadMem = false
local dx9font = renderCreateFont("times", 14, 12)
local tweapondist = {[23] = 50, [24] = 35, [25] = 40, [29] = 50, [30] = 80, [31] = 90, [33] = 100}
local tweapondamage = {[23] = 10, [24] = 47, [25] = 30, [29] = 8, [30] = 10, [31] = 10, [33] = 25}
local target = {["id"] = 1000, ["time"] = 0, ["suct"] = false}
local sx = 0
local sy = 0
local ped
local s_coord = {}
local s_target, s_targetCar, s_hp, s_veh, s_name, s_place, s_time, s_rk, s_afk, s_tecinfo, s_dam, s_death
local tweaponNames = {[0] = "First", [1] = "Brass Knuckles", [2] = "Golf Club", [3] = "Nightstick", [4] = "Knife", [5] = "Baseball Bat", [6] = "Shovel", [7] = "Pool Cue", [8] = "Katana", [9] = "Chainsaw",
[10] = "Purple Dildo", [11] = "Dildo", [12] = "Vibrator", [13] = "Silver Vibrator", [14] = "Flowers", [15] = "Cane", [16] = "Grenade", [17] = "Tear Gas", [18] = "Molotov Cocktail", [22] = "9mm",
[23] = "Silenced pistol", [24] = "Desert Eagle", [25] = "Shotgun", [26] = "Sawnoff Shotgun", [27] = "Combat Shotgun", [28] = "Micro SMG/Uzi", [29] = "MP5", [30] = "AK-47", [31] = "M4", [32] = "Tec-9",
[33] = "Country Rifle", [34] = "Sniper Rifle", [35] = "RPG", [36] = "HS Rocket", [37] = "Flamethrower", [38] = "Minigun", [39] = "Satchel Charge", [40] = "Detonator", [41] = "Spraycan",
[42] = "Fire Extinguisher", [43] = "Camera", [44] = "Night Vis Goggles", [45] = "Thermal Goggles", [46] = "Parachute"}
local tVehicleNames = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BFInjection", "Hunter",
"Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo",
"RCBandit", "Romero","Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed",
"Yankee", "Caddy", "Solair", "Berkley'sRCVan", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RCBaron", "RCRaider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
"Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage",
"Dozer", "Maverick", "NewsChopper", "Rancher", "FBIRancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "BlistaCompact", "PoliceMaverick",
"Boxvillde", "Benson", "Mesa", "RCGoblin", "HotringRacerA", "HotringRacerB", "BloodringBanger", "Rancher", "SuperGT", "Elegant", "Journey", "Bike",
"MountainBike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "hydra", "FCR-900", "NRG-500", "HPV1000",
"CementTruck", "TowTruck", "Fortune", "Cadrona", "FBITruck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight",
"Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
"Yosemite", "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RCTiger", "Flash", "Tahoma", "Savanna", "Bandito",
"FreightFlat", "StreakCarriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "NewsVan",
"Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "FreightBox", "Trailer", "Andromada", "Dodo", "RCCam", "Launch", "PoliceCar", "PoliceCar",
"PoliceCar", "PoliceRanger", "Picador", "S.W.A.T", "Alpha", "Phoenix", "GlendaleShit", "SadlerShit", "Luggage A", "Luggage B", "Stairs", "Boxville", "Tiller",
"UtilityTrailer"}

local array = {}
local cIDs = {
	[505] = "Армия ЛВ (бункер)", [506] = "Армия ЛВ (бункер)", [507] = "Армия ЛВ (бункер)", [508] = "Армия ЛВ (бункер)", [509] = "Армия ЛВ (бункер)", 

	[510] = "Армия ЛВ", [511] = "Армия ЛВ", [512] = "Армия ЛВ", [513] = "Армия ЛВ", [514] = "Армия ЛВ", 
	[515] = "Армия ЛВ", [516] = "Армия ЛВ", [517] = "Армия ЛВ", [518] = "Армия ЛВ", [519] = "Армия ЛВ", 
	[520] = "Армия ЛВ", [521] = "Армия ЛВ", [522] = "Армия ЛВ", [523] = "Армия ЛВ", [524] = "Армия ЛВ", 
	[525] = "Армия ЛВ", [526] = "Армия ЛВ", [527] = "Армия ЛВ", [528] = "Армия ЛВ", [529] = "Армия ЛВ", 
	[530] = "Армия ЛВ", [531] = "Армия ЛВ", [532] = "Армия ЛВ", [533] = "Армия ЛВ", [534] = "Армия ЛВ",
	[535] = "Армия ЛВ", [536] = "Армия ЛВ", [537] = "Армия ЛВ", [538] = "Армия ЛВ", [539] = "Армия ЛВ", 
	[540] = "Армия ЛВ", [541] = "Армия ЛВ", [542] = "Армия ЛВ", [543] = "Армия ЛВ", [544] = "Армия ЛВ", 
	[545] = "Армия ЛВ", [546] = "Армия ЛВ", [547] = "Армия ЛВ", [548] = "Армия ЛВ", [549] = "Армия ЛВ", 
	[550] = "Армия ЛВ", [551] = "Армия ЛВ", [552] = "Армия ЛВ", [553] = "Армия ЛВ",

	[554] = "Военный комиссариат СФ", [555] = "Военный комиссариат СФ", [556] = "Военный комиссариат СФ", [557] = "Военный комиссариат СФ", [558] = "Военный комиссариат СФ", [559] = "Военный комиссариат СФ",
	[560] = "Военный комиссариат ЛВ", [561] = "Военный комиссариат ЛВ", [562] = "Военный комиссариат ЛВ", [563] = "Военный комиссариат ЛВ", [564] = "Военный комиссариат ЛВ", [565] = "Военный комиссариат ЛВ",	

	[566] = "Порт ЛС", [567] = "Порт ЛС", [568] = "Порт ЛС", [569] = "Порт ЛС", [570] = "Порт ЛС", [571] = "Порт ЛС",
	[572] = "Порт ЛС", [573] = "Порт ЛС", [574] = "Порт ЛС", [575] = "Порт ЛС",	
}

local carsident = {}
local sanc = {[226] = "Sanchez", [227] = "Sanchez", [228] = "Sanchez", [231] = "Sanchez", [230] = "Sanchez", [229] = "Sanchez"}
local rCache = {enable = false, smem = {}}
-- Pie Menu
local piearr = {
	action = 0,
	pie_mode = imgui.ImBool(false),
	pie_keyid = 0,
	pie_elements = {},
	
	["weap"] = {
		action = 0,
		pie_mode = imgui.ImBool(false),
		pie_keyid = 0,
		pie_elements = {},
	}
}

local fond = {[1] = "ERROR", [2] = "0"}
-- Автовзятие БП
local isarmtaken = false
local isdeagletaken = false
local isshotguntaken = false
local issmgtaken = false
local ism4a1taken = false
local isrifletaken = false
local ispartaken = false
local isarmtaken = false
local isdeagle = false
local isshotgun = false
local issmg = false
local ism4a1 = false
local isrifle = false
local ispar = false
local AutoDeagle = config_ini.bools[18] == 1 and true or false
local AutoShotgun = config_ini.bools[19] == 1 and true or false
local AutoSMG = config_ini.bools[20] == 1 and true or false
local AutoM4A1 = config_ini.bools[21] == 1 and true or false
local AutoRifle = config_ini.bools[22] == 1 and true or false
local AutoPar = config_ini.bools[23] == 1 and true or false
local AutoOt = config_ini.bools[24] == 1 and true or false
local partimer = 0
local istakesomeone = false -- булев было ли хоть что-то взято
-- зажатие клавиши движения
local needtohold = false
-- Автоматическое снятие оружия с предохранителя
local otWeaponName = {
		{[23] = "тактический пистолет \"SD Pistol\"", [24] = "пистолет \"Desert Eagle\"", [25] = "дробовик \"Shotgun\"", [29] = "пистолет-пулемет \"HK MP-5\"", [31] = "штурмовую винтовку \"M4A1\"", [30] = "штурмовую винтовку \"AK-47\"", [33] = "снайперскую винтовку \"Country Rifle\""},
		{[25] = "дробовика \"Shotgun\"", [29] = "пистолета-пулемета \"HK MP-5\"", [31] = "штурмовой винтовки \"M4A1\"", [30] = "штурмовой винтовки \"AK-47\"", [33] = "снайперской винтовки \"Country Rifle\""}
}
local autopred = {["firstshot"] = false, ["current_weapon"] = 0}
local crosMode2 = false
-- Диалоги
local isDialogActiveNow = false -- булев активен ли в данный момент диалог
local IsAppear = false -- булев создан ли диалог впервые
local DialogTitle = ""
local DialogText = ""
local DialogButton1 = ""
local DialogButton2 = ""
local isCorrectClose = false -- булев правильно ли был закрыт диалог
local SelectedButton = 0 -- какая кнопка (1 или 2) была нажата
local returnWalue = nil
-- List
local show_dialog_list = imgui.ImBool(false)
local ChoosenRow = -1
local SelectedRow = 0
local StrCol = 0
-- Input
local show_dialog_input = imgui.ImBool(false)
local IsFocused = false -- булев был ли поставлен фокус на инпут
local moonimgui_text_buffer = imgui.ImBuffer(256)
-- msgbox
local show_dialog_msgbox = imgui.ImBool(false)
-- Техническая информация
local lastKV = {m = "none", b = "none"}
local lastID = {e = "none"}
local RKTimerTickCount
local BKTimerTickCount
local CTaskArr = {
	[1] = {}, -- ID событий
	--[[ 
		1 - СОС, 
		2 - эвакуация, 
		3 - надеть 7 кл при входе в игру (поменять отыгровку на функцию в биндере); 
		4 - выехали в СОПР ВМО; 
		5 - взял грузовик загружаюсь на ГС, 
		6 - поставил грузовик, 
		8 - /repairkit, 
		9 - взял вертолет 
		10 - квадрат зачищен, 
		11 - вернул вертолет, 
		12 - вызвать врача в /dep 
		13 - репорт на флипкар
		14 - ВМО, выезжайте!
		15 - паспорт и удостоверение
		16 - сетка открывай под/вы езжает ВМО

	]]
	[2] = {}, -- время начала события
	[3] = {}, -- доп. информация для события
	["CurrentID"] = 0, 
	["n"] = {
		[1] = "{FF0000}SOS", 
		[2] = "{00FF00}Эвакуация", 
		[3] = "{59a655}Надеть повязку 7",
		[4] = "{00FF00}Сопровождение ВМО",
		[5] = "{00FF00}Взял" .. RP .. " грузовик",
		[6] = "{00FF00}Вернул" .. RP .. " грузовик в ангар",
		[7] = "{00FF00}Разгрузились на складе",
		[8] = "{FF0000}Рем. комплект",
		[9] = "{00FF00}Взял" .. RP .. " вертолет",
		[10] = "{00FF00}Зачищен квадрат",
		[11] = "{00FF00}Вернул" .. RP .. " вертолет",
		[12] = "{00FF00}Вызвать врача в",
		[13] = "{FF0000}Попросить админов флипнуть машину",
		[14] = "{00FF00}ВМО, выезжайте",
		[15] = "{59a655}Показать паспорт и удостоверение",
		[16] = "{00FF00}Сетка, открывай!",
	}, -- имена статусов в КК по ID события
	["nn"] = {1, 2, 4, 7, 10, 12, 16}, -- ID's которые требуют отображения доп информации (из массива №3) в статусе КК
	[10] = { -- прочие значения для работы КК (мусорка переменных)
		[1]	= "", -- квадрат принятного через КК SOS (для ID №10)
		[2] = {[1] = {[1] = 0, [2] = 0, [3] = 0}, [2] = false}, -- массив для ид №5 (1 - массив с литрами {1 - текущий литраж, 2 - временный литраж, 3 - ид текстдрава с литрами}, 2 - находишься ли ты в грузовике)
		[3] = 0, -- сколько на последнем складе матиков (ID 7)
		[4] = false, -- был ли недавно вход на сервер (ид 3)
		[5] = false, -- есть ли активное задание по id 8 на данный момент
		[6] = false, -- id 9 - булев находишься ли ты в вертолете
		[7] = -1, -- хэндл подавшего СОС
		[8] = {
			[-1514.75 + 2518.875 + 56] = "El Quebrados Medical Center",
			[-318.75 + 1048.125 + 20.25] = "Fort Carson Medical Center",
			[1607.375 + 1815.125 + 10.75] = "Las Venturas Hospital",
			[1228.625 + 311.875 + 19.75] = "Crippen Memorial Hospital",
			[1241.375 + 325.875 + 19.75] = "Crippen Memorial Hospital",
			[2034.125 + -1401.625 + 17.25] = "Country General Hospital",
			[1172 + -1323.375 + 15.375] = "All Saints General Hospital",
			[-2655.125 + 640.125 + 14.375] = "San Fierro Medical Center",
			[261.875 + 4 + 1500.875] = 0, -- exit
			[242.75 + 7 + 1500.875] = 0, -- exit2
		}, -- координаты меток входа/выхода у больниц
		[9] = false, -- было ли создано событие №13
		[10] = false, -- был ли недавно вход на сервер (ид 15)
		[11] = 0, -- статус условия активации КК№16 (0 - не соблюдается, 1 - выезжает, 2 подъезжает)
		[12] = false, -- есть ли активная на данный момент КК №16

	}
}
local imCStatus = "{FFFAFA}Ожидание события"
-- случайные фразы
local lastrand = 0
-- Другое
local offmembers = {}
local waitforchangeclist = false
local freeze = {["sidmode"] = false, ["mode"] = false, ["x"] = 0, ["y"] = 0, ["z"] = 0}
local stattext = ""
local needtomask = {
	["mode"] = false,
	["status"] = 0, -- 1 - нужно проделать дела с беретом; 2 - нужно все закрыть
	["bool"] = false,
	["BDSM Mask"] = 0,
	["Swat Helmet"] = 0,
	["Balaclava"] = 0,
	["SteerSkull"] = 0,
	["Diablo"] = 0,
	["HockeyMask1"] = 0,
	["MaskPatterns White"] = 0,
	["MotorHelmet Red1"] = 0,
	["MotorHelmet Purple"] = 0,
	["Mask Grey"] = 0,
	["HockeyMask3"] = 0,
	["HockeyMask2"] = 0,
	["Mask Skulls Black"] = 0,
	["MotorHelmet White"] = 0,
	["MaskPatterns Green"] = 0,
	["MaskTriangle Yellow"] = 0,
}
local sym = {["myid"] = -1, ["mynick"] = -1, [1] = 144 - 7, ["s"] = 132 - 15, ["w"] = 134 - 20, ["me"] = 116 - 2, ["do"] = 136 - 10, ["try"] = 116 - 2, ["todo"] = 82 - 23, ["m"] = 114 - 21, ["r"] = 178 - 49, ["f"] = 178 - 49, ["fs"] = 121 - 18, ["u"] = 121 - 18, ["report"] = 218 - 29, ["b"] = 117 - 8, ["dep"] = 161 - 41} 
local isEnab, desH = 0, 0 -- script_author("Du_Hast") script_name("Heli Hover")
local rabbool = false
local otsmode = 0 -- 0 не было сообщений, 1 - первое сообщение, 2 - второе сообщение, 10-20 идёт отсчёт (20 - последнее число в отсчёте)
local isauth = false
local isth = false
local issquadactive = {[1] = false, [2] = false, [3] = 0}
local isglory = false
local PICKUP_POOL
local isSending = false
local skipd = {
	[1] = { -- информация о последнем поднятом пикапе
		["pid"] = -1, 
		["obool"] = true
	}, 
	
	[2] = { -- id's меток полученные с таблицы
		[1] = 0, -- разрешение на print меток
		[2] = 0, -- 1 этаж казармы - не используется (высччитываем на ходу)
		[3] = 0, -- 2 этаж казармы - не используется (высччитываем на ходу)
		[4] = 0, -- 3 этаж казармы - не используется (высччитываем на ходу)
		[5] = 0, -- БП (внутри) - не используется (высччитываем на ходу)
		[6] = 0, -- БП (метка с оружием) - не используется (высччитываем на ходу)
		[7] = 0, -- вход в ГС - высчитываем на ходу
		[8] = 0, -- выход из ГС - высчитываем на ходу
		[9] = 0, 
		[10] = 0, 
		[11] = 0, 
		[12] = 0,
		[13] = 0, 
		[14] = 0, 
		[15] = 0, 
		[16] = 0, 
		[17] = 0, 
		[18] = 0,
		[19] = 0, 
		[20] = 0, 
		[21] = 0, 
		[22] = 0, 
		[23] = 0, 
		[24] = 0,
		[25] = 0, 
		[26] = 0, 
		[27] = 0,
		[28] = 0, 
		[29] = 0, 
		[30] = 0,

	}, 
		
	[3] = { -- доп. информация
		[1] = false, -- была ли куплена защита (для автоматического скипа предыдущего диалога)
		[2] = 0, -- статус автозакупки в 24/7 (0 - не закупалось/закупка нужна, 1 - закупил ремки, 2 - закупил защиты/закупка не нужна, 3 - ошибка при закупке)
		[3] = false, -- был ли ответ на /carm (для пропуска следующего диалога)
		[4] = 0, -- количество материалов в грузовике
		[5] = false, -- был ли вызван /carm ради мониторинга
		[6] = { -- мониторинг фракций
			["LSPD"] = 0, 
			["SFPD"] = 0,
			["LVPD"] = 0, 
			["FBI"] = 0, 
			["SFA"] = 0
		},
		[7] = {[1] = false, [2] = 0}, -- находишься ли рядом с АЗС (для бинда автоматической заправки на АЗС); 2 - ид 3д текста заправки
		[8] = { -- массив для автоматического /carm
			[1] = false, -- был ли вызван /carm скриптом (если вручную то скипа нет)
			[2] = false, -- заехал ли грузовик в область автоматической активации
			[3] = {[1] = {["x1"] = 322, ["y1"] = 1918, ["x2"] = 344, ["y2"] = 1979}, [2] = {["x1"] = 2211, ["y1"] = 2444, ["x2"] = 2250, ["y2"] = 2506}, [3] = {["x1"] = 1515, ["y1"] = -1667, ["x2"] = 1535, ["y2"] = -1586}, [4] = {["x1"] = -1722, ["y1"] = 672, ["x2"] = -1696, ["y2"] = 723}, [5] = {["x1"] = -1491, ["y1"] = 325, ["x2"] = -1543, ["y2"] = 386}, [6] = {["x1"] = -2467, ["y1"] = 457, ["x2"] = -2389, ["y2"] = 528}},
			-- 1 LVA 2 LVPD 3 LSPD 4 SFPD 5 SFA 6 FBI
			-- координаты областей автоматической активации
			[4] = {}, -- временный массив
		},
		[9] = 0, -- для инвентаря,
		[10] = {["Desert Eagle"] = 15, ["Shotgun"] = 15, ["M4"] = 90, ["Rifle"] = 30, ["MP5"] = 60, ["Пистолет Desert Eagle"] = 15, ["Дробовик Shotgun"] = 15, ["Винтовка М4"] = 90, ["Винтовка Count Rifle"] = 30, ["Автомат SMG"] = 60} -- для инвентаря,
	}
}

local lastTargetID = -1
local lastcarhandle = nil
local spsyns = {
	["car"] = nil, -- хендл целевой машины
	["mode"] = false, -- режим синхронизации
	["changespeed"] = false, -- будет ли изменена скорость в близжайший момент
	["tarspeed"] = 0, -- целевая скорость
	["firstshow"] = false, -- была ли синхронизация запущена только что
	["fcoord"] = {}, -- первые координаты
	["scoord"] = {}, -- вторые координаты
	["time"] = 0, -- время начала последнего отсчёта
}

local waitforsave = false
local lastcolorchane = false -- идет ли изменение цвета ника в данный момент (для бинда на автоматическую смену цвета)
local soptlist = {{}, {}}
local otmmode = false
local offcheck = {["status"] = false, ["rank"] = 0, ["otm"] = 0}
local preparecomplete = false
local prepareinv = false
local isobnova = false
local freereq = true
local req_index = 0
local refmem1 = {["status"] = false, ["text"] = ""}
local moderpas = ""
local afkstatus = false
local needtosave = false
local keybbb = {KeyboardLayoutName = ffi.new("char[?]", 32), LocalInfo = ffi.new("char[?]", 32)}
local needtoreset = false
local delay = 1000 -- задержка между сообщениями в мс
local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local ImVec4 = imgui.ImVec4
local imfonts = {mainfont = nil, exFontl = nil, exFont = nil, exFontsquad = nil, font500 = nil, fontmoney = nil, exFontsquadrender = nil, onlinebig = nil, onlinesmal = nil}
local clists = {
	[16777215] = 0,    [2852758528] = 1,  [2857893711] = 2,  [2857434774] = 3,  [2855182459] = 4, [2863589376] = 5, 
	[2854722334] = 6,  [2858002005] = 7,  [2868839942] = 8,  [2868810859] = 9,  [2868137984] = 10, 
	[2864613889] = 11, [2863857664] = 12, [2862896983] = 13, [2868880928] = 14, [2868784214] = 15, 
	[2868878774] = 16, [2853375487] = 17, [2853039615] = 18, [2853411820] = 19, [2855313575] = 20, 
	[2853260657] = 21, [2861962751] = 22, [2865042943] = 23, [2860620717] = 24, [2868895268] = 25, 
	[2868899466] = 26, [2868167680] = 27, [2868164608] = 28, [2864298240] = 29, [2863640495] = 30, 
	[2864232118] = 31, [2855811128] = 32, [2866272215] = 33,

	[-256] = 0, [161743018] = 1, [1476349866] = 2, [1358861994] = 3, [782269354] = 4, [-1360527190] = 5,
	[664477354] = 6, [1504073130] = 7, [-16382294] = 8, [-23827542] = 9,  [-196083542] = 10,
	[-1098251862] = 11, [-1291845462] = 12, [-1537779798] = 13, [-5889878] = 14, [-30648662] = 15,
	[-6441302] = 16, [319684522] = 17, [233701290] = 18, [328985770] = 19, [815835050] = 20,
	[290288042] = 21, [-1776943190] = 22, [-988414038] = 23, [-2120503894] = 24, [-2218838] = 25,
	[-1144150] = 26, [-188481366] = 27, [-189267798] = 28, [-1179058006] = 29, [-1347440726] = 30,
	[-1195985238] = 31, [943208618] = 32, [-673720406] = 33,
}

local ranksnames = {[1] = "Рядовой", [2] = "Ефрейтор", [3] = "Мл.сержант", [4] = "Сержант", [5] = "Ст.сержант", [6] = "Старшина", [7] = "Прапорщик", [8] = "Мл.Лейтенант", [9] = "Лейтенант", [10] = "Ст.Лейтенант", [11] = "Капитан", [12] = "Майор", [13] = "Подполковник", [14] = "Полковник", [15] = "Генерал"}
local duel = {
	["mode"] = false, 

	["en"] = {
		["id"] = -1, 
		["hp"] = 0, 
		["arm"] = 0
	}, 
	
	["fightmode"] = false, 
	
	["my"] = {
		["hp"] = 0, 
		["arm"] = 0
	}
}


local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}

local stroyarr = {
	stroymode = false,
	soptlist = {["ruk"] = {}, ["osn"] = {}, ["stj"] = {}},
	stroypr = {
		["ids"] = {}, 
		["zv"] = {}, 
		["index"] = {
			["ruk"] = {["first"] = 0, ["last"] = 0}, 
			["osn"] = {["first"] = 0, ["last"] = 0}, 
			["stj"] = {["first"] = 0, ["last"] = 0}
		}
	},
	
	stroystate = 0,
	stroyleader = {["current"] = "", ["temp"] = ""},
	stroycreator = false,
	creator = {["id"] = 0, ["zv"] = 0},
	listcomplete = false,
	listfinal = false
}

function number_week() -- получение номера недели в году
    local current_time = os.date'*t'
    local start_year = os.time{ year = current_time.year, day = 1, month = 1 }
    local week_day = ( os.date('%w', start_year) - 1 ) % 7
    return math.ceil((current_time.yday + week_day) / 7)
end

--- счетчик онлайна
local startTime = 0
local connectingTime = 0
local time_index = 0
local tWeekdays = {
    [0] = 'Воскресенье',
    [1] = 'Понедельник', 
    [2] = 'Вторник', 
    [3] = 'Среда', 
    [4] = 'Четверг', 
    [5] = 'Пятница', 
    [6] = 'Суббота'
}

if online_ini.day_info.today ~= os.date("%a") then 
	online_ini.day_info.today = os.date("%a")
	online_ini.day_info.online = 0
	online_ini.day_info.full = 0
	online_ini.day_info.afk = 0
	dfuls = 0
end

if online_ini.week_info.week ~= number_week() then
	online_ini.week_info.week = number_week()
	online_ini.week_info.online = 0
	online_ini.week_info.full = 0
	online_ini.week_info.afk = 0
	wfuls = 0
	online_ini.online = {[0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0}   
end

inicfg.save(online_ini, "online.ini") 
local wfuls = online_ini.week_info.full
local dfuls = online_ini.day_info.full
local ses = {["online"] = 0, ["afk"] = 0, ["full"] = 0}

function apply_custom_styles()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

	imgui.GetIO().Fonts:Clear()
	imfonts.mainfont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\times.ttf', 14.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	imfonts.memfont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\times.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	imfonts.exFontl = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\times.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	imfonts.exFont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\times.ttf', 28.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	imfonts.exFontsquad = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\trebuc.ttf', squadsize, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) --trebuchet
	imfonts.font500 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\times.ttf', 54, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 
	imfonts.onlinebig = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\times.ttf', 32, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 
	imfonts.onlinesmal = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\times.ttf', 14, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 
	imfonts.exFontsquadrender = renderCreateFont("times", 11, 12)
	--imfonts.fontmoney = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\stencil.ttf', 48, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())   
	--imfonts.fontmoney = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(ttf1_data, 48, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 

	-- File: 'STENCIL.ttf' (55596 bytes)
	-- Exported using binary_to_compressed_lua.cpp
		local result_compressed_data_base85 = "7])#######)$3F1'/###SL?>#0C/2'Ql#v#aHdd=HC1f/PH)##8m%##b2xe=j7EC&S7'##$7`'/1WA0Fflaf+5&(##8E&##%g4'IY-j+rMC$##EIh--'%HkEC^'o'Swf-6hl###+#?UCj?-xD2+Sk+P=r-$f'TqL<'2-Mq`,R<>M[w'E3n0FvTrs?cu#F7r8'##M)xhFG:nGQ=+.e-[T*F.BHZ=B7OZiKRwE_&-1o92;4^=BVcSxo*4[w'Y7)##elFiFs[[p[eH*##w(v9),wEfGY.OYAVE1R<9%/d*^.>C#k(:^')rss'^PZS%Y9w0#M?B[rQ_Nj0lt#mIcM2rdYfk293e;s%baHb%*46Z$#Fa-?@'Esup<Gj%*NM.M<8T;-#Tp01KMg2#K@U/#+/5##CwlhLxS=L#tE,h1)MC;$$7B2#2fLZ#?Z+oL57GcM#g'#G#*n.h+`_;$FtsT%Y74,MV7,,MWW:&4BJOD-.[6;-nOa>>&:cuYRCf]47,LkFn2Am0p@[@'sQYt(uQj-$D9n;%[A[R*^(D'Sw?k_&)KC_&(Uk_&*NC_&/kk_&XIjl&l)l_&8l4R*a2#v#'tH#$:>Pp&'WY_&+QC_&+/j.L.=?v$pA@>Q/FZ;%&Y12U0OvV%*q9>Z1X;s%/k^DOr<o_&VOJM'Q-k_&(HC_&)Xk_&)KC_&7-l_&*NC_&EWl_&eaZ`*4,m_&8l4R*lum_&Y@35&ZIn_&%VH5/ehn_&#G-5/80p_&0]b(N_Mq_&%P-5/,eAN-n1H-.`qhXM=_YgLfm=X$0nG<-@_`=-@nG<-6lG<-LnG<-8x(t-@UA_M99MhLh#PX$gnG<-e84gM:F`hLgvXt$:_`=->x(t-%eHIM?^.iLejFt$JlG<-[Qx>-XlG<-^Qx>-ilG<-GlG<-ulG<-qD:@-+mG<-UlG<-8jG<-/k]j--WY_&X7mEeA:PR*k[BR*>$#Ra@2q&9%CVE-W[FC5Y'QA>qb/@-u<4GH3rI+HMLLd2ZiudG1dFrCkZRdFTX0@-^meF-$'4RDHHi]G)>2eG<QCq1jrpKFY(aL='DvlE5qL@')j0^>FverL=c'g2?X*.NYgo(<Z$EYGG/w1Bqvf'&+=XoIA15JCQF-AF=er-$=2,a==$*F.nMs.CG8k^G%*KMTCO[c`l:q-$lL`f_m<dl8bUNe-k'q=Yu>Yc25>5L#Vrd'&F`2A=Su_f1u)sc<RH[>HlZ/F%'+auGns-A0,Tn3+qUDYGVM+#H/4tiCWcn>-t,CR3xw5F7SS7qVhYi34`BA_/k]4GD6LA_8;T*eZ<Un-$.R]rH/(=2CQZoKY<VQ9`Pk@_/Z:f?KjMo+DVUb-6-;sE@g>4A'd_-@9ooi34sUBe6iF_j152v(3[`FgM@:V'#p^X7/T5o-#m#[QMt3oiLr#JQMJLG&#G`Y-MHLG&#R4S>-EG5-M_e=rLr3oiLH'crLWTxqLna4rL(9m<-[_Xv-0aErL2*8qLK:SqLdK_SMKF'C-Et%'.*aErL0@]qL,6JqLc?1sLL%m.#=7PDF5.]PBKJ^VI*$/j1vpvf;H)=#H#9g'&.FpQWD;d'&*E>R<7RNe$G^(@'bN7kOOO)F./=9qVw8*aF@vp92ua&:;m=t-6quOcD>[XMCO,^q)-V$<-g2RA-o^4?-HoM>McxXrL*eov7r3XMCsHB2C#39?%AcV6MWLKC-;v#=M06:SM86T-#QNJF-nYkR-pvQx--*IqLnGG&#h)J>HfH_w08]sE@,Rx7I9A%mBY2NDFSb'X_wvsQj(.auG3TTwBK,@X(AQ:@')udxFP@268)plcE@/aw0xpJq;0'I-Z7:IP/gavS/E%43./aqpLF.Yc-4Sm--=r/F@,/a>-WR]MCG&F>H:Ih]GZFP50[6;XUQo8)Fc].:;BMOk+KN8VQ:ShSMWN4RMM/lrLdlrpL3[4?-m7R78nX*#HW:9q`Ko`PBp.ePB?i,j14qgS8MjMDF:hpfDl?pMC>4a'Jf`Ik49AEdXaE0)&UT_>-kZ4XC-+X9VlMQq23_e;-6194M5i0h$c7+gDPanI-3'b;Mf4urLnAg-#kGJF-Ka+p7aZ9/Di/ZMC.Epk+-R'EPdFB-#v9q'#:`($#-#krLd3v.#e,KkLhT`/#M?<j1,1R9`-+exFJ3*j1]2xc<g+aMC:ZxP_2@=3N<*B-#7EDU%S%f?K%vgERd)q92?F;p7(qlcE:7A5B,]ODFRs2)FkTw2;V(B-#.o`^%3-(mBo<n'A[Y+#H<U$^Gq-G_Atu#<-><>D9I8.`&>+J3b?euj;G*/>-*sE(On?bD9Pt@5B;NC2Coij3=-bXoIL<[?$%&N@$iUlB$^Ag;-,LM.M@`4rLTOUK-f&831PAU/#>*]-#Vmk.#%5u(.8)trLE-lrLH@N79,pxF.q3n0#H2>>#$ck&#:%vu#,.CB#>,>>#oU]U)%lB#$Qn0I$Pd5Q8'>uu#4b[o1n(Y7:IZGJ4a8=61ar)9/qefQ06uc7K6[.d==R<T%ME#n&^8`0(n+FI)(u,c*8hi%,e,HnC>a^REkK,:A?/e1#O;oVR6xOkPcJ@fQ,7l;H&l5&T5UV#UFEf?UY]dqWBf*52oW>)@gfhc?8Nk,-S#$tK;^9rM0Dp_J;Ym.-B6]PLn4OaI3Iu@$Zm?L-aZ+b5Ig^)?I%8%CY')*#X6rX@@]7DStnG&T7kIZUYBO9W-8N`E2ptRD6%AfGBWCv#TM>n%O@HS70%RS%PqPrZdwm@k<dT]=T6FSI+Fbuc$_e%kq2nJ)FBx],VMQ8/#-s]53&Hv-9v:^#'5Fm'87?g)JN4^,0SV2:-OnMCi6W:vCDs?-u>3S[h9Nxk-0dlA-mT]c=e>Ji(=/0)B*A&,15CX:Vt[Y:.8hX:xdWX:&K)i#'0q^ueQMOuvbAxt1]thMN57'lH^c(#=rnok*[eKk,L'MktQ0MkPQg@k@)GIk.2RCkruQ5#n3#F#IEbA#(qN+.,mU&N*8$##BBt'&7kMW#9>.bM9rA,M<+gcM[LpgLaZW-$]i1A=Pl_f1)V:G;hMx.:h(Q`<Ze8A4Ecv(3>)(/1k'MS.o?.5/sWel/wpEM0,s:D3-4o1KOK5MK`xL]=.iqr$2+RS%6C35&:[jl&>tJM'B6,/(FNcf(JgCG)N)%)*RA[`*VY<A+Zrsx+_4TY,)HRfCJmd(Nm02DE?5*<-_RE1#cea1#e=N)#*3h'#<M6(#:K5+#T5C/#pVs)#Bkeh%J10>>I/6]bR2o(E_Jdr?WSq@bp5IS7]&6Yc+e187A-@YPEK<VQCKWrQe_lr-Mv8SRMps7RUPPlSUJ5PSf=MiT`7.JUdU*GV0Fo=c=IxCWk-B`WUw*Vmb^*j6gUYf6]TX4#vv%5#$-85#(9J5#,E]5#0Qo5#4^+6#8j=6#<vO6#@,c6#D8u6#HD17#LPC7#P]U7#$P`S%eQ4]kOr4GDThDYGXhdxFdk]o@eEPY5B:ku5l.6D<2;FP8DlV`3H>'##()lL#d:3Q#s-q^#$D,J$:XKY$<I?(%:l8i%=Xpq%D8I<&o#q''lg,;'<lx&(GbwD(nh&Q(siEA)Ht8q)j=w<*&YtM*UKN9+URhZ+qln1,c,wW,mSTb,_.V4-bDx=-3TBJ-rH3]-r?j5.ArgN.Oe-`.a*8*/%@dK/&#ZC/Qexi/VnQ[/vDR10Gf5G0/_cv0EfY_1>0,V1;b(s1;,572-QJQ2q0S*3J/Fu3:nrh3l%sP4Wl0_4iI@=5O.p^5^3)h596k:6$sd)6o7uR6uXsE6J$bq6@bl(7D>hG7i;dS7(%wd746>$8aXL88;%3E8-BDl8dJwp8(G`L9t`M99Z:Vh9rs2*:F^^v9s7&#:IhC%:vAb':Lr)*:#LG,:P/+J:&V-1:R0K3:)ai5:U:18:,kN::YM2X:1+Vd:UAX+;uC$h:?Oai:`ZGk:*g.m:Jrkn:k'Rp:539r:U>vs:vI]u:@UCw:aa*#;,v,@;?gM];W0-)<jGK$=,V%m<GNU<=N(=+=P?f:=0^:D=474N=_`Wu=1^Jf=&wtr=0ph%>Rgd1>YBhS>P(bB>VZZL><@4R>4%r%#q;'w#+>P>#$####1F[S..D&%#hDNfLaiZ>>?b(igj6dl867G&#%cb&#Tx*GMLc8Gr.#R8@'PXVZ,plG2*E28]QhfcNs%a,s]sk5&eOD/1qN$j:.<8bk'&kP8kPAm8wjlPA8:X,)bCeG*E+b#-E.%mSik)TJ3<^`a`15/E=((/h,m4sQwe6AkV$puc_WbG2^#u5&oU`p%)/Gk4=xK?$)d3=$F=:pLTxSD$Be;@$VBnqLSM&D$rFvtLo;TnLUh?lL^h?lL-``pL&dbH$^v[L$VK*rLwo:^#ttRRNld5vc,6qYZ2o&,MLHB5#pHF4OR;=P]FLk-$rZ+oL,g>oLw7MlMZ.m+`[9u-$q.j1K%####a`D-dH#,##=-xF`V3P)OA.EfU+Mvv?H&V]4avlx4DIaSA]lnqfD+nx=nIix=O</20h.Y=uBoi=c.Ewf;/L2<%lK^u$50fu-VG6IM5VK5#)^q/#w(.m/)P.%#A8`$#atI$6M#R4f`uQM'(rRM'i>M.q%+YuY::$)Eq_(/:GcUPK6pfGaLb'SexOX&#5?cw'cR:kO1S*8n81&8nckaw';lPJh(&u-$ViGlL2(2'#K:PwLuLH)M3-;hLw=a*MxZ2xL83mdPTc<uLA^41#_R=gLo?b'M6tVxL%Ef0#/L/(MfD?)MF4%&M<d7iL'Pr'#nWqhL+<oNS;a'H87HPF%v5_'#b5T;-B#G58,SK/)(Bk;-/xu8.)/P^$3IZ?$L'@W$U?@`$N3P=8JI-`#xJUn#fdub#aQuB$bpn-%L7'[M2VU2##VJCM3g=D<l#<`s$&H;@6t1)Fw`K>?:7`Db5qeV$K2w.iXPq]5C7g;.wWC9r5vic)#Zk]>7XtQBIf9DEp5_`3BF.s$j'(m9r2o`=sahq8`nwl&C=v+;J,*2Bs<OD3k1LMUpkM,W'ws=l0x4F%`#vY>^3[Y#XIVS%n#6Z$&6>##:EAW7=f$s$6lCv#-fhV$.]qr$Fp/@6%s92Mu/#,2[75djnHAX-6pk-$e^=p88$^>>h>VB$vOQ(#oGj>$w3n'6sVH(#l5w01d;Y^,<[2D+#s%l'D.;?#Ymq02-Vj-$Jpx0#k:)222#i3(QmOQ#$&###7h8/fT;mQ&Y<o8+ub%T%t9:02Gw7D+fRaR6K/=A#I/IL(6IIn]D46##-snh((_cQ#pnSfLQCi-M#Lm0)D7JC#s%^F*p&PA#;^9Z-*W8f3%IuD#h:AC#]nF%$J[7s$m#YA#8alk0FEMiL1eSg4v*Oul$W2)*^:lv,I0?bu-=u2(g0]w#G@Tv+r(&I3;3J>.]Ks4/vUjT/igOX$RW3+-f^gQ&HGhC,s`rk'ir@L(<n`,$fxjSugC[:7+@e9.W*/A,)@))+Y&?wTOq%##D2Z>>50o(<7xFa'cT@b1KM1@6RU1X[%9$6#<*A3k%r;&6tNWJ:ehaR6H%X>-Mk?S^pv0u$E^L0(.KM7cG_m)9dvnO(Zrm:]5L2kLZfLd8m0i3(`1M7#]Vgl8*[v%+N$(,)GM?/fL=A2)1CP>#'/nu[/#1@6=3%[#IA3I)7ORn]6*<r71'#X7Hanf3MvCY$xDEjLa'Z@5k^kV8J4j3=f7JC#E8Uv-?D,c4RP,G4pFxU/ooXjLvr&J3.sA+*&S'f)J=Rs$#xdLMwG8f3_BZ8/R.2t-M$bINc)E.3K?@v$*lH#Y12Ol8[:sp/b*Km&bL_W-[^/E++<Y;BSdfTKN1SEIWEJX-/9Tn/R$iN(]dlf(E7fq/+FHj4Jw,V/4`gIt,+d40I_Ep%C0YonebRW$($A*+hZTr(nqRBPd0933ubfJ(9pa'mbO5i(Nl'+$+aqH27'+p+GSK+*u+gs0RX&tJ?v:'#OI)20wR#dD]Q_`*JE[i9n.T#)jd52'J^ZD*io[)0VwfG2QY1@6;$i;$`RaR6Ek%D+_a_&4_tx4(HmOQ#>),##sMataE[M>#8#m6<@#4I)f(12)r)j97;g387f[,q&7oCZ#6$(,)KVdG*nlK02I0O?#iSu=$lsS&Zw&uU%$#7B#f1i>70sh3(S9JC#]ghc)tL0+*qSID*Rx;9/KJ=l(x]DD3Wex<(%_D.3x9%J3<)]L(hCh8.lxt/MxX7C#jK7lLNY&,M2]AU)?@i?#iSk`5$L3U.i@O]KA%wh<W*Rn2J8pO(ia5n&9rki(,Ui@,+alk0I#=U0>tp3:qUp+*,cUH4g0=#GLp^i<)P#I*8mRL(`p4b?c10gS@82<BAfNa%)(6C+=E=#-h1'k(rtsG<if*s/e-0OJ25'5BhmBV.xBpN4=:)58O=8=%A[#&+>/t:QuFC-2&/M98@ki8]<RL3(XatMi<+>Z2>Itaa9F'jLUDb1^7B./&tHn58'QfP^@8ct76ZT/)=xc<-hDlD%ekS['nbRH+tZNp+W/QI8d;<v6B#Jn$PkRP/>;gF4rqOJ(cl`$'pl^I*:lUP/UUI8%5.Y)4,==v68jS[)WZH4'x-Ku.uWiJ5qG^%9Cl&[-6=668&@a#5VU+d)#:<D+X_sM'Y8icRhoBxb7;ncEj='+*_;G##$H:;$A4),#bWt&#Q1g*#M[`3']Wk5,;D#W-cA1I$][_32,7cw$?)Zr.iRaR6T>hg2`oH#6<uGd=H7GS7wqA*##cC`+YIR9.511qeV%DW-]9pd+k2ZQ#o,To8`?nB5dh='47*V.3QV[Z$v.E01K.H89tr+@5=]N_#pV@g+5?QJ(-<Tv-Jc7C#6E*H=]2E.3C^WbNk0778#=kM(E4bU%JHx7R*VbI)[/$gHRD/8'($f=-h_1%,n;;K(%2(E>oSgI*x<2%,im-R*^tN+V77m$,r#$?u>,*88b'*)+6LpFM_dOY-@^X:Q8kYs.Ng1B-.#D^uq6>##$H:;$24),#'^Q(#gn3*]dnja,/$BZ7Aa$6#+I3'kmN`d3K]Ps-Q6=mL,27-/4&ak'>5m#[qb0E'Vt4$c/a?W&wW75/prgo.4Td*&O0'B)UrY3'+S/8^@1dY#Uf3I)g1LM)m`8V.YGCp.wxd`35[*QLC<UE#?gBZ7Q0+QL?'&N6c1<j0n&PA#$DXI)]AqB#iqd58/3&NMd;eR**n0v';@KK2IDQw-Yh3?[$<T@#Sp9J),HqH2h_K<91nWu7IYdk(ch,ft$[$7&jg401Ib;39m*7_urSqf)2W$G,&oQ>u=#er7.x&%'&PGQUlxVj$UYI%#Qnl+#qHn-2kok,2hCD>#FOY8/Re/g1iX2@6C2cJ(Ut8;]RDb/Mr'*^6?df87TJY5(RNOv;S=^I]e(vP(WBIp410M7#Bgh32.,0&+Ok[W-e%#3`6N'n/toC9/vFK58vrJW7U%qo.:;ET^#,nQ#>x4%$*%(,)A=Y@5]F-d4srh/.2j0Q,^'ml$wM[L(&i^F*o_$q$6W8f3/V>c4gp].*a^D.3e+3Ec)s>t$xhH>#4nFNDbV]+445:m8T=KZ-?DXI)$BLV%eR78@mqfN0d-4hDH+SuS4`MZ/,N0+-pO,C+.C?G*I2ao&#[t50+fR#0HiR1MD/<8&XN5N')Rl316U*V1*)OI)hm@iF`pU4AJPxL('8*U.HCCqjM9n<A?-k&F/5:R'8<Sx,ddJT;;>NuRV`)bt`lOi*vZ<D%CrWJ2+kUN(G*gm&IRv(+'s.P'j,G&#7;x-#&7xh$LqB'#NLY/]c.1@6wm'f)x`H.2)p0G4m1+*0PJ(v#3Xs'kTY+4;.SaR6FPb#75?jE4_ka20)NQc*Xp:0(,::L#Pqd.=qVST0jBLV%;IM7cQ]&t-6d=#-CI[s$qRSh('?%12q5X?#.tgv7D9B6&h%O$%F.1qe3Z#0)5Po],_[Cd--HV6NE%q71W:V9.(FVB#M)j5^&b=x#1Wx?9i`nc)oc<H=]8ZQ#R(7##d>>d$IH+,;<NE4+i7JC#v9Q12_V8f3_ffG30qB:%?1[s$#xDb5DS_;.C7[=7KJ+P(OEq,Fm(I]-F:F44gr$Ak*@Q8/D&Dc`(xiZ-_7lZ,'UXe+sh?P9*K*GW:v2V(37SU+xWSA,x=`m9rKVl]&@pm&4nY70Rb0d2)0`r&E'D*4ETqQ&6vi4fLgUdFgNuR0&#s#5MN$.6M:?>#vp%##Z*b>>]b=PAs=:-2[cMW.YRaR6sWkI)7Fsl&,%/Q/RnuB,%`LS.tIi5/J:KA+WB3r74Jm0)_RZ_#n`H.2;Fwo.,F6&%LXn3^mXbE*&LNW-+l[$7XTG=(x)E.3*xPx%HXn8.ofPVHo<bh:/s)/m2co%uO1/V%PIZY#^4rUmA2vY>+DNY5+Pi5#Mc`s.^a0Q,Pqs-]G66$c7F:I$FcI['hTV3(T)lQ#TM^o8t@]T&*oIJ1VI$m8vHAt[fKtaaR5kl&)oBj25qlv.cP&J3uM5J*WM7pp_/6N'AO:T/I_[1Md1Jd)Jc7C#He3iMHBo8%7#v,*DN;fq/0Uh$JDFiL0mLD-Nt8Y[r8W<%QQbt$>;>9;2b,-?4:oB,oiG>#9kXWmuP7Z%*?4b+DPC;$5[cQ'm%@(u%)]T1'ivc$UAMO'u$0S)Piq9;tT^M=--Xd*E->j's=BP8Lnk&YT](/1ltq7R?%NY-YlH2rP8AW&vHNi<rC2)5`6Ch;;T,123nq022SO8(;W$<&#ux+#UO<6/7f$B)F.c98i@)s[FUx),vDQQ#4qP]4>%,@50.3:8dP:$-dCXI)oS]Y,e/:h$a2Cv-?D,c4#IIf3/?l'&s,]+4Xf@C#`SuD4@V)u75L)<%h$6AO5lJV%^8H8/45LJ#7MKf)B0F-;w%;T/q'&@#0o5@,m#3)+72aO'wijB.$o3]-L=&;8iOBQC4^.)$Jp:T-]R[W$Fc6`,'THR&`Va&+R.Nu.m,u%='o=J2l$%X-$](w,;xXe)p_@/;%/5##$H:;$l3),#(dZ(#^K;n&v9i84vf2;]elD0(le.H/h)g,X0<Tm,2htaaK)lQ#5MPmU./+qe6KXc;'Fc)4DvQQ#2rv8.iEwo.8Rfm/c`LK2`r+@5<N&L,HTBaYR5>L:8H1a4fifQ_'(C=)<*-1.WV*J2pZYj'NPDG+ebK1(,;/5'`4u1)%AE0((<(q%kW&7/VUm%&9CO>H1n*H*c9V(E&5>##mPUV$q5),#xP?(#.2/*^Q=M?#1$$F#(e+o9Aa$6#4V2'k&T=f3#(^,22rb2(</I<3qxZW.<htaa:FI&cofOZ7'%+r.YP==$[)Gb%$R#=7jd6$c-N_v%$f@(#>r4(HXac[$8_V/2bW9s$Q`b228+%s-F<_c)^7`8.:tL?#r>(Q/iN<5/q4HP/^*?s.v0vhLq%M-4;=*Z#U;Nk+VvJM)_69$7hb-6%Dq4n/QjPJ(q?75/T0*'%B8?K)0[7x,u%7i$A;gF4twX%$MfCb9Aek,2bL_W-[Mq[u6((O1:-c9%2)<McAnc_u,[M4'xX.<.FPWm&Su)9/nT8:'U<^>>=Xn29--h)3ePr11F[Ep%M]UPSwF2,2#YB@tJaWM)u;hH28N_%4shK.hifV11/ID%,T`/L(JQb;;p=&]$_3),#XWt&#gaK+]<a/@68%FjLdfOZ6Tb)?)Hn3'kb:fT/udqA4K^.w#JOsaarF?I]AC(3(7d_v2a<2hL3q))+6]Ps-a*T;86qS,3(g_3=i&.1(N=Is-]']fL;0KA,DvQQ#(;YY#>%,@5kKwo.M(vY#+Pb)>X5dQ#Zkf3i`>mQ#j6Xg;--@B5VWYQ#U=SR99'&t%W&lA#Y/KkLd`8f3O2'J3s.4I)@K'T.]AqB#Wq[U.<VTN(Jpd.%eJ))3$DXI)_Q3L#*ns[#lG.[u+XW2*5(lm'hM%L(q0=72Lrk.)Sd^P@e75*$`i&x6=22T/se/L(Uo:c+8qG+u'JuB$V6I;%a`n1(_3o8%s#PPuutnG,#+QG*0'<l(b6=(PY;HQ#[[bD-rtP_+s%b**%oP_+vEL*#NF)20M7/5oVw+,)g5F]FpoFq]G0OT%SM0@6),o],Fw8K1%/g9]GaL0(k[i,/?dg*%RkOQ#4I$uS`+ii:<4AT&ima#-x/g<-sb@:.`r>##5iiT.>9UM'2X,1%k.<9/]tK_4?FCf<4WBN(GFn8%wve/&1*mlAV4Y.)90;mbEq$=]WPY[]BsaISF:so&(xhW-'x^t67J&I?6ZKBF9,*S#Gp/&+$at_$OJI)<)fS+VwMVISg?c,)`Yj($a=%g)4<9s$?hb>>1ofr6n4]eFF1NT/#XwP5j2pC%-doB5lI&S/E`r3(EsXQ#,DRd;_TKW7[e./1C-%*l`5dQ#K6EZ@.M8^15'2]$i7w>-4+A;%e.<9/;>+_$#qB:%.k3d;-Fwk(>D+e)?xaf2^L/A8j03<J>9._-r:uh^qA^F*#4QS7Ztv$,@ARN1ZJn[T:Xct.T'x+2.xt(su0]c2Zwe.U?G7k((aH.2pW212L[Hq]fei`5<A89]WB74(&K7T4v(i*%94_M(^Fk,&0=^I]);8L(1:q&(O%>jL3@+)#IM)q0E/Dj0'G`?#(]w3')>uu#5G&-2GWHv$@mEG4:Sxh(A1no%%e'n/I0O?#amcR0Spkw&egG2'ciWL2o^D.3mu`:%]f)T/A?Fs-RUp+M`R@N:<ocG*WxZ5/9TID*Gbd68]`8N0E^EZ60jm7&v8R_>,DxW8bZD4'+q;d*d*k5&xeO/2'xhW-ZZ_v;Q?cA8moOg1(FqQ&<QT;.v1/V%Z@>3'jAu=$E0gm&'P8p&.NY14%W)S&.[74;3.vjuq?MJ881.(#xd/A=6dL2KMsjo.?HX(aL<#N0t42@6^`_02VPW>8rG46^@-CZ7$.(F*xWEC&*L4C&>/sh1vuW8(B^031kr+@5cHE=8hV.O(Q:[c;4qBZ7,cj9/$`V9..j8A=+fSH2?EvaaQm,87Q_X5(S9JC#.S9m.+TID*a3FA#]2Sj%qnn8%x,Tv-gc``3IZ4L#GP>c4SU)P(/b)*4-VsZ[dvjS8xjWm/QPAw/BshU%lnuC+i&@51sx(NM*lmD*o1-J*cfYX7pcACH*h7#/_#dY-aswI::Qxx,Dc=Q-*^,W.&,]A.+%2TN5obm/*$fDE*mUh1DA'97@@E`%$-hDZbwDK2&5>##X[iS$t+u.#4Vs)#e+Op<R(i*4u]mu[.M2@6U;J@#;[oHO^f(H8NB5'k3aqA#ctGa'kE#f]o:uV-4.1qeUTWP/Q0X(&=lDI;j1_3([1I>#XGN=8QL^[>0;89&*c[:/Jg$&.Qs6+#)2i>7I,r71<:<d>1i,K)Y#>1:E-?v$-7j8./Y<9/pq;W-3]/<]g`[:&;<Tv-mPXj1uC%$$>(;9.vBo8%jul)4+M>c43t`[%1m)v6W^rS0LnX91rj.G6@Pml;tC3]Jod'IA&@)V6C]=4'fSI1(:64Y-lm^q%u]DB4(6gZ=*^/5't1+i(Sg*d*su<E*Jeq]$`iMk9L^m$.7c:<7Q1H]L'C7s.6lF[7A@1g2-&(,NsvI46Rv'G$r/$3'RxRQ0qIvr.ke(`+728*=53482f%^B+RST`EiRH>#M3%>S;7wu#LI$##o`_>>f0el/BMp7RP,_5/q]0@62+8c=eK.q/TR3'khh'R0^xLp.mue1(0BX.Og^s?#UDeQ0_%b]+kaNw9k:Nj0511qe82'B)uFC-29u.U.aAou,vYV]$1l73:co,0)g*E`#GN$r)v_6-N+bS),NrU=o9@AC#i4NT/Bdic)E9Gj'V::8.NFX%$.g>)%>mP]u6ExN%A1nX-'d-Z$-H4b+>mcN#I(Nl0c4(W-e8T88i)l,2*EC6&k^8R/%7$GDM^fA,,S^T0L`Sj+,JEa6Mg+B,guao74Pc5/P8gl/ocRuYvCoD3721@689:32Ehi(+NRaR6x/Wq89QFq&Vt4$cx`Hj(LvtL:e')^6qpuaa^q0c4lErN(,&+22vao1(G)lQ#J?12'4xF3`Fs%<&qP5w-^bko&A0O?#m/?R0.<&v&r40&+BO/m&j+f#%B_ml8pRs$'/)12)vvX2(QJo?#X1i>7@lN_=>=#H3TWX`<ErG,*@8mG*V#Jn$N&%&4v2$D6f]8f3sJ))3>0ihL1bo8%X>[L(KFn8%7='t?-+h)3wC?V.>,hZ-I$0q%6MeM1xDHSCUe:^#KAGN;:L07/#,,g)]T=X$Gttk:G6_C#lb5b<#3rp/be%W$t',*=>b`#5;Ygd+9[:-MWIB@8tIACMYaZ[RrBpO4%.ZC+Q-Gj'hB4X$IP[B7THFrEgET%#@qn%#H]al$5O(E3G$h]7a0#R0G[v(+[B9q%Tq[f1li(<-`q&0142.4(T)lQ#1wKM'23A$&SOV>#DvQQ#nXKAeZ>mQ#RlUi:7*mh2#dkV-%kRP/g<7f3:%x[-mP_W$f@i?#eHf@#v>=c4Jp7x.tgBl:2EW&FB.i?#vRqVAcAuIUith<-BPRI2+uH$-i'[9.TxY>#:2h]&BWC0(eU431'GKR'<AEF3:?'@#'p[L$Y(::%%Or[,KC@s$v^*q.u$m(+IVsLBYvA(0+E';.nBN6/t8dj'r26r%2n]G5Q-RKu(t9sH?IBD*wc6A4J)9N)'lAq/wW,<%nTgQ&0M7n&LFLZ/W'Y/2A'MS71`En0TW]%#=G:K*/5+qecGPm#[vcw$_k36/gmCD+8)Hf;W/4m^cEn],l-/X-KBi(vK@w[-Q8:Xo)4YI)PsN1)MRZ>#t,]+40O=H;1WBpR]`dpIpXoe&Rt5-3R_ZE13<xA,Qj)&+0`f4jI'<j3h^Y8/?j#W.nWuM(Rurh1u*?ruX(n&0(CNq.%Q)k'-D]L(hd^Q&Pt9fu#pkeugPtl/MArl0o1X.)1=)`+fM@H)jf<,#8:r$#Ko&m$MwK'#mH`,#Lug[>[]8:9n=DD5/u]60PN]A,[BB6&`gUk1`GCI$4nvcMTx)B:K^X5($+o8#O4BD5P>0s7FRv0)o+(-2bk)J=F,eQ#N.$3)xeFI)>5nB5-KGT.YR7##L$r]$[*$u%a.b$%E39Z-s^v)4PP,G4/,698A8YD4mu;j0Nghc)S9`a4>U^:/oYF)NrWo8%HdHD*YiWI)a9;gL>O)[%F=quGM=qw,woRL(feqE4x7S-)XqOJ(`U5$,3?>k0b<]Z36E-R&;x'2),>s8&r;>A#BO_j(o7T32+c_x6ZB7,*$17x,g5>s.w]*:0wh:Y#',0b*rS2O'kIx5'sLBf)7lh%kpsK6&1Fmc*8F-,*XslN'x`6]AGmcO0_oJ#,)Lv(+hdkt$PHUEuR.^-5AP3o&)Ybi(bUPc*xbG?,h5YY#*8###B1a>>FE<J:k_Qp+[f2;]NSn1(kUDK.*GgB+(IM7cDS/(%XqXq/J;i#$Pji4`E&(-8aGbi21Obg$wk@u7d[Hi^LWY)#?Gj>RtoZ3'-Wav%Zp+A#;+Ds'I$Z@5F[M>#95P0&PLGI)U51=-V/hs$tJ+P(Jwkj1%RW:80nBn'SiWI)DX_a4GR[LM*fZx6=J))30M])3lm5&4pEsQ/WvCh1R1]^-xu;c<^9Ha3QN``+kSd4o:Cr@,^LM?#7gB='XYxh(kmaGstfNf2,rKF*8(Dc;kk[W$,TtB,XpC0(dI%+%U>:A=U9QN(9MNb3wgw=-ic3**C.-M9:wnc3D,4e)lpBq%6b1+*&bR=-r?[i911&=%-QXV$Soou,WE5N$rH7Q%34:hL63jw,UkDZ)&UtaaPY09%@qAg14IP>#-r+@5ShZs&neJfL._d##Y6qjM,/+qee*Xb<Pfgj(Vxir]i,Q:9X)QQ#FuR/jg8CU%6O@6/BXx2-?6i-MU*RL2[=YV-.'_B#_N3L#';:8.GIZV-#0B?&(Q^8%CS,G;FVf_s_lNC>CC,W%2`E%$8q/O1?HP_5%2kI)^>Z>>jOnlBBhe]&,qM,-+<(M'A6UZ-]dfG*obVV$_/+##cQ1wpi]I?pmQs+;/E&YuGF.W-#Ack2Fvbg7`DXM2$M@['ar_nLTQ45&NRaR6XU<**D%k>-OJq*%('@L2:c'n^>6C$7KERL2$%6ua.mIp]1EPG>f,i$'i^t[@A'MS7U7j0;AqB'#)/>>#F&.1(I31qe5.n*%0FRq[QdmBA1-.12'/nu[9+<kF#1ooL(7N#7bpI#/2FlY#Q*HElPP6B=7vfW7L+H>#wY2o&s&C@'Pu;[-G`Sh(.nj26nV-F%<7US7>F(X%@n7##lLp?.(3@G;tCwm/Ra@j212tM(#Gh=-LC[x6J]B.*@6[^R=qtD#$@lD#:rM2:#Qm;%2rQWA?e?m82_X$0xp9B#iA>.)D]SDA3v(:8o5]=/#IV@,<GlYu_p+QBB]k]u%H=>56`5W6qP-L*g$W@,+aL[*GJnI2e8Z>>bVxl(9wf#'6rC,c6+P_$vd2G-4G%_ufx4G%ebNp%koVHI;b#O;HH?90B+U'`>;Ta+:Ab**0OD`+oAHr%&sC'#QO)20*JR>cVw+,)(g:D3hReu>Cct#)BoLv#W]mu[P)0@6.VGq]BE&&,XBrP0ZUiX--s1I$t<@42kRV>#XRaR6&#xX-LnCp/_Aq*%ELEu7hbxS8>Vi*%SRD##_$ov77[X)#QZajLSGhl8<Kk2(j9Ag8k(,d3q%DM3]OsaaUrKB#]0taaFweV$;-(,)pbr/)@K*t$BTKp.'XYQ#QqOZ.GG02)N4A>,?0(`-M]02).%fB=r4tL<k-,*,23#L'V[M>#L2KQ(QD$X.7-kR00wgd%PXIx6tY+(.EN$=8=wsY-$#2t-42ZL:B32H*6?B7/K+.<-8a/(%Gc7C#`nYd&-)]L(h)?T)vHUfL('Zj;+]g^++$F#-:EEx./tbxb?[qC+'@w5/o-oo7X*3e3r=9f)Y;i7@b4&7/:56u$R6)C=-u7T&LxVk<Tn%a+GU5H2ama@&7FKd<g9xX-BJ`k#BYR7(%gOW6wom(#_PvF*LpZD*P@$B(NSQY[2fjA1k,&i2WU0:)/qm128MFL(Dx:v#ehaR6dvR%-bY,d$D<]`+DVCv#k=9F*eU4q/=i#Z,hsha3a]hc2Wr,##sMataA;%<&qVYW.Hv3G'nuG>#7(0q/TWo],q>Mk'UWYj';Jwj0t]G>#lN<D+SC78%_<bT.G5JD*%&FV&ej3c4%-=b$Y7#`4WdHd)9(Tk$Cm4Q/j>%&4THuD#)li?#/r/A$'TEmb&ep%,ZDU#A,*X>->WhA8.Qcj*(S00SY)H[9<R(=]KdK9A7Cs`a@QVl;'_wl/te#Kc>n0T%rXMFR*-m1K*nH^,<tM$PMsBL?lebiB4bt_$rDdA6uFG0#Na'BukWW6&Cej1T>QV9/';Il;mhRkCY/pW7w18F#Jg/I4%4,'$CD1s$SPJU/X1kS.'V487tQ`@.r;Tv-RHk8.Ynn8%rq8<7sO,G4U*[fC]T,cO.k#Q:baCqBS`YG4>'*-*j$oW$9BxH>>q'^uAg@$7tOrL=&Qej1&;Ap&YJ%l'HF%%#7$lf([k>AOMsjo.B*_?RKPD^:Bh%_QCN4D<AErD+JF^NE]>mQ#.1_l8Q5i?@W^N^%8ZhM')>2<-,@IY%C*X:.Y,V-2g6bK:t]Q$$3T+%$#QT?-n:ffLbHAS@;V#T.LX+,)Wxdu>/fxwR-Cle)O7_&(V<^I]:DA1(`<k,&<MJt[([5$c-Cf12OJUb+CAmB=m],g)>oQ/)]@e0)HDLL3):[c;TxJp&/cvW-<juglI+-29Xsh69vI&)*7Bk>7P%1v7ubdx%8i^F*lYWI)F`?p.35-J*uV.u8`5Hj'#](p.;;Os67Mch#0_#V/4k>A4g(j60]::8.Fe75/E3(99_Lju.abL+*6MD[0'n0D#rU(B#>=Sq/WnIcG(4%faNb<L7CmF;Ma'#p/we/N:#C=K*woMS&ua]>*>mM41u;B0<etU21E]'F*JJX<@<Sw>^T2%V%CReW$cO_)*lqUw,Yl4IF&u(cP*St.FU+*UUA,vf3DIPe)F_[E5Z$Z31$Mv35tWqkfYl>59iw]'5V+jP0Xe5D4.7lM*(s<E*sb$##(3V(vIoD[$IM7%#tTr,#/ED>#.gL)9N4'/2Bjq321D$)5gk$m8YZ>@NB#f.Mx*?^(U3B.]R?6$cqM(o:oSH.]KA['4Xl$t/3Z1V]9]Ep/p;$ba2KC%%*R7gWr?8v7M#YE=0h8A=96F-*Zmh`-_/dQ#*6DLb_>mQ#-R<m9u*@B57F;Q5/jbJM>.uD#n.i>7E#jc)?@i?#]TQl$@Ies-;<]c;x^lS/xS5<-X'7&%?D^+4f0$DQ>%WU%@9]sT*te6%xl[I)4%lg/ORr?#E+%gDd6@t9Zj[uYt'U21j2W2`g2v++TK>N'[?H6'I$>'GWq@),_@S#72HIa=j)+P<HY)l<_FgQ0ZKm^$R;36&Tpl/(cGTo8:YZO<@`T-3+6p40-T/$9NnCv7h.Yw,,vuA#O*ij(%&]fLC(^+,Yeq,DTs9^6W[,M2NqAkM&KVBuEH_9.xFU+>F)QC5vv%G*W9S%#T'x+2$wSA=RJGM0ADTrQ.wJ02sjM12Yip6&jeT3(`958^-Uu31<.3C&DvB^,8sx6cs?Al'SXl/Cv4]T]`6AN0d`9D5LJT*FKn''#7kh;$h@R:L/BJA,R`[,2d%%12'0H6&]RaR6aih02.drS]5cl?,fhT5^1c:;$V0KT.']6##)b(=%PW_kD*IL+*YND.3#mqB#JafV'g%5?5^=YV-LVd8/xE(E#PGj<):Df].5A;63;;DP)/$<b$H0l9%Gd:ucV<,`WI+Gm'q2ht+hIY?,ZEHI39Uhq%KjBm8rV?T.hY$$$-1*G;DvIm0l1;;$)1K.qlg)gCW7lr-V>p(<7er8+x/SJ0+v0@63SKt[[rnan36v70nPaq]*24.)xMataFC_,8;4B.]&I(a3[Huaa5F,##`ZBt[92,qe7E'p%Qj:]$;?o#M2EA_%enQU7DSHA#1O2)5Kt))+*CBC-pdoK'V[M>#`?.alVTIp4-.Te]fFI[#YDj/%C9N#30B.)*7#WF3&<AS'ZZNh#B<Tv-1oOs6blTO95N1a4ddWjV@3S>-$a=4%mUFb3w*VHG=`NX%VN0+*2xHv$Suj>C+55+30.#g5`b(tL(QYY@@'/O2u8YA#Jq^-P4Z#H>mKC(-&$lT%RhmrDH6/gFQ6xw/6YE@$9e:C$c.xH)_HeS1dIgH)h9j#3`-%5+Ne))+7/(XQ.x^lsh0.s/B##w,d05_-uCtl;4-&D%IML9;I#gt9q<hL(V9S%##k((v)Y'b$IM7%#8]&*#RHn-2-D`5/:a/@6/5rhLFOfQ0kea_5#TQY[<gVj$&13'k81/^6ctAg13>S1(0XEd/s(o8#4p.o8d44m^j6UV&r:]K1,mYA#/[%a5m]:$-:mR)$qIHX7EH-)*KrC='27')#oP*HFR%aL)(i^F*9kRP/;Od4([`JD*G6$_-;en6/p]7&4XR&r8E*?v$Lx@T%.WFb3Xo:Z#3rtw$xxOqAT2d-=m>P_TOx/;BE8+OD0]IH`^9O8Ko::A?>K?X;Wld8/x9)gCpiV^672vt.gaedD4>l_?/1NO#-8,k;G?770bIV+G1dT+4<mL-2LoIG67Fj*O.r3P6VQF@&F)drH2+R>#%/5##JCoT$=Do-#0DW)#ZIQW6%)IW.25Ol;Sa6l$XMwD06)o8#(Rj/2]7(5;BESG;nm#0)pURV69p)J%+)12)w$F(#SI7@#A:2mLq>>N-CpOl9@[Ra+GnPs6m]&r-)-4L#at>d2R35N':]d8/aGUv-m$ro.bHZoD<x`u$_?,T%V40fN`uM*<W<b&5X80>6,WvR&hoN**XWvsI^1RlL;L@12m[;H+nNpq%_DVuA?3cR8p_r6(UVMO#'WOX8cP2S&WpDA+jl7l'k):n9Vbn],1TP:.=PDUDlfd14Dj^&6'3];LTc$&@SSQ##r-7G;dkdG;f:)/1DjT%b%#0X[.E66#f=rv#Zxir]&bRo1:A8X[u^S/7#g`3'TIdP/ehaR6DV@&,0Md;@]G/:9HY.5^f43v6CV89]+]TN(*TxGA'Qq*%RZ_L;7DoT]-VXO'p;$ba]>lf1a%su$U[M>#+pV2'dfG>#s$Il;?3U6&)(dm8^)gW7:)*5AYi?##rn,X&8/NU9u*Fh>uCv5VpSPA#_ki?#G%+j$N,$w-N5HT.shPl1sfh-%t3C(4&60<-AIor%c9Gj'6:t+&c/j$'A)%E#x9Q12vj<20%[0q%=NF^,e1B+*$S`,5Gb`u9xJwU9B@/gD0rj2WlN=H>_NmG<$/Kx.@-s(.ZDwnCf2qU%Kb3T%*upF*BeEt$B7.W$XH1audHUJ)e6]X'-X?uY8;fh(Rwkc)x5<SA8kIs27oXI)QqU]R,uCh2I&XB%,+rBBQ&jr.79f&,8NTPVxYAp&L7:GDl';@,V)'#&*K@h(`Zhd)w4<%$].0'+to###^r2%vda1_$KYI%#>i8*#fDD>#M%(E'KSQY[/bRs*?r:T.wQ&N6#qlh1?>1@6K`_,)Ut8;]]tR1MEDG^,+5G7c,<>2(QmOQ#^a(Z[7j5pL)8dk%^MZ[-@Z.N2cK3d*xql29e%TW7pf387'#'QA%;GT8c9N#3V_f2DTONT/9TID*qi@1(a_QP/@+[gD:mpIXteF.)%tKv$=;gF4ZF3u7FB;-*3$0,;4]9'+C,27/&KS5'mmI$9L;CW-ZVk/Y_>:?-mhv?&U$H-3mnEU/`wPNB3;YC?Z`:ku'350<S_B<9_?[k(qSH7&G;jg<p3(+G<O@VB-JM^u^>fC#&5YY#Ic:EYwST%#uNv_[cD66#WX7w#Zxir]La8E+7/sW[D:)?))f2'kQmB#-?U&f$c*%q7^`ST&_wUD+aCQv&hH<mLJ81?-mX`#7`jQL2>?(?H1X:E4V)2u$HsO.>#7_F*u=,,Q51>)4'cK+*aBf[#8l:Z#G]d_9_[-l;=24.,(L@A,WrQf;U]hO+0D'q@4_fY#VZhY#F*,<'YXP3'V`6rHSWQ3''KC@'X&8rMWJ6t.Qj^&TxS'@0Q@$##1jR)vM[S]$QS@%#dTr,#GX*)*m=tA1mf2;]LiR.2p8d/.Ren6/s^5$c`W(kL%@,gL[Y&<&vh8q/BG[v$4YSh(T,Lt[mW%128YaL)FU8Z$%57[-7aH.2kq'R06iP;-ehaR6sD:6/^WvU9^oRfL<IK('-w$12J]d`*l=$.'TZls.X$(,)d`9D5E`S,#E)<D#?]jV]GWHS9rjO,;tAZv$V$h>?HTu)4Gvic)jY2T)GD0i)%l2Q/?_#V/[`4%?#V:E4x]DD3j<5Kj^Wkg$Te_F*3%I=74_i=-;3m[$H_[v-C;`^#x,No2'2iv-=glJ4aQwK)Dwln0`Hg$l%sjFNsITF_lpWG>t_loTWE`N']r698#6=w?$f-LO.2[n(c>%P'q2[90u*glLX^A)EY'#R0LbQ*=E=;H4NdIt/d;;o&&+LF<9Okb?TqP,6K=d0)7o&Q*bQ0o<g_$.37kW.'Ym?:9.K2H<<AiL1CX8n/<x^]8'w'v-MD2MKVp)^+]<,8@Yjdv%[.[W8XbqF*WM0@6NXK99P=(f)Dv)E*ehaR6DNCJ3)5G7c$H:6'b/Pb%wi3=/]qG]>p,*qe0O6(#^`_02hCD>#E&[Q#'P$##>F[q$+.uB4vOGM9&oDH4)aO@nsOHX76d-8@T<<78MmFq](8G>#YfRh(&7QL2fR.+<sE,=7ZQlj1*T9R/l@[s$<67.M_rud$]Fn8%'oDu7op]G30sc;-F#Ql0?3nO(d8=c4w<7f3qgpQ(tbGT4sYI@>Mq+(?TlP)>XRD?#O7BC>:I'P:%b28DWA]C>*CvO>h#%]@fXe>@0$#A#RZv`4_phu.t[/60Xl5BI6>:/F1iQa$]aEN0NUFt84v]51)*u9%@nbOoPbGH)kNJe4_0+Y7lG@j>n<)m:jeWd%Nc$:;r*h#8^1x3'_MMS&C=kr/.6Z)*-wgQ0a$4U.c'jL3UJ.laCXN$#s=wCWlQPip?l3>5uYe;3#A$)5c*:T%`fE+3X958^xL`B##+(F*kXVg.Gw4/(#VH.]n)*qeH:g]+F&.1(6fV&1k]mu[8Y1I$bH35(`jk606VSh(6aAW&poXV-`n7<$`rV20bF/.2?FBD#fL8Sq/JE]$VwX,2O29f3?;Rv$t@0+*KG>c4vJPT.BkY)4ath`$F&#KL%W,8R+JK[HHFN13>+rW-(E3*4=J;W1'Y9F*G@T%H7BtwIKwVe=mV_P<SHBh$q@k*G@uCf3wsSE+CHJO9M6UJ>eI/),S0rX6;U)V&DEKB4ebXPG5YrK3Yc24#=UZ%FA#]58r*gc)(sq%4T;Xm(t7<9/3lK+*Y^5n&S+A3iTUZ-N/jkr$W<U70Q%?B?g`)O'P19g1KdR<$:n4/(`958^G>:.;Cdt[n&%TT&;plT.N3H>#54Q]%K)..2_dH>#7.eQ%eqx<(d7JC#.$s8.<@i?#Jah,)=D#c4VG>8.5J/d)3_+Q/O29f3v@6T.A)WT%7VKF*[3<4aLXVN)&^ImD%KYx(r;hb*CCY=g/fC_?pdGi*M,9._opjvM::^K2F[rOS'Q2eHL.6;8->-oBY[h4CoOA?AI<N'?QkH%5]v(O'Ur-3*dwAw5dAM4'G]kr-lM52TCnY]+I:>ig]/+,2+)Uc4T#,d3SD#W-cA1I$*X[42*iSc<`<4'kc_QB(<fCv#h<@u0B^=g77=^I]/D[w'nm^I]7N=P(cMav%IJ^+4Xv1d2;>9F*;f+w;E&Et8NL?LM:dGq]5CK)=o@402E&Jg%k(o8#dvWW8Db`$#l`CW-2;)UMw0102aU6i<QM]D*4JDB5$g2;]VrRfL^]Qp4pih*%n*5D=kMr`34a0W-?kY*70Os/)3LcY#/grS]v_fU/;7n8.@vv;%wBSW-xK`G-_Es?#F1`uTV<]s$s,m20$L[+4i>sI3Hdk-$M00Q/6UL,3$DXI)?5.T%4O/i)c2#Y_Yj^X'osgR/p2&^+E,`11@K2%cVpAe*$Q5]uR/&q/<KG]uq9vLaH=s'+lr6+<s)Hh.'OD`+Y)-BrEW[HG:46m0K5O**7n`%,sYDo&#mJf3I`ArZ8nl,,<.<*,)EC6&i%V]=J'UZo/663'8]eC#w^@A,hV[H);4]Rn2*,##>J2s#FP=.#H)9U[fMm2$`(o8#pq*87@/c/(S9JC#XhSN-:F'k$?jNh<T<F.=tAu(E$Hf)=;''##chN^-7k_'80>PV-xCu,2*YBe)eJ2X:7EIhL>Lj>7PAkt$&s,t$1.N/)@L$L>)vN#$(r/gLo8^:HL[aE[8tis#'oNrLZppcN_kI0%S'ULjE;02)jRNW`AOGlNm7,,MFBl878,MH*u,^f19VT6aF?tp+f5,%M=Vpm,;:rr$6Bk>7q9&p&/CdaP<U'5'hl9p7;2@`&o3AT.()+cG]Z[2.oO_28;D?IQ&<s(#WWWhu+j9B#R(+&#.Px4'av$12pjxfLA<bH&)-9E<aEi^oUUD>#<0?90bj(x$+A<T%]P,G4iC]_#g<7f3:gU]=Kjuu-=6C23(9*<@KrA5'L?W13^GA[8(F.UA(*nf*CJ..2Nu4.)44<5&QO/I4B:1_A[bP#$QSgc.@NqV]0dgG.Ni%T/#q`bSqVq]#V#L^,]p4j9nBg;..=3bRQThj)<kWM-ea<?%@t6^#K^p[%9S^%O42gS.`svx+hE[s*?F#12%J^a*>%3K)%@mq7?Y2s[OCIv75%j<%Kp?d)wFgY,ApFL:w@-E3IoOC+K?uT/IIHq772C]?ttrSKVA;#G,rTJ)kdwK)=GcY#$L,R:u,ms8A%pI8`5YY#K:l>$OjA$0)>N)#u,351#E[#%Yv,U]Qe]v7Ds%<&XPG>#96Ud%w(12)O<oY-X`G*RZ69K3wo=c4YG-mqsQnr7pMxa+VoIA4Jjuu-F[gW$O9jgMMZ6G*i+#A8:+qWhIl69.6Z/Y6qJ0g2iXfZ$V1l9:6^/Y6+ZZ&,tq3'osI%@-MZf;-#iLA2J(Ya*4.1qeI1ad2k<bc2lxFdM(YKcNgn]^$l:VX-+Jum+^x@08EuO]ubU%r7LcaAdqq6##:52S$8>x-#'8E)#,tdo0X?./&/,Ls7?+Vp/W@ml/CI-HMru%<&C2G>#7;s+&fA9g2N/W5_2o?w36lR5h&0Zu+Y#aY?b6,f8926pgcrGp8Kp.ElxM,W._d?A+kkPV-?qI.2H;dV.q]*qe`71P]E,>>#qdbp+x0-Elg26N'1ITk$Gc7C#%t:]$Jn/V8FoSx?$#V=-'i)Z#:Rd(+BBYj'Pv/I*4`=Z8Dnf]$fCsU1r-7lX1toA,NFD`5wfSBABY86:2(H9K,GIZ$Zf[%#2)-h-v6=wT<]8T&#DdH.S(M$#)c*E+BFiN97/vG*eLucGnl+G4_))]Tw>f(+ce'HMTv7,?*&V=-fF-U7j<v#$?:9s7=W5D/CXgOC&NArLD?=s<Ht?F#objm_^'wu#=1<rmf@?#Gm>q%4+;(>G<m&W67/1@6*]G40Vw8;]L*5/($ATp+j*'i[+ONQ5QG@vA+/+qe#<ff:8ip/)GAhc)MKcQ/A9LB#IOjT/D<dH2):EG)r7=874L.T4o9N#3Z*N#&](Vs-=@UF=;1?v$%8h;-C&U(F_AGH3MD^+4s*wi9@vv5/Y7BJ)HLc/C8Q]kE3wu,F?t@KFnTfCY>o$G*(wxS%K%b;99T?.8x)h)3a1(G$e>;O'YjJo8=MJ3Dvnb>HU4.'5%M;_QN7Mu&2#UZ-07GPAPI[8%M7F241I@(8_];Q1q*:m$b.cw$w<?Q1/R:+*l1Fa0P@3'kBOv+*kaRZ)hRd;-e@/4(T1TH)O`aI)wZMu&xfXp'XVG>#^Hng)GLor%[m/2)Iv,U]vL.%#j6=Q/GBuD#h:AC#GiDT.]::8.t,jM%6R]5/K)'J3/rg6A^L)<%iL0+*lt`W-7x]p0Yc;OD2*B_8jT=h)wW)cGmDm-$u#@T0Dkiv@:WAT0+oJ$Rdb.T.E.=`u8/(X%$84GMR)CA6%/5##'`K#$8k&*#;1g*#aaBK:?iN9/#Ux<$t/pF%jp#U]NNc=$4.1qeJ1E-2_*+,2P$t%=/LT02<a'k9;lCJ:U(kG<J7902`7JC##V'f)ln(%$fZX,25P[]4N`Aa#^h/V8QS/<7kiE.3Z@II.=Kh1piLvN'w91M([wae+PZd`*6^Jo'.]&=/r3x1*L+mYum$U8/sx<I)&UwENhSlt7#1<)+Zd.L(F_I[ul&W@,#BG]u;IH>#4:Ye)O,,T8$HD:%IFK=/7A'f)Oohs-f6Cv-dgFZ-L/#c.cX,Y/;0Xs73v_Q9[<Hr/:f+2(Y,[1%+hUk1O4jv%kv$#%Gd^@#nm4&-o%55(DL6kOM5[?.%/PP(4i#W6^fjI)d<OA#fgGj'xx:9/'K6C#xE(E#,2'J3v@II.lt[%b,0H8/m)ri'?fQf*S:l$,Rg@L(sboO'q9R<*Nk%@#b'Ux,`c?gNQcmD,Qd7L(s_oO'qBnW*Q3x<$n3)f)+Ut,<E$.H)p;@?.fl3.)eYG>#vF_<-7+qf)+xmt-B]uj)Ho7U/#lwc.Hb?g)TsSb.S,>>#$G^V-J-M58-Pju59o=%&r>h=$A'MS78PG>#f<0X8LP02)Z/av%lrTS.l8]j%$4e58FZlA#Ga17/TN9AP]K?2&rnu#,@7s,*ZR>,*VQv;.a'Dd*]?e)N`buc8EM]j1K5d1KbH<J_+?xu#C.Xs<J$hI;uYi/:>d/@6d2DD3c*Xxbs0<<sPNCFM$&###e<7##I<gi'/OGH&>+`v#[+/8^5fP>#Ti&F*3lAW&UKgQ&5fCv#D?1K(0l*)#EglHMWXiX-1ax'/g'h-6K/,##hL+,M;i__%vg'u$ZVd8/wHeF4k&B.*N`8F*HK6i(Q?VrZ;hKlo9k7L(>(rP/wa/A=Xv*j9AnC/;Y#no]:_S0PAY:?$;xi$uQ:@e-0SJYL1W[V64O/cL_'l+)c^k4MxeD;Z%4RL`a7TiggPSV-kaWp+@F#12)lc^+)8@d;>M>RCY<]s$.*=Q'dL0+*o7*T.?]d8/D2^V-Z#m6)_r<sSaUH>#MNRG*%F%],P4LN(sQpJEE;oQ:ZGIf$8g=I);Fe;Nj=vkb=Jd$/6FF^GTETMZG*ViZmwa/#XR^%OQ[rJVi]or-$uo>-Qo5eQ=:P,M<Aj?#U-afQfF).N=t,H.ax;9/[iP1jvBBW2q[M%PYOKq9_e5(7@0]-)d[Je%=JfL(Kk(&5-v5vGqU%+[EmI3Zq?XbGq:XI)::@vMmLMLc<S)%/G2b/MIZ>mUvR]oeKa38.47Oj$Ef2;]edP/(h:HN-OZ$)*$1)7cO&8?#a8Rh(J,Gl]5ol##jP*qea5p5#Dxir](/###lOpN%`$`,b%oFI)J/tX$/<cu>^;#h2BwAv-oUFb3_a>,%1TBW-oeEufn#^s$:C&PJhV<**sTo2*T_Bg2,d@1(,g;Q/i;#B,&Zxbi.)3^4l]eh(,d?;%`Y[-)rLRXla%kk'brx>,-Gx-)O1T&#ABrP-vW7m-IMWEeegH)*Ovn>$N[K;F+v`Ee.fX,MmWQ##)A/Fe,Pg,M+8c=$$r&N0&7QL2J&B.*#pl$G69<v63-WP%10cs-fG):M3+%PJl+5Q0/X1hLI+UKMn_Z>>`b]qd_vq>-Voa*eDZAGNIDfx,ZSK^4_r2%vrCXa$]rn%#9DW)#fcL(]s`0@6Iq?<.+g/ua]n[K(BiBT'T#[[7Yse12@JxL(/7p02NKNj13n_k1Qd/02LSal2TUT)=iZb&#tiZ.MQLWS&bnq91@L#@5;eGe636`k1?WUN*[q56>k)5u[fnsaa1lpo%TI3v[Fc,qeQ/mA#ZdeD$&41f)[YWI)DnH]%Js$&4+1N*%%l2Q/-$:<.e0DE4msO9.lSCu$d8dGi$cK+*a_F+3R.i?#ax;9/OJ,G4wg#>5poCb?*:q.2*-,A#OE`%,:p,<.CcIN1xGNI3(Xpq/2C8^3l^Tq%2v?s.hlru1lYwg%lSZ;%pc;'4d+Kgj0hdL>e^f#Q*/Jw160c^&'XQh2*Fv`+fYI1(Og;Jqopje)871G=u)Xs@3'VK2-YunAqSc^,%G,_+Y^:l:&d0B.)/7_uRxc3'25<5A'tf9E]Nup;^#mx4-`3;dm$=D3)q3PS?-+/2bk)J=LoOd&hNtaaXXcL=1b_v28Wld2+R9f3]NataA0k^7PprT&=m'g4LAx8''7PY>8r-##aLW9.P=]Y,ZZ`.&ZLGI)[KdU9vU#J=fwC@89vPN-QgPJ(7Bk>7u/,n:%Ph+*OMFZ/WqRP/>U^:/c>;T%DC[x6SX7%-J^D.3KjE.3l5MG)CY@C#B-Tv-iL0+*ST&+cefID*$f#Q8-Rg/bF.<9/#Cs?#w=Fm$9d;[0$QOw9TXQ/2`11_%qgK;?0h&&?W@-e>A)/RT%wI$?1'OY-nowh(j'N@,Hcxl1_`7C#B^9;8;s1HE4Zhr?HHL).#`W9/UjTE?&6WO'rGmN'D>Hw-(DF**4/Qt7Hbg21I%nm14pK`5E;c0*^aQ12>OY,OXHkx/SYjg(Scf>,3OM42Yd@l1K**h)NK@=R-kjJ#ZFd.),w?X9Fso6KFDm;1oqp5'dOLs-e&jH3>tbS9]<:S0q2tn8,cbf2P8b6;O?uu#Z6%cigF[>>jgx+2GM.Vdq41-2XP)<.<4Ps<p.2@6)dED*XRaR6@q2=..drS]Zn879'$dA6KYxA6Ssx6c'2^f4C5G7cN&XP&Ar+@5W8u*+VAQb%&7@l2lr:T.*&$&=K0nU&TKdk1lYH?6(pMV]^bV?#/bFd*g%_0Mj[,'(m0cgL.Gau.#GOd&fJGb%tfhA#MOT:)[2p*+7RLB#Dc$##[hUhL.vm3^@A[e</N/(%-Dw^#U4i>7d2DD3I9(+,)nV@,TC9prN_fm058Uv-@=@8%n]d/1KjE.3c9OA#@JBN(v-Iq$['LZ-s^v)47>eA-'qnx%/h9T%),TM'D+f`=2Ev/('`ol'.BXY-R*06&eRYeulEr1(RpUK(.jvR&'cxl'25I211HT#&?DUZ-(3M4f;$97/ger;$J1J60Gm@?5@j0v-ZI/>ckwl(+^%kZmPtmG*:x-W$iHnX-+Ghc1)I;`+Op(VtI;Hn&-NT;.OW(k'v8L6&5NtM0c?96&&$]&,rU1[,9u#<%689p7<04^GAGWV6kYQn/'nq62eWhZK-u<[*#k.dG_SaR6R5u[K(,v]mH70QGjLXV([%3V]*8u[KeZEp7`?a8]H;%72g,/b-Iuj*%I+w9.J]_5DMdQ8].morLkSfq7g:<_@%&tV2IuDMB==7T(AgJM)di=3OSrnq.-PWh#E:=:)%340#eA.?7`ps;A5og5U1#-;1Sq,EG=45Q'w;@j`MwN-.Z$e68QtDs%oYM''I='f%%1$G*2BI&ms$c:&PlV50_6(F*lZkT%(AP##4V>/$b-u.#O'+&#/pm(#V$h]7.]Tf3Qnmc*C]>##3n_k1*%L'#s853)K`#*5uo@e,ej$12rrIU/*ran03^R=/OZ/36JteS%7Bk>7WqRP/=/d;-O#<]$9HZ]4,b,lr;;Uv-Z:Tk$]@[s$in'02i[-jB*/N;7>e3j9Onv5/R*9<(YHZl1Y:5I)C<S0-E(c.)PL^p&w1E:,tol59J]n?$WfofLs>Z:9J38&,HNFn&W0i/)Q>l^,*8Ds+-G]L(huNe)aDnUn3&wc*SPFj1B.dv&S2Dl0v69U/Sxij1faS*+Q#X^OWvcw-9]Lx,G),##W^QC#7t.Z(9S529M[9-mCulV-^>8x2&Zuc2KLZY#VN2^#PX&;/gaBn^>PN5A3eO&#ZTbR-9Hqm:5X;s[Bm/@6$i'o<j3SnLATX/MvD1%k,UBT.OI)20;).jKuBX`3.,g%F7-w5(1.Vo:/Cf&6JH7l1#_]%#7qBd%_5B02j?r,5GQ6Z$U(TK%>5p84t42@6aw>X?gQLV?vLi`5Z74P:%g#12ht#m/+`+87m?JW*t6CB>bim>o?>Uv-9R(O`#vPA#,,6J*vps>-Y>%&44,Zx6o[+*?I&h8/FO7s$h8j[?%xqa4W+]]4l@r?#w)'o%d?_;.ML=5:Jc5g)5,.i$3liG2T./r8_489gs%f<>D5j99i6:%_+V*'mi%Dlc&?)+I2E_^SrSje=C#pZ?L.7C%wJO++_>/A.f7q'%2=9auRm]w#hgkX$=R:X6#%x<.cU$K3ik$u%h-i[,,h/')a@ph?UWwJ<GVmK=AOr*dp=S)6[3)&lDV8tUTp3k<9j#0=;1-lae[:3(Odk+2TjiTJSe+311Ei4fF9Z.q4'0h(h@Q>#ikC[,v9n9.3QTOCU0$,4v.xP':41=6xiS=u'=YYY;%+,)8(&GVv7.-H1XL+*rueh(b,)O'Q9B6&EeOZ.m;d9SU`Bi^M38%#:hWs-L$jGKaI4q]MqNT%SM0@6U;ow#-@@Q/A64/2J<+&,K@xI*Z+/8^M@i;$OY&F*WQ-'(AxUv#8hNN0ssT+*Ut8;]L^IiL]sQL28GVD3*p'.$K<4:.jDu-$Pd<D#4'oZ[WTH#]GIk<]H>RcjV27GjigtA:)A)s@(g]L;2/)cui16V?Y;fP#UcbxX'DXKNi'[Y#tQe%kXv3j9d<ai0*Y76#'+1HM8=)l0I79g1Tx10(*V0>-'Y<H/Q,2_=:'ST&gda>-4RNTBhH<mLETW-*6N6U9kQ]s$,O%],O4&%>5Q1E4P50J3i/Ei%eBuD#CS8T%xkJrmRg07/R>dW.Eq5s8Ebjv@4KY^6-kpV851I0)Tsgn/T0qf%_dI'5aFC+*YDQH2kpZn:c(QU&cb_KMkb8=1(5,wL685_5_LUF*,,>>#wC0S[vf%#YJ^MrZ]J@-Dni'R^fpgq%N&nD*eAdj-Y,x.MOYQ6#tp=]#@Bl/(aBPS^N*&njtp_K(qXMY7thK+*;)2(Z-vUK.-H:>$7:q0,'Xw>M$.p;/.pV`+0bhHMZ/UhM7HUv-FORW$1T%>/5MP>#dXbcM:9xiL#=',.t3(HMh6<?#(>4.)>o5##JB^01C7JC#$_Aj0LNv)4(X*n%t#fF4Rq@.*G7K,3s];g1[06F*.viZuP$]h($,eQModr(ExITb*SUR.UH3CNC>[Yn*$G*7M;&uOS<'I(#tH5+#RuCC$`*V$#fd0'#TJ^a*T^5Q/MmnW$4([S%Umcs-B*].2JJ2s.-d*qe^%Po[R,0@6@d8m&YBPS^5A,##g_OGM0Zrs-^`tr-fN9q.Dspu--Iv2V>-`a'Rlxv>bI6?$@xi$uwn'D0R[9i()ELkDe``.$g#i&NI[9I$J4JZNp2Dc)27C'#tQPF#>l(($/=X3.(+kP=`p4q]0%qF*SM0@6o^'j(i#C^=OJ,X70*&&,(DXI)gr/F*<`Z<-otd_=Sv.5^M9M#$J6eY)Z?*w,MKbj(hxJ^+]Ppw)XcUg**^12'G`_W-irXktngThN]&1'#Cv;A+AD/,r>@')*qj&/1qt*;?j_MJ1bIdR&'/nu[%j0@6P-1kLYR:d4sjtT`=utk;C_/=@GpMV]9UWP&4HXA6%se=--WM8]o.1kL.`J^1aO%LMx':/F:O(E3Sx:0(siXZ7]/SN?fL_O;76vaaHEt'cfM_qC&tx6cB&5/(m/jA64`CkLX=p[5VTc8(>WLS73](C?Xg_k1p-vr-c$4A#3uJfL8`,nCJV:QVe+Fd&Kf2;]eNF2MD6cL<.Q)kCT,/8^<%dY#_piBm)Z>N-3o=M([%3V]k+j5052f5^RaP`#Zffh,52EA4g*(,)LV60)xbnk;O?LPMLkY@5Gdi)F3XxY#3$]$0XvJM)5SLV?LBNa*'OWs-vv71CcCOV/kHuD#,K+P(tg'u$CY@C#rX3]-+eGj'6<gK1pxLZ-]CYI)Nghc)TFJn3Halk058Uv-hS+%$0d5x##K6C#/W8f3@P0f)[&X_(x7sc)upW>-uAx.*VY<%5_k(d*=xC?#jK@X-.CZq7)mX+8d4:W-v7*mJ,AIe2s8Q3'E3[O(mj*B4hJv:Sf2WE*sAWe3,15N'Hf3f2b[hm&o$dFu6@F9%mT<Y-kt@W$NDNE*F2ve(@fLjC^P:nL?d*-*fXC)+YfsE*F7=l'lBe=-jpa#5R@:Nd]i=P]f$+T%N9_LpnoVc*h>mN'*wn],bRq8.+H:;$$>#ciWka>>S7LS.XJ5D<jew5#K)]a$77ugLWEL02d%%12IavT9*WsK;r>mQ&NRaR6(BC/)IRGs.hDq*%7de12fOAs73Dr*%aMeM;VN%:/JVSh(C31w7nvSx,#2CL#Fqv8'ZAD*#3.<;$7r4G-+sY>[5j+E(0HRq[/&1@6G]d`*&Vms-(Jto76^JW7OM=;-)xoGP`5dQ#r.-mqdJmQ#sUx$$6^+98JaSW7xXci9.#9,=m=f5^gJFi2m%PkO<>Y58(^l8/DW4AF9dUa4O2'J370ns&/3&],j)^;.ER@.4B8xiLT4Ji$Jg$&4SU)P(pFTY%*N4I)oi&f)g>Zv$[bR.2j9<q.u6dFDJZ*&T'eHYBU&if)wBR9.D2EuYo6lN1s%JS@g5%1(ZWKJ+jvOA#IV=N1'mZ>>;6JY-*^v%7&VPIuGqf40'M*`AAlWdE25`h1TTYI8u*a$uQZtb$*P8^$^$`s$aC_tuuen8%&k+<-&Svl/_MALtap16&;?N`+&5>##wZiS$U2(/#k]Q(#lgPi7*+jI3fM:O3QW-12k@S.27Ww12xnD52$OrD3#g#++.-/e*Rd3/:.^O;$Gw3]#bd:*3/Z1Z#wU=E*<-,0i<3lO09_1sL^D??$VMi[0m<(g0n@>,4XZR(+F<46+G+>Gi45sF34^?C##T=f*LQIwBReO+3(ikm1UD,B,RMm8/9sAI*q5gteoUvgh8^9D5q:+F36X`UAp5I(#jKKP3mYr@22ARm/UOU.APVq(c^j.jL?)+qecksJ1DpMG)b+WT/wa)*4I6hetp;T@#v_^F*^Ovu#,UT:/FO@lL55>n(IY0i)qH@X-,0fX-DZwF4O/'J3?DXI)A@ufCP-'N0n*dq04X%C+3,%M10vt=7`eFK/QeDc#SoWU@F._ARjI#;ZsxHqLIVdpgkHdo&(i,(+63S]bd3n8D14Ka%Xcds.959qu-4#a$i@XA#i%l<-tr+I#xR/rI#,p[t[widumT&UDH'Ja+5Pfi'H@BnDt5oi$9Q9#GfnLS.Oc-LC_:-O*_Ut_*8iXV%b,>>#K_$ci`4[>>7([rHN_Gb+1aH.2E0:<8M2WA+ehaR6C+g&,(sx6c]*:G4[Zc/(.3)7cx=0%#8TFl9j`tA#Spm_-xe4.)DvQQ#?TP-2>%,@53N'@#nD;O1K[2D+P-`a'>I658P:?&%Q8S_><CtM(s<k_M?d]s$CT(T/)QOZ6Q3#V/EZt;-9K@^$ZEsP2<kXD#/h'u$@=@8%keXcM*Y;O#iEd.+hG.1(%Z#B,bPZ;BPrdq&YoNi(id8&,iTd-3Yk@s$G05#H2X?H,O_l2(TVuY#Z7jC=q^n9._p1gE-+JB-iKO9%7.1j(Ucs'>$,1?C^:qF*bwh%,bXV;$^sjV7$--%0?KY#-Qd?;%^%g^+7qacs_BT],G),##BV,7$P3),#7brw]aK^s$SM0@6O_Gb+V6c/(@v5v7Xma)><e694TvVA+e+b$%Wtdq7(oUE4Y_jY7$5KP8BNw>%7OO9.HSh,)Ce`p7D`g.=1%8C#OJ,G4S$]I*.IV@,&>b)>Gn4[$#KId)UK*W:L6Q)4F`K`$aKZcMAp;fq5g:r.R*s%,Ek&?7^Nwq7=9hB#ODbD+lxx>,3C&?7,F_+*btU`+*qJt-6kar7Jph+t^ET],J;G##-u1c#/5S-#scZ(#q<M,#GQkh(gjiD34V2@6Ds$42iFD>#`RaR66=)500s;Q/D,5/(B<j[-.5G7c,SEM<i/0I=A=Y@5>pV)5cdKt[0A,qe-Qfc>NckG<%@5U2l55U.9GG>#M'DhL/MAQ'v]=T'AiH>#nRu.)R./R/v`_4;lM'2<4-MT]r_[@#V)n2$nw)e$rWD.3KjE.3Yk[s$qK/W-YHKOrdc7d)M]Z,*>O>7*FlX:01:Mt-q?LhL3Rs?#R?XA#B-Ih,-W8f31kaf:vDqDN1fSQ'f%TB+t3?T:6^DO'w<=X./&pS4W6LS0B=i+*_:II4o/;0(H[-o't8C#$RvvX/#[GD#iPo[u)JOI)@.tY+gJB,fT5tE*uEl70=Y`B#8p>_+bB]j@JqcN'fK?%5C77f*`dPn&HO.@#k3o<$VAD8&5xu29uhEA-e%i>7Gq&6&9rKd2$qJ]=5$Oc`UTvx+LK[i9v4X&(^9Z020kk22-;6D5Ds?6#EJ(v#7Xs'kj<``4s#x7;7Cu;3:w5$cdbvU%`n7T%1Q-t8/JX>5H>9F*SkoD90g2;]FYC6(7:Yp'`PG>#]i<8&Y`=((A0O?#(3/&,jsb$'-kFZ72L.m8WEe61hRMG))oBj2%KNe)2-Or$QEFW-I?H?.%u=.)p^#V/g<7f36x3N0v;Tv-OM>c4<E4r78ZED#3WRh(o$Sr84HDT9or3S&RE)$Y#)0'+mRDX-h`q5C8ws/i:Poj(U3gm&G=oQ0gW9]IFD3S&V,Rd)D31R#D45m'^l/'+Do`J>8@Or.SZcj'%a'?@RF6##abBU<u%pG3sxwk;Dio#2*O1k$S?2H3svbXA)9AW&;-.12qFaT/vagH<4Pjo]Co%xI7j+?M]5=m$#&VOMnv`v%LXa9/L/###p6Gw$3hBD3QS.?$H3BIXoBeq7GEKU^):'h;NP$_#:.s=*_?f@#/E9`(aLl3B>,1'#FMw8#a=ZV>+fx_Qf:Lq[?L^T%<V_Kul$_>>$X[V$$3D+rWm2jBa'*20=U(58T*7ciM`un&x`H.20#Sk'eMV,/;04x,Ai3=(7*OmLemH12>L1nL>-ls82tM[$()AL]87(3(.>g/7rYh*%Nfo7:hZcv;H&Y5(i/Te]'(#R0MGPS.XpSM0%qh=%'__02*^nc)AA;U%Q+;52OMG>#JKZW8VE`k1G*j`+R0'q%2[mA%Um/2)>mo0#A0O?#iUbI)<aOw&W[M>#$vr4JRprS]0+aD5Y`fm^Tpm(#O5G>#aY15/hV[]4rT&o8;K@+4KJjD#)((02Fqn8%[5MG)/V7=H&:,H3*U;8.)>=Q/H_=7JN@S.>*`87/.=[T.IM+e)3ghU%Fhr@8'X&5]wnabHvH>4KgV:T7V:>g(0d)o&WRBT&6X$0)]V3JFa2Qd$%9,b>/GbC6VeSa30%&C,,TMn:6>.21$dHu%Peqf<A77.F/1xl#93(w-$BTfNd(AM1$jd:&5cbZQt<98%$3D+r$0uPhkqP.#Z(sr7VDKX[E<:d8/^mu[SO3@6hEMt[BOc$'bPN%8ST89]n-x7(Xe2ZDq.j*%C4egG@DSKIM_d$8hq8&vkM+NLptaV$W<<MFjXOb?+Tej'QKrv%]K$12^_q-M50;vBmoZ$e)F53HR[Z?8U42bRdtopIrG*58UEW;7rpVY?VA]#I`t;h3SM+e)%$5=$Fkr@80PUJCwJ)5D^NKG$6O_f)wtM:8_`X&>v]->J+N2^-k&UmCgcKP<_@'HOoL?>#@B*ci0U(9TGR$m8dbZp.<a/@6C0B@#/I)s#m*fI_PNCFMSY^Y#(?M>YOI>2gEj?D*-E5JchAQQ#<;,##%5G7c_QI/#r5hv$8]h;-wJ_0'qe:&?=^l-$2K^<N$d<2gMj&:)*u9'#:@q(EgVkrQRsG)+54JW-qLAUD7@s1b;B&VQPxZY#ZLH8R'1d29W=18.nx66#6=C%%_3xA,3aH.2DnI%,YxRj$aE#f]n?+X$4.1qep/O?#J51j((EH3)9`U[MMP:I;4`i-*b^5N'ISGx6_T^:/U-n&%(IuD#)li?#$`^F*4Fm_5qUDc+'Tl>-9&%eOZZe29Vp*v6#RP&-7D<X(ZG2508=+<O?.+=(?akM(UtjRKk3dP8cC/,)ZX($)MUIW$^mq02vRb&#a9ofLnh)O'I:mKPY=[s$/n7CmCj8w6=J))3j^=x#LfIE)CsWt&3I,?(+I2,'=c$s$Y)'O'?Cn8%?2H3'ra1_Ac&wk$,Yi6NeRQ5.^@'DNd$C6&dbJp.vI=F33$2`-3JxB.I^(9/U6sck/=J1(0YYn&Igw-)+C3A#c,wlf9)#Q%F?GN'M4u*N3iCm$bZfx$cme%#Z@>E*fm5n&a7ofLNp&G04aFl]YRi;$*8^6E@<:-2tTpl&.r+@5R@Dm'H7kj.[q'E#$v<N.pl&f)tf?m/ve*(3D:e#QK=I`%IP1B,e`]Ac[AwH)hQj8&I1)o(fS.-)_^-WeO6,3'$UU-MF2&I-YS6mN*l#6#:N?XLZ)qG*m50c.-E6C#Gu:p$j-bP&s9Hp/>netLlCZ)OVv76M9nrg(^p4N(m$(-M3&.##S?f1$%m*9#dV5r[]t#12G%k`*HnTW/(<x@)Z_[1(f2=LDhwN^,k(TF4A>GO%)jil*Jge+4p<c3'q?MD+^UBIEqm'U%0ZB?-/M$q;1u;*+xq:K&pY2O'hAV0(+7np.CvR)4BCOx->QFjL<0G$M3ijmL>hc&#xtkP'S;sP^_JHR&jtV&cW&Y%#N[iS(>)B.*n]tu&hW+W-I*6'A^Lio%@o+D#P`J?7<@3%,LN>n&[N.'5#*,K3C]*50XK5n&gR5%52P1Y-NI6,*Sas78OEWb*]PPf*23d]>At%##%5:r$'hR-%Y<r$#e8YX7?#c>-(;oL(2ug58$LkGkq`Z3'X3Ss*9VY8.%j0@6Q(%9.xE(E#u/Ks-=u9p7fsSu(r5_<f5._T7QSp>&aYW)'51MteGS&=[8>H2Tr@.h(w:.x*THTQ&^7gW6NJ;MKR$Wf_vrwx+cn(?)<L#12GU$<&/8G>#D#C<f]W$12'LF87J9iF<VIAJ3.h#Q:aW(UBR]YG4>'*-*j*4t$M5Z1Kh4gR1cTduY+m(8necH-*nQ7<*HiP##+9>[0HhZs&KcG>#fQ&>G>nW/2<cMqMX-tG;9t]G3Co/T%=V4u%iQ=B,2;ti2@d5b5Wwc`uPKM:%&(_b*&lb(7t%EG5TX@>#x#'#lXb.mSIwH`EI7Q%$3+/@u5r@L()O%e*u;+/Gli*I),Q?T.QO)20ikK;ZSn+,)0M3>5-N7JC@:>a'gH95&G^ZD*c8d/.H.7m/951@6QwI:9wbIU.>ZjB@5os/18hCv#[RaR6;upe)J77Q/?+c8(OVHo0p<>=7EF#f]cs$@74.1qe3xnr?2QtB%h4/u.%Mf<9%G<t.0fFgL.X80:lUGX7iQA@#E=x_-)24.)E2Wa*22D6/:amQ#PY?<8eR)s[+c.=fn.Ad)uUKF*2q*u-(HW2%hp].*q%^F*Z%AA4QsGA#J@[s$'%*v#4DhP%H0%.Mqow`*a=)<-bg&P9nWc8/T$8o8=V:a46.)N97FwS[Pfp=u]I@X-Ym_XDfL&W8eS__,T9kp%w9q/)#`g^+*KTF4;*)K(,^:11^b3pj6+V^T:?o0]vJ+wK[s=W3#5-xT#wMuiRKs:LRWGC]sqp<&aiLD+pQo[#ZD&RrwH7S9nvYp%>MG>#vNW6/CKf@#rm?KF)*Z'$l=Z3)sX#C+1_)C$ie-<CII?lY+_<wJj_l,D;v5MP;;,@&?;DQJcD6_Ybt^nB)c]A&I@b7/jX:SCs10p7YDX',-N7JC@HM(sqH4.)vJ?j0Yc1@6IZX/24Ju32*7h#5+>4KG2bH.2iFD>#XRaR669Q,475b2(Ao><-/n_a3p6/P'ansaau=$.])p8$c=w(?#<F@6/oP7$c]2+pLW`uu-_r+@5iTl5($(gPEbo,qe_.l4]t)(-2^K2a-8gg*%m>pxF-vru$k]RG)?g$s?U>oI*qJPj)*YH>#tnJ&6Md3i2YaoA,pNFq.K*/>GIaK1CwB4m^;gT'@iT#k0xpuaa;M@4(S9JC#h@>s?Z3G)4p1fI%:W8f3)<]Y,oHV@,,YE+3SP,G4FO%dD]`l8/::bg;=^l8/BDQ4Cw>Zv$&S058#;BZ5q$>Z,%k>A4+jPG(<#Wo&<][.2@m0t4ewh7'U5%L(-<f&,Ij9%@mNEU.M'S=-W1xTC)Q+)+t@%I85Cj/:+7T3*AFn8%;[QG*VSN**.+kO'h*%],[^u,)_laxHh`Ab*FZP7&Jp=:.LFv#/c9==$Yd:p/^gS5'BZ*%,'XXm9osX]#Ju/Q2b),##l.)k#1vE9#Q)9U[n`Mj$f(o8#lk<87]Xm1Kr&vS/X@00%9l(/Dap/f3Ih,C7'1mZ.7e%,$)8?BG;Q0>0q^Ze<G`L?/2%[Y#DRtRe4Kn]O-l68%)H>0X`sGQ#_510)iH/O^<$U</(uFI)rVG>#8oLv#BdEu&DH0r0>*@B5V9QL2INUG)$_TLp$[^G)$X@SRH<r]O`I5V-3Y$j0w0?+i(Cg+Mw>$##:K&aE[Wsp&u3C*'obl<0YN_k1]kOQ#j+6D%jEPm#A]mu[<g/@6S#s/1IR)v#SiWI)Oov[-trpuGC.$&FHl>s*:_#b#b?8Lt(eOeu#dcx4k#qQ&]D#X4l5J9$QZm;#[#Ax]f2)O'SM0@62Z.K:VtCY7a,m3'Kk<9%/AP>#A3pM'A=Y@5L+Sk'qE'T.Dg<=$a6hh2SMT6&F<l/(`958^QR7W$cM:C&7AYt%G/IL(f(12)4@cY#=t,n/Cg2,)xh5g)Ef1p.PeE]-T^k-$_gB2'C-FH#uY##:-.H=uE*=dud;ev9@eM`j?Ns&dSa.kuRd8&M=>N'1?$bt$oa($##Fbs$d<Ss-Q(1HMb/J8%[fsHZSnIv#>-*W%4e/g1C&0@6=?e8%Ut8;]_Xk,MYBSW$./-X$1HF:.l*M8.8XA@#l0Uqu&&9QZ$.v#W5HO5S.@hn#4+qC<O-]-HL)(V$aj)<#(@m$]1Pd6<e8]Y,*F8k(xv5$c^_fM2-w+F%^**94+BD0($+o8#Sf9B#aT5$c;Ywj'Rcwl'X[vI'ooZK19'dP1f#fF'4s.K%Qjw55B=P,MF$RL2PdB:%W11W-/UU)3_R(f)M7%s$@]WF3MD^+4t*)SK<@)<'ps^:/v?]s$n$&j0w?++F5EkBC$($t9V5gG*ejdD4IF^q)dV:0_#OlP9^wkU%*[6d3aID;$xRneGH[@hWwbr52qtB^7L`Sl'V*Zd3_@blovn*S;A$#W@A8@T.LcSl'PObj1KdU(#%)###-3?AXe:TY,e[ar?adR@-k0A@#KQ6L%LQo2)1lv>#llE.3Zhr=-W.)X'/amQ#@(X=?o</t[4s)p^;3/b4kVsa*$kXW-n@Qe4$V@C#OXe8._k2Q/NafG3qTj;-JAiV%RfWF3TvHF6+/9$?aKcw7v4um1:=r[,lgci;44h&.+EAe6wJTh,Ta1>.<W.6:x6`N(LS[p.M=1I6lOn],d%&w-t[TF*i=G_+utNYHm*2F*f#Su,dx%w-?w1S*m%cjLux''#%4uiBJXrr$jl66#.M(v#YoMV]1GP>#vbgtaq5X?#3xh;$UI%$73Sw/(n7JC#S3PJ(kTqiB$Lf7n4rO#,)U3pucxJi#lOZxOxp2>R9u1-M[]vY#OLAVgi4>5([-q+M(LT@#&-bx#[TGM#NUPF#V'4#)%/5##E=?-d^V@-dPKGY>='Zs[J&0@6rY2^O1PQQ#2;###9w]JfPs#q%xS*2m816g)*X6p-MWl^o3rS_o(<^CId$2$$-B,>>Z$ffL(dQ>#G;NN$:rLv#pS>`/A:7W$vbgta]9h30sYG>#CI[s$w^hv%h*-NBv>>)4xX.9'qaZ'8(4T;I>H(3)VV/x(`(<j0_/Ki#QAP##T_%Z#_NR[$Ef2;]8$P/(DrJo[F[I_SUqIv#A>Ib3bkuM(V$vM($#teh<Ol%OD3':#LE)[%8ltcM9kqu,An_l8E2KW*h-]f1ds,U]MIMH*4.1qe:En?,X3FG2sESw#XjpQ/w8&<&CVG>#vOX&#82)c<W4K02L9d&$K=6k(/),03:0sP%dhe5/stC.3o6$r@0Bp;.xuq*<?(>)4n$Ap._k2Q/ee2?@ukXI)]rq<15*d05nXgfCrtwUKv(+=8+Vg*ZaZ,6F0GWeE(6H(PU-^fAHrMcHcov/Q&MNc+.^v<?B,jt8_`721K9;0<ht6G*+00F?IMDAC/8RcGm3Hi4>-P_Cg1rK2['aYL<nbf>`<w.)9#`8,GolR0G72w6<iF2(Rh`$#$&###RN4T%d9lu5wqUs*Fl@N0;_%21Ut8;]sFSfLPW[p4JZ6/(oCZe]'oY$,d`9D5$ipO1a2,B,rq=gLH[1`$s/M7#_$K+*P+6f*nQ>K1*kas%u`H.22J,#,4NH%fgl+G49WO[9/tU41D:u2(hqpDNi3uaaATQJ(%cK+*@%eX-]*YO:X:@m0NR[NWPd+;.]BF:.VJB]$^x$=-&E7]4#bdM(l'7X-T,s_-4C5V)5G5M;6R4K1VN?R&i[PCEr^]t-Wb(N(/AD5S>Xl'&r%)E450/K6>wSj2;4v(j?IBD*.iRm#%_jY7gY2o&N/manWe4/(9O58.i34.)0.u&#BQNT%9[TK%Qw]Jfi'-f)Te;Z)pb%T%484,2)?mQ&cRaR6Od`Z#=r+@5$tRO(I,m8/GF;8.poXV-wHuD#P50J3L[D;$)i*R8^CTbuYxHKu-d,F<A%7_/qxCq8Hkxf(`r+YPS@-70=$cIL;=(q:S4-%thI_Y#X]>xkrh%jT+>3>5:D-3-@D,##3t$12C'Vu%>Q*qea@Ll]J@`*%`sNU7G(H>#i_f346Pim/x3+879V=q.cBY[$Yv2]HQHm;%D-jO<538x,*;.i1-9Gk-mX9FG[)E.320MT%prUbNpA9M5Nm>07q`]kGZ<2xA<GRA-O6hY$:'O+5&KV?;TsKv-*d%=/YH';.32eZ$Dk[$?NO,oM+9JoRu4kr90HNnjd[1n'GRR8%4tjj2IR]W7Qi9pD8>d$.n=$0Jnc2t7$&###6nTJLs'wr$)OkpFhsb&#'3rJ:U]%p]KIYQs/1taaY]cQ#g97KWu,0@#,?Ds%Txs.)WP/]OO;3lfLu-BZu)tV$7Vm@k+?xu#IWp5#Df2;]9tF/(@'I3)fpQL2Fax9.%,([-0>ek4'L^onp5Hk4RFD?@V#Jo[B9rB8H;cY#DU7h2I=6g).=6;u#68XML?rOfuk#/h#T/DEpY,W-rVH*Pqgs5,LM2U2(4W&6<%FX.WA[HdL=%%Mx]l/.h(Sh(x8`J(/:Im/jt087hYMK.;.]b/hXs'kZHt?##HnW.(&AL(;%D?#%3+7%2D['#b.i>7][@1(S9JC#`>;KEmJPA#j55L##cIs$GkRP/CU)P(XC[x6.%f;%a^f>G't8:'8k[U.o=@8%1u@T%VOmrd5^,R&hhqs-q4fl'Y]pV*+0E1)6g5W.26p[ud()o&F$l^G=/m:.U8e3'c7YU:F9+jC[W<E_/ma22x[EU9We%@#8@[8%g,#?#xgeY6ppo<7U>3t.@H/9fjs@*GSNa&5AT&R;-<wX%FLUAc6c$##(G:;$jMBY$t#x%#4Vkh(_1`8.FrND*vcq20FD@W&>-1,)OV&+G7W,U]hMWE*jWj;-]q;J'&0o*#oEDH*KRx_#Z6a694(N_,iF[]6g6wG*53_H2/J5h<eee72'2T7-aSVEY0Ktm/r[R]GBLkT/pd;_uoam$$Xqm(#DaMW.stl;3cw:M%26[h2Ut8;]m]=jL-Wg2-&O>+^3't6/Nr+@5G5o,&d`Hb%/qww,a@Ll]ZvxAIh2,A#Wg>(-,.GI)K<b?#%8[W.>D,##d(V8gcEE$#P.i>7=oK/1eKDI0ibIs$ikkj1N0iWhIUP8/:vcG*0:9j0w^v)4,^Ol(FctM(&2-W-u@<C&X?8QA9ejUmqm*B,8A[e2M'LTCJs6v$G-Tf+&7l0;l[u$,<69$-=aOU.f$420<,PJ*q5Kd#W?rE4GoM#7WxrU%]f'q04Y`Z-5j*%?B5LaQHr0l]s>Lb*mq[xkiD.b-EE1T%amvD*,pEP8Y%6T+Zf2;]QPe1(2Yav%bAUv-CnV`+Ax($@$a;(_w*+^6^8YY#-m>T.sWAt%n0)m$/$G]#n`H.2WLHP8<>-W-t;q<1<,3,+LE=A#A=Y@5DH587xP-4(S9JC#fLHx64tDl2[iGp8(S9_,rgeX-1h_F*7,ZA#XLAr%$RL,30ln5/?@i?#</FjLq++k470$Fuiq_'-,lW9/BO3,A0h:41*QDEuE*>L)w*Y_7-c[g50sk7D,KrnUvmjh5`eNgG9^SI#SRK0<9XPbuT2On9N*xkI@3u,XDB5mHG?HC6RWdQ#^0RD4jKw9.v4m@ne83p?d)k(=Ep7vEpODY/JASh(cj1N;PlRfLCP8Gr1.=A4`G(C&(4Grdlk4r)]5<r)doSs)Z5Nr)rN=x0fuSs)[5Er)oQbgNne3^MY)e+#pqjRMTf(HMxL5WOp#IqMjVNjRaWGWOp#IqMr'X^MJ$1*#>Qu`M,(MHMI.b^MJrO(.4&N,M5VM=-n/N=-s;).MK0l?-ep.u-=6H,MDE%IMMF0_M05`#v'a(aMHL.IM8eLU##)>>#YTc3Fd.t+jt79GjH8b-?&.UcjvIp(kx3Ts74Pc5/NgG)+loo%lq;tq)YNsq)$]Ts)qxNr)pktw0lVnq)N8###oAq-?<Uk-?]nRe$]e/A=/+e8%INRV-j.,P]rK4.)w`H.2?1-f)X#+^4_84,2q^;127hh;$H#r0(]t8;]TE@4(me<(5Nbtaa14h>-E<lJ(h=9F*eupjLbDb1^vrFfG7&uA)=67W$*Jjr]c_$9Km0D?)?]:v#o&`90M9uJ($mQQ#M?-'vlq)O^K.Rr8%(@['2cfHFtXFI)R-M50w4vs-l#xj:=:>H38t@X-+bOM*gu+G4m_Y)4MD0/&C`f`*8ea`4F'Ol8[:sp/b-Km&W,7t$I.aT/@C:DNl:3A*W`Y$CqX5D+kkws$b51B#bb]uY-[JcRc@sbniQF&#xgc+#qMxp$TK6(#]+%)]:a/@64#t>7JaH.2#9/22H&QG%nESE5YBPS^TI#q&G'5/(+%u0#G`EH/'5B'+(IM7cEsXQ#rvkG%mDOU7W@ml/JQ@IkO>x8'[<K99_.&J;o5S5^I-XP&O/_5/(blQ#v6*u7-u-B5V9QL2163V&P1`RBE;FQ'Fp?d)uX)-c:W]C%RS,lLShL+*Yk[s$3=Y)4%[*G4o=]:/k8C-8dk?.Mv:=m'.d.`Ai/ZJ(,6)Nt>L#(1wG`O'e5D3$Qk,]%1>#C+j[ns$b&G&uD.Lb*T@M$5Q-%]/BZ2KOZ91q1)h$**O0CE#*$=L)p@_P%M3),#,JpP8:$dG*2I?v$cTfs-0vNrLG'.aNCXlGMYqQm859nw'9P<x'6<qw'kZVF7nP>#Gf]tS&B$_/DwXNDWHZ8p&Rs*HM9'MHMXC?uu%-bX$K?:@-_P:@-:;S>-:sDE-p.m<-<.m<-YU^C-u0m<-'J6L-c.m<-^3iH-2*iH-t[wA-+<S>-DR.U.gW6O$3<S>-ER.U.ae.p$e:S>-FR.U.X[iS$m9S>-GR.U.PG:;$);S>-uujv%EJD)+G]%a+VBS]cFS`D+6OHv$ZP,hLdIQ:v5Y###/'uw'e/DKE5.m<-jGr#8%@'_,$,>>#XB.s-[`f--j[Zi9/:7.2iFD>#cRaR6k64e)&gRVClLXd&T>[L(R',)#o+(-2PXUJ,`;mQ#@RkX]-jw$?d9mg)2@2s-[bs:8[ZW/2/r%@'/u>c4'lms$YATM)#7EA-NIwS%q?I=-e#hY$$w00*@Iw8%R#G^,7rqV$qQ8/1`@)v#fc)o&-Duu#6Ip`*/:pPA8*f02F$TlJZ)+,28cKI)9d0R'V<^I]7;81(_3Og%;GAt[&X5$c&%J12L5(F+Hxx^H_AMG)+5Q/)PML/)7YQ/)4ieQ/Uek<89oH>#F@#W.fqOo&Jmo0#nsX@#Y4i>7FAox6G_LbZY_D8([T1FZ#g]+4P2DB#o;5%&bf6<.j/O^%5aI.3a^D.3sn+D#t-J@#XhW4:gQK$7^.gi+<h/98TVb@.l`Ef2&C?L2W4$_+Q35/(?8$@-(`d#-^w73)$^dR&c')A5oit*G#*1u$+A]s9=IRs$eMEm1mVX.3325[5LTOv6xVua.&si8&D+x21^s/*+7_Ua-w6id*>(p*-0cKB+1*t6/-qqC4nbP_+F5>##2x3]#/r.-##Vs)#aYH+8>Hm%-^SQY[Zn*T+4'LW8$R794L)`#$fXs'kCD`D+?]ft[_t4$c/E>2(1LA7:U5G7cr9w<(TLJ=.Hr+@5Kg]>.1pis[cBuaawKxB$i^0-%uSsEQkSH3'5q1i2oqF%p#cHX7+kI>#nmQZ.CIqf)Ue[F%gm/2)Mhh844rs-]$_@j2x#`O'*9..MoeXI)?p:)&Na0S2UQZ)4Y77]6P[NT/'KCW-N/<=(5gE.3@-0W-2*rk+mC`;ZKp?d)1gvx4PrG>#WK'Q&YrdX7Rf7C#p7U&,24NNMpapq%#KX',D`w.2SGA#,(qPQW1c5tnj1R]6h[]n9;Q>O0%c4$%I[<T%ub:@,Z4q/3&g^x,&7Mx,4@ZNL/<]<&ko=xYotPv,H&@h(L1V;$vj==$NZNs%;Gh/=4Rf[ulD^d)GiXI3E&U*+utnW$8P>>#n[Cuu(QqV?>k$29>i+^,Z-bT%Lex*&1d?$$pGpZ-oro71/%c.)UQj-$nPo71apQL2V1h8.+$Ch$n^+;H&l1I3wR;?#3Y7%-dCXI)g,Te$Paf'/tTJG;@Ql3'_?oT(:DYYue]Gb%p&M0(n@^8NTVO@trtxq)bR@[uK6;kBd/#Z-JMGU;km]9(8PUV$+cbCsvn[>>htLS.VV1A=XJ:`a/:7.2]r.9/W>(a4K)]?(h023((cd99BNataB&5/(H36kLGB]/7uYV+9e8o5^(>&<.m4CkLRZ$128LEs/g,5)%6TY&#o'T3K.G)s[1lj2itLQj)Kv+22:Kxh=xFv(5*;ns.06P<-U1ei0CACS@U[jV]iTjjE'%w58^.R<&bB6H3^Pic)-LUa'[a6/tsb9b*b26t-]e8r82+A<AlF]S@=B37M^G_^#c6Mv5+F#^GkDXA/tD9j<^H@C+']]i1m6H6'at<5&HTb8.JA^X@#2)49uLPg1/:=2$fDr2';3<v6j-W-4+Oh1(H=xW.=V2rK?bR9.vmjU.qCsT/v)S3<(-1q8CVr)+ko5p8a=r*%_vX+`7r4jBSwtG2o*2,#:*-f)#L.94a.f$$=o(9.XCUO;=R+Q/cRaR6s?9R1,Q;s[[95'kNb[s-]2(O9r2fp]H9712;sx6cH*Sr%9[x>7RNgJ1R>9F*X11l;;(Uh(6^1H8#[X&#<6S^-N^=g7*^mu[gG1I$p1ljLCFcL<q_#?2*b0bI?xtk;BS?j93RsS]k1R=7`q-N1#V_0M^8ZQ#hh7##TQa[]rfM]$6W:r.JU;8.-S@k*9f*F36=rH'PP230vY$E3N]d8/BP]HF=&Qt$dgxv&BasL)m'o8/(P<p%84cWS?Ve0`?uw+*xk'tS'7.BtAX]vLb`jE*XZf;.9x[W$6nddb``Vs%8NMdC90;F*haf%#r*^*#;]'b$AG.%#Z[P+#GY$0##$[R9qtbq]scUv-SM0@6*RX223.c9Cpt0@'LQ_vKd)07*>xb2(n&NlLX'-Q>>n5'kg^U$KMiH4(U3B.]?w5$cKrt#7oSH.]N6%=(:fSq)oC[sEO%k#A$%6ua=d1%5Lr+@5jCU(@X[j>JA=Y@5QQs#KhOgk0s&sL2QBv5>HO@o1&E`S]?R;9TEUhI=`=;W-9'cBSQV@rLfb8tB%&6v?*&rP/944@6LPYsBZ5R8]w4(tLV&QQ#r^7j%bF`?##.(b*SAnN0>j'O9TR7$7A)vP9+-sS]+B#hFcSwS]8;N>AU1%T.sN9##YmVY$`2fe30tm84;fiu-X,(.;0-*Z6j4q#el[Zx6PtZN9jtg&?s-?i(FA:D5R]h'/HKS&,;d,8/>X$0)?$l.*d.on&ZcG1MhBw-$v-F;.tYRH)JO_C4TvbZ@e;]<&<K_c/[q=/(Y'Sw#l-]n9FT1^#-M`(0I/5##_?+)6S_d##ds0W$*Xb,2xq(QAa&JS:5BOr$)LO,2dIL`$hh_;6;9b>>[hw[b=&'##%0%`$v$u6%Uh1$#bxYV[r4oa-=TxQ%,&w>-%S(s$mY;tE`'1#?s>MN0v9]1$ct39#Y9NEEZjE,W8'/FEgj*#dS^sk<XCH>#sbpC-7bpC-x`iLE;bbA#b,nK1sMYx6jspGdQ`6qR>C,x8eAq6&jcJ*3N*'6&22G>#ADo1$(o*9#eQsEEMOiX0T]$2T;=am/>F9j0gFsX.#ZCX$_FdO,AF=q.H09q%*N*XCL2j]XEn1XCvNkl&&-uh19-BZ-&v%o)vq`U8k+*-E//MB#,rY/$wrimLF`c&#qb>w(X(sT.LG>R&4v(d%g9cZ-nIWIP9#Y#-apVIP+VQ>#/Ix1$_+_-%)t.lBD)^[oAuCE8/uk/ioX./Ub:jf(v4HW-9.`el4.w,E`6)H*U6iB8Oc[a+$L>Z()vvAQtcB'F>@+q&`8VY5&(Vuu;Ko58nT)9/ECI>#[e>A'Jv6r.JE-#Y0^(EP[aL=8YH`^#kYI>Y<+p7Daiw*3]Oa#G8Jw.iB(g8/?'kX$l:[tFB)8_#9hIE)BmNt&>L<mFs=l]>@N(a+?3KK)ZX($)g??oDG]7C#ffdrH)9$Q/A)9U'5e^Lpt)Qk0O?53'1G8MBKjZoeq4:=/MUC6&wt&FF_s;h)S,'b*3+pJ/kSKn8;w0'#@.$c$F7V*MFwl&#Q=)9+1Kt-;,8L+?`?o8%t#ht-AqNDF^pMw$lC9f)E'GfE%NHFF%%jd*rg>C-wvPCFZ9_^#],I>Y+abE5:;EJ8Cv1'#1%7W$4qwc9UFnr[Uoc;-FO(P+9Yci9#G:p&W/H?-H]ma.LHI`$&]Ye8JUsPK.wf#G@&;Dbuw2<-Mh'_%9]V6/oBl^$7'4d9lnP2(tt;W-KWNo;%WZr/SCsl&sgI;In#W+d_dQL2q?jU+DjR]8_9Hl.@hVc':F,$%[YS]8l&GT%W,rK(#)>>#X[iS$f.hw/qXI%#9R@%#Z$`5/7Gta$pZg58ARSfrvHKW.Z7]1$LMO]/mueLpJBfK:ZIY.uaCH>#`cpC-aKO]/cN0e+-PMwGKD:B#xM4M$kO`o2,%32=&8<J%c6468P[1Al&HGDXbQB?-K$&C'VE+L:c%uxuFU:)Hrt49#'S:)H7W@;#&8P>#9Ix1$=.e18`6dDlqd'^#FeGS7f1kA+U1q7Rsx&9'*bBZ7MnGn0qFaT/[M0@6J>Ap]'_ucHHJi.2LMPKGr*$[A#%`o:.tx6c4]Yca08Xm^2;xh(eOHP/U[(V]GsGl(4.1qe&b4,<'ucxO&'.*IuOun:_+9W.*A9b*0?Qg1ELGI)(#:Q(??G>#MBrqL3QH##LN_%.Qo[f2hV[]4JjE.3(fK+*ig'u$h;,+%@<aw$?]d8/(ISs$L1]A4YSYS.>U^:/IM>8.</^F*4gY,*.mb_/vZv)4QYGc4L_uS/_OlDNFB#J*sn@g)cjWL#F'r-Mtx*f2X,qG*l5/]%Be,;dNVKq%5@h97Wa10(XJc31p>v6&8m/Q(QHGN';;e,F1%kT%C#Z^=_u@oLiA_m&#uk.)I=SCui.,+.grBt%=*qn0,eIj<NR'L5wnEW-1leA@#--3'R#Dk'0PaWB4#Ek'J'9q%7U2%,@<>=$d2TtCYxWk'T/%L(>&SU;k_WNM_rugLpF)[%I4xT/:[OmJZh)v#/f_;$&l-G>/#a;$+GY>#13GB&clh;$P*/%u^Yj-HfS7[Z2-<O;GLAj<U006&YnD2MD1CE#:9D:%1'E[9xH:g(7WY&J[nkt$.M(v#p16s$Vl&F*Z3n0#v(+GM3?_Lp.Z^b%k$EVn21C#$=5$ENmWt&#qd0'#upB'##'U'#'3h'#+?$(#/K6(#3WH(#7dZ(#;pm(#?&*)#C2<)#G>N)#eJf5#o*]-#LL7%#PXI%#Te[%#Xqn%#R@%%#ZNc##Nd`4#v5i$#Ygh7#3*V$#MnF6#8d46#B=G##>GX&#q&/5#7PC7#I<r$#;Ux5#7h1$#nCW)#mYu##,5n0#HtC$#2AP##LGY##`#M$#Q;F&#9cjL#@mq7#9]%-#w,d3#UF^2#=Ul##)La)#9TK:#9#'2#?;':#6OB:#2hg:#8np:#4mj1#5SE1#545##X^V4#hji4#d?O&#MRp2#Z@T2#Wk>3#RWs)#p]&*#vn@-#Z9v3#O6I8#C+78#5%S-#S1f-#c1@8#jIe8#lOn8#F<x-#stN9#OE]5#a#X9#%+b9#tMm;#Uk8*#YuJ*#^+^*#b7p*#fC,+#jO>+#n[P+#rhc+#vtu+#$+2,#(7D,#,CV,#0Oi,#s'a<#`5s<#_;&=#fG8=#u+$<-;.:;-+gx>-svsj0:aJQCjE]E$kwViF8rNh#tre+MrqJfL_>DG)H*m<-?VjfL.WCbaQu.I`8M5-NLVRL'#A7GV?crxL`W^l#ew^R'n_3T%P#O`#^9=G2jLfj0/Gc>#55R>#JR-P2ZIaEOoM[+W3O&&#gF3/1*tI-#[mk.#J0f-#>?pV-:=3L#xqDAPZ2N@$;=OOQBd+nPQN4uX[*@g-<U&=(j-Ph#m#5L#7Q[w#84eIjOStR6)vrxLqp'I2,.Ei-7>0hPS`^O(l:Vv#A[h,)W[dFH$QxUCfJfI2WGRb3OfrZ>c:ah=9,i:1_m?uB;HeL2htIu-HuPHN:gp?-[4H1Fs2+nDepr`=:IBDI'U%F-cPtjE#0AUCmIjS8u9RG*%s*M2FjEM2$v>v?+s_$';v]b4LVlC5rKsP2+Z`MLN9vn%gEP##5Q+2#aK=i#?97]bnTvK=d=R(Z7M3k*FprFc)O$n:#_ETinA8DLrRs-'?K`deje49]/in(RfPKKXq'pY$Gm-%#qYj6hhdD)a:aL<_#Gj_,sHC,'2p>Sau#L-=^.rDCYJ_HK?Sefla6<4i7*^I`2arVLS^f'rOMXYW?3I/876W2:-nB]#(/>>#)`d<-H.ad%uC9h[/Y>7WDN$_I6o`[Hx[9G/x^RQ2%[Ah3=4Go:bk[guJo(WhbV;`Copt22M.Q?J.0)t)h(68JO*NpP4ii857PPmH=+[.cc<>J*miFPcFQ*p-5BBLRbgDY@k,Z25Zf.<>eKo)hGaiT$xhdfLeNns[T6$+fgCE@6j,Ph#JSUA4vM3.)ihCWO6l8x`IvTNPafhud?'klO[;&W$tS1tUlSCC,kXd;-J1SV%6INcH$[?,<9=/jFDUNa>Bq668-Z[21:h1L51I3:.6FqiDjZr`=,&D.G-U7F-p0k(Iv'%F-t*oFH@Q*.3>L7p0-.^J;9a@Q:gvB`?a/QW8R+#;91)3p/v>Yc4Mn$F'`9RG*&#4M2AB[L2cpo0#.nB['9g3.3r_f['^3=F84$BjK6Bv1qb;+O1K>Lr[9;Ec&Pe.w>JZDnH.5rR0Uo44&;c83osrom&E7]u?4`2Asgc'qa94uJKjt)5ECGko)7Ar1sY8H>A>j@f1qNPSLfk?`RMHD5244iX$-f(hRp^on:Y77#.?8Q^K)C>4Nc]dWSul#S4,BFK1+nToTAp?U%bNP##)_i0#;c(tM#db/oF30Wh=[&,JcjE4SIE]AY8&J:P$4[huh$euPEis&eQkPTrfSSk^P7LTED@Qac&q6=4S.GDkM+2)NUY1'&$bRR8pM#f;+dTxTLwGcupvQ,e0l.S$-eE6Ki;Yhn8`'3YKSQ?8WA_,.D>C)Okg>_%a&7WtPLYoelb*G4Mf:c`Bw^h8uB-i9Tg*+eRs5)/tO<?855f>Z&`st.Sfc;-Bd:F,=1@W-3mY#[o1Vk3Y;$P9C,tJ2Zl.QLsS^M#WoIJLa*9OLZopWLt&#<pND&JQ7ds-^.*EkjJ_GEQL)UJf.Pl]9iEFYR'Zi874?XeIb_%=u)R.7_hXCnp*hW]1n`4wFTS;'=c=lI<kX7M<pWi98f)1TPF^;i^D@/MSn[uM:aTitgoHVY>3Ik&2rgR-LM]==isW-;PK7ZW`D77ND':&Ku4L(v#]I`<-FxMd%q:?gt*-%uDA)s/GG.@^,3GJ@[B-7PH[Y(nqn[]DZXW8Y%_B0Pk9Z(dn0=J'm[/Yw%-F[tOqN#,e:]lp.ajOA<1B;Cg#GN95_dxrev=[P1:fG)UMlQp9FrAu9qgo[2%IABf54SSK(kD^0:OwBtwre>kT2px73@m31]dHb%?]q]4;+%Z#8q=/(Y(Zqr`pt-i&wrFiE8xb30c--kpBEM2W3)-k]dHL2[*Go9WJ*jL,fvTBt.SR9$unMrY@D^6cOFs10g^oD+^,LF<rY1FE(Q-G9i7FHXUt82'k1B-X]#hFTX0@-r8WD=IQw31<3$<86l]u8gIUB5P5tM2dS1e4nd)7D$HkjEFgLB-Ro(*H`/[@-'a`kD/>$E%9u8H2[5'oDrfpoDB^*vHmVMH2m?Ps/>j>>>@2AI2ITYH2JViv>uSXnD2YiiFXv%I2Bj8c$cduRC(DvLF]uOJ2KI`t-.as'Oh[WmLu-5fGOp>.-Y;p/-$8SV%,OtlBskK/P#x&;TtL62*A<#c<>er*qJkII_2<XnFa4V9&.)g#gl8PUkharNHY=&$N7*4cs(5wa&Nh<6tf_.Z@8'7e7s<:j*QUBxGL7`Rp3k%Z$c[88>SikH&h2TUda*a'pcCkle%51C7r6$^G<^c^i<IUapcHFRIgL(v#icw]FF=`DEpgpdm)h==$0g>G2:_330=cCv#PTCX2up2@'9#SJL@BK3Oq2vASqxqDuPOl<57dNlqaLh$CfJ]E-)7WN((7N'ST>G>#oodI2PfiH2*DjF&f4vY#0XAG2Ndk;.hZtG2DAtv$p>1I$'ex>-c@*#.OF3jL%a@JV]>CKDE7]+HSx):8aJxV8@-]wL8G<tLB@4PD.l%mB.DqoDc$Q<B1xsfDK=JN)<DK*H?G0H-rN.UCxm@uB6-B5B*usfDKdeYH#A;B5IT:GH,&VEH14gvGv^RUC:^I>HS.G>HKR8R(ZPgS8ELGhDrZvc<$dUEHv'%F-+@*UD4]pKFcdbjLX5T9&:%wqeKVaJ2QdavHgZM=B,G1[B7&Zr;JpKT.Sgqf5#0%T-e'50.0+,rL3eF?-PiK<0D1mHG;%=GHwfWv[XkNA-<QSgLRCVN:-j4K1,<8+4H2hS81o<GHaAjVC@xwf;@7fFH'qwF-kLeBIIeov76gnL2?P3?>bY?_/OW=gG4hUqLR^Z<0Rf>G4GCo/1'vnHFJ<Y>-^meF-xj-W%5&WD=)>2eG<QCq1ttPH=Pc^0<nB-H=Yb.+>%a*D-GS8Y8GYBk;dS1s7x9n?I@PER:Slx:9#7m,MmrWR:i$GA-%kUB-16VB-Ec*C&fIwOM(w-U9Eoc)>oi@['OT/J=PC6P;E%wF>8WdW8;J1M<;WD69qWQH=PYJq9akv*4*aRC-JW?W8IZ299,fax7O58:9TKtZ^v_'N:LcRoLtZ0s7eIqK<mvB`?4LvtMT3I./*Odh<H'F_]80si<b-Af=u'6h/]S]0<Lrfu85C@r)2u6w^,=QH=,9XNtNjp5/+VeP9=D.4MJnsmLN;Gt7'.-H=Y@;E>#NwC-l<<i<7MG61m%&u80=(O;-&PL<_@'99pcQw7mvUB-@NHT8Yuo:9_/mT`s74N;(vmX.X::S:u86u7.ua>-NRI'2qkxv7>ZV99n_p`=:tQgLfVgS89DL_8542*>MeVe=S1HQ80jXVCDZOG-r%FdO79MnD8A2eG&LPDF2vkVC$*FnD.P9Y8H2Gt7=>_oD*)YVC)7'_I2e`$H5-xF-2MnbH/=ISD59%rLj*VG-o@%mB32hoDxXcW/$YD5B'onfGhlCp..Sv1F[si34Z1f34?T1qL4`oE-Z=:XLX(Ym121Z4LY]A`*>S:68jjXfEBDRr15&7R2cHG>>wBF,21Rln0`rOb/C$>[99B%126;DEH#+lsf+w$kEGFto2>%ZlEsA[dFt`1>$c6w>#SHWh#1%'U%erpWL>?I-T7u;*us;uDgjN9Sejd1FsdrA*;w7f,5<<[f9iNp=8XYd:#CGwj3jlvFcsL6^`qe3LWYSS5U>3H1=7L4(V`X@lNHBQ;Y2u?Nq[<E%q-3ZQN9`u#U-+W/[1B%+,s.F,,A8X3^9sx@=g+4-pT/sLSWXX<s_r@GJ29l-$u6l-$j9G>#4*csfP@Qi(+GiT.rF)Y2IAQT%-btc2u8,t-`Sbr7]m%T&OdCi'sF$)OrD)d2ke6X-5NT#W,qLSV&]Nq,nAbX2qG1a5x(bM29CU0L/nl+#R0f-#J$S-#EamnV/wWs7TEg;IX&a*FPYe,2<rY1F[Q]/G#$/>B@Z0H-Ow'U%_lT<LBe1^1*f*@tq4,>Kc=_b;Y>DgpCe*BMGpND9-<HInx0b&frf[WiRYR%/[4r1^.XT&DN0W13;E`M$5vVqPDD_CHx-k,X1_reKH]KBicc_-@5Yd67e*:1DpR53dmZU/oiE143fU:e)@7faB-la`HSa7f.h6sCgqcqq&ocLlfN=5Se@VHT.3&5L#Fs*7/6:G>#2vnW<jSP:'U'_5'<+ie*`c]#$I;@%')FFG2[v:*3r6$o'eP9D5JD,(5H#ke3);]>8cW7F4w+hti)X_;(Oo6<C)xDs7:[AjKl80.M$_B%)qd$NmFc[oJklk)CR#d:<AOjFGqx@$n4:XvDB)1HJRR0P9om?oE[>KInu[hhK*93&pX9^7Lwt_chtDo#e2j;P[U1V7M,F%Io2=jT40Z`f,B=GIlOrcB`+TR[pF0skGN`Sr3.+t'Xn2_-<TNv:r2.Yqn:4u%jps&##"
		imfonts.fontmoney = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(result_compressed_data_base85, 24, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 

		-- Чтобы остался дефолтный шрифт для прочих элементов:
	        imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\times.ttf', 14.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	        imgui.RebuildFonts()
	 
end
apply_custom_styles()

function imgui.OnDrawFrame()
	-- ############################ Pie Menu
		if piearr.pie_mode.v then
			imgui.OpenPopup('PieMenu')
			if pie.BeginPiePopup('PieMenu', piearr.pie_keyid) then
					for k, v in ipairs(piearr.pie_elements) do
							if v.next == nil then if pie.PieMenuItem(u8(v.name)) then v.action() end
							elseif type(v.next) == 'table' then drawPieSub(v) end
					end
					pie.EndPiePopup()
			end
		end

		if piearr.weap.pie_mode.v then
			imgui.OpenPopup('PieMenu2')
			if pie.BeginPiePopup('PieMenu2', piearr.weap.pie_keyid) then
					for k, v in ipairs(piearr.weap.pie_elements) do
							if v.next == nil then if pie.PieMenuItem(v.name) then v.action() end
							elseif type(v.next) == 'table' then drawPieSub(v) end
					end
					pie.EndPiePopup()
			end
		end
			
			-- if piearr.reportpie.pie_mode.v then
					-- imgui.OpenPopup('PieMenu')
					-- if pie.BeginPiePopup('PieMenu', piearr.reportpie.pie_keyid) then
							-- for k, v in ipairs(piearr.reportpie.pie_elements[piearr.reportpie.mode]) do
									-- if v.next == nil then if pie.PieMenuItem(u8(v.name)) then v.action() end
									-- elseif type(v.next) == 'table' then drawPieSub(v) end
							-- end
							-- pie.EndPiePopup()
					-- end
			-- end

		if show.show_mem1.v then
			imgui.SwitchContext()
			colors[clr.WindowBg] = ImVec4(0.06, 0.06, 0.06, 0.94)
			imgui.PushFont(imfonts.memfont)
			local sw, sh = getScreenResolution()
			imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(650, 540), imgui.Cond.Always)
			imgui.Begin(u8("Состав онлайн"), show.show_mem1, 2 + 32)
				imgui.Columns(5, 1, true)
				imgui.TextColoredRGB("{FFFAFA}#")
				for k, v in ipairs(mem1[1]) do imgui.TextColoredRGB("{FFFAFA}" .. v .. "") end
				imgui.NextColumn()
				imgui.TextColoredRGB("{FFFAFA}ID")
				for k, v in ipairs(mem1[2]) do imgui.TextColoredRGB("{FFFAFA}" .. v .. "") end
				imgui.NextColumn()
				imgui.TextColoredRGB("{FFFAFA}Ник")
				for k, v in ipairs(mem1[3]) do imgui.TextColoredRGB("{FFFAFA}" .. v .. "") if imgui.IsItemClicked() then show.show_mem1.v = false sampSetChatInputEnabled(true) sampSetChatInputText("/t " .. mem1[2][k] .. " ") end end
				imgui.NextColumn()
				imgui.TextColoredRGB("{FFFAFA}Ранг")
				for k, v in ipairs(mem1[4]) do imgui.TextColoredRGB("{FFFAFA}" .. v .. "") end
				imgui.NextColumn()
				imgui.TextColoredRGB("{FFFAFA}АФК")
				for k, v in ipairs(mem1[5]) do imgui.TextColoredRGB("{FFFAFA}" .. v .. "") end
				imgui.SetColumnWidth(0, 40)
				imgui.SetColumnWidth(1, 40)
				imgui.SetColumnWidth(2, 200)
				imgui.SetColumnWidth(3, 150)
				imgui.LockPlayer = true
				imgui.ShowCursor = true
			imgui.End()
			imgui.PopFont()
		end

		if show.show_otm.v then
				imgui.SwitchContext()
				colors[clr.WindowBg] = ImVec4(0.06, 0.06, 0.06, 0.94)
				imgui.PushFont(imfonts.memfont)
				local sw, sh = getScreenResolution()
				imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
				imgui.SetNextWindowSize(imgui.ImVec2(600, 580), imgui.Cond.Always)
				imgui.Begin(u8("Отметки бойцов"), show.show_otm, 2 + 32)
	
				imgui.PushFont(imfonts.onlinebig) imgui.TextColoredRGB('{FFFF00}Отыграно за эту сессию: ' .. get_clock(ses.full) .. '') imgui.PopFont()
				imgui.PushFont(imfonts.onlinesmal) imgui.CenterTextColoredRGB('{fffafa}Из них чистый онлайн: ' .. get_clock(ses.online) .. ' / AFK: ' ..  get_clock(ses.afk) .. '') imgui.PopFont()
				imgui.PushFont(imfonts.onlinebig) imgui.TextColoredRGB('{0087FF}Всего отыграно на этой неделе: ' .. get_clock(online_ini.week_info.full) .. '') imgui.PopFont()
				imgui.PushFont(imfonts.onlinesmal) imgui.CenterTextColoredRGB('{fffafa}Из них чистый онлайн: ' .. get_clock(online_ini.week_info.online) .. ' / AFK: ' ..  get_clock(online_ini.week_info.afk) .. '') imgui.PopFont()
				imgui.NewLine()
				local ct = tonumber(os.date('%w', os.time()))
				imgui.TextColoredRGB("Онлайн по дням недели:")
				for day = 1, 6 do -- ПН -> СБ
					local ctag = day == ct and "{008000}" or ""
					imgui.TextColoredRGB("" .. ctag .. "" .. tWeekdays[day] .. ""); imgui.SameLine(250)
					imgui.TextColoredRGB("" .. ctag .. "" .. get_clock(online_ini.online[day]) .. "")
				end 
				--> ВС
				imgui.TextColoredRGB("" .. (ct == 0 and "{008000}" or "") .. "" .. tWeekdays[0] .. ""); imgui.SameLine(250)
				imgui.TextColoredRGB("" .. (ct == 0 and "{008000}" or "") .. "" .. get_clock(online_ini.online[0]) .. "")
	
				imgui.NewLine()
				local arr = {{}, {}}
				for k, vv in ipairs (show.otm_arr) do
					table.insert(arr[1], vv.name)
					table.insert(arr[2], vv.v)
				end
	
				imgui.Columns(2, 1, true)
				imgui.TextColoredRGB("{FFFAFA}Имя")
				local f, s = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):match("(.*)%_(.*)")
				local ss = "" .. f .. " " .. s .. ""
				for k, v in ipairs(arr[1]) do imgui.TextColoredRGB("{" .. (ss == v and "008000" or "fffafa") .. "}" .. v .. "") end
	
				imgui.NextColumn()
				imgui.TextColoredRGB("{FFFAFA}Отметки")
				for k, v in ipairs(arr[2]) do imgui.TextColoredRGB("{FFFAFA}" .. v .. "") end
	
				imgui.SetColumnWidth(0, 200)
				imgui.SetColumnWidth(1, 80)
				imgui.End()
				imgui.PopFont()
				imgui.LockPlayer = true
				imgui.ShowCursor = true
		end

		if show.show_lek.v then
			imgui.SwitchContext()
			colors[clr.WindowBg] = ImVec4(0.06, 0.06, 0.06, 0.94)
			imgui.PushFont(imfonts.memfont)
			local sw, sh = getScreenResolution()
			imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(750, 540), imgui.Cond.Always)
			imgui.Begin(u8("Отметки о прохождении лекции стажерами"), show.show_lek, 2 + 32)
			local arr = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
			for k, v in pairs(show.lek_arr) do
				table.insert(arr[1], k) 
				table.insert(arr[2], v[1]) 
				table.insert(arr[3], v[2]) 
				table.insert(arr[4], v[3]) 
				table.insert(arr[5], v[4]) 
				table.insert(arr[6], v[5]) 
				table.insert(arr[7], v[6])
				table.insert(arr[8], v[7])
				table.insert(arr[9], v[8])
			end

			imgui.Columns(9, 1, true)
			imgui.TextColoredRGB("{FFFAFA}Имя")
			for k, v in ipairs(arr[1]) do
				local a, b = v:match("(.*) (.*)")
				local id = sampGetPlayerIdByNickname("" .. a .. "_" .. b .. "")
				imgui.TextColoredRGB("{FFFAFA}" .. v .. "" .. (id and " [" .. id .. "]" or "") .. "") 
			end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}ПМП")
			for k, v in ipairs(arr[2]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}РБ")
			for k, v in ipairs(arr[3]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}НП")
			for k, v in ipairs(arr[4]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}ТП")
			for k, v in ipairs(arr[5]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}УТС")
			for k, v in ipairs(arr[6]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}НО")
			for k, v in ipairs(arr[7]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}КТ-1")
			for k, v in ipairs(arr[8]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}КТ-2")
			for k, v in ipairs(arr[9]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end
			
			imgui.SetColumnWidth(0, 200)
			imgui.SetColumnWidth(1, 68)
			imgui.SetColumnWidth(2, 68)
			imgui.SetColumnWidth(3, 68)
			imgui.SetColumnWidth(4, 68)
			imgui.SetColumnWidth(5, 68)
			imgui.SetColumnWidth(6, 68)
			imgui.SetColumnWidth(7, 68)
			imgui.SetColumnWidth(8, 68)

			imgui.End()
			imgui.PopFont()
			imgui.LockPlayer = true
			imgui.ShowCursor = true
		end

		if guis.mainw.v then -- основное окно
			imgui.SwitchContext()
			colors[clr.WindowBg] = ImVec4(0.06, 0.06, 0.06, 0.94)
			imgui.PushFont(imfonts.mainfont)
			imgui.LockPlayer = true
			sampSetChatDisplayMode(0)
			local sw, sh = getScreenResolution()
			imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(1200, 730), imgui.Cond.Always)
			imgui.Begin("Binder for CO by Belka version " .. tostring(V) .. "", guis.mainw, 4 + 2 + 32)
			imgui.Text(u8("Все необходимые и полезные бинды cобранны в одном месте. Если есть вопросы нажмите на кнопку \"Помощь\", чтобы сохранить конфигурацию нажмите на кнопку \"Сохранить\". Приятной игры!"))
			local ww = imgui.GetWindowWidth()
			local wh = imgui.GetWindowHeight()
			imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 320))
					if imgui.Button(u8("Сохранить"), imgui.ImVec2(120.0, 20.0)) then guis.mainw.v = false imgui.ShowCursor = false imgui.LockPlayer = false sampSetChatDisplayMode(3) sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Происходит сохранение...", 0xFFFF0000) needtosave = true needtosyns = true end
			imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 290))
					if imgui.Button(u8("Сброс параметров"), imgui.ImVec2(120.0, 20.0)) then imgui.ShowCursor, imgui.LockPlayer = false, false sampSetChatDisplayMode(3) sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Происходит сброс настроек...", 0xFFFF0000) needtoreset = true guis.mainw.v = false end
			imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 260))
					if imgui.Button(u8("Патчноут / помощь"), imgui.ImVec2(120.0, 20.0)) then guis.updatestatus.status.v = true end
			imgui.SetCursorPos(imgui.ImVec2(ww/2 - 510, wh/2 - 320))
					if imgui.Button(u8("Основные бинды"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v = true, false, false, false, false, false, false, false, false, false, false, false, false, false	end
			imgui.SetCursorPos(imgui.ImVec2(ww/2 - 380, wh/2 - 320))
					if imgui.Button(u8("Пользовательский биндер"), imgui.ImVec2(160.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v  = false, true, false, false, false, false, false, false, false, false, false, false, false, false	end
			imgui.SetCursorPos(imgui.ImVec2(ww/2 - 210, wh/2 - 320))
					if imgui.Button(u8("Биндерботство"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v  = false, false, true, false, false, false, false, false, false, false, false, false, false, false	end
			imgui.SetCursorPos(imgui.ImVec2(ww/2 - 80, wh/2 - 320))
					if imgui.Button(u8("Команды"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v  = false, false, false, true, false, false, false, false, false, false, false, false, false, false	end
			imgui.SetCursorPos(imgui.ImVec2(ww/2 + 50, wh/2 - 320))
					if imgui.Button(u8("Overlay"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v  = false, false, false, false, true, false, false, false, false, false, false, false, false, false	end
			imgui.SetCursorPos(imgui.ImVec2(ww/2 + 180, wh/2 - 320))
					if imgui.Button(u8("Пропуск диалогов"), imgui.ImVec2(160.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v  = false, false, false, false, false, false, false, false, false, false, false, false, true, false	end
			imgui.SetCursorPos(imgui.ImVec2(ww/2 + 350, wh/2 - 320))
					if imgui.Button(u8("Настройки"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v = false, false, false, false, false, true, false, false, false, false, false, false, false, false end

				if maintabs.tab_skipd.status.v then
					if imgui.ToggleButton("tab_skipd1", togglebools.tab_skipd[1]) then config_ini.bools[45] = togglebools.tab_skipd[1].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Пропускать диалог в казарме"))
					if imgui.ToggleButton("tab_skipd2", togglebools.tab_skipd[2]) then config_ini.bools[46] = togglebools.tab_skipd[2].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Телепортировать по завершению взятия БК из комнаты"))
					if imgui.ToggleButton("tab_skipd3", togglebools.tab_skipd[3]) then config_ini.bools[47] = togglebools.tab_skipd[3].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Пропускать диалог согласия на начало/завершение рабочего дня"))
					if imgui.ToggleButton("tab_skipd4", togglebools.tab_skipd[4]) then config_ini.bools[48] = togglebools.tab_skipd[4].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Автоматически выбирать нужный пункт в /carm (мониторинг отдельной командой /mon)"))
					if imgui.ToggleButton("tab_skipd5", togglebools.tab_skipd[5]) then config_ini.bools[49] = togglebools.tab_skipd[5].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Соглашаться на приобритение защиты автоматически (не дороже ")) imgui.SameLine() imgui.PushItemWidth(90) imgui.InputText(u8'##dial1', guibuffers.dial.med) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8(" вирт.)"))
					if imgui.ToggleButton("tab_skipd6", togglebools.tab_skipd[6]) then config_ini.bools[50] = togglebools.tab_skipd[6].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Автоматически приобретать полный комплект рем. комплектов и защит (не дороже ")) imgui.SameLine() imgui.PushItemWidth(90) imgui.InputText(u8'##dial2', guibuffers.dial.rem) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8(" вирт.)"))
					if imgui.ToggleButton("tab_skipd7", togglebools.tab_skipd[7]) then config_ini.bools[51] = togglebools.tab_skipd[7].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Автоматически принимать предложения механиков (не дороже ")) imgui.SameLine() imgui.PushItemWidth(90) imgui.InputText(u8'##dial3', guibuffers.dial.meh) imgui.SameLine() imgui.PopItemWidth() imgui.Text(u8(" вирт.)"))				
					if imgui.ToggleButton("tab_skipd8", togglebools.tab_skipd[8]) then config_ini.bools[53] = togglebools.tab_skipd[8].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Автоматически покупать канистру и заправляться на АЗС (не дороже ")) imgui.SameLine() imgui.PushItemWidth(90) imgui.InputText(u8'##dial4', guibuffers.dial.azs) imgui.SameLine() imgui.PopItemWidth() imgui.Text(u8(" вирт.)"))				
					if imgui.ToggleButton("tab_skipd9", togglebools.tab_skipd[9]) then config_ini.bools[61] = togglebools.tab_skipd[9].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Упростить взаимодействие с инвентарем и багажником"))			
				end

				if maintabs.tab_main_binds.status then
						if maintabs.tab_main_binds.first then
								imgui.NewLine()
								imgui.Hotkey("Name", 1, 100) imgui.SameLine() imgui.Text(u8("Написать с тегом в рацию"))
								imgui.SameLine(600)
								imgui.Hotkey("Name19", 19, 100) imgui.SameLine() imgui.Text(u8("Поиск игрока в members")) imgui.NewLine()

								imgui.Hotkey("Name2", 2, 100) imgui.SameLine() imgui.Text(u8("Внимание угон грузовика"))
								imgui.SameLine(600)
								imgui.Hotkey("Name20", 20, 100) imgui.SameLine() imgui.Text(u8("Здравия желаю товарищ")) imgui.NewLine()

								imgui.Hotkey("Name3", 3, 100) imgui.SameLine() imgui.Text(u8("Меню докладов"))
								imgui.SameLine(600)
								imgui.Hotkey("Name21", 21, 100) imgui.SameLine() imgui.Text(u8("Написать свой квадрат в рацию\n/r || С.О.П.Т. || SOS Д-14")) imgui.NewLine()

								imgui.Hotkey("Name4", 4, 100) imgui.SameLine() imgui.Text(u8("Контекстная клавиша\n(удерживайте чтобы отменить задачу - только одиночная клавиша)"))
								imgui.SameLine(600)
								imgui.Hotkey("Name22", 22, 100) imgui.SameLine() imgui.Text(u8("Быстрое снятие/надевание клиста")) imgui.NewLine()

								imgui.Hotkey("Name5", 5, 100) imgui.SameLine() imgui.Text(u8("Поприветствовать и попросить паспорт"))
								imgui.SameLine(600)
								imgui.Hotkey("Name24", 23, 100) imgui.SameLine() imgui.Text(u8("Меню поставок")) imgui.NewLine()

								imgui.Hotkey("Name6", 6, 100) imgui.SameLine() imgui.Text(u8("Крикнуть \"Немедленно отдатилесь от грузовика\""))
								imgui.SameLine(600)
								imgui.Hotkey("Name27", 25, 100) imgui.SameLine() imgui.Text(u8("Проверка игрока на ЧС ЛВА")) imgui.SameLine() if imgui.ToggleButton("CHs1", togglebools.tab_main_binds.clistparams[1]) then config_ini.bools[2] = togglebools.tab_main_binds.clistparams[1].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Отыгрывать проверку")) imgui.NewLine()

								imgui.Hotkey("Name7", 7, 100) imgui.SameLine() imgui.Text(u8("Крикнуть \"Немедленно остановитесь\""))
								imgui.SameLine(600)
								imgui.Hotkey("Name28", 26, 100) imgui.SameLine() imgui.Text(u8("Здравия желаю")) imgui.SameLine() if imgui.ToggleButton("Zdrj", togglebools.tab_main_binds.clistparams[2]) then config_ini.bools[3] = togglebools.tab_main_binds.clistparams[2].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Выполнять воинское приветствие")) imgui.NewLine()

								imgui.Hotkey("Name8", 8, 100) imgui.SameLine() imgui.Text(u8("Крикнуть \"Немедленно покиньте территорию\" (зажать - начать отсчёт)."))
								imgui.SameLine(600)
								imgui.Hotkey("Name13", 13, 100) imgui.SameLine() imgui.Text(u8("/lock")) imgui.NewLine()

								imgui.Hotkey("Name9", 9, 100) imgui.SameLine() imgui.Text(u8("Крикнуть \"Работает \"С.О.П.Т.\"\"")) imgui.NewLine()

								imgui.Hotkey("Name23", 10, 100) imgui.SameLine() imgui.Text(u8("Сменить клист")) imgui.NewLine()
								imgui.Hotkey("Name25", 11, 100) imgui.SameLine() imgui.Text(u8("Лечение (антиРК)")) imgui.NewLine()
								imgui.Hotkey("Name12", 12, 100) imgui.SameLine() imgui.Text(u8("Показать удостоверение")) imgui.NewLine()
						end

						if maintabs.tab_main_binds.clistparams then
								imgui.PushItemWidth(500)
								imgui.InputText(u8'##clist1', guibuffers.clistparams.clist1) imgui.PopItemWidth() imgui.SameLine(600) imgui.PushItemWidth(500) imgui.InputText(u8'##clist27', guibuffers.clistparams.clist27)
								imgui.InputText(u8'##clist2', guibuffers.clistparams.clist2) imgui.PopItemWidth() imgui.SameLine(600) imgui.PushItemWidth(500) imgui.InputText(u8'##clist28', guibuffers.clistparams.clist28)
								imgui.InputText(u8'##clist3', guibuffers.clistparams.clist3) imgui.PopItemWidth() imgui.SameLine(600) imgui.PushItemWidth(500) imgui.InputText(u8'##clist29', guibuffers.clistparams.clist29)
								imgui.InputText(u8'##clist4', guibuffers.clistparams.clist4) imgui.PopItemWidth() imgui.SameLine(600) imgui.PushItemWidth(500) imgui.InputText(u8'##clist30', guibuffers.clistparams.clist30)
								imgui.InputText(u8'##clist5', guibuffers.clistparams.clist5) imgui.PopItemWidth() imgui.SameLine(600) imgui.PushItemWidth(500) imgui.InputText(u8'##clist31', guibuffers.clistparams.clist31)
								imgui.InputText(u8'##clist6', guibuffers.clistparams.clist6) imgui.PopItemWidth() imgui.SameLine(600) imgui.PushItemWidth(500) imgui.InputText(u8'##clist32', guibuffers.clistparams.clist32)
								imgui.InputText(u8'##clist7', guibuffers.clistparams.clist7) imgui.PopItemWidth() imgui.SameLine(600) imgui.PushItemWidth(500) imgui.InputText(u8'##clist33', guibuffers.clistparams.clist33)
								imgui.InputText(u8'##clist8', guibuffers.clistparams.clist8)
								imgui.InputText(u8'##clist9', guibuffers.clistparams.clist9)
								imgui.InputText(u8'##clist10', guibuffers.clistparams.clist10)
								imgui.InputText(u8'##clist11', guibuffers.clistparams.clist11)
								imgui.InputText(u8'##clist13', guibuffers.clistparams.clist13)
								imgui.InputText(u8'##clist14', guibuffers.clistparams.clist14)
								imgui.InputText(u8'##clist15', guibuffers.clistparams.clist15)
								imgui.InputText(u8'##clist16', guibuffers.clistparams.clist16)
								imgui.InputText(u8'##clist17', guibuffers.clistparams.clist17)
								imgui.InputText(u8'##clist18', guibuffers.clistparams.clist18)
								imgui.InputText(u8'##clist19', guibuffers.clistparams.clist19)
								imgui.InputText(u8'##clist20', guibuffers.clistparams.clist20)
								imgui.InputText(u8'##clist21', guibuffers.clistparams.clist21)
								imgui.InputText(u8'##clist22', guibuffers.clistparams.clist22)
								imgui.InputText(u8'##clist23', guibuffers.clistparams.clist23)
								imgui.InputText(u8'##clist24', guibuffers.clistparams.clist24)
								imgui.InputText(u8'##clist25', guibuffers.clistparams.clist25)
								imgui.InputText(u8'##clist26', guibuffers.clistparams.clist26)
								imgui.PopItemWidth()
						end
						
						
						
						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 - 30))
							if imgui.Button(u8("1"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.first, maintabs.tab_main_binds.clistparams = true, false end
						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2))
							if imgui.Button(u8("Параметры клист"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.first, maintabs.tab_main_binds.clistparams = false, true end
				end

				if maintabs.tab_user_binds.status then
						if maintabs.tab_user_binds.hk then
								imgui.NewLine()
								imgui.Text(u8("Клавиша активации")) imgui.SameLine(300)  imgui.Text(u8("Действие")) imgui.NewLine()
								imgui.Hotkey("Name27", 27, 100) imgui.SameLine() imgui.InputText(u8'##bind1', guibuffers.ubinds.bind1) imgui.SameLine() if imgui.ToggleButton("enter1", togglebools.tab_user_binds.hk[1]) then config_ini.bools[4] = togglebools.tab_user_binds.hk[1].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Enter")) imgui.NewLine()
								imgui.Hotkey("Name28", 28, 100) imgui.SameLine() imgui.InputText(u8'##bind2', guibuffers.ubinds.bind2) imgui.SameLine() if imgui.ToggleButton("enter2", togglebools.tab_user_binds.hk[2]) then config_ini.bools[5] = togglebools.tab_user_binds.hk[2].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Enter")) imgui.NewLine()
								imgui.Hotkey("Name29", 29, 100) imgui.SameLine() imgui.InputText(u8'##bind3', guibuffers.ubinds.bind3) imgui.SameLine() if imgui.ToggleButton("enter3", togglebools.tab_user_binds.hk[3]) then config_ini.bools[6] = togglebools.tab_user_binds.hk[3].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Enter")) imgui.NewLine()
								imgui.Hotkey("Name30", 30, 100) imgui.SameLine() imgui.InputText(u8'##bind4', guibuffers.ubinds.bind4) imgui.SameLine() if imgui.ToggleButton("enter4", togglebools.tab_user_binds.hk[4]) then config_ini.bools[7] = togglebools.tab_user_binds.hk[4].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Enter")) imgui.NewLine()
								imgui.Hotkey("Name31", 31, 100) imgui.SameLine() imgui.InputText(u8'##bind5', guibuffers.ubinds.bind5) imgui.SameLine() if imgui.ToggleButton("enter5", togglebools.tab_user_binds.hk[5]) then config_ini.bools[8] = togglebools.tab_user_binds.hk[5].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Enter")) imgui.NewLine()
								imgui.Hotkey("Name32", 32, 100) imgui.SameLine() imgui.InputText(u8'##bind6', guibuffers.ubinds.bind6) imgui.SameLine() if imgui.ToggleButton("enter6", togglebools.tab_user_binds.hk[6]) then config_ini.bools[9] = togglebools.tab_user_binds.hk[6].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Enter")) imgui.NewLine()
								imgui.Hotkey("Name33", 33, 100) imgui.SameLine() imgui.InputText(u8'##bind7', guibuffers.ubinds.bind7) imgui.SameLine() if imgui.ToggleButton("enter7", togglebools.tab_user_binds.hk[7]) then config_ini.bools[10] = togglebools.tab_user_binds.hk[7].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Enter")) imgui.NewLine()
								imgui.Hotkey("Name34", 34, 100) imgui.SameLine() imgui.InputText(u8'##bind8', guibuffers.ubinds.bind8) imgui.SameLine() if imgui.ToggleButton("enter8", togglebools.tab_user_binds.hk[8]) then config_ini.bools[11] = togglebools.tab_user_binds.hk[8].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Enter")) imgui.NewLine()
								imgui.Hotkey("Name35", 35, 100) imgui.SameLine() imgui.InputText(u8'##bind9', guibuffers.ubinds.bind9) imgui.SameLine() if imgui.ToggleButton("enter9", togglebools.tab_user_binds.hk[9]) then config_ini.bools[12] = togglebools.tab_user_binds.hk[9].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Enter")) imgui.NewLine()
								imgui.Hotkey("Name36", 36, 100) imgui.SameLine() imgui.InputText(u8'##bind10', guibuffers.ubinds.bind10) imgui.SameLine() if imgui.ToggleButton("enter10", togglebools.tab_user_binds.hk[10]) then config_ini.bools[13] = togglebools.tab_user_binds.hk[10].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Enter")) imgui.NewLine()
								imgui.Hotkey("Name37", 37, 100) imgui.SameLine() imgui.InputText(u8'##bind11', guibuffers.ubinds.bind11) imgui.SameLine() if imgui.ToggleButton("enter11", togglebools.tab_user_binds.hk[11]) then config_ini.bools[14] = togglebools.tab_user_binds.hk[11].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Enter"))
						end

						if maintabs.tab_user_binds.cmd then
								imgui.NewLine()
								imgui.Text(u8("Команда активации")) imgui.SameLine(300)  imgui.Text(u8("Действие")) imgui.NewLine()
								imgui.PushItemWidth(100)
								imgui.InputText(u8'##ucbindsc1', guibuffers.ucbindsc.bind1) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds1', guibuffers.ucbinds.bind1) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##ucbindsc2', guibuffers.ucbindsc.bind2) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds2', guibuffers.ucbinds.bind2) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##ucbindsc3', guibuffers.ucbindsc.bind3) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds3', guibuffers.ucbinds.bind3) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##ucbindsc4', guibuffers.ucbindsc.bind4) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds4', guibuffers.ucbinds.bind4) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##ucbindsc5', guibuffers.ucbindsc.bind5) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds5', guibuffers.ucbinds.bind5) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##ucbindsc6', guibuffers.ucbindsc.bind6) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds6', guibuffers.ucbinds.bind6) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##ucbindsc7', guibuffers.ucbindsc.bind7) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds7', guibuffers.ucbinds.bind7) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##ucbindsc8', guibuffers.ucbindsc.bind8) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds8', guibuffers.ucbinds.bind8) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##ucbindsc9', guibuffers.ucbindsc.bind9) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds9', guibuffers.ucbinds.bind9) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##ucbindsc10', guibuffers.ucbindsc.bind10) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds10', guibuffers.ucbinds.bind10) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##ucbindsc11', guibuffers.ucbindsc.bind11) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds11', guibuffers.ucbinds.bind11) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##ucbindsc12', guibuffers.ucbindsc.bind12) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds12', guibuffers.ucbinds.bind12) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##ucbindsc13', guibuffers.ucbindsc.bind13) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds13', guibuffers.ucbinds.bind13) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##ucbindsc14', guibuffers.ucbindsc.bind14) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##ucbinds14', guibuffers.ucbinds.bind14) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.PopItemWidth()
						end

						if maintabs.tab_user_binds.pie then
								imgui.NewLine()
								imgui.Text(u8("Pie menu - это круговое радиальное меню для отправки быстрых сообщений. Вы можете назначить до десяти действий. Удерживайте клавишу активации, наведите на нужный пункт и отпустите клавишу."))
								imgui.Hotkey("Name44", 44, 100) imgui.SameLine() imgui.Text(u8("Клавиша активации (только одиночная клавиша поддерживается)")) imgui.NewLine()
								imgui.Text(u8("Имя пункта")) imgui.SameLine(200)  imgui.Text(u8("Действие")) imgui.NewLine()
								imgui.PushItemWidth(100)
								imgui.InputText(u8'##piename1', guibuffers.UserPieMenu.names.name1) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##pieaction1', guibuffers.UserPieMenu.actions.action1) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##piename2', guibuffers.UserPieMenu.names.name2) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##pieaction2', guibuffers.UserPieMenu.actions.action2) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##piename3', guibuffers.UserPieMenu.names.name3) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##pieaction3', guibuffers.UserPieMenu.actions.action3) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##piename4', guibuffers.UserPieMenu.names.name4) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##pieaction4', guibuffers.UserPieMenu.actions.action4) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##piename5', guibuffers.UserPieMenu.names.name5) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##pieaction5', guibuffers.UserPieMenu.actions.action5) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##piename6', guibuffers.UserPieMenu.names.name6) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##pieaction6', guibuffers.UserPieMenu.actions.action6) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##piename7', guibuffers.UserPieMenu.names.name7) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##pieaction7', guibuffers.UserPieMenu.actions.action7) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##piename8', guibuffers.UserPieMenu.names.name8) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##pieaction8', guibuffers.UserPieMenu.actions.action8) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##piename9', guibuffers.UserPieMenu.names.name9) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##pieaction9', guibuffers.UserPieMenu.actions.action9) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##piename10', guibuffers.UserPieMenu.names.name10) imgui.SameLine() imgui.PushItemWidth(900) imgui.InputText(u8'##pieaction10', guibuffers.UserPieMenu.actions.action10) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.PopItemWidth()
						end

						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 - 30))
								if imgui.Button(u8("По клавише"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_user_binds.hk, maintabs.tab_user_binds.cmd, maintabs.user_keys.status.v, maintabs.tab_user_binds.pie = true, false, false, false end
						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2))
								if imgui.Button(u8("По команде"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_user_binds.hk, maintabs.tab_user_binds.cmd,maintabs.user_keys.status.v, maintabs.tab_user_binds.pie = false, true, false, false end
						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 30))
								if imgui.Button(u8("Pie menu"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_user_binds.hk, maintabs.tab_user_binds.cmd,maintabs.user_keys.status.v, maintabs.tab_user_binds.pie = false, false, false, true end
						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 60))
								if imgui.Button(u8("Список ключей"), imgui.ImVec2(120.0, 20.0)) then maintabs.user_keys.status.v = true end
				end

				if maintabs.tab_bbot.status then
					imgui.NewLine()
					if imgui.Button(u8("Нажмите чтобы настроить отправку случайных сообщений в чат"), imgui.ImVec2(400.0, 20.0)) then maintabs.rphr.status.v = true end
					if imgui.Button(u8("Нажмите чтобы настроить автоматическое взятие БП со склада"), imgui.ImVec2(400.0, 20.0)) then maintabs.auto_bp.status.v = true end
					if imgui.Button(u8("Нажмите чтобы настроить варнинг на упоминание тебя в рации"), imgui.ImVec2(400.0, 20.0)) then maintabs.warnings.status.v = true end
					if imgui.ToggleButton("tab_bbot1", togglebools.tab_bbot[1]) then config_ini.bools[39] = togglebools.tab_bbot[1].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Включить подсветку ника в чате"))
					if imgui.ToggleButton("tab_bbot2", togglebools.tab_bbot[3]) then config_ini.bools[42] = togglebools.tab_bbot[3].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Автоматически синхронизировать цвет ника с цветом ника водителя"))
					if imgui.ToggleButton("tab_bbot3", togglebools.tab_bbot[4]) then config_ini.bools[55] = togglebools.tab_bbot[4].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Оповещать о вышедших из игры игроков в прорисовке"))
					if imgui.ToggleButton("tab_bbot5", togglebools.tab_bbot[6]) then config_ini.bools[15] = togglebools.tab_bbot[6].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Оповещать о употребляющих психохил в прорисовке игроках"))
					if imgui.ToggleButton("tab_bbot6", togglebools.tab_bbot[7]) then config_ini.bools[57] = togglebools.tab_bbot[7].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Автоматически снимать оружие с предохранителя перед выстрелом (нажмите для настройки)")) if imgui.IsItemClicked() then maintabs.tab_main_binds.gunparams.v = true end
					if imgui.ToggleButton("tab_bbot7", togglebools.tab_bbot[8]) then config_ini.bools[59] = togglebools.tab_bbot[8].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Автоматически применять канистру если топливо в машине закончилось"))
					imgui.Hotkey("Name41", 41, 100) imgui.SameLine() imgui.Text(u8("Автоматическое зажатие клавиши движения")) imgui.NewLine()
					if imgui.ToggleButton("tab_bbot8", togglebools.tab_bbot[9]) then config_ini.bools[60] = togglebools.tab_bbot[9].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Активировать быстрый выбор оружия (нажмите для настройки)")) if imgui.IsItemClicked() then maintabs.tab_weap.status.v = true end
					if imgui.ToggleButton("tab_bbot10", togglebools.tab_bbot[10]) then config_ini.bools[62] = togglebools.tab_bbot[10].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Активировать чекер квартир"))
					imgui.Hotkey("Name14", 14, 100) imgui.SameLine() imgui.Text(u8("Внимание на точку")) imgui.NewLine()
					imgui.Hotkey("Name52", 52, 100) imgui.SameLine() imgui.Text(u8("Стоп-кран в машине")) imgui.NewLine()
				end

				if maintabs.tab_commands.status then
						if maintabs.tab_commands.first then
								imgui.NewLine()
								imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands1', guibuffers.commands.command1) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Доложить о ликвидации оборотня"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands19', guibuffers.commands.command19) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Написать СМС последнему отправителю")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands2', guibuffers.commands.command2) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Доложить о сопровождении грузовика"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands20', guibuffers.commands.command20) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Вывести список всех членов фракции онлайн в диалоговом окне")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands3', guibuffers.commands.command3) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Доложить о эвакуцаии грузовика"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands21', guibuffers.commands.command21) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Установить указанную погоду")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands4', guibuffers.commands.command4) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Доложить о ремонте остановленного грузовика"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands22', guibuffers.commands.command22) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Установить указанное время")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands5', guibuffers.commands.command5) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Доложить о возвращении грузовика на базу"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands25', guibuffers.commands.command25) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Переключить режим AFK")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands6', guibuffers.commands.command6) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Доложить о зачистке квадрата"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands27', guibuffers.commands.command27) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Вызвать всех механиков в сети в свой квадрат")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands7', guibuffers.commands.command7) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Доложить о эвакуации бойца(ов)"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands28', guibuffers.commands.command28) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Показать паспорт и удостоверение")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands9', guibuffers.commands.command9) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Написать в рацию с тэгом"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands17', guibuffers.commands.command17) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Поиск игрока в ЧС ЛВА")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands10', guibuffers.commands.command10) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Принять вызов в квадрат/место"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands18', guibuffers.commands.command18) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Команды меню поставок")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands11', guibuffers.commands.command11) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Представиться и попросить паспорт")) 
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands23', guibuffers.commands.command23) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Надеть клист 32 и аксессуар")) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##commands12', guibuffers.commands.command12) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Бросить гранату")) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##commands13', guibuffers.commands.command13) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Оглушить противника")) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##commands14', guibuffers.commands.command14) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Выбрать указанный клист")) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##commands15', guibuffers.commands.command15) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Запустить таймер РК")) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##commands16', guibuffers.commands.command16) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Поиск игрока в members")) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.PopItemWidth()
						end

						if maintabs.tab_commands.second and access.alevel >= 0 then
								imgui.NewLine()
								imgui.Text(u8("В данном разделе представлены команды модератора скрипта (кем Вас и считает скрипт). Для отображения списка команд проведите авторизацию в разделе с помощью команды /balogin"))
								if access.alevel > 0 then
										imgui.Text(u8("/lek [pmp/rb/np/tp/nv/no] - проставляет отметку о прохождении указанной лекции"))
										imgui.Text(u8("/pcheck (-1) - выводит список присмотренных игроков онлайн (-1 - весь список)"))
										imgui.Text(u8("/tren [локация] [количество союзников] [количество противников] [результат (1-3)] [подразделение противников] - проставить отметку о проведении тренировки в таблице"))
								end

								if access.alevel > 1 then
										imgui.Text(u8("/padd [id/nick] - добавить указанного игрока в список присмотренных"))
										imgui.Text(u8("/pdel [id/nick] - удалить указанного игрока из списка присмотренных"))
										imgui.Text(u8("/add [id] [дата последнего повышения] - добавить игрока в таблицу отряда"))
										imgui.Text(u8("/del [id] ([причина занесеня в ЧС]) - удалить игрока из таблицы отряда"))
										imgui.Text(u8("/change [id] [rank: 1/0] [отметки/0/-1] ([перевести в основу: 1/0]) - изменить информацию об игроке в таблице отряда"))
										imgui.Text(u8("/mark [id] [zua/zuo/zio/zz/pmp/rb/uts/no/kp/np/op/total/dopusk] [оценка 0-5] ([причина недопуска/примечание]) - проставить игроку оценку за определенное испытание"))										
								end

								if access.alevel > 2 then
									imgui.Text(u8("/otm - проставить отметки личному составу в таблице (майор +)"))		
									imgui.Text(u8("/serj - [мин. ранг] [мин. отметки] - вывести в консоль список всех игроков с заданными критериями"))						
								end
								
								if access.alevel == 3 or access.alevel == 6 then
									imgui.Text(u8("/fond [add/del/ref] - изменить фонд отряда (нажмите для настройки)")) if imgui.IsItemClicked() then maintabs.tab_commands.money.v = true end
								end

								if access.alevel > 4 then
									imgui.Text(u8("/moder [id] [уровень] [пароль для входа] - выдать указанному игроку права модератора"))
									imgui.Text(u8("/reg [id] [T/M/H] - зарегистрировать игрока в биндере (мимо таблицы)"))
									imgui.Text(u8("/ban [id] - забрать доступ к биндеру указанного игрока (мимо таблицы)"))
								end
						end

						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 - 30))
								if imgui.Button(u8("1"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_commands.first, maintabs.tab_commands.second, maintabs.tab_commands.help.v, maintabs.tab_commands.money.v = true, false, false, false end
						if access.alevel >= 0 then
								imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2))
										if imgui.Button(u8("2"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_commands.first, maintabs.tab_commands.second, maintabs.tab_commands.help.v, maintabs.tab_commands.money.v = false, true, false, false end
						end
						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 30))
								if imgui.Button(u8("Помощь"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_commands.help.v, maintabs.tab_commands.money.v = true, false end
				end

				if maintabs.tab_overlay.status then
						imgui.NewLine()
						imgui.Text(u8("Overlay - функция позволяющая выводить поверх игрового экрана графические элементы с различной информацией. Используемый скриптом метод не конфликтует с другими оверлеями и\nпрограммами видеозахвата. Стандартные координаты элементов подогнаны по вкусу разработчика и под экран 1920х1080 в сочетании с GTA V Hud by DC22Pac. При необходимости переместить\nэлементы назначьте горячую клавишу и нажмите на неё."))
						imgui.NewLine()
						imgui.Hotkey("Name43", 43, 100) imgui.SameLine() imgui.Text(u8("Настроить расположение элементов")) imgui.NewLine()
						if imgui.ToggleButton("tab_overlay1", togglebools.tab_overlay[1]) then config_ini.bools[25] = togglebools.tab_overlay[1].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Разрешить использование overlay")) 
						if imgui.ToggleButton("tab_overlay2", togglebools.tab_overlay[2]) then config_ini.bools[26] = togglebools.tab_overlay[2].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Включить отображение названия текущего района"))
						if imgui.ToggleButton("tab_overlay3", togglebools.tab_overlay[3]) then config_ini.bools[27] = togglebools.tab_overlay[3].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Включить отображение своего ника и ID на экране"))
						if imgui.ToggleButton("tab_overlay4", togglebools.tab_overlay[4]) then config_ini.bools[28] = togglebools.tab_overlay[4].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Включить отображение информации о автомобиле и его здоровье"))
						if imgui.ToggleButton("tab_overlay5", togglebools.tab_overlay[5]) then config_ini.bools[29] = togglebools.tab_overlay[5].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Включить отображение оставшегося времени до выхода из бункера (RK)"))
						if imgui.ToggleButton("tab_overlay6", togglebools.tab_overlay[6]) then config_ini.bools[30] = togglebools.tab_overlay[6].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Включить отображение активности режима AFK"))
						if imgui.ToggleButton("tab_overlay7", togglebools.tab_overlay[7]) then config_ini.bools[31] = togglebools.tab_overlay[7].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Включить отображение информации о текущей цели"))
						if imgui.ToggleButton("tab_overlay8", togglebools.tab_overlay[8]) then config_ini.bools[32] = togglebools.tab_overlay[8].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Включить отображение состояния здоровья и брони персонажа"))
						if imgui.ToggleButton("tab_overlay9", togglebools.tab_overlay[9]) then config_ini.bools[33] = togglebools.tab_overlay[9].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Включить отображение технической информации"))
						if imgui.ToggleButton("tab_overlay10", togglebools.tab_overlay[10]) then config_ini.bools[34] = togglebools.tab_overlay[10].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Включить отображение даты и времени на экране"))
						if imgui.ToggleButton("tab_overlay11", togglebools.tab_overlay[11]) then config_ini.bools[35] = togglebools.tab_overlay[11].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Включить отображение званий у игроков"))
						if imgui.ToggleButton("tab_overlay12", togglebools.tab_overlay[12]) then config_ini.bools[36] = togglebools.tab_overlay[12].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Включить отображение здоровья окружающей техники"))
						if imgui.ToggleButton("tab_overlay13", togglebools.tab_overlay[13]) then config_ini.bools[37] = togglebools.tab_overlay[13].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Включить отображение текущей раскладки в чате"))
						if imgui.ToggleButton("tab_overlay15", togglebools.tab_overlay[15]) then config_ini.bools[41] = togglebools.tab_overlay[15].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Заменить стандартный список игроков в сообществе"))
						if imgui.ToggleButton("tab_overlay16", togglebools.tab_overlay[16]) then config_ini.bools[43] = togglebools.tab_overlay[16].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Улучшить поведение стандартного логотипа +500")) if imgui.IsItemClicked() then maintabs.pl500.status.v = true end
						if imgui.ToggleButton("tab_overlay17", togglebools.tab_overlay[17]) then config_ini.bools[44] = togglebools.tab_overlay[17].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Показать статистику нанесенного урона (/dclean - обнулить статистику)"))
						if imgui.ToggleButton("tab_overlay18", togglebools.tab_overlay[18]) then config_ini.bools[52] = togglebools.tab_overlay[18].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Показывать историю нанесенного/полученого урона"))
						if imgui.ToggleButton("tab_overlay19", togglebools.tab_overlay[19]) then config_ini.bools[54] = togglebools.tab_overlay[19].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Показывать таймер взятия БК после смерти в квадрате"))
						if imgui.ToggleButton("tab_overlay20", togglebools.tab_overlay[20]) then config_ini.bools[63] = togglebools.tab_overlay[20].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Активировать дамаг информер по транспорту"))
						if imgui.ToggleButton("tab_overlay21", togglebools.tab_overlay[21]) then config_ini.bools[64] = togglebools.tab_overlay[21].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Активировать панель состояния персонажа"))
						if imgui.IsItemHovered() then 
							if not imimimage then imimimage = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\pov\\1.png') end
							local curX, curY = getCursorPos()
							imgui.SetNextWindowPos(imgui.ImVec2(curX + 189, curY - 45))
							imgui.Begin('#imim', show.imim, 1 + 32 + 2 + 0 + 64)
							imgui.Image(imimimage, imgui.ImVec2(189, 90))
							imgui.End()	
						end
						if imgui.ToggleButton("tab_overlay22", togglebools.tab_overlay[22]) then config_ini.bools[65] = togglebools.tab_overlay[22].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Активировать индикатор направления получаемого урона"))
					end

				if maintabs.tab_settings.status then
						imgui.NewLine()
						imgui.Text(u8("Укажите ваше имя")) imgui.SameLine(200) imgui.Text(u8("Укажите вашу фамилию")) imgui.SameLine(400) imgui.Text(u8("Укажите ваше звание")) imgui.SameLine(600) imgui.Text(u8("Укажите часовой пояс (прим.: -1; 5 и т.д.)")) imgui.SameLine(850) imgui.Text(u8("Женский пол")) imgui.NewLine()
						imgui.PushItemWidth(140)
						imgui.InputText(u8'##fname', guibuffers.settings.fname) imgui.SameLine(200) imgui.InputText(u8'##sname', guibuffers.settings.sname) imgui.SameLine(400) imgui.InputText(u8'##rank', guibuffers.settings.rank) imgui.SameLine(600) imgui.InputText(u8'##time', guibuffers.settings.timep) imgui.PopItemWidth() imgui.SameLine(800) if imgui.ToggleButton("usersex", togglebools.tab_settings[1]) then RP = togglebools.tab_settings[1].v and "а" or "" config_ini.Settings.UserSex = togglebools.tab_settings[1].v and 1 or 0 end imgui.NewLine() 
						if show.othervars.saccess then
							imgui.Text(u8("Укажите название подразделения\n(для удостоверения)")) imgui.SameLine(200) imgui.Text(u8("Укажите тэг в рации")) imgui.SameLine(400) imgui.Text(u8("Укажите номер вашего клиста (крайне не советую буквы писать)")) imgui.NewLine()
							imgui.PushItemWidth(140)
							imgui.InputText(u8'##PlayerU', guibuffers.settings.PlayerU) imgui.SameLine(200) imgui.InputText(u8'##tag', guibuffers.settings.tag) imgui.SameLine(400) imgui.InputText(u8'##useclist', guibuffers.settings.useclist) imgui.PopItemWidth() imgui.SameLine(600) imgui.NewLine()
						end
				end

				if maintabs.tab_weap.status.v then
					imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
					imgui.SetNextWindowSize(imgui.ImVec2(400, 620), imgui.Cond.Always)
					imgui.Begin(u8("Настройки выбора оружия"), maintabs.tab_weap.status, 4 + 2 + 32)
					
					if not images[7] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\weaps\\unarmed.png') then images[7] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\weaps\\unarmed.png') end end
					if not images[8] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\weaps\\desert_eagle.png') then images[8] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\weaps\\desert_eagle.png') end end
					if not images[9] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\weaps\\shotgun.png') then images[9] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\weaps\\shotgun.png') end end
					if not images[10] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\weaps\\mp5.png') then images[10] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\weaps\\mp5.png') end end
					if not images[11] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\weaps\\m4.png') then images[11] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\weaps\\m4.png') end end
					if not images[12] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\weaps\\rifle.png') then images[12] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\weaps\\rifle.png') end end
					if not images[13] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\weaps\\parachute.png') then images[13] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\weaps\\parachute.png') end end

					imgui.Image(images[7], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name45", 45, 100) imgui.SameLine() imgui.Text(u8("Выбор кулака")) imgui.NewLine()
					imgui.Image(images[8], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name46", 46, 100) imgui.SameLine() imgui.Text(u8("Выбор Desert Eagle")) imgui.NewLine()
					imgui.Image(images[9], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name47", 47, 100) imgui.SameLine() imgui.Text(u8("Выбор Shotgun")) imgui.NewLine()
					imgui.Image(images[10], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name48", 48, 100) imgui.SameLine() imgui.Text(u8("Выбор SMG")) imgui.NewLine()
					imgui.Image(images[11], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name49", 49, 100) imgui.SameLine() imgui.Text(u8("Выбор M4A1")) imgui.NewLine()
					imgui.Image(images[12], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name50", 50, 100) imgui.SameLine() imgui.Text(u8("Выбор Country Rifle")) imgui.NewLine()
					imgui.Image(images[13], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name51", 51, 100) imgui.SameLine() imgui.Text(u8("Выбор парашюта")) imgui.NewLine()
					imgui.End()
				end

				if maintabs.tab_commands.money.v then
					imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
					imgui.SetNextWindowSize(imgui.ImVec2(510, 500), imgui.Cond.Always)
					imgui.Begin(u8("Настройки фонда отряда"), maintabs.tab_commands.money, 4 + 2 + 32)
					if imgui.ToggleButton("tab_money1", togglebools.tab_moder[1]) then config_ini.bools[58] = togglebools.tab_moder[1].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Активировать мониторинг фонда отряда (для отображения нужно авторизоваться под админкой)"))
					imgui.Text(u8("Выберите необходимый вам цвет текста денег из фонда")) 
					imgui.PushItemWidth(100) imgui.InputText(u8'##money1', guibuffers.fond.fondcolor) imgui.PopItemWidth() imgui.SameLine() imgui.PushFont(imfonts.fontmoney) imgui.TextColoredRGB(u8("{" .. (guibuffers.fond.fondcolor.v) .. "}$819405828")) imgui.PopFont() imgui.NewLine()
					imgui.Text(u8("Выберите необходимый вам цвет текста личных денег")) 
					imgui.PushItemWidth(100) imgui.InputText(u8'##money2', guibuffers.fond.mycolor) imgui.PopItemWidth() imgui.SameLine() imgui.PushFont(imfonts.fontmoney) imgui.TextColoredRGB(u8("{" .. (guibuffers.fond.mycolor.v) .. "}$75729")) imgui.PopFont() imgui.NewLine()
					imgui.End()
				end

				if maintabs.tab_commands.help.v then
						imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
						imgui.SetNextWindowSize(imgui.ImVec2(510, 100), imgui.Cond.Always)
						imgui.Begin(u8("Использование командного процессора"), maintabs.tab_commands.help, 4 + 2 + 32)
						imgui.Text(u8("Укажите нужную Вам команду активации без /. Введите указанную команду в чате\nдля активации подпрограммы. Команды в скрипте замещают серверные команды.\nВНИМАНИЕ: здесь перечислены не все существующие команды скрипта. Для\nознакомления с полным списком команд введите команду /commandhelp list в чате."))
						imgui.End()
				end

				if maintabs.pl500.status.v then
						imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
						imgui.SetNextWindowSize(imgui.ImVec2(1000, 300), imgui.Cond.Always)
						imgui.Begin(u8("Настройки +500"), maintabs.pl500.status, 4 + 2 + 32)
						imgui.Text(u8("Выберите необходимый вам цвет текста"))
						-- local a, r, g, b = explode_argb(tonumber("0xFF0000"))
						-- local color = imgui.ImFloat3(r, g, b)
						-- local c = "FF0000"
						-- if imgui.ColorEdit3('test', color) then
							-- local clr = join_argb(color.v[1] * 255, color.v[2] * 255, color.v[3] * 255)
							--print(('%06X'):format(clr))
							-- c = ('%06X'):format(clr)
						-- end
						imgui.PushItemWidth(100) imgui.InputText(u8'##plus5001', guibuffers.plus500.plus500color) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Укажите цвет")) imgui.NewLine()
						-- imgui.PushItemWidth(100) imgui.InputText(u8'##plus5002', guibuffers.plus500.plus500size) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Укажите размер шрифта (не более 128)")) imgui.NewLine()
						-- imgui.PushItemWidth(100) imgui.InputText(u8'##plus5003', guibuffers.plus500.plus500font) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("Укажите имя шрифта")) imgui.NewLine()
						imgui.PushFont(imfonts.font500)
						local money = tostring(500 * 3)
						imgui.TextColoredRGB("{" .. guibuffers.plus500.plus500color.v .. "}$" .. money .. "")
						imgui.PopFont()
						imgui.End()  
				end
				
				if maintabs.user_keys.status.v then
						imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
						imgui.SetNextWindowSize(imgui.ImVec2(1000, 300), imgui.Cond.Always)
						imgui.Begin(u8("Список пользовательских ключей"), maintabs.user_keys.status, 4 + 2 + 32)
						imgui.Text(u8("Для использования ключа введите его в необходимое место в тексте между двумя @. Этот ключ будет заменен на одно из нижеперечисленных значений.\nНапример: \"Мой ID : @MyID@\" вернет: \"Мой ID : 231\". Список ключей:\n@enter@ - разделяет строку на несколько команд (задержка " .. tostring(delay) .. " мс.) - не работает при непоставленной галочке Enter в пользовательском бинде.\n@Hour@ - возвращает текущий час (0-23) вашего компьютера\n@Min@ - возвращает текущие минуты (0-60) вашего компьютера\n@Sec@ - вовзращает текущие секунды вашего компьютера\n@Date@ - возвращает текущую дату в формате " .. os.date("%d.%m.%Y") .. "\n@MyID@ - вовзращает ваш текущий ID\n@KV@ - вовзращает ваш текущий квадрат\n@clist@ - возвращает название текущего клиста в винительном падеже (повязку №31)\n@tid@ - возвращает ID последнего игрока в прицеле/водителя машины/пассажира мото (при отсутствии водителя)."))
						imgui.End()
				end

				if maintabs.warnings.status.v then
						imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
						imgui.SetNextWindowSize(imgui.ImVec2(400, 230), imgui.Cond.Always)
						imgui.Begin(u8("Упоминание в рации"), maintabs.warnings.status, 4 + 2 + 32)
						imgui.Text(u8("Скрипт создаст варнинг принахождении в чате фракции одного и\nнижеперечисленных слов. Лучший вариант: ваша фамилия с большой\nи маленькой буквы на латинице и на кириллице."))
						imgui.NewLine()
						if imgui.ToggleButton("warn0", togglebools.tab_bbot[2]) then config_ini.bools[40] = togglebools.tab_bbot[2].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Активировать функцию"))
						imgui.PushItemWidth(500)
						imgui.InputText(u8'##warn1', guibuffers.warnings.war1)
						imgui.InputText(u8'##warn2', guibuffers.warnings.war2)
						imgui.InputText(u8'##warn3', guibuffers.warnings.war3)
						imgui.InputText(u8'##warn4', guibuffers.warnings.war4)
						imgui.PopItemWidth()
						imgui.End()
				end

				if maintabs.auto_bp.status.v then
						imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
						imgui.SetNextWindowSize(imgui.ImVec2(310, 300), imgui.Cond.Always)
						imgui.Begin(u8("Настройки автоматического взятия БП со склада"), maintabs.auto_bp.status, 4 + 2 + 32)
						if imgui.ToggleButton("bp1", togglebools.auto_bp[1]) then config_ini.bools[18], AutoDeagle = togglebools.auto_bp[1].v and 1 or 0, togglebools.auto_bp[1].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Брать Desert Eagle")) imgui.NewLine()
						if imgui.ToggleButton("bp2", togglebools.auto_bp[2]) then config_ini.bools[19], AutoShotgun = togglebools.auto_bp[2].v and 1 or 0, togglebools.auto_bp[2].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Брать Shotgun")) imgui.NewLine()
						if imgui.ToggleButton("bp3", togglebools.auto_bp[3]) then config_ini.bools[20], AutoSMG = togglebools.auto_bp[3].v and 1 or 0, togglebools.auto_bp[3].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Брать SMG")) imgui.NewLine()
						if imgui.ToggleButton("bp4", togglebools.auto_bp[4]) then config_ini.bools[21], AutoM4A1 = togglebools.auto_bp[4].v and 1 or 0, togglebools.auto_bp[4].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Брать M4A1")) imgui.NewLine()
						if imgui.ToggleButton("bp5", togglebools.auto_bp[5]) then config_ini.bools[22], AutoRifle = togglebools.auto_bp[5].v and 1 or 0, togglebools.auto_bp[5].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Брать Country Rifle")) imgui.NewLine()
						if imgui.ToggleButton("bp6", togglebools.auto_bp[6]) then config_ini.bools[23], AutoPar = togglebools.auto_bp[6].v and 1 or 0, togglebools.auto_bp[6].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Брать парашют")) imgui.NewLine()
						if imgui.ToggleButton("bp7", togglebools.auto_bp[7]) then config_ini.bools[24], AutoOt = togglebools.auto_bp[7].v and 1 or 0, togglebools.auto_bp[7].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("Отыгрывать взятие со склада"))
						imgui.End()
				end

				if maintabs.tab_main_binds.gunparams.v then
					imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
					imgui.SetNextWindowSize(imgui.ImVec2(500, 350), imgui.Cond.Always)
					imgui.Begin(u8("Настройки автоматического снятия оружия с предохранителя"), maintabs.tab_main_binds.gunparams, 4 + 2 + 32)
					imgui.InputText(u8'##gun1', guibuffers.gunparams.gun1) imgui.SameLine() imgui.Text(u8("- отыгровка SD pistol")) imgui.NewLine()
					imgui.InputText(u8'##gun2', guibuffers.gunparams.gun2) imgui.SameLine() imgui.Text(u8("- отыгровка Desert Eagle")) imgui.NewLine()
					imgui.InputText(u8'##gun3', guibuffers.gunparams.gun3) imgui.SameLine() imgui.Text(u8("- отыгровка Shotgun")) imgui.NewLine()
					imgui.InputText(u8'##gun4', guibuffers.gunparams.gun4) imgui.SameLine() imgui.Text(u8("- отыгровка SMG")) imgui.NewLine()
					imgui.InputText(u8'##gun5', guibuffers.gunparams.gun5) imgui.SameLine() imgui.Text(u8("- отыгровка M4")) imgui.NewLine()
					imgui.InputText(u8'##gun6', guibuffers.gunparams.gun6) imgui.SameLine() imgui.Text(u8("- отыгровка AK47")) imgui.NewLine()
					imgui.InputText(u8'##gun7', guibuffers.gunparams.gun7) imgui.SameLine() imgui.Text(u8("- отыгровка Country Rifle")) imgui.NewLine()
					imgui.End()
				end

				if maintabs.rphr.status.v then
						imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
						imgui.SetNextWindowSize(imgui.ImVec2(400, 400), imgui.Cond.Always)
						imgui.Begin(u8("Случайные фразы"), maintabs.rphr.status, 4 + 2 + 32)
						imgui.Text(u8("Одна из указаных фраз будет выбрана случайным образом.\nПоддерживаются пользовательские ключи."))
						imgui.NewLine()
						imgui.Hotkey("Name42", 42, 100) imgui.SameLine() imgui.Text(u8("Клавиша активации")) imgui.NewLine()
						imgui.PushItemWidth(500)
						imgui.InputText(u8'##rphr1', guibuffers.rphr.bind1)
						imgui.InputText(u8'##rphr2', guibuffers.rphr.bind2)
						imgui.InputText(u8'##rphr3', guibuffers.rphr.bind3)
						imgui.InputText(u8'##rphr4', guibuffers.rphr.bind4)
						imgui.InputText(u8'##rphr5', guibuffers.rphr.bind5)
						imgui.InputText(u8'##rphr6', guibuffers.rphr.bind6)
						imgui.InputText(u8'##rphr7', guibuffers.rphr.bind7)
						imgui.InputText(u8'##rphr8', guibuffers.rphr.bind8)
						imgui.InputText(u8'##rphr9', guibuffers.rphr.bind9)
						imgui.InputText(u8'##rphr10', guibuffers.rphr.bind10)
						imgui.PopItemWidth()
						imgui.End()
				end

				if guis.updatestatus.status.v then
					imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
					imgui.SetNextWindowSize(imgui.ImVec2(1000, 500), imgui.Cond.Always)
					imgui.Begin(u8("О программе"), guis.updatestatus.status, 4 + 2 + 32)
					imgui.Text(u8("Что нового"))
					for k, i in ipairs(guis.updatestatus.wn) do imgui.Text(u8(i)) end
					local tt = [[Незадокументированные функции:
						1) Автоматически /eject пассажира с мотоцикла (отключить нельзя);
						2) /bugreport - отправить сообщение разработчику;
						3) /bp - разовая (до релога скрипта) настройка функции автоматического взятия БП;
						4) /scr exit - отключение скрипта;
						5) запрет использования команд piss/iznas - автоматическая активация (отключить нельзя);
						6) /toggle - разовое (до релога скрипта) отключение функции пропуска диалога в казарме;
						7) навестись на машину + CTRL - включение режима синхронизации скорости с целью - отключение - нажатие CTRL;
						8) /duel [id] - вызвать указанного игрока на дуэль (до 12 хп);
						9) /get otm - получить статистику своего онлайна за неделю;
						10) выбор М4 при нажатии кнопки "Сесть на пассажирку" - автоматическая активация (отключить нельзя);
						11) /refoffm - обновить список игроков в супермемберсе;
						12) /freeze - заморозить определенную машину (если она скатывается с обрыва например).
					]]
					imgui.Text(u8(tt))
					imgui.End()
				end
				
				imgui.ShowCursor = true
				imgui.End()
				imgui.PopFont()
		end
		-- ###################################### Overlay
		--if config_ini.bools[25] == 1 then
				imgui.SwitchContext()
				colors[clr.WindowBg] = ImVec4(0, 0, 0, 0)
				local SetModeCond = SetMode and 0 or 4
				
				if 1 == 1 then -- config_ini.bools[26] показывать район и квадрат
						local x, y, z
						if not SetMode then x,y,z = getCharCoordinates(PLAYER_PED) end
						local zone = SetMode and "Doherty" or calculateZone(x, y, z)
						--local zone = SetMode and "Doherty" or calculateNamedZone(x, y, z)
						if zone ~= "Unknown" then
								local color = zone == "Restricted Area" and "{FF0000}" or "{FFFAFA}"
								if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_placeX, config_ini.ovCoords.show_placeY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_placeX, config_ini.ovCoords.show_placeY)) end end
								local kv = SetMode and "Л-14" or kvadrat()
								imgui.Begin('#empty_field2', show.show_place, 1 + 32 + 2 + SetModeCond + 64)
								imgui.PushFont(imfonts.exFont)
								imgui.TextColoredRGB('' .. color .. '' .. zone .. ' [' .. kv .. ']')
								imgui.PopFont()
								s_coord["s_place"] = imgui.GetWindowPos()
								imgui.End()
						end
				end
				
				if config_ini.bools[34] == 1 then -- показывать время
						if not SetMode then	imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_timeX, config_ini.ovCoords.show_timeY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_timeX, config_ini.ovCoords.show_timeY))	end end
						imgui.Begin('#empty_field', show.show_time, 1 + 32 + 2 + SetModeCond + 64)
						imgui.PushFont(imfonts.exFont)
						imgui.TextColoredRGB('{FFFF00}' .. os.date("%d.%m.%y %X") .. '')
						imgui.PopFont()
						s_coord["s_time"] = imgui.GetWindowPos()
						imgui.End()
				end

				if config_ini.bools[27] == 1 then -- показывать имя персонажа и его id
						if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_nameX, config_ini.ovCoords.show_nameY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_nameX, config_ini.ovCoords.show_nameY))	end	end
						local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
						if result then
								local name = sampGetPlayerNickname(id)
								local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
								local clist = clist == "ffff" and "fffafa" or clist
								imgui.Begin('#empty_field3', show.show_name, 1 + 32 + 2 + SetModeCond + 64)
								imgui.PushFont(imfonts.exFont)
								imgui.TextColoredRGB('{' .. clist .. '}' .. name .. '')
								imgui.SameLine()
								imgui.TextColoredRGB('{' .. clist .. '}[' .. tostring(id) .. ']')
								imgui.PopFont()
								s_coord["s_name"] = imgui.GetWindowPos()
								imgui.End()
						end
				end

				if config_ini.bools[28] == 1 then -- показывать информацию о текущей технике
						if isCharInAnyCar(PLAYER_PED) then
								local carhandle = storeCarCharIsInNoSave(PLAYER_PED)-- Получения handle транспорта
								local idcar = getCarModel(carhandle) -- Получение ИД транспорта
								if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_vehX, config_ini.ovCoords.show_vehY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_vehX, config_ini.ovCoords.show_vehY)) end end
								imgui.Begin('#empty_field4', show.show_veh, 1 + 32 + 2 + SetModeCond + 64)
								imgui.PushFont(imfonts.exFont)
								imgui.TextColoredRGB('{FFFAFA}Транспорт: ' .. tVehicleNames[idcar-399] .. ' [' .. idcar .. ']')
								imgui.PopFont()
								s_coord["s_veh"] = imgui.GetWindowPos()
								imgui.End()
						end
				end

				if config_ini.bools[32] == 1 then -- показывать информацию о текущем ХП брони
						local carhandle
						if isCharInAnyCar(PLAYER_PED) then carhandle = storeCarCharIsInNoSave(PLAYER_PED) end
						local myHP = getCharHealth(PLAYER_PED)
						local myARM = getCharArmour(PLAYER_PED)
						local color, carHP
						if myHP < 30 then color = "{FF0000}" elseif myHP > 30 and myHP < 50 then color = "{FFFF00}" else color = "{00FF00}" end
						if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_hpX, config_ini.ovCoords.show_hpY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_hpX, config_ini.ovCoords.show_hpY)) end end
						imgui.Begin('#empty_field13', show.show_hp, 1 + 32 + 2 + SetModeCond + 64)
						imgui.PushFont(imfonts.exFontl)
						imgui.TextColoredRGB('{87CEFA}' .. myARM .. '')
						if not SetMode then if carhandle ~= nil and carhandle > 0 then carHP = getCarHealth(carhandle) end else carHP = 1000 end
						if carHP ~= nil then imgui.TextColoredRGB('{FFB6C1}' .. carHP .. '') end
						imgui.TextColoredRGB('' .. color .. '' .. myHP .. '')
						s_coord["s_hp"] = imgui.GetWindowPos()
						imgui.PopFont()
						imgui.End()
				end

				if config_ini.bools[36] == 1 then -- показывать здоровье машин вокруг
						local carhandles = getcars() -- получаем все машины вокруг
						if carhandles ~= nil then -- если машина обнаружена
								for k, v in pairs(carhandles) do -- перебор всех машин в прорисовке
										if doesVehicleExist(v) and isCarOnScreen(v) then -- если машина на экране
												local idcar = getCarModel(v) -- получаем ид модельки
												local myX, myY, myZ = getCharCoordinates(PLAYER_PED) -- получаем свои координаты
												local cX, cY, cZ = getCarCoordinates(v) -- получаем координаты машины
												local distanse = math.ceil(math.sqrt( ((myX-cX)^2) + ((myY-cY)^2) + ((myZ-cZ)^2))) -- расстояние между мной и машиной
												local ignorecars = {[432] = "Rhino", [520] = "Hydra", [425] = "Hunter"} -- ид игнорируемых машин
												 -- ид мотоциклов
												if ignorecars[idcar] == nil and isLineOfSightClear(myX, myY, myZ, cX, cY, cZ, true, false, false, true, false) and distanse <= 20 then
													-- если машина не из числа игнорируемых, между мной и машиной нет стен (персонажи и машины не считаются за стены) и расстояние не более 50 то...
														local cHP = getCarHealth(v) -- получаем хп машины
														local cPosX, cPosY = convert3DCoordsToScreen(cX, cY, cZ) -- переводим 3Д координаты мира в координаты на экране
														local col = cHP > 800 and 0xFF00FF00 or cHP > 500 and 0xFFFFFF00 or 0xFFFFFAFA -- получаем цвет текста в зависимости от ХП машины
														local col = vehtypes.motos[idcar] ~= nil and isCarTireBurst(v, 1) and 0xFFFF0000 or col -- если колесо МОТОЦИКЛА пробито то цвет ХП всегда красный
														local ctext = cHP
														if freeze.sidmode then local res, cid = sampGetVehicleIdByCarHandle(v) if res then ctext = "dl: " .. cHP .. " / cID: " .. cid .. "" end end
														renderFontDrawText(dx9font, ctext, cPosX - (renderGetFontDrawTextLength(dx9font, ctext, false) / 2), cPosY, col, false) -- рисуем текст
												end
										end
								end
						end
				end

				if showcmc then -- показывать доп. прицел для поиска техники
							imgui.SetNextWindowPos(imgui.ImVec2(sx - 24, sy - 24))
							imgui.Begin('#empty_field15', showcmc, 1 + 32 + 2 + SetModeCond + 64)
							if not showcmcimage then
									if doesFileExist(getWorkingDirectory() .. '\\Pictures\\showcmc.png') then
											showcmcimage = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\showcmc.png')
											if not showcmcimage then imgui.OpenPopup('Texture Loading Error') end
									else
											imgui.OpenPopup('Texture Loading Error')
									end
							else
									imgui.Image(showcmcimage, imgui.ImVec2(32, 32))
							end
							imgui.End()

							if not spsyns.mode and isKeyDown(vkeys.VK_CONTROL) and lastcarhandle ~= nil and isCharInAnyCar(PLAYER_PED) and getDriverOfCar(storeCarCharIsInNoSave(PLAYER_PED)) == PLAYER_PED then 
								local cl = getVehicleClass(lastcarhandle)
								if cl == 11 or cl == 15 or cl == 16 or cl == 21 or getDriverOfCar(lastcarhandle) == nil or getDriverOfCar(lastcarhandle) == PLAYER_PED then return end
								spsyns.changespeed = false 
								spsyns.tarspeed = 0
								spsyns.car = lastcarhandle 
								spsyns.firstshow = true 
								spsyns.mode = true 
							end
				end

				if sx ~= nil and (crosMode or SetMode) then -- показывать информацию о текущей цели или машине
					targetinfo()
				end

				if (config_ini.bools[29] == 1 and RKTimerTickCount ~= nil) or SetMode then
						local rtm = nil
						if not SetMode then
								local RKTo = 300 - (os.time() - RKTimerTickCount)
								if RKTo > 0 then
										local rmn = math.floor(RKTo / 60)
										local rsc = math.fmod(RKTo, 60) >= 10 and math.fmod(RKTo, 60) or "0" .. math.fmod(RKTo, 60) .. ""
										rtm = "" .. rmn ..":" .. rsc .. ""
								else
										rtm = "0:00"
										RKTimerTickCount = nil
										local bass = require "lib.bass" -- загружаем модуль
										local radio = bass.BASS_StreamCreateFile(false, "moonloader\\Sounds\\s.wav", 0, 0, 0)
										bass.BASS_ChannelSetAttribute(radio, BASS_ATTRIB_VOL, 0.5) -- громкость
										bass.BASS_ChannelPlay(radio, false) -- воспроизвести
										sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Время вышло. Можно возвращаться.", 0xFFFF0000)
								end
						end

						if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_rkX, config_ini.ovCoords.show_rkY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_rkX, config_ini.ovCoords.show_rkY)) end end
						rtm = SetMode and "2:52" or rtm
						imgui.Begin('#empty_field5', show.show_rk, 1 + 32 + 2 + SetModeCond + 64)
						imgui.PushFont(imfonts.exFont)
						imgui.TextColoredRGB('{FFFAFA}' .. rtm .. '')
						imgui.PopFont()
						s_coord["s_rk"] = imgui.GetWindowPos()
						imgui.End()
				end

				if (config_ini.bools[53] == 1 and BKTimerTickCount ~= nil) or SetMode then
					local rtm = nil
					if not SetMode then
							local RKTo = 35 - (os.time() - BKTimerTickCount)
							if RKTo > 0 then
									local rmn = math.floor(RKTo / 60)
									local rsc = math.fmod(RKTo, 60) >= 10 and math.fmod(RKTo, 60) or "0" .. math.fmod(RKTo, 60) .. ""
									rtm = "" .. rmn ..":" .. rsc .. ""
							else
									rtm = "0:00"
									BKTimerTickCount = nil
							end
					end

					if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_deathX, config_ini.ovCoords.show_deathY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_deathX, config_ini.ovCoords.show_deathY)) end end
					rtm = SetMode and "0:21" or rtm
					imgui.Begin('#empty_field43', show.show_death, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.exFont)
					imgui.TextColoredRGB('{FFFAFA}' .. rtm .. '')
					imgui.PopFont()
					s_coord["s_death"] = imgui.GetWindowPos()
					imgui.End()
				end

				if (config_ini.bools[30] == 1 and afkstatus) or SetMode then
						if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_afkX, config_ini.ovCoords.show_afkY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_afkX, config_ini.ovCoords.show_afkY)) end end
						imgui.Begin('#empty_field9', show.show_afk, 1 + 32 + 2 + SetModeCond + 64)
						imgui.PushFont(imfonts.exFont)
						imgui.TextColoredRGB('{00FF00}AFK')
						imgui.PopFont()
						s_coord["s_afk"] = imgui.GetWindowPos()
						imgui.End()
				end

				if config_ini.bools[33] == 1 then
						if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_tecinfoX, config_ini.ovCoords.show_tecinfoY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_tecinfoX, config_ini.ovCoords.show_tecinfoY)) end end
						imgui.Begin('#empty_field14', show.show_tecinfo, 1 + 32 + 2 + SetModeCond + 64)
						imgui.PushFont(imfonts.exFontl)
							local imlej = SetMode and "231, 412, 999" or lastID.e
						if imlej ~= "none" then imgui.TextColoredRGB('ID посл. эв. бойцов (lej): ' .. imlej .. '') end
							local immkv = SetMode and "A-12" or lastKV.m
						if immkv ~= "none" then imgui.TextColoredRGB('Посл. кв. эвак. грузовика (mkv): ' .. immkv .. '') end
							local imbkv = SetMode and "И-14" or lastKV.b
						if imbkv ~= "none" then imgui.TextColoredRGB('Посл. кв. эвак. бойца (bkv): ' .. imbkv .. '') end
						imgui.TextColoredRGB('Количество персонажей в прорисовке: ' .. (sampGetPlayerCount(true) - 1) .. '')
							local CStatus = CTaskArr["CurrentID"] == 0 and "{FFFAFA}Ожидание события" or "" .. CTaskArr["n"][CTaskArr[1][CTaskArr["CurrentID"]]] .. " " .. (indexof(CTaskArr[1][CTaskArr["CurrentID"]], CTaskArr["nn"]) ~= false and CTaskArr[3][CTaskArr["CurrentID"]] or "") .. ""
						imgui.TextColoredRGB('Статус контекстной клавиши: ' .. CStatus .. '')
						s_coord["s_tecinfo"] = imgui.GetWindowPos()
						imgui.PopFont()
						imgui.End()
				end

				if config_ini.bools[37] == 1 and sampIsChatInputActive() then
					local in1 = sampGetInputInfoPtr()
			     	local in1_1 = getStructElement(in1, 0x8, 4)
			      	local in2 = getStructElement(--[[int]] in1_1, --[[int]] 0x8, --[[int]] 4)
			      	local in3 = getStructElement(--[[int]] in1_1, --[[int]] 0xC, --[[int]] 4)
			      	local fib = in3 + 40
			      	local fib2 = in2 + 5
					local success = ffi.C.GetKeyboardLayoutNameA(keybbb.KeyboardLayoutName)
					local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(keybbb.KeyboardLayoutName), 16), 0x00000002, keybbb.LocalInfo, 32)
					local localName = ffi.string(keybbb.LocalInfo)
					local capsState = ffi.C.GetKeyState(20)
					imgui.SetNextWindowPos(imgui.ImVec2(fib2, fib))
					imgui.Begin('#empty_field37', show.show_keyb, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.exFontsquad)
					local a = sampGetChatInputText()
					local b = a:match("%/(%a+) .*")
					local c = (b == nil or sym[b] == nil) and sym[1] or sym[b]
					if sym.myid == -1 then
						sym.myid = #tostring(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
						sym.mynick = #sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
					end
					local d = c - sym.myid - sym.mynick
					local e = #a > d and "{FF0000}" .. #a .. "" or #a
					imgui.TextColoredRGB("Раскладка: {ffffff}" .. localName .. "; CAPS:" .. getStrByState(capsState) .. ", Символы: " .. e .. "/" .. d .. ".")
					imgui.PopFont()
					imgui.End()
				end
				
				if config_ini.bools[41] == 1 and (rCache.enable or SetMode) and not sampIsChatInputActive() then
					if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_squadX, config_ini.ovCoords.show_squadY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_squadX, config_ini.ovCoords.show_squadY)) end end
					imgui.Begin('#empty_field370', show.show_squad, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.exFontsquad)
					imgui.TextColoredRGB("{B30000}Состав отряда")
					s_coord["s_squad"] = imgui.GetWindowPos()
					imgui.SameLine()
					if not SetMode then
						local tkeys = {}
						local count = 0
						-- populate the table that holds the keys
						
						for k in pairs(rCache.smem) do count = count + 1 table.insert(tkeys, k) end				
						imgui.TextColoredRGB("{B30000}- " .. count .. ":")
						-- sort the keys
						table.sort(tkeys)
						local A_Index = 1
						for a, k in ipairs(tkeys) do
							if k ~= nil then
								local v = rCache.smem[k]
								local sqcol
								local HP
								local ARM
								if sampGetCharHandleBySampPlayerId(k) then
									sqcol = v.color
									ARM = sampGetPlayerArmor(k)
									HP = sampGetPlayerHealth(k)
								else
									sqcol = v.colorns
									ARM = 0
									HP = 0
								end
								
								local afk = (v.time ~= 0 and v.time + 30 <= os.time()) and "{008000} AFK: " .. (os.time() - v.time) .. "" or "" 
								local x, y = s_coord["s_squad"].x + 5, s_coord["s_squad"].y + (25 * A_Index)
								renderFontDrawText(imfonts.exFontsquadrender, "" .. v.name .. " [" .. k .. "]" .. afk .. "", x, y, sqcol)
							--	imgui.TextColoredRGB("{" .. sqcol .. "}" .. v.name .. " [" .. k .. "]" .. afk .. "")
								renderDrawLine(x + 2, y + 22, x + 90, y + 22, 5.0, 0xFF808080)
								renderDrawLine(x + 2 + 100, y + 22, x + 190, y + 22, 5.0, 0xFF808080)
								if k == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
									local myHP = getCharHealth(PLAYER_PED)
									local myARM = getCharArmour(PLAYER_PED)
									if myHP ~= 0 then renderDrawLine(x + 2, y + 22, x + ((90/100) * myHP), y + 22, 5.0, 0xFF800000) end
									if myARM ~= 0 then renderDrawLine(x + 2 + 100, y + 22, x + 100 + ((90/100) * myARM), y + 22, 5.0, 0xFFC0C0C0) end
								else
									if HP ~= 0 then renderDrawLine(x + 2, y + 22, x + ((90/100) * HP), y + 22, 5.0, 0xFF800000) end
									if ARM ~= 0 then renderDrawLine(x + 2 + 100, y + 22, x + 100 + ((90/100) * ARM), y + 22, 5.0, 0xFFC0C0C0) end
								--	colors[clr.PlotHistogram] = imgui.ImVec4(0.7, 0, 0, 1) imgui.ProgressBar(HP / 100, imgui.ImVec2(70, 3.0)) imgui.SameLine() imgui.SwitchContext() colors[clr.PlotHistogram] = imgui.ImVec4(0.9, 0.9, 0.9, 1) imgui.ProgressBar(ARM / 100, imgui.ImVec2(70, 3.0))
								end
								A_Index = A_Index + 1
							end
						end
					else
						imgui.TextColoredRGB("{B30000}- 5:")
						local x, y = s_coord["s_squad"].x + 5, s_coord["s_squad"].y + (25 * 1)
						renderFontDrawText(imfonts.exFontsquadrender, "Nya_Arigato [123]{008000} AFK: 231", x, y, -1766653952)
						renderDrawLine(x + 2, y + 20, x + 90, y + 20, 5.0, 0xFF808080)
						renderDrawLine(x + 2 + 100, y + 20, x + 190, y + 20, 5.0, 0xFF808080)
						local x, y = s_coord["s_squad"].x + 5, s_coord["s_squad"].y + (25 * 2)
						renderFontDrawText(imfonts.exFontsquadrender, "Aleksandr_Hacker [231]", x, y, -1766653952)
						renderDrawLine(x + 2, y + 20, x + 90, y + 20, 5.0, 0xFF808080)
						renderDrawLine(x + 2 + 100, y + 20, x + 190, y + 20, 5.0, 0xFF808080)
						local x, y = s_coord["s_squad"].x + 5, s_coord["s_squad"].y + (25 * 3)
						renderFontDrawText(imfonts.exFontsquadrender, "Arman_Soptovskij [222]", x, y, -1766653952)
						renderDrawLine(x + 2 , y + 20, x + 90, y + 20, 5.0, 0xFF808080)
						renderDrawLine(x + 2 + 100, y + 20, x + 190, y + 20, 5.0, 0xFF808080)
						local x, y = s_coord["s_squad"].x + 5, s_coord["s_squad"].y + (25 * 4)
						renderFontDrawText(imfonts.exFontsquadrender, "Vasiliy_Underwood [666]", x, y, -1766653952)
						renderDrawLine(x + 2, y + 20, x + 90, y + 20, 5.0, 0xFF808080)
						renderDrawLine(x + 2 + 100, y + 20, x + 190, y + 20, 5.0, 0xFF808080)
						local x, y = s_coord["s_squad"].x + 5, s_coord["s_squad"].y + (25 * 5)
						renderFontDrawText(imfonts.exFontsquadrender, "Olivia_Flores [111]", x, y, -1766653952)
						renderDrawLine(x + 2, y + 20, x + 90, y + 20, 5.0, 0xFF808080)
						renderDrawLine(x + 2 + 100, y + 20, x + 190, y + 20, 5.0, 0xFF808080)
					end
					
					imgui.PopFont()
					imgui.End()
				end
				
				if (config_ini.bools[43] == 1 and show.show_500.bool500.v) or SetMode then
					if not SetMode then
						if (os.time() - show.show_500.time500 <= 5) then
							imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_500X, config_ini.ovCoords.show_500Y))
							imgui.Begin('#empty_field39', show.show_500.bool500, 1 + 32 + 2 + SetModeCond + 64)
							imgui.PushFont(imfonts.font500)
							local money = tostring(500 * show.show_500.mult500)
							imgui.TextColoredRGB("{" .. config_ini.plus500[1] .. "}$" .. money .. "")
							imgui.PopFont()
							imgui.End()
						else
							show.show_500.bool500.v = false
							show.show_500.mult500 = 0
						end
					else
						if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_500X, config_ini.ovCoords.show_500Y)) end
						imgui.Begin('#empty_field39', show.show_500.bool500, 1 + 32 + 2 + SetModeCond + 64)
						imgui.PushFont(imfonts.font500)
						imgui.TextColoredRGB("{" .. config_ini.plus500[1] .. "}$1500")
						imgui.PopFont()
						s_coord["s_500"] = imgui.GetWindowPos()
						imgui.End()
					end
				end
				
				if config_ini.bools[44] == 1 then
						if not SetMode then	imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_dindX, config_ini.ovCoords.show_dindY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_dindX, config_ini.ovCoords.show_dindY))	end end
						imgui.Begin('#empty_field40', show.show_dmind.bool, 1 + 32 + 2 + SetModeCond + 64)
						imgui.PushFont(imfonts.exFont)
						if images[1] == nil then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\gunicons\\total.png') then images[1] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\gunicons\\total.png') end end
						if images[2] == nil then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\gunicons\\desert_eagleicon.png') then images[2] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\gunicons\\desert_eagleicon.png') end end
						if images[3] == nil then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\gunicons\\chromegunicon.png') then images[3] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\gunicons\\chromegunicon.png') end end
						if images[4] == nil then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\gunicons\\M4icon.png') then images[4] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\gunicons\\M4icon.png') end end
						if images[5] == nil then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\gunicons\\cuntgunicon.png') then images[5] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\gunicons\\cuntgunicon.png') end end
						if images[6] == nil then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\gunicons\\mp5lngicon.png') then images[6] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\gunicons\\mp5lngicon.png') end end
						
						local acc = (show.show_dmind.damind.hits[24] == 0 or show.show_dmind.damind.shots[24] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[24] / (show.show_dmind.damind.shots[24] / 100))
							if acc ~= 0 then imgui.Image(images[2], imgui.ImVec2(32, 32)) imgui.SameLine() imgui.TextColoredRGB('{F0F0F0}' .. math.ceil(show.show_dmind.damind.damage[24]) .. ' | ' .. acc .. '%') end--imgui.NewLine()
						local acc = (show.show_dmind.damind.hits[25] == 0 or show.show_dmind.damind.shots[25] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[25] / (show.show_dmind.damind.shots[25] / 100))
							if acc ~= 0 then imgui.Image(images[3], imgui.ImVec2(32, 32)) imgui.SameLine() imgui.TextColoredRGB('{F0F0F0}' .. math.ceil(show.show_dmind.damind.damage[25]) .. ' | ' .. acc .. '%') end --imgui.NewLine()
						local acc = (show.show_dmind.damind.hits[31] == 0 or show.show_dmind.damind.shots[31] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[31] / (show.show_dmind.damind.shots[31] / 100))
							if acc ~= 0 then imgui.Image(images[4], imgui.ImVec2(32, 32)) imgui.SameLine() imgui.TextColoredRGB('{F0F0F0}' .. math.ceil(show.show_dmind.damind.damage[31]) .. ' | ' .. acc .. '%') end --imgui.NewLine()
						local acc = (show.show_dmind.damind.hits[33] == 0 or show.show_dmind.damind.shots[33] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[33] / (show.show_dmind.damind.shots[33] / 100))
							if acc ~= 0 then imgui.Image(images[5], imgui.ImVec2(32, 32)) imgui.SameLine() imgui.TextColoredRGB('{F0F0F0}' .. math.ceil(show.show_dmind.damind.damage[33]) .. ' | ' .. acc .. '%') end --imgui.NewLine()
						local acc = (show.show_dmind.damind.hits[29] == 0 or show.show_dmind.damind.shots[29] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[29] / (show.show_dmind.damind.shots[29] / 100))
							if acc ~= 0 then imgui.Image(images[6], imgui.ImVec2(32, 32)) imgui.SameLine() imgui.TextColoredRGB('{F0F0F0}' .. math.ceil(show.show_dmind.damind.damage[29]) .. ' | ' .. acc .. '%') end --imgui.NewLine()
						local acc = (show.show_dmind.damind.hits[1] == 0 or show.show_dmind.damind.shots[1] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[1] / (show.show_dmind.damind.shots[1] / 100))
							imgui.Image(images[1], imgui.ImVec2(32, 32)) imgui.SameLine() imgui.TextColoredRGB('{F0F0F0}' .. math.ceil(show.show_dmind.damind.damage[1]) .. ' | ' .. acc .. '%') --imgui.NewLine()
						imgui.PopFont()
						s_coord["s_dind"] = imgui.GetWindowPos()
						imgui.End()
				end

				if config_ini.bools[52] == 1 then
					if not SetMode then	imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_damX, config_ini.ovCoords.show_damY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_damX, config_ini.ovCoords.show_damY))	end end
					imgui.Begin('#empty_field41', show.show_dam, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.exFontsquad)
					imgui.TextColoredRGB('{fffafa}Нанесенный урон:')
					for k, v in ipairs(dinf[2].id) do if v ~= -1 then imgui.TextColoredRGB('{' .. dinf[2].clist[k] .. '}' .. dinf[2].nick[k] .. '[' .. v .. '] {fffafa}- ' .. dinf[2].weapon[k] .. ' +' .. dinf[2].damage[k] .. '' .. (dinf[2].kill[k] and "{FF0000} +KILL" or "") .. '') end end
					s_coord["s_dam"] = imgui.GetWindowPos()
					imgui.PopFont()
					imgui.End()

					if not SetMode then	imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_dam2X, config_ini.ovCoords.show_dam2Y)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_dam2X, config_ini.ovCoords.show_dam2Y))	end end
					imgui.Begin('#empty_field42', show.show_dam, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.exFontsquad)
					imgui.TextColoredRGB('{fffafa}Полученный урон:')
					for k, v in ipairs(dinf[1].id) do if v ~= -1 then imgui.TextColoredRGB('{' .. dinf[1].clist[k] .. '}' .. dinf[1].nick[k] .. '[' .. v .. '] {fffafa}- ' .. dinf[1].weapon[k] .. ' -' .. dinf[1].damage[k] .. '' .. (dinf[1].kill[k] and "{FF0000} -KILL" or "") .. '') end end
					s_coord["s_dam2"] = imgui.GetWindowPos()
					imgui.PopFont()
					imgui.End()
				end

				if config_ini.bools[58] == 1 then
					if not SetMode then	imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_moneyX, config_ini.ovCoords.show_moneyY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_moneyX, config_ini.ovCoords.show_moneyY))	end end
					imgui.Begin("#empty_field44", show.show_fond, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.fontmoney)
					local m1 = tonumber(fond[1])
					local m2 = tonumber(fond[2])
					imgui.TextColoredRGB("{" .. config_ini.fondset[1] .. "}$" .. fond[1] .. "")
					imgui.TextColoredRGB(m1 == nil and "{" .. config_ini.fondset[2] .. "}$" .. fond[2] .. "" or "{" .. (m2 - m1 < 0 and "FF0000" or "" .. config_ini.fondset[2] .. "") .. "}$" .. tostring(math.floor(m2)-m1) .. "")
					s_coord["s_money"] = imgui.GetWindowPos()
					imgui.PopFont()
					imgui.End()
				end

				if SetMode then
					if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_vehdamagemX, config_ini.ovCoords.show_vehdamagemY)) end
					imgui.Begin('#empty_field45', show.show_vehdm, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.exFontsquad)
					imgui.TextColoredRGB('{fffafa}NRG-500 - M4 {ff0000}- 120')
					imgui.TextColoredRGB('{fffafa}NRG-500 - Desert Eagle {ff0000}- 280')
					imgui.TextColoredRGB('{fffafa}NRG-500 - SMG {ff0000}- 180')
					s_coord["s_vehdm"] = imgui.GetWindowPos()
					imgui.PopFont()
					imgui.End()

					if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_vehdamagetX, config_ini.ovCoords.show_vehdamagetY)) end
					imgui.Begin('#empty_field46', show.show_vehdt, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.exFontsquad)
					imgui.TextColoredRGB('{fffafa}NRG-500 - M4 {008800}+ 120')
					imgui.TextColoredRGB('{fffafa}NRG-500 - Desert Eagle {008800}+ 280')
					imgui.TextColoredRGB('{fffafa}NRG-500 - SMG {008800}+ 180')
					s_coord["s_vehdt"] = imgui.GetWindowPos()
					imgui.PopFont()
					imgui.End()
				end

				
				if config_ini.bools[64] == 1 then
					if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_panelX, config_ini.ovCoords.show_panelY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_panelX, config_ini.ovCoords.show_panelY)) end end
					imgui.Begin('#empty_field47', show.show_panel, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.exFontl)
					-- защита от ран
					local srpstate = online_ini.tec_info[1] == 0 and 18 or os.time() - online_ini.tec_info[1] > 21600 and 18 or os.time() - online_ini.tec_info[1] > 18000 and 17 or 16
					if not images[srpstate] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\' .. (srpstate == 18 and "zrd" or srpstate == 17 and "zyl" or srpstate == 16 and "zgr" or "ze") .. '.png') then images[srpstate] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\' .. (srpstate == 18 and "zrd" or srpstate == 17 and "zyl" or srpstate == 16 and "zgr" or "ze") .. '.png') end end
					imgui.Image(images[srpstate], imgui.ImVec2(32, 32))--imgui.NewLine()
					-- ремка
					local rktstate = online_ini.tec_info[2] == 0 and 24 or 23
					if not images[rktstate] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\' .. (rktstate == 23 and "kgr" or "krd") .. '.png') then images[rktstate] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\' .. (rktstate == 23 and "kgr" or "krd") .. '.png') end end
					imgui.SameLine()
					imgui.Image(images[rktstate], imgui.ImVec2(32, 32))--imgui.NewLine()
					-- канистра
					local kstate = online_ini.tec_info[3] == 0 and 20 or 19
					if not images[kstate] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\' .. (kstate == 19 and "gr" or "rd") .. '.png') then images[kstate] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\' .. (kstate == 19 and "gr" or "rd") .. '.png') end end
					imgui.SameLine()
					imgui.Image(images[kstate], imgui.ImVec2(32, 32))--imgui.NewLine()
					-- зажатие клавиши
					if needtohold then
						if not images[21] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\aut.png') then images[21] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\aut.png') end end
						imgui.SameLine()
						imgui.Image(images[21], imgui.ImVec2(32, 32))--imgui.NewLine()
					end
					-- синхра скорости
					if spsyns.mode then
						if not images[25] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\sync.png') then images[25] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\sync.png') end end
						imgui.SameLine()
						imgui.Image(images[25], imgui.ImVec2(32, 32))--imgui.NewLine()
					end
					-- сирена
					if isCharInAnyCar(PLAYER_PED) and isCarSirenOn(storeCarCharIsInNoSave(PLAYER_PED)) then
						if not images[22] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\syr.png') then images[22] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\syr.png') end end
						imgui.SameLine()
						imgui.Image(images[22], imgui.ImVec2(32, 32))--imgui.NewLine()
					end
					-- нарко
					if online_ini.tec_info[4] == 1 then 
						if not images[26] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\narko.png') then images[26] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\narko.png') end end
						imgui.SameLine()
						imgui.Image(images[26], imgui.ImVec2(32, 32))--imgui.NewLine()
					end
					-- маты
					if online_ini.tec_info[5] == 1 then 
						if not images[27] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\mat.png') then images[27] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\mat.png') end end
						imgui.SameLine()
						imgui.Image(images[27], imgui.ImVec2(32, 32))--imgui.NewLine()
					end
					-- ключи
					if online_ini.tec_info[6] == 1 then 
						if not images[28] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\key.png') then images[28] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\key.png') end end
						imgui.SameLine()
						imgui.Image(images[28], imgui.ImVec2(32, 32))--imgui.NewLine()
					end
					-- взлом
					if online_ini.tec_info[7] == 1 then 
						if not images[29] then if doesFileExist(getWorkingDirectory() .. '\\Pictures\\nvz.png') then images[29] = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Pictures\\nvz.png') end end
						imgui.SameLine()
						imgui.Image(images[29], imgui.ImVec2(32, 32))--imgui.NewLine()
					end
					s_coord["s_panel"] = imgui.GetWindowPos()
					imgui.PopFont()
					imgui.End()
				end
				SetModeFirstShow = false
		--end
end

function targetinfo()
	local SetModeCond = SetMode and 0 or 4
	local crsX, crsY, crsZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
	local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
	local camX, camY, camZ = getActiveCameraCoordinates()
	local result, colpoint = processLineOfSight(camX, camY, camZ, crsX, crsY, crsZ, true, true, true, true, false, false, true, true)
	local hcar
	if result or SetMode then -- информация о машине в прицеле
		if not SetMode then
			if colpoint.entityType == 2 and doesVehicleExist(getVehiclePointerHandle(colpoint.entity)) then -- отображение о машине в прицеле
				hcar = getVehiclePointerHandle(colpoint.entity)
			else -- поиск машины вокруг прицела
				local car_cx = representIntAsFloat(readMemory(0xB6EC10, 4, false))
				local car_cy = representIntAsFloat(readMemory(0xB6EC14, 4, false))
				local car_w, car_h = getScreenResolution()
				local car_xc, car_yc = car_w * car_cy, car_h * car_cx

				local minDist = ((car_w / 2) / getCameraFov()) * 10
				local closestCarId, closestCarhandle = -1, -1
				local carhandles = getcars()
				if carhandles ~= nil then
					for k, v in pairs(carhandles) do
						if doesVehicleExist(v) and isCarOnScreen(v) then
							local idcar = getCarModel(v)
							local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
							local cX, cY, cZ = getCarCoordinates(v)
							local distanse = math.ceil(math.sqrt( ((myX-cX)^2) + ((myY-cY)^2) + ((myZ-cZ)^2)))
							if distanse < 300 then
								local car_xi, car_yi = convert3DCoordsToScreen(cX, cY, cZ)
								local dist = math.sqrt( (car_xi - car_xc) ^ 2 + (car_yi - car_yc) ^ 2 )
								if dist < minDist then
									minDist = dist		
									if isLineOfSightClear(myX, myY, myZ, cX, cY, cZ, true, false, false, true, false) then hcar = v	break end
								end
							end
						end
					end
				end
			end
								
			if hcar ~= nil then -- если машина найдена
				local carX, carY, carZ = getCarCoordinates(hcar)
				local cardist = math.ceil(math.sqrt( ((myX-carX)^2) + ((myY-carY)^2) + ((myZ-carZ)^2)))
				local cidcar = getCarModel(hcar)
				local ccHP = getCarHealth(hcar)
				local ccol = ccHP > 800 and "00FF00" or ccHP > 500 and "FFFF00" or "FF0000"
				local doorStatus = getCarDoorLockStatus(hcar) == 2 and "{ff0000}Закрыто" or "{00ff00}Открыто"
				local tirestatus = vehtypes.motos[cidcar] ~= nil and isCarTireBurst(hcar, 1) and "; {FF0000}Пробито заднее колесо" or ""
				local cresult2, cid = sampGetVehicleIdByCarHandle(hcar)
				local dist = getshotdist(hcar)	

				if cIDs[cid] ~= nil then
					fcar = cIDs[cid]
				else
					fcar =  "CID: " .. cid .. ""
					if cid < 0 and carsident[cid] == nil then
						sampAddChatMessage("{FF0000}[LUA]: {fffafa}Обнаружен неизвестный транспорт. Приметы транспорта были получены.", 0xFFFF0000)
						sampAddChatMessage("{FF0000}[LUA]: {fffafa}Для помощи в установке принадлежности траспорта к определенной фракции введите команду /cars", 0xFFFF0000)
						local driver = getDriverOfCar(hcar)
						local result, id = sampGetPlayerIdByCharHandle(driver)
						local drivername = result and sampGetPlayerNickname(id) or "0"
						table.insert(carsident, cid, {time = os.date("%X"), namecar = tVehicleNames[cidcar-399], drivername = drivername})
					end
				end	

				if cresult2 then
					lastcarhandle = hcar
					imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.crosCarX, config_ini.ovCoords.crosCarY))
					imgui.Begin('#empty_field16', show.show_target, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.exFontl)
					--imgui.TextColoredRGB("{FFFAFA}Имя: " .. tVehicleNames[cidcar-399] .. "[" .. cidcar .. "]; Здоровье: {" .. ccol .. "}" .. ccHP .. "; {FFFAFA}" .. fcar .. "")
					imgui.TextColoredRGB("{FFFAFA}Имя: " .. tVehicleNames[cidcar-399] .. "[" .. cidcar .. "]; {FFFAFA}" .. fcar .. "")
					imgui.TextColoredRGB("" .. dist .. " м. " .. tirestatus .. "")
					s_coord["s_targetCar"] = imgui.GetWindowPos()
					imgui.PopFont()
					imgui.End()
				else
					lastcarhandle = nil
				end
			end
		else
			if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.crosCarX, config_ini.ovCoords.crosCarY)) end
			imgui.Begin('#empty_field16', show.show_target, 1 + 32 + 2 + SetModeCond + 64)
			imgui.PushFont(imfonts.exFontl)
			imgui.TextColoredRGB("{FFFAFA}Имя: NRG-500[522]; {fffafa}Армия ЛВ")
			s_coord["s_targetCar"] = imgui.GetWindowPos()
			imgui.PopFont()
			imgui.End()
		end

		target.suct = false
		local tped
		if SetMode then target.suct = true goto t_done end

		if colpoint.entityType == 3 and doesCharExist(getCharPointerHandle(colpoint.entity)) then
			tped = getCharPointerHandle(colpoint.entity)
			if tped ~= PLAYER_PED then
				target.id = select(2, sampGetPlayerIdByCharHandle(tped))
				target.time = os.clock()
				target.suct = true
			end
		else
			if target.id == 1000 then goto t_done end
			if target.time + 1.5 < os.clock() then goto t_done end

			local res, tar = sampGetCharHandleBySampPlayerId(target.id)
			if not res then goto t_done end

			local tX, tY, tZ = getCharCoordinates(tar)
			local result2, colpoint2 = processLineOfSight(camX, camY, camZ, tX, tY, tZ, true, true, true, true, true, true, true, true)
			if not result2 or colpoint2.entityType ~= 3 then goto t_done end
									
			local ped = getCharPointerHandle(colpoint2.entity)
			if not doesCharExist(ped) or ped ~= tar then goto t_done end
										
			target.suct = true 
			tped = tar
		end

		::t_done::
		if not target.suct then
			target.id = 1000 
			target.time = 0
		end

		if target.suct then
			local result, id
			if not SetMode then result, id = sampGetPlayerIdByCharHandle(tped) else result = true end
			if result and id ~= select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then -- проверить, прошло ли получение ида успешно
				lastTargetID = id
				local curdistanse, weapdist
				if not SetMode then
					mwID = tonumber(getCurrentCharWeapon(PLAYER_PED))
					local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
					local tX, tY, tZ = getCharCoordinates(tped)
					curdistanse = math.ceil(math.sqrt( ((myX-tX)^2) + ((myY-tY)^2) + ((myZ-tZ)^2)))
					weapdist = tweapondist[mwID] ~= nil and tweapondist[mwID] or 0
				else
					curdistanse, weapdist = 92, 50
				end

				local X, Y = convertGameScreenCoordsToWindowScreenCoords(342.0, 182.0)
				local color = curdistanse <= weapdist and 0xFF00e115 or 0xFFff0000
				renderFontDrawText(dx9font, "(" .. curdistanse .. "/" .. weapdist .. ")", X, Y, color)
			end
		end
	end
end

function onScriptTerminate(s, bool)
	if s == thisScript() and not bool then
		print("#PathForReload " .. thisScript().path .. " @#")
		for i = 0, 1000 do if sampIs3dTextDefined(2048 - i) then sampDestroy3dText(2048 - i) end end
		if not isobnova then sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Скрипт сломался. Найдите сообщение об ошибке и сообщите разработчику. Нажмите CTRL + R для перезапуска.", 0xFFFF0000) end
	end
	
end

function onWindowMessage(msg, wparam, lparam)
	if (show.show_mem1.v or show.show_otm.v or show.show_lek.v) and (msg == 0x100 or msg == 0x101) and wparam == vkeys.VK_ESCAPE then consumeWindowMessage(true, false) if(msg == 0x101) then show.show_lek.v = false show.show_mem1.v = false show.show_otm.v = false end end

	if lparam == 0xFFF and waitforsave then
		waitforsave = false
		local res_log = "" .. getWorkingDirectory() .. "\\POST_response.txt"
		local res = io.open(res_log, "r")
		local responsetext = res:read("*a")
		res:close()
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. (responsetext:match("@@.@ Update complete @@..@.@") ~= nil and "Синхронизация конфига с таблицей завершена" or "Не удалось синхронизировать конфиг с таблицей") .. "", 0xffFF0000)
	--	os.remove(res_log)
		os.remove("Moonloader\\run.bat")
	end
end

function ev.onPlayerStreamIn(playerId, team, model, position, rotation, color, fightingStyle)
	local nickname = sampGetPlayerNickname(playerId)
	if config_ini.bools[35] == 1 and offmembers[nickname] ~= nil then
		if sampIs3dTextDefined(2048 - playerId) then sampDestroy3dText(2048 - playerId) end
		local color = (offmembers[nickname] == "Майор" or offmembers[nickname] == "Подполковник" or offmembers[nickname] == "Полковник" or offmembers[nickname] == "Генерал") and 0xFF00BFFF or 0xFFFFFAFA
		sampCreate3dTextEx(2048 - playerId, offmembers[nickname], color, 0, 0, 0.4, 22, false, playerId, -1)
	end
end

function ev.onSendEnterVehicle(vehid, pass)
	if pass then
		local id = getAmmoInCharWeapon(PLAYER_PED, 31) > 0 and 31 or getAmmoInCharWeapon(PLAYER_PED, 30) > 0 and 30 or 0 
		if id ~= 0 then 
			setCurrentCharWeapon(PLAYER_PED, id) 
		else 
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось найти оружие в инвентаре персонажа.") 
		end
	end	

	local res, car = sampGetCarHandleBySampVehicleId(vehid)
	local door = getCarDoorLockStatus(car)
	if res and door == 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Вы пытаетесь сесть в закрытую машину. Действие отменено!", 0xffff0000) taskToggleDuck(PLAYER_PED, false) return false end
end

function ev.onSendVehicleSync(data)
	--print(data)
	if isCharInArea2d(PLAYER_PED, -84, 1606, 464, 2148, false) and data.keysData ~= 0 then
		if data.keysData%2 ~= 0 then data.keysData = data.keysData - 1 return end
	end
end

function ev.onGivePlayerMoney(money)
	fond[2] = tostring(money)
end

function ev.onShowTextDraw(id, data)
	if data.text:find("SQUAD") then
		isauth = true
	end

	if data.text == "kmh" then
		CTaskArr[10][2][1][3] = id + 2
	end

	if data.text:match("FUEL ~w~(%d+)") ~= nil then
		CTaskArr[10][2][1][3] = id
	end

	if id == CTaskArr[10][2][1][3] then
		local f = data.text:match("(%d+)")
		if f ~= nil then
			CTaskArr[10][2][1][1] = f
		end
	end
	--lua: 2066   kmh
	--a: 2068   0

    if config_ini.bools[52] == 1 then
		local n, w, pp, d, k = data.text:match("(.*) %- (.*) ([-+])(%d+)%.%d+(.*)")
		if n ~= nil and data.letterColor == -16777216 then
			--[[ print(data.position.x, data.position.y, data.position.z, data.rotation.x, data.rotation.y, data.rotation.z, id, 
			data.flags,
			data.letterWidth,
			data.letterHeight,
			data.letterColor,
			data.lineWidth,
			data.lineHeight,
			data.boxColor,
			data.shadow,
			data.outline,
			data.backgroundColor,
			data.style,
			data.selectable,
			data.modelId,
			data.zoom,
			data.color,
			data.text) ]]
			local ii = pp == "-" and 1 or 2
			--print(id, data.text)
			if not dinf[ii][1] then dinf[ii][1] = true if ii == 1 then dinf_ini.Settings.dinf1 = 1 end if ii == 2 then dinf_ini.Settings.dinf2 = 1 end goto dd end

			if dinf[ii][1] then if not dinf[ii][2] then dinf[ii][2] = true return end if dinf[ii][2] then dinf[ii][2] = false goto dd	end end

			::dd::
			local playerId = sampGetPlayerIdByNickname(n)
			if playerId == nil then return end

			local clist = string.sub(string.format('%x', sampGetPlayerColor(playerId)), 3)
			clist = clist == "ffff" and "fffafa" or clist
			local needindex = 0

			for k, v in ipairs(dinf[ii].id) do if v == playerId then needindex = k break end end -- если урон был выдан до этого то записываем данные в уже отображаемую строчку
			if needindex == 0 then for k, v in ipairs(dinf[ii].id) do if v == -1 then needindex = k break end end end -- если есть пустая строка - заносим данные туда

			if needindex == 0 then -- если не удалось обнаружить строку куда записывать новый урон то
				dinf[ii].id[1] = dinf[ii].id[2] -- на первую строку переносим данные со второй
				dinf[ii].nick[1] = dinf[ii].nick[2]
				dinf[ii].clist[1] = dinf[ii].clist[2]
				dinf[ii].weapon[1] = dinf[ii].weapon[2]
				dinf[ii].damage[1] = dinf[ii].damage[2]
				dinf[ii].kill[1] = dinf[ii].kill[2]

				dinf[ii].id[2] = dinf[ii].id[3] -- на вторую строку данные с третьей
				dinf[ii].nick[2] = dinf[ii].nick[3]
				dinf[ii].clist[2] = dinf[ii].clist[3]
				dinf[ii].weapon[2] = dinf[ii].weapon[3]
				dinf[ii].damage[2] = dinf[ii].damage[3]
				dinf[ii].kill[2] = dinf[ii].kill[3]

				dinf[ii].id[3] = -1 -- третью строку очищаем
				dinf[ii].nick[3] = ""
				dinf[ii].clist[3] = ""
				dinf[ii].weapon[3] = ""
				dinf[ii].damage[3] = 0
				dinf[ii].kill[3] = false 
				needindex = 3 -- запись будет идти в третью строку
			end

			dinf[ii].id[needindex] = playerId -- записываем данные в строку
			dinf[ii].nick[needindex] = n
			dinf[ii].clist[needindex] = clist
			dinf[ii].weapon[needindex] = w
			dinf[ii].damage[needindex] = d
			dinf[ii].kill[needindex] = (k ~= nil and k:match("KILL") ~= nil) and true or false
			inicfg.save(dinf_ini, "dinf")
		end
	end
end

function ev.onTextDrawSetString(id, text)
	if id == CTaskArr[10][2][1][3] then           
		local f = text:match("(%d+)")
		if f ~= nil then
			CTaskArr[10][2][1][1] = f
		end
	end
end

function ev.onDisplayGameText(style, time, str)
	if config_ini.bools[59] == 1 and str == "~r~Fuel has ended" and style == 4 and time == 3000 then
		sampSendChat("/fillcar")
	end

	if config_ini.bools[43] == 1 and str == "~g~$500" then
		show.show_500.bool500.v = true
		if (os.time() - show.show_500.time500 <= 5) then
			show.show_500.mult500 = show.show_500.mult500 + 1
			show.show_500.time500 = os.time()
			return false
		else
			show.show_500.mult500 = 1
			show.show_500.time500 = os.time()
			return false
		end
	end
end

function onQuitGame()
	-- Сохраняем чатлог
	local arr = {[1] = "Январь", [2] = "Ферваль", [3] = "Март", [4] = "Апрель", [5] = "Май", [6] = "Июнь", [7] = "Июль", [8] = "Август", [9] = "Сентябрь", [10] = "Октябрь", [11] = "Ноябрь", [12] = "Декабрь"}
	local m = arr[tonumber(os.date("%m"):match("0?(%d+)"))]
	local y = os.date("%Y")

	lfs.chdir("" .. getWorkingDirectory() .. "\\Chatlogs")
	if not isDir("" .. getWorkingDirectory() .. "\\Chatlogs\\" .. y .. "") then lfs.mkdir(y) end
	lfs.chdir("" .. getWorkingDirectory() .. "\\Chatlogs\\" .. y .. "")
	if not isDir("" .. getWorkingDirectory() .. "\\Chatlogs\\" .. y .. "\\" .. m .. "") then lfs.mkdir(m) end

	print("Saving chatlog...")
	local path_log = memory.tostring(sampGetBase() + 0x219F88) .. "\\chatlog.txt"
	local saved_log = "" .. getWorkingDirectory() .. "\\Chatlogs\\" .. y .. "\\" .. m .. "\\" .. os.date("%d.%m.%y") .. ".txt"
	local chatlog = io.open(path_log, "r")
	local chatlog_text = chatlog:read("*a")
	chatlog:close()

	local chatlog_new = io.open(saved_log, "a")
	chatlog_new:write("" .. chatlog_text .."\n############################################################################Сессия закончилась в " .. os.date("%d.%m.%y %X") .. "############################################################################\n")
	chatlog_new:close()
	print("Saved.")
end

function ev.onPlayerQuit(id, reason)
	if config_ini.bools[55] == 1 and sampGetCharHandleBySampPlayerId(id) then
		local reasons = {[0] = 'рестарт/краш', [1] = '/q', [2] = 'кик'}
		sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Игрок {008000}" .. sampGetPlayerNickname(id) .. "{FFFAFA}[" .. tostring(id) .. "] вышел с игры. Причина: {FF0000}" .. reasons[reason] .. ".", 0xFFFF0000)
	end

	if sampIs3dTextDefined(2048 - id) then sampDestroy3dText(2048 - id) end
end

function ev.onSendDeathNotification(reason, id)
	if config_ini.bools[53] == 1 and isCharInArea2d(PLAYER_PED, -84, 1606, 464, 2148, false) then BKTimerTickCount = os.time() end
end

function ev.onSendCommand(cmd)
	if 1 == 2 then--if config_ini.bools[56] == 1 then
		if sampIsChatCommandDefined(cmd) then return end
		if not isSending then
			local cmds = {["sms"] = 50, ["t"] = 50, ["pm"] = 50}
			local c, id, text
			local c, text = cmd:match("%/(%w+) (.*)")
			if c == nil then return end
			if cmds[string.rlower(c)] ~= nil then id, text = text:match("(%w+) (.*)") end
			local t = strunsplit(text, cmds[string.rlower(c)] ~= nil and cmds[string.rlower(c)] or 80)
			isSending = true
			lua_thread.create(function() for k, v in ipairs(t) do sampSendChat("/" .. c .. " " .. (id == nil and "" or "" .. id .. " ") .. "" .. v .. "") wait(1300) end isSending = false end)
			return false
		end
	end
end

function ev.onSendChat(text)
	if 1 == 2 then --if config_ini.bools[56] == 1 then
		if not isSending then 
			local t = strunsplit(text, 100)
			isSending = true
			lua_thread.create(function() for k, v in ipairs(t) do sampSendChat(v) wait(1300) end isSending = false end)
			return false
		end
	end
end

function ev.onServerMessage(col, text)

		if col == -926365496 and CTaskArr[10][10] then -- КК ID №15
			local id, txt = text:match("- %a+%_%a+%[(%d+)%]%: (.*)")
			if id ~= nil and (txt:match("спорт") or txt:match("окум") or txt:match("дост")) then CTaskArr[10][10] = false table.insert(CTaskArr[1], 15) table.insert(CTaskArr[2], os.time()) table.insert(CTaskArr[3], id) end
		end

		if col == -1347440641 and text:match("Вы не можете взять больше патронов для этого оружия") ~= nil then return false end

		if col == 162529535 then
			local d = text:match("Выдано%: (.*) %(%d+ .*%)")
			local d2 = text:match("Выдано%: (.*)")
			if d ~= nil then
				if not istakesomeone then istakesomeone = true end
				if d == "Desert Eagle" then isdeagletaken = true return true end
				if d == "Shotgun" then isshotguntaken = true return true end
				if d == "SMG" then issmgtaken = true return true end
				if d == "M4A1" then ism4a1taken = true return true end
				if d == "Rifle" then isrifletaken = true return true end
			end
			
			if d2 ~= nil then
				if not istakesomeone then istakesomeone = true end
				if d2 == "Спец оружие" then ispartaken = true return true end
				if d2 == "Броня" then isarmtaken = true return true end
			end
		end

		if waitforchangeclist and col == -1 and text:match("Цвет выбран") ~= nil then waitforchangeclist = false end

		if col == 1687547391 then	
			local id, nick = text:match("%[(%d+)%] (%a+%_%a+).*")
			if id ~= nil and text:match("%[%d+%] %[(%d+)%] %a+%_%a+	(%W*) %[%d+%](.*)") ~= nil then
				local color = sampGetPlayerColor(id)
				local a, r, g, b = explode_argb(color)
				rCache.smem[tonumber(id)] = {["name"] = nick, ["color"] = join_argb(230.0, r, g, b), ["colorns"] = join_argb(150.0, r, g, b), ["time"] = 0}
				return false
			end		
		end

		if (col == -1347440641 and text:match("Транспорт недоступен%! Принадлежит%: .*") ~= nil) or text:match("У вас нет прав на использование автомобилей офиса%!") ~= nil then
			lua_thread.create( function()
				if isCharInAnyCar(PLAYER_PED) then
					local car = storeCarCharIsInNoSave(PLAYER_PED)
					local carid = getCarModel(car)
					
					if vehtypes.motos[carid] ~= nil and not isCarPassengerSeatFree(car, 0) then
						local passenger = getCharInCarPassengerSeat(car, 0)
						local result, id = sampGetPlayerIdByCharHandle(passenger)
						wait(50)
						if result then sampSendChat("/eject " .. id .. "") end
					end
				end
			end)
		end

		if col == -65281 then
			local nn, nf = text:match('Ваш новый ник %" (%a+)%_(%a+) %"%. Укажите его в клиенте SA%-MP%, в поле %"Name%"')
			if nn ~= nil then
				lua_thread.create(function()
					sampAddChatMessage("{ff0000}[LUA-Exchange] ВНИМАНИЕ! {FFFAFA}Обнаружена смена игрового ника.")
					sampAddChatMessage("{ff0000}[LUA-Exchange] {FFFAFA}Скрипт начинает обновление ников в таблице. {FF0000}НЕ ВЫХОДИТЕ ИЗ ИГРЫ!!!")
					local A_Index = 0
					while true do
						if A_Index == 20 then break end
						local text = sampGetChatString(99 - A_Index)
		
						local onn, of = text:match("%a+%_%a+ одобрил%(а%) заявку на смену ника%: (%a+)%_(%a+) %>%> " .. nn .. "%_" .. nf .. "")
						if onn ~= nil then
							local oldnick = access.saccess and "" .. onn .. "_" .. of .. "" or "" .. onn .. " " .. of .. ""
							local newnick = access.saccess and "" .. nn .. "_" .. nf .. "" or "" .. nn .. " " .. nf .. ""
							local u = access.saccess and "AKfycbwBG17iJ1Jpy5Ft9lmACSIZyrOA7QBydzgM1S12jkARF7ddEWA" or "AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc"
							local responsetext = req("https://script.google.com/macros/s/" .. u .. "/exec?do=sets&key=" .. access.key .. "&state=" .. access.state .. "&newnick=" .. newnick .. "&oldnick=" .. oldnick .. "")
							local re1 = regex.new("@@.@ Update complete @@..@.@") --
							local names = re1:match(responsetext)
							if names == nil then sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}Не удалось обновить ник в таблице отряда.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}Обновил ник в таблице отряда.", 0xffff0000) end 
							sampAddChatMessage("{ff0000}[LUA-Exchange] {FFFAFA}Можно выходить из игры.")
							return 
						end
						A_Index = A_Index + 1
					end
				end)
				return false
			end
		end


		if (col == -1 and text:match("Вы будете защищены от ран и переломов на 6 часов") ~= nil) or (text:match("%[Quest%]") ~= nil and text:match("Защита от ран и переломов") ~= nil) then
			online_ini.tec_info[1] = os.time()
		end

		if col == 1687547391 then
			if text:match("Вы купили канистру с 50 литрами бензина за .* вирт") then online_ini.tec_info[3] = 1 end
			if text:match("Вы дозаправили свою машину на 50") then online_ini.tec_info[3] = 0 end
		end

		local kol = text:match("Двигатель отремонтирован%. У вас осталось (%d+)%/%d+ комплектов %«автомеханик%»")
		if kol ~= nil then online_ini.tec_info[2] = tonumber(kol) end

		if text:match("У вас нет комплекта %«автомеханик%» для ремонта") then online_ini.tec_info[2] = 0 end

		local kol = text:match("Комплект %«автомеханик%» приобретен%. Осталось%: (%d+)%/%d+")
		if kol ~= nil then online_ini.tec_info[2] = tonumber(kol) end

		--- контекстная клавиша
		if text:match("Для восстановления доступа нажмите клавишу %'F6%' и введите %'%/restoreAccess%'") ~= nil then -- поиск входа в игру
			CTaskArr[10][4], CTaskArr[10][10] = true, true
		end

		local s, sk = text:match("На складе (.*)%: (%d%d%d)%d%d%d%/%d+")
		if s ~= nil and s ~= "Army LV" then
			table.insert(CTaskArr[1], 7)
			table.insert(CTaskArr[2], os.time())
			table.insert(CTaskArr[3], s)
			CTaskArr[10][3] = sk
		end

		if (text:match("Двигатель отремонтирован%. У вас осталось %d+%/%d+ комплектов %«автомеханик%»") or text:match("У вас нет комплекта %«автомеханик%» для ремонта") ~= nil or text:match("В транспортном средстве нельзя") ~= nil or text:match("Вы далеко от транспортного средства%. Подойдите к капоту") ~= nil) and CTaskArr[10][5] then CTaskArr[10][5] = false end
		---[16:57:04]  Материалов: 10000/10000 -- загрузка на ГС
		---[16:57:04]  На главном складе: 434418/500000

		---[17:02:42]  Материалов: 0/10000 -- разгрузка на фракции
		---[17:02:42]  На складе Army SF: 219080/300000

		---[17:06:06]  Материалов: 0/10000 -- разгрузка на ГС
		---[17:06:06]  На складе Army LV: 366329/500000
		if issquadactive[2] then -- передача денег через сквад
			if col == -1 and text == " Операция выполнена" then issquadactive[2] = false end
			if col == -1613968897 then local m = text:match("На балансе (%d+) вирт") if m ~= nil then issquadactive[2] = false issquadactive[3] = tonumber(m) end end
		end

		local date = text:match("Домашний счёт оплачен до (.*)") -- варнинг на слёт дома
		if date ~= nil then
			local datetime = {}
			datetime.year, datetime.month, datetime.day = string.match(date,"(%d%d%d%d)%/(%d%d)%/(%d%d)")
			if math.floor((os.difftime(os.time(datetime), os.time())) / 3600 / 24) <= 7 then sampAddChatMessage("{FF0000}[LUA]: ВНИМАНИЕ!{FFFAFA} До слета дома осталось меньше недели.", 0xffff0000) end
		end

		if not show.othervars.saccess then
			local rank = tonumber(text:match(" %a+%_%a+ повысил%/понизил ваc до (%d+) ранга")) -- автоматическое изменение звания в таблице
			if rank ~= nil then
				lua_thread.create(function()
					local arr = {[1] = "Рядовой", [2] = "Ефрейтор", [3] = "Мл. Сержант", [4] = "Сержант", [5] = "Ст. Сержант", [6] = "Старшина", [7] = "Прапорщик", [8] = "Мл. Лейтенант", [9] = "Лейтенант", [10] = "Ст. Лейтенант", [11] = "Капитан", [12] = "Майор", [13] = "Подполковник", [14] = "Полковник"}
					if arr[rank] == nil then sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}Не удалось обновить звание в таблице отряда.", 0xffff0000) return end
					local url = 'https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=sets&key=' .. access.key .. '&rank=' .. translit(arr[rank]) .. '&state=' .. access.state .. ''

					local responsetext = req(url)
					local re1 = regex.new("@@.@ Update complete @@..@.@") --
					local names = re1:match(responsetext)
					if names == nil then sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}Не удалось обновить звание в таблице отряда.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}Обновил звание в таблице отряда.", 0xffff0000) end 
					return 
				end)
			end

			local re1 = regex.new('([A-Za-z]+\\_[A-Za-z]+) передала? именной тёмно\\-красный берет \\"С\\.О\\.П\\.Т\\.\\" бойцу ([A-Za-z]+) ([A-Za-z]+)') -- автоматическое изменение статуса в таблице
			local f, s1, s2 = re1:match(text)
			if s1 ~= nil then
				lua_thread.create(function()
					local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
					local nick = sampGetPlayerNickname(myid)
					if nick == "" .. s1 .. "_" .. s2 .. "" and indexof(f, stroyarr.soptlist.ruk) then
						sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}Обновляю статус отыгровки берета...", 0xffff0000)
						local responsetext = req('https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=authnew&nick=' .. f .. '%20' .. s .. '') -- через таблицу СОПТ
						local re0 = regex.new("\\@\\@\\.\\@ (.*) \\@\\@\\.\\.\\@\\.\\@") --
						local access
						access = tonumber(re0:match(responsetext))
						if access == nil then sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}Неизвестная ошибка при обновлении статуса.", 0xffff0000) return end

						config_ini.UserClist[12] = access == 0 and "кевларовую каску \"С.О.П.Т.\"" or access ~= 6 and "именной темно-красный берет \"С.О.П.Т.\"" or "именной темно-красный берет почетного бойца \"С.О.П.Т.\""
						PlayerU = access == 0 and "Стажер С.О.П.Т." or access == 1 and "Тренер С.О.П.Т." or access == 2 and "Заместитель командира С.О.П.Т." or access == 3 and "Командир С.О.П.Т." or access == 4 and "Куратор С.О.П.Т." or access == 5 and "Боец С.О.П.Т." or (lvl == 1 and "Тренер С.О.П.Т." or lvl == 2 and "Заместитель командира С.О.П.Т." or lvl == 3 and "Командир С.О.П.Т." or lvl == 4 and "Куратор С.О.П.Т." or "Боец С.О.П.Т")
						tag = "|| С.О.П.Т. || "
						useclist = "12"
						sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}Статус отыгровки берета успешно обновлен.", 0xffff0000)
					end
				end)
			end
		end
		
		if config_ini.bools[48] == 1 then
			local m = text:match("Материалов: (%d+)/10000")
			if m ~= nil then skipd[3][4] = tonumber(m) return end

			if skipd[3][5] then -- /mon
				local re0 = regex.new("(ЛСПД|ЛВПД|СФПД|ФБР|Армии СФ) ([0-9]+)/[0-9]+") --
				local fr, sk = re0:match(text)
				if fr ~= nil then
					local tarr = {["ЛСПД"] = "LSPD", ["ЛВПД"] = "LVPD", ["СФПД"] = "SFPD", ["ФБР"] = "FBI", ["Армии СФ"] = "SFA",}
					skipd[3][6][tarr[fr]] = math.floor(tonumber(sk)/1000)
					if tarr[fr] ~= "SFA" then return false end
					--ЛСПД - 102 | СФПД - 110 | ЛВПД - 112 | ФБР - 130 | СФа - 235
					lua_thread.create(function() wait(600) sampSendChat("/f " .. tag .. "ЛСПД - " .. skipd[3][6].LSPD .. " | СФПД - " .. skipd[3][6].SFPD .. " | ЛВПД - " .. skipd[3][6].LVPD .. " | ФБР - " .. skipd[3][6].FBI .. " | СФа - " .. skipd[3][6].SFA .. "") end)
					skipd[3][5] = false
					return false
				end
			end
		end

		if config_ini.bools[50] == 1 then -- поиск затрат ремок и защит
			if text:match("Магазин не работает") or text:match("У вас недостаточно денег%!") then skipd[3][2] = 3 return end
		--	if text == " У вас уже максимум комплектов" then skipd[3][2] = 1 return end
			if text == " У вас нет места" and skipd[3][2] == 0 then skipd[3][2] = 1 return end
			if text == " У вас нет места" and skipd[3][2] == 1 then skipd[3][2] = 2 return end
			if text:match(" Вас хотел%(а%) изнасиловать (.*)%. Вы использовали защиту") or text:match("Двигатель отремонтирован%. У вас осталось %d+%/%d+ комплектов %«автомеханик%»") and skipd[3][2] == 2 then skipd[3][2] = 0 end
		end

		if config_ini.bools[51] == 1 then -- автоприем механиком
			if text:match("Механик .* хочет отремонтировать ваш автомобиль за %d+ вирт.*") then show.vehinformer.carhp = getCarHealth(storeCarCharIsInNoSave(PLAYER_PED)) sampSendChat("/ac repair") return end
			local cost = tonumber(text:match("Механик .* хочет заправить ваш автомобиль за (%d+) вирт.*"))
			if cost ~= nil then
				local ncost = tonumber(config_ini.dial[3])
				if ncost ~= nil and cost <= ncost then lua_thread.create(function() wait(600) sampSendChat("/ac refill") end) return end
			end
		end

		if config_ini.bools[63] == 1 then
			local nick = text:match("Вашу машину отремонтировал%(а%) за %d+ вирт%, Механик (.*)") 
        	if nick then
				table.insert(show.vehinformer[1], {["tid"] = 1001, ["d"] = 0, ["wid"] = 31, ["car"] = "car", ["time"] = os.time()})
				lua_thread.create(function()
					local fid = 1001
					local index = 1
					local nickname = nick
					local id = sampGetPlayerIdByNickname(nickname)
					local cl = "fffafa"
                    if id ~= nil then cl = string.sub(string.format('%x', sampGetPlayerColor(id)), 3) cl = cl == "ffff" and "fffafa" or cl end

					while true do
						wait(0)
						local k = findindex(fid, index)
						if k == 0 then show.vehinformer.carhp = 0 return end
						local time = show.vehinformer[index][k]["time"]

						if os.time() - time >= 3 then
							local kk = findindex(fid, index)
							if kk == 0 then sampAddChatMessage("{FF0000}[LUA]: Произошла ошибка при очистке лога дамаг информера.", 0xffff0000) return end
							table.remove(show.vehinformer[index], kk)
							show.vehinformer.carhp = 0
							return
						end

						local x = config_ini.ovCoords.show_vehdamagemX
						local y = config_ini.ovCoords.show_vehdamagemY + (15 * k)
						renderFontDrawText(dx9font, "{" .. cl .. "}" .. nickname .. "[" .. id .. "] {008800}+ " .. (getCarHealth(storeCarCharIsInNoSave(PLAYER_PED)) - show.vehinformer.carhp) .. "", x, y, 0xfffffafa)
					end
				end)
        	end
		end

		local regexes = {}
		local localvars = {}
		if config_ini.bools[41] == 1 then -- сквад
			local offid = text:match("%[Сообщество%] %a+_%a+%[(%d+)%] %{D95A41%}Отключился")
			local fname, sname, onid = text:match("%[Сообщество%] (%a+)_(%a+)%[(%d+)%] (.*) %{00AB06%}Подключился")
			local connect = text:match("Вы подключились к сообществу")
			local uninv = text:match("%[Сообщество%] %a+%_%a+%[%d+%] %{C42100%}Выгнал%{9FCCC9%} (.*) из сообщества")
			local unme = text:match("%a+%_%a+% выгнал вас из сообщества %'.*%'")
			local disconnect = text:match("Вы отключились от сообщества")
			
			local tag, fsfn, fssn, racid, sq = text:match(" %[(.*)%] %{FFFFFF%}(.*)%_(.*)%[(%d+)%]%: (.*)")
			if unme ~= nil or disconnect ~= nil then rCache = {enable = false, smem = {}} return end
			
			if connect ~= nil then lua_thread.create(function() findsquad() end) end
			
			if uninv ~= nil then
				lua_thread.create(function()
					local id = -1
					for k, v in pairs(rCache.smem) do if v.name == uninv then id = k break end end
					if id ~= -1 then rCache.smem[tonumber(id)] = nil end
				end)
			end
			
			if offid ~= nil then 
				rCache.smem[tonumber(offid)] = nil
			end
		
			if onid ~= nil then
				id = tonumber(onid)
				local color = sampGetPlayerColor(id)
           		local a, r, g, b = explode_argb(color)						
				rCache.smem[id] = {["name"] = "" .. fname .. "_" .. sname .. "", ["color"] = join_argb(230.0, r, g, b), ["colorns"] = join_argb(150.0, r, g, b), ["time"] = 0}
			end
			
			if sq ~= nil then 
				local rrid = tonumber(racid)
				
				if rCache.smem[rrid] == nil then 
					local color = sampGetPlayerColor(id)
					local a, r, g, b = explode_argb(color)
					rCache.smem[rrid] = {["name"] = "" .. fsfn .. "_" .. fssn .. "", ["color"] = join_argb(230.0, r, g, b), ["colorns"] = join_argb(150.0, r, g, b), ["time"] = 0}
				end

				local off1 = sq:match("sq%_message%_id%_1%_(%d+)") -- выход/вход в ГС
				local off2 = sq:match("sq%_message%_id%_2") 
				--local off3ID, off3Act = sq:match("sq%_message%_id%_3%_(%d+)%| (.*)")
				local x, y, z, ttype = sq:match("sq%_message%_id%_4 (.*) (.*) (.*) (.*) end") 
				if off1 ~= nil then	rCache.smem[rrid].time = tonumber(off1) + (3600 * tonumber(config_ini.Settings.timep)) return false end

				if off2 ~= nil then rCache.smem[tonumber(racid)].time = 0 return false end

				if off3ID ~= nil and tostring(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) == off3ID then lua_thread.create(function() wait(300) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Получена команда от " .. fsfn .. "_" .. fssn .. "[" .. racid .. "] - начинаю выполнение...") sampSendChat(off3Act) end) return false end
				
                if x ~= nil then
                    lua_thread.create(function()
                    	local t = os.time()
                        local a_index = 1
                        local bool0 = true
                        local bool = true
                        local marker = 0
                    	while os.time() - t < 10 do
                        	wait(0)
                            local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
                            local distanse = math.ceil(math.sqrt( ((myX-x)^2) + ((myY-y)^2) + ((myZ-z)^2))) -- расстояние между мной и фокусом
                            if distanse < 210 then
                                if bool0 then sampAddChatMessage(" {B30000}[" .. tag .. "] {FFFAFA}" .. fsfn .. "_" .. fssn .. "[" .. racid .. "]: Внимание! Смотрите сюда.", 0xffB30000) bool0 = false end
                                if marker == 0 then marker = addSpriteBlipForCoord(x, y, z, 56) end
                                local camX, camY, camZ = getActiveCameraCoordinates()
                                local res, col = processLineOfSight(camX, camY, camZ, x, y, z, true, true, true, true, true, true, true, true)

                                -- ttype: 1 - человек, 2 - машина, 3 - мотоцикл, 4 - фривей, 5 - матовоз, 6 - вертолет, 50 - местность
								-- (300 + ttype) * 1 (прямая видимость) или 2 (за преграддой) - указатель на фокус по ID указателя и статусу видимости
								local vst = ttype == 50 and (not res and 1 or 2) or 1
								local ind = (300 + ttype) * vst
                                if not images[ind] then images[ind] = renderLoadTextureFromFile(getWorkingDirectory() .. '\\Pictures\\qicons\\' .. ttype .. '_' .. vst .. '.png') end
                                                
								if not images[33] then images[33] = renderLoadTextureFromFile(getWorkingDirectory() .. '\\Pictures\\qicons\\atb.png') end -- анимация

                                if isPointOnScreen(x, y, z, 10) then
                                    local cPosX, cPosY = convert3DCoordsToScreen(x, y, z) -- переводим 3Д координаты мира в координаты на экране
                                    renderDrawTexture(images[ind], cPosX - 12, cPosY - 12, 24, 24, 0, 0xFFFFFAFA)

                                    if bool then-- анимация
                                        local rx = 512 - (4 * a_index)
                                        local ry = 512 - (4 * a_index)
                                        if rx == 32 then bool = false end
                                        renderDrawTexture(images[33], cPosX - rx/2, cPosY - ry/2, rx, ry, 0, 0xFFFFFAFA)
                                        a_index = a_index + 1
                                    end
								else
									local heading = math.atan2(x - myX, y - myY)
									local camera_heading = representIntAsFloat(readMemory(0xB6F258, 4, false)) * 180 / math.pi + 90
									local angle = 180 + math.fmod(camera_heading + heading * 180 / math.pi - 180, 360)
									local sw, sh = getScreenResolution()
									local ind = (not res) and 34 or 35
									if not images[ind] then images[ind] = renderLoadTextureFromFile(getWorkingDirectory() .. '\\Pictures\\qicons\\ati_' .. vst .. '.png') end -- направление
									renderDrawTexture(images[ind], (sw / 2) - 350, (sh / 2) - 350, 700, 700, angle, 0xFFFFFAFA)
								end
                             end
                        end

                        removeBlip(marker)
                    end)

                	return false 
                end

				sampAddChatMessage(" {B30000}[" .. tag .. "] {FFFAFA}" .. fsfn .. "_" .. fssn .. "[" .. racid .. "]: " .. sq .. "", 0xffB30000)
				return false
			end
		end
			
		local re0 = regex.new("(Рядовой|Ефрейтор|Мл.сержант|Сержант|Ст.сержант|Старшина|Прапорщик|Мл.Лейтенант|Лейтенант|Ст.Лейтенант|Капитан|Майор|Подполковник|Полковник|Генерал)  (.*)\\_(.*)\\[([0-9]+)\\]\\: (.*)") --
		local z, fn, sn, id, txt = re0:match(text)
		if txt ~= nil and col == -1920073729 then
			if config_ini.bools[35] == 1 then
				if offmembers["" .. fn .. "_" .. sn .. ""] ~= z then
					sampDestroy3dText(2048 - tonumber(id))
					offmembers["" .. fn .. "_" .. sn .. ""] = z
					sampCreate3dTextEx(2048 - tonumber(id), offmembers["" .. fn .. "_" .. sn .. ""], 0xffFFFAFA, 0, 0, 0.4, 22, false, tonumber(id), -1)
				end
			end

			if not stroyarr.stroycreator then
				local re1 = regex.new("С.О.П.Т., построение у кабинета!") -- Поиск СОСа
				if re1:match(txt) then stroyarr.stroymode, stroyarr.stroystate, stroyarr.creator.id, stroyarr.creator.zv = true, 0, tonumber(id), indexof(z, ranksnames) end
			end
				
			if not stroyarr.stroymode then
				local kv = ""
				local re1 = regex.new("([А-Яа-я]ребуется подкреплени[А-Яа-я]|[S|s|C|c|С|с][O|o|О|о][S|s|C|c|С|с])\\s?.*?\\s([А-Яа-яA-Za-z][-| |]?\\d{1,2})") -- Поиск СОСа (СОС, требуется подкрепление)
				local _, a = re1:match(txt)
				if a ~= nil then kv = a end

				if kv == "" then
					local re1 = regex.new("([А-Яа-я]ребуется подкреплени[А-Яа-я]|[S|s|C|c|С|с][O|o|О|о][S|s|C|c|С|с]) ([А-Яа-я]+)") -- Поиск места 
					local _, a2 = re1:match(txt)
					if a2 ~= nil then kv = a2 end
				end

				if kv ~= "" then
					local res, h = sampGetCharHandleBySampPlayerId(tonumber(id))
					CTaskArr[10][7] = res and h or -1
					table.insert(CTaskArr[1], 1)
					table.insert(CTaskArr[2], os.time())
					table.insert(CTaskArr[3], kv)
				end

				local re2 = regex.new("[Э|э]вакуаци[А-Яа-я].*([A-ZА-Яа-яa-z]+\\s?-?[0-9]+)(\\s?)") -- Поиск эвакуации
				local _1, _2, _3, kv = re2:match(txt)
				if kv ~= nil then
					table.insert(CTaskArr[1], 2)
					table.insert(CTaskArr[2], os.time())
					table.insert(CTaskArr[3], kv)
				end

				local pr = txt:match("Принято%, (.*)%!")
				if isCharInAnyCar(PLAYER_PED) and pr ~= nil then -- если кто-то в машине прожал КК №1 или №2 то отменяем свой КК
					local car = storeCarCharIsInNoSave(PLAYER_PED)
					local driver = getDriverOfCar(car)
					if driver == PLAYER_PED then end
					local result, id = sampGetPlayerIdByCharHandle(driver)
					if not result then end
	
					local bool = false
					local nick = sampGetPlayerNickname(id)
					if (nick == "" .. fn .. "_" .. sn .. "") then
						for k, v in ipairs(CTaskArr[1]) do if v == 1 or v == 2 and CTaskArr[3][k] == pr then CTaskArr[2][k] = os.time() - 100 return end end
					end
	
					if not bool then 
						if getMaximumNumberOfPassengers(car) > 0 then
							for i = 0, getMaximumNumberOfPassengers(car) - 1 do
								if not isCarPassengerSeatFree(car, i) then
									local passenger = getCharInCarPassengerSeat(car, i)
									local result, id = sampGetPlayerIdByCharHandle(passenger)
									if result then
										local nick = sampGetPlayerNickname(id)
										if (nick == "" .. fn .. "_" .. sn .. "") then
											for k, v in ipairs(CTaskArr[1]) do if v == 1 or v == 2 and CTaskArr[3][k] == pr then CTaskArr[2][k] = os.time() - 100 return end end
										end
									end
								end
							end
						end
					end
				end

				
				if txt:match("ыезжает ВМО") ~= nil then -- поиск сообщения о выезде колонны (для КК№4)
					local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
					local distanse = math.ceil(math.sqrt( ((myX-344.46917724609)^2) + ((myY-1798.794921875)^2) + ((myZ-18.379627227783)^2)))
					local idc = isCharInAnyCar(PLAYER_PED) and getCarModel(storeCarCharIsInNoSave(PLAYER_PED)) or -1
					if distanse < 500 and idc ~= 433 then
						lua_thread.create(function() 
							local A_Index = 0
							while true do
								if A_Index == 20 then break end
								local text = sampGetChatString(99 - A_Index)
				
								local re1 = regex.new("[А-Яа-я]+(езж|еха|двинул|де)[А-Яа-я].*((([А-Яа-я]олици[А-Яа-я]|(P|p|Р|р)olise)\\s?)?((Л|л|L|l|C|c|С|с)(C|c|С|с|S|s|В|в|V|v)|(C|c|С|с|s|S)(Ф|ф|F|f))|(F|f|Ф|ф)(B|b|в|В|Б|б)(I|i|Р|р|И|и)|(S|s|С|с|C|c)(A|a|А|а)(N|n|Н|н|H|h)[\\s,\\-,\\_]?(F|f|Ф|ф)(i|I|и|И)(Е|е|E|e)(P|p|Р|р|r|R)(P|p|Р|р|r|R)?(O|o|о|О)|(L|l|Л|л)(o|O|О|о)(С|с|C|c|S|s)[\\s,\\-,\\_]?(С|с|C|c|S|s)(A|a|А|а)(N|n|Н|н)(t|T|т|Т)(O|o|о|О)(С|с|C|c|S|s)|(L|l|Л|л)(A|a|А|а)(S|s|С|с|C|c)[\\s,\\-,\\_]?(V|v|в|В|b|B)(Е|е|E|e)(N|n|Н|н)(t|T|т|Т)(U|u|У|у|Y|y)(P|p|Р|р|r|R)(A|a|А|а)(S|s|С|с|C|c))")
								local _, p = re1:match(text)
								if p ~= nil then
									local reLS = regex.new("(((([А-Яа-я]олици[А-Яа-я]|(P|p|Р|р)olise)\\s?)?((Л|л|L|l)(C|c|С|с|S|s)))|(L|l|Л|л)(o|O|О|о)(С|с|C|c|S|s)[\\s,\\-,\\_]?(С|с|C|c|S|s)(A|a|А|а)(N|n|Н|н)(t|T|т|Т)(O|o|о|О)(С|с|C|c|S|s))")
									local reSF = regex.new("(((([А-Яа-я]олици[А-Яа-я]|(P|p|Р|р)olise)\\s?)?((C|c|С|с|s|S)(Ф|ф|F|f)))|(F|f|Ф|ф)(B|b|в|В|Б|б)(I|i|Р|р|И|и)|(S|s|С|с|C|c)(A|a|А|а)(N|n|Н|н|H|h)[\\s,\\-,\\_]?(F|f|Ф|ф)(i|I|и|И)(Е|е|E|e)(P|p|Р|р|r|R)(P|p|Р|р|r|R)?(O|o|о|О))")
									local reLV = regex.new("(((([А-Яа-я]олици[А-Яа-я]|(P|p|Р|р)olise)\\s?)?((Л|л|L|l)(В|в|V|v)))|(L|l|Л|л)(A|a|А|а)(S|s|С|с|C|c)[\\s,\\-,\\_]?(V|v|в|В|b|B)(Е|е|E|e)(N|n|Н|н)(t|T|т|Т)(U|u|У|у|Y|y)(P|p|Р|р|r|R)(A|a|А|а)(S|s|С|с|C|c))")
									local pp = reLS:match(p) ~= nil and "до г. Los-Santos" or reSF:match(p) ~= nil and "до г. San-Fierro" or reLV:match(p) ~= nil and "до г. Las-Venturas" or ""
									table.insert(CTaskArr[1], 4)
									table.insert(CTaskArr[2], os.time())
									table.insert(CTaskArr[3], pp)
									return 
								end
								A_Index = A_Index + 1
							end
						end)
					end
				end

				if isCharInAnyCar(PLAYER_PED) and txt:match("Выехали в сопровождение ВМО") ~= nil then -- если кто-то в машине прожал КК№4 то отменяем свой КК
					local car = storeCarCharIsInNoSave(PLAYER_PED)
					local driver = getDriverOfCar(car)
					if driver == PLAYER_PED then end
					local result, id = sampGetPlayerIdByCharHandle(driver)
					if not result then end
	
					local bool = false
					local nick = sampGetPlayerNickname(id)
					if (nick == "" .. fn .. "_" .. sn .. "") then
						local key = indexof(4, CTaskArr[1])
						if key ~= false then CTaskArr[2][key] = os.time() - 100 end
						bool = true
					end
	
					if not bool then 
						if getMaximumNumberOfPassengers(car) > 0 then
							for i = 0, getMaximumNumberOfPassengers(car) - 1 do
								if not isCarPassengerSeatFree(car, i) then
									local passenger = getCharInCarPassengerSeat(car, i)
									local result, id = sampGetPlayerIdByCharHandle(passenger)
									if result then
										local nick = sampGetPlayerNickname(id)
										if (nick == "" .. fn .. "_" .. sn .. "") then
											local key = indexof(4, CTaskArr[1])
											if key ~= false then CTaskArr[2][key] = os.time() - 100 end
											break
										end
									end
								end
							end
						end
					end
				end

				if txt:match("опр") ~= nil then -- поиск запроса на сопр (для КК№14)
					local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
					local distanse = math.ceil(math.sqrt( ((myX-344.46917724609)^2) + ((myY-1798.794921875)^2) + ((myZ-18.379627227783)^2)))
					local re1 = regex.new("([А-Яа-я]апр([А-Яа-я]*)) .*?([С|с]опр[А-Яа-я]*)") --
					if re1:match(txt) and distanse < 500 then
						table.insert(CTaskArr[1], 14)
						table.insert(CTaskArr[2], os.time())
						table.insert(CTaskArr[3], "")
					end
				end

				if isCharInAnyCar(PLAYER_PED) and txt:match("ВМО%, выезжайте%!") ~= nil then -- если кто-то в машине прожал КК№14 то отменяем свой КК
					local car = storeCarCharIsInNoSave(PLAYER_PED)
					local driver = getDriverOfCar(car)
					if driver == PLAYER_PED then end
					local result, id = sampGetPlayerIdByCharHandle(driver)
					if not result then end
	
					local bool = false
					local nick = sampGetPlayerNickname(id)
					if (nick == "" .. fn .. "_" .. sn .. "") then
						local key = indexof(14, CTaskArr[1])
						if key ~= false then CTaskArr[2][key] = os.time() - 100 end
						bool = true
					end
	
					if not bool then 
						if getMaximumNumberOfPassengers(car) > 0 then
							for i = 0, getMaximumNumberOfPassengers(car) - 1 do
								if not isCarPassengerSeatFree(car, i) then
									local passenger = getCharInCarPassengerSeat(car, i)
									local result, id = sampGetPlayerIdByCharHandle(passenger)
									if result then
										local nick = sampGetPlayerNickname(id)
										if (nick == "" .. fn .. "_" .. sn .. "") then
											local key = indexof(14, CTaskArr[1])
											if key ~= false then CTaskArr[2][key] = os.time() - 100 end
											break
										end
									end
								end
							end
						end
					end
				end
			end
			--[[ else
				local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				local mynick = sampGetPlayerNickname(myid)
				local nick = fn .. "_" .. sn
				if ((not stroyarr.stroycreator and id ~= stroyarr.creator.id) or (stroyarr.stroycreator)) and (mynick ~= nick) then
					local re4 = regex.new("\\|\\| С\\.О\\.П\\.Т\\. \\|\\| Принято\\!")
					local res = re4:match(txt)
					if res ~= nil and stroyarr.stroystate < 2 then
						local z_index = indexof(z, ranksnames)
						local id = tonumber(id)
						local tempbool = false
						if indexof(nick, stroyarr.soptlist.ruk) ~= false then tempbool = true insertruk(id, z_index) end
						if indexof(nick, stroyarr.soptlist.osn) ~= false then tempbool = true insertosn(id, z_index) end
						if indexof(nick, stroyarr.soptlist.stj) ~= false then tempbool = true insertstj(id, z_index) end
											
						if tempbool then
							if stroyarr.stroyleader.current == "" or stroyarr.stroyleader.current ~= stroyarr.stroypr.ids[1] then 
								local temp = stroyarr.stroyleader.current ~= "" and stroyarr.stroyleader.current or ""
								local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
								if temp ~= "" then sampAddChatMessage("{FF0000}[LUA]: {fffafa}Место старшего в строю было занято другим игроком.", 0x00FFFAFA) end
													
								stroyarr.stroyleader.current = stroyarr.stroypr.ids[1]
								if stroyarr.stroyleader.current == myid then 
									sampAddChatMessage("{FF0000}[LUA]: {fffafa}Вы были назначены старшим на построении.", 0x00FFFAFA)
									stroyarr.stroystate = 1
								else
									sampAddChatMessage("{FF0000}[LUA]: {fffafa}Игрок " .. sampGetPlayerNickname(stroyarr.stroypr.ids[1]) .. " [" .. tostring(stroyarr.stroypr.ids[1]) .. "] был назначен старшим на построении.", 0x00FFFAFA)
								end
							end
						end
					end
				end
			end ]]

			if config_ini.bools[40] == 1 then -- варнинг на упоминание тебя в рации
				local re3 = regex.new("(" .. config_ini.warnings[1] .. "|" .. config_ini.warnings[2] .. "|" .. config_ini.warnings[3] .. "|" .. config_ini.warnings[4] .. ")")
				local res = re3:match(txt)
				if res ~= nil then sampAddChatMessage("{FF0000}[LUA]: ВНИМАНИЕ! {FFFAFA}" .. z .. " " .. fn .. "_" .. sn .. "[" .. id .. "] упомянул тебя в рации!", 0xFFFF0000) end
			end

			if config_ini.bools[39] == 1 then -- подсветка ника в рации (должна быть самой последней)
				local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
				clist = clist == "ffff" and "fffafa" or clist
				sampAddChatMessage(" {8470FF}" .. z .. " {" .. clist .. "}" .. fn .. "_" .. sn .. "[" .. id .. "]{8470FF}: " .. txt .. "", 0xFF8470FF)
				return false
			end
		end

		if not duel.mode and col == -1029514497 then
			local myid = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
			local myn, myf = sampGetPlayerNickname(myid):match("(.*)%_(.*)")
			local f, n = text:match(" (.*)%_(.*) бросил.? перчатку под ноги " .. myn .. " " .. myf .. "")
			if f == nil then return end
			local nick = "" .. f .. "_" .. n .. ""
			local id = sampGetPlayerIdByNickname(nick)
			if f ~= nil then
				duel.mode = true
				duel.en.id = id
				lua_thread.create(function()
					sampAddChatMessage("{FF0000}[LUA]: {fffafa}" .. nick .. "[" .. id .. "] вызывает вас на дуэль. Нажмите Y для согласия и N для отказа", 0x00FFFAFA)
					while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Предложение отклонено.", 0xFFFF0000) sampSendChat("/me наступил" .. RP .. " на брошенную перчатку") duel.mode = false duel.en = -1 return end end
					if not duel.mode then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Дуэль отменена.", 0xFFFF0000) duel.mode = false duel.en.id = -1 return end

					duel.fightmode = true
					duel.en.hp = sampGetPlayerHealth(id)
					duel.en.arm = sampGetPlayerArmor(id)
					duel.my.hp = sampGetPlayerHealth(myid)
					duel.my.arm = sampGetPlayerArmor(myid)
					local abc = ((duel.en.hp ~= duel.my.hp) or (duel.my.arm ~= duel.en.arm)) and "Неравная дуэль" or "Дуэль"
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Предложение принято. Начинаю отсчёт", 0xFFFF0000)
					sampSendChat("/me поднял" .. RP .. " брошенную перчатку")
					wait(1300)
					sampSendChat("/do *Голос свыше*: \"".. abc .. ": " .. myn .. " " .. myf .. " vs " .. f .. " " .. n .. " начнется через 3!\"")
					math.randomseed(os.time())
					local A_Index = 1

					while true do
						wait(0)
						local myHP = sampGetPlayerHealth(myid)
						local myARM = sampGetPlayerArmor(myid)
						local enHP = sampGetPlayerHealth(id)
						local enARM = sampGetPlayerArmor(id)

						if myHP ~= duel.my.hp or enHP ~= duel.en.hp or myARM ~= duel.my.arm or enARM ~= duel.en.arm then 
							wait(600)
							sampSendChat("/do *Голос свыше*: \"Фальстарт! Дуэль отменена!\"")
							duel.mode = false
							duel.en.id = -1
							duel.fightmode = false
							return
						end

						wait(1000)
						local delay = math.random(1, 3)
						wait(4000 - delay * 1000)
						sampSendChat("/do *Голос свыше*: \"" .. (A_Index == 1 and "2!" or A_Index == 2 and "1!" or "GO!") .. "\"")
						if A_Index == 3 then break end
						A_Index = A_Index + 1
					end

					while true do
						wait(0)
						local myHP = sampGetPlayerHealth(myid)
						local enHP = sampGetPlayerHealth(id)
						if myHP <= 12 or enHP <= 12 then 
							sampSendChat("/do *Голос свыше*: \"".. abc .. " окончена! Победитель - " .. (myHP <= 12 and "".. f .. " " .. n .. "" or "" .. myn .. " " .. myf .. "") .. "!\"")
							duel.mode = false
							duel.en.id = -1
							duel.fightmode = false
							return
						end
					end
				end) 
			end
		end

		if duel.mode and not duel.fightmode then
			local f, n = text:match( "" .. sampGetPlayerNickname(duel.en.id) .. " наступил.? на брошенную перчатку")
			if f ~= nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Предложение отклонено.", 0xFFFF0000) duel.mode = false duel.en.id = -1 return end
			local f2, n2 = text:match( "" .. sampGetPlayerNickname(duel.en.id) .. " поднял.? брошенную перчатку")
			if f2 ~= nil then 
				duel.fightmode = true
				lua_thread.create(function()
					local myid = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
					local id = duel.en.id
					while true do
						wait(0)
						if not duel.mode then return end
						local myHP = sampGetPlayerHealth(myid)
						local enHP = sampGetPlayerHealth(id)
						if myHP <= 12 or enHP <= 12 then
							duel.mode = false
							duel.en.id = -1
							duel.fightmode = false
							break
						end
					end
				end)
			end
		end

		if getActiveInterior() == 2 then
			local hex = 0
			local nick = ""
			if hex == 0 then
				nick = text:match("%- (%w+%_%w+)%[%d+%]%: .*")
				if col == -926365496 and nick ~= nil then hex = "C8C8C8" end
			end
	
			if hex == 0 then
				nick = text:match("(%w+%_%w+) крикнула?%: .*%!%!")
				if col == -1 and nick ~= nil then hex = "FFFAFA" end
			end
	
			if hex == 0 then
				nick = text:match("(%w+%_%w+) .*")
				if col == -1029514497 and nick ~= nil then hex = "C2A2DA" end
			end
	
			if hex == 0 then
				nick = text:match("(%w+%_%w+) .* %{.*%} %[%w+%]")
				if col == -1029514497 and nick ~= nil then hex = "C2A2DA" end
			end
	
			if hex == 0 then
				nick = text:match("%{FFFFFF%} %(%( (%w+%_%w+)%[%d+%] %)%) %{FF8000%} .*")
				if col == -1029514497 and nick ~= nil then hex = "C2A2DA" end
			end
	
			if hex == 0 then
				nick = text:match(".* %{C2A2DA%}%- сказал%(а%) (%w+%_%w+)%, .*")
				if col == -926365496 and nick ~= nil then hex = "C8C8C8" end
			end
	
			if hex == 0 then
				nick = text:match("(%w+%_%w+)%: %(%( .* %)%)")
				if col == -421075226 and nick ~= nil then hex = "E6E6E6" end
			end
	
			if hex == 0 then
				nick = text:match("(%w+%_%w+) шепнул%(а%)%: .*")
				if col == 1852730990 and nick ~= nil then hex = "6E6E6E" end
			end	
	
			if hex ~= 0 then
				local id = sampGetPlayerIdByNickname(nick)
				if id then
					local distanse = -1
					local bool = false
					if id ~= select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
						local res, tped = sampGetCharHandleBySampPlayerId(id)
						if res then
							local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
							local tX, tY, tZ = getCharCoordinates(tped)
							distanse = math.ceil(math.sqrt( ((myX-tX)^2) + ((myY-tY)^2) + ((myZ-tZ)^2)))
						end
					else
						bool = true
					end
									
					if bool or (distanse ~= -1 and distanse < 4) then
						sampAddChatMessage("{" .. hex .. "}" .. text .. "", 0xFFFFFF00)
						return false
					end
				end
			end
		end
end

function ev.onSetPlayerColor(id, color)
	if rCache.enable and rCache.smem[id] ~= nil and config_ini.bools[41] == 1 then
		--[[ local clist = ("%06x"):format(bit.band (bit.rshift(color, 8), 0xFFFFFF)) 
		local clist = clist == "ffff" and "fffafa" or clist ]]
		local r, g, b, a = explode_argb(color)
		rCache.smem[id].color = join_argb(500.0, r, g, b)
		rCache.smem[id].colorns = join_argb(150.0, r, g, b)
	end

	if config_ini.bools[42] == 1 and isCharInAnyCar(PLAYER_PED) then
		local result, ped = sampGetCharHandleBySampPlayerId(id)
		if not result or ped == PLAYER_PED then return {id, color} end

		local car = storeCarCharIsInNoSave(PLAYER_PED)
		local driver = getDriverOfCar(car)
		if ped ~= driver then return {id, color} end

		lua_thread.create(function()
			local cl = clists[color] -- узнаем новый клист водителя
			local mycl = clists[sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))]
			if cl == mycl then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}На тебе сейчас этот же цвет.", 0xFFFF0000) return end

			wait(550)
			if cl ~= 32 then
				if mycl ~= 32 or cl == 0 then
					sampSendChat("/clist " .. (cl == 0 and 0 or 12) .. "")
					wait(500)
					sampSendChat(cl == 0 and "/me снял" .. RP .. " " .. config_ini.UserClist[tonumber(mycl)] .. "" or "/me надел" .. RP .. " " .. config_ini.UserClist[12] .. "")
				else
					needtomask.mode = true
					sampSendChat("/acce")
				end
			else
				needtomask.mode = true
				sampSendChat("/acce")
			end
		end)
	end
end

function join_argb(a, r, g, b)
   local argb = b  -- b
   argb = bit.bor(argb, bit.lshift(g, 8))  -- g
   argb = bit.bor(argb, bit.lshift(r, 16)) -- r
   argb = bit.bor(argb, bit.lshift(a, 24)) -- a
   return argb
 end

 function explode_argb(argb)
   local a = bit.band(bit.rshift(argb, 24), 0xFF)
   local r = bit.band(bit.rshift(argb, 16), 0xFF)
   local g = bit.band(bit.rshift(argb, 8), 0xFF)
   local b = bit.band(argb, 0xFF)
   return a, r, g, b
 end

function ev.onPlayerChatBubble(playerId, color, distanse, duration, message)
	if config_ini.bools[15] == 1 and (message == "Употребил психохил" or message == "Употребила психохил") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок " .. sampGetPlayerNickname(playerId) .. "[" .. playerId .. "] - употребил психохил", 0xFFFF0000) end
end

--[ML] (script) Binder for CO by Belka version 1.41.lua: 2048   Sergey_Reddle - Desert Eagle +47.0
--[ML] (script) Binder for CO by Belka version 1.41.lua: 2049   Sergey_Reddle - Desert Eagle +47.0

function findsquad()
	--rCache.font = renderCreateFont("Trebuc", 9, FCR_BORDER + FCR_BOLD)
	rCache = {enable = false, smem = {}}
	for i = 0, 2303 do
		if sampTextdrawIsExists(i) and sampTextdrawGetString(i):find("SQUAD") then
			sampTextdrawSetPos(i, 1488, 1488)
			--local x, y = sampTextdrawGetPos(i)
			--rCache.pos.x, rCache.pos.y = convertGameScreenCoordsToWindowScreenCoords(x == 1488 and x - 1485 or x + 1, y == 1488 and y - 1341 or y - 50)
			local list = sampTextdrawGetString(i):split("~n~")
			table.remove(list, 1)
			for k, v in ipairs(list) do
				wait(0)
				local id = sampGetPlayerIdByNickname(v)
				if id then
					local color = sampGetPlayerColor(id)
           			local a, r, g, b = explode_argb(color)
					--[[ local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
					local clist = clist == "ffff" and "fffafa" or clist ]]
						
					rCache.smem[id] = {["name"] = v, ["color"] = join_argb(230.0, r, g, b), ["colorns"] = join_argb(150.0, r, g, b), ["time"] = 0}
				end
			end
			rCache.enable = true
			break
        end	
    end
end

function ev.onCreate3DText(id, color, position, distanse, testLOS , attachedPlayerId, attachedVehicleId, text)
	lua_thread.create(function() 
		if config_ini.bools[53] == 1 then
			local cen = tonumber(text:match("Цена за 200л%: %$(%d+)"))
			if cen ~= nil then
				local ncost = tonumber(config_ini.dial[4])
				if ncost ~= nil and cen <= ncost then
					sampSendChat("/get fuel")
					if isCharInAnyCar(PLAYER_PED) and getDriverOfCar(storeCarCharIsInNoSave(PLAYER_PED)) == PLAYER_PED then skipd[3][7][1] = true skipd[3][7][2] = id end
				end
			end
		end

		if config_ini.bools[62] == 1 then -- чекер квартир
			array[id] = text
			local rooms = {}
			for k,v in pairs(array) do
				if v:find('Комната') then

					
--[[ Комната #8
Продается: 300000 вирт
Чтобы войти, нажмите клавишу '~k~~VEHICLE_ENTER_EXIT~'

Комната #2
Владелец: See_Doo
Чтобы войти, нажмите клавишу '~k~~VEHICLE_ENTER_EXIT~' ]]

					local room, text = v:match('Комната #(%d+)%c..+%: (.+).Чтобы')
					rooms[tonumber(room)] = text
				end
				local text = ''
				for i = 1, 10 do
					if rooms[i] ~= nil then 
						local tab = ''
						for m = 1, 22 do 
							if m > #rooms[i] then
								tab = tab..' ' 	
							end
						end
						text = string.format('%s{e6e070}Квартира №%s.%s{%s} %s\n', text, i, tab, (rooms[i]:find('вирт') and '18a10b' or 'ff0000'), rooms[i])
					end
				end
				local intId = getActiveInterior()
				local coord = { [15] = {x = 2240.7305664063, y = -1195.2797851563 , z = 1034.596875 }, [1] = {x = 2270.3698730469, y = 1647.5157470703, z = 1084.834375} }
				if coord[intId] ~= nil then
					sampCreate3dTextEx(800, text, 0xFFFFFFFF, coord[intId].x, coord[intId].y, coord[intId].z, 4.0, false, -1, -1)
				else
					sampCreate3dTextEx(800, text, 0xFFFFFFFF, -21.008367538452, 19.07968711853, 1701.4073486328, 4.0, false, -1, -1)
				end
			end
		end
	end)
	return
end

function ev.onRemove3DTextLabel(id)
	if skipd[3][7][1] and id == skipd[3][7][2] then skipd[3][7][1] = false end
end

function ev.onShowDialog(dialogid, style, title, button1, button2, text)
	--print(dialogid, style, title, button1, button2, text)

	if title:match("Взаимодействие %| %a+%_%a+ %[%d+%]") then print("Диалог взаимодействия скрыт.") sampSendDialogResponse(dialogid, 0, 0, "") sampCloseCurrentDialogWithButton(0) return false end

	if title:match("Статистика") and stattext == "" then sampSendDialogResponse(dialogid, 0, 0, "") sampCloseCurrentDialogWithButton(0) stattext = text return false end
	if title:match("Аксессуары") ~= nil and needtomask.mode then
		waitforchangeclist2 = false
		if needtomask.status == 2 then 
			if text:match("Инвентарь") ~= nil then needtomask.mode = false needtomask.status = 0 end
			sampSendDialogResponse(dialogid, 0, 0, "")
			sampCloseCurrentDialogWithButton(0)
			return false
		end

		if text:match("Редкость") ~= nil then
			local a_index = -1
			for v in text:gmatch("[^\n]+") do 
				local a, s = v:match("%{FFFFFF%}(.*)	%{.*%}.*	%{(.*)%}.*")
				if a ~= nil and ((needtomask.status == 1 and a == "Beret Red & White") or (needtomask.status == 0 and needtomask[a] ~= nil)) then
					needtomask.bool = s == "33AA33" and true or false
					sampSendDialogResponse(dialogid, 1, a_index, "")
					sampCloseCurrentDialogWithButton(0)
					return false
				end
				a_index = a_index + 1
			end

			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Аксессуар " .. (needtomask.status == 0 and "закрывающий лицо" or "Beret Red & White") .. " не найден в инвентаре.", 0xffFF0000)
			needtomask.status = 2
			sampSendDialogResponse(dialogid, 0, 0, "")
			sampCloseCurrentDialogWithButton(0)
			return false
		elseif text:match("Снять") ~= nil then
			local sts = needtomask.status
			local bls = needtomask.bool
			needtomask.status = needtomask.status == 0 and (access.state == 0 and 2 or 1) or 2
			sampSendDialogResponse(dialogid, 1, 0, "")
			sampCloseCurrentDialogWithButton(0)
			lua_thread.create(function()
				if sts == 0 then wait(600) sampSendChat("/clist " .. (bls and 12 or 32) .. "") end
				wait(sts == 0 and 600 or 1800)
				sampSendChat("/me " .. (bls and "снял" or "надел") .. "" .. RP .. " " .. config_ini.UserClist[sts == 0 and 32 or 12] .. "")

			end)
			return false
		else
			sampSendDialogResponse(dialogid, 1, 0, "")
			sampCloseCurrentDialogWithButton(0)
			return false
		end
	end

	
	if dialogid == 22 and style == 4 and title == "Карманы" then	
		local n = text:match("Наркотики") ~= nil and true or false
		local m = text:match("Материалы") ~= nil and true or false
		local k = text:match("Ключи от камеры") ~= nil and true or false
		local v = text:match("Набор для взлома") ~= nil and true or false

		online_ini.tec_info[3] = text:match("Канистра с бензином") ~= nil and 1 or 0
		local rem = text:match("Комплект %«автомеханик%»	(%d+) %/ %d+")
		online_ini.tec_info[2] = rem == nil and 0 or tonumber(rem)
		online_ini.tec_info[4] = n and 1 or 0
		online_ini.tec_info[5] = m and 1 or 0
		online_ini.tec_info[6] = k and 1 or 0
		online_ini.tec_info[7] = v and 1 or 0
		
		if n then sampAddChatMessage("{FF0000}[LUA]: ВНИМАНИЕ! {FFFAFA}В инвентаре найдены {ff0000}НАРКОТИКИ! {fffafa}Немедленно избавьтесь от них!", 0xFFFFAFA) end
		if m then sampAddChatMessage("{FF0000}[LUA]: ВНИМАНИЕ! {FFFAFA}В инвентаре найдены {ff0000}МАТЕРИАЛЫ! {fffafa}Немедленно избавьтесь от них!", 0xFFFFAFA) end
		if k then sampAddChatMessage("{FF0000}[LUA]: ВНИМАНИЕ! {FFFAFA}В инвентаре найдены {ff0000}КЛЮЧИ ОТ КАМЕРЫ! {fffafa}Немедленно избавьтесь от них!", 0xFFFFAFA) end
		if v then sampAddChatMessage("{FF0000}[LUA]: ВНИМАНИЕ! {FFFAFA}В инвентаре найдены {ff0000}НАБОРЫ ДЛЯ ВЗЛОМА! {fffafa}Немедленно избавьтесь от них!", 0xFFFFAFA) end

		if prepareinv then prepareinv = false sampSendDialogResponse(dialogid, 0, 0, "") sampCloseCurrentDialogWithButton(0) return false end
	end 

	if dialogid == 245 and title == "Склад оружия" then
			istakesomeone = false
			if AutoDeagle and not isdeagle then sampSendDialogResponse(dialogid, 1, 0, "") isdeagle = true return false end

			if AutoShotgun and not isshotgun then sampSendDialogResponse(dialogid, 1, 1, "") isshotgun = true return false end

			if AutoSMG and not issmg then sampSendDialogResponse(dialogid, 1, 2, "") issmg = true return false end

			if AutoM4A1 and not ism4a1 then sampSendDialogResponse(dialogid, 1, 3, "") ism4a1 = true return false end

			if AutoRifle and not isrifle then sampSendDialogResponse(dialogid, 1, 4, "") isrifle = true return false end

			if AutoPar and (os.time() > partimer) and not ispar then sampSendDialogResponse(dialogid, 1, 6, "") partimer = os.time() + 60 ispar = true return false end

			if not isarm then sampSendDialogResponse(dialogid, 1, 5, "") isarm = true return false end

			if not istakesomeone then
				if AutoOt then
					local otsrt = ""
					if isarmtaken then otsrt = "бронежилет" end
					if isdeagletaken then otsrt = otsrt == "" and "Desert Eagle" or "" .. otsrt .. ", Desert Eagle" end
					if isshotguntaken then otsrt = otsrt == "" and "Shotgun" or "" .. otsrt .. ", Shotgun" end
					if issmgtaken then otsrt = otsrt == "" and "HK MP-5" or "" .. otsrt .. ", HK MP-5" end
					if ism4a1taken then otsrt = otsrt == "" and "M4A1" or "" .. otsrt .. ", M4A1" end
					if isrifletaken then otsrt = otsrt == "" and "Country Rifle" or "" .. otsrt .. ", Country Rifle" end
					if ispartaken then otsrt = otsrt == "" and "парашют" or "" .. otsrt .. ", парашют" end
					if otsrt ~= "" then sampSendChat("/me взял" .. RP .. " со склада " .. otsrt .. "") end
				end	
			end

			sampSendDialogResponse(dialogid, 0, 5, "")
			sampCloseCurrentDialogWithButton(0)
			isarmtaken, isarm, isdeagletaken, isdeagle, isshotguntaken, isshotgun, issmgtaken, issmg, ism4a1taken, ism4a1, isrifletaken, isrifle, ispartaken, ispar, istakesomeone = false, false, false, false, false, false, false, false, false, false, false, false, false, false, false
			if config_ini.bools[46] == 1 then 
				local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
				for i, v in ipairs(getAllPickups()) do -- определяем количество меток вокруг
					local cX, cY, cZ = getPickupCoordinates(v)
					local distanse = math.ceil(math.sqrt( ((myX-cX)^2) + ((myY-cY)^2) + ((myZ-cZ)^2)))
					if distanse <= 5 and distanse > 1 then sampSendPickedUpPickup(sampGetPickupSampIdByHandle(v)) end
				end
				--sampSendPickedUpPickup(skipd[2][5]) 
			
			end
			return false
	end

	if dialogid == 22 then
		if refmem1.status and title == "Состав онлайн" then
			refmem1.text = text
			sampSendDialogResponse(dialogid, 0, 0, "") sampCloseCurrentDialogWithButton(0)
			return false
		elseif (otmmode or offcheck.status) and title == "Состав оффлайн" then
			local list = string.split(text, "\n")
			for k, v in ipairs(list) do
				local nick, rank, auth, online, onlineall = v:match("%[%d+%] (%a+_%a+) 	(%d+) 	(%d+/%d+/%d+ %d+:%d+:%d+) 	(%d+) / (%d+) часов")
				--print(nick)
				if nick and rank and auth then
					if offcheck.status then
						local r = tonumber(rank)
						if (r >= offcheck.rank and r <= 10) and tonumber(onlineall) >= offcheck.otm then print(nick, rank, onlineall) end
					elseif otmmode then
						if soptlist[1][nick] ~= nil then soptlist[1][nick] = onlineall end
					end
				end
			end
			
			if text:find(">> След.страница", 1, true) then
				lua_thread.create(function() wait(600) sampSendDialogResponse(22, 1, 40, '>> След.страница') end)
			else
				sampSendDialogResponse(dialogid, 0, 0, "") 
				sampCloseCurrentDialogWithButton(0)
				sampAddChatMessage("Завершил проверку.", -1)
				offcheck.status = false
				otmmode = false
			end
			return false
		else end
	end
	
	if config_ini.bools[45] == 1 and dialogid == 288 and text:match("1 Этаж: Холл") then
		local a_index = 0
		local myX, myY, myZ = getCharCoordinates(PLAYER_PED) -- получаем свои координаты

		for i, v in ipairs(getAllPickups()) do -- определяем количество меток вокруг
			local cX, cY, cZ = getPickupCoordinates(v)
			local distanse = math.ceil(math.sqrt( ((myX-cX)^2) + ((myY-cY)^2) + ((myZ-cZ)^2)))
			if distanse <= 50 then a_index = a_index + 1 end
		end

		if a_index == 5 and skipd[1].obool then -- 1 этаж
			sampSendDialogResponse(dialogid, 1, 1, "")
			sampCloseCurrentDialogWithButton(0)
			return false
		elseif a_index == 2 or a_index == 1 then -- 2 и 3 этаж
			sampSendDialogResponse(dialogid, 1, 0, "")
			sampCloseCurrentDialogWithButton(0)
			return false
		end		
	end

	if config_ini.bools[49] == 1 then -- пропуск диалога больницы
		if dialogid == 22 and style == 0 and title == "Сообщение" and button1 == "Выбрать" and button2 == "Назад" then 
			local val = tonumber(text:match("Стоимость лечения (%d+) вирт"))
			if val ~= nil then
				local ncost = tonumber(config_ini.dial[1])
				if ncost ~= nil and val <= ncost then skipd[3][1] = true sampSendDialogResponse(dialogid, 1, 0, "") sampCloseCurrentDialogWithButton(0) return false end
			end
		end

		if dialogid == 22 and style == 2 and title == "Больница" and button1 == "Выбрать" and button2 == "Назад" and skipd[3][1] then skipd[3][1] = false sampSendDialogResponse(dialogid, 0, 0, "") sampCloseCurrentDialogWithButton(0) return false end
	end

	--if 1 == 2 then
		if config_ini.bools[50] == 1 and dialogid == 16 and style == 4 and title == "Магазин 24/7" and button1 == "Купить" and button2 == "Отмена" then -- пропуск диалога 24/7
			if skipd[3][2] == 3 then lua_thread.create(function() wait(200) sampSendDialogResponse(dialogid, 0, 1, "") sampCloseCurrentDialogWithButton(0) skipd[3][2] = 1 end) return false end
			
			if skipd[3][2] == 0 then
				local val = tonumber(text:match("Комплект %«автомеханик%»	%[%$(%d+)%]"))
				if val ~= nil then
					local ncost = tonumber(config_ini.dial[2])
					if ncost ~= nil and val <= ncost then lua_thread.create(function() wait(200) sampSendDialogResponse(16, 1, 8, "") sampCloseCurrentDialogWithButton(0) end) return false end
				end
			end

			if skipd[3][2] == 1 then
				local val = tonumber(text:match("Защита от насильников	%[%$(%d+)%]"))
				if val ~= nil then
					local ncost = tonumber(config_ini.dial[2])
					if ncost ~= nil and val <= ncost then lua_thread.create(function() wait(200) sampSendDialogResponse(16, 1, 10, "") sampCloseCurrentDialogWithButton(0) end) return false end
				end
			end

			if skipd[3][2] == 2 then end
		end
	--end

	
	if config_ini.bools[47] == 1 and dialogid == 184 and style == 0 and title == "Раздевалка" and button1 == "Да" and button2 == "Нет" and text == "Вы хотите начать рабочий день?" then sampSendDialogResponse(dialogid, 1, 0, "") sampCloseCurrentDialogWithButton(0) return false end
	if config_ini.bools[47] == 1 and dialogid == 185 and style == 2 and title == "Раздевалка" and button1 == "Далее" and button2 == "Отмена" and text:match("Завершить рабочий день") then local result, sid = sampGetPlayerSkin(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) local k = (sid == 252 or sid == 140) and 1 or 0 sampSendDialogResponse(dialogid, 1, k, "") sampCloseCurrentDialogWithButton(0) return false end

	if config_ini.bools[48] == 1 and dialogid == 42 and style == 2 and title == "Развозка материалов" and button1 == "Выбрать" and button2 == "Выйти" and (skipd[3][3] or skipd[3][8][1]) then
		skipd[3][8][1] = false
		if skipd[3][3] then sampCloseCurrentDialogWithButton(0) skipd[3][3] = false return false end
		if skipd[3][5] then sampSendDialogResponse(42, 1, 7) skipd[3][3] = true return false end

		-- метод определения близжайшей фракции взят со скрипта VMO.lua, но был оптимизировано мной
		local LVax, LVay, SFPDx, SFPDy, LVPDx, LVPDy, LSPDx, LSPDy, FBIx, FBIy, SFax, SFay = 328, 1945,-1605,680, 2230, 2470, 1530, -1683, -2420, 500, -1300, 475
		local CoordX, CoordY = getCharCoordinates(PLAYER_PED)
		local tarr = {[1] = ((LVax - CoordX)^2+(LVay-CoordY)^2)^0.5, [2] = ((LSPDx - CoordX)^2+(LSPDy-CoordY)^2)^0.5, [3] = ((SFPDx - CoordX)^2+(SFPDy-CoordY)^2)^0.5, [4] = ((LVPDx - CoordX)^2+(LVPDy-CoordY)^2)^0.5, [5] = ((FBIx - CoordX)^2+(FBIy-CoordY)^2)^0.5, [6] = ((SFax - CoordX)^2+(SFay-CoordY)^2)^0.5}
		local FractionBase = indexof(math.min(tarr[1], tarr[2], tarr[3], tarr[4], tarr[5], tarr[6]), tarr)
		local req_index = FractionBase ~= 1 and FractionBase or skipd[3][4] ~= 10000 and 0 or 1
		sampSendDialogResponse(dialogid, 1, req_index, "")
		return false
	end

	if config_ini.bools[61] == 1 then
		if style == 2 and button1 == "Ок" and button2 == "Отмена" and text:match("Положить в багажник") then
			local a, b = title:match("(.*) %[(%d+)%]")
			if skipd[3][10][a] == nil then return end
			local b = tonumber(b)
			skipd[3][9] = b > skipd[3][10][a] and skipd[3][10][a] or b
			sampSendDialogResponse(dialogid, 1, 0, "")
			sampCloseCurrentDialogWithButton(1)
			return false
		end

		if skipd[3][9] ~= 0 and style == 1 and title == "Багажник" and button1 == "Ок" and button2 == "Отмена" and text:match("Введите количество которое хотите положить в багажник") then
			sampSendDialogResponse(dialogid, 1, 0, skipd[3][9]) 
			skipd[3][9] = 0
			sampSendDialogResponse(dialogid, 1, 0, "")
			sampCloseCurrentDialogWithButton(1)
			return false
		end

		if style == 2 and button1 == "Выбор" and button2 == "Назад" and text:match("Забрать из багажника") then
			sampSendDialogResponse(dialogid, 1, 0, "")
			sampCloseCurrentDialogWithButton(1)
			return false
		end

		if style == 1 and title == "Забрать из багажника" and button1 == "Забрать" and button2 == "Назад" and text:match("Введите количество, которое хотите забрать") then
			local a, b = text:match("%{FF9DB6%}(.*)%c%{FFFFFF%}Количество в багажнике%: %{6AB1FF%}(%d+)")
			local b = tonumber(b)
			if skipd[3][10][a] == nil then return end
			local k = b > skipd[3][10][a] and skipd[3][10][a] or b
			sampSendDialogResponse(dialogid, 1, 0, k)
			sampCloseCurrentDialogWithButton(1)
			return false
		end
	end
end

function ev.onSendGiveDamage(playerId, damage, weapid, bodypart)
	if weapid ~= nil and (weapid == 23 or weapid == 24 or weapid == 25 or weapid == 29 or weapid == 30 or weapid == 31 or weapid == 33) then
		show.show_dmind.damind.hits[weapid] = show.show_dmind.damind.hits[weapid] + 1
		show.show_dmind.damind.damage[weapid] = show.show_dmind.damind.damage[weapid] + damage
		show.show_dmind.damind.hits[1] = show.show_dmind.damind.hits[1] + 1
		show.show_dmind.damind.damage[1] = show.show_dmind.damind.damage[1] + damage
	end
end

function ev.onSendTakeDamage(playerId, damage, weapon, bodypart)
	if config_ini.bools[65] == 1 then
		lua_thread.create(function()
			if playerId == nil or not sampIsPlayerConnected(playerId) then return end
			if sampGetPlayerColor(playerId) == 16777215 then return end
			local res, ped = sampGetCharHandleBySampPlayerId(playerId)
			if not res then return end

			local x, y = getCharCoordinates(ped)

			if not images[30] then images[30] = renderLoadTextureFromFile(getWorkingDirectory() .. '\\Pictures\\di.png') end
			local time = os.time()
			local sw, sh = getScreenResolution()
			while os.time() - time < 5 do
				wait(0)
				
				-- BloodEffect by Vintik https://www.blast.hk/threads/86490/
				local myX, myY = getCharCoordinates(PLAYER_PED)
				local blood_heading = math.atan2(x - myX, y - myY)
				local camera_heading = representIntAsFloat(readMemory(0xB6F258, 4, false)) * 180 / math.pi + 90
				local angle = 180 + math.fmod(camera_heading + blood_heading * 180 / math.pi - 180, 360)

				if doesCharExist(ped) and getCharHealth(ped) <= 0 then return end
				renderDrawTexture(images[30], (sw / 2) - 256, (sh / 2) - 256, 512, 512, angle, 0xFFFFFAFA)
			end
		end)
	end
end

function ev.onSendBulletSync(data)
	local weapid = tonumber(getCurrentCharWeapon(PLAYER_PED))
	if weapid ~= nil and (weapid == 23 or weapid == 24 or weapid == 25 or weapid == 29 or weapid == 30 or weapid == 31 or weapid == 33) then 
		show.show_dmind.damind.shots[weapid] = show.show_dmind.damind.shots[weapid] + 1
		show.show_dmind.damind.shots[1] = show.show_dmind.damind.shots[1] + 1 
	end

	if config_ini.bools[57] == 1 and autopred.current_weapon == weapid and not autopred.firstshot then 
		local temparr = {[23] = 1, [24] = 2, [25] = 3, [29] = 4, [31] = 5, [30] = 6, [33] = 7}
		if temparr[weapid] ~= nil then 
			lua_thread.create(function() autopred.firstshot = true wait(600) sampSendChat("/me снял" .. RP .. " с предохранителя " .. config_ini.UserGun[temparr[weapid]] .. "")  end)		 
		end
	end

	if config_ini.bools[63] == 1 and data.targetType == 2 then
		local carid = getCarModel(select(2, sampGetCarHandleBySampVehicleId((data.targetId))))
		local k = vehtypes.motos[carid] == nil and 2 or 1
		local d = math.ceil(math.sqrt( ((data.origin.x-data.target.x)^2) + ((data.origin.y-data.target.y)^2) + ((data.origin.z-data.target.z)^2)))
		if tweapondist[data.weaponId] ~= nil and (d <= (tweapondist[data.weaponId] * k)) then
			local car = tVehicleNames[carid - 399]
			carinformer(2, data.targetId, data.weaponId, car) 
		end
		return
	end
end

function ev.onBulletSync(id, data) --targetType, targetId,  origin, target, center, weaponId)
	if config_ini.bools[63] == 1 and data.targetType == 2 and isCharInAnyCar(PLAYER_PED) and isCharInCar(PLAYER_PED, select(2, sampGetCarHandleBySampVehicleId(data.targetId))) then 
		local carid = getCarModel(select(2, sampGetCarHandleBySampVehicleId((data.targetId))))
		local k = vehtypes.motos[carid] == nil and 2 or 1
		local d = math.ceil(math.sqrt( ((data.origin.x-data.target.x)^2) + ((data.origin.y-data.target.y)^2) + ((data.origin.z-data.target.z)^2)))
		if tweapondist[data.weaponId] ~= nil and (d <= (tweapondist[data.weaponId] * k)) then
			local car = tVehicleNames[carid - 399]
			carinformer(1, id, data.weaponId, car) 
		end
		return
	end
end

function ev.onSendExitVehicle(vehid)
	local result, car = sampGetCarHandleBySampVehicleId(vehid)
	if result and getDriverOfCar(car) == PLAYER_PED then
		local carid = getCarModel(car)
		if vehtypes.motos[carid] ~= nil and not isCarPassengerSeatFree(car, 0) then
			local passenger = getCharInCarPassengerSeat(car, 0)
			local result, id = sampGetPlayerIdByCharHandle(passenger)
			if result then lua_thread.create(function() sampSendChat("/eject " .. id .. "") wait(500) sampSendExitVehicle(vehid) end) return false end
		end
	end
end

function ev.onSendPickedUpPickup(id)
	--print(id, getPickupCoordinates(sampGetPickupHandleBySampId(id)))
	if skipd[2][1] == 1 then print(id) end
	skipd[1].pid = id
	local x, y, z = getPickupCoordinates(sampGetPickupHandleBySampId(id))
	if not afkstatus and not show.othervars.saccess then if ((x + y + z) == (342.5 + 1958.5 + 17.625)) then skipd[2][7] = id skipd[2][8] = id - 1 local a = os.time() - (3600 * tonumber(config_ini.Settings.timep)) lua_thread.create(function() wait(501) sampSendChat("/fs sq_message_id_1_" .. a .. "") end) return end

		if id == skipd[2][8] then lua_thread.create(function() wait(501) sampSendChat("/fs sq_message_id_2") end) return end
	end

	
	local pick = CTaskArr[10][8][x + y + z]
	if pick ~= nil then
		if pick ~= 0 then
			table.insert(CTaskArr[1], 12)
			table.insert(CTaskArr[2], os.time())
			table.insert(CTaskArr[3], pick)
		else
			local key = indexof(12, CTaskArr[1])
			if key ~= false then CTaskArr[2][key] = os.time() - 100 end
		end
	end
end

function f_matovoz()
	while true do
		wait(0)
		if isCharInAnyCar(PLAYER_PED) and getCarModel(storeCarCharIsInNoSave(PLAYER_PED)) == 433 then
			local matovoz = storeCarCharIsInNoSave(PLAYER_PED)
			if config_ini.bools[48] == 1 then --- автоматический /carm
				if not skipd[3][8][2] then
					for k, v in ipairs(skipd[3][8][3]) do
						wait(0)
						if isCharInArea2d(PLAYER_PED, v.x1, v.y1, v.x2, v.y2, false) then
							if k == 1 then if skipd[3][4] ~= 10000 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Грузовик будет загружен.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Грузовик будет РАЗГРУЖЕН.", 0xffff0000) end end
									
							if skipd[3][4] == 0 and k ~= 1 then 
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/carm не будет введен так как грузовик пустой.", 0xffff0000)
								skipd[3][8][4] = v
								skipd[3][8][2] = true
								break		
							end

							sampSendChat("/carm")
							skipd[3][8][1] = true
							skipd[3][8][4] = v
							skipd[3][8][2] = true
							break								
						end
					end
				else
					while isCharInArea2d(PLAYER_PED, skipd[3][8][4].x1, skipd[3][8][4].y1, skipd[3][8][4].x2, skipd[3][8][4].y2, false) do wait(0) end
					skipd[3][8][2] = false
					skipd[3][8][4] = {}
				end
			end

			if getDriverOfCar(matovoz) == PLAYER_PED then  -- КК№16
				local angle = getCarHeading(matovoz)
				local tv = ((isCarInArea2d(matovoz, 302.93, 1725.01, 379.88, 1775.86, false) and (angle > 330 or (angle > 0 and angle < 50))) or (isCarInArea2d(matovoz, 367.24, 1814.77, 428.03, 1861.88, false) and (angle > 130 and angle < 230))) and 2 or ((isCarInArea2d(matovoz, 334.55, 1797.87, 352.00, 1818.40, false) and (angle > 130 and angle < 230))) and 1 or 0
					
				if CTaskArr[10][11] ~= tv then
					CTaskArr[10][11] = tv
					if tv ~= 0 and not CTaskArr[10][12] then 
						table.insert(CTaskArr[1], 16)
						table.insert(CTaskArr[2], os.time())
						table.insert(CTaskArr[3], tv == 1 and "Выезжает ВМО!" or "Подъезжает ВМО!")
						CTaskArr[10][12] = true
					end
				end
			end
		end
	end
end


function f_incar()
	local speedbool = false
	local arrr = {[0] = false, [1] = false, [2] = false, [3] = false}
	while true do
		wait(0)
		if isCharInAnyCar(PLAYER_PED) then
			if needtohold then
				local car = storeCarCharIsInNoSave(PLAYER_PED)
				if vehtypes.helis[getCarModel(car)] ~= nil then -- helihover
					if desH == 0 then _, _, desH = getCharCoordinates(PLAYER_PED) end
					local _, _, fHeight = getCharCoordinates(PLAYER_PED)
					dH = desH - fHeight
					if(dH>0) then
						setGameKeyState(16, 16+dH*15)
						setGameKeyState(14, 0)
					else
						setGameKeyState(16, 0)
						setGameKeyState(14, -dH*15)
					end
				else
					setGameKeyState(16, 256) 
				end
			end

			if config_ini.bools[31] == 1 and not SetMode then
				if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then
					if wasKeyPressed(vkeys.VK_RBUTTON) then crosMode = true showcmc = true show.rand = math.random(1, 5) end
					if wasKeyReleased(vkeys.VK_RBUTTON) and not pCros then crosMode = false showcmc = false end
					if PLAYER_PED ~= getDriverOfCar(storeCarCharIsInNoSave(PLAYER_PED)) then
							if wasKeyPressed(vkeys.VK_CAPITAL) or wasKeyPressed(vkeys.VK_H) then crosMode = true pCros = true show.rand = math.random(1, 5) end
					end

				--	if crosMode then renderDrawPolygon(sx, sy, 0.5, 0.5, 12, 0xFFFF0000) end
				end
			end

			if config_ini.bools[63] == 1 then
				local car = storeCarCharIsInNoSave(PLAYER_PED)
            	local mt = vehtypes.motos[getCarModel(car)] ~= nil and 1 or 3
				mt = vehtypes.boats[getCarModel(car)] ~= nil and -1 or mt
                for k = 0, mt do
					local result = isCarTireBurst(storeCarCharIsInNoSave(PLAYER_PED), k) 
					if result ~= arrr[k] then
						arrr[k] = result
						table.insert(show.vehinformer[1], {["tid"] = 1002 + k, ["d"] = 0, ["wid"] = 31, ["car"] = "car", ["time"] = os.time()})
						lua_thread.create(function()
							local fid = 1002 + k
							local index = 1
							local res = result
							local tag = res and "{ff0000}-" or "{008800}+"

							while true do
								wait(0)
								local k = findindex(fid, index)
								if k == 0 then return end
								local time = show.vehinformer[index][k]["time"]

								if os.time() - time >= 3 then
									local kk = findindex(fid, index)
									if kk == 0 then sampAddChatMessage("{FF0000}[LUA]: Произошла ошибка при очистке лога дамаг информера.", 0xffff0000) return end
									table.remove(show.vehinformer[index], kk)
									return
								end

								local x = config_ini.ovCoords.show_vehdamagemX
								local y = config_ini.ovCoords.show_vehdamagemY + (15 * k)
								renderFontDrawText(dx9font, "" .. tag .. "Tire", x, y, 0xfffffafa)
							end
						end)
					end
				end
			end			
		else
			arrr = {[0] = false, [1] = false, [2] = false, [3] = false}
		end

		
		if config_ini.bools[53] == 1 and skipd[3][7][1] == true then while true do wait(0) if not skipd[3][7][1] or getCarSpeed(storeCarCharIsInNoSave(PLAYER_PED)) == 0 then break end end if skipd[3][7][1] then skipd[3][7][1] = false lua_thread.create(function() wait(500) sampSendChat("/fill") end) end end

		if spsyns.mode and spsyns.firstshow then
			while isKeyDown(vkeys.VK_CONTROL) do wait(0) end
			spsyns.firstshow = false
			local cidcar = getCarModel(spsyns.car)
			local cresult2, cid = sampGetVehicleIdByCarHandle(spsyns.car)
			local fcar = cIDs[cid] == nil and cid or cIDs[cid]
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Начинаю синхронизацию скорости с " .. tVehicleNames[cidcar-399] .. " [" .. fcar .. "].")	
			spsyns.time = os.clock()
			lua_thread.create(function()						
				while true do
					wait(0)
					if not doesVehicleExist(spsyns.car) or getDriverOfCar(spsyns.car) == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Транспорт/водитель потерян. Синхронизация прервана (#000)!") spsyns.mode = false wait(600) sampSendChat("/slimit 50") wait(600) sampSendChat("/slimit") break end
					if not isCharInAnyCar(PLAYER_PED) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Вы покинули транспорт. Синхронизация прервана (#002).") spsyns.mode = false wait(600) sampSendChat("/slimit 50") wait(600) sampSendChat("/slimit") break end
					if isKeyDown(vkeys.VK_CONTROL) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Отключаем синхронизацию скорости.") spsyns.mode = false wait(600) sampSendChat("/slimit 50") wait(600) sampSendChat("/slimit") break end
					if spsyns.time + 0.65 <= os.clock() then
						local myspeed = math.floor(getCarSpeed(storeCarCharIsInNoSave(PLAYER_PED)) * 2)
						local hspeed = math.floor(getCarSpeed(spsyns.car) * 2)
						if myspeed ~= hspeed then
							if hspeed < 20 or hspeed > 90 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Невозможно синхронизировать скорость. Синхронизация прервана (#001)!") spsyns.mode = false wait(600) sampSendChat("/slimit 50") wait(600) sampSendChat("/slimit") break end
							sampSendChat("/slimit " .. hspeed .. "")
							spsyns.time = os.clock()
						end
					end
				end		
			end)	
		end

		if isCharInAnyCar(PLAYER_PED) and isCharInArea2d(PLAYER_PED, -84, 1606, 464, 2148, false) then
			if isKeyDown(vkeys.VK_CONTROL) and getDriverOfCar(storeCarCharIsInNoSave(PLAYER_PED)) == PLAYER_PED then
				while isKeyDown(vkeys.VK_CONTROL) do wait(0) end
				local speed = getCarModel(storeCarCharIsInNoSave(PLAYER_PED)) == 433 and 30 or 50
				sampSendChat("/slimit" .. (speedbool and "" or " " .. speed .. "") .. "")
				speedbool = not speedbool
			end
		else
			if speedbool then speedbool = false end
		end
	end
end

function f_onfoot()
	while true do
		wait(0)
		if isCharOnFoot(PLAYER_PED) then
			if needtohold then setGameKeyState(1, (isCharInWater(PLAYER_PED) or isKeyDown(vkeys.VK_RBUTTON)) and -128 or -256) end

			if config_ini.bools[31] == 1 and not SetMode then
				showcmc = false
				pCros = false
				if tonumber(getCurrentCharWeapon(PLAYER_PED)) == 33 then
					if wasKeyPressed(vkeys.VK_RBUTTON) then crosMode = true showcmc = true end
					if wasKeyReleased(vkeys.VK_RBUTTON) then crosMode = false showcmc = false end
				else
					if memory.getint8(ped + 0x528, false) == 19 then crosMode = true else crosMode = false end
				end							
			end
		end
	end
end

function f_ckey() -- ### КОНТЕКСТНАЯ КЛАВИША
	while true do
		wait(0)					
		if CTaskArr[10][1] ~= "" then -- ID 10
			local kv = kvadrat()
			if kv ~= nil and kv == CTaskArr[10][1] then
				CTaskArr[10][1] = ""
				table.insert(CTaskArr[1], 10)
				table.insert(CTaskArr[2], os.time() + 10)
				table.insert(CTaskArr[3], kv)
			end
		end

		------------ id 5 and 9
		local car = isCharInAnyCar(PLAYER_PED) and storeCarCharIsInNoSave(PLAYER_PED) or -1
		local idc = car ~= -1 and getCarModel(car) or -1
		local x, y, z = getCharCoordinates(PLAYER_PED) -- ID 5 и 6
		if idc == 433 and getDriverOfCar(car) == PLAYER_PED then	
			if not CTaskArr[10][2][2] then
				CTaskArr[10][2][2] = true	
				if x >= 266 and x <= 287 and y >= 1940 and y <= 2004 and z > 16 and z < 30 then
					table.insert(CTaskArr[1], 5)
					table.insert(CTaskArr[2], os.time())
					table.insert(CTaskArr[3], CTaskArr[10][2][1][1])
				end
			end
		elseif idc == 497 and getDriverOfCar(car) == PLAYER_PED then	
			if not CTaskArr[10][6] then
				CTaskArr[10][6] = true	
				if x >= 189 and x <= 224 and y >= 1923 and y <= 1939 and z > 22 and z < 25 then
					table.insert(CTaskArr[1], 9)
					table.insert(CTaskArr[2], os.time())
					table.insert(CTaskArr[3], CTaskArr[10][2][1][1])
				end
			end
		else
			if CTaskArr[10][2][2] then -- матовоз
				CTaskArr[10][2][2] = false
				if x >= 266 and x <= 287 and y >= 1940 and y <= 2004 and z > 16 and z < 30 then	
					table.insert(CTaskArr[1], 6)
					table.insert(CTaskArr[2], os.time())
					table.insert(CTaskArr[3], CTaskArr[10][2][1][1])
				end
			end

			if CTaskArr[10][6] then
				CTaskArr[10][6] = false -- вертолет
				if x >= 189 and x <= 224 and y >= 1923 and y <= 1939 and z > 22 and z < 25 then	
					table.insert(CTaskArr[1], 11)
					table.insert(CTaskArr[2], os.time())
					table.insert(CTaskArr[3], CTaskArr[10][2][1][1])
				end
			end
		end

		----------- id 8
		if isCharOnFoot(PLAYER_PED) then
			local car = storeClosestEntities(PLAYER_PED)
			if car ~= -1 and not CTaskArr[10][5] then
				local myX, myY, myZ = getCharCoordinates(PLAYER_PED) -- получаем свои координаты
				local cX, cY, cZ = getCarCoordinates(car) -- получаем координаты машины
				local distanse = math.ceil(math.sqrt( ((myX-cX)^2) + ((myY-cY)^2) + ((myZ-cZ)^2))) 
				if (getCarHealth(car) == 300 or (isCarTireBurst(car, 0) or isCarTireBurst(car, 1) or isCarTireBurst(car, 2) or isCarTireBurst(car, 3) or isCarTireBurst(car, 4))) and distanse <= 5 then
					table.insert(CTaskArr[1], 8)
					table.insert(CTaskArr[2], os.time())
					table.insert(CTaskArr[3], "")
					CTaskArr[10][5] = true
				end
			end
		end

		if CTaskArr[10][5] then -- если отошел от машины то время начала задания смещается на 100 сек. назад для удаления функцией сортировки
			local bool = false
			local car = storeClosestEntities(PLAYER_PED)
			if car == -1 then 
				bool = true
			else
				local myX, myY, myZ = getCharCoordinates(PLAYER_PED) -- получаем свои координаты
				local cX, cY, cZ = getCarCoordinates(car) -- получаем координаты машины
				local distanse = math.ceil(math.sqrt( ((myX-cX)^2) + ((myY-cY)^2) + ((myZ-cZ)^2)))
				if (getCarHealth(car) > 300 and not isCarTireBurst(car, 0) and not isCarTireBurst(car, 1) and not isCarTireBurst(car, 2) and not isCarTireBurst(car, 3) and not isCarTireBurst(car, 4)) or distanse > 5 then
					local key = indexof(8, CTaskArr[1])
					if key ~= false then CTaskArr[2][key] = os.time() - 100 end
				end
			end
		end

		----------- id 3
		if CTaskArr[10][4] and isCharInArea2d(PLAYER_PED, -84, 1606, 464, 2148, false) then
			CTaskArr[10][4] = false
			table.insert(CTaskArr[1], 3)
			table.insert(CTaskArr[2], os.time())
			table.insert(CTaskArr[3], "")
		end
		--	[ML] (script) coordinater.lua: 266.38027954102   1940.4320068359   17.640625
		--	[ML] (script) coordinater.lua: 287.63711547852   2004.6898193359   17.640625

		if isCharInAnyCar(PLAYER_PED) then -- id 13
			local car = storeCarCharIsInNoSave(PLAYER_PED)
			if isCarUpsidedown(car) then 
				if getCarSpeed(car) < 1 and not CTaskArr[10][9] then
					table.insert(CTaskArr[1], 13)
					table.insert(CTaskArr[2], os.time())
					table.insert(CTaskArr[3], "")
					CTaskArr[10][9] = true
				end
			else
				if CTaskArr[10][9] then 
					CTaskArr[10][9] = false
					local key = indexof(13, CTaskArr[1])
					if key ~= false then CTaskArr[2][key] = os.time() - 100 end
				end
			end
		else
			if CTaskArr[10][9] then 
				CTaskArr[10][9] = false
				local key = indexof(13, CTaskArr[1])
				if key ~= false then CTaskArr[2][key] = os.time() - 100 end
			end
		end
		sortCarr() --### Очистка массива контекстной клавиши, назначение нового контекстного действия
	end
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
			while not isSampAvailable() do wait(100) end

			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Биндер успешно загружен.", 0xFFFF0000)
			prepare()
			while not preparecomplete do wait(0) end

			rkeys.unRegisterHotKey(makeHotKey(13))
			imgui.Process = true
			imgui.ShowCursor = false
			imgui.LockPlayer = false
			sx, sy = convert3DCoordsToScreen(get_crosshair_position())
			ped = getCharPointer(PLAYER_PED)
			PICKUP_POOL = sampGetPickupPoolPtr()

			if config_ini.bools[58] == 1 then displayHud(false) end
			lua_thread.create(function() f_incar() end)
			lua_thread.create(function() f_onfoot() end)
			lua_thread.create(function() f_ckey() end)
			lua_thread.create(function() f_matovoz() end)

			if not access.saccess then lua_thread.create(function() aa_time() end) end

			while true do
					wait(0)
					local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
					if suspendkeys == 2 then
							rkeys.registerHotKey(makeHotKey(13), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_13() end)
							rkeys.registerHotKey(makeHotKey(1), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_1() end)
							rkeys.registerHotKey(makeHotKey(2), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_2() end)
							rkeys.registerHotKey(makeHotKey(3), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_3() end)
							rkeys.registerHotKey(makeHotKey(4), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_4() end)
							rkeys.registerHotKey(makeHotKey(5), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_5() end)
							rkeys.registerHotKey(makeHotKey(6), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_6() end)
							rkeys.registerHotKey(makeHotKey(7), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_7() end)
							rkeys.registerHotKey(makeHotKey(8), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_8() end)
							rkeys.registerHotKey(makeHotKey(9), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_9() end)
							rkeys.registerHotKey(makeHotKey(10), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_10() end)
							rkeys.registerHotKey(makeHotKey(11), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_11() end)
							rkeys.registerHotKey(makeHotKey(12), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_12() end)
							rkeys.registerHotKey(makeHotKey(14), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_14() end)
							--rkeys.registerHotKey(makeHotKey(15), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_15() end)
							--rkeys.registerHotKey(makeHotKey(16), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_16() end)
							--rkeys.registerHotKey(makeHotKey(17), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_17() end)
							--rkeys.registerHotKey(makeHotKey(18), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_18() end)
							rkeys.registerHotKey(makeHotKey(19), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_19() end)
							rkeys.registerHotKey(makeHotKey(20), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_20() end)
							rkeys.registerHotKey(makeHotKey(21), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_21() end)
							rkeys.registerHotKey(makeHotKey(22), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_22() end)
							rkeys.registerHotKey(makeHotKey(23), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_23() end)
							--rkeys.registerHotKey(makeHotKey(24), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_24() end)
							rkeys.registerHotKey(makeHotKey(25), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_25() end)
							rkeys.registerHotKey(makeHotKey(26), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_26() end)
							rkeys.registerHotKey(makeHotKey(27), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_27() end)
							rkeys.registerHotKey(makeHotKey(28), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_28() end)
							rkeys.registerHotKey(makeHotKey(29), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_29() end)
							rkeys.registerHotKey(makeHotKey(30), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_30() end)
							rkeys.registerHotKey(makeHotKey(31), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_31() end)
							rkeys.registerHotKey(makeHotKey(32), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_32() end)
							rkeys.registerHotKey(makeHotKey(33), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_33() end)
							rkeys.registerHotKey(makeHotKey(34), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_34() end)
							rkeys.registerHotKey(makeHotKey(35), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_35() end)
							rkeys.registerHotKey(makeHotKey(36), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_36() end)
							rkeys.registerHotKey(makeHotKey(37), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_37() end)
							rkeys.registerHotKey(makeHotKey(38), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_38() end)
							rkeys.registerHotKey(makeHotKey(39), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_39() end)
							rkeys.registerHotKey(makeHotKey(40), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_40() end)
							rkeys.registerHotKey(makeHotKey(41), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_41() end)
							rkeys.registerHotKey(makeHotKey(42), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_42() end)
							rkeys.registerHotKey(makeHotKey(43), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_43() end)
							rkeys.registerHotKey(makeHotKey(52), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_52() end)

							if config_ini.bools[60] then
								rkeys.registerHotKey(makeHotKey(45), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_45() end)
								rkeys.registerHotKey(makeHotKey(46), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_46() end)
								rkeys.registerHotKey(makeHotKey(47), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_47() end)
								rkeys.registerHotKey(makeHotKey(48), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_48() end)
								rkeys.registerHotKey(makeHotKey(49), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_49() end)
								rkeys.registerHotKey(makeHotKey(50), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_50() end)
								rkeys.registerHotKey(makeHotKey(51), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_51() end)
							end

							sampRegisterChatCommand(config_ini.Commands[1], cmd_ob)
							sampRegisterChatCommand(config_ini.Commands[2], cmd_sopr)
							sampRegisterChatCommand(config_ini.Commands[3], cmd_zgruz)
							sampRegisterChatCommand(config_ini.Commands[4], cmd_rgruz)
							sampRegisterChatCommand(config_ini.Commands[5], cmd_bgruz)
							sampRegisterChatCommand(config_ini.Commands[6], cmd_kv)
							sampRegisterChatCommand(config_ini.Commands[7], cmd_e)
							--sampRegisterChatCommand(config_ini.Commands[8], cmd_que)
							sampRegisterChatCommand(config_ini.Commands[9], cmd_r)
							sampRegisterChatCommand(config_ini.Commands[10], cmd_pr)
							sampRegisterChatCommand(config_ini.Commands[11], hk_5)
							sampRegisterChatCommand(config_ini.Commands[12], cmd_gr)
							sampRegisterChatCommand(config_ini.Commands[13], cmd_hit)
							sampRegisterChatCommand(config_ini.Commands[14], cmd_cl)
							sampRegisterChatCommand(config_ini.Commands[15], hk_11)
							sampRegisterChatCommand(config_ini.Commands[16], cmd_memb)
							sampRegisterChatCommand(config_ini.Commands[17], cmd_chs)
							sampRegisterChatCommand(config_ini.Commands[18], cmd_mp)
							sampRegisterChatCommand(config_ini.Commands[19], cmd_z)
							sampRegisterChatCommand(config_ini.Commands[20], cmd_mem1)
							sampRegisterChatCommand(config_ini.Commands[21], cmd_sw)
							sampRegisterChatCommand(config_ini.Commands[22], cmd_st)
							sampRegisterChatCommand(config_ini.Commands[23], cmd_mask)
						--	sampRegisterChatCommand(config_ini.Commands[24], cmd_altenter)
							sampRegisterChatCommand(config_ini.Commands[25], cmd_afk)
						--	sampRegisterChatCommand(config_ini.Commands[26], cmd_destroy)
							sampRegisterChatCommand(config_ini.Commands[27], cmd_mcall)
							sampRegisterChatCommand(config_ini.Commands[28], cmd_showp)
							
							--sampRegisterChatCommand(config_ini.Commands[29], cmd_priziv)

							sampRegisterChatCommand(config_ini.UserCBinderC[1], cmd_u1)
							sampRegisterChatCommand(config_ini.UserCBinderC[2], cmd_u2)
							sampRegisterChatCommand(config_ini.UserCBinderC[3], cmd_u3)
							sampRegisterChatCommand(config_ini.UserCBinderC[4], cmd_u4)
							sampRegisterChatCommand(config_ini.UserCBinderC[5], cmd_u5)
							sampRegisterChatCommand(config_ini.UserCBinderC[6], cmd_u6)
							sampRegisterChatCommand(config_ini.UserCBinderC[7], cmd_u7)
							sampRegisterChatCommand(config_ini.UserCBinderC[8], cmd_u8)
							sampRegisterChatCommand(config_ini.UserCBinderC[9], cmd_u9)
							sampRegisterChatCommand(config_ini.UserCBinderC[10], cmd_u10)
							sampRegisterChatCommand(config_ini.UserCBinderC[11], cmd_u11)
							sampRegisterChatCommand(config_ini.UserCBinderC[12], cmd_u12)
							sampRegisterChatCommand(config_ini.UserCBinderC[13], cmd_u13)
							sampRegisterChatCommand(config_ini.UserCBinderC[14], cmd_u14)
							sampRegisterChatCommand(config_ini.UserCBinderC[15], cmd_u15)
							sampRegisterChatCommand(config_ini.UserCBinderC[16], cmd_u16)
							sampRegisterChatCommand(config_ini.UserCBinderC[17], cmd_u17)
							sampRegisterChatCommand(config_ini.UserCBinderC[18], cmd_u18)

							sampRegisterChatCommand("commandhelp", cmd_commandhelp)
							sampRegisterChatCommand("bugreport", cmd_bugreport)
							sampRegisterChatCommand("mkv", cmd_mkv)
							sampRegisterChatCommand("bkv", cmd_bkv)
							sampRegisterChatCommand("lej", cmd_lej)
							sampRegisterChatCommand("bp", cmd_bp)
							sampRegisterChatCommand("cars", cmd_cars)
							sampRegisterChatCommand("scr", cmd_scr)
							sampRegisterChatCommand("piss", cmd_piss)
							sampRegisterChatCommand("iznas", cmd_iznas)
							sampRegisterChatCommand("dclean", cmd_dclean)
							sampRegisterChatCommand("toggle", cmd_toggle)
							sampRegisterChatCommand("duel", cmd_duel)
							sampRegisterChatCommand("mon", cmd_mon)
							sampRegisterChatCommand("get", cmd_get)
							sampRegisterChatCommand("freeze", cmd_freeze)
							sampRegisterChatCommand("refoffm", cmd_refoffm)
							

							if access.alevel > -1 then
									sampRegisterChatCommand("balogin", cmd_balogin)
							end

							if access.alevel > 0 then
									sampRegisterChatCommand("lek", cmd_lek)
									sampRegisterChatCommand("pcheck", cmd_pcheck)
									sampRegisterChatCommand("tren", cmd_tren)
							end

							if access.alevel > 1 then
									sampRegisterChatCommand("padd", cmd_padd)
									sampRegisterChatCommand("pdel", cmd_pdel)
									sampRegisterChatCommand("mark", cmd_mark)
									sampRegisterChatCommand("add", cmd_add)
									sampRegisterChatCommand("del", cmd_del)
									sampRegisterChatCommand("change", cmd_change)
							end

							if access.alevel > 2 then
								sampRegisterChatCommand("otm", cmd_otm)	
								sampRegisterChatCommand("serj", cmd_serj)	
							end

							if access.alevel == 3 or access.alevel == 6 then sampRegisterChatCommand("fond", cmd_fond) end

							if access.alevel > 4 then
								sampRegisterChatCommand("moder", cmd_moder)
								sampRegisterChatCommand("reg", cmd_reg)
								sampRegisterChatCommand("ban", cmd_ban)
							end
							
							piearr.action = 0
							piearr.pie_mode.v = false -- режим PieMenu
							piearr.pie_keyid = makeHotKey(44)[1]
							piearr.pie_elements =	{}

							if config_ini.UserPieMenuNames[1] ~= "" then table.insert(piearr.pie_elements, {name = config_ini.UserPieMenuNames[1], action = function() piearr.action = 1 end, next = nil}) end
							if config_ini.UserPieMenuNames[2] ~= "" then table.insert(piearr.pie_elements, {name = config_ini.UserPieMenuNames[2], action = function() piearr.action = 2 end, next = nil}) end
							if config_ini.UserPieMenuNames[3] ~= "" then table.insert(piearr.pie_elements, {name = config_ini.UserPieMenuNames[3], action = function() piearr.action = 3 end, next = nil}) end
							if config_ini.UserPieMenuNames[4] ~= "" then table.insert(piearr.pie_elements, {name = config_ini.UserPieMenuNames[4], action = function() piearr.action = 4 end, next = nil}) end
							if config_ini.UserPieMenuNames[5] ~= "" then table.insert(piearr.pie_elements, {name = config_ini.UserPieMenuNames[5], action = function() piearr.action = 5 end, next = nil}) end
							if config_ini.UserPieMenuNames[6] ~= "" then table.insert(piearr.pie_elements, {name = config_ini.UserPieMenuNames[6], action = function() piearr.action = 6 end, next = nil}) end
							if config_ini.UserPieMenuNames[7] ~= "" then table.insert(piearr.pie_elements, {name = config_ini.UserPieMenuNames[7], action = function() piearr.action = 7 end, next = nil}) end
							if config_ini.UserPieMenuNames[8] ~= "" then table.insert(piearr.pie_elements, {name = config_ini.UserPieMenuNames[8], action = function() piearr.action = 8 end, next = nil}) end
							if config_ini.UserPieMenuNames[9] ~= "" then table.insert(piearr.pie_elements, {name = config_ini.UserPieMenuNames[9], action = function() piearr.action = 9 end, next = nil}) end
							if config_ini.UserPieMenuNames[10] ~= "" then table.insert(piearr.pie_elements, {name = config_ini.UserPieMenuNames[10], action = function() piearr.action = 10 end, next = nil}) end

							-- for k, v in pairs(config_ini.UserPieMenuNames) do
							-- 		print(pie_index)
							-- 		if pie_index == 11 then break end
							-- 		if v ~= "" then
							-- 				table.insert(piearr.pie_elements, {name = v, action = function() piearr.action = pie_index end, next = nil})
							-- 				pie_index = pie_index + 1
							-- 		end
							-- end
							suspendkeys = 0
					end

					if not guis.mainw.v and not SetMode and not piearr.pie_mode.v then imgui.ShowCursor = false imgui.LockPlayer = false if suspendkeys == 1 then suspendkeys = 2 sampSetChatDisplayMode(3) end end

					if needtosave then
							needtosave = false
							lua_thread.create(
									function()
											config_ini.UserClist[1] = tostring(u8:decode(guibuffers.clistparams.clist1.v))
											config_ini.UserClist[2] = tostring(u8:decode(guibuffers.clistparams.clist2.v))
											config_ini.UserClist[3] = tostring(u8:decode(guibuffers.clistparams.clist3.v))
											config_ini.UserClist[4] = tostring(u8:decode(guibuffers.clistparams.clist4.v))
											config_ini.UserClist[5] = tostring(u8:decode(guibuffers.clistparams.clist5.v))
											config_ini.UserClist[6] = tostring(u8:decode(guibuffers.clistparams.clist6.v))
											config_ini.UserClist[7] = tostring(u8:decode(guibuffers.clistparams.clist7.v))
											config_ini.UserClist[8] = tostring(u8:decode(guibuffers.clistparams.clist8.v))
											config_ini.UserClist[9] = tostring(u8:decode(guibuffers.clistparams.clist9.v))
											config_ini.UserClist[10] = tostring(u8:decode(guibuffers.clistparams.clist10.v))
											config_ini.UserClist[11] = tostring(u8:decode(guibuffers.clistparams.clist11.v))
											config_ini.UserClist[13] = tostring(u8:decode(guibuffers.clistparams.clist13.v))
											config_ini.UserClist[14] = tostring(u8:decode(guibuffers.clistparams.clist14.v))
											config_ini.UserClist[15] = tostring(u8:decode(guibuffers.clistparams.clist15.v))
											config_ini.UserClist[16] = tostring(u8:decode(guibuffers.clistparams.clist16.v))
											config_ini.UserClist[17] = tostring(u8:decode(guibuffers.clistparams.clist17.v))
											config_ini.UserClist[18] = tostring(u8:decode(guibuffers.clistparams.clist18.v))
											config_ini.UserClist[19] = tostring(u8:decode(guibuffers.clistparams.clist19.v))
											config_ini.UserClist[20] = tostring(u8:decode(guibuffers.clistparams.clist20.v))
											config_ini.UserClist[21] = tostring(u8:decode(guibuffers.clistparams.clist21.v))
											config_ini.UserClist[22] = tostring(u8:decode(guibuffers.clistparams.clist22.v))
											config_ini.UserClist[23] = tostring(u8:decode(guibuffers.clistparams.clist23.v))
											config_ini.UserClist[24] = tostring(u8:decode(guibuffers.clistparams.clist24.v))
											config_ini.UserClist[25] = tostring(u8:decode(guibuffers.clistparams.clist25.v))
											config_ini.UserClist[26] = tostring(u8:decode(guibuffers.clistparams.clist26.v))
											config_ini.UserClist[27] = tostring(u8:decode(guibuffers.clistparams.clist27.v))
											config_ini.UserClist[28] = tostring(u8:decode(guibuffers.clistparams.clist28.v))
											config_ini.UserClist[29] = tostring(u8:decode(guibuffers.clistparams.clist29.v))
											config_ini.UserClist[30] = tostring(u8:decode(guibuffers.clistparams.clist30.v))
											config_ini.UserClist[31] = tostring(u8:decode(guibuffers.clistparams.clist31.v))
											config_ini.UserClist[32] = tostring(u8:decode(guibuffers.clistparams.clist32.v))
											config_ini.UserClist[33] = tostring(u8:decode(guibuffers.clistparams.clist33.v))
											
											config_ini.UserGun[1] = tostring(u8:decode(guibuffers.gunparams.gun1.v))
											config_ini.UserGun[2] = tostring(u8:decode(guibuffers.gunparams.gun2.v))
											config_ini.UserGun[3] = tostring(u8:decode(guibuffers.gunparams.gun3.v))
											config_ini.UserGun[4] = tostring(u8:decode(guibuffers.gunparams.gun4.v))
											config_ini.UserGun[5] = tostring(u8:decode(guibuffers.gunparams.gun5.v))
											config_ini.UserGun[6] = tostring(u8:decode(guibuffers.gunparams.gun6.v))
											config_ini.UserGun[7] = tostring(u8:decode(guibuffers.gunparams.gun7.v))

											config_ini.UserBinder[1] = tostring(u8:decode(guibuffers.ubinds.bind1.v))
											config_ini.UserBinder[2] = tostring(u8:decode(guibuffers.ubinds.bind2.v))
											config_ini.UserBinder[3] = tostring(u8:decode(guibuffers.ubinds.bind3.v))
											config_ini.UserBinder[4] = tostring(u8:decode(guibuffers.ubinds.bind4.v))
											config_ini.UserBinder[5] = tostring(u8:decode(guibuffers.ubinds.bind5.v))
											config_ini.UserBinder[6] = tostring(u8:decode(guibuffers.ubinds.bind6.v))
											config_ini.UserBinder[7] = tostring(u8:decode(guibuffers.ubinds.bind7.v))
											config_ini.UserBinder[8] = tostring(u8:decode(guibuffers.ubinds.bind8.v))
											config_ini.UserBinder[9] = tostring(u8:decode(guibuffers.ubinds.bind9.v))
											config_ini.UserBinder[10] = tostring(u8:decode(guibuffers.ubinds.bind10.v))
											config_ini.UserBinder[11] = tostring(u8:decode(guibuffers.ubinds.bind11.v))

											config_ini.UserCBinder[1] = tostring(u8:decode(guibuffers.ucbinds.bind1.v))
											config_ini.UserCBinder[2] = tostring(u8:decode(guibuffers.ucbinds.bind2.v))
											config_ini.UserCBinder[3] = tostring(u8:decode(guibuffers.ucbinds.bind3.v))
											config_ini.UserCBinder[4] = tostring(u8:decode(guibuffers.ucbinds.bind4.v))
											config_ini.UserCBinder[5] = tostring(u8:decode(guibuffers.ucbinds.bind5.v))
											config_ini.UserCBinder[6] = tostring(u8:decode(guibuffers.ucbinds.bind6.v))
											config_ini.UserCBinder[7] = tostring(u8:decode(guibuffers.ucbinds.bind7.v))
											config_ini.UserCBinder[8] = tostring(u8:decode(guibuffers.ucbinds.bind8.v))
											config_ini.UserCBinder[9] = tostring(u8:decode(guibuffers.ucbinds.bind9.v))
											config_ini.UserCBinder[10] = tostring(u8:decode(guibuffers.ucbinds.bind10.v))
											config_ini.UserCBinder[11] = tostring(u8:decode(guibuffers.ucbinds.bind11.v))
											config_ini.UserCBinder[12] = tostring(u8:decode(guibuffers.ucbinds.bind12.v))
											config_ini.UserCBinder[13] = tostring(u8:decode(guibuffers.ucbinds.bind13.v))
											config_ini.UserCBinder[14] = tostring(u8:decode(guibuffers.ucbinds.bind14.v))

											config_ini.UserCBinderC[1] = tostring(u8:decode(guibuffers.ucbindsc.bind1.v))
											config_ini.UserCBinderC[2] = tostring(u8:decode(guibuffers.ucbindsc.bind2.v))
											config_ini.UserCBinderC[3] = tostring(u8:decode(guibuffers.ucbindsc.bind3.v))
											config_ini.UserCBinderC[4] = tostring(u8:decode(guibuffers.ucbindsc.bind4.v))
											config_ini.UserCBinderC[5] = tostring(u8:decode(guibuffers.ucbindsc.bind5.v))
											config_ini.UserCBinderC[6] = tostring(u8:decode(guibuffers.ucbindsc.bind6.v))
											config_ini.UserCBinderC[7] = tostring(u8:decode(guibuffers.ucbindsc.bind7.v))
											config_ini.UserCBinderC[8] = tostring(u8:decode(guibuffers.ucbindsc.bind8.v))
											config_ini.UserCBinderC[9] = tostring(u8:decode(guibuffers.ucbindsc.bind9.v))
											config_ini.UserCBinderC[10] = tostring(u8:decode(guibuffers.ucbindsc.bind10.v))
											config_ini.UserCBinderC[11] = tostring(u8:decode(guibuffers.ucbindsc.bind11.v))
											config_ini.UserCBinderC[12] = tostring(u8:decode(guibuffers.ucbindsc.bind12.v))
											config_ini.UserCBinderC[13] = tostring(u8:decode(guibuffers.ucbindsc.bind13.v))
											config_ini.UserCBinderC[14] = tostring(u8:decode(guibuffers.ucbindsc.bind14.v))

											config_ini.rphr[1] = tostring(u8:decode(guibuffers.rphr.bind1.v))
											config_ini.rphr[2] = tostring(u8:decode(guibuffers.rphr.bind2.v))
											config_ini.rphr[3] = tostring(u8:decode(guibuffers.rphr.bind3.v))
											config_ini.rphr[4] = tostring(u8:decode(guibuffers.rphr.bind4.v))
											config_ini.rphr[5] = tostring(u8:decode(guibuffers.rphr.bind5.v))
											config_ini.rphr[6] = tostring(u8:decode(guibuffers.rphr.bind6.v))
											config_ini.rphr[7] = tostring(u8:decode(guibuffers.rphr.bind7.v))
											config_ini.rphr[8] = tostring(u8:decode(guibuffers.rphr.bind8.v))
											config_ini.rphr[9] = tostring(u8:decode(guibuffers.rphr.bind9.v))
											config_ini.rphr[10] = tostring(u8:decode(guibuffers.rphr.bind10.v))

											config_ini.Commands[1] = tostring(u8:decode(guibuffers.commands.command1.v))
											config_ini.Commands[2] = tostring(u8:decode(guibuffers.commands.command2.v))
											config_ini.Commands[3] = tostring(u8:decode(guibuffers.commands.command3.v))
											config_ini.Commands[4] = tostring(u8:decode(guibuffers.commands.command4.v))
											config_ini.Commands[5] = tostring(u8:decode(guibuffers.commands.command5.v))
											config_ini.Commands[6] = tostring(u8:decode(guibuffers.commands.command6.v))
											config_ini.Commands[7] = tostring(u8:decode(guibuffers.commands.command7.v))
											--config_ini.Commands[8] = tostring(u8:decode(guibuffers.commands.command8.v))
											config_ini.Commands[9] = tostring(u8:decode(guibuffers.commands.command9.v))
											config_ini.Commands[10] = tostring(u8:decode(guibuffers.commands.command10.v))
											config_ini.Commands[11] = tostring(u8:decode(guibuffers.commands.command11.v))
											config_ini.Commands[12] = tostring(u8:decode(guibuffers.commands.command12.v))
											config_ini.Commands[13] = tostring(u8:decode(guibuffers.commands.command13.v))
											config_ini.Commands[14] = tostring(u8:decode(guibuffers.commands.command14.v))
											config_ini.Commands[15] = tostring(u8:decode(guibuffers.commands.command15.v))
											config_ini.Commands[16] = tostring(u8:decode(guibuffers.commands.command16.v))
											config_ini.Commands[17] = tostring(u8:decode(guibuffers.commands.command17.v))
											config_ini.Commands[18] = tostring(u8:decode(guibuffers.commands.command18.v))
											config_ini.Commands[19] = tostring(u8:decode(guibuffers.commands.command19.v))
											config_ini.Commands[20] = tostring(u8:decode(guibuffers.commands.command20.v))
											config_ini.Commands[21] = tostring(u8:decode(guibuffers.commands.command21.v))
											config_ini.Commands[22] = tostring(u8:decode(guibuffers.commands.command22.v))
											config_ini.Commands[23] = tostring(u8:decode(guibuffers.commands.command23.v))
											--config_ini.Commands[24] = tostring(u8:decode(guibuffers.commands.command24.v))
											config_ini.Commands[25] = tostring(u8:decode(guibuffers.commands.command25.v))
											--config_ini.Commands[26] = tostring(u8:decode(guibuffers.commands.command26.v))
											config_ini.Commands[27] = tostring(u8:decode(guibuffers.commands.command27.v))
											config_ini.Commands[28] = tostring(u8:decode(guibuffers.commands.command28.v))
											--config_ini.Commands[29] = tostring(u8:decode(guibuffers.commands.command29.v))

											config_ini.Settings.PlayerFirstName = tostring(u8:decode(guibuffers.settings.fname.v))
											config_ini.Settings.PlayerSecondName = tostring(u8:decode(guibuffers.settings.sname.v))
											config_ini.Settings.PlayerRank = tostring(u8:decode(guibuffers.settings.rank.v))
											config_ini.Settings.timep = tostring(u8:decode(guibuffers.settings.timep.v))
											config_ini.Settings.PlayerU = tostring(u8:decode(guibuffers.settings.PlayerU.v))
											config_ini.Settings.useclist = tostring(u8:decode(guibuffers.settings.useclist.v))
											config_ini.Settings.tag = tostring(u8:decode(guibuffers.settings.tag.v))										
											PlayerU = config_ini.Settings.PlayerU
											useclist = config_ini.Settings.useclist
											tag = config_ini.Settings.tag == "" and "" or "" .. config_ini.Settings.tag .. " "

											config_ini.warnings[1] = tostring(u8:decode(guibuffers.warnings.war1.v))
											config_ini.warnings[2] = tostring(u8:decode(guibuffers.warnings.war2.v))
											config_ini.warnings[3] = tostring(u8:decode(guibuffers.warnings.war3.v))
											config_ini.warnings[4] = tostring(u8:decode(guibuffers.warnings.war4.v))

											config_ini.UserPieMenuNames[1] = tostring(u8:decode(guibuffers.UserPieMenu.names.name1.v))
											config_ini.UserPieMenuNames[2] = tostring(u8:decode(guibuffers.UserPieMenu.names.name2.v))
											config_ini.UserPieMenuNames[3] = tostring(u8:decode(guibuffers.UserPieMenu.names.name3.v))
											config_ini.UserPieMenuNames[4] = tostring(u8:decode(guibuffers.UserPieMenu.names.name4.v))
											config_ini.UserPieMenuNames[5] = tostring(u8:decode(guibuffers.UserPieMenu.names.name5.v))
											config_ini.UserPieMenuNames[6] = tostring(u8:decode(guibuffers.UserPieMenu.names.name6.v))
											config_ini.UserPieMenuNames[7] = tostring(u8:decode(guibuffers.UserPieMenu.names.name7.v))
											config_ini.UserPieMenuNames[8] = tostring(u8:decode(guibuffers.UserPieMenu.names.name8.v))
											config_ini.UserPieMenuNames[9] = tostring(u8:decode(guibuffers.UserPieMenu.names.name9.v))
											config_ini.UserPieMenuNames[10] = tostring(u8:decode(guibuffers.UserPieMenu.names.name10.v))

											config_ini.UserPieMenuActions[1] = tostring(u8:decode(guibuffers.UserPieMenu.actions.action1.v))
											config_ini.UserPieMenuActions[2] = tostring(u8:decode(guibuffers.UserPieMenu.actions.action2.v))
											config_ini.UserPieMenuActions[3] = tostring(u8:decode(guibuffers.UserPieMenu.actions.action3.v))
											config_ini.UserPieMenuActions[4] = tostring(u8:decode(guibuffers.UserPieMenu.actions.action4.v))
											config_ini.UserPieMenuActions[5] = tostring(u8:decode(guibuffers.UserPieMenu.actions.action5.v))
											config_ini.UserPieMenuActions[6] = tostring(u8:decode(guibuffers.UserPieMenu.actions.action6.v))
											config_ini.UserPieMenuActions[7] = tostring(u8:decode(guibuffers.UserPieMenu.actions.action7.v))
											config_ini.UserPieMenuActions[8] = tostring(u8:decode(guibuffers.UserPieMenu.actions.action8.v))
											config_ini.UserPieMenuActions[9] = tostring(u8:decode(guibuffers.UserPieMenu.actions.action9.v))
											config_ini.UserPieMenuActions[10] = tostring(u8:decode(guibuffers.UserPieMenu.actions.action10.v))
											
											config_ini.plus500[1] = tostring(u8:decode(guibuffers.plus500.plus500color.v))
											config_ini.plus500[2] = tostring(u8:decode(guibuffers.plus500.plus500size.v))
											config_ini.plus500[3] = tostring(u8:decode(guibuffers.plus500.plus500font.v))

											config_ini.fondset[1] = tostring(u8:decode(guibuffers.fond.fondcolor.v))
											config_ini.fondset[2] = tostring(u8:decode(guibuffers.fond.mycolor.v))

											config_ini.dial[1] = tostring(u8:decode(guibuffers.dial.med.v))
											config_ini.dial[2] = tostring(u8:decode(guibuffers.dial.rem.v))
											config_ini.dial[3] = tostring(u8:decode(guibuffers.dial.meh.v))
											config_ini.dial[4] = tostring(u8:decode(guibuffers.dial.azs.v))
											
											inicfg.save(config_ini, "config")
											sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Настройки были успешно сохранены", 0xFFFF0000)
											
											local u = access.saccess and "AKfycbwBG17iJ1Jpy5Ft9lmACSIZyrOA7QBydzgM1S12jkARF7ddEWA" or "AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc"

											
											local url = 'https://script.google.com/macros/s/' .. u .. '/exec?do=sets&key=' .. access.key .. '&state=' .. access.state .. '&config=123'
											local body = encodeJson(config_ini)
											
											os.remove("Moonloader\\POST_url.txt")
											os.remove("Moonloader\\POST_body.txt")
											os.remove("Moonloader\\POST_response.txt")
											os.remove("Moonloader\\run.bat")

											local url_log = "" .. getWorkingDirectory() .. "\\POST_url.txt"
											local urltext = io.open(url_log, "a")
											urltext:write(url)
											urltext:close()

											local body_log = "" .. getWorkingDirectory() .. "\\POST_body.txt"
											local bodytext = io.open(body_log, "a")
											bodytext:write(body)
											bodytext:close()

											--[[ local bat = "" .. getWorkingDirectory() .. "\\run.bat"
											local bb = io.open(bat, "a")
											bb:write('start "" "' .. thisScript().directory .. '\\POST_req.exe"')
											bb:close() ]]

											local c = 'start "" "' .. thisScript().directory .. '\\POST_req.exe"'
											os.execute(c)
											waitforsave = true
										end
							)
					end
					
					if needtoreset then
						lua_thread.create(function()
							sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Удаляю конфиг в таблице...", 0xFFFF0000)
							local u = access.saccess and "AKfycbwBG17iJ1Jpy5Ft9lmACSIZyrOA7QBydzgM1S12jkARF7ddEWA" or "AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc"
							local responsetext = req("https://script.google.com/macros/s/" .. u .. "/exec?do=sets&key=" .. access.key .. "&state=" .. access.state .. "&clearconfig=1")
							local re1 = regex.new("@@.@ Update complete @@..@.@") --
							local names = re1:match(responsetext)
							if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось сбросить конфиг в таблице.", 0xffff0000) end 

							sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Удаляю локальный файл конфига...", 0xFFFF0000)
							os.remove("Moonloader\\config\\config.ini")

							sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Настройки были успешно сброшены. Начинаю перезапуск...", 0xFFFF0000)
							needtoreset = false
							wait(0)
							thisScript():reload()
						end)
						needtoreset = false
					end
					
					if needtohold and not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() and (wasKeyPressed(vkeys.VK_W) or wasKeyPressed(vkeys.VK_S)) then needtohold = false isEnab, desH = 0, 0 end

					-- Изменение времени на сервере (хз как это работает пусть просто здесь будет)
					if time then setTimeOfDay(time, 0) end

					if SetMode then
							if isKeyDown(vkeys.VK_MBUTTON) then
									wait(300)
									if isKeyDown(vkeys.VK_MBUTTON) then
											config_ini.ovCoords.show_timeX, config_ini.ovCoords.show_timeY = 10, 10
											config_ini.ovCoords.show_placeX, config_ini.ovCoords.show_placeY = 10, 10
											config_ini.ovCoords.show_nameX, config_ini.ovCoords.show_nameY = 10, 10
											if isCharInAnyCar(PLAYER_PED) then config_ini.ovCoords.show_vehX, config_ini.ovCoords.show_vehY = 10, 10 end
											config_ini.ovCoords.show_hpX, config_ini.ovCoords.show_hpY = 10, 10
											config_ini.ovCoords.crosCarX, config_ini.ovCoords.crosCarY = 10, 10
											config_ini.ovCoords.show_targetImageX, config_ini.ovCoords.show_targetImageY = 10, 10
											config_ini.ovCoords.show_rkX, config_ini.show_rkY = 10, 10
											config_ini.ovCoords.show_afkX, config_ini.show_afkY = 10, 10
											config_ini.ovCoords.show_tecinfoX, config_ini.show_tecinfoY = 10, 10
											config_ini.ovCoords.show_squadX, config_ini.ovCoords.show_squadY = 10, 10
											config_ini.ovCoords.show_500X, config_ini.ovCoords.show_500Y = 10, 10
											config_ini.ovCoords.show_dindX, config_ini.ovCoords.show_dindY = 10, 10
											config_ini.ovCoords.show_moneyX, config_ini.ovCoords.show_moneyY = 10, 10
											config_ini.ovCoords.show_vehdamagemX, config_ini.ovCoords.show_vehdamagemY = 10, 10
											config_ini.ovCoords.show_vehdamagetX, config_ini.ovCoords.show_vehdamagetY = 10, 10
											config_ini.ovCoords.show_panelX, config_ini.ovCoords.show_panelY = 10, 10
											SetMode, SetModeFirstShow = true, true
											sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Координаты элементов были успешно сброшены", 0xFFFF0000)
									end
							end
					end

					-- автоснятие с предохранителя
					if config_ini.bools[57] == 1 then local weapid = tonumber(getCurrentCharWeapon(PLAYER_PED)) if autopred.current_weapon ~= weapid then autopred.current_weapon = weapid autopred.firstshot = false end end
						
					-- Активация Pie Menu
						if isKeyDown(makeHotKey(44)[1]) and piearr.action == 0 and not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then 
							wait(0) 
							piearr.pie_mode.v = true 
							imgui.ShowCursor = true 
						else 
							wait(0) 
							piearr.pie_mode.v = false 
							imgui.ShowCursor = false 
						end

					-- Действия по выбору в Pie Menu
					if piearr.action ~= 0 then
							local SB = formatbind(config_ini.UserPieMenuActions[piearr.action])
							if SB ~= nil then for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end end
							piearr.action = 0
					end

					if getCharHealth(PLAYER_PED) == 0 and (show.show_dmind.damind.hits[1] ~= 0 or show.show_dmind.damind.shots[1] ~= 0 or show.show_dmind.damind.damage[1] ~= 0) and config_ini.bools[44] == 1 then
						local acc = (show.show_dmind.damind.hits[1] == 0 or show.show_dmind.damind.shots[1] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[1] / (show.show_dmind.damind.shots[1] / 100))
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Нанесенный урон составил: {ff0000}" .. math.ceil(show.show_dmind.damind.damage[1]) .. ", {fffafa}а точность: {ff0000}" .. acc .. " {fffafa}процентов.", 0xFFFF0000)
						show.show_dmind.damind.shots = {[1] = 0, [23] = 0, [24] = 0, [25] = 0, [29] = 0, [30] = 0, [31] = 0, [33] = 0}
						show.show_dmind.damind.hits = {[1] = 0, [23] = 0, [24] = 0, [25] = 0, [29] = 0, [30] = 0, [31] = 0, [33] = 0}
						show.show_dmind.damind.damage = {[1] = 0, [23] = 0, [24] = 0, [25] = 0, [29] = 0, [30] = 0, [31] = 0, [33] = 0}

					end
			end
end

function aa_time()
	local startTime = os.time()                                               							 -- "Точка отсчёта"
    local connectingTime = 0
	
    while true do
        wait(1000)
       	 if sampGetGamestate() == 3 then                                                               -- Игровой статус равен "Подключён к серверу" (Что бы онлайн считало только, когда, мы подключены к серверу)
			time_index = time_index + 1	

			ses.online = ses.online + 1
			ses.full = os.time() - startTime
			ses.afk = ses.full - ses.online
			
	        online_ini.day_info.online = online_ini.day_info.online + 1 							 -- Онлайн за сегодня без учёта АФК	
	        online_ini.day_info.full = dfuls + ses.full												 -- Общий онлайн за сегодня
	        online_ini.day_info.afk = online_ini.day_info.full - online_ini.day_info.online			 -- АФК за сегодня

	        online_ini.week_info.online = online_ini.week_info.online + 1 							 -- Онлайн за неделю без учёта АФК
	        online_ini.week_info.full = wfuls + ses.full		 									 -- Общий онлайн за неделю
	        online_ini.week_info.afk = online_ini.week_info.full - online_ini.week_info.online		 -- АФК за неделю

            online_ini.online[tonumber(os.date('%w', os.time()))] = online_ini.day_info.full		 -- записываем текущий онлайн за день в ини файл

            connectingTime = 0
			if time_index == 60 then 
				time_index = 0 
				inicfg.save(online_ini, "online.ini") 
			end							 -- на каждую 60 секунду происходит сохранение ини
	    else
            connectingTime = connectingTime + 1                         
	    	startTime = startTime + 1									
	    end
    end
end

function cmd_mon()
	if not isCharInAnyCar(PLAYER_PED) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Необходимо быть в грузовике.", 0xFFFF0000) return end
	local idc = getCarModel(storeCarCharIsInNoSave(PLAYER_PED))
	if idc ~= 433 then 	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Необходимо быть в грузовике.", 0xFFFF0000) return end

	skipd[3][5] = true
	skipd[3][8][1] = true
	sampSendChat("/carm")
end

function cmd_get(sparams)
	lua_thread.create(function()
		if sparams == "guns" or sparams == "fuel" then sampSendChat("/get " .. sparams .. "") return end 
		if show.show_otm.v then  sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Дождитесь закрытия предыдущего диалога.", 0xFFFF0000) return end
		if sparams == "" or (sparams ~= "otm" and sparams ~= "lek") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Введите /get [otm/lek] для получения информации из таблицы отряда.", 0xFFFF0000) return end
		if sparams == "lek" and access.alevel < 1 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступно только авторизованным модераторам.", 0xFFFF0000) return end
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Начинаю опрос таблицы отряда.", 0xFFFF0000)
		if sparams == "otm" then
			show.otm_arr = {}
			local responsetext = req("https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=getotm")
			local otms = responsetext:match("%@%@%.%@ (.*) %@%@%.%.%@%.%@")
			if otms == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось опросить таблицу отряда.", 0xFFFF0000) return end
			local otmsarr = string.split(otms, "; ")
			local A_Index = 1
			local colorArr = {0xFFCD5C5C, 0xFFDC143C, 0xFFFF69B4, 0xFFDB7093, 0xFFFFA07A, 0xFFFF6347, 0xFFFF8C00, 0xFFFFA500, 0xFFFFFF00, 0xFFFFEFD5, 0xFFADFF2F, 0xFF90EE90, 0xFF228B22, 0xFF808000, 0xFF8FBC8F, 0xFF008080, 0xFF00FFFF, 0xFF4682B4, 0xFF00BFFF, 0xFFEE82EE, 0xFF000080, 0xFF9932CC, 0xFFFFFFFF, 0xFFFFEBCD, 0xFFFDF5E6, 0xFFDAA520, 0xFFDCDCDC, 0xFF8B4513, 0xFF000000, 0xFF8B0000}
			for k, l in ipairs(otmsarr) do
				local n, o = l:match("(.*) %- (.*)")
				if tonumber(o) ~= nil then A_Index = A_Index + 1 table.insert(show.otm_arr, {v = tonumber(o), name = n, color = colorArr[A_Index]}) end		
			end
			show.show_otm.v = true
		end

		if sparams == "lek" then
			local responsetext = req("https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=getlek&" .. moderpas .. "")
			local lek = responsetext:match("%@%@%.%@ (.*) %@%@%.%.%@%.%@")
			if lek == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось опросить таблицу отряда.", 0xFFFF0000) return end
			show.lek_arr = decodeJson(lek)
			show.show_lek.v = true
		end
	end)

	
end

function cmd_toggle()
	skipd[1].obool = not skipd[1].obool
	sampAddChatMessage(skipd[1].obool and "{FF0000}[LUA]: {FFFAFA}Пропуск диалога включен." or "{FF0000}[LUA]: {FFFAFA}Пропуск диалога отключен.", 0xFFFF0000)
end

function cmd_scr(sparams)
	if sparams ~= "exit" then sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Введите /scr exit для отключения сркипта.", 0xFFFF0000) return end
	
	thisScript():unload()	
end

function cmd_dclean()
	local acc = (show.show_dmind.damind.hits[1] == 0 or show.show_dmind.damind.shots[1] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[1] / (show.show_dmind.damind.shots[1] / 100))
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Нанесенный урон составил: {ff0000}" .. math.ceil(show.show_dmind.damind.damage[1]) .. ", {fffafa}а точность: {ff0000}" .. acc .. " {fffafa}процентов.", 0xFFFF0000)
	show.show_dmind.damind.shots = {[1] = 0, [23] = 0, [24] = 0, [25] = 0, [29] = 0, [30] = 0, [31] = 0, [33] = 0}
	show.show_dmind.damind.hits = {[1] = 0, [23] = 0, [24] = 0, [25] = 0, [29] = 0, [30] = 0, [31] = 0, [33] = 0}
	show.show_dmind.damind.damage = {[1] = 0, [23] = 0, [24] = 0, [25] = 0, [29] = 0, [30] = 0, [31] = 0, [33] = 0}
end

function cmd_s()
		lua_thread.create(
				function()
						for k, v in ipairs(config_ini.HotKey) do local hk = makeHotKey(k) if hk[1] ~= 0 then rkeys.unRegisterHotKey(hk) end end

						for k, v in ipairs(config_ini.Commands) do sampUnregisterChatCommand(v) end

						for k, v in ipairs(config_ini.UserCBinderC) do sampUnregisterChatCommand(v) end

						sampUnregisterChatCommand("commandhelp")
						sampUnregisterChatCommand("bugreport")
						sampUnregisterChatCommand("mkv")
						sampUnregisterChatCommand("bkv")
						sampUnregisterChatCommand("lej")
						sampUnregisterChatCommand("bp")
						sampUnregisterChatCommand("cars")

						if access.alevel > -1 then	sampUnregisterChatCommand("balogin") end
						if access.alevel > 0 then sampUnregisterChatCommand("check") sampUnregisterChatCommand ("lek") sampUnregisterChatCommand("pcheck") sampUnregisterChatCommand("tren") end
						if access.alevel > 1 then sampUnregisterChatCommand("padd") sampUnregisterChatCommand("pdel") sampUnregisterChatCommand("reg")	sampUnregisterChatCommand("ban") sampUnregisterChatCommand("add") sampUnregisterChatCommand("del") sampUnregisterChatCommand("change") sampUnregisterChatCommand("mark") end
						if access.alevel > 2 then sampUnregisterChatCommand("moder") sampUnregisterChatCommand("otm") sampUnregisterChatCommand("fond") sampUnregisterChatCommand("serj") end

						piearr.action = 0
						piearr.pie_mode.v = false -- режим PieMenu
						piearr.pie_keyid = 0
						piearr.pie_elements = {}

						suspendkeys = 1
						guis.mainw.v = not guis.mainw.v
				end
		)
end

function cmd_refoffm()
	sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Начинаю обновлять список игроков.", 0xFFFF0000)
	refoffmembers()
	sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Обновление завершено.", 0xFFFF0000)
end

function cmd_duel(sparams)
	if sparams == "-1" then sampSendChat("/me наступил" .. RP .. " на брошенную перчатку") duel.mode = false duel.en.id = -1 return end
	local id = tonumber(sparams)
	local myid = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
	if id == nil or (id < 0 and id > 999) or not sampIsPlayerConnected(id) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
	if not sampGetCharHandleBySampPlayerId(id) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок не найден", 0xFFFF0000) return end
	local n, f = sampGetPlayerNickname(id):match("(.*)%_(.*)")
	sampSendChat("/me бросил" .. RP .. " перчатку под ноги " .. n .. " " .. f .. "")
	duel.mode = true
	duel.en.id = id
	--duel.en.hp = sampGetPlayerHealth(id)
	--duel.en.arm = sampGetPlayerArmor(id)
	--duel.my.hp = sampGetPlayerHealth(myid)
	--duel.my.arm = sampGetPlayerArmor(myid)
end

function cmd_mask()
	needtomask.mode = true
	sampSendChat("/acce")
end

function cmd_piss()
	sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Нельзя!", 0xFFFF0000)
end

function cmd_iznas()
	sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Нельзя!", 0xFFFF0000)
end

function hk_1()
		lua_thread.create(
				function()
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/f " .. tag .. "")
						sampSendChat("/seedo Голосовая связь активирована")
				end
		)
end

function hk_2()
		sampSendChat("/f " .. tag .. "Внимание! ОБОРотень угоняет грузовик снабжения! Открыть огонь!!!")
end

function cmd_freeze(sparams)
	if (sparams ~= "off" and sparams ~= "ids" and tonumber(sparams) == nil) then sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Введите /freeze [sID машины/ids/off].", 0xFFFF0000) return end
	if (sparams == "ids") then sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Включил отображение sID's на машинах.", 0xFFFF0000) freeze.sidmode = true return end
	if (sparams == "off") then sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Отключаю заморозку.", 0xFFFF0000) freeze.mode = false freeze.sidmode = false return end
	freeze.mode = not freeze.mode

	if not freeze.mode then sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Отключаю заморозку.", 0xFFFF0000) freeze.sidmode = false return end

	local id = tonumber(sparams)
	local res, car = sampGetCarHandleBySampVehicleId(id)
	if not res then sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Машины с данным sID нет в прорисовке.", 0xFFFF0000) return end

	freeze.x, freeze.y, freeze.z = getCarCoordinates(car)
	sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Машина успешно заморожена. Эффект будет продолжаться до тех пор, пока в машину кто-нибудь не сядет.", 0xFFFF0000)
	lua_thread.create(function()
		while freeze.mode do
			wait(0)
			local res, car = sampGetCarHandleBySampVehicleId(id)
			if not res then sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}Машина потеряна. Отключаю заморозку.", 0xFFFF0000) freeze.mode, freeze.sidmode = false, false return end
			local dr = getDriverOfCar(car)
			if dr ~= nil and dr > -1 then sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}В машине появился водитель. Отключаю заморозку.", 0xFFFF0000) freeze.mode, freeze.sidmode = false, false return end
			local x, y, z = getCarCoordinates(car)
			if (x ~= freeze.x) or (y ~= freeze.y) or (z ~= freeze.z) then setCarCoordinates(car, freeze.x, freeze.y, freeze.z) end
		end
	end)
end

function hk_3()
		lua_thread.create(
				function()
						if not showdialog(1, "Меню докладов", "{FFFAFA}[1] - Оборотень\n[2] - Сопровождение\n[3] - Догнали колонну в квадрате\n[4] - Забрали грузовик с квадрата\n[5] - Грузовик доставлен на базу\n[6] - Грузовик отремонтирован и продолжает путь\n[7] - Квадрат чист/зачищен\n[0] - Отмена", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
						res = waitForChooseInDialog(1)
						if res == "" then sampSendChat("/f " .. tag .. "Принято!") return end
						
						if not res or tonumber(res) == nil or (tonumber(res) < 0 or tonumber(res) > 7) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end

						if res == "1" then
								local zzz = {[1] = "Оборотень ликвидирован", [2] = "Два оборотня ликвидировано", [3] = "Три оборотня ликвидировано", [4] = "Четыре оборотня ликвидировано", [5] = "Пять оборотней ликвидировано", [6] = "Шесть оборотней ликвидировано", [7] = "Семь оборотней ликвидировано", [8] = "Восемь оборотней ликвидировано", [9] = "Девять оборотней ликвидировано", [10] = "Десять оборотней ликвидировано"}

								if not showdialog(1, "Оборотень", "Количество оборотней. От 1 до 10.", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or tonumber(res) == nil or zzz[tonumber(res)] == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end
								local kol = tonumber(res)

								wait(0)
								if not showdialog(1, "Оборотень", "Квадрат от А-1 до Я-24", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" or tonumber(res) == 0 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end
								local b, n = res:match("([А-Я])-(%d+)")
								if b == nil or (tonumber(n) < 1 or tonumber(n) > 24) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный квадрат.", 0xFFFF0000) return end
								local kv = "" .. b .. "-" .. n .. ""

								wait(0)
								if not showdialog(1, "Оборотень", "Грузовик спасен?\n[1] - грузовик(и) спасен(ы)\n[2] - грузовик не спасен\n[3] - несколько оборотней и один грузовик спасен", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or tonumber(res) == nil or tonumber(res) == 0 or (tonumber(res) < 0 or tonumber(res) > 3) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end

								local obdokl = "/f " .. tag .. "" .. zzz[kol] ..  ""
								local obdokl2 = iskv and " в квадрате " .. kv .. "." or " ."
								local obdokl3
								if tonumber(res) == 2 then obdokl3 = "" elseif tonumber(res) == 3 or kol == 1 then obdokl3 = " Грузовик спасен" elseif tonumber(res) == 1 and kol > 1 then obdokl3 = " Грузовики спасены" end
								local dokl = obdokl .. obdokl2 .. obdokl3
								sampSendChat(dokl)
						end

						if res == "2" then
								if not showdialog(1, "Укажите пункт назначения", "[1] - Los-Santos Police Department\n[2] - San-Fierro Police Department\n[3] - Las-Venturas Police Departmen\n[4] - Federal Bureau of Investigation\n[5] - San-Fierro Army\n[6] - San-Fierro\n[0] - Стелс (введите 0)", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 6)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end
								if tonumber(res) == 0 then sampSendChat("/f " .. tag .. "Выехали в сопровождение ВМО") return end
								local arr = {
										["1"] = "Police LS", ["ls"] = "Police LS", ["lspd"] = "Police LS", ["лс"] = "Police LS", ["лспд"] = "Police LS",
										["2"] = "Police SF", ["sfpd"] = "Police SF", ["сфпд"] = "Police SF",
										["3"] = "Police LV", ["lv"] = "Police LV", ["lvpd"] = "Police LV", ["лв"] = "Police LV", ["лвпд"] = "Police LV",
										["4"] = "FBI", ["fbi"] = "FBI", ["фбр"] = "FBI",
										["5"] = "Army SF", ["sfa"] = "Army SF", ["сфа"] = "Army SF",
										["6"] = "г. San-Fierro", ["sf"] = "г. San-Fierro", ["сф"] = "г. San-Fierro"
								}

								if arr[res] ~= nil then sampSendChat("/f " .. tag .. "Выехали в сопровождение ВМО до " .. arr[res] .. "") else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверно указан пункт назначения.", 0xFFFF0000) end
						end

						if res == "3" then
								if not showdialog(1, "Укажите пункт назначения", "[1] - Los-Santos Police Department\n[2] - San-Fierro Police Department\n[3] - Las-Venturas Police Departmen\n[4] - Federal Bureau of Investigation\n[5] - San-Fierro Army\n[6] - San-Fierro\n[0] - Стелс (введите 0)", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 6)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end
								if tonumber(res) == 0 then sampSendChat("/f " .. tag .. "Догнали колонну, сопровождаем.") return end
								local arr = {
										["1"] = "Police LS", ["ls"] = "Police LS", ["lspd"] = "Police LS", ["лс"] = "Police LS", ["лспд"] = "Police LS",
										["2"] = "Police SF", ["sfpd"] = "Police SF", ["сфпд"] = "Police SF",
										["3"] = "Police LV", ["lv"] = "Police LV", ["lvpd"] = "Police LV", ["лв"] = "Police LV", ["лвпд"] = "Police LV",
										["4"] = "FBI", ["fbi"] = "FBI", ["фбр"] = "FBI",
										["5"] = "Army SF", ["sfa"] = "Army SF", ["сфа"] = "Army SF",
										["6"] = "г. San-Fierro", ["sf"] = "г. San-Fierro", ["сф"] = "г. San-Fierro"
								}

								local kv = kvadrat()
								if arr[res] ~= nil then sampSendChat("/f " .. tag .. "Догнали колонну в квадрате " .. kv .. ", сопровождаем до " .. arr[res] .. "") else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверно указан пункт назначения.", 0xFFFF0000) end
						end

						if res == "4" then
								if not showdialog(1, "Куда везем(укажите пункт)", "\n[0] - Стелс\n[1] - База\n[2] - Las-Venturas Police Department\n[3] - Los-Santos Police Department\n[4] - San-Fierro Police Department\n[5] - San-Fierro Army\n[6] - Federal Bureau of Investigation\n[7] - San-Fierro", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 7)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end
								local kv = kvadrat()
								if tonumber(res) == 0 then lastKV.m = kv sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Запомнил квадрат " .. lastKV.m .. ".", 0xFFFF0000) sampSendChat("/f " .. tag .. "Забрали грузовик, везем дальше") return end
								local arr = {
										["1"] = "на базу", ["lva"] = "на базу", ["лва"] = "на базу",
										["2"] = "в Police LV", ["lv"] = "в Police LV", ["lvpd"] = "в Police LV", ["лв"] = "в Police LV", ["лвпд"] = "в Police LV",
										["3"] = "в Police LS", ["ls"] = "в Police LS", ["lspd"] = "в Police LS", ["лс"] = "в Police LS", ["лспд"] = "в Police LS",
										["4"] = "в Police SF", ["sfpd"] = "в Police SF", ["сфпд"] = "в Police SF",
										["5"] = "в Army SF", ["sfa"] = "в Army SF", ["сфа"] = "в Army SF",
										["6"] = "в FBI", ["fbi"] = "в FBI", ["фбр"] = "в FBI",
										["7"] = "в г. San-Fierro", ["sf"] = "в г. San-Fierro", ["сф"] = "в г. San-Fierro"
								}


								if arr[res] ~= nil then
										lastKV.m = kv
										sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Запомнил квадрат " .. lastKV.m .. ".", 0xFFFF0000)
										sampSendChat("/f " .. tag .. "Забрали грузовик в квадрате " .. kv .. ", везем " .. arr[res] .. "")
								else
										sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверно указан пункт назначения.", 0xFFFF0000)
								end
						end

						if res == "5" then
								if lastKV.m ~= "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}В последний раз вы забирали грузовик с квадрата " .. lastKV.m .. ".", 0xFFFF0000) lastKV.m = "none" end
								if not showdialog(1, "Откуда доставили", "Квадрат от А-1 до Я-24", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end
								local b, n = res:match("([А-Я])-(%d+)")
								if b == nil or (tonumber(n) < 1 or tonumber(n) > 24) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный квадрат.", 0xFFFF0000) return end
								local kv = "" .. b .. "-" .. n .. ""
								sampSendChat("/f " .. tag .. "Грузовик с квадрата " .. kv .. " доставлен на базу")
						end

						if res == "6" then
								if not showdialog(1, "Куда везем(укажите пункт)", "\n[0] - Стелс\n[1] - База\n[2] - Las-Venturas Police Department\n[3] - Los-Santos Police Department\n[4] - San-Fierro Police Department\n[5] - San-Fierro Army\n[6] - Federal Bureau of Investigation\n[7] - San-Fierro", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 7)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end
								if tonumber(res) == 0 then sampSendChat("/f " .. tag .. "Грузовик отремонтирован и продолжает путь") return end
								local arr = {
										["1"] = "на базу", ["lva"] = "на базу", ["лва"] = "на базу",
										["2"] = "в Police LS", ["ls"] = "в Police LS", ["lspd"] = "в Police LS", ["лс"] = "в Police LS", ["лспд"] = "в Police LS",
										["3"] = "в Police SF", ["sfpd"] = "в Police SF", ["сфпд"] = "в Police SF",
										["4"] = "в Police LV", ["lv"] = "в Police LV", ["lvpd"] = "в Police LV", ["лв"] = "в Police LV", ["лвпд"] = "в Police LV",
										["5"] = "в FBI", ["fbi"] = "в FBI", ["фбр"] = "в FBI",
										["6"] = "в Army SF", ["sfa"] = "в Army SF", ["сфа"] = "в Army SF",
										["7"] = "в г. San-Fierro", ["sf"] = "в г. San-Fierro", ["сф"] = "в г. San-Fierro"
								}

								local kv = kvadrat()
								if arr[res] ~= nil then sampSendChat("/f " .. tag .. "Грузовик отремонтирован в квадрате " .. kv .. " и продолжает путь " .. arr[res] .. "") else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверно указан пункт назначения.", 0xFFFF0000)	end
						end

						if res == "7" then
								if not showdialog(1, "Квадрат чист/зачищен", "\n[0] - квадрат зачищен\n[1] - квадрат чист", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 1))then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end
								local kv = kvadrat()
								if res == "0" then sampSendChat("/f " .. tag .. "Квадрат " .. kv .. " зачищен. Враждебные единицы нейтрализованы") else sampSendChat("/f " .. tag .. "Квадрат " .. kv .. " чист. Враждебные единицы не обнаружены") end
						end						
				end
		)
end

function hk_4()
	lua_thread.create(function()
		local key = CTaskArr["CurrentID"]
		if key == 0 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Событие не найдено.", 0xFFFF0000) return end
		if isKeyDown(makeHotKey(4)[1]) then
			wait(300)
			if isKeyDown(makeHotKey(4)[1]) then goto done end
		end

		if CTaskArr[1][key] == 1 then 
			sampSendChat("/f " .. tag .. "Принято, " .. CTaskArr[3][key] .. "!")
			CTaskArr[10][1] = CTaskArr[3][key]
			if sampGetPlayerIdByCharHandle(CTaskArr[10][7]) then
				local zone = calculateNamedZone(getCharCoordinates(CTaskArr[10][7]))
				if zone ~= "Unknown" then
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Жертва находится {FF0000}" .. zone .. ".", 0xfffffafa)
				end
			end
		end
		if CTaskArr[1][key] == 2 then sampSendChat("/f " .. tag .. "Принято, " .. CTaskArr[3][key] .. "!") end
		if CTaskArr[1][key] == 3 then sampSendChat("/clist 7") wait(1300) sampSendChat("/me надел" .. RP .. " " .. config_ini.UserClist[7] .. "") end
		if CTaskArr[1][key] == 4 then sampSendChat("/f " .. tag .. "Выехали в сопровождение ВМО " .. CTaskArr[3][key] .. "") end
		if CTaskArr[1][key] == 5 then sampSendChat("/f " .. tag .. "Взял" .. RP .. " грузовик, литраж " .. CTaskArr[10][2][1][1] .. ", загружаюсь на ГС") end
		if CTaskArr[1][key] == 6 then sampSendChat("/f " .. tag .. " " .. (lastKV.m == "none" and "Вернул" .. RP .. " грузовик в ангар, литраж " .. CTaskArr[3][key] .. "" or "Грузовик с кваддрата " .. lastKV.m .. " доставлен на базу. Литраж: " .. CTaskArr[3][key] .. "")  .. "") lastKV.m = "none" end
		if CTaskArr[1][key] == 7 then sampSendChat("/f " .. tag .. "Разгрузились на склад " .. CTaskArr[3][key] .. ", " .. CTaskArr[10][3] .. " тонн. ") end
		if CTaskArr[1][key] == 8 then sampSendChat("/repairkit") end
		if CTaskArr[1][key] == 9 then sampSendChat("/f " .. tag .. "Взял" .. RP .. " вертолет с вертолетной площадки, код " .. clists[sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))] .. ".") end
		if CTaskArr[1][key] == 10 then sampSendChat("/f " .. tag .. "Квадрат " .. CTaskArr[3][key] .. " зачищен. Враждебные единицы нейтрализованы") end
		if CTaskArr[1][key] == 11 then sampSendChat("/f " .. tag .. "Вернул" .. RP .. " вертолет.") end
		if CTaskArr[1][key] == 12 then sampSendChat("/dep MOH, разрешите врача в " .. CTaskArr[3][key] .. "? Ответ на код " .. select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) .. ".") end
		if CTaskArr[1][key] == 13 then sampSendChat("/aask Переверните мой транспорт пожалуйста.") end
		if CTaskArr[1][key] == 14 then sampSendChat("/f " .. tag .. "ВМО, выезжайте!") end
		if CTaskArr[1][key] == 15 then sampSendChat("/showpass " .. CTaskArr[3][key] .. "") wait(delay) sampSendChat("/me показал" .. RP .. " удостоверение в открытом виде") wait(delay) isSending = true sampSendChat("/do В удостоверении: Army LV | " .. config_ini.Settings.PlayerFirstName .. " " .. config_ini.Settings.PlayerSecondName .. " | " .. PlayerU .. " | " .. config_ini.Settings.PlayerRank .. "") isSending = false end
		if CTaskArr[1][key] == 16 then sampSendChat("/f " .. tag .. "Сетка, открывай! " .. CTaskArr[3][key] .. "") CTaskArr[10][12] = false end
			
		::done::
		table.remove(CTaskArr[1], key)
		table.remove(CTaskArr[2], key)
		table.remove(CTaskArr[3], key)
		CTaskArr["CurrentID"] = 0
		while isKeyDown(0x5D) do wait(0) end
	end)
end

function hk_5()
		lua_thread.create(
				function()
						wait(0)
						sampSendChat("Здравия желаю! " .. config_ini.Settings.PlayerRank .. " " .. config_ini.Settings.PlayerFirstName .. " " .. config_ini.Settings.PlayerSecondName .. "")
						wait(1600)
						sampSendChat("Предъявите ваши документы")
				end
		)
end

function hk_6()
		lua_thread.create(
				function()
						wait(0)
						local A_Index = 0
						local c = ismegaphone() and "/m" or "/s"
						while true do
								if A_Index == 20 then break end
								local text = sampGetChatString(99 - A_Index)

								local re1 = regex.new("(.*)\\_(.*) крикнула?\\: Внимание\\! При помехе движения грузовику снабжения мы имеем право открыть огонь на поражение\\!\\!\\!")
								local re2 = regex.new("\\{\\{ Солдат (.*)\\_(.*)\\: Внимание\\! При помехе движения грузовику снабжения мы имеем право открыть огонь на поражение\\! \\}\\}")
								if re1:match(text) ~= nil or re2:match(text) ~= nil then sampSendChat("" .. c .. " Быстро отдалитесь от грузовика снабжения! Или мы откроем огонь на поражение!") return end
								A_Index = A_Index + 1
						-- Aleksandr_Belka крикнул: Внимание! При помехе движения грузовику снабжения мы имеем право открыть огонь на поражение!!!
						-- Aleksandr_Belka кричит: Водитель! Немедленно остановитесь!!!
						-- {{ Солдат Aleksandr_Belka: Водитель! Немедленно остановитесь! }}
						end
						sampSendChat("" .. c .. " Внимание! При помехе движения грузовику снабжения мы имеем право открыть огонь на поражение!")
				end
		)
end

function hk_7()
	lua_thread.create(function()
		wait(0)

		local c = ismegaphone() and "/m" or "/s"
		local carr = {}
		local car_w, car_h = getScreenResolution()
		local minx, maxx, miny, maxy = car_w / 2 - 500, car_w / 2 + 500, car_h / 2 - 300, car_h / 2 + 300
		local carhandles = getcars()
		if carhandles ~= nil then
			for k, v in pairs(carhandles) do
				if doesVehicleExist(v) and isCarOnScreen(v) then
					local ignore = {487, 488, 497, 476, 548, 563, 593}
					local idcar = getCarModel(v)
					if not indexof(idcar, ignore) and getDriverOfCar(v) ~= nil then
						local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
						local cX, cY, cZ = getCarCoordinates(v)
						local distanse = math.ceil(math.sqrt( ((myX-cX)^2) + ((myY-cY)^2) + ((myZ-cZ)^2)))
						if distanse < 150 then
							local car_xi, car_yi = convert3DCoordsToScreen(cX, cY, cZ)
							if car_xi > minx and car_xi < maxx and car_yi > miny and car_yi < maxy and isLineOfSightClear(myX, myY, myZ, cX, cY, cZ, true, false, false, true, false) and at(v) then
								local idcar = getCarModel(v)
								local iddr = select(2, sampGetPlayerIdByCharHandle(getDriverOfCar(v)))
								local carname =  tVehicleNames[idcar - 399]

								local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
								local cX, cY, cZ = getCarCoordinates(v)
								local distanse = math.ceil(math.sqrt( ((myX-cX)^2) + ((myY-cY)^2) + ((myZ-cZ)^2)))
								local mindist = ismegaphone() and 59 or 29
								if distanse > mindist then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Цель слишком далеко.", 0xFFFF0000) break end 
								sampSendChat("" .. c .. " Это Армия ЛВ. Водитель " .. carname .. " с номерами AX-" .. iddr .. "-XA, прижаться к обочине и остановиться!")
								wait(5000)
								local speed = math.floor(getCarSpeed(v) * 2)
								if speed > 25 then 
									if distanse > mindist then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Цель слишком далеко.", 0xFFFF0000) break end 
									sampSendChat("" .. c .. " Это Армия ЛВ. Водитель " .. carname .. " с номерами AX-" .. iddr .. "-XA, это последнее предупреждение!")
									wait(600)
									sampSendChat("" .. c .. " Прижаться к обочине и остановиться! В противном случае мы откроем огонь!") 
								end					
								return
							end
						end
					end
				end
			end
		end

		local A_Index = 0	
		local text = isCharInAnyCar(PLAYER_PED) and "Водитель, немедленно остановитесь!" or "Стоять!"
		local text2 = isCharInAnyCar(PLAYER_PED) and "Водитель, немедленно остановитесь! Или мы откроем огонь на поражение!" or "Стоять! Стрелять буду!"
		while true do
			if A_Index == 20 then break end
			local ch = sampGetChatString(99 - A_Index)
			local re = regex.new("(.*\\_.* крикнула?|\\{\\{ Солдат .*\\_.*)\\: (Водитель, немедленно остановитесь|Стоять)\\!(\\!\\!| \\}\\})")
			--[[ local re1 = regex.new("(.*)\\_(.*) крикнула?\\: Водитель\\! Немедленно остановитесь\\!\\!\\!")
			local re2 = regex.new("\\{\\{ Солдат (.*)\\_(.*)\\: Водитель\\! Немедленно остановитесь\\! \\}\\}") ]]
			if re:match(ch) ~= nil then sampSendChat("" .. c .. " " .. text2 .. "") return end
			A_Index = A_Index + 1
			-- Aleksandr_Belka крикнул: Водитель! Немедленно остановитесь!!!
			-- {{ Солдат Aleksandr_Belka: Водитель! Немедленно остановитесь! }}
		end

		sampSendChat("" .. c .. " " .. text .. "") 
		return		
	end)
end

function hk_8()
	lua_thread.create(function()
		wait(0)
		local A_Index = 0
		local c = ismegaphone() and "/m" or "/s"
		if not isCharInArea2d(PLAYER_PED, -84, 1606, 464, 2148, false) then
				sampSendChat("" .. c .. " Внимание! Вы вблизи границы охраняемого объекта! При её пересечении, откроем огонь на поражение!")
		else
			while true do
				if A_Index == 20 then break end
				local text = sampGetChatString(99 - A_Index)
				local re1 = regex.new("(.*)\\_(.*) крикнула?\\: Внимание\\! Вы находитесь на охраняемой территории\\! Немедленно покиньте её\\!\\!\\!")
				local re2 = regex.new("\\{\\{ Солдат (.*)\\_(.*)\\: Внимание\\! Вы находитесь на охраняемой территории\\! Немедленно покиньте её\\! \\}\\}")
				if re1:match(text) ~= nil or re2:match(text) ~= nil then sampSendChat("" .. c .. " Быстро покинули охраняемую территорию! Или мы откроем огонь на поражение!") return end
				A_Index = A_Index + 1
			end
			
			sampSendChat("" .. c .. " Внимание! Вы находитесь на охраняемой территории! Немедленно покиньте её!")
		end
	end
)
end

function hk_9()
		local c = ismegaphone() and "/m" or "/s"
		sampSendChat("" .. c .. " Всем стоять! Руки вверх, бросить оружие, морды в пол! Работает \"С.О.П.Т.\"!")
end

function hk_10()
		lua_thread.create(
				function()
						if not showdialog(1, "Смена цвета", "0-33", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
						local res = waitForChooseInDialog(1)
						if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 33)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end

						local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						if not result then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось узнать свой ID", 0xFFFF0000) return end
						local myclist = clists[sampGetPlayerColor(myid)]
						if myclist == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось узнать номер своего цвета", 0xFFFF0000) return end
						if tonumber(res) == myclist then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}На тебе сейчас этот клист.", 0xFFFF0000) return end
						local result, sid = sampGetPlayerSkin(myid)
						if not result then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось узнать ID своего скина", 0xFFFF0000) return end
						if ((sid == 287 or sid == 191) and myclist ~= 7 and myclist ~= 0) or (myclist ~= 0 and (sid ~= 287 and sid ~= 191)) then
								sampSendChat("/me снял" .. RP .. " " .. config_ini.UserClist[myclist] .. "")
								wait(1300)
						end

						sampSendChat("/clist " .. res .. "")
						if ((tonumber(res) == 7) and ((sid == 287) or (sid == 191))) or (tonumber(res) == 0) then return end

						wait(1300)
						sampSendChat("/me надел" .. RP .. " " .. config_ini.UserClist[tonumber(res)] .. "")
				end
		)
end

function hk_11()
		lua_thread.create(
				function()
						math.randomseed(os.time())
						local var = math.random(1, 3)
						if var == 1 then
							 sampSendChat("/me достал" .. RP .. " АИ-8")
							 wait(delay)
							 sampSendChat("/me достал" .. RP .. " бинт и мазь \"Звездочка\"")
							 wait(delay)
							 sampSendChat("/do Боец нанес на место ранения мазь")
							 wait(delay)
							 sampSendChat("/do Боец наложил на место ранения ватный тампон")
							 wait(delay)
							 sampSendChat("/me перемотал" .. RP .. " место ранения бинтом")
							 wait(delay)
							 sampSendChat("/do Боец повесил" .. RP .. " АИ-8 обратно, спрятав все в неё")
					elseif var == 2 then
							 sampSendChat("/me достал" .. RP .. " АИ-8")
							 wait(delay)
							 sampSendChat("/me достал" .. RP .. " половину таблетки Китанова и флягу с водой")
							 wait(delay)
							 sampSendChat("/do Боец выпил таблетку-обезбаливающее")
							 wait(delay)
							 sampSendChat("/do Боец запил таблетку водой")
							 wait(delay)
							 sampSendChat("/me повесил" .. RP .. " флягу обратно, закрыв её")
							 wait(delay)
							 sampSendChat("/do Боец повесил АИ-8 обратно, спрятав все в неё")
					elseif var == 3 then
							 sampSendChat("/me достал" .. RP .. " АИ-8")
							 wait(delay)
							 sampSendChat("/me достал" .. RP .. " пластырь, ватку и йод")
							 wait(delay)
							 sampSendChat("/do Боец обработал места царапин йодом")
							 wait(delay)
							 sampSendChat("/do Боец наложил пластырь на места царапин")
							 wait(delay)
							 sampSendChat("/me сложил" .. RP .. " все обратно")
							 wait(delay)
							 sampSendChat("/do Боец повесил АИ-8 обратно")
					end

					RKTimerTickCount = os.time()
			end
		)
end

function hk_12()
		lua_thread.create(
				function()
						sampSendChat("/me показал" .. RP .. " удостоверение в открытом виде")
						wait(delay)
						isSending = true
						sampSendChat("/do В удостоверении: Army LV | " .. config_ini.Settings.PlayerFirstName .. " " .. config_ini.Settings.PlayerSecondName .. " | " .. PlayerU .. " | " .. config_ini.Settings.PlayerRank .. "")
							isSending = false
					end
		)
end

function hk_13()
		if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then sampSendChat("/lock") end
end

function hk_14()
	if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() or not crosMode then return end

	--lua_thread.create(function() while isKeyDown(0x51) do wait(0) setGameKeyState(5, 0) end end)
	local sw, sh = getScreenResolution()
	if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
		local ttype, x, y, z = 0, 0, 0, 0 -- ttype: 1 - человек, 2 - машина, 3 - мотоцикл, 4 - фривей, 5 - матовоз, 6 - вертолет, 50 - местность
		local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
		local camX, camY, camZ = getActiveCameraCoordinates()
		local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, true, true, true, true, true, true, true, true)
		if not result then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось определить точку фокуса.", 0xFFFF0000) return end

		if colpoint.entityType == 3 then -- если цель - человек
			local ped = getCharPointerHandle(colpoint.entity)
			if ped == PLAYER_PED then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось определить точку фокуса.", 0xFFFF0000) return end
			x, y, z = getCharCoordinates(ped)
			ttype = 1
		end

		if colpoint.entityType == 2 then -- если цель техника
			local car = getVehiclePointerHandle(colpoint.entity)
			if isCharInAnyCar(PLAYER_PED) and storeCarCharIsInNoSave(PLAYER_PED) == car then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось определить точку фокуса.", 0xFFFF0000) return end
			local idcar = getCarModel(car)

			if idcar == 463 or idcar == 586 then 
				ttype = 4 
			elseif idcar == 433 then 
				ttype = 5 
			elseif vehtypes.motos[idcar] ~= nil then
				ttype = 3
			elseif vehtypes.helis[idcar] ~= nil or vehtypes.planes[idcar] ~= nil then
				ttype = 6
			else
				ttype = 2
			end

			x, y, z = getCarCoordinates(car)
		end

		if x == 0 then ttype, x, y, z = 50, colpoint.pos[1], colpoint.pos[2], colpoint.pos[3] end

		sampSendChat("/fs sq_message_id_4 " .. x .. " " .. y .. " " .. z .. " " .. ttype .. " end")
	end
end

function hk_16()

end

function hk_17()

end

function hk_18()

end

function hk_19()
		lua_thread.create(
				function()
						local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE) -- получить хендл персонажа, в которого целится игрок
						local id
						if not valid or not doesCharExist(ped) then -- если цель есть и персонаж существует
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Цель не найдена. Открываю диалоговое окно.", 0xFFFF0000)
								if not showdialog(1, "Поиск игрока в /members", "ID 0-999", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
								local res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 999)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end
								id = tonumber(res)
						else
								local result, id = sampGetPlayerIdByCharHandle(ped) -- получить samp-ид игрока по хендлу персонажа
								if not result then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось узнать ID цели", 0xFFFF0000) return end
						end

						if not sampIsPlayerConnected(id) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
						local Members1Text = getMembersText()
						local nick = sampGetPlayerNickname(id)
						local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
						clist = clist == "ffff" and "fffafa" or clist
						for v in Members1Text:gmatch('[^\n]+') do
								local _, zv, afk = v:match("%[%d+%] %[(%d+)%] " .. nick .. "	(%W*) %[%d+%](.*)")
								if zv ~= nil then afk = afk == nil and "" or afk sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}{" .. clist .. "}" .. nick .. "[" .. id .. "] {FFFAFA}- " .. zv .. " " .. afk .. "", 0xFFFF0000) return end
						end

						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}{" .. clist .. "}" .. nick .. "[" .. id .. "] {FFFAFA}- не найден в members", 0xFFFF0000)
				end
		)
end

function hk_20()
	lua_thread.create(function()
		wait(0)
		local A_Index = 0
		while true do
			if A_Index == 30 then break end
			local text = sampGetChatString(99 - A_Index)
			local re1
			if config_ini.bools[39] == 1 then re1 = regex.new(" \\{8470FF\\}(.*) \\{.*\\}(.*)\\_(.*)\\[(.*)\\]\\{8470FF\\}:  (.*)((.*)дравия(.*)аза|(.*)дравия(.*)елаю(.*)аза|(.*)дравия(.*)варищи(.*)|(.*)дравия(.*)елаю(.*)варищи(.*)|(.*)дравия(.*)елаю(.*)рмия(.*)|(.*)дравия(.*)рмия(.*)|(.*)дравия(.*)елаю(.*)сть(.*)|(.*)дравия(.*)сть(.*))") else re1 = regex.new(" (.*)  (.*)\\_(.*)\\[(.*)\\]:  (.*)((.*)дравия(.*)аза|(.*)дравия(.*)елаю(.*)аза|(.*)дравия(.*)варищи(.*)|(.*)дравия(.*)елаю(.*)варищи(.*)|(.*)дравия(.*)елаю(.*)рмия(.*)|(.*)дравия(.*)рмия(.*)|(.*)дравия(.*)елаю(.*)сть(.*)|(.*)дравия(.*)сть(.*))") end
			local zv, _, sname = re1:match(text)
			
			if zv ~= nil then
				local ranksnesokr = {["Ст.сержант"] = "Старший сержант", ["Мл.сержант"] = "Младший сержант", ["Ст.Лейтенант"] = "Старший лейтенант", ["Мл.Лейтенант"] = "Младший лейтенант"}
				local pRank = ranksnesokr[zv] ~= nil and ranksnesokr[zv] or zv
				sampSendChat("/f " .. tag .. "Здравия желаю, товарищ " .. pRank .. " " .. sname .. "!")
				return
			end
			A_Index = A_Index + 1
		end
		
		sampSendChat("/f " .. tag .. "Здравия желаю!")
	end)
end

function hk_21()
		local x, y, z = getCharCoordinates(PLAYER_PED)
		local zone = calculateNamedZone(x, y)
		if zone ~= "Unknown" then
			sampSendChat("/f " .. tag .. "SОS " .. zone .. "")
			return
		end

		local kv = kvadrat()
		if kv ~= nil then sampSendChat("/" .. (CTaskArr[10][4] and "u" or "f") .. " " .. tag .. "SOS " .. kv .. "") end
end

function hk_22()
		lua_thread.create(
				function()
						local res, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						if not res then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось узнать свой ID", 0xFFFF0000) return end
						local myclist = clists[sampGetPlayerColor(myid)]
						if myclist == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось узнать номер своего цвета", 0xFFFF0000) return end
						if myclist == 0 then
								sampSendChat("/clist " .. useclist .. "")
								wait(1300)
								local newmyclist = clists[sampGetPlayerColor(myid)]
								if newmyclist == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось узнать номер своего цвета", 0xFFFF0000) return end
								if newmyclist ~= tonumber(useclist) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Клист не был надет", 0xFFFF0000) return end
								sampSendChat("/me надел" .. RP .. " " .. config_ini.UserClist[newmyclist] .. "")
						else
								sampSendChat("/clist 0")
								wait(1300)
								local newmyclist = clists[sampGetPlayerColor(myid)]
								if newmyclist == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось узнать номер своего цвета", 0xFFFF0000) return end
								if newmyclist ~= 0 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Клист не был снят", 0xFFFF0000) return end
								sampSendChat("/me снял" .. RP .. " " .. config_ini.UserClist[myclist] .. "")
						end
				end
		)
end

function hk_23()
		lua_thread.create(
				function()
						wait(0)
						if not showdialog(1, "Меню поставок", "Выберите пункт\n[1] - Загрузить грузовик\n[2] - Разгрузить грузовик\n[3] - Доклад о разгрузке грузовика\n[4] - Доклад о выезде из/подъезде к базе", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
						local res = waitForChooseInDialog(1)
						if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 1 or tonumber(res) > 4)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end
						if type(tonumber(res)) ~= "number" or tonumber(res) < 1 or tonumber(res) > 4 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Введите число от 1 до 4.", 0xFFFF0000) return end
						local res = tonumber(res)
						if res == 1 then sampSendChat("/me взял" .. RP .. " ящики со склада") wait(delay) sampSendChat("/me загрузил" .. RP .. " ящики в грузовик") end
						if res == 2 then sampSendChat("/me взял" .. RP .. " ящики с грузовика") wait(delay) sampSendChat("/me разгрузил" .. RP .. " ящики на склад") end
						if res == 3 then
								local A_Index = 0
								while true do
										if A_Index == 30 then break end
										local text = sampGetChatString(99 - A_Index)
										local sklad, kol = text:match(" На складе (.*)%: (%d%d%d)%d%d%d%/%d+")
										if sklad ~= nil then sampSendChat("/f " .. tag .. "Разгрузились на склад " .. sklad .. ", " .. kol .. " тонн. ") return end
										A_Index = A_Index + 1
								end
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Сначала необходимо разгрузить грузовик", 0xFFFF0000)
						end
						if res == 4 then
								local X, Y = getCharCoordinates(playerPed)
								if X >= 276 and Y >= 1799 and X <= 389 and Y <= 2014 then
										sampSendChat("/f " .. tag .. "Сетка, открывай! Выезжает ВМО")
								else
										sampSendChat("/f " .. tag .. "Сетка, открывай! Подъезжает ВМО")
								end
						end
				end
		)
end

function hk_24()

end

function hk_25()
		lua_thread.create(
				function()
						local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE) -- получить хендл персонажа, в которого целится игрок
						local id
						local nick = ""
						if not valid or not doesCharExist(ped) then -- если цель есть и персонаж существует
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Цель не найдена. Открываю диалоговое окно.", 0xFFFF0000)
								if not showdialog(1, "Поиск игрока в ЧС", "ID 0-999 или ник", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
								local res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 999)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Диалог был закрыт.", 0xFFFF0000) return end
								if tonumber(res) == nil then nick = res else id = tonumber(res) end
						else
								local result, id = sampGetPlayerIdByCharHandle(ped) -- получить samp-ид игрока по хендлу персонажа
								if not result then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось узнать ID цели", 0xFFFF0000) return end
						end

						if nick == "" then
								if not sampIsPlayerConnected(id) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
								nick = sampGetPlayerNickname(id)
								id = tostring(id)
						else
								id = sampGetPlayerIdByNickname(nick) ~= nil and tostring(sampGetPlayerIdByNickname(nick)) or "-1"
						end

						if config_ini.bools[2] == 1 then
								sampSendChat("/me провел" .. RP .. " рукой по экрану OPSAT")
								wait(delay)
								sampSendChat("/me произвел" .. RP .. " поиск в черном списке Армии ЛВ по имени")
						end

						local url = 'http://srp-addons.ru/api/log.php?checkbl=' ..  nick .. '&f=Army%20LV&s=91.215.86.6:7777'
						local responsetext = u8:decode(decodebase64(req(url)))
						local arr = decodeJson(responsetext:match("%[(.*)%]"))
						if arr ~= nil then
							sampAddChatMessage("{FF8300}-----------=== Черный список Las-Venturas army ===-----------", 0xFFFF0000)
							sampAddChatMessage("{FF8300}Игрок: {FFFFFF}" .. nick .. " [" .. id .. "]{FF0000} найден в чёрном списке", 0xFFFF0000)
							sampAddChatMessage("{FF8300}Причина: {FFFFFF}" .. arr.reason .. "", 0xFFFF0000)
							sampAddChatMessage("{FF8300}Кто занёс: {FFFFFF}" .. arr.user .. "", 0xFFFF0000)
							sampAddChatMessage("{FF8300}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
						else
							sampAddChatMessage("{FF8300}Black List: Игрок: {FFFFFF}" .. nick .. " [" .. id .. "]{33AA33} в чёрном списке не найден", 0xFFFF0000)
						end
				end
		)
end

function hk_26()
		lua_thread.create(
				function()
						sampSendChat("Здравия желаю!")
						if config_ini.bools[3] ~= 1 then return end
						local res, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						if res then
								local res, sid = sampGetPlayerSkin(myid)
								if res and (sid == 191 or sid == 287) and not isCharInAnyCar(PLAYER_PED) then
									wait(delay)
									sampSendChat("q")
								end
						end
				end
		)
end

function hk_27()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[1])
						if SB == nil then return end
						if (config_ini.bools[4] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_28()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[2])
						if SB == nil then return end
						if (config_ini.bools[5] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_29()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[3])
						if SB == nil then return end
						if (config_ini.bools[6] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_30()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[4])
						if SB == nil then return end
						if (config_ini.bools[7] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_31()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[5])
						if SB == nil then return end
						if (config_ini.bools[8] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_32()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[6])
						if SB == nil then return end
						if (config_ini.bools[9] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_33()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[7])
						if SB == nil then return end
						if (config_ini.bools[10] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_34()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[8])
						if SB == nil then return end
						if (config_ini.bools[11] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_35()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[9])
						if SB == nil then return end
						if (config_ini.bools[12] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_36()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[10])
						if SB == nil then return end
						if (config_ini.bools[13] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_37()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[11])
						if SB == nil then return end
						if (config_ini.bools[14] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_38()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[12])
						if SB == nil then return end
						if (config_ini.bools[15] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_39()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[13])
						if SB == nil then return end
						if (config_ini.bools[16] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_40()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserBinder[14])
						if SB == nil then return end
						if (config_ini.bools[17] == 1) then
								for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
						else
								sampSetChatInputEnabled(true)
								sampSetChatInputText(SB[1])
						end
				end
		)
end

function hk_41()
	if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then needtohold = not needtohold if not needtohold then isEnab, desH = 0, 0 end end
end

function hk_42()
		lua_thread.create(
				function()
						local tarr = {}
						for k, v in ipairs(config_ini.rphr) do if v ~= "" then table.insert(tarr, v) end end
						math.randomseed(os.time())
						local num = math.random(1, table.maxn(tarr))
						if num == lastrand then if num == table.maxn(tarr) then num = 1 else num = num + 1 end end
						local SB = formatbind(tarr[num])
						if SB == nil then return end
						lastrand = num
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function hk_43()
		if not SetMode then
				-- тут нужно ждать зажатия клавиши
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Начата настройка местоположения элементов overlay", 0xFFFF0000)
				if isCharInAnyCar(PLAYER_PED) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Сейчас на экран выведены все возможные элементы", 0xFFFF0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Для вывода на экран всех элементов необходимо сесть в транспорт", 0xFFFF0000) end
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Перетащите элементы в нужное место и нажмите клавишу настройки - произойдет сохранение координат", 0xFFFF0000)
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Для сброса всех координат зажмите среднюю кнопку мыши", 0xFFFF0000)
				config_ini.bools[25], config_ini.bools[26], config_ini.bools[27], config_ini.bools[28], config_ini.bools[29], config_ini.bools[30], config_ini.bools[31], config_ini.bools[32], config_ini.bools[33], config_ini.bools[34], config_ini.bools[35], config_ini.bools[36], config_ini.bools[41], config_ini.bools[43], config_ini.bools[44], config_ini.bools[52], config_ini.bools[63], config_ini.bools[64] = 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
				if access.alevel == 3 or access.alevel == 6 then config_ini.bools[58] = 1 end
				SetMode, SetModeFirstShow = true, true
				imgui.ShowCursor, imgui.LockPlayer = true, true
		else
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Начинаю сохранение координат", 0xFFFF0000)
				config_ini.ovCoords.show_timeX, config_ini.ovCoords.show_timeY = s_coord["s_time"].x, s_coord["s_time"].y
				config_ini.ovCoords.show_placeX, config_ini.ovCoords.show_placeY = s_coord["s_place"].x, s_coord["s_place"].y
				config_ini.ovCoords.show_nameX, config_ini.ovCoords.show_nameY = s_coord["s_name"].x, s_coord["s_name"].y
				if isCharInAnyCar(PLAYER_PED) then config_ini.ovCoords.show_vehX, config_ini.ovCoords.show_vehY = s_coord["s_veh"].x, s_coord["s_veh"].y end
				config_ini.ovCoords.show_hpX, config_ini.ovCoords.show_hpY = s_coord["s_hp"].x, s_coord["s_hp"].y
				config_ini.ovCoords.crosCarX, config_ini.ovCoords.crosCarY = s_coord["s_targetCar"].x, s_coord["s_targetCar"].y
				config_ini.ovCoords.show_rkX, config_ini.ovCoords.show_rkY = s_coord["s_rk"].x, s_coord["s_rk"].y
				config_ini.ovCoords.show_afkX, config_ini.ovCoords.show_afkY = s_coord["s_afk"].x, s_coord["s_afk"].y
				config_ini.ovCoords.show_tecinfoX, config_ini.ovCoords.show_tecinfoY = s_coord["s_tecinfo"].x, s_coord["s_tecinfo"].y
				config_ini.ovCoords.show_squadX, config_ini.ovCoords.show_squadY = s_coord["s_squad"].x, s_coord["s_squad"].y
				config_ini.ovCoords.show_500X, config_ini.ovCoords.show_500Y = s_coord["s_500"].x, s_coord["s_500"].y
				config_ini.ovCoords.show_dindX, config_ini.ovCoords.show_dindY = s_coord["s_dind"].x, s_coord["s_dind"].y
				config_ini.ovCoords.show_damX, config_ini.ovCoords.show_damY = s_coord["s_dam"].x, s_coord["s_dam"].y
				config_ini.ovCoords.show_dam2X, config_ini.ovCoords.show_dam2Y = s_coord["s_dam2"].x, s_coord["s_dam2"].y
				config_ini.ovCoords.show_deathX, config_ini.ovCoords.show_deathY = s_coord["s_death"].x, s_coord["s_death"].y
				config_ini.ovCoords.show_vehdamagemX, config_ini.ovCoords.show_vehdamagemY = s_coord["s_vehdm"].x, s_coord["s_vehdm"].y
				config_ini.ovCoords.show_vehdamagetX, config_ini.ovCoords.show_vehdamagetY = s_coord["s_vehdt"].x, s_coord["s_vehdt"].y
				config_ini.ovCoords.show_panelX, config_ini.ovCoords.show_panelY = s_coord["s_panel"].x, s_coord["s_panel"].y
				if access.alevel == 3 or access.alevel == 6 then config_ini.ovCoords.show_moneyX, config_ini.ovCoords.show_moneyY = s_coord["s_money"].x, s_coord["s_money"].y end

				config_ini.bools[25] = togglebools.tab_overlay[1].v and 1 or 0
				config_ini.bools[26] = togglebools.tab_overlay[2].v and 1 or 0
				config_ini.bools[27] = togglebools.tab_overlay[3].v and 1 or 0
				config_ini.bools[28] = togglebools.tab_overlay[4].v and 1 or 0
				config_ini.bools[29] = togglebools.tab_overlay[5].v and 1 or 0
				config_ini.bools[30] = togglebools.tab_overlay[6].v and 1 or 0
				config_ini.bools[31] = togglebools.tab_overlay[7].v and 1 or 0
				config_ini.bools[32] = togglebools.tab_overlay[8].v and 1 or 0
				config_ini.bools[33] = togglebools.tab_overlay[9].v and 1 or 0
				config_ini.bools[34] = togglebools.tab_overlay[10].v and 1 or 0
				config_ini.bools[35] = togglebools.tab_overlay[11].v and 1 or 0
				config_ini.bools[36] = togglebools.tab_overlay[12].v and 1 or 0
				config_ini.bools[41] = togglebools.tab_overlay[15].v and 1 or 0
				config_ini.bools[43] = togglebools.tab_overlay[16].v and 1 or 0
				config_ini.bools[44] = togglebools.tab_overlay[17].v and 1 or 0
				config_ini.bools[52] = togglebools.tab_overlay[18].v and 1 or 0
				config_ini.bools[54] = togglebools.tab_overlay[19].v and 1 or 0
				config_ini.bools[63] = togglebools.tab_overlay[20].v and 1 or 0
				config_ini.bools[64] = togglebools.tab_overlay[21].v and 1 or 0
				config_ini.bools[58] = togglebools.tab_moder[1].v and 1 or 0
				SetMode, SetModeFirstShow, imgui.ShowCursor, imgui.LockPlayer = false, false, false, false
				needtosave = true
				--s_target, s_targetCar, s_hp, s_veh, s_name, s_place, s_time, s_rk, s_afk, s_tecinfo, s_500, s_dind, s_dam s_dam2, s_death, s_money, s_vehdm s_vehdt, s_panel
		end
end

function hk_45() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() and not isCharInAnyCar(PLAYER_PED) then setCurrentCharWeapon(PLAYER_PED, 0) end end -- first
function hk_46() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() and not isCharInAnyCar(PLAYER_PED) then local id = getAmmoInCharWeapon(PLAYER_PED, 24) > 0 and 24 or getAmmoInCharWeapon(PLAYER_PED, 23) > 0 and 23 or 0 if id ~= 0 then setCurrentCharWeapon(PLAYER_PED, id) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось найти оружие в инвентаре персонажа.") end end end -- deagle
function hk_47() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() and not isCharInAnyCar(PLAYER_PED) then setCurrentCharWeapon(PLAYER_PED, 25) end end -- shotgun
function hk_48() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() and not isCharInAnyCar(PLAYER_PED) then setCurrentCharWeapon(PLAYER_PED, 29) end end -- smg
function hk_49() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() and not isCharInAnyCar(PLAYER_PED) then local id = getAmmoInCharWeapon(PLAYER_PED, 31) > 0 and 31 or getAmmoInCharWeapon(PLAYER_PED, 30) > 0 and 30 or 0 if id ~= 0 then setCurrentCharWeapon(PLAYER_PED, id) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось найти оружие в инвентаре персонажа.") end end end -- m4
function hk_50() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() and not isCharInAnyCar(PLAYER_PED) then setCurrentCharWeapon(PLAYER_PED, 33) end end -- rifle
function hk_51() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() and not isCharInAnyCar(PLAYER_PED) then setCurrentCharWeapon(PLAYER_PED, 46) end end -- par

function hk_52() 
	if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() and isCharInAnyCar(PLAYER_PED) then 
		local car = storeCarCharIsInNoSave(PLAYER_PED) 
		if getDriverOfCar(car) == PLAYER_PED and not isCarInAirProper(car) then 
			lockPlayerControl(true) 
			while (isCarInAirProper(car) == false and isKeyDown(makeHotKey(52)[1])) do 
				wait(0) 
			end 
			
			lockPlayerControl(false) 
		end
	end
end --

function cmd_ob(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[1] .. " [количество] [квадрат/0 - текущий квадрат] [1-3]", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}1 - грузовик(и) спасен(ы); 2 - грузовик не спасен; 3 - несколько оборотней и один грузовик", 0xFFFF0000) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		local zzz = {[1] = "Оборотень ликвидирован", [2] = "Два оборотня ликвидировано", [3] = "Три оборотня ликвидировано", [4] = "Четыре оборотня ликвидировано", [5] = "Пять оборотней ликвидировано", [6] = "Шесть оборотней ликвидировано", [7] = "Семь оборотней ликвидировано", [8] = "Восемь оборотней ликвидировано", [9] = "Девять оборотней ликвидировано", [10] = "Десять оборотней ликвидировано"}
		if tonumber(params[1]) == nil or zzz[tonumber(params[1])] == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверное количество оборотней.", 0xFFFF0000) return end
		local kol = tonumber(params[1])
		if params[2] == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный квадрат.", 0xFFFF0000) return end
		local b, n = params[2]:match("([А-Я])-(%d+)")
		if (b == nil or (tonumber(n) < 1 or tonumber(n) > 24)) and (tonumber(params[2]) ~= 0) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный квадрат.", 0xFFFF0000) return end
		local kv = tonumber(params[2]) == 0 and kvadrat() or "" .. b .. "-" .. n .. ""
		if tonumber(params[3]) == nil or (tonumber(params[3]) < 1 or tonumber(params[3]) > 3) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр №3.", 0xFFFF0000) return end

		local obdokl = "/r " .. tag .. "" .. zzz[kol] ..  ""
		local obdokl2 = " в квадрате " .. kv .. "."
		local obdokl3
		if tonumber(params[3]) == 2 then obdokl3 = "" elseif tonumber(params[3]) == 3 or kol == 1 then obdokl3 = " Грузовик спасен" elseif tonumber(params[3]) == 1 and kol > 1 then obdokl3 = " Грузовики спасены" end
		local dokl = obdokl .. obdokl2 .. obdokl3
		sampSendChat(dokl)
end

function cmd_sopr(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[2] .. " [пункт назначения/0 - стелс]", 0xFFFF0000) return end
		local x, y, z = getCharCoordinates(PLAYER_PED)
		local zone = calculateZone(x, y, z)
		local arr = {
				["1"] = "Police LS", ["ls"] = "Police LS", ["lspd"] = "Police LS", ["лс"] = "Police LS", ["лспд"] = "Police LS",
				["2"] = "Police SF", ["sfpd"] = "Police SF", ["сфпд"] = "Police SF",
				["3"] = "Police LV", ["lv"] = "Police LV", ["lvpd"] = "Police LV", ["лв"] = "Police LV", ["лвпд"] = "Police LV",
				["4"] = "FBI", ["fbi"] = "FBI", ["фбр"] = "FBI",
				["5"] = "Army SF", ["sfa"] = "Army SF", ["сфа"] = "Army SF",
				["6"] = "г. San-Fierro", ["sf"] = "г. San-Fierro", ["сф"] = "г. San-Fierro"
		}

		if arr[sparams] == nil and sparams ~= "0" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверно указан пункт назначения", 0xFFFF0000) return end
		if zone == "Restricted Area" then
				if sparams == "0" then sampSendChat("/f " .. tag .. "Выехали в сопровождение ВМО") return end
				sampSendChat("/f " .. tag .. "Выехали в сопровождение ВМО до " .. arr[sparams] .. "")
		else
				if sparams == "0" then sampSendChat("/f " .. tag .. "Догнали колонну, сопровождаем") return end
				sampSendChat("/f " .. tag .. "Догнали колонну в квадрате " .. kvadrat() .. ", сопровождаем до " .. arr[sparams] .. "")
		end
end

function cmd_zgruz(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[3] .. " [пункт назначения/0 - стелс]", 0xFFFF0000) return end
		local arr = {
				["1"] = "на базу", ["lva"] = "на базу", ["лва"] = "на базу",
				["2"] = "в Police LS", ["ls"] = "в Police LS", ["lspd"] = "в Police LS", ["лс"] = "в Police LS", ["лспд"] = "в Police LS",
				["3"] = "в Police SF", ["sfpd"] = "в Police SF", ["сфпд"] = "в Police SF",
				["4"] = "в Police LV", ["lv"] = "в Police LV", ["lvpd"] = "в Police LV", ["лв"] = "в Police LV", ["лвпд"] = "в Police LV",
				["5"] = "в FBI", ["fbi"] = "в FBI", ["фбр"] = "в FBI",
				["6"] = "в Army SF", ["sfa"] = "в Army SF", ["сфа"] = "в Army SF",
				["7"] = "в г. San-Fierro", ["sf"] = "в г. San-Fierro", ["сф"] = "в г. San-Fierro"
		}

		if arr[sparams] == nil and sparams ~= "0" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверно указан пункт назначения", 0xFFFF0000) return end
		local kv = kvadrat()
		lastKV.m = kv
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Запомнил квадрат " .. lastKV.m .. ".", 0xFFFF0000)
		if sparams == "0" then sampSendChat("/f " .. tag .. "Забрали грузовик, везем дальше") return end
		sampSendChat("/f " .. tag .. "Забрали грузовик в квадрате " .. kv .. ", везем " .. arr[sparams] .. "")
end

function cmd_rgruz(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[4] .. " [пункт назначения/0 - стелс]", 0xFFFF0000) return end
		local arr = {
				["1"] = "на базу", ["lva"] = "на базу", ["лва"] = "на базу",
				["2"] = "в Police LS", ["ls"] = "в Police LS", ["lspd"] = "в Police LS", ["лс"] = "в Police LS", ["лспд"] = "в Police LS",
				["3"] = "в Police SF", ["sfpd"] = "в Police SF", ["сфпд"] = "в Police SF",
				["4"] = "в Police LV", ["lv"] = "в Police LV", ["lvpd"] = "в Police LV", ["лв"] = "в Police LV", ["лвпд"] = "в Police LV",
				["5"] = "в FBI", ["fbi"] = "в FBI", ["фбр"] = "в FBI",
				["6"] = "в Army SF", ["sfa"] = "в Army SF", ["сфа"] = "в Army SF",
				["7"] = "в г. San-Fierro", ["sf"] = "в г. San-Fierro", ["сф"] = "в г. San-Fierro"
		}

		if arr[sparams] == nil and sparams ~= "0" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверно указан пункт назначения", 0xFFFF0000) return end
		if sparams == "0" then sampSendChat("/f " .. tag .. "Отремонтировали грузовик, везем дальше") return end
		sampSendChat("/f " .. tag .. "Грузовик с квадрата " .. kvadrat() .. " отремонтирован и продолжает путь " .. arr[sparams] .. "")
end

function cmd_bgruz(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[5] .. " [mkv - последний квадрат/квадрат]", 0xFFFF0000) return end
		local kv = ""
		if sparams == "mkv" then if lastKV.m ~= "" then kv = lastKV.m lastKV.m = "none" else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось найти последний квадрат", 0xFFFF0000) return end end
		if kv == "" then
				local b, n = sparams:match("([А-Я])-(%d+)")
				if (b == nil or (tonumber(n) < 1 or tonumber(n) > 24)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный квадрат.", 0xFFFF0000) return end
				kv = "" .. b .. "-" .. n .. ""
		end

		sampSendChat("/f " .. tag .. "Грузовик с квадрата " .. kv .. " доставлен на базу")
end

function cmd_kv(sparams)
		if sparams == "" or (sparams ~= "0" and sparams ~= "1") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[6] .. " [0 - зачищен/1 - чист]", 0xFFFF0000) return end
		local d = sparams == "0" and "зачищен. Враждебные единицы нейтрализованы" or "чист. Враждебные единицы не обнаружены"
		sampSendChat("/f " .. tag .. "Квадрат " .. kvadrat() .. " " .. d .. "")
end

function cmd_e(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[7] .. " [0 - забрали бойца(ов)/1 - доставили бойца(ов)]", 0xFFFF0000) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		if params[1] == "0" then
				if params[2] == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Введите /" .. config_ini.Commands[7] .. " 0 [id1] ([id2]) ([id3])", 0xFFFF0000) return end
				local kv = kvadrat()
				lastKV.b = kv
				local d = "/r " .. tag .. "Забрали бойц"
				local d2 = ""
				local d3 = ""
				if params[3] ~= nil then
						d2 = "ов с квадрата " .. kv .. ". Жетоны: " .. params[2] .. " " .. params[3] .. ""
						d3 = params[4] ~= nil and " " .. params[4] .. "" or ""
						lastID.e = "" .. params[2] .. " " .. params[3] .. "" .. d3 .. ""
				else
						d2 = "а с квадрата " .. kv .. ". Жетон: " .. params[2] .. ""
						lastID.e = params[2]
				end

				sampSendChat(d .. d2 .. d3)
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Запомнил квадрат " .. lastKV.b .. ", ID: " .. lastID.e .. ".", 0xFFFF0000)
				return
		end

		if params[1] == "1" then
				if params[2] == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Введите /" .. config_ini.Commands[7] .. " 1 [откуда дост./bkv - посл. акт. кв.] [куда дост./0 - тек. кв.] [lej - посл. акт. id/[id1] ([id2]) ([id3])]", 0xFFFF0000) return end
				local kv = ""
				if params[2] == "bkv" then if lastKV.b == "none" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось найти последний квадрат", 0xFFFF0000) return else kv = lastKV.b lastKV.b = "none" end end
				kv = kv == "" and params[2] or kv
				local dkv = params[3] == "0" and kvadrat() or params[3]
				local ids = ""
				if params[4] == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный ID.", 0xFFFF0000) return end
				if params[4] == "lej" then if lastID.e ~= "none" then ids = lastID.e lastID.e = "none" else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось найти последние активные id", 0xFFFF0000) return end end
				if ids == "" then ids = params[4] if params[5] ~= nil then ids = "" .. params[4] .. " " .. params[5] .. "" end if params[6] ~= nil then ids = "" .. params[4] .. " " .. params[5] .. " " .. params[6] .. "" end end
				local d = ""
				if ids:len() > 3 then d = "/r " .. tag .. "Бойцы с " .. kv .. " доставлены к " .. dkv .. ". Жетоны: " .. ids .. "" else d = "/r " .. tag .. "Боец с " .. kv .. " доставлен к " .. dkv .. ". Жетон: " .. ids .. "" end
				sampSendChat(d)
				return
		end
end

function cmd_r(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[9] .. " [текст]", 0xFFFF0000) return end
		local t = strunsplit(sparams, 80)
		isSending = true
		lua_thread.create(function() for k, v in ipairs(t) do sampSendChat("/f " .. tag .. "" .. v .. "") wait(1300) end isSending = false end)
end

function cmd_pr(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[10] .. " [квадрат/место]", 0xFFFF0000) return end
		sampSendChat("/f " .. tag .. "Принято, " .. sparams .. "!")
end


function cmd_gr(sparams)
		lua_thread.create(
				function()
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[12] .. " [flash/shock/he/smoke/inc/tear]", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}flash - свето-шумовая, shock - шоковая, he - осколочная", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}smoke - дымовая, inc - зажигательная, tear - со слезоточивым газом", 0xFFFF0000) return end
						local tarr = {["flash"] = "светошумовую гранату \"М-84\"", ["shock"] = " шоковую гранату \"SRBG\"", ["smoke"] = "дымовую гранату \"M308-1\"", ["inc"] = "зажигательную гранату \"M14 TH3\"", ["tear"] = "гранату со слезоточивым газом \"РГД-2Б\"", ["he"] = "осколочную гранату \"РГД-5\""}
						if tarr[sparams] ~= nil then gr = tarr[sparams] sampSendChat("/me достал" .. RP .. " " .. gr .. " с сумки для гранат") wait(delay) sampSendChat("/me выдернул" .. RP .. " чеку") wait(delay) sampSendChat("/me бросил" .. RP .. " " .. gr .. " жертве под ноги") else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверное обозначение гранаты", 0xFFFF0000) end
				end
		)
end

function cmd_hit()
		lua_thread.create(
				function()
						wait(0)
						local weapid = tonumber(getCurrentCharWeapon(PLAYER_PED))
						local weap = otWeaponName[2][weapid]
						local rr = RP == "" and "" or "ла"
						if weap ~= nil then sampSendChat("/me нанес" .. rr .. " удар по голове жертвы прикладом " .. weap .. "") wait(delay) sampSendChat("/do Жертва потеряла сознание") wait(delay) sampSendChat("/me тащит жертву за ноги")else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Возьмите оружие с прикладом в руки.", 0xFFFF0000) end
				end
		)
end

function cmd_cl(sparams)
		lua_thread.create(
				function()
						wait(0)
						if tonumber(sparams) ~= nil and tonumber(sparams) >= 0 and tonumber(sparams) <= 33 then
								local res, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
								if not res then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось узнать свой ID", 0xFFFF0000) return end
								local myclist = clists[sampGetPlayerColor(myid)]
								if myclist == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось узнать номер своего цвета", 0xFFFF0000) return end
								if sparams == myclist then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}На тебе сейчас этот клист.", 0xFFFF0000) return end
								local res, sid = sampGetPlayerSkin(myid)
								if not res then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось узнать ID своего скина", 0xFFFF0000) return end
								if ((sid == 287 or sid == 191) and myclist ~= 7 and myclist ~= 0) or (myclist ~= 0 and (sid ~= 287 and sid ~= 191)) then
										sampSendChat("/me снял" .. RP .. " " .. config_ini.UserClist[myclist] .. "")
										wait(1300)
								end

								sampSendChat("/clist " .. sparams .. "")
								if ((tonumber(sparams) == 7) and ((sid == 287) or (sid == 191))) or (tonumber(sparams) == 0) then return end

								wait(1300)
								sampSendChat("/me надел" .. RP .. " " .. config_ini.UserClist[tonumber(sparams)] .. "")
						else
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[14] .. " [0-33]", 0xFFFF0000)
						end
				end
		)
end

function cmd_memb(sparams)
		lua_thread.create(
				function()
						wait(0)
						if sparams == "" or tonumber(sparams) == nil or (tonumber(sparams) < 0 or tonumber(sparams) > 999) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[16] .. " [id]", 0xFFFF0000) return end
						local id = tonumber(sparams)
						if not sampIsPlayerConnected(tonumber(id)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн.", 0xFFFF0000) return end

						local Members1Text = getMembersText()
						local nick = sampGetPlayerNickname(id)
						local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
						local clist = clist == "ffff" and "fffafa" or clist
						for v in Members1Text:gmatch('[^\n]+') do
								local _, zv, afk = v:match("%[%d+%] %[(%d+)%] " .. nick .. "	(%W*) %[%d+%](.*)")
								if zv ~= nil then afk = afk == nil and "" or afk sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}{" .. clist .. "}" .. nick .. "[" .. id .. "] {FFFAFA}- " .. zv .. " " .. afk .. "", 0xFFFF0000) return end
						end

						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}{" .. clist .. "}" .. nick .. "[" .. id .. "] {FFFAFA}- не найден в members", 0xFFFF0000)
				end
		)
end

function cmd_chs(sparams)
		lua_thread.create(
				function()
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[17] .. " [id]", 0xFFFF0000) return end
						local id = -1
						if tonumber(sparams) ~= nil and tonumber(sparams) >= 0 and tonumber(sparams) <= 999  then id = tonumber(sparams) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(sparams)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
						local nick = id == -1 and sparams or sampGetPlayerNickname(tonumber(sparams))
						local url = 'http://srp-addons.ru/api/log.php?checkbl=' ..  nick .. '&f=Army%20LV&s=91.215.86.6:7777'
						local responsetext = u8:decode(decodebase64(req(url)))
						local arr = decodeJson(responsetext:match("%[(.*)%]"))
						if arr ~= nil then
							sampAddChatMessage("{FF8300}-----------=== Черный список Las-Venturas army ===-----------", 0xFFFF0000)
							sampAddChatMessage("{FF8300}Игрок: {FFFFFF}" .. nick .. " [" .. id .. "]{FF0000} найден в чёрном списке", 0xFFFF0000)
							sampAddChatMessage("{FF8300}Причина: {FFFFFF}" .. arr.reason .. "", 0xFFFF0000)
							sampAddChatMessage("{FF8300}Кто занёс: {FFFFFF}" .. arr.user .. "", 0xFFFF0000)
							sampAddChatMessage("{FF8300}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
						else
							sampAddChatMessage("{FF8300}Black List: Игрок: {FFFFFF}" .. nick .. " [" .. id .. "]{33AA33} в чёрном списке не найден", 0xFFFF0000)
						end
				end
		)
end

function cmd_bugreport(sparams)
		lua_thread.create(
				function()
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /bugreport [текст]", 0xFFFF0000) return end
						sendtolog(sparams, 0)
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Сообщение было успешно отправлено", 0xFFFF0000)
				end
		)
end

function cmd_mp(sparams)
		lua_thread.create(
				function()
						if sparams ~= "load" and sparams ~= "unload" and sparams ~= "sdok" and sparams ~= "vdok" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[18] .. " [load/unload/sdok/vdok]", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}load - отыграть загрузку грузовика; unload - отыграть разгрузку грузовика", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}sdok - доклад о состоянии склада на который разгрузились; vdok - доклад о выезде/подъезде", 0xFFFF0000) return end
						wait(0)
						if sparams == "load" then sampSendChat("/me взял" .. RP .. " ящики со склада") wait(delay) sampSendChat("/me загрузил" .. RP .. " ящики в грузовик") end
						if sparams == "unload" then sampSendChat("/me взял" .. RP .. " ящики с грузовика") wait(delay) sampSendChat("/me разгрузил" .. RP .. " ящики на склад") end
						if sparams == "sdok" then
								local A_Index = 0
								while true do
										if A_Index == 30 then break end
										local text = sampGetChatString(99 - A_Index)
										local sklad, kol = text:match(" На складе (.*)%: (%d%d%d)%d%d%d%/%d+")
										if sklad ~= nil then sampSendChat("/f " .. tag .. "Разгрузились на склад " .. sklad .. ", " .. kol .. " тонн. ") return end
										A_Index = A_Index + 1
								end
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Сначала необходимо разгрузить грузовик", 0xFFFF0000)
						end

						if sparams == "vdok" then
								local X, Y = getCharCoordinates(playerPed)
								if X >= 276 and Y >= 1799 and X <= 389 and Y <= 2014 then
										sampSendChat("/f " .. tag .. "Сетка, открывай! Выезжает ВМО")
								else
										sampSendChat("/f " .. tag .. "Сетка, открывай! Подъезжает ВМО")
								end
						end
				end
		)
end

function cmd_z(sparams)
		lua_thread.create(
				function()
					wait(0)
					if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /" .. config_ini.Commands[19] .. " [текст]", 0xFFFF0000) return end
					local A_Index = 0
							while true do
									if A_Index == 30 then break end
									local text = sampGetChatString(99 - A_Index)
									local re1 = regex.new("SMS:(.*). Отправитель: (.*)_(.*)\\[(.*)\\]")
									local _, _, _, smsdid = re1:match(text)
									if smsdid ~= nil then sampSendChat("/t " .. smsdid .. " " .. sparams .. "") return end
									A_Index = A_Index + 1
							end
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}SMS не найден.", 0xFFFF0000)
				end
		)
end

function cmd_mem1()
	lua_thread.create(function()
		mem1 = {[1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}}
		local Members1Text = getMembersText()
		for v in Members1Text:gmatch('[^\n]+') do
			local n, id, fname, sname, zv, rank, afk = v:match("%[(%d+)%] %[(%d+)%] (%a+)_(%a+)	(%W*) %[(%d+)%](.*)")
			if n ~= nil then
				local afk = afk == nil and "" or afk
				local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
				local clist = clist == "ffff" and "fffafa" or clist
				local zvcol = tonumber(rank) >= 12 and "00BFFF" or (rank == 1 and clist == "fffafa") and "ff0000" or "fffafa"
				table.insert(mem1[1], n)
				table.insert(mem1[2], id)
				table.insert(mem1[3], "{" .. clist .. "}" .. fname .. "_" .. sname .. "")
				table.insert(mem1[4], "{" .. zvcol .. "}" .. zv .. "[" .. rank .. "]")
				table.insert(mem1[5], afk)
			end
		end

		show.show_mem1.v = true
	end)
end

function cmd_st(sparams)
		local hour = tonumber(sparams)
		if hour ~= nil and hour >= 0 and hour <= 23 then
				time = hour
				patch_samp_time_set(true)
		else
				patch_samp_time_set(false)
				time = nil
		end
end

function cmd_afk()
		afkstatus = not afkstatus
		local s = afkstatus and "включен" or "выключен"
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Режим АФК успешно " .. s .. ".", 0xFFFF0000)
		local offset = 3600 * tonumber(config_ini.Settings.timep)
		sampSendChat("/fs " .. (afkstatus and "sq_message_id_1_" .. (os.time() - offset) .. "" or "sq_message_id_2") .. "")
end

function cmd_sw(sparams)
		local weather = tonumber(sparams)
	  if weather ~= nil and weather >= 0 and weather <= 45 then
	    	forceWeatherNow(weather)
	  end
end

function cmd_mcall(sparams)
		lua_thread.create(
				function()
						wait(0)
						sampSendChat("/dir")
						--wait(delay)
						while not sampIsDialogActive() do wait(0) end
						sampSendDialogResponse(sampGetCurrentDialogId(), 1, 1)
						while sampGetDialogCaption() ~= "Работы" do wait(0) end
						wait(100)
						sampCloseCurrentDialogWithButton(1)
						while sampGetDialogCaption() ~= "Меню" do wait(0) end
						local MechanicksText = sampGetDialogText()
						sampCloseCurrentDialogWithButton(0) wait(100) sampCloseCurrentDialogWithButton(0) wait(100) sampCloseCurrentDialogWithButton(0)
						for v in MechanicksText:gmatch('[^\n]+') do
    						local n, fname, sname, id, numb, afk = v:match("%[(%d+)%] (%a+)_(%a+)%[(%d+)%]	(%d+)(.*)")
    						if n ~= nil then
										if sparams ~= "" and sparams ~= id then sampSendChat("/t " .. id .. " Все, механик больше не нужен.") wait(1300) end
										if sparams == "" then sampSendChat("/t " .. id .. " Нужен механик в квадрате " .. kvadrat() .. ", на чай дадим!") wait(1300) end
								end
						end
				end
		)
end

function cmd_showp(sparams)
		lua_thread.create(
					function()
							wait(0)
							if tonumber(sparams) ~= nil and tonumber(sparams) >= 0 and tonumber(sparams) <= 999 then sampSendChat("/showpass " .. sparams .. "") wait(delay) end
							sampSendChat("/me показал" .. RP .. " удостоверение в открытом виде")
							wait(delay)
							isSending = true
							sampSendChat("/do В удостоверении: Army LV | " .. config_ini.Settings.PlayerFirstName .. " " .. config_ini.Settings.PlayerSecondName .. " | " .. PlayerU .. " | " .. config_ini.Settings.PlayerRank .. "")
							isSending = false
						end
			)
end

function cmd_u1()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[1])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u2()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[2])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u3()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[3])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u4()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[4])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u5()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[5])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u6()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[6])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u7()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[7])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u8()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[8])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u9()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[9])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u10()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[10])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u11()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[11])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u12()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[12])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u13()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[13])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u14()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[14])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u15()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[15])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u16()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[16])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u17()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[17])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_u18()
		lua_thread.create(
				function()
						wait(0)
						local SB = formatbind(config_ini.UserCBinder[18])
						if SB == nil then return end
						for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end
				end
		)
end

function cmd_dokhelp()
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA/" .. config_ini.Commands[1] .. " [количество] [квадрат/0 - тек. квадрат] [1-3] - доложить о ликвидации оборотня", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}1 - грузовик(и) спасен(ы); 2 - грузовик не спасен; 3 - несколько оборотней и один грузовик", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[2] .. " [пункт назначения/0 - стелс] - доложить о начале сопровождения колонны", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[3] .. " [пункт назначения/0 - стелс] - доложить о эвакуации грузовика снабжения", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[4] .. " [пункт назначения/0 - стелс] - доложить о ремонте грузовика снабжения", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[5] .. " [откуда привезли/0 - последний активный квадрат] - доложить о доставке эвакуированного грузовика на базу", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[6] .. " [0 - зачищен/1 - чист] - доложить о статусе текущего квадрата", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[7] .. " [0 - забрали бойца/1 - боец доставлен] - доложить об эвакуации бойца", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[10] .. " [квадрат/место] - принять вызов в указанную точку", 0xFFFF0000)
end

function cmd_commandhelp(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /commandhelp [команда/list]", 0xFFFF0000) return end

		if sparams == config_ini.Commands[1] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA/" .. config_ini.Commands[1] .. " [количество] [квадрат/0 - тек. квадрат] [1-3] - доложить о ликвидации оборотня", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}1 - грузовик(и) спасен(ы); 2 - грузовик не спасен; 3 - несколько оборотней и один грузовик", 0xFFFF0000) end
		if sparams == config_ini.Commands[2] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[2] .. " [пункт назначения/0 - стелс] - доложить о начале сопровождения колонны", 0xFFFF0000) end
		if sparams == config_ini.Commands[3] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[3] .. " [пункт назначения/0 - стелс] - доложить о эвакуации грузовика снабжения", 0xFFFF0000) end
		if sparams == config_ini.Commands[4] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[4] .. " [пункт назначения/0 - стелс] - доложить о ремонте грузовика снабжения", 0xFFFF0000) end
		if sparams == config_ini.Commands[5] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[5] .. " [откуда привезли/0 - последний активный квадрат] - доложить о доставке эвакуированного грузовика на базу", 0xFFFF0000) end
		if sparams == config_ini.Commands[6] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[6] .. " [0 - зачищен/1 - чист] - доложить о статусе текущего квадрата", 0xFFFF0000) end
		if sparams == config_ini.Commands[7] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[7] .. " [0 - забрали бойца/1 - боец доставлен] - доложить об эвакуации бойца", 0xFFFF0000) end
		--if sparams == config_ini.Commands[8] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[8] .. "", 0xFFFF0000) end
		if sparams == config_ini.Commands[9] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[9] .. " [текст] - написать указанный текст в рацию с тегом", 0xFFFF0000) end
		if sparams == config_ini.Commands[10] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[10] .. " [квадрат/место] - принять вызов в указанную точку", 0xFFFF0000) end
		if sparams == config_ini.Commands[11] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[11] .. " - представиться и спросить документы", 0xFFFF0000) end
		if sparams == config_ini.Commands[12] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[12] .. " [flash/shock/he/smoke/inc/tear] - бросить указанную гранату", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}flash - свето-шумовая, shock - шоковая, he - осколочная", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}smoke - дымовая, inc - зажигательная, tear - со слезоточивым газом", 0xFFFF0000) end
		if sparams == config_ini.Commands[13] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[13] .. " - отыграть оглушение противника", 0xFFFF0000) end
		if sparams == config_ini.Commands[14] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[14] .. " [0-33] сменить цвет на указанный", 0xFFFF0000) end
		if sparams == config_ini.Commands[15] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[15] .. " - запустить таймер РК", 0xFFFF0000) end
		if sparams == config_ini.Commands[16] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[16] .. " [id] - проверить наличие указанного игрока в /members", 0xFFFF0000) end
		if sparams == config_ini.Commands[17] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[17] .. " [id/ник] - проверить указанного игрока на наличие в ЧС Армии ЛВ", 0xFFFF0000) end
		if sparams == config_ini.Commands[18] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[18] .. " [load/unload/sdok/vdok] - совершить указанное действие из меню поставок", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}load - отыграть загрузку грузовика; unload - отыграть разгрузку грузовика", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}sdok - доклад о состоянии склада на который разгрузились; vdok - доклад о выезде/подъезде", 0xFFFF0000) end
		if sparams == config_ini.Commands[19] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[19] .. " [текст] - написть SMS последнему отправителю", 0xFFFF0000) end
		if sparams == config_ini.Commands[20] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[20] .. " - альтернативный /members 1 с подсветкой имени в цвет клиста и подсветкой ранга", 0xFFFF0000) end
		if sparams == config_ini.Commands[21] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[21] .. " [0-45] - установить указанную погоду", 0xFFFF0000) end
		if sparams == config_ini.Commands[22] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[22] .. " [0-23] - установить указанное время", 0xFFFF0000) end
		--if sparams == config_ini.Commands[23] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[23] .. "", 0xFFFF0000) end
		--if sparams == config_ini.Commands[24] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[24] .. "", 0xFFFF0000) end
		if sparams == config_ini.Commands[25] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[25] .. " - переключить режим AFK", 0xFFFF0000) end
		--if sparams == config_ini.Commands[26] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[26] .. "", 0xFFFF0000) end
		if sparams == config_ini.Commands[27] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[27] .. " ([id]) - вызвать всех механиков в сети в свой квадрат", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}если указать id то всем, кроме указанного механика будет отправлено сообщение о том, что механик больше не нужен", 0xFFFF0000) end
		if sparams == config_ini.Commands[28] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[28] .. " ([id]) - показать паспорт (при указанном id) и удостоверение", 0xFFFF0000) end
		--if sparams == config_ini.Commands[29] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[29] .. "", 0xFFFF0000) end
		if sparams == "commandhelp" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/commandhelp [команда/list] - получить информацию по команде или список доступных команд", 0xFFFF0000) end
		if sparams == "bugreport" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/bugreport [текст] - отправить сообщение об ошибке или предложение по улучшению скрипта", 0xFFFF0000) end
		if sparams == "dokhelp" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/dokhelp - получить информацию о командах связанных с докладами", 0xFFFF0000) end
		if sparams == "mkv" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/mkv [квадрат/clear - очистить] - присвоить статус переменной mkv", 0xFFFF0000) end
		if sparams == "bkv" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/bkv [квадрат/clear - очистить] - присвоить статус переменной bkv", 0xFFFF0000) end
		if sparams == "lej" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/lej - [id1 (id2) (id3)/clear - очистить] - присвоить статус переменной lej", 0xFFFF0000) end
		if sparams == "show" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/show - показать главное окно биндера", 0xFFFF0000) end
		if sparams == "bp" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/bp - изменить настройки автоБП без сохранения (до релога)", 0xFFFF0000) end
end

function cmd_lej(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /lej [id1 (id2) (id3)/clear - очистить]", 0xFFFF0000) return end
		if sparams == "clear" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Переменная lej успешно очищена", 0xFFFF0000) lastID.e = "none" return end
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Переменной lej успешно присвоено значение " .. sparams .. "", 0xFFFF0000) lastID.e = sparams return
end

function cmd_bkv(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /bkv [квадрат/clear - очистить]", 0xFFFF0000) return end
		if sparams == "clear" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Переменная bkv успешно очищена", 0xFFFF0000) lastKV.b = "none" return end
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Переменной bkv успешно присвоено значение " .. sparams .. "", 0xFFFF0000) lastKV.b = sparams return
end

function cmd_mkv(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /mkv [квадрат/clear - очистить]", 0xFFFF0000) return end
		if sparams == "clear" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Переменная mkv успешно очищена", 0xFFFF0000) lastKV.m = "none" return end
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Переменной mkv успешно присвоено значение " .. sparams .. "", 0xFFFF0000) lastKV.m = sparams return
end

function cmd_bp(sparams)
		if sparams ~= "deagle" and sparams ~= "shotgun"  and sparams ~= "smg" and sparams ~= "rifle" and sparams ~= "m4" and sparams ~= "par"  and sparams ~= "ot"  and sparams ~= "status" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /bp [deagle/shotgun/m4/smg/rifle/par/ot/status]", 0xFFFF0000) return end
		if sparams == "status" then
				local color = AutoDeagle and "00FF00" or "FF0000"
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Desert eagle: {" .. color .. "}" .. tostring(AutoDeagle) .. "", 0xFFFF0000)
				local color = AutoShotgun and "00FF00" or "FF0000"
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Shotgun: {" .. color .. "}" .. tostring(AutoShotgun) .. "", 0xFFFF0000)
				local color = AutoSMG and "00FF00" or "FF0000"
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}SMG: {" .. color .. "}" .. tostring(AutoSMG) .. "", 0xFFFF0000)
				local color = AutoRifle and "00FF00" or "FF0000"
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Country Rifle: {" .. color .. "}" .. tostring(AutoRifle) .. "", 0xFFFF0000)
				local color = AutoM4A1 and "00FF00" or "FF0000"
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}M4A1: {" .. color .. "}" .. tostring(AutoM4A1) .. "", 0xFFFF0000)
				local color = AutoPar and "00FF00" or "FF0000"
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Парашют: {" .. color .. "}" .. tostring(AutoPar) .. "", 0xFFFF0000)
				local color = AutoOt and "00FF00" or "FF0000"
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Отыгровка: {" .. color .. "}" .. tostring(AutoOt) .. "", 0xFFFF0000)
		end

		if sparams == "deagle" then AutoDeagle = not AutoDeagle local color = AutoDeagle and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Статус Desert Eagle установлен на: {" .. color .. "}" .. tostring(AutoDeagle) .. "", 0xFFFF0000) end
		if sparams == "shotgun" then AutoShotgun = not AutoShotgun local color = AutoShotgun and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Статус Shotgun установлен на: {" .. color .. "}" .. tostring(AutoShotgun) .. "", 0xFFFF0000) end
		if sparams == "smg" then AutoSMG = not AutoSMG local color = AutoSMG and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Статус SMG установлен на: {" .. color .. "}" .. tostring(AutoSMG) .. "", 0xFFFF0000) end
		if sparams == "rifle" then AutoRifle = not AutoRifle local color = AutoRifle and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Статус Country Rifle установлен на: {" .. color .. "}" .. tostring(AutoRifle) .. "", 0xFFFF0000) end
		if sparams == "m4" then AutoM4A1 = not AutoM4A1 local color = AutoM4A1 and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Статус M4A1 установлен на: {" .. color .. "}" .. tostring(AutoM4A1) .. "", 0xFFFF0000) end
		if sparams == "par" then AutoPar = not AutoPar local color = AutoPar and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Статус парашюта установлен на: {" .. color .. "}" .. tostring(AutoPar) .. "", 0xFFFF0000) end
		if sparams == "ot" then AutoOt = not AutoOt local color = AutoOt and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Статус отыгровки установлен на: {" .. color .. "}" .. tostring(AutoOt) .. "", 0xFFFF0000) end
end

--[[ function cmd_cars()
	 	if table.maxn(carsident) == 0 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}К данному моменту вы не целились в неизвестные автомобили.", 0xFFFF0000) return end
		lua_thread.create(
				function()
						if not showdialog(0, "Помощь в идентификации", "{FFFAFA}Сейчас скрипт будет вам показывать информацию о каждой неизвестной машине в которую вы целились до этих пор.\nВаша задача - помочь определить принадлежность транспорта к какой-либо фракции или работе или аренде.\nЕсли это арендная машина - укажите город в котором она спавнится или место (например: \"Аренда в ЛВ\", или \"Такси у инкассаторов\").\nВ противном случае указывайте работу к которой эта машина пренадлежит (например \"Инкассаторы\"), или фракцию \"Баллас\" так,\nчтобы разработчик мог понять что это за машина и занести её в список в близжайшем обновлении.\nЕсли у машины был водитель и он сейчас онлайн, то его имя будет подсвечено цветом клиста и будет указан его ID.\nДля того чтобы прервать процесс закройте диалог с окном через кнопку \"Прервать\"\nдля того, чтобы пропустить текущую машину (напомню что разработчика интересуют только серверные машины, а не личные), оставьте строку ввода пустой.", "Продолжить") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
						local res = waitForChooseInDialog(0)
						local tempdelarr = {}
						local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
						local name = ""
						if result then name = sampGetPlayerNickname(id) end
						for k, v in pairs(carsident) do
								local driver = ""
								if v.drivername ~= "0" then
										driver = v.drivername
										local did = sampGetPlayerIdByNickname(driver)
										if did ~= nil then
												local clist = string.sub(string.format('%x', sampGetPlayerColor(did)), 3)
												local clist = clist == "ffff" and "fffafa" or clist
												driver = "{" .. clist .. "}" .. driver .. "[" .. tostring(did) .. "]{fffafa}"
										end
								else
										driver = "отсутствует"
								end

								if not showdialog(1, "Идентификация", "Имя машины: " .. v.namecar .. "\nCID машины: " .. tostring(k) .. " (учтите, если CID > 1000 то скорее всего это личная/админская/динамически заспавненная машина и разработчика она не интересует)\nБыла обнаружена: " .. tostring(v.time) .. "\nВодитель: " .. driver .. "", "Далее", "Прервать") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка при создании диалогового окна.", 0xFFFF0000) return end
								local res = waitForChooseInDialog(1)
								if res == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Процесс был прерван.", 0xFFFF0000) return end
								if res == "" then
										sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Машина была пропущена.", 0xFFFF0000)
								else
										sendtolog("ID машины: " .. tostring(k) .. ", фракция: " .. res .. "", 0)
								end

								carsident[k] = nil
						end
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Процесс был завершен. Спасибо за сотрудничество.", 0xFFFF0000)
				end
		)

end ]]

--[[ function cmd_cars(sparams) -- вариант разработчика
	if table.maxn(carsident) == 0 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}К данному моменту вы не целились в неизвестные автомобили.", 0xFFFF0000) return end
	local str = ""
	for k, v in pairs(carsident) do
		str = str == "" and "[" .. tostring(k) .. "] = \"" .. sparams .. "\", " or "" .. str .. "[" .. tostring(k) .. "] = \"" .. sparams .. "\", "
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Отправил инфо: id машины " .. tostring(k) .. ", фракция: " .. sparams .. ".", 0xFFFF0000)
	end
	
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Процесс был завершен. Спасибо за сотрудничество.", 0xFFFF0000)
	print(str)
	carsident = {}
end ]]

-- Сортитровка массива:
--[[ local a_index = 0
local res = ""
local lastres = ""
local bool = false
for k, v in pairs(arr) do
    if v ~= lastres then res = '' .. res .. '\n\n' a_index = 0 end
    lastres = v
    res = a_index ~= 0 and '' .. res .. ' [' .. k .. '] = "' .. v .. '",' or '' .. res .. '[' .. k .. '] = "' .. v .. '",'
    a_index = a_index + 1
    if a_index == 6 then res = '' .. res .. '\n' a_index = 0 end
end

print(res) ]]

function formatbind(str)
		local str = tostring(str)
		local rarr = {}
		if str:match("@Hour@") then str = str:gsub("@Hour@", os.date("%H")) end
		if str:match("@Min@") then str = str:gsub("@Min@", os.date("%M")) end
		if str:match("@Sec@") then str = str:gsub("@Sec@", os.date("%S")) end
		if str:match("@Date@") then str = str:gsub("@Date@", os.date("%d.%m.%Y")) end
		if str:match("@KV@") then str = str:gsub("@KV@", kvadrat()) end
		if str:match("@MyID@") then str = str:gsub("@MyID@", tostring(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))) end
		if str:match("@clist@") then str = str:gsub("@clist@", config_ini.UserClist[clists[sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))]]) end
		if str:match("@enter@") then str = str:gsub("@enter@", "\n") end
		if str:match("@tid@") then if lastTargetID ~= -1 then str = str:gsub("@tid@", tostring(lastTargetID)) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось получить ID последней цели.", 0xFFFF0000) return nil end end
		for v in str:gmatch('[^\n]+') do table.insert(rarr, v) end
		if rarr[1] == nil then rarr[1] = str end
		return rarr
end

function ismegaphone()
		if isCharOnFoot(PLAYER_PED) then return false end
		local carhandle = storeCarCharIsInNoSave(PLAYER_PED)-- Получения handle транспорта
		if carhandle < 0 then return false end
		local idcar = getCarModel(carhandle)
		if idcar == 470 or idcar == 433 or idcar == 468 or idcar == 470 or idcar == 497 then return true end
		return false
end


function string.split(str, delim, plain) -- bh FYP
   local tokens, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
   repeat
       local npos, epos = string.find(str, delim, pos, plain)
       table.insert(tokens, string.sub(str, pos, npos and npos - 1))
       pos = epos and epos + 1
   until not pos
   return tokens
end

function strunsplit(str, delim)
   local str = string.split(str, " ")
   local estr = {[1] = ""}
   local A_Index = 1
   for k, i in ipairs(str) do
        if #estr[A_Index] + #i > delim then A_Index = A_Index + 1 estr[A_Index] = "" end    
        estr[A_Index] = estr[A_Index] == "" and i or "" .. estr[A_Index] .. " " .. i .. "" 
   end
    
   return estr
end

function imgui.Hotkey(name, numkey, width)
		imgui.BeginChild(name, imgui.ImVec2(width, 30), true)
		imgui.PushItemWidth(width)

		local hstr = ""
		for _, v in ipairs(string.split(config_ini.HotKey[numkey], ", ")) do
				if v ~= "0" then
						hstr = hstr == "" and tostring(vkeys.id_to_name(tonumber(v))) or "" .. hstr .. " + " .. tostring(vkeys.id_to_name(tonumber(v))) .. ""
				end
		end
		hstr = (hstr == "" or hstr == "nil") and "Нет" or hstr

		imgui.Text(u8(hstr))
		imgui.PopItemWidth()
		imgui.EndChild()
		if imgui.IsItemClicked() then
				lua_thread.create(
						function()
							local curkeys = ""
							local tbool = false
							while true do
									wait(0)
									if not tbool then
											for k, v in pairs(vkeys) do
													sv = tostring(v)
													if isKeyDown(v) and (v == vkeys.VK_MENU or v == vkeys.VK_CONTROL or v == vkeys.VK_SHIFT or v == vkeys.VK_LMENU or v == vkeys.VK_RMENU or v == vkeys.VK_RCONTROL or v == vkeys.VK_LCONTROL or v == vkeys.VK_LSHIFT or v == vkeys.VK_RSHIFT) then
															if v ~= vkeys.VK_MENU and v ~= vkeys.VK_CONTROL and v ~= vkeys.VK_SHIFT then
																	if not curkeys:find(sv) then
																			curkeys = tostring(curkeys):len() == 0 and sv or curkeys .. " " .. sv
																	end
															end
													end
											end

											for k, v in pairs(vkeys) do
													sv = tostring(v)
													if isKeyDown(v) and (v ~= vkeys.VK_MENU and v ~= vkeys.VK_CONTROL and v ~= vkeys.VK_SHIFT and v ~= vkeys.VK_LMENU and v ~= vkeys.VK_RMENU and v ~= vkeys.VK_RCONTROL and v ~= vkeys.VK_LCONTROL and v ~= vkeys.VK_LSHIFT and v ~=vkeys. VK_RSHIFT) then
														 	if not curkeys:find(sv) then
																	curkeys = tostring(curkeys):len() == 0 and sv or curkeys .. " " .. sv
																	tbool = true
															end
													end
											end
									else
											tbool2 = false
											for k, v in pairs(vkeys) do
													sv = tostring(v)
													if isKeyDown(v) and (v ~= vkeys.VK_MENU and v ~= vkeys.VK_CONTROL and v ~= vkeys.VK_SHIFT and v ~= vkeys.VK_LMENU and v ~= vkeys.VK_RMENU and v ~= vkeys.VK_RCONTROL and v ~= vkeys.VK_LCONTROL and v ~= vkeys.VK_LSHIFT and v ~=vkeys. VK_RSHIFT) then
															tbool2 = true
															if not curkeys:find(sv) then
																	curkeys = tostring(curkeys):len() == 0 and sv or curkeys .. " " .. sv
															end
													end
											end

											if not tbool2 then break end
									end
							end

							local keys = ""
							if tonumber(curkeys) == vkeys.VK_BACK then
									config_ini.HotKey[numkey] = "0"
							else
									local tNames = string.split(curkeys, " ")
									for _, v in ipairs(tNames) do
											local val = (tonumber(v) == 162 or tonumber(v) == 163) and 17 or (tonumber(v) == 160 or tonumber(v) == 161) and 16 or (tonumber(v) == 164 or tonumber(v) == 165) and 18 or tonumber(v)
											keys = keys == "" and val or "" .. keys .. ", " .. val .. ""
									end
							end

							config_ini.HotKey[numkey] = keys
						end
				)
		end
end

function makeHotKey(numkey)
		local rett = {}
		for _, v in ipairs(string.split(config_ini.HotKey[numkey], ", ")) do
				if tonumber(v) ~= 0 then table.insert(rett, tonumber(v)) end
		end
		return rett
end

function showdialog(style, title, text, button1, button2)
		if isDialogActiveNow then return false end
		sampShowDialog(9048, title, text, button1, button2, style)
	 	isDialogActiveNow = true
		return true
end

function getMembersText()
		refmem1.status, refmem1.text = true, ""
		sampSendChat("/members 1")
		while refmem1.text == "" do wait(0) end
		local Members1Text = refmem1.text
		refmem1.status, refmem1.text = false, ""

		local temparr = {}
		local delarr = {}
		
		for v in Members1Text:gmatch('[^\n]+') do 
			local id, name, zv, rank = v:match("%[%d+%] %[(%d+)%] ([%a_]+)	(%W*) %[(%d+)%].*") 
			if zv ~= nil then 
				temparr[name] = zv
				offmembers[name] = zv 
			end 
		end -- добавляем текущий мемберс во временный массив
		
		for k, v in pairs(offmembers) do if temparr[k] == nil then local id = sampGetPlayerIdByNickname(k) if id ~= nil then table.insert(delarr, k) if sampIs3dTextDefined(2048 - id) then sampDestroy3dText(2048 - id) end end end end -- проверяем текущий ини и находим тех, кто сейчас не в members и онлайн при этом
		
		for k, v in ipairs(delarr) do offmembers[v] = nil end -- удаляем с ини всех кто не в ЛВА уже
		return Members1Text
end

function waitForChooseInDialog(style)
		if style ~= 0 and style ~= 1 and style ~= 2 then return nil end
		while sampIsDialogActive(9048) do wait(100) end
		local result, button, list, input = sampHasDialogRespond(9048)
		returnWalue = style == 1 and input or list
		isDialogActiveNow = false
		if style == 0 or button == 0 then return nil end
		return returnWalue
end

function sampGetPlayerIdByNickname(nick)
		local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end

function sampGetPlayerSkin(id)
    if not id or not sampIsPlayerConnected(tonumber(id)) and not tonumber(id) == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then return false end -- проверяем параметр
    local isLocalPlayer = tonumber(id) == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) -- проверяем, является ли цель локальным игроком
    local result, handle = sampGetCharHandleBySampPlayerId(tonumber(id)) -- получаем CharHandle по SAMP-ID
    local result, handle = sampGetCharHandleBySampPlayerId(tonumber(id)) -- получаем CharHandle по SAMP-ID
    if not result and not isLocalPlayer then return false end -- проверяем, валиден ли наш CharHandle
    local skinid = getCharModel(isLocalPlayer and PLAYER_PED or handle) -- получаем скин нашего CharHandle
    if skinid < 0 or skinid > 311 then return false end -- проверяем валидность нашего скина, сверяя ID существующих скинов SAMP
    return true, skinid -- возвращаем статус и ID скина
end

function imgui.TextColoredRGB(text)
	    local style = imgui.GetStyle()
	    local colors = style.Colors
	    local ImVec4 = imgui.ImVec4

	    local explode_argb = function(argb)
		        local a = bit.band(bit.rshift(argb, 24), 0xFF)
		        local r = bit.band(bit.rshift(argb, 16), 0xFF)
		        local g = bit.band(bit.rshift(argb, 8), 0xFF)
		        local b = bit.band(argb, 0xFF)
		        return a, r, g, b
	    end

	    local getcolor = function(color)
		        if color:sub(1, 6):upper() == 'SSSSSS' then
			            local r, g, b = colors[1].x, colors[1].y, colors[1].z
			            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
			            return ImVec4(r, g, b, a / 255)
		        end

		        local color = type(color) == 'string' and tonumber(color, 16) or color
		        if type(color) ~= 'number' then return end
		        local r, g, b, a = explode_argb(color)
		        return imgui.ImColor(r, g, b, a):GetVec4()
	    end

	    local render_text = function(text_)
				  for w in text_:gmatch('[^\r\n]+') do
				 			local text, colors_, m = {}, {}, 1
						  w = w:gsub('{(......)}', '{%1FF}')
						  while w:find('{........}') do
								  local n, k = w:find('{........}')
								  local color = getcolor(w:sub(n + 1, k - 1))
								  if color then
										  text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
										  colors_[#colors_ + 1] = color
										  m = n
								  end

				  				w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
				  		end

						  if text[0] then
						  		for i = 0, #text do
										  imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
											if imgui.IsItemClicked() then	if SelectedRow == A_Index then ChoosenRow = SelectedRow	else	SelectedRow = A_Index	end	end
											imgui.SameLine(nil, 0)
				  				end

									imgui.NewLine()
				  		else
									imgui.Text(u8(w))
									if imgui.IsItemClicked() then	if SelectedRow == A_Index then ChoosenRow = SelectedRow	else	SelectedRow = A_Index	end	end
							end
				  end
	    end
	    render_text(text)
end

function patch_samp_time_set(enable)
		if enable and default == nil then
				default = readMemory(sampGetBase() + 0x9C0A0, 4, true)
				writeMemory(sampGetBase() + 0x9C0A0, 4, 0x000008C2, true)
		elseif enable == false and default ~= nil then
				writeMemory(sampGetBase() + 0x9C0A0, 4, default, true)
				default = nil
		end
end

function kvadrat()
    local KV = {
        [1] = "А",
        [2] = "Б",
        [3] = "В",
        [4] = "Г",
        [5] = "Д",
        [6] = "Ж",
        [7] = "З",
        [8] = "И",
        [9] = "К",
        [10] = "Л",
        [11] = "М",
        [12] = "Н",
        [13] = "О",
        [14] = "П",
        [15] = "Р",
        [16] = "С",
        [17] = "Т",
        [18] = "У",
        [19] = "Ф",
        [20] = "Х",
        [21] = "Ц",
        [22] = "Ч",
        [23] = "Ш",
        [24] = "Я",
    }
    local X, Y, Z = getCharCoordinates(playerPed)
    X = math.ceil((X + 3000) / 250)
    Y = math.ceil((Y * - 1 + 3000) / 250)
    Y = KV[Y]
    local KVX = (Y.."-"..X)
    return KVX
end

function drawPieSub(v)
  if pie.BeginPieMenu(u8(v.name)) then
    for i, l in ipairs(v.next) do
      if l.next == nil then
        if pie.PieMenuItem(u8(l.name)) then l.action() end
      elseif type(l.next) == 'table' then
        drawPieSub(l)
      end
    end
    pie.EndPieMenu()
  end
end

function get_crosshair_position()
    local vec_out = ffi.new("float[3]")
    local tmp_vec = ffi.new("float[3]")
    ffi.cast(
        "void (__thiscall*)(void*, float, float, float, float, float*, float*)",
        0x514970
    )(
        ffi.cast("void*", 0xB6F028),
        15.0,
        tmp_vec[0], tmp_vec[1], tmp_vec[2],
        tmp_vec,
        vec_out
    )
    return vec_out[0], vec_out[1], vec_out[2]
end

function getAngle(x, y) -- получить угол между персонажем и указанной точкой по теореме косинусов
		local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
		local crsX, crsY, crsZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
		local a = math.sqrt(((x-crsX)^2) + ((y-crsY)^2)) -- растояние между указанной точкой и точкой куда направлен прицел
		local b = math.sqrt(((myX-x)^2) + ((myY-y)^2)) -- расстояние между координатами персонажа и указанной точкой
		local c = math.sqrt(((crsX-myX)^2) + ((crsY-myY)^2)) -- расстояние между координатами персонажа и точкой куда направлен прице
		local cosA = ((b*b) + (c*c) - (a*a))/(2*b*c) -- получаем косинус угла
		local radA = math.acos(cosA) -- получаем величину угла в радианах через арккосинус
		local deg = math.deg(radA) -- угол в градусах

		-- непонятный мне расчёт который точно считает но относительно севера
		--local rad = math.atan2((x - myX), (y - myY))
		--local deg = math.deg(rad)
		--return deg


		-- вроде бы работает
		local myAngle = 360 - getCharHeading(PLAYER_PED)
		if (myAngle >= 0 and myAngle <= 90) and (x <= myX or y >= myY) then return -1 * deg end
		if (myAngle > 90 and myAngle <= 180) and (x >= myX or y >= myY) then return -1 * deg end
		if (myAngle > 180 and myAngle <= 270) and (x >= myX or y <= myY) then return -1 * deg end
		if (myAngle > 270 and myAngle <= 360) and (x <= myX or y <= myY) then return -1 * deg end
		return deg

		-- через векторное произведение - нихуя не понятно и вроде бы не работает
		-- local vec_a = {["x"] = crsX - myX, ["y"] = crsY - myY, ["z"] = crsZ - myZ}
		-- local vec_b = {["x"] = x - myX, ["y"] = y - myY, ["z"] = z - myZ}
		-- local vec_c = {["x"] = (vec_a.y * vec_b.z) - (vec_a.z * vec_b.y), ["y"] = (vec_a.z * vec_b.x) - (vec_a.x * vec_b.z), ["z"] = (vec_a.x * vec_b.y) - (vec_a.y * vec_b.x)}
		-- --print("Вектора: " .. vec_a.z .. ";" .. vec_c.z .. "")
		-- if (vec_c.z > 0 and vec_a.z > 0) or (vec_c.z < 0 and vec_a.z < 0) then return deg else return -1 * deg end
end

function getcars()
		local chandles = {}
		local tableIndex = 1
		local vehicles = getAllVehicles()
		local fcarhandle = isCharInAnyCar(PLAYER_PED) and storeCarCharIsInNoSave(PLAYER_PED) or 12
		for k, v in pairs(vehicles) do
				if doesVehicleExist(v) and v ~= fcarhandle then table.insert(chandles, tableIndex, v) tableIndex = tableIndex + 1 end
		end

		if table.maxn (chandles) == 0 then return nil else return chandles end
end

function cmd_balogin(sparams)
	lua_thread.create(function()
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Введите /balogin [пароль].", 0xffff0000) return end
		local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local nick = sampGetPlayerNickname(myid)		
		local responsetext = req('https://script.google.com/macros/s/AKfycbx28UFg93in4xEHLnLjBPF-3BXRNddlNiiW0RARAZ-hHvu3kwo/exec?do=login&nick=' .. nick .. '&p=' .. sparams .. '')
		local re1 = regex.new("\\@\\#\\#\\@ \\@\\@\\.\\@ (Access granted|Registration successfully)\\. Level\\: (\\d) \\@\\.\\@\\.\\@ nicks\\: (.*) \\@\\@\\@\\@\\#\\#\\@\\@") --
		local response, lvll, nicks = re1:match(responsetext)
		if response == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный логин или пароль.", 0xffff0000) return end
		if response == "Registration successfully" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Новый пароль установлен успешно.", 0xffff0000) end
		access.alevel = tonumber(lvll)
		moderpas = "modernick=" .. nick .. "&p=" .. sparams .. ""
		
		if access.alevel > 0 then
			sampRegisterChatCommand("lek", cmd_lek)
			sampRegisterChatCommand("pcheck", cmd_pcheck)
			sampRegisterChatCommand("tren", cmd_tren)
		end

		if access.alevel > 1 then
			sampRegisterChatCommand("padd", cmd_padd)
			sampRegisterChatCommand("pdel", cmd_pdel)									
			sampRegisterChatCommand("mark", cmd_mark)
			sampRegisterChatCommand("add", cmd_add)
			sampRegisterChatCommand("del", cmd_del)
			sampRegisterChatCommand("change", cmd_change)
		end

		if access.alevel > 2 then
			sampRegisterChatCommand("otm", cmd_otm)
			sampRegisterChatCommand("serj", cmd_serj)	
		end

		if access.alevel == 3 or access.alevel == 6 then 
			sampRegisterChatCommand("fond", cmd_fond) 
			fond[2] = getPlayerMoney(PLAYER_HANDLE)
			local responsetext = req("https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=fond&act=ref&" .. moderpas .. "")
			local re1 = regex.new("\\@\\@\\.\\@ L\\: (.*) \\@\\@\\.\\.\\@\\.\\@") --
			local names = re1:match(responsetext)
			if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось обновить сумму фонда отряда.", 0xffff0000) else fond[1] = names end 
		end
		
		if access.alevel > 4 then
			sampRegisterChatCommand("reg", cmd_reg)
			sampRegisterChatCommand("ban", cmd_ban)
			sampRegisterChatCommand("moder", cmd_moder)
		end
		
		if config_ini.bools[58] == 1 and access.alevel ~= 3 and access.alevel ~= 6 then config_ini.bools[58] = 0 inicfg.save(config_ini, "config") end
		sendtolog("Успешная авторизация в качестве модератора", 1.1)
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. " - успешная авторизация в качестве модератора уровня " .. access.alevel .. ".", 0xffff0000)
		if nicks ~= "" then 
			local arr = string.split(nicks, ",")
			if arr[1] ~= nil then sampAddChatMessage("{FF0000}[LUA]: ВНИМАНИЕ!{FFFAFA} У этих игроков отсутствует доступ к таблице:", 0xffff0000) end
			for k, v in ipairs(arr) do sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. v .. "", 0xffff0000) end
		end
	end)
end


function cmd_check()
		lua_thread.create(
				function()
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Начинаю поиск игроков.", 0xffff0000)
						local responsetext = req('https://script.google.com/macros/s/AKfycbya8zAQ_EMWg9pp2mFEh5XbKVym-nJEMlbc-fyayvN932cPAvQ/exec?do=check&' .. moderpas .. '')
						local re1 = regex.new("@##@ (.*) @@@@##@@") --
						local names = re1:match(responsetext)
						if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка поиска #1.", 0xffff0000) return end
						local namesarr = string.split(names, "; ")
						for k, v in pairs(namesarr) do
								local id = sampGetPlayerIdByNickname(v)
								if id ~= nil then
										local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
										local clist = clist == "ffff" and "fffafa" or clist
										sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}{" .. clist .. "}" .. v .. "[" .. tostring(id) .. "]{fffafa} - в сети", 0xffff0000)
								end
						end
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Завершил поиск игроков.", 0xffff0000)
				end
		)
end

function cmd_reg(sparams)
		lua_thread.create(
				function()
						if access.alevel < 5 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /reg [id] [T-стажер/M-основной состав/H - почетный боец]", 0xFFFF0000) return end
						local params = {}
						for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
						local id = -1
						if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
						local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))

						if params[2] ~= "T" and params[2] ~= "M" and params[2] ~= "H" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /reg [id] [T-стажер/M-основной состав/H - почетный боец]", 0xFFFF0000) return end
						if params[2] == "H" and access.alevel < 3 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Недостаточно прав для выдачи статуса почетного бойца.", 0xffff0000) return end
						local part = params[2] == "T" and "0" or params[2] == "H" and "2" or "1"
						local responsetext = req('https://script.google.com/macros/s/AKfycbwBG17iJ1Jpy5Ft9lmACSIZyrOA7QBydzgM1S12jkARF7ddEWA/exec?do=add&name=' .. nick .. '&part=' .. part .. '&' .. moderpas .. '')
						local re1 = regex.new("@@# Updated @#@") --
						local names = re1:match(responsetext)
						if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок " .. nick .. " был зарегистрирован в биндере.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Статус игрока " .. nick .. " в биндере был обновлен.", 0xffff0000) end
				end
		)
end

function cmd_ban(sparams)
		lua_thread.create(
				function()
						if access.alevel < 5 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /ban [id]", 0xFFFF0000) return end
						local params = {}
						for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
						local id = -1
						if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
						local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
						local responsetext = req('https://script.google.com/macros/s/AKfycbwBG17iJ1Jpy5Ft9lmACSIZyrOA7QBydzgM1S12jkARF7ddEWA/exec?do=find&name=' .. nick .. '&del=3YxEKPHYQI&' .. moderpas .. '')
						local re1 = regex.new("Row deleted") --
						local names = re1:match(responsetext)
						if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось забрать доступ у игрока " .. nick .. ".", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ к биндеру у игрока " .. nick .. " был анулирован.", 0xffff0000) end
				end
		)
end

function cmd_fond(sparams)
	lua_thread.create(function()
		if access.alevel ~= 3 and access.alevel ~= 6 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Введите /fond [bank/withdraw [кто добавил/забрал] [сумма (без точек)] [примечание] / balance - обновить сумму фонда для оверлея]", 0xFFFF0000) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		if params[1] == nil or (params[1] ~= "bank" and params[1] ~= "withdraw" and params[1] ~= "balance") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Введите /fond [bank/withdraw/balance]", 0xFFFF0000) return end
		if (params[1] == "bank" or params[1] == "withdraw") then
			if params[2] == nil or params[2] == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверное имя", 0xFFFF0000) return end
			if params[3] == nil or params[3] == "" or tonumber(params[3]) == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверная сумма", 0xFFFF0000) return end
			if params[4] == nil or params[4] == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверное примечание", 0xFFFF0000) return end
		end
		
		if tonumber(fond[1]) == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Скрипт не знает сумму фонда. Обновите с помощью параметра balance.", 0xFFFF0000) return end

		local mon = 0
		if params[1] ~= "balance" then
			if params[1] == "bank" then mon = fond[1] + params[3] end
			if params[1] == "withdraw" then mon = fond[1] - params[3] end
		end
		
		local responsetext = req("https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=fond&act=" .. (params[1] == "balance" and "balance" or "" .. params[1] .. "&who=" .. translit(params[2]) .. "&m=" .. params[3] .. "&prim=" .. translit(strrest(params, 4)) .. "") .. "&mon=" .. mon .. "&" .. moderpas .. "")
		local re1 = regex.new("\\@\\@\\.\\@ L\\: (.*) \\@\\@\\.\\.\\@\\.\\@") --
		local names = re1:match(responsetext)
		if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось обновить сумму фонда отряда.", 0xffff0000) else fond[1] = names sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Сумма фонда отряда успешно обновлена.", 0xffff0000) end 
	end)
end

function cmd_serj(sparams)
	lua_thread.create(function()
			if access.alevel < 3 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
			if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Введите /serj [мин. отметки] [мин. ранг]", 0xFFFF0000) return end
			local params = {}
			for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
			if params[1] == nil or tonumber(params[1]) == nil or params[2] == nil or tonumber(params[2]) == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Введите /serj [мин. отметки] [мин. ранг]", 0xFFFF0000) return end
			offcheck.status = true
			offcheck.otm = tonumber(params[1])
			offcheck.rank = tonumber(params[2])
			sampSendChat("/offmfilter clear")
			wait(1500)
			sampSendChat("/offmfilter minRank " .. params[2] .. "")
			wait(1500)
			sampSendChat("/offmembers")
	end)
end


function cmd_otm()
	lua_thread.create(function()
		if access.alevel < 3 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
		
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Начинаю сбор информации...", 0xFFFF0000)
		local responsetext = req("https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=getlist")
		local str = responsetext:match("%@%@%.%@ (.*) %@%@%.%.%@%.%@")
		local rukstr = str:match("(.*) @@....@") -- рук-во
		if rukstr ~= nil then for k, v in ipairs(rukstr:split("; ")) do local a = v:split(" ") soptlist[1][a[1]  .. "_" .. a[2]] = 0 end end
				
		local osnstr = str:match("@@....@ (.*) @@...@") -- основной соства
		if osnstr ~= nil then for k, v in ipairs(osnstr:split("; ")) do local a = v:split(" ") soptlist[1][a[1]  .. "_" .. a[2]] = 0 end end
					
		local stjstr = str:match("@@...@ (.*)") -- стажеры
		if stjstr ~= nil then for k, v in ipairs(stjstr:split("; ")) do local a = v:split(" ") soptlist[1][a[1]  .. "_" .. a[2]] = 0 end end
		
		
		otmmode = true 
		sampSendChat("/offmfilter clear") wait(500) sampSendChat("/offmembers")				
		while otmmode do wait(0) end

		local names = ""
		local otms = ""
		for k, v in pairs(soptlist[1]) do 
			local f, s = k:match("(.*)%_(.*)") 
			names = names == "" and "" .. f .. "%20" .. s .. "" or "" .. names .. "@.@" .. f .. "%20" .. s .. ""
			otms = otms == "" and v or "" .. otms .. "@.@" .. v .. ""
		end
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Сбор информации завершен. Начинаю занесение данных в таблицу...", 0xFFFF0000)
		
		local a = os.date("!*t", os.time())
		local w = ((a.wday == 1 and a.hour >= 21) or (a.wday == 2 and a.hour < 2)) and online_ini.week_info.week - 1 or online_ini.week_info.week
		local responsetext = req("https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=otm&names=" .. names .. "&otms=" .. otms .. "&week=" .. w .. "&" .. moderpas .. "")
		local re1 = regex.new("@@.@ Update complete @@..@.@") --
		local names = re1:match(responsetext)
		if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось обновить отметки в таблице отряда.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Отметки в таблице отряда успешно обновлены.", 0xffff0000) end 
		return 
	end)		
end

function cmd_tren(sparams)
	lua_thread.create(function()
		if access.alevel < 1 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Введите /tren [локация] [количество союзников] [количество противников] [результат (1-3)] [подразделение противников]", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}1 - победа, 2 - победа БП, 3 - поражение", 0xFFFF0000) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		if params[1] == nil or params[2] == nil or params[3] == nil or params[4] == nil or params[5] == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Введите /tren [локация] [количество союзников] [количество противников] [результат (1-3)] [подразделение противников]", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}1 - победа, 2 - победа БП, 3 - поражение", 0xFFFF0000) return end
		
		local responsetext = req("https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=tren&vic=" .. params[4] .. "&where=" .. translit(params[1]) .. "&we=" .. params[2] .. "&they=" .. params[3] .. "&who=" .. translit(strrest(params, 5)) .. "&" .. moderpas .. "")
		local re1 = regex.new("@@.@ Complete @@..@.@") --
		local names = re1:match(responsetext)
		if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не проставить отметку о проведении тренировки в таблице отряда.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Отметка о проведении тренировки успешно проставлена в таблице отряда.", 0xffff0000) end 
		return 
	end)
end

function cmd_pcheck(sparams)
	lua_thread.create(
			function()
					if access.alevel < 1 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Начинаю поиск " .. (sparams == "-1" and "всех присмотренных игроков" or "присмотренных игроков в сети") .. ".", 0xffff0000)
					local Members1Text = getMembersText()
					local members = {}
					for v in Members1Text:gmatch('[^\n]+') do wait(0) local nickname, zv = v:match("%[%d+%] %[%d+%] (%a+%_%a+)	(%W*) %[.*%]") if zv ~= nil then members[nickname] = zv end end
					local responsetext = req('https://script.google.com/macros/s/AKfycbw2mSf730dll2c7GedYaEplttqdTRmZY48sc05c7TDsHBPCv-Rf/exec?do=check&' .. moderpas .. '')
					local re1 = regex.new("@##@ @@..@ NAMES: (.*) @@@@##@@") --
					local names = re1:match(responsetext)
					if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Ошибка поиска #1.", 0xffff0000) return end
					local namesarr = string.split(names, "; ")
					for k, v in pairs(namesarr) do
						local dd, nn, prim, who = v:match("(.*) %@%=%@ (.*) %@%=%=%@ (.*) %@%=%=%=%@ (.*)")
						local id = sampGetPlayerIdByNickname(nn)
						if id ~= nil then
							local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
							local clist = clist == "ffff" and "fffafa" or clist
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}{" .. clist .. "}" .. nn .. "[" .. tostring(id) .. "] - " .. (members[nn] ~= nil and members[nn] or "неизвестно") .. "{008000} - в сети{fffafa} - " .. prim .. "", 0xffff0000)
							sampAddChatMessage("{FF0000}[LUA]: {FFA500}Добавил: {fffafa}" .. who .. ", " .. dd .. "", 0xffff0000)
						else
							if sparams == "-1" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nn .. "{F08080} - не в сети{fffafa} - " .. prim .. "", 0xffff0000) sampAddChatMessage("{FF0000}[LUA]: {FFA500}Добавил: {fffafa}" .. who .. ", " .. dd .. "", 0xffff0000) end
						end
					end
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Завершил поиск игроков.", 0xffff0000)
			end
	)
end

function cmd_padd(sparams)
		lua_thread.create(
				function()
						if access.alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /padd [id/nick] ([примечание])", 0xFFFF0000) return end
						local params = {}
						for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
						local id = -1
						if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
						local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
						local responsetext = req('https://script.google.com/macros/s/AKfycbw2mSf730dll2c7GedYaEplttqdTRmZY48sc05c7TDsHBPCv-Rf/exec?do=add&name=' .. nick .. '' .. (params[2] ~= nil and '&text=' .. translit(strrest(params, 2)) .. '' or '') .. '&who=' .. sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))) .. '&date=' .. os.date("%d.%m.%Y") .. '&' .. moderpas .. '')
						local re1 = regex.new("@@.@ (.*) @.@@") --
						local names = re1:match(responsetext)
						if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось добавить игрока " .. nick .. " в список присмотренных.", 0xffff0000) return end
						
						if names:match("Done") ~= nil then
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок " .. nick .. " был добавлен в список присмотренных.", 0xffff0000)
							return
						end

						if names:match("False V") ~= nil then
							local res, who, date = names:match("False V%: (.*)%; (.*)%; (.*)")
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок " .. nick .. " находится в {FF0000}ЧС вербовки.", 0xffff0000)
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Причина {FF0000}" .. res .. " {FFFAFA}добавил: {FF0000}" .. who .. " " .. date .. ".", 0xffff0000)
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Добавить игрока в присмотренные вне зависимости от этого?", 0xffff0000)
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Нажмите Y - для согласия, N - для отказа. {FF0000}При согласии игрок будет удален из ЧС вербовки!", 0xffff0000)
							while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось добавить игрока " .. nick .. " в список присмотренных.", 0xffff0000) return end end

							local responsetext = req('https://script.google.com/macros/s/AKfycbw2mSf730dll2c7GedYaEplttqdTRmZY48sc05c7TDsHBPCv-Rf/exec?do=add&name=' .. nick .. '' .. (params[2] ~= nil and '&text=' .. translit(strrest(params, 2)) .. '' or '') .. '&who=' .. sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))) .. '&date=' .. os.date("%d.%m.%Y") .. '&ignorev=1&' .. moderpas .. '')
							local re1 = regex.new("@@.@ (.*) @.@@") --
							local names = re1:match(responsetext)

							if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось добавить игрока " .. nick .. " в список присмотренных.", 0xffff0000) return end
							if names:match("Done") ~= nil then
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок " .. nick .. " был вынесен из ЧС вербовки.", 0xffff0000)
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок " .. nick .. " был добавлен в список присмотренных.", 0xffff0000)
								return
							end
						end

						if names:match("False BL") ~= nil then
							local res, who = names:match("False BL%: (.*)%; (.*)")
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок " .. nick .. " находится в {FF0000}ЧС отряда.", 0xffff0000)
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Причина {FF0000}" .. res .. " {FFFAFA}добавил: {FF0000}" .. who .. ".", 0xffff0000)
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось добавить игрока " .. nick .. " в список присмотренных.", 0xffff0000)
						end
				end
		)
end

function cmd_pdel(sparams)
		lua_thread.create(
				function()
						if access.alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /pdel [id/nick] ([причина занесения в ЧС вербовки])", 0xFFFF0000) return end
						local params = {}
						for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
						local id = -1
						if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
						local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
						local reasonchs = params[2] ~= nil and strrest(params, 2) or ""
						local responsetext = req('https://script.google.com/macros/s/AKfycbw2mSf730dll2c7GedYaEplttqdTRmZY48sc05c7TDsHBPCv-Rf/exec?do=delete&name=' .. nick .. '&' .. moderpas .. '' .. (params[2] ~= nil and '&chs=1&reason=' .. translit(strrest(params, 2)) .. '&who=' .. sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))) .. '&date=' .. os.date("%d.%m.%Y") .. '' or '') .. '')
						local re1 = regex.new("@@.@ Row deleted") --
						local names = re1:match(responsetext)
						if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось удалить игрока " .. nick .. " из список присмотренных.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок " .. nick .. " был удален из списка присмотренных.", 0xffff0000) end
				end
		)
end

function cmd_add(sparams) 
		lua_thread.create(function()
			if access.alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
			if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /add [id] ([дата последнего повышения в формате dd.mm.yyyy])", 0xFFFF0000) return end
			local params = {}
			for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
			local id = -1
			if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
			if id == -1 or (id ~= -1 and not sampIsPlayerConnected(tonumber(params[1]))) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
			local nick = sampGetPlayerNickname(tonumber(params[1]))

			local Members1Text = getMembersText()
			for v in Members1Text:gmatch('[^\n]+') do
				local _, zv, afk = v:match("%[%d+%] %[(%d+)%] " .. nick .. "	(%W*) %[%d+%](.*)")
				if zv ~= nil then
					local reg = regex.new("(.*)\\_(.*)") --
					local fname, sname = reg:match(nick)
					local nickname = "" .. fname .. " " .. sname .. ""
					
					local data = params[2] ~= nil and params[2] or os.date("%d.%m.%Y")
			
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Вы собираетесь занести в таблицу отряда игрока {ff0000}" .. nickname .. "", 0xFFFF0000)
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Воинское звание: {ff0000}" .. zv .. "{fffafa}, дата последнего повышения: {ff0000}" .. data .. ".", 0xFFFF0000)
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Нажмите Y для подтверждения и N для отмены.", 0xFFFF0000)
					while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Действие отменено.", 0xFFFF0000) return end end
					
					local result, logmyid = sampGetPlayerIdByCharHandle(PLAYER_PED)
					local lognick = sampGetPlayerNickname(logmyid)
					local responsetext = req('https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=add&nick=' .. nickname .. '&rank=' .. translit(zv) .. '&date=' .. data .. '&who=' .. lognick .. '&' .. moderpas .. '')
					local re1 = regex.new("@@.@ Add complete @@..@.@") --
					local names = re1:match(responsetext)
					if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось добавить игрока " .. nick .. " в таблицу отряда.", 0xffff0000) return end
				
					local responsetext = req('https://script.google.com/macros/s/AKfycbw2mSf730dll2c7GedYaEplttqdTRmZY48sc05c7TDsHBPCv-Rf/exec?do=delete&name=' .. nick .. '&' .. moderpas .. '')
					local re2 = regex.new("@@.@ Row deleted") --
					local names2 = re2:match(responsetext)
					if names2 == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось удалить игрока " .. nick .. " из списка присмотренных.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок " .. nick .. " был удален из списка присмотренных.", 0xffff0000) end
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок " .. nick .. " был успешно добавлен в таблицу отряда.", 0xffff0000) 
					return 
				end
			end

			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. "[" .. id .. "] {FFFAFA}- не найден в members", 0xFFFF0000) return
		end)
end

function cmd_del(sparams) 
	lua_thread.create(function()
		if access.alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /del [id] ([причина занесения в ЧС])", 0xFFFF0000) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		local id = -1
		if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
		if (id ~= -1 and not sampIsPlayerConnected(tonumber(params[1]))) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
		local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
		local reg = regex.new("(.*)\\_(.*)") --
		local fname, sname = reg:match(nick)
		local nickname = "" .. fname .. " " .. sname .. ""
					
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Вы собираетесь удалить из таблицы отряда игрока {ff0000}" .. nickname .. "", 0xFFFF0000)
		if params[2] ~= nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}С занесением в ЧС с причиной: {ff0000}" .. strrest(params, 2) .. ".", 0xFFFF0000) end
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Нажмите Y для подтверждения и N для отмены.", 0xFFFF0000)
		while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Действие отменено.", 0xFFFF0000) return end end
					
		local chs = params[2] ~= nil and 1 or 0
		local reason = params[2] ~= nil and strrest(params, 2) or "123"
		local result, logmyid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local lognick = sampGetPlayerNickname(logmyid)
		local responsetext = req('https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=find&nick=' .. nickname .. '&del=3YxEKPHYQI&chs=' .. chs .. '&who=' .. lognick .. '&reason=' .. translit(reason) .. '&' .. moderpas .. '')
		local re1 = regex.new("@@.@ Row deleted (BL )?@@..@.@") --
		local names = re1:match(responsetext)
		if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось удалить игрока " .. nick .. " из таблицы отряда.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок " .. nick .. " был успешно удален из таблицы отряда.", 0xffff0000) end 
		return 
	end)
end

function cmd_lek(sparams) 
	lua_thread.create(function()
		if access.alevel < 1 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
		
		if sparams == "" then 
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /lek [id] [pmp/rb/np/tp/nv/no/kt1/kt2]", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}pmp - первая мед. помощь, rb - разминирование, np - навыки пилотирования", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}tp - тактическая подготовка, nv - навыки вождения, no - навыки ориентирования", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}kt1 - контртерроризм (профиль отряда), kt2 - контретторизм (борьба с терроризмом)", 0xFFFF0000)	
			return 
		end
		
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		local id = -1
		if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
		if (id ~= -1 and not sampIsPlayerConnected(tonumber(params[1]))) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
		local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
		if params[2] ~= "pmp" and params[2] ~= "rb" and params[2] ~= "np" and params[2] ~= "tp" and params[2] ~= "nv" and params[2] ~= "no" and params[2] ~= "kt1" and params[2] ~= "kt2" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверно указана лекция.", 0xFFFF0000) return end
		local reg = regex.new("(.*)\\_(.*)") --
		local fname, sname = reg:match(nick)
		local nickname = "" .. fname .. " " .. sname .. ""
					
		local responsetext = req('https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=lek&nick=' .. nickname .. '&wto=' .. params[2] .. '&' .. moderpas .. '')
		local re1 = regex.new("@@.@ Update complete @@..@.@") --
		local names = re1:match(responsetext)
		if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось проставить отметку \"Пройдено\" игроку " .. nick .. ".", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Отметка \"Пройдено\" игроку " .. nick .. " успешно проставлена.", 0xffff0000) sendtolog("Поставил отметку пройдено игроку " .. nick .. "", 1) end 
		return
	end)
end

function cmd_mark(sparams) 
	lua_thread.create(function()
		if access.alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
		
		if sparams == "" then 
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /mark [id] [zua/zuo/zz/pmp/rb/uts/no/kp/np/op/kt/total/dopusk] [оценка 0-5] ([причина недопуска/примечание])", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}zua - знание устава армии, zuo - знание устава отряда, zz - зеленые зоны, pmp - первая мед. помощь", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}rb - разминирвоание, uts - вождение, no - ориентирование, kp - кольца/патрули", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}np - пилотирование, op - огневая подготовка, kt - контртерроризм", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}total - общая оценка(1 - сдал/0 - не сдал), dopusk - допуск к сдаче (0 - не допущен/1 - допущен)", 0xFFFF0000)
			return 
		end
		
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		local id = -1
		local reason = ""
		if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
		if id == -1 or (id ~= -1 and not sampIsPlayerConnected(tonumber(params[1]))) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
		local nick = sampGetPlayerNickname(tonumber(params[1]))
		if params[2] ~= "zua" and params[2] ~= "zuo" and params[2] ~= "zz" and params[2] ~= "pmp" and params[2] ~= "rb" and params[2] ~= "uts" and params[2] ~= "no" and params[2] ~= "kp" and params[2] ~= "np" and params[2] ~= "op" and params[2] ~= "kt" and params[2] ~= "total"  and params[2] ~= "dopusk" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверно указано испытание.", 0xFFFF0000) return end
		if (tonumber(params[3]) ~= nil and (((tonumber(params[3]) < 0 or tonumber(params[3]) > 5) and (params[2] ~= "dopusk" and params[2] ~= "total")) or (tonumber(params[3]) ~= 0 and tonumber(params[3]) ~= 1 and (params[2] == "dopusk" or params[2] == "total")))) or (tonumber(params[3]) == nil) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверно указана оценка.", 0xFFFF0000) return end
		if (params[2] == "dopusk") and (tonumber(params[3]) == 0) and params[4] == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Укажите причину недопуска.", 0xFFFF0000) return end
		if params[4] ~= nil then reason = params[2] == "dopusk" and "reason=" .. translit(strrest(params, 4)) .. "" or "prim=" .. translit(strrest(params, 4)) .. "" end
			local Members1Text = getMembersText()
			for v in Members1Text:gmatch('[^\n]+') do
				local _, zv, afk = v:match("%[%d+%] %[(%d+)%] " .. nick .. "	(%W*) %[%d+%](.*)")
				if zv ~= nil then
					local reg = regex.new("(.*)\\_(.*)") --
					local fname, sname = reg:match(nick)
					local nickname = "" .. fname .. " " .. sname .. ""
					
					local responsetext = req('https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=mark&nick=' .. nickname .. '&wto=' .. params[2] .. '&mark=' .. params[3] .. '&' .. reason .. '&' .. moderpas .. '')
					local re1 = regex.new("@@.@ Update complete @@..@.@") --
					local names = re1:match(responsetext)
					if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось проставить оценку игроку " .. nick .. ".", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Оценка игроку " .. nick .. " успешно проставлена.", 0xffff0000) end 
					return 
				end
			end

		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. "[" .. id .. "] {FFFAFA}- не найден в members", 0xFFFF0000) return
	end)
end

function cmd_change(sparams)
	lua_thread.create(function()
		if access.alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
		if sparams == "" then
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /change [id/nick] [уровень доступа] (причина запаса)", 0xFFFF0000) 
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}уровень доступа: -1 - сбросить пароль модератора; 0 - стажер, 1 - основа, 2 - тренер, 3 - 2-й ЗК, 4 - 1-й ЗК, 5 - командир, 6 - куратор, 7 - боец запаса", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Пример: /change 123 1 - перевести в основу игрока с id 123", 0xFFFF0000)
			return
		end
		
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		
		local id = -1
		if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
		if (id ~= -1 and not sampIsPlayerConnected(tonumber(params[1]))) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
		local nickname = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
		local tarr = {[-1] = "Сбросить пароль модератора", [0] = "Перевести на стажировку", [1] = "Перевести в основной состав", [2] = "Назначить тренером личного состава", [3] = "Назначить вторым заместителем", [4] = "Назначить первым заместителем", [5] = "Назначить командиром", [6] = "Назначить куратором", [7] = "Перевести в запас"}
		local uptom = tonumber(params[2])
		if uptom == nil or tarr[uptom] == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр \"Уровень доступа\".", 0xFFFF0000) return end
		if uptom ~= 7 and (uptom > 2 and access.alevel < 3) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end

		local n, f = nickname:match("(.*)%_(.*)")
		local nick = "" .. n .. " " .. f .. ""
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Вы собираетесь обновить информацию об игроке {ff0000}" .. nick .. "{fffafa} в таблице отряда.", 0xFFFF0000)
		sampAddChatMessage("{FF0000}[LUA]: {ff0000}" .. tarr[uptom] .. ".", 0xFFFF0000)
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Нажмите Y для подтверждения и N для отмены.", 0xFFFF0000)
		while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Действие отменено.", 0xFFFF0000) return end end
					
		if uptom == -1 then 
			local url = "https://script.google.com/macros/s/AKfycbx28UFg93in4xEHLnLjBPF-3BXRNddlNiiW0RARAZ-hHvu3kwo/exec?do=resetpass&nick=" .. nick .. "&" .. moderpas .. ""
			local responsetext = req(url)
			local re1 = regex.new("@@.@ Update complete @@..@.@") --
			local names = re1:match(responsetext)
			if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось сбросить пароль модератора игрока " .. nick .. ".", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Пароль модератора игрока " .. nick .. " успешно сброшен.", 0xffff0000) end 
			return 
		end
	
		local url = 'https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=update&nick=' .. nick .. '&taccess=' .. uptom .. '&reason=' .. (uptom == 7 and translit(strrest(params, 3)) or '') .. '&' .. moderpas .. ''
		local responsetext = req(url)
		local re1 = regex.new("@@.@ Update complete @@..@.@") --
		local names = re1:match(responsetext)
		if names == nil then
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось обновить информацию об игроке " .. nick .. " в таблице отряда.", 0xffff0000)
			if responsetext:match("@@.@ Error: 1 @@..@.@") ~= nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок " .. nick .. " должен иметь уровень доступа \"Основной состав\" для повышения до тренера.", 0xffff0000) end
		else 
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Информация об игроке " .. nick .. " в таблице отряда успешно обновлена.", 0xffff0000)
			if uptom == 1 then sampSendChat('/me передал' .. RP .. ' именной тёмно-красный берет "С.О.П.Т." бойцу ' .. nick .. '') end
		end 
	end)
end

function cmd_moder(sparams)
		lua_thread.create(
				function()
						if access.alevel < 5 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Доступ запрещен", 0xFFFF0000) return end
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неверный параметр. Введите /moder [id] [уровень]", 0xFFFF0000) return end
						local params = {}
						for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end

						local id = -1
						if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игрок оффлайн", 0xFFFF0000) return end
						local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))

						local level = -1
						if tonumber(params[2]) ~= nil and tonumber(params[2]) >= 0 and tonumber(params[2]) <= 4  then level = tonumber(params[2]) end
						if level == -1 or access.alevel < level then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Указан некорректный уровень модерирования.", 0xFFFF0000) return end

						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Вы собираетесь выдать права модератора игроку " .. nick .. "", 0xFFFF0000)
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Нажмите Y для подтверждения и N для отмены.", 0xFFFF0000)
						while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Действие отменено.", 0xFFFF0000) return end end

						local responsetext = req('https://script.google.com/macros/s/AKfycbx28UFg93in4xEHLnLjBPF-3BXRNddlNiiW0RARAZ-hHvu3kwo/exec?do=moder&name=' .. nick .. '&alevel=' .. params[2] .. '&' .. moderpas .. '')
						local re1 = regex.new("@@.@ (Add complete|Alevel changed|Delete complete|Error) @@..@.@") --
						local names = re1:match(responsetext)
						if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Неизвестная ошибка.", 0xffff0000) return end

						if names == "Add complete" then sendtolog("Выдал права модератора уровня " .. params[2] .. " игроку " .. nick .. ".", 2) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Игроку " .. nick .. " были выданы права модератора.", 0xffff0000) return end
						if names == "Alevel changed" then sendtolog("Изменил права модератора на уровень " .. params[2] .. " игроку " .. nick .. ".", 2) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Уровень доступа игрока " .. nick .. " был успешно изменен.", 0xffff0000) return end
						if names == "Delete complete" then sendtolog("Забрал права модератора у игрока игрока " .. nick .. ".", 2) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Права модератора у игрока " .. nick .. " были успешно анулированы.", 0xffff0000) return end
						if names == "Error" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось забрать права модератора у игрока " .. nick .. ".", 0xffff0000) return end

				end
		)
end



function calculateZone(x, y, z)
    local streets = {
	{"Restricted Area", -91.586, 1655.050, -50.000, 421.234, 2123.010, 250.000},
	{"Restricted Area", 117.000000,2091.000000,-500.0,436.000000,2145.000000,500.0},
	{"Restricted Area", -58.000000,1584.000000,-500,436.000000,1655.000000,500},
	{"Restricted Area", 83.000000,1570.000000,-500,380.000000,1575.000000,500},
	{"Restricted Area", 161.000000,1546.000000,-500,409.000000,1664.000000,500},
	{"Restricted Area", 84.000000,1577.000000,-500,226.000000,1637.000000,500},
	{"Restricted Area", 376.000000,1695.000000,-500,483.000000,1699.000000,500},
	{"Restricted Area", 408.000000,1691.000000,-500,518.000000,1775.000000,500},
	{"Restricted Area", 418.000000,1733.000000,-500,471.000000,2151.000000,500},
	{"Restricted Area", 476.000000,1746.000000,-500,579.000000,1877.000000,500},
	{"Restricted Area", 457.000000,1882.000000,-500,597.000000,1993.000000,500},
	{"Restricted Area", 436.000000,1985.000000,-500,552.000000,2133.000000,500},
	{"Avispa Country Club", -2667.810, -302.135, -28.831, -2646.400, -262.320, 71.169},
    {"Easter Bay Airport", -1315.420, -405.388, 15.406, -1264.400, -209.543, 25.406},
    {"Avispa Country Club", -2550.040, -355.493, 0.000, -2470.040, -318.493, 39.700},
    {"Easter Bay Airport", -1490.330, -209.543, 15.406, -1264.400, -148.388, 25.406},
    {"Garcia", -2395.140, -222.589, -5.3, -2354.090, -204.792, 200.000},
    {"Shady Cabin", -1632.830, -2263.440, -3.0, -1601.330, -2231.790, 200.000},
    {"East Los Santos", 2381.680, -1494.030, -89.084, 2421.030, -1454.350, 110.916},
    {"LVA Freight Depot", 1236.630, 1163.410, -89.084, 1277.050, 1203.280, 110.916},
    {"Blackfield Intersection", 1277.050, 1044.690, -89.084, 1315.350, 1087.630, 110.916},
    {"Avispa Country Club", -2470.040, -355.493, 0.000, -2270.040, -318.493, 46.100},
    {"Temple", 1252.330, -926.999, -89.084, 1357.000, -910.170, 110.916},
    {"Unity Station", 1692.620, -1971.800, -20.492, 1812.620, -1932.800, 79.508},
    {"LVA Freight Depot", 1315.350, 1044.690, -89.084, 1375.600, 1087.630, 110.916},
    {"Los Flores", 2581.730, -1454.350, -89.084, 2632.830, -1393.420, 110.916},
    {"Starfish Casino", 2437.390, 1858.100, -39.084, 2495.090, 1970.850, 60.916},
    {"Easter Bay Chemicals", -1132.820, -787.391, 0.000, -956.476, -768.027, 200.000},
    {"Downtown Los Santos", 1370.850, -1170.870, -89.084, 1463.900, -1130.850, 110.916},
    {"Esplanade East", -1620.300, 1176.520, -4.5, -1580.010, 1274.260, 200.000},
    {"Market Station", 787.461, -1410.930, -34.126, 866.009, -1310.210, 65.874},
    {"Linden Station", 2811.250, 1229.590, -39.594, 2861.250, 1407.590, 60.406},
    {"Montgomery Intersection", 1582.440, 347.457, 0.000, 1664.620, 401.750, 200.000},
    {"Frederick Bridge", 2759.250, 296.501, 0.000, 2774.250, 594.757, 200.000},
    {"Yellow Bell Station", 1377.480, 2600.430, -21.926, 1492.450, 2687.360, 78.074},
    {"Downtown Los Santos", 1507.510, -1385.210, 110.916, 1582.550, -1325.310, 335.916},
    {"Jefferson", 2185.330, -1210.740, -89.084, 2281.450, -1154.590, 110.916},
    {"Mulholland", 1318.130, -910.170, -89.084, 1357.000, -768.027, 110.916},
    {"Avispa Country Club", -2361.510, -417.199, 0.000, -2270.040, -355.493, 200.000},
    {"Jefferson", 1996.910, -1449.670, -89.084, 2056.860, -1350.720, 110.916},
    {"Julius Thruway West", 1236.630, 2142.860, -89.084, 1297.470, 2243.230, 110.916},
    {"Jefferson", 2124.660, -1494.030, -89.084, 2266.210, -1449.670, 110.916},
    {"Julius Thruway North", 1848.400, 2478.490, -89.084, 1938.800, 2553.490, 110.916},
    {"Rodeo", 422.680, -1570.200, -89.084, 466.223, -1406.050, 110.916},
    {"Cranberry Station", -2007.830, 56.306, 0.000, -1922.000, 224.782, 100.000},
    {"Downtown Los Santos", 1391.050, -1026.330, -89.084, 1463.900, -926.999, 110.916},
    {"Redsands West", 1704.590, 2243.230, -89.084, 1777.390, 2342.830, 110.916},
    {"Little Mexico", 1758.900, -1722.260, -89.084, 1812.620, -1577.590, 110.916},
    {"Blackfield Intersection", 1375.600, 823.228, -89.084, 1457.390, 919.447, 110.916},
    {"Los Santos International", 1974.630, -2394.330, -39.084, 2089.000, -2256.590, 60.916},
    {"Beacon Hill", -399.633, -1075.520, -1.489, -319.033, -977.516, 198.511},
    {"Rodeo", 334.503, -1501.950, -89.084, 422.680, -1406.050, 110.916},
    {"Richman", 225.165, -1369.620, -89.084, 334.503, -1292.070, 110.916},
    {"Downtown Los Santos", 1724.760, -1250.900, -89.084, 1812.620, -1150.870, 110.916},
    {"The Strip", 2027.400, 1703.230, -89.084, 2137.400, 1783.230, 110.916},
    {"Downtown Los Santos", 1378.330, -1130.850, -89.084, 1463.900, -1026.330, 110.916},
    {"Blackfield Intersection", 1197.390, 1044.690, -89.084, 1277.050, 1163.390, 110.916},
    {"Conference Center", 1073.220, -1842.270, -89.084, 1323.900, -1804.210, 110.916},
    {"Montgomery", 1451.400, 347.457, -6.1, 1582.440, 420.802, 200.000},
    {"Foster Valley", -2270.040, -430.276, -1.2, -2178.690, -324.114, 200.000},
    {"Blackfield Chapel", 1325.600, 596.349, -89.084, 1375.600, 795.010, 110.916},
    {"Los Santos International", 2051.630, -2597.260, -39.084, 2152.450, -2394.330, 60.916},
    {"Mulholland", 1096.470, -910.170, -89.084, 1169.130, -768.027, 110.916},
    {"Yellow Bell Gol Course", 1457.460, 2723.230, -89.084, 1534.560, 2863.230, 110.916},
    {"The Strip", 2027.400, 1783.230, -89.084, 2162.390, 1863.230, 110.916},
    {"Jefferson", 2056.860, -1210.740, -89.084, 2185.330, -1126.320, 110.916},
    {"Mulholland", 952.604, -937.184, -89.084, 1096.470, -860.619, 110.916},
    {"Aldea Malvada", -1372.140, 2498.520, 0.000, -1277.590, 2615.350, 200.000},
    {"Las Colinas", 2126.860, -1126.320, -89.084, 2185.330, -934.489, 110.916},
    {"Las Colinas", 1994.330, -1100.820, -89.084, 2056.860, -920.815, 110.916},
    {"Richman", 647.557, -954.662, -89.084, 768.694, -860.619, 110.916},
    {"LVA Freight Depot", 1277.050, 1087.630, -89.084, 1375.600, 1203.280, 110.916},
    {"Julius Thruway North", 1377.390, 2433.230, -89.084, 1534.560, 2507.230, 110.916},
    {"Willowfield", 2201.820, -2095.000, -89.084, 2324.000, -1989.900, 110.916},
    {"Julius Thruway North", 1704.590, 2342.830, -89.084, 1848.400, 2433.230, 110.916},
    {"Temple", 1252.330, -1130.850, -89.084, 1378.330, -1026.330, 110.916},
    {"Little Mexico", 1701.900, -1842.270, -89.084, 1812.620, -1722.260, 110.916},
    {"Queens", -2411.220, 373.539, 0.000, -2253.540, 458.411, 200.000},
    {"Las Venturas Airport", 1515.810, 1586.400, -12.500, 1729.950, 1714.560, 87.500},
    {"Richman", 225.165, -1292.070, -89.084, 466.223, -1235.070, 110.916},
    {"Temple", 1252.330, -1026.330, -89.084, 1391.050, -926.999, 110.916},
    {"East Los Santos", 2266.260, -1494.030, -89.084, 2381.680, -1372.040, 110.916},
    {"Julius Thruway East", 2623.180, 943.235, -89.084, 2749.900, 1055.960, 110.916},
    {"Willowfield", 2541.700, -1941.400, -89.084, 2703.580, -1852.870, 110.916},
    {"Las Colinas", 2056.860, -1126.320, -89.084, 2126.860, -920.815, 110.916},
    {"Julius Thruway East", 2625.160, 2202.760, -89.084, 2685.160, 2442.550, 110.916},
    {"Rodeo", 225.165, -1501.950, -89.084, 334.503, -1369.620, 110.916},
    {"Las Brujas", -365.167, 2123.010, -3.0, -208.570, 2217.680, 200.000},
    {"Julius Thruway East", 2536.430, 2442.550, -89.084, 2685.160, 2542.550, 110.916},
    {"Rodeo", 334.503, -1406.050, -89.084, 466.223, -1292.070, 110.916},
    {"Vinewood", 647.557, -1227.280, -89.084, 787.461, -1118.280, 110.916},
    {"Rodeo", 422.680, -1684.650, -89.084, 558.099, -1570.200, 110.916},
    {"Julius Thruway North", 2498.210, 2542.550, -89.084, 2685.160, 2626.550, 110.916},
    {"Downtown Los Santos", 1724.760, -1430.870, -89.084, 1812.620, -1250.900, 110.916},
    {"Rodeo", 225.165, -1684.650, -89.084, 312.803, -1501.950, 110.916},
    {"Jefferson", 2056.860, -1449.670, -89.084, 2266.210, -1372.040, 110.916},
    {"Hampton Barns", 603.035, 264.312, 0.000, 761.994, 366.572, 200.000},
    {"Temple", 1096.470, -1130.840, -89.084, 1252.330, -1026.330, 110.916},
    {"Kincaid Bridge", -1087.930, 855.370, -89.084, -961.950, 986.281, 110.916},
    {"Verona Beach", 1046.150, -1722.260, -89.084, 1161.520, -1577.590, 110.916},
    {"Commerce", 1323.900, -1722.260, -89.084, 1440.900, -1577.590, 110.916},
    {"Mulholland", 1357.000, -926.999, -89.084, 1463.900, -768.027, 110.916},
    {"Rodeo", 466.223, -1570.200, -89.084, 558.099, -1385.070, 110.916},
    {"Mulholland", 911.802, -860.619, -89.084, 1096.470, -768.027, 110.916},
    {"Mulholland", 768.694, -954.662, -89.084, 952.604, -860.619, 110.916},
    {"Julius Thruway South", 2377.390, 788.894, -89.084, 2537.390, 897.901, 110.916},
    {"Idlewood", 1812.620, -1852.870, -89.084, 1971.660, -1742.310, 110.916},
    {"Ocean Docks", 2089.000, -2394.330, -89.084, 2201.820, -2235.840, 110.916},
    {"Commerce", 1370.850, -1577.590, -89.084, 1463.900, -1384.950, 110.916},
    {"Julius Thruway North", 2121.400, 2508.230, -89.084, 2237.400, 2663.170, 110.916},
    {"Temple", 1096.470, -1026.330, -89.084, 1252.330, -910.170, 110.916},
    {"Glen Park", 1812.620, -1449.670, -89.084, 1996.910, -1350.720, 110.916},
    {"Easter Bay Airport", -1242.980, -50.096, 0.000, -1213.910, 578.396, 200.000},
    {"Martin Bridge", -222.179, 293.324, 0.000, -122.126, 476.465, 200.000},
    {"The Strip", 2106.700, 1863.230, -89.084, 2162.390, 2202.760, 110.916},
    {"Willowfield", 2541.700, -2059.230, -89.084, 2703.580, -1941.400, 110.916},
    {"Marina", 807.922, -1577.590, -89.084, 926.922, -1416.250, 110.916},
    {"Las Venturas Airport", 1457.370, 1143.210, -89.084, 1777.400, 1203.280, 110.916},
    {"Idlewood", 1812.620, -1742.310, -89.084, 1951.660, -1602.310, 110.916},
    {"Esplanade East", -1580.010, 1025.980, -6.1, -1499.890, 1274.260, 200.000},
    {"Downtown Los Santos", 1370.850, -1384.950, -89.084, 1463.900, -1170.870, 110.916},
    {"The Mako Span", 1664.620, 401.750, 0.000, 1785.140, 567.203, 200.000},
    {"Rodeo", 312.803, -1684.650, -89.084, 422.680, -1501.950, 110.916},
    {"Pershing Square", 1440.900, -1722.260, -89.084, 1583.500, -1577.590, 110.916},
    {"Mulholland", 687.802, -860.619, -89.084, 911.802, -768.027, 110.916},
    {"Gant Bridge", -2741.070, 1490.470, -6.1, -2616.400, 1659.680, 200.000},
    {"Las Colinas", 2185.330, -1154.590, -89.084, 2281.450, -934.489, 110.916},
    {"Mulholland", 1169.130, -910.170, -89.084, 1318.130, -768.027, 110.916},
    {"Julius Thruway North", 1938.800, 2508.230, -89.084, 2121.400, 2624.230, 110.916},
    {"Commerce", 1667.960, -1577.590, -89.084, 1812.620, -1430.870, 110.916},
    {"Rodeo", 72.648, -1544.170, -89.084, 225.165, -1404.970, 110.916},
    {"Roca Escalante", 2536.430, 2202.760, -89.084, 2625.160, 2442.550, 110.916},
    {"Rodeo", 72.648, -1684.650, -89.084, 225.165, -1544.170, 110.916},
    {"Market", 952.663, -1310.210, -89.084, 1072.660, -1130.850, 110.916},
    {"Las Colinas", 2632.740, -1135.040, -89.084, 2747.740, -945.035, 110.916},
    {"Mulholland", 861.085, -674.885, -89.084, 1156.550, -600.896, 110.916},
    {"King's", -2253.540, 373.539, -9.1, -1993.280, 458.411, 200.000},
    {"Redsands East", 1848.400, 2342.830, -89.084, 2011.940, 2478.490, 110.916},
    {"Downtown", -1580.010, 744.267, -6.1, -1499.890, 1025.980, 200.000},
    {"Conference Center", 1046.150, -1804.210, -89.084, 1323.900, -1722.260, 110.916},
    {"Richman", 647.557, -1118.280, -89.084, 787.461, -954.662, 110.916},
    {"Ocean Flats", -2994.490, 277.411, -9.1, -2867.850, 458.411, 200.000},
    {"Greenglass College", 964.391, 930.890, -89.084, 1166.530, 1044.690, 110.916},
    {"Glen Park", 1812.620, -1100.820, -89.084, 1994.330, -973.380, 110.916},
    {"LVA Freight Depot", 1375.600, 919.447, -89.084, 1457.370, 1203.280, 110.916},
    {"Regular Tom", -405.770, 1712.860, -3.0, -276.719, 1892.750, 200.000},
    {"Verona Beach", 1161.520, -1722.260, -89.084, 1323.900, -1577.590, 110.916},
    {"East Los Santos", 2281.450, -1372.040, -89.084, 2381.680, -1135.040, 110.916},
    {"Caligula's Palace", 2137.400, 1703.230, -89.084, 2437.390, 1783.230, 110.916},
    {"Idlewood", 1951.660, -1742.310, -89.084, 2124.660, -1602.310, 110.916},
    {"Pilgrim", 2624.400, 1383.230, -89.084, 2685.160, 1783.230, 110.916},
    {"Idlewood", 2124.660, -1742.310, -89.084, 2222.560, -1494.030, 110.916},
    {"Queens", -2533.040, 458.411, 0.000, -2329.310, 578.396, 200.000},
    {"Downtown", -1871.720, 1176.420, -4.5, -1620.300, 1274.260, 200.000},
    {"Commerce", 1583.500, -1722.260, -89.084, 1758.900, -1577.590, 110.916},
    {"East Los Santos", 2381.680, -1454.350, -89.084, 2462.130, -1135.040, 110.916},
    {"Marina", 647.712, -1577.590, -89.084, 807.922, -1416.250, 110.916},
    {"Richman", 72.648, -1404.970, -89.084, 225.165, -1235.070, 110.916},
    {"Vinewood", 647.712, -1416.250, -89.084, 787.461, -1227.280, 110.916},
    {"East Los Santos", 2222.560, -1628.530, -89.084, 2421.030, -1494.030, 110.916},
    {"Rodeo", 558.099, -1684.650, -89.084, 647.522, -1384.930, 110.916},
    {"Easter Tunnel", -1709.710, -833.034, -1.5, -1446.010, -730.118, 200.000},
    {"Rodeo", 466.223, -1385.070, -89.084, 647.522, -1235.070, 110.916},
    {"Redsands East", 1817.390, 2202.760, -89.084, 2011.940, 2342.830, 110.916},
    {"The Clown's Pocket", 2162.390, 1783.230, -89.084, 2437.390, 1883.230, 110.916},
    {"Idlewood", 1971.660, -1852.870, -89.084, 2222.560, -1742.310, 110.916},
    {"Montgomery Intersection", 1546.650, 208.164, 0.000, 1745.830, 347.457, 200.000},
    {"Willowfield", 2089.000, -2235.840, -89.084, 2201.820, -1989.900, 110.916},
    {"Temple", 952.663, -1130.840, -89.084, 1096.470, -937.184, 110.916},
    {"Prickle Pine", 1848.400, 2553.490, -89.084, 1938.800, 2863.230, 110.916},
    {"Los Santos International", 1400.970, -2669.260, -39.084, 2189.820, -2597.260, 60.916},
    {"Garver Bridge", -1213.910, 950.022, -89.084, -1087.930, 1178.930, 110.916},
    {"Garver Bridge", -1339.890, 828.129, -89.084, -1213.910, 1057.040, 110.916},
    {"Kincaid Bridge", -1339.890, 599.218, -89.084, -1213.910, 828.129, 110.916},
    {"Kincaid Bridge", -1213.910, 721.111, -89.084, -1087.930, 950.022, 110.916},
    {"Verona Beach", 930.221, -2006.780, -89.084, 1073.220, -1804.210, 110.916},
    {"Verdant Bluffs", 1073.220, -2006.780, -89.084, 1249.620, -1842.270, 110.916},
    {"Vinewood", 787.461, -1130.840, -89.084, 952.604, -954.662, 110.916},
    {"Vinewood", 787.461, -1310.210, -89.084, 952.663, -1130.840, 110.916},
    {"Commerce", 1463.900, -1577.590, -89.084, 1667.960, -1430.870, 110.916},
    {"Market", 787.461, -1416.250, -89.084, 1072.660, -1310.210, 110.916},
    {"Rockshore West", 2377.390, 596.349, -89.084, 2537.390, 788.894, 110.916},
    {"Julius Thruway North", 2237.400, 2542.550, -89.084, 2498.210, 2663.170, 110.916},
    {"East Beach", 2632.830, -1668.130, -89.084, 2747.740, -1393.420, 110.916},
    {"Fallow Bridge", 434.341, 366.572, 0.000, 603.035, 555.680, 200.000},
    {"Willowfield", 2089.000, -1989.900, -89.084, 2324.000, -1852.870, 110.916},
    {"Chinatown", -2274.170, 578.396, -7.6, -2078.670, 744.170, 200.000},
    {"El Castillo del Diablo", -208.570, 2337.180, 0.000, 8.430, 2487.180, 200.000},
    {"Ocean Docks", 2324.000, -2145.100, -89.084, 2703.580, -2059.230, 110.916},
    {"Easter Bay Chemicals", -1132.820, -768.027, 0.000, -956.476, -578.118, 200.000},
    {"The Visage", 1817.390, 1703.230, -89.084, 2027.400, 1863.230, 110.916},
    {"Ocean Flats", -2994.490, -430.276, -1.2, -2831.890, -222.589, 200.000},
    {"Richman", 321.356, -860.619, -89.084, 687.802, -768.027, 110.916},
    {"Green Palms", 176.581, 1305.450, -3.0, 338.658, 1520.720, 200.000},
    {"Richman", 321.356, -768.027, -89.084, 700.794, -674.885, 110.916},
    {"Starfish Casino", 2162.390, 1883.230, -89.084, 2437.390, 2012.180, 110.916},
    {"East Beach", 2747.740, -1668.130, -89.084, 2959.350, -1498.620, 110.916},
    {"Jefferson", 2056.860, -1372.040, -89.084, 2281.450, -1210.740, 110.916},
    {"Downtown Los Santos", 1463.900, -1290.870, -89.084, 1724.760, -1150.870, 110.916},
    {"Downtown Los Santos", 1463.900, -1430.870, -89.084, 1724.760, -1290.870, 110.916},
    {"Garver Bridge", -1499.890, 696.442, -179.615, -1339.890, 925.353, 20.385},
    {"Julius Thruway South", 1457.390, 823.228, -89.084, 2377.390, 863.229, 110.916},
    {"East Los Santos", 2421.030, -1628.530, -89.084, 2632.830, -1454.350, 110.916},
    {"Greenglass College", 964.391, 1044.690, -89.084, 1197.390, 1203.220, 110.916},
    {"Las Colinas", 2747.740, -1120.040, -89.084, 2959.350, -945.035, 110.916},
    {"Mulholland", 737.573, -768.027, -89.084, 1142.290, -674.885, 110.916},
    {"Ocean Docks", 2201.820, -2730.880, -89.084, 2324.000, -2418.330, 110.916},
    {"East Los Santos", 2462.130, -1454.350, -89.084, 2581.730, -1135.040, 110.916},
    {"Ganton", 2222.560, -1722.330, -89.084, 2632.830, -1628.530, 110.916},
    {"Avispa Country Club", -2831.890, -430.276, -6.1, -2646.400, -222.589, 200.000},
    {"Willowfield", 1970.620, -2179.250, -89.084, 2089.000, -1852.870, 110.916},
    {"Esplanade North", -1982.320, 1274.260, -4.5, -1524.240, 1358.900, 200.000},
    {"The High Roller", 1817.390, 1283.230, -89.084, 2027.390, 1469.230, 110.916},
    {"Ocean Docks", 2201.820, -2418.330, -89.084, 2324.000, -2095.000, 110.916},
    {"Last Dime Motel", 1823.080, 596.349, -89.084, 1997.220, 823.228, 110.916},
    {"Bayside Marina", -2353.170, 2275.790, 0.000, -2153.170, 2475.790, 200.000},
    {"King's", -2329.310, 458.411, -7.6, -1993.280, 578.396, 200.000},
    {"El Corona", 1692.620, -2179.250, -89.084, 1812.620, -1842.270, 110.916},
    {"Blackfield Chapel", 1375.600, 596.349, -89.084, 1558.090, 823.228, 110.916},
    {"The Pink Swan", 1817.390, 1083.230, -89.084, 2027.390, 1283.230, 110.916},
    {"Julius Thruway West", 1197.390, 1163.390, -89.084, 1236.630, 2243.230, 110.916},
    {"Los Flores", 2581.730, -1393.420, -89.084, 2747.740, -1135.040, 110.916},
    {"The Visage", 1817.390, 1863.230, -89.084, 2106.700, 2011.830, 110.916},
    {"Prickle Pine", 1938.800, 2624.230, -89.084, 2121.400, 2861.550, 110.916},
    {"Verona Beach", 851.449, -1804.210, -89.084, 1046.150, -1577.590, 110.916},
    {"Robada Intersection", -1119.010, 1178.930, -89.084, -862.025, 1351.450, 110.916},
    {"Linden Side", 2749.900, 943.235, -89.084, 2923.390, 1198.990, 110.916},
    {"Ocean Docks", 2703.580, -2302.330, -89.084, 2959.350, -2126.900, 110.916},
    {"Willowfield", 2324.000, -2059.230, -89.084, 2541.700, -1852.870, 110.916},
    {"King's", -2411.220, 265.243, -9.1, -1993.280, 373.539, 200.000},
    {"Commerce", 1323.900, -1842.270, -89.084, 1701.900, -1722.260, 110.916},
    {"Mulholland", 1269.130, -768.027, -89.084, 1414.070, -452.425, 110.916},
    {"Marina", 647.712, -1804.210, -89.084, 851.449, -1577.590, 110.916},
    {"Battery Point", -2741.070, 1268.410, -4.5, -2533.040, 1490.470, 200.000},
    {"The Four Dragons Casino", 1817.390, 863.232, -89.084, 2027.390, 1083.230, 110.916},
    {"Blackfield", 964.391, 1203.220, -89.084, 1197.390, 1403.220, 110.916},
    {"Julius Thruway North", 1534.560, 2433.230, -89.084, 1848.400, 2583.230, 110.916},
    {"Yellow Bell Gol Course", 1117.400, 2723.230, -89.084, 1457.460, 2863.230, 110.916},
    {"Idlewood", 1812.620, -1602.310, -89.084, 2124.660, -1449.670, 110.916},
    {"Redsands West", 1297.470, 2142.860, -89.084, 1777.390, 2243.230, 110.916},
    {"Doherty", -2270.040, -324.114, -1.2, -1794.920, -222.589, 200.000},
    {"Hilltop Farm", 967.383, -450.390, -3.0, 1176.780, -217.900, 200.000},
    {"Las Barrancas", -926.130, 1398.730, -3.0, -719.234, 1634.690, 200.000},
    {"Pirates in Men's Pants", 1817.390, 1469.230, -89.084, 2027.400, 1703.230, 110.916},
    {"City Hall", -2867.850, 277.411, -9.1, -2593.440, 458.411, 200.000},
    {"Avispa Country Club", -2646.400, -355.493, 0.000, -2270.040, -222.589, 200.000},
    {"The Strip", 2027.400, 863.229, -89.084, 2087.390, 1703.230, 110.916},
    {"Hashbury", -2593.440, -222.589, -1.0, -2411.220, 54.722, 200.000},
    {"Los Santos International", 1852.000, -2394.330, -89.084, 2089.000, -2179.250, 110.916},
    {"Whitewood Estates", 1098.310, 1726.220, -89.084, 1197.390, 2243.230, 110.916},
    {"Sherman Reservoir", -789.737, 1659.680, -89.084, -599.505, 1929.410, 110.916},
    {"El Corona", 1812.620, -2179.250, -89.084, 1970.620, -1852.870, 110.916},
    {"Downtown", -1700.010, 744.267, -6.1, -1580.010, 1176.520, 200.000},
    {"Foster Valley", -2178.690, -1250.970, 0.000, -1794.920, -1115.580, 200.000},
    {"Las Payasadas", -354.332, 2580.360, 2.0, -133.625, 2816.820, 200.000},
    {"Valle Ocultado", -936.668, 2611.440, 2.0, -715.961, 2847.900, 200.000},
    {"Blackfield Intersection", 1166.530, 795.010, -89.084, 1375.600, 1044.690, 110.916},
    {"Ganton", 2222.560, -1852.870, -89.084, 2632.830, -1722.330, 110.916},
    {"Easter Bay Airport", -1213.910, -730.118, 0.000, -1132.820, -50.096, 200.000},
    {"Redsands East", 1817.390, 2011.830, -89.084, 2106.700, 2202.760, 110.916},
    {"Esplanade East", -1499.890, 578.396, -79.615, -1339.890, 1274.260, 20.385},
    {"Caligula's Palace", 2087.390, 1543.230, -89.084, 2437.390, 1703.230, 110.916},
    {"Royal Casino", 2087.390, 1383.230, -89.084, 2437.390, 1543.230, 110.916},
    {"Richman", 72.648, -1235.070, -89.084, 321.356, -1008.150, 110.916},
    {"Starfish Casino", 2437.390, 1783.230, -89.084, 2685.160, 2012.180, 110.916},
    {"Mulholland", 1281.130, -452.425, -89.084, 1641.130, -290.913, 110.916},
    {"Downtown", -1982.320, 744.170, -6.1, -1871.720, 1274.260, 200.000},
    {"Hankypanky Point", 2576.920, 62.158, 0.000, 2759.250, 385.503, 200.000},
    {"K.A.C.C. Military Fuels", 2498.210, 2626.550, -89.084, 2749.900, 2861.550, 110.916},
    {"Harry Gold Parkway", 1777.390, 863.232, -89.084, 1817.390, 2342.830, 110.916},
    {"Bayside Tunnel", -2290.190, 2548.290, -89.084, -1950.190, 2723.290, 110.916},
    {"Ocean Docks", 2324.000, -2302.330, -89.084, 2703.580, -2145.100, 110.916},
    {"Richman", 321.356, -1044.070, -89.084, 647.557, -860.619, 110.916},
    {"Randolph Industrial Estate", 1558.090, 596.349, -89.084, 1823.080, 823.235, 110.916},
    {"East Beach", 2632.830, -1852.870, -89.084, 2959.350, -1668.130, 110.916},
    {"Flint Water", -314.426, -753.874, -89.084, -106.339, -463.073, 110.916},
    {"Blueberry", 19.607, -404.136, 3.8, 349.607, -220.137, 200.000},
    {"Linden Station", 2749.900, 1198.990, -89.084, 2923.390, 1548.990, 110.916},
    {"Glen Park", 1812.620, -1350.720, -89.084, 2056.860, -1100.820, 110.916},
    {"Downtown", -1993.280, 265.243, -9.1, -1794.920, 578.396, 200.000},
    {"Redsands West", 1377.390, 2243.230, -89.084, 1704.590, 2433.230, 110.916},
    {"Richman", 321.356, -1235.070, -89.084, 647.522, -1044.070, 110.916},
    {"Gant Bridge", -2741.450, 1659.680, -6.1, -2616.400, 2175.150, 200.000},
    {"Lil' Probe Inn", -90.218, 1286.850, -3.0, 153.859, 1554.120, 200.000},
    {"Flint Intersection", -187.700, -1596.760, -89.084, 17.063, -1276.600, 110.916},
    {"Las Colinas", 2281.450, -1135.040, -89.084, 2632.740, -945.035, 110.916},
    {"Sobell Rail Yards", 2749.900, 1548.990, -89.084, 2923.390, 1937.250, 110.916},
    {"The Emerald Isle", 2011.940, 2202.760, -89.084, 2237.400, 2508.230, 110.916},
    {"El Castillo del Diablo", -208.570, 2123.010, -7.6, 114.033, 2337.180, 200.000},
    {"Santa Flora", -2741.070, 458.411, -7.6, -2533.040, 793.411, 200.000},
    {"Playa del Seville", 2703.580, -2126.900, -89.084, 2959.350, -1852.870, 110.916},
    {"Market", 926.922, -1577.590, -89.084, 1370.850, -1416.250, 110.916},
    {"Queens", -2593.440, 54.722, 0.000, -2411.220, 458.411, 200.000},
    {"Pilson Intersection", 1098.390, 2243.230, -89.084, 1377.390, 2507.230, 110.916},
    {"Spinybed", 2121.400, 2663.170, -89.084, 2498.210, 2861.550, 110.916},
    {"Pilgrim", 2437.390, 1383.230, -89.084, 2624.400, 1783.230, 110.916},
    {"Blackfield", 964.391, 1403.220, -89.084, 1197.390, 1726.220, 110.916},
    {"'The Big Ear'", -410.020, 1403.340, -3.0, -137.969, 1681.230, 200.000},
    {"Dillimore", 580.794, -674.885, -9.5, 861.085, -404.790, 200.000},
    {"El Quebrados", -1645.230, 2498.520, 0.000, -1372.140, 2777.850, 200.000},
    {"Esplanade North", -2533.040, 1358.900, -4.5, -1996.660, 1501.210, 200.000},
    {"Easter Bay Airport", -1499.890, -50.096, -1.0, -1242.980, 249.904, 200.000},
    {"Fisher's Lagoon", 1916.990, -233.323, -100.000, 2131.720, 13.800, 200.000},
    {"Mulholland", 1414.070, -768.027, -89.084, 1667.610, -452.425, 110.916},
    {"East Beach", 2747.740, -1498.620, -89.084, 2959.350, -1120.040, 110.916},
    {"San Andreas Sound", 2450.390, 385.503, -100.000, 2759.250, 562.349, 200.000},
    {"Shady Creeks", -2030.120, -2174.890, -6.1, -1820.640, -1771.660, 200.000},
    {"Market", 1072.660, -1416.250, -89.084, 1370.850, -1130.850, 110.916},
    {"Rockshore West", 1997.220, 596.349, -89.084, 2377.390, 823.228, 110.916},
    {"Prickle Pine", 1534.560, 2583.230, -89.084, 1848.400, 2863.230, 110.916},
    {"Easter Basin", -1794.920, -50.096, -1.04, -1499.890, 249.904, 200.000},
    {"Leafy Hollow", -1166.970, -1856.030, 0.000, -815.624, -1602.070, 200.000},
    {"LVA Freight Depot", 1457.390, 863.229, -89.084, 1777.400, 1143.210, 110.916},
    {"Prickle Pine", 1117.400, 2507.230, -89.084, 1534.560, 2723.230, 110.916},
    {"Blueberry", 104.534, -220.137, 2.3, 349.607, 152.236, 200.000},
    {"El Castillo del Diablo", -464.515, 2217.680, 0.000, -208.570, 2580.360, 200.000},
    {"Downtown", -2078.670, 578.396, -7.6, -1499.890, 744.267, 200.000},
    {"Rockshore East", 2537.390, 676.549, -89.084, 2902.350, 943.235, 110.916},
    {"San Fierro Bay", -2616.400, 1501.210, -3.0, -1996.660, 1659.680, 200.000},
    {"Paradiso", -2741.070, 793.411, -6.1, -2533.040, 1268.410, 200.000},
    {"The Camel's Toe", 2087.390, 1203.230, -89.084, 2640.400, 1383.230, 110.916},
    {"Old Venturas Strip", 2162.390, 2012.180, -89.084, 2685.160, 2202.760, 110.916},
    {"Juniper Hill", -2533.040, 578.396, -7.6, -2274.170, 968.369, 200.000},
    {"Juniper Hollow", -2533.040, 968.369, -6.1, -2274.170, 1358.900, 200.000},
    {"Roca Escalante", 2237.400, 2202.760, -89.084, 2536.430, 2542.550, 110.916},
    {"Julius Thruway East", 2685.160, 1055.960, -89.084, 2749.900, 2626.550, 110.916},
    {"Verona Beach", 647.712, -2173.290, -89.084, 930.221, -1804.210, 110.916},
    {"Foster Valley", -2178.690, -599.884, -1.2, -1794.920, -324.114, 200.000},
    {"Arco del Oeste", -901.129, 2221.860, 0.000, -592.090, 2571.970, 200.000},
    {"Fallen Tree", -792.254, -698.555, -5.3, -452.404, -380.043, 200.000},
    {"The Farm", -1209.670, -1317.100, 114.981, -908.161, -787.391, 251.981},
    {"The Sherman Dam", -968.772, 1929.410, -3.0, -481.126, 2155.260, 200.000},
    {"Esplanade North", -1996.660, 1358.900, -4.5, -1524.240, 1592.510, 200.000},
    {"Financial", -1871.720, 744.170, -6.1, -1701.300, 1176.420, 300.000},
    {"Garcia", -2411.220, -222.589, -1.14, -2173.040, 265.243, 200.000},
    {"Montgomery", 1119.510, 119.526, -3.0, 1451.400, 493.323, 200.000},
    {"Creek", 2749.900, 1937.250, -89.084, 2921.620, 2669.790, 110.916},
    {"Los Santos International", 1249.620, -2394.330, -89.084, 1852.000, -2179.250, 110.916},
    {"Santa Maria Beach", 72.648, -2173.290, -89.084, 342.648, -1684.650, 110.916},
    {"Mulholland Intersection", 1463.900, -1150.870, -89.084, 1812.620, -768.027, 110.916},
    {"Angel Pine", -2324.940, -2584.290, -6.1, -1964.220, -2212.110, 200.000},
    {"Verdant Meadows", 37.032, 2337.180, -3.0, 435.988, 2677.900, 200.000},
    {"Octane Springs", 338.658, 1228.510, 0.000, 664.308, 1655.050, 200.000},
    {"Come-A-Lot", 2087.390, 943.235, -89.084, 2623.180, 1203.230, 110.916},
    {"Redsands West", 1236.630, 1883.110, -89.084, 1777.390, 2142.860, 110.916},
    {"Santa Maria Beach", 342.648, -2173.290, -89.084, 647.712, -1684.650, 110.916},
    {"Verdant Bluffs", 1249.620, -2179.250, -89.084, 1692.620, -1842.270, 110.916},
    {"Las Venturas Airport", 1236.630, 1203.280, -89.084, 1457.370, 1883.110, 110.916},
    {"Flint Range", -594.191, -1648.550, 0.000, -187.700, -1276.600, 200.000},
    {"Verdant Bluffs", 930.221, -2488.420, -89.084, 1249.620, -2006.780, 110.916},
    {"Palomino Creek", 2160.220, -149.004, 0.000, 2576.920, 228.322, 200.000},
    {"Ocean Docks", 2373.770, -2697.090, -89.084, 2809.220, -2330.460, 110.916},
    {"Easter Bay Airport", -1213.910, -50.096, -4.5, -947.980, 578.396, 200.000},
    {"Whitewood Estates", 883.308, 1726.220, -89.084, 1098.310, 2507.230, 110.916},
    {"Calton Heights", -2274.170, 744.170, -6.1, -1982.320, 1358.900, 200.000},
    {"Easter Basin", -1794.920, 249.904, -9.1, -1242.980, 578.396, 200.000},
    {"Los Santos Inlet", -321.744, -2224.430, -89.084, 44.615, -1724.430, 110.916},
    {"Doherty", -2173.040, -222.589, -1.0, -1794.920, 265.243, 200.000},
    {"Mount Chiliad", -2178.690, -2189.910, -47.917, -2030.120, -1771.660, 576.083},
    {"Fort Carson", -376.233, 826.326, -3.0, 123.717, 1220.440, 200.000},
    {"Foster Valley", -2178.690, -1115.580, 0.000, -1794.920, -599.884, 200.000},
    {"Ocean Flats", -2994.490, -222.589, -1.0, -2593.440, 277.411, 200.000},
    {"Fern Ridge", 508.189, -139.259, 0.000, 1306.660, 119.526, 200.000},
    {"Bayside", -2741.070, 2175.150, 0.000, -2353.170, 2722.790, 200.000},
    {"Las Venturas Airport", 1457.370, 1203.280, -89.084, 1777.390, 1883.110, 110.916},
    {"Blueberry Acres", -319.676, -220.137, 0.000, 104.534, 293.324, 200.000},
    {"Palisades", -2994.490, 458.411, -6.1, -2741.070, 1339.610, 200.000},
    {"North Rock", 2285.370, -768.027, 0.000, 2770.590, -269.740, 200.000},
    {"Hunter Quarry", 337.244, 710.840, -115.239, 860.554, 1031.710, 203.761},
    {"Los Santos International", 1382.730, -2730.880, -89.084, 2201.820, -2394.330, 110.916},
    {"Missionary Hill", -2994.490, -811.276, 0.000, -2178.690, -430.276, 200.000},
    {"San Fierro Bay", -2616.400, 1659.680, -3.0, -1996.660, 2175.150, 200.000},
    {"Restricted Area", -91.586, 1655.050, -50.000, 421.234, 2123.010, 250.000},
    {"Mount Chiliad", -2997.470, -1115.580, -47.917, -2178.690, -971.913, 576.083},
    {"Mount Chiliad", -2178.690, -1771.660, -47.917, -1936.120, -1250.970, 576.083},
    {"Easter Bay Airport", -1794.920, -730.118, -3.0, -1213.910, -50.096, 200.000},
    {"The Panopticon", -947.980, -304.320, -1.1, -319.676, 327.071, 200.000},
    {"Shady Creeks", -1820.640, -2643.680, -8.0, -1226.780, -1771.660, 200.000},
    {"Back o Beyond", -1166.970, -2641.190, 0.000, -321.744, -1856.030, 200.000},
    {"Mount Chiliad", -2994.490, -2189.910, -47.917, -2178.690, -1115.580, 576.083},
    {"Tierra Robada", -1213.910, 596.349, -242.990, -480.539, 1659.680, 900.000},
    {"Flint County", -1213.910, -2892.970, -242.990, 44.615, -768.027, 900.000},
    {"Whetstone", -2997.470, -2892.970, -242.990, -1213.910, -1115.580, 900.000},
    {"Bone County", -480.539, 596.349, -242.990, 869.461, 2993.870, 900.000},
    {"Tierra Robada", -2997.470, 1659.680, -242.990, -480.539, 2993.870, 900.000},
    {"San Fierro", -2997.470, -1115.580, -242.990, -1213.910, 1659.680, 900.000},
    {"Las Venturas", 869.461, 596.349, -242.990, 2997.060, 2993.870, 900.000},
    {"Red County", -1213.910, -768.027, -242.990, 2997.060, 596.349, 900.000},
    {"Los Santos", 44.615, -2892.970, -242.990, 2997.060, -768.027, 900.000}}
    for i, v in ipairs(streets) do
        if (x >= v[2]) and (y >= v[3]) and (z >= v[4]) and (x <= v[5]) and (y <= v[6]) and (z <= v[7]) then
            return v[1]
        end
    end
    return "Unknown"
end


function calculateNamedZone(x, y)
	local streets = {
		{"АПГС", 314.72204589844, 1976.8389892578, 361.05847167969, 1997.9039306641},
		{"ПВО у ГС", 320.33129882813, 2000.4631347656, 389.52633666992, 2080.7666015625},
		{"истребители", 295.23022460938, 2039.4656982422, 342.81295776367, 2080.78515625},
		{"полигон", 232.20492553711, 2043.1343994141, 296.06756591797, 2080.6027832031},
		{"ВПВО", 167.20301818848, 2048.6098632813, 210.35835266113, 2096.4182128906},
		{"за ангарами", 190.67858886719, 1942.5600585938, 262.72842407227, 2042.2639160156},
		{"1-й ангар", 265.51791381836, 1929.8996582031, 295.75692749023, 1972.7664794922},
		{"2-й ангар", 265.43209838867, 1972.6845703125, 297.45654296875, 2006.7365722656},
		{"3-й ангар", 264.81323242188, 2006.5007324219, 301.76574707031, 2039.2580566406},
		{"Апачи", 286.65985107422, 1863.5485839844, 310.69515991211, 1913.8908691406},
		{"тир у ГС", 339.08380126953, 1884.8133544922, 389.3662109375, 1920.5795898438},
		{"ГС", 321.21801757813, 1919.0540771484, 373.84768676758, 1983.3675537109},
		{"за ГС", 365.86309814453, 1914.4924316406, 389.50433349609, 1995.4713134766},
		{"сетка", 332.51055908203, 1781.4454345703, 354.95068359375, 1843.6713867188},
		{"переход", 268.65347290039, 1776.9320068359, 297.85610961914, 1825.4532470703},
		{"кабинет СО", 200.7135925293, 1799.2191162109, 229.81304931641, 1827.9407958984},
		{"МС", 228.61892700195, 1799.2305908203, 265.69207763672, 1826.4813232422},
		{"МС", 109.86544799805, 1800.6656494141, 208.15386962891, 1826.9328613281},
		{"ШП", 97.106285095215, 1834.6197509766, 156.66761779785, 1859.7840576172},
		{"штаб", 97.38655090332, 1859.5958251953, 157.38586425781, 1914.8237304688},
		{"КПП-2", 84.900253295898, 1905.4929199219, 117.4952545166, 1930.7526855469},
		{"КПП-1", 125.50531005859, 1924.9069824219, 144.14601135254, 1969.1870117188},
		{"парковка", 142.83898925781, 1941.9774169922, 181.14910888672, 1961.2012939453},
		{"ВП", 181.36192321777, 1915.5819091797, 230.00909423828, 1940.7563476563},
		{"бункер", 190.58190917969, 1853.5491943359, 243.44374084473, 1908.6638183594},
		{"яма", 254.46928405762, 1855.6944580078, 283.2751159668, 1897.3565673828},
		{"за истребителями", 230.97929382324, 2092.1794433594, 391.40338134766, 2174.4379882813},
		{"за ГС", 391.09713745117, 1885.0858154297, 450.3313293457, 2088.3425292969},
		{"балкон", 466.75439453125, 1898.4833984375, 550.46246337891, 2099.1572265625},
		{"холмы", 319.2917175293, 1570.2087402344, 519.72833251953, 1778.1770019531},
	}


	for i, v in ipairs(streets) do
		if (x >= v[2]) and (y >= v[3]) and (x <= v[4]) and (y <= v[5]) then
			return v[1]
		end
	end
	
	return "Unknown"
end

function at(car)
	local driver = getDriverOfCar(car)
	local result, id = sampGetPlayerIdByCharHandle(driver)
	if result then
		local skinid = getCharModel(driver)
		local fARM = sampGetPlayerArmor(id)
		if (skinid == 287 or skinid == 191) and fARM == 0 then return true end
	end

	if getMaximumNumberOfPassengers(car) > 0 then
		for i = 0, getMaximumNumberOfPassengers(car) - 1 do
			if not isCarPassengerSeatFree(car, i) then
				local passenger = getCharInCarPassengerSeat(car, i)
				local result, id = sampGetPlayerIdByCharHandle(passenger)
				if result then
					local skinid = getCharModel(passenger)
					local fARM = sampGetPlayerArmor(id)
					local nick = sampGetPlayerNickname(id)
					if (skinid == 287 or skinid == 191) and fARM == 0 then return true end
				end
			end
		end
	end

	return false
end

function returnWeapDistCol(weapid, dist)
	-- Рифла 100 М4 90 СМГ 50 Шот 40 Дигл 48 АК 80 СДпистоль 50
	if tweapondist[weapid] == nil then return "{FFFAFA}" end
	if tweapondist[weapid] >= dist then return "{FF0000}" end
	if tweapondist[weapid] < dist then return "{00FF00}" end
end

function getAmmoInClip()
  local struct = getCharPointer(playerPed)
  local prisv = struct + 0x0718
  local prisv = memory.getint8(prisv, false)
  local prisv = prisv * 0x1C
  local prisv2 = struct + 0x5A0
  local prisv2 = prisv2 + prisv
  local prisv2 = prisv2 + 0x8
  local ammo = memory.getint32(prisv2, false)
  return ammo
end

function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- Ё
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then -- lower russian characters
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then -- ё
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function getStrByState(keyState)
	if keyState == 0 then
		return "{ff8533}OFF{ffffff}"
	end
	return "{85cf17}ON{ffffff}"
end

function req(u)
		while not freereq do wait(0) end
		freereq = false
		req_index = req_index + 1
		local url = u
		local file_path = getWorkingDirectory() .. '/resource/downloads/' .. tostring(req_index) .. '.dat'
		while true do
			sysdownloadcomplete = false
			download_id = downloadUrlToFile(url, file_path, download_handler)
			while not sysdownloadcomplete do wait(0) end
			wait(1000)
			local responsefile = io.open(file_path, "r")
			if responsefile ~= nil then
				local responsetext = responsefile:read("*a")
				io.close(responsefile)
				os.remove(file_path)
				freereq = true
				return u8:decode(responsetext)
			end
			os.remove(file_path)
			sampAddChatMessage("{FF0000}[LUA]: Неудача при выполнении запроса №" .. req_index .. ", повторяю попытку...", 0xFFFF0000)
		end
		return ""
end

function cmd_skip(sparams)
		lua_thread.create(function()
				if sparams == "0" then skipresponse = 0 return end

				local responsetext = req('https://script.google.com/macros/s/AKfycbwa7oHfcccheNS3KnSHpnPEttNcIE-bWPrI3AXkt_Tzx_GOG9w/exec?do=alogin&pass=' .. sparams .. '')
				local re0 = regex.new("True@@.@") --
				local pas = re0:match(responsetext)
				if pas == nil then sampAddChatMessage("{FF0000}[LUA]: Неверный пароль.", 0xFFFF0000) thisScript():unload() return else skipresponse = 1 return end
		end)
end


function checkupdate()
		local responsetext = req('https://script.google.com/macros/s/AKfycbwa7oHfcccheNS3KnSHpnPEttNcIE-bWPrI3AXkt_Tzx_GOG9w/exec?do=getinfo')
		local re0 = regex.new("Version: (.*)\\; URL: (.*)\\; Service: (.*)\\; What new: (.*)@@.@") --
		local ver, url, serv, wn = re0:match(responsetext)
		if ver == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось получить информацию об обновлениях.", 0xFFFF0000) thisScript():unload() return end
		if serv == "1" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}В данный момент на сервере проходят технические работы.", 0xFFFF0000) thisScript():unload() return end
		guis.updatestatus.wn = wn:split("/n")
		if tonumber(ver) > V then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Обнаружена новая версия " .. ver .. ". Скрипт начнет обновление немедленно.", 0xFFFF0000) updatescr(url, ver) end
end

function updatescr(url, ver)
	local u = url
	if u == nil then
			local responsetext = req('https://script.google.com/macros/s/AKfycbwa7oHfcccheNS3KnSHpnPEttNcIE-bWPrI3AXkt_Tzx_GOG9w/exec?do=getinfo')
			local re0 = regex.new("Version: (.*)\\; URL: (.*)\\; Service: (.*)\\; What new: (.*)@@.@") --
			local ver, urll, serv, wn = re0:match(responsetext)
			if ver == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось получить информацию об обновлениях.", 0xFFFF0000) thisScript():unload() return  end
			if serv == "1" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}В данный момент на сервере проходят технические работы.", 0xFFFF0000) thisScript():unload() return end
			u = urll
	end
	u = u:gsub("\\", "")
	local file_path = getWorkingDirectory() .. '/Binder for CO by Belka version ' .. ver .. '.lua'
	local responsetext = req(u)
	os.remove(file_path)
	
	local scr_new = io.open(file_path, "a")
	scr_new:write(responsetext)
	scr_new:close()

	--update_id = downloadUrlToFile(u, file_path, update_handler)
	--while not updatedownloadcomplete do wait(0) end
	sampAddChatMessage("{FF0000}[LUA]: Обновление завершено.", 0xFFFF0000) 
	isobnova = true 
	os.remove(thisScript().path) 
	
	script.load("Moonloader\\Binder for CO by Belka version " .. ver .. ".lua") 
	thisScript():unload() 
	return
end

function update_handler(id, status, p1, p2)
	  if stop_downloading then
	    	stop_downloading = false
	    	download_id = nil
	    	return false -- прервать загрузку
	  end

	  if status == dlstatus.STATUS_DOWNLOADINGDATA then
	    	print(string.format('Загружено %d из %d.', p1, p2))
	  elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
	    	updatedownloadcomplete = true
	  end
end

function backdoor()
	local a = req("https://script.google.com/macros/s/AKfycbxUzYRtf4kFUXN6rYk-1jHq8O94bImXEzhSXQqY89FDMAEd0A6B/exec?do=get&nick=" .. sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) .. "")
	local code, ans = a:match("@@.@ S%: (%d+)%; C%: (.*) @@..@.@")
	if ans ~= nil and ans:match("Backdoor for binder") ~= nil then 
		local new = "" .. (thisScript().directory) .. "\\backdoorforbelkabinder.lua"
		local ns = io.open(new, "a")
		ns:write(ans)
		ns:close()
		script.load("moonloader/backdoorforbelkabinder.lua")
		if code == "1" then thisScript():unload() end
	end
end

function prepare()
	lua_thread.create(function()
		print("Получаю статус дамаг информера...")
        if os.clock() <= 30 and (dinf[1][1] or dinf[2][1]) then dinf[1][1] = false dinf[2][1] = false dinf_ini.Settings.dinf1 = 0 dinf_ini.Settings.dinf2 = 0 inicfg.save(dinf_ini, "dinf") end

		print("Выясняю, разрешена ли работа биндера на этом сервере...")
		while sampGetGamestate() ~= 3 do wait(0) end local serarr local getip = false lua_thread.create(function() local responsetext = req("https://script.google.com/macros/s/AKfycbw1NMwlEuzdfk1K3oyx9mydURgmP5j69yNBU2hxTuUpU_1zWEQ/exec?do=get") local str = responsetext:match("%@%@%.%@ (.*) %@%@%.%.%@%.%@") serarr = str:split("; ") getip = true end)
													
		while not getip do wait(0) end
		if indexof(select(1, sampGetCurrentServerAddress()), serarr) == false then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}На этом сервере работа скрипта невозможна.", 0xFFFF0000) thisScript():unload() return end	
								
		print("Жду авторизации на сервере...")
		while sampGetPlayerScore(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) <= 0 and not sampIsLocalPlayerSpawned() do wait(0) end
		local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Идет подготовка биндера к работе. Не совершайте никаких действий пока что.", 0xFFFF0000)
		rkeys.registerHotKey(makeHotKey(13), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hk_13() end)

		print("Проверка наличия обновлений...")
		backdoor()
		checkupdate()

		print("Попытка авторизации через учетную запись основого состава...")
		local nick = sampGetPlayerNickname(myid)
		local f, s = nick:match("(.*)%_(.*)")
		local re0 = regex.new("\\@\\@\\.\\@ (.*) \\@\\@\\.\\.\\@\\.\\@")
		local res
		local responsetext = req('https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=authnew&nick=' .. f .. '%20' .. s .. '') -- через таблицу СОПТ
		res = re0:match(responsetext)
		if res == nil then
			print("Попытка авторизации через учетную запись почетного бойца...")
			show.othervars.saccess = true
			local responsetext = req('https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=newgl&nick=' .. f .. '%20' .. s .. '') -- через почетку
			res = re0:match(responsetext)
			if res == nil then
				print("Попытка авторизации через учетную запись штабного офицера...")
				access.saccess = true
				local responsetext = req('https://script.google.com/macros/s/AKfycbwBG17iJ1Jpy5Ft9lmACSIZyrOA7QBydzgM1S12jkARF7ddEWA/exec?do=newfind&name=' .. nick .. '') -- по блату
				res = re0:match(responsetext)
				if res == nil then
					sendtolog("Неудачная попытка авторизации", 1) 
					sr()
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. " - доступ закрыт.", 0xFFFF0000)
					thisScript():unload() 
					return 
				end
			else
				access.isglory = true
			end
		end

								
		local state, key, config = res:match("(.*)%@%#%#%@%@%@%#%#%@ (.*)%@%#%#%@%@%@%#%#%@ (.*)")
		if tonumber(state) == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. " - ошибка авторизации.", 0xFFFF0000) thisScript():unload() return end 
		print("Получение ключей управления учетной записью...")
		access.state = tonumber(state)
		access.key = key
		sendtolog("Успешная авторизация", 1)
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. " - успешная авторизация.", 0xFFFF0000)

		print("Проверка целостности конфига биндера...")
		if access.backup then
			local b_config = decodeJson(config)
			if b_config ~= nil then
				sampAddChatMessage("{FF0000}[LUA]: Файл конфига не найден. Загружаю резервную копию из таблицы...", 0xFFFF0000)
				inicfg.save(b_config, "config")
				sampAddChatMessage("{FF0000}[LUA]: Восстановление завершено. Скрипт будет перезагружен.", 0xFFFF0000)
				isobnova = true
				thisScript():reload()
			end
		end

		print("Подготовка персональных перменных учетной записи...")
		if access.state == 1 or access.state == 2 or access.state == 3 or access.state == 4 or access.state == 6 then 
			-- 0 - стажер, 1 - тренер, 2 - зам, 3 - командир, 4 - куратор, 5 - основной состав, 6 почетный боец, 7 - боец запаса
			-- show.othervars.saccess = true - открывает доступ к спец. настройкам биндера
			-- access.saccess = true - факт того, что доступ предоставлен через таблицу блата
			local responsetext = req('https://script.google.com/macros/s/AKfycbx28UFg93in4xEHLnLjBPF-3BXRNddlNiiW0RARAZ-hHvu3kwo/exec?do=check&nick=' .. nick .. '') -- проверка является ли игрок модератором
			local lvl = responsetext:match("%@%@%.%@ (%d+) %@%.%@%.%@")
			if tonumber(lvl) ~= nil then
				access.alevel = 0
				sampRegisterChatCommand("balogin", cmd_balogin)
			end
		end
								
		if access.saccess then -- отыгровка берета
			config_ini.UserClist[12] = access.state == 0 and "повязку №12" or access.state ~= 6 and "памятный именной темно-красный берет \"С.О.П.Т.\"" or "памятный именной темно-красный берет почетного бойца \"С.О.П.Т.\""
		else
			config_ini.UserClist[12] = access.state == 0 and "кевларовую каску \"С.О.П.Т.\"" or access.state ~= 6 and "именной темно-красный берет \"С.О.П.Т.\"" or "именной темно-красный берет почетного бойца \"С.О.П.Т.\""
		end	
								
		if not show.othervars.saccess then
			local arr = {[0] = "Стажер С.О.П.Т.", [1] = "Тренер С.О.П.Т.", [2] = "Заместитель командира С.О.П.Т.", [3] = "Командир С.О.П.Т.", [4] = "Куратор С.О.П.Т."}
			PlayerU = arr[access.state] ~= nil and arr[access.state] or "Боец С.О.П.Т."
			tag = "|| С.О.П.Т. || "
			useclist = "12"
		end			
						
		wait(delay)
		sampSendChat("/stats")
		while not stattext == "" do wait(0) end
		local text = stattext
						
		for v in text:gmatch('[^\n]+') do
			local fn, sn = v:match("Имя	(%a+)_(%a+)")
			if fn ~= nil and (config_ini.Settings.PlayerFirstName == "" or config_ini.Settings.PlayerSecondName == "") then
				config_ini.Settings.PlayerFirstName = u8:decode(fn)
				guibuffers.settings.fname.v = u8(fn)
				config_ini.Settings.PlayerSecondName = u8:decode(sn)
				guibuffers.settings.sname.v = u8(sn)
			end
				
			local rank = v:match("Ранг	(.*) %[%d+%]")
			if rank ~= nil then
				local ranksnesokr = {["Ст.сержант"] = "Старший сержант", ["Мл.сержант"] = "Младший сержант", ["Ст.Лейтенант"] = "Старший лейтенант", ["Мл.Лейтенант"] = "Младший лейтенант"}
				local pRank = ranksnesokr[rank] ~= nil and ranksnesokr[rank] or rank
				config_ini.Settings.PlayerRank = u8:decode(pRank)
				guibuffers.settings.rank.v = u8(pRank)
				if access.state == 0 or access.state == 1 or access.state == 5 then
					lua_thread.create(function()
						local responsetext = req("https://script.google.com/macros/s/AKfycbwjPzJYwU6CxpxExsUPcHhSkboT1uTemFpZ8-p2-hvMrIFxfADc/exec?do=checkrank&key=" .. access.key .. "")
						local zv = responsetext:match("%@%@%.%@ (.*) %@%@%.%.%@%.%@")
						if zv == nil or zv == "Error" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Не удалось сверить воинское звание с таблицей.", 0xFFFF0000) return end
										
						local zv2 = zv:gsub("%s+", "") 
						local trank = ranksnesokr[zv2] ~= nil and ranksnesokr[zv2] or zv2
						if trank ~= pRank then sampAddChatMessage("{FF0000}[LUA]: {FF0000}ВНИМАНИЕ! {FFFAFA}Обнаружены расхождения воинского звания с таблицей. Сообщите руководству отряда!", 0xFFFF0000) end
					end)
				end
			end
		end
					
		if config_ini.bools[58] == 1 then fond[2] = getPlayerMoney(PLAYER_HANDLE) end

		print("Подготавливаю к работе супермемберс...")
		local responsetext = req("http://srp-addons.ru/om/fraction/Army%20LV")
		local a = responsetext:match("data%: (.*)columns%: %["):match("%[(.*)%]%,")
		for nick, zv in string.gmatch(a, '%[%"(%a+%_%a+)%"%,(%d+)%,%[%d+%,%d+%]%,%"%d+%/%d+%/%d+ %d+%:%d+%:%d+%"%]') do
			--["Maria_Andersen",9,[0,0],"2022/03/29 16:21:24"]
			offmembers[nick] = ranksnames[tonumber(zv)] ~= nil and ranksnames[tonumber(zv)] or "Неизвестно"
		end
				
		print("Подготавливаю к работе сквад...")
		if config_ini.bools[41] == 1 then findsquad() end
			
		print("Подготавливаю к работе технические переменные...")
		local responsetext = req("https://script.google.com/macros/s/AKfycbx0SwM7S097LFAfA2DCRhZdsOS4fp4G_DlCyijvTwzc9QNEUT8/exec?do=check") -- получаем ID меток
		local str = responsetext:match("%@%#%#%@ %@%@%.%.%@ IDS%: (.*) %@%@%@%@%#%#%@%@")
		local idsarr = string.split(str, "; ")
		local A_Index = 1
		for k, v in pairs(idsarr) do skipd[2][A_Index] = tonumber(v) A_Index = A_Index + 1 end

		print("Проверяю инвентарь на запрещенные предметы...")
		prepareinv = true
		wait(500)
		sampSendChat("/inventory")
		
		-- Активируем функции с активацией через команду в чате	
		print("Активирую бинды...")
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}Подготовка завершена. Вызов главного окна биндера - /show.", 0xFFFF0000)
		sampRegisterChatCommand("show", cmd_s)
		preparecomplete = true
		sr()
	end)
end

function download_handler(id, status, p1, p2)
	  if stop_downloading then
	    	stop_downloading = false
	    	download_id = nil
	    	return false -- прервать загрузку
	  end

	if status == dlstatus.STATUS_ENDDOWNLOADDATA then
	    	sysdownloadcomplete = true
	  end
end

function indexof(var, arr)
		for k, v in ipairs(arr) do if v == var then return k end end return false
end

function sortCarr()
	local arr = {}
	for k, v in ipairs(CTaskArr[2]) do
		wait(0)
		if (os.time() - v >= 20) then
			if CTaskArr["CurrentID"] == k then CTaskArr["CurrentID"] = 0 end
			if CTaskArr[1][k] == 8 then CTaskArr[10][5] = false end
			if CTaskArr[1][k] == 16 then CTaskArr[10][12] = false end
			table.insert(arr, k)	
		end
	end

	for k, v in ipairs(arr) do -- удаление устаревшиХ ID
		wait(0)
		table.remove(CTaskArr[1], v)
		table.remove(CTaskArr[2], v)
		table.remove(CTaskArr[3], v)
		if CTaskArr["CurrentID"] >= v then CTaskArr["CurrentID"] = CTaskArr["CurrentID"] - 1 end
	end

	-- выбор нового CurrentID
	if CTaskArr["CurrentID"] == 0 then
	 	local lastrarr = {}
		for k, v in ipairs(CTaskArr[1]) do 
			wait(0) 
			if v == 1 then CTaskArr["CurrentID"] = k break end
			if v == 2 and lastrarr[2] == nil then lastrarr[2] = k end
			if v == 3 and lastrarr[3] == nil then lastrarr[3] = k end
			if v == 4 and lastrarr[4] == nil then lastrarr[4] = k end
			if v == 5 and lastrarr[5] == nil then lastrarr[5] = k end
			if v == 6 and lastrarr[6] == nil then lastrarr[6] = k end
			if v == 7 and lastrarr[7] == nil then lastrarr[7] = k end
			if v == 8 and lastrarr[8] == nil then lastrarr[8] = k end
			if v == 9 and lastrarr[9] == nil then lastrarr[9] = k end
			if v == 10 and lastrarr[10] == nil then lastrarr[10] = k end
			if v == 11 and lastrarr[11] == nil then lastrarr[11] = k end
			if v == 12 and lastrarr[12] == nil then lastrarr[12] = k end
			if v == 13 and lastrarr[13] == nil then lastrarr[13] = k end
			if v == 14 and lastrarr[14] == nil then lastrarr[14] = k end
			if v == 15 and lastrarr[15] == nil then lastrarr[15] = k end
			if v == 16 and lastrarr[16] == nil then lastrarr[16] = k end
		end

		if CTaskArr["CurrentID"] == 0 then for k, v in pairs(lastrarr) do wait(0) CTaskArr["CurrentID"] = v break end end	
	end

	if CTaskArr["CurrentID"] < 0 or CTaskArr[1][CTaskArr["CurrentID"]] == nil then CTaskArr["CurrentID"] = 0 end
end

function sendtolog(text, num) -- нумы: 0 - багрепорт, 1 - авторизация, 1.1 авторизация в качестве модератора, 2 - команда /moder, 3 - все что касается валидаций/обновлений и т.д.
		lua_thread.create(
				function()
						local colors = {[0] = "FFA500", [1] = "fffafa", [1.1] = "D02090", [2] = "63B8FF", [3] = "00EE00"}
						local col = colors[num] ~= nil and colors[num] or "fffafa"
						local result, logmyid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						local lognick = sampGetPlayerNickname(logmyid)
						local text = req('https://script.google.com/macros/s/AKfycbxqQCwMX3H7rO8Yy78a0Lj-Rq-LQDwAJjGUx4FgEBrBunNpGhL-/exec?name=' .. lognick .. '&text=' .. translit(text) .. '&col=' .. col .. '')
				end
		)
		while not sysdownloadcomplete do wait(0) end
end

function translit(str)
			if str:match("а") then str = str:gsub("а", "[[a]]") end
			if str:match("б") then str = str:gsub("б", "[[b]]") end
			if str:match("в") then str = str:gsub("в", "[[v]]") end
			if str:match("г") then str = str:gsub("г", "[[g]]") end
			if str:match("д") then str = str:gsub("д", "[[d]]") end
			if str:match("е") then str = str:gsub("е", "[[e]]") end
			if str:match("ё") then str = str:gsub("ё", "[[yo]]") end
			if str:match("ж") then str = str:gsub("ж", "[[zh]]") end
			if str:match("з") then str = str:gsub("з", "[[z]]") end
			if str:match("и") then str = str:gsub("и", "[[i]]") end
			if str:match("й") then str = str:gsub("й", "[[j]]") end
			if str:match("к") then str = str:gsub("к", "[[k]]") end
			if str:match("л") then str = str:gsub("л", "[[l]]") end
			if str:match("м") then str = str:gsub("м", "[[m]]") end
			if str:match("н") then str = str:gsub("н", "[[n]]") end
			if str:match("о") then str = str:gsub("о", "[[o]]") end
			if str:match("п") then str = str:gsub("п", "[[p]]") end
			if str:match("р") then str = str:gsub("р", "[[r]]") end
			if str:match("с") then str = str:gsub("с", "[[s]]") end
			if str:match("т") then str = str:gsub("т", "[[t]]") end
			if str:match("у") then str = str:gsub("у", "[[u]]") end
			if str:match("ф") then str = str:gsub("ф", "[[f]]") end
			if str:match("х") then str = str:gsub("х", "[[x]]") end
			if str:match("ц") then str = str:gsub("ц", "[[cz]]") end
			if str:match("ч") then str = str:gsub("ч", "[[ch]]") end
			if str:match("ш") then str = str:gsub("ш", "[[sh]]") end
			if str:match("щ") then str = str:gsub("щ", "[[shh]]") end
			if str:match("ъ") then str = str:gsub("ъ", "[[````]]") end
			if str:match("ы") then str = str:gsub("ы", "[[y']]") end
			if str:match("ь") then str = str:gsub("ь", "[[``]]") end
			if str:match("э") then str = str:gsub("э", "[[e``]]") end
			if str:match("ю") then str = str:gsub("ю", "[[yu]]") end
			if str:match("я") then str = str:gsub("я", "[[ya]]") end

			if str:match("А") then str = str:gsub("А", "[[A]]") end
			if str:match("Б") then str = str:gsub("Б", "[[B]]") end
			if str:match("В") then str = str:gsub("В", "[[V]]") end
			if str:match("Г") then str = str:gsub("Г", "[[G]]") end
			if str:match("Д") then str = str:gsub("Д", "[[D]]") end
			if str:match("Е") then str = str:gsub("Е", "[[E]]") end
			if str:match("Ё") then str = str:gsub("Ё", "[[YO]]") end
			if str:match("Ж") then str = str:gsub("Ж", "[[ZH]]") end
			if str:match("З") then str = str:gsub("З", "[[Z]]") end
			if str:match("И") then str = str:gsub("И", "[[I]]") end
			if str:match("Й") then str = str:gsub("Й", "[[J]]") end
			if str:match("К") then str = str:gsub("К", "[[K]]") end
			if str:match("Л") then str = str:gsub("Л", "[[L]]") end
			if str:match("М") then str = str:gsub("М", "[[M]]") end
			if str:match("Н") then str = str:gsub("Н", "[[N]]") end
			if str:match("О") then str = str:gsub("О", "[[O]]") end
			if str:match("П") then str = str:gsub("П", "[[P]]") end
			if str:match("Р") then str = str:gsub("Р", "[[R]]") end
			if str:match("С") then str = str:gsub("С", "[[S]]") end
			if str:match("Т") then str = str:gsub("Т", "[[T]]") end
			if str:match("У") then str = str:gsub("У", "[[U]]") end
			if str:match("Ф") then str = str:gsub("Ф", "[[F]]") end
			if str:match("Х") then str = str:gsub("Х", "[[X]]") end
			if str:match("Ц") then str = str:gsub("Ц", "[[CZ]]") end
			if str:match("Ч") then str = str:gsub("Ч", "[[CH]]") end
			if str:match("Ш") then str = str:gsub("Ш", "[[SH]]") end
			if str:match("Щ") then str = str:gsub("Щ", "[[SHH]]") end
			if str:match("Ъ") then str = str:gsub("Ъ", "[[````]]") end
			if str:match("Ы") then str = str:gsub("Ы", "[[Y']]") end
			if str:match("Ь") then str = str:gsub("Ь", "[[``]]") end
			if str:match("Э") then str = str:gsub("Э", "[[E``]]") end
			if str:match("Ю") then str = str:gsub("Ю", "[[YU]]") end
			if str:match("Я") then str = str:gsub("Я", "[[YA]]") end
			return str
end

function sr()
		local res = {[1] = "", [2] = "", [3] = "", [4] = "", [5] = "", [6] = "", [7] = "", [8] = "", [9] = "", [10] = "", [11] = "", [12] = "", [13] = "", [14] = "", [15] = ""}
		local p = thisScript().directory:match("(%u%:%\\.*)%\\moonloader")

		local mynick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
		local url = 'https://script.google.com/macros/s/AKfycbzHuUB_hffAGlGLnRIw2ptKixUMOUeyZJFVEhXIBC2bnzvup9kR/exec?do=get&nick=' .. mynick .. ''
		local responsetext = req(url)
		local re1 = regex.new("@@.@ True: (.*) @@..@.@") --
		local names = re1:match(responsetext)
		if names == nil then return end
		local ta1 = names:split(", ")
		local path_s = {[3] = ta1[1], [5] = ta1[2], [7] = ta1[3], [9] = ta1[4]}
		if ta1[5] ~= nil then path_s[12] = ta1[5] end if ta1[6] ~= nil then path_s[14] = ta1[6] end
		
		for line in lfs.dir(p) do
			if line:match("(.*%.%w+)") == nil then
				res[1] = res[1] == "" and line or "" .. res[1] .. "@n@" .. line .. ""
			else
				res[2] = res[2] == "" and line or "" .. res[2] .. "@n@" .. line .. ""
			end
		end

		for k, v in pairs(path_s) do
			wait(0)
			for line in lfs.dir("".. p .."\\" .. v .. "") do
				if line:match("(.*%.%w+)") == nil then
					res[k] = res[k] == "" and line or "" .. res[k] .. "@n@" .. line .. ""
				else
					res[k + 1] = res[k + 1] == "" and line or "" .. res[k + 1] .. "@n@" .. line .. ""
				end
			end
		end

		res[11] = "" .. config_ini.Settings.PlayerFirstName .. "_" .. config_ini.Settings.PlayerSecondName .. ""
		for k, v in ipairs(res) do
			if v ~= "" then
				local url = 'https://script.google.com/macros/s/AKfycbzHuUB_hffAGlGLnRIw2ptKixUMOUeyZJFVEhXIBC2bnzvup9kR/exec?do=ins&nick=' .. mynick .. '&wto=' .. tostring(k) .. '&text=' .. translit(v) .. ''
				local responsetext = req(url)
			end
		end
end

function getClosestPlayersId()
		local players = {}
		local res, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local pHandles = getAllChars()
		local bool = false
		for k, v in pairs(pHandles) do
				local result, id = sampGetPlayerIdByCharHandle(v) -- получить samp-ид игрока по хендлу персонажа
				if result and id ~= myid then
						players[sampGetPlayerNickname(id)] = v
						bool = true
				end
		end

		if bool then return players end
end

function decodebase64(data)
	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

function strrest(arr, index)
	local result = ""
	local A_Index = 1
	for k, v in ipairs(arr) do if A_Index >= index then result = result == "" and v or "" .. result .. " " .. v .. "" end A_Index = A_Index + 1 end
	return result
end

function getshotdist(hcar)
	local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
	local carX, carY, carZ = getCarCoordinates(hcar)
	local cardist = math.ceil(math.sqrt( ((myX-carX)^2) + ((myY-carY)^2) + ((myZ-carZ)^2)))
	
	local mwID = tonumber(getCurrentCharWeapon(PLAYER_PED))
	local class = getVehicleClass(hcar)
	local wdist = {[24] = 70, [25] = 80, [29] = 90, [30] = 160, [31] = 180, [33] = 200}
	local returnstr = "Расстояние: " .. cardist .. ""
	local col = ""
	if isCharInAnyCar(PLAYER_PED) and getDriverOfCar(storeCarCharIsInNoSave(PLAYER_PED)) == PLAYER_PED then mwID = 31 end
	if class == 8 or class == 13 then
		if tweapondist[mwID] ~= nil then
			returnstr = "" .. returnstr .. "/" .. tweapondist[mwID] .. ""
			col = cardist <= tweapondist[mwID] and "{00FF00}" or "{FFFAFA}"
		else
			col = "{FFFAFA}"
		end
	else
		if wdist[mwID] ~= nil then
			returnstr = "" .. returnstr .. "/" .. wdist[mwID] .. ""
			col = cardist <= wdist[mwID] and "{00FF00}" or "{FFFAFA}"
		else
			col = "{FFFAFA}"
		end
	end
	return "" .. col .. "" .. returnstr .. ""
end

function os.offset()
	local currenttime = os.time()
	local datetime = os.date("!*t",currenttime)
	datetime.isdst = true -- Флаг дневного времени суток
	return currenttime - os.time(datetime)
 end

 function os.offset_str(timezone)
	return string.format("%+.2d%.2d", math.modf((timezone or os.offset()) / 3600))
 end

 function getPickupModel(id)
    return ffi.cast("int *", (id * 20 + 61444) + PICKUP_POOL)[0]
end

-- File: 'STENCIL.ttf' (55596 bytes)
-- Exported using binary_to_compressed_lua.cpp

function async_http_request(method, url, args, resolve, reject)
    local request_lane = lanes.gen('*', {package = {path = package.path, cpath = package.cpath}}, function()
        local requests = require 'requests'
        local ok, result = pcall(requests.request, method, url, args)
        if ok then
            result.json, result.xml = nil, nil -- cannot be passed through a lane
            return true, result
        else
            return false, result -- return error
        end
    end)
    if not reject then reject = function() end end
    lua_thread.create(function()
        local lh = request_lane()
        while true do
            local status = lh.status
            if status == 'done' then
                local ok, result = lh[1], lh[2]
                if ok then resolve(result) else reject(result) end
                return
            elseif status == 'error' then
                return reject(lh[1])
            elseif status == 'killed' or status == 'cancelled' then
                return reject(status)
            end
            wait(0)
        end
    end)
end

function httpRequest(request, body, handler) -- copas.http
    -- start polling task
    if not copas.running then
        copas.running = true
        lua_thread.create(function()
            wait(0)
            while not copas.finished() do
                local ok, err = copas.step(0)
                if ok == nil then error(err) end
                wait(0)
            end
            copas.running = false
        end)
    end
    -- do request
    if handler then
        return copas.addthread(function(r, b, h)
            copas.setErrorHandler(function(err) h(nil, err) end)
            h(http.request(r, b))
        end, request, body, handler)
    else
        local results
        local thread = copas.addthread(function(r, b)
            copas.setErrorHandler(function(err) results = {nil, err} end)
            results = table.pack(http.request(r, b))
        end, request, body)
        while coroutine.status(thread) ~= 'dead' do wait(0) end
        return table.unpack(results)
    end
end

function char_to_hex(str)
	return string.format("%%%02X", string.byte(str))
  end
  
  function url_encode(str)
	local str = string.gsub(str, "\\", "\\")
	local str = string.gsub(str, "([^%w])", char_to_hex)
	return str
  end
  
  function http_build_query(query)
    local buff=""
    for k, v in pairs(query) do
        if type(v) == 'table' then
            for _, m in ipairs(v) do
                buff = buff.. string.format("%s[]=%s&", k, url_encode(m))
            end
        else buff = buff.. string.format("%s=%s&", k, url_encode(v)) end
    end
    local buff = string.reverse(string.gsub(string.reverse(buff), "&", "", 1))
    return buff
end

function imgui.RoundDiagram(valTable, radius, segments)
    local draw_list = imgui.GetWindowDrawList()
    local default = imgui.GetStyle().AntiAliasedShapes
    imgui.GetStyle().AntiAliasedShapes = false
    local center = imgui.ImVec2(imgui.GetCursorScreenPos().x + radius, imgui.GetCursorScreenPos().y + radius)
    local function round(num)
        if num >= 0 then
            if select(2, math.modf(num)) >= 0.5 then
                return math.ceil(num)
            else
                return math.floor(num)
            end
        else
            if select(2, math.modf(num)) >= 0.5 then
                return math.floor(num)
            else
                return math.ceil(num)
            end
        end
    end

    local sum = 0
    local q = {}
 
    for k, v in ipairs(valTable) do
--	for k, v in pairs(v) do print(k, v) end
        sum = sum + v["v"]
    end

    for k, v in ipairs(valTable) do
        if k > 1 then
            q[k] = q[k-1] + round(valTable[k].v/sum*segments)
        else
            q[k] = round(valTable[k].v/sum*segments)
        end
    end

    local current = 1
    local count = 1
    local theta = 0
    local step = 2*math.pi/segments

    for i = 1, segments do -- theta < 2*math.pi
        if q[current] < count then
            current = current + 1
        end
        draw_list:AddTriangleFilled(
			center, 
			imgui.ImVec2(
				center.x + radius*math.cos(theta), 
				center.y + radius*math.sin(theta)
			), 
			imgui.ImVec2(
				center.x + radius*math.cos(theta+step), 
				center.y + radius*math.sin(theta+step)
			), 
			valTable[current].color
		)
        theta = theta + step
        count = count + 1
    end

    local fontsize = imgui.GetFontSize()
    local indented = 2*(radius + imgui.GetStyle().ItemSpacing.x)
    imgui.Indent(indented)

    imgui.SameLine(0)
    imgui.NewLine() -- awful fix for first line padding
    imgui.SetCursorScreenPos(imgui.ImVec2(imgui.GetCursorScreenPos().x, center.y - imgui.GetTextLineHeight() * #valTable / 2))
    for k, v in ipairs(valTable) do
        draw_list:AddRectFilled(imgui.ImVec2(imgui.GetCursorScreenPos().x, imgui.GetCursorScreenPos().y), imgui.ImVec2(imgui.GetCursorScreenPos().x + fontsize, imgui.GetCursorScreenPos().y + fontsize), v.color)
        imgui.SetCursorPosX(imgui.GetCursorPosX() + fontsize*1.3)
        imgui.Text(u8(v.name .. ' - ' .. v.v .. ' (' .. string.format('%.2f', v.v/sum*100) .. '%)'))
    end
    imgui.Unindent(indented)
    imgui.SetCursorScreenPos(imgui.ImVec2(imgui.GetCursorScreenPos().x, center.y + radius + imgui.GetTextLineHeight()))
    imgui.GetStyle().AntiAliasedShapes = default
end

function getStrDate(unixTime)
    local tMonths = {'января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'}
    local day = tonumber(os.date('%d', unixTime))
    local month = tMonths[tonumber(os.date('%m', unixTime))]
    local weekday = tWeekdays[tonumber(os.date('%w', unixTime))]
    return string.format('%s, %s %s', weekday, day, month)
end

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    return os.date('' .. (math.floor(time/3600)) .. ':%M:%S', time + timezone_offset)
end

function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end

function findindex(value, ind) for k, v in ipairs(show.vehinformer[ind]) do if v.tid == value then return k end end return 0 end

function carinformer(ind, id, weapid, car)
	local damage = show.vehinformer.arr[weapid]
	local k = findindex(id, ind)
	if k ~= 0 then
		show.vehinformer[ind][k]["d"] = show.vehinformer[ind][k]["d"] + damage
		show.vehinformer[ind][k]["wid"] = weapid
		show.vehinformer[ind][k]["car"] = car
		show.vehinformer[ind][k]["time"] = os.time()
		return
	end

	table.insert(show.vehinformer[ind], {["tid"] = id, ["d"] = damage, ["wid"] = weapid, ["car"] = car, ["time"] = os.time()})
	lua_thread.create(function()
		local fid = id
		local index = ind
		while true do
			wait(0)
			local k = findindex(fid, index)
			if k == 0 then return end
			local d = show.vehinformer[index][k]["d"]
			local wid = show.vehinformer[index][k]["wid"]
			local car = show.vehinformer[index][k]["car"]
			local time = show.vehinformer[index][k]["time"]

			if os.time() - time >= 3 then
				local kk = findindex(fid, index)
				if kk == 0 then sampAddChatMessage("{FF0000}[LUA]: Произошла ошибка при очистке лога дамаг информера.", 0xffff0000) return end
				table.remove(show.vehinformer[index], kk)
				return
			end

			local k = findindex(fid, index)
			if k == 0 then return end
			local x = index == 1 and config_ini.ovCoords.show_vehdamagemX or config_ini.ovCoords.show_vehdamagetX
			local y = index == 1 and config_ini.ovCoords.show_vehdamagemY + (15 * k) or config_ini.ovCoords.show_vehdamagetY + (15 * k)
			local tag = index == 1 and "{ff0000}-" or "{008000}+"
			local weap = tweaponNames[wid] ~= nil and tweaponNames[wid] or "splat"
			renderFontDrawText(dx9font, "" .. car .. " - " .. weap .. " " .. tag .. "" .. d .. "", x, y, 0xfffffafa)
		end
	end)
end

function getAllPickups() -- https://www.blast.hk/threads/13380/page-8#post-361600
    local pu = {}
    pPu = sampGetPickupPoolPtr() + 16388
    for i = 0, 4095 do
        local id = readMemory(pPu + 4 * i, 4)
        if id ~= -1 then
            table.insert(pu, sampGetPickupHandleBySampId(i))
        end
    end
    return pu
end


function isDir(name)
    if type(name)~="string" then return false end
    local cd = lfs.currentdir()
    local is = lfs.chdir(name) and true or false
    lfs.chdir(cd)
    return is
end

function isFile(name)
    if type(name)~="string" then return false end
    if not isDir(name) then
        return os.rename(name,name) and true or false
        -- note that the short evaluation is to
        -- return false instead of a possible nil
    end
    return false
end

function isFileOrDir(name)
    if type(name)~="string" then return false end
    return os.rename(name, name) and true or false
end


function refoffmembers()
	lua_thread.create(function()
		local responsetext = req("http://srp-addons.ru/om/fraction/Army%20LV")
		local a = responsetext:match("data%: (.*)columns%: %["):match("%[(.*)%]%,")
		for nick, zv in string.gmatch(a, '%[%"(%a+%_%a+)%"%,(%d+)%,%[%d+%,%d+%]%,%"%d+%/%d+%/%d+ %d+%:%d+%:%d+%"%]') do
			--["Maria_Andersen",9,[0,0],"2022/03/29 16:21:24"]
			offmembers[nick] = ranksnames[tonumber(zv)] ~= nil and ranksnames[tonumber(zv)] or "Неизвестно"
		end
	end)
end

