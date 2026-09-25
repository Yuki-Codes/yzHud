class YZH_UiMusicInfo : YZH_UiAddOnBase
{
    private ui Font m_bigFont;
    private ui Font m_smallFont;

    private ui String m_currentTrack;
    private ui YZH_KeyFrameAnimation m_animation;

    private ui String m_trackName;
    private ui String m_albumName;
    private ui String m_artistName;

    override void Initialize()
    {
        m_bigFont = Font.FindFont('BigFont');
        m_smallFont = Font.FindFont('SmallFont');

        m_animation = new("YZH_KeyFrameAnimation");
        m_animation.AddKeyFrame(0, 0);
        m_animation.AddKeyFrame(2.0, 0);
        m_animation.AddKeyFrame(5.0, 1.0);
        m_animation.AddKeyFrame(10.0, 1.0);
        m_animation.AddKeyFrame(12.0, 0.0);
    }

    override void Draw(float deltaTime)
    {
        if (m_currentTrack != level.Music)
        {
            m_trackName = "";
            m_albumName = "";
            m_artistName = "";
            m_currentTrack = level.Music;

            String lumpName = m_currentTrack.MakeUpper();
            lumpName.Replace("$MUSIC_", "D_");

            int lumpId = GetMusicLumpId(lumpName);
            if (lumpId != -1)
            {
                string data = Wads.ReadLump(lumpId);

                if (data.Left(4) == "OggS")
                {
                    m_artistName = SearchVorbisTag("ARTIST", data);
                    m_trackName = SearchVorbisTag("TITLE", data);
                }
                else if (data.Left(3) == "ID3")
                {
                    m_artistName = SearchId3Tag("TPE1", data);
                    m_trackName = SearchId3Tag("TIT2", data);
                    m_albumName = SearchId3Tag("TALB", data);
                }
                else
                {
                    // unknown file format. probably midi.
                }
            }

            if (m_trackName == "" && m_albumName == "" && m_artistName == "")
                return;

            m_animation.Reset();
        }

        if (m_animation.IsComplete())
            return;

        int y = (GetHeight() / 2) + 100;

        float alpha = m_animation.Update(deltaTime);

        self.DrawText(
            m_smallFont,
            m_albumName,
            GetWidth() / 2,
            y,
            align: 0.5,
            alpha: alpha,
            color: Font.CR_Red);

        self.DrawText(
            m_bigFont,
            m_trackName,
            GetWidth() / 2,
            y + m_smallFont.GetHeight(),
            align: 0.5,
            alpha: alpha,
            color: Font.CR_Red);

        self.DrawText(
            m_smallFont,
            m_artistName,
            GetWidth() / 2,
            y + m_smallFont.GetHeight() + m_bigFont.GetHeight(),
            align: 0.5,
            alpha: alpha,
            color: Font.CR_Red);
    }

    ui int GetMusicLumpId(String name)
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

    // Search the wad data for a tag name in ascii format.
    private ui String SearchVorbisTag(string tagName, string wadData)
    {
        // metadata is somewhere near the font, so don't search the entire track.
        int searchLength = min(wadData.Length() - 5, 16384);

        for (int i = 0; i < searchLength; i++)
        {
            for (int j = 0; j < tagName.Length(); j++)
            {
                if (wadData.ByteAt(i + j) != tagName.ByteAt(j))
                {
                    break;
                }

                if (j == tagName.Length() - 1)
                {
                    String result;

                    for (int k = 0; k < 64; k++)
                    {
                        int nextChar = wadData.ByteAt(2 + i + j + k);
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

    // Thanks to https://github.com/Geetha083/MP3-tag-reader/blob/main/id3_reader.c#L67
    private ui String SearchId3Tag(string tagName, string wadData)
    {
        String header = wadData.Mid(0, 10);
        if (header.Left(3) != "ID3")
            return "";

        int sectionVersion = header.ByteAt(3);
        uint sectionSize = ReadInt(6, header, 4);

        int position = 10;

        while(position < sectionSize)
        {
            String frameHeader = wadData.Mid(position, 10);
            position += 10;

            String frameId = frameHeader.Left(4);
            uint frameSize = ReadInt(4, frameHeader, sectionVersion);
            position += frameSize;

            if (frameId.ByteAt(0) == 0)
                continue;

            if (frameId == tagName)
                return wadData.Mid(position - frameSize, frameSize);
        }

        return "";
    }

    private ui uint ReadInt(int position, string data, int ver)
    {
        if (ver >= 4)
        {
            return ((uint(data.ByteAt(position)) & 0x7F) << 21) |
                ((uint(data.ByteAt(position + 1)) & 0x7F) << 14) |
                ((uint(data.ByteAt(position + 2)) & 0x7F) << 7) |
                ((uint(data.ByteAt(position + 3)) & 0x7F));
        }

        return (uint(data.ByteAt(position)) << 24) |
            (uint(data.ByteAt(position + 1)) << 16) |
            (uint(data.ByteAt(position + 2)) << 8) |
            (uint(data.ByteAt(position + 3)));
    }
}