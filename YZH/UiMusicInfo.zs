#include "YZH/MusicInfo/Parser.zs"
#include "YZH/MusicInfo/OggParser.zs"
#include "YZH/MusicInfo/Mp3Parser.zs"
#include "YZH/MusicInfo/MidiParser.zs"

class YZH_UiMusicInfo : YZH_UiAddOnBase
{
    private ui Font m_bigFont;
    private ui Font m_smallFont;

    private ui String m_currentTrack;

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
                YZH_MusicParserBase parser;

                if (data.Left(4) == "OggS")
                {
                    parser = new("YZH_OggParser");
                }
                else if (data.Left(3) == "ID3")
                {
                    parser = new("YZH_Mp3Parser");
                }
                else if (data.Left(4) == "MThd")
                {
                    parser = new("YZH_MidiParser");
                }
                else
                {
                    // unknown file format.
                }

                parser.Parse(data);

                m_artistName = parser.Artist;
                m_artistName.Replace("\"", "");
                m_albumName = parser.Album;
                m_albumName.Replace("\"", "");
                m_trackName = parser.Title;
                m_trackName.Replace("\"", "");
            }

            // Why you didn't tag titles, Andrew. =(
            if (m_artistName == "Andrew Hulshult")
            {
                if (m_trackName == "")
                    m_trackName = GetFallbackTrackName(lumpName);
            }

            if (m_trackName == "")
                return;

            // basic word wrapping.
            int wrapWidth = 250;
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
        }

        if (!automapActive)
            return;

        if (m_trackName == "" && m_albumName == "" && m_artistName == "")
            return;

        int y = GetHeight() - 100;
        int x = GetWidth() - 120;

        float alpha = 1.0f;

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
            color: Font.CR_Gray);

        self.DrawText(
            m_smallFont,
            m_artistName,
            x,
            y + 18,
            align: 0.5,
            alpha: alpha,
            color: Font.CR_DarkGray);

        self.DrawText(
            m_bigFont,
            m_trackName,
            x,
            y + 55,
            align: 0.5,
            alpha: alpha,
            color: Font.CR_Red,
            scale: 0.65);
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
}