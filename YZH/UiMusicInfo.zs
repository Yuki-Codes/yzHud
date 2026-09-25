class YZH_UiMusicInfo : YZH_UiAddOnBase
{
    private ui Font m_bigFont;
    private ui Font m_smallFont;

    private ui String m_currentTrack;
    private ui YZH_KeyFrameAnimation m_alphaAnimation;
    private ui YZH_KeyFrameAnimation m_yAnimation;

    private ui TextureId m_tapea;
    private ui TextureId m_tapeb;
    private ui String m_trackName;
    private ui String m_albumName;
    private ui String m_artistName;

    private ui float m_frameTime;
    private ui bool m_frame;

    override void Initialize()
    {
        m_bigFont = Font.FindFont('BigFont');
        m_smallFont = Font.FindFont('SmallFont');
        m_tapea = TexMan.CheckForTexture("yztapea");
        m_tapeb = TexMan.CheckForTexture("yztapeb");

        m_alphaAnimation = new("YZH_KeyFrameAnimation");
        m_alphaAnimation.AddKeyFrame(0, 0);
        m_alphaAnimation.AddKeyFrame(2, 0);
        m_alphaAnimation.AddKeyFrame(2.5, 1.0);
        m_alphaAnimation.AddKeyFrame(10.0, 1.0);
        m_alphaAnimation.AddKeyFrame(10.5, 0);

        m_yAnimation = new("YZH_KeyFrameAnimation");
        m_yAnimation.AddKeyFrame(0, 0);
        m_yAnimation.AddKeyFrame(2, 0);
        m_yAnimation.AddKeyFrame(2.5, 130);
        m_yAnimation.AddKeyFrame(3.0, 100);
        m_yAnimation.AddKeyFrame(10.0, 100);
        m_yAnimation.AddKeyFrame(10.5, 0);
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

            if (m_trackName == "")
                m_trackName = GetFallbackTrackName(lumpName);

            if (m_albumName == "")
                m_albumName = GetFallbackAlbumName(lumpName);

            if (m_trackName == "" && m_albumName == "" && m_artistName == "")
                return;

            // basic word wrapping.
            int wrapWidth = 200;
            if (m_bigFont.StringWidth(m_trackName) > wrapWidth)
            {
                Array<string> words;
                m_trackName.Split(words, " ", TOK_SKIPEMPTY);
                m_trackName = words[0];

                for (int i = 1; i < words.Size(); i++)
                {
                    string nextStr = String.Format("%s %s", m_trackName, words[i]);

                    if (m_bigFont.StringWidth(nextStr) > wrapWidth)
                        nextStr = String.Format("%s\n%s", m_trackName, words[i]);

                    m_trackName = nextStr;
                }

                m_trackName.StripLeftRight();
            }

            m_alphaAnimation.Reset();
            m_yAnimation.Reset();
        }

        if (m_alphaAnimation.IsComplete() && m_yAnimation.IsComplete())
            return;

        int y = GetHeight() - m_yAnimation.Update(deltaTime);
        int x = GetWidth() - 200;

        float alpha = m_alphaAnimation.Update(deltaTime);

        m_frameTime += deltaTime;
        if (m_frameTime > 0.33)
        {
            m_frame = !m_frame;
            m_frameTime = 0.0;
        }

        self.DrawTexture(
            m_frame ? m_tapea : m_tapeb,
            x,
            y,
            anchor: (0.5, 0),
            height: 128,
            alpha: alpha);

        self.DrawText(
            m_smallFont,
            m_albumName,
            x,
            y + 10,
            align: 0.5,
            alpha: alpha,
            color: Font.CR_Black);

        self.DrawText(
            m_smallFont,
            m_artistName,
            x,
            y + 18,
            align: 0.5,
            alpha: alpha,
            color: Font.CR_Black);

        self.DrawText(
            m_bigFont,
            m_trackName,
            x,
            y + 50,
            align: 0.5,
            alpha: alpha,
            color: Font.CR_Black,
            scale: 0.75);
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

    private ui String GetFallbackTrackName(string track)
    {
        // Doom 2 tracks
        if (track == "D_RUNNIN") return "Running from Evil";
        if (track == "D_RUNNI2") return "Running from Evil";
        if (track == "D_STALKS") return "The Healer Stalks";
        if (track == "D_STLKS2") return "The Healer Stalks";
        if (track == "D_STLKS3") return "The Healer Stalks";
        if (track == "D_COUNTD") return "Countdown to Death";
        if (track == "D_COUNT2") return "Countdown to Death";
        if (track == "D_BETWEE") return "Between Levels";
        if (track == "D_DOOM") return "DOOM";
        if (track == "D_DOOM2") return "DOOM";
        if (track == "D_THE_DA") return "In the Dark";
        if (track == "D_THEDA2") return "In the Dark";
        if (track == "D_THEDA3") return "In the Dark";
        if (track == "D_SHAWN") return "Shawn's Got the Shotgun";
        if (track == "D_SHAWN2") return "Shawn's Got the Shotgun";
        if (track == "D_SHAWN3") return "Shawn's Got the Shotgun";
        if (track == "D_DDTBLU") return "The Dave D. Taylor Blues";
        if (track == "D_DDTBL2") return "The Dave D. Taylor Blues";
        if (track == "D_DDTBL3") return "The Dave D. Taylor Blues";
        if (track == "D_IN_CIT") return "Into Sandy's City";
        if (track == "D_DEAD") return "The Demon's Dead";
        if (track == "D_DEAD2") return "The Demon's Dead";
        if (track == "D_ROMERO") return "Waiting for Romero to Play";
        if (track == "D_ROMER2") return "Waiting for Romero to Play";
        if (track == "D_MESSAG") return "Message for the Archvile";
        if (track == "D_MESSG2") return "Message for the Archvile";
        if (track == "D_AMPIE") return "Bye Bye American Pie";
        if (track == "D_ADRIAN") return "Adrian's Asleep";
        if (track == "D_TENSE") return "Getting Too Tense";
        if (track == "D_OPENIN") return "Opening to Hell";
        if (track == "D_EVIL") return "Evil Incarnate";
        if (track == "D_ULTIMA") return "The Ultimate Challenge/Conquest";
        if (track == "D_DM2TTL") return "untitled";
        if (track == "D_DM2INT") return "Intermission To DOOM II";
        if (track == "D_READ_M") return "Read Me While Listening to This";

        return track;
    }

    private ui String GetFallbackAlbumName(string track)
    {
        // Doom 2 tracks
        if (track == "D_RUNNIN"
        || track == "D_RUNNI2"
        || track == "D_STALKS"
        || track == "D_STLKS2"
        || track == "D_STLKS3"
        || track == "D_COUNTD"
        || track == "D_COUNT2"
        || track == "D_BETWEE"
        || track == "D_DOOM"
        || track == "D_DOOM2"
        || track == "D_THE_DA"
        || track == "D_THEDA2"
        || track == "D_THEDA3"
        || track == "D_SHAWN"
        || track == "D_SHAWN2"
        || track == "D_SHAWN3"
        || track == "D_DDTBLU"
        || track == "D_DDTBL2"
        || track == "D_DDTBL3"
        || track == "D_IN_CIT"
        || track == "D_DEAD"
        || track == "D_DEAD2"
        || track == "D_ROMERO"
        || track == "D_ROMER2"
        || track == "D_MESSAG"
        || track == "D_MESSG2"
        || track == "D_AMPIE"
        || track == "D_ADRIAN"
        || track == "D_TENSE"
        || track == "D_OPENIN"
        || track == "D_EVIL"
        || track == "D_ULTIMA"
        || track == "D_DM2TTL"
        || track == "D_DM2INT"
        || track == "D_READ_M")
            return "DOOM II";

        return track;
    }
}