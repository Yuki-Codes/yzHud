class YZH_OggParser : YZH_MusicParserBase
{
    override void Parse(string lumpData)
    {
        self.Artist = SearchVorbisTag("ARTIST", lumpData);
        self.Title = SearchVorbisTag("TITLE", lumpData);
    }

    // Search the wad data for a tag name in ascii format.
    // such a hack.
    private ui String SearchVorbisTag(string tagName, string lumpData)
    {
        // metadata is somewhere near the font, so don't search the entire track.
        int searchLength = min(lumpData.Length() - 5, 16384);

        for (int i = 0; i < searchLength; i++)
        {
            for (int j = 0; j < tagName.Length(); j++)
            {
                if (lumpData.ByteAt(i + j) != tagName.ByteAt(j))
                {
                    break;
                }

                if (j == tagName.Length() - 1)
                {
                    String result;

                    for (int k = 0; k < 64; k++)
                    {
                        int nextChar = lumpData.ByteAt(2 + i + j + k);
                        if (nextChar < 32)
                            return result;

                        result.AppendCharacter(nextChar);
                    }

                    return result;
                }
            }
        }

        return "";
    }
}