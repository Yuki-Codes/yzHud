class YZH_Lumps
{
    static ui String ReadLump(String name)
    {
        int lumpId = GetLumpId(name);
        if (lumpId == -1)
            return "";

        return Wads.ReadLump(lumpId);
    }

    static ui int GetLumpId(String name)
    {
        for (int i = Wads.GetNumLumps(); i>= 0; i--)
        {
            if (Wads.GetLumpName(i) == name)
            {
                return i;
            }
        }

        return -1;
    }
}