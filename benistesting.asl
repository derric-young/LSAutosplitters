state("BasicsInFilmmaking-Win64-Shipping")
{
///	byte sus : "BasicsInFilmmaking-Win64-Shipping.exe", 0x6C13DB8, 0x170, 0x8, 0x10;
///	byte aaa : "BasicsInFilmmaking-Win64-Shipping.exe", 0x6C13DB8, 0x170, 0x8, 0x12;
///	byte aaa : "BasicsInFilmmaking-Win64-Shipping.exe", 0x6C13DB8, 0x170, 0x8;
}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    vars.Helper.AlertLoadless();
}

init
{
    vars.Helper.GameName = "Basics In Intermediate Filmmaking";
	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 05 ???????? 48 3B C? 48 0F 44 C? 48 89 05 ???????? E8");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 89 05 ???????? 48 85 c9 74 ?? e8 ???????? 48 8d 4d");
	IntPtr fNames = vars.Helper.ScanRel(3, "48 8d 0d ?? ?? ?? ?? e8 ?? ?? ?? ?? c6 05 ?? ?? ?? ?? ?? 0f 10 07");

    //GWorld.???.???.Begin_Player_C
    vars.Helper["???"] = vars.Helper.Make<bool>(gEngine, 0x1058, 0x38, 0x0, 0x30, 0x348, 0x12D0);

    if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
    {
        const string Msg = "Not all required addresses could be found by scanning.";
        throw new Exception(Msg);
    }

    vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x30, 0xE8, 0x2A8);
    vars.Helper["sus"] = vars.Helper.Make<ulong>(gWorld, 0x170, 0x8, 0x10);
    vars.Helper["aaa"] = vars.Helper.Make<ulong>(gWorld, 0x170, 0x8);

	vars.FNameToString = (Func<ulong, string>)(fName =>
	{
	var nameIdx  = (fName & 0x000000000000FFFF) >> 0x00;
	var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
	var number   = (fName & 0xFFFFFFFF00000000) >> 0x20;

	IntPtr chunk = vars.Helper.Read<IntPtr>(fNames + 0x10 + (int)chunkIdx * 0x8);
	IntPtr entry = chunk + (int)nameIdx * sizeof(short);

	int length = vars.Helper.Read<short>(entry) >> 6;
	string name = vars.Helper.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));
	return number == 0 ? name : name + "_" + number;
});
}

update
{
    vars.Helper.Update();
    vars.Helper.MapPointers();
    vars.level = vars.FNameToString(current.GWorldName);
//    if (!string.IsNullOrEmpty(world) && vers.level != "None") vars.level = vars.level;
//    if (vars.level != current.World) vars.Log("World: " + current.World);
//    print(vars.level);
    print(current.sus.ToString());
}

start
{
	if (vars.level == "Start" && current.aaa != old.aaa)
		return true;
}

reset
{
	if (vars.level == "MainMenu" || vars.level == "IntroVideo")
		return true;
}

split
{
//	Level 2 Split	
    if (vars.level == "Level2" ||
//	Level 3 Split
	vars.level == "Level2_B_" ||
//	Level 4 Split
	vars.level == "Level2_C" ||
//	Level 5 Split
	vars.level == "Level3" ||
//	Level 6 Split
	vars.level == "Level4" ||
//	Level 7 Split
	vars.level == "Level5" ||
//	Level 8 Split
	vars.level == "Level6_1" ||
//	Level 9 Split
	vars.level == "Level7_1" ||
//	Level 8 (FIXED) Split
	vars.level == "Level6_2" ||
//	Level 9 (FIXED) Split
	vars.level == "Level7_2" ||
//	Level 10 Split
	vars.level == "Level8" ||
//	Level 11 Split
	vars.level == "Level9" ||
//	Level 12 Split
	vars.level == "Level10" ||
//	Level 13 Split
	vars.level == "LevelEND" ||
//	Ending Split
	vars.level == "Start")
	if (current.aaa != old.aaa)
		return true;
}

isLoading
{	
	if (current.sus == 3003296979008 || current.sus == 2678491060288)
		return false;
	else
		return true;
}
