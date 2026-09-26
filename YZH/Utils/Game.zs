class YZH_Game
{
    static ui String GetGameTitle()
    {
        String title;
        String gameInfoLump = YZH_Lumps.ReadLump("GAMEINFO");
        int index = gameInfoLump.IndexOf("STARTUPTITLE");
        if (index != -1)
        {
            for (int i = index + 14; i < gameInfoLump.Length(); i++)
            {
                int byte = gameInfoLump.ByteAt(i);
                if (byte < 32)
                    break;

                title.AppendCharacter(byte);
            }

            title.StripLeftRight(" ");
            title.StripLeftRight("\"");
        }

        return title;
    }
}