// https://github.com/craigsapp/midifile/blob/master/src/MidiFile.cpp#L2823
class YZH_MidiParser : YZH_MusicParserBase
{
    static const String Instruments[] =
    {
        "acoustic grand piano",   "bright acoustic piano",  "electric grand piano",  "honky-tonk piano", "rhodes piano",   "chorused piano",
        "harpsichord",  "clavinet",  "celeste",   "glockenspiel",   "music box",  "vibraphone",
        "marimba",   "xylophone",  "tubular bells",  "dulcimer",    "hammond organ",   "percussive organ",
        "rock organ",   "church organ", "reed organ",   "accordion",   "harmonica", "tango accordion",
        "nylon guitar",  "steel guitar",  "jazz guitar",   "clean guitar",  "muted guitar",   "overdriven guitar",
        "distortion guitar",   "guitar harmonics",   "acoustic bass",    "fingered electric bass",  "picked electric bass",  "fretless bass",
        "slap bass 1",  "slap bass 2",  "synth bass 1",  "synth bass 2",  "violin",    "viola",
        "cello",     "contrabass",  "tremolo strings",   "pizzcato strings",  "orchestral harp",      "timpani",
        "string ensemble 1",   "string ensemble 2",   "synth strings 1",   "synth strings 1",   "choir aahs",     "voice oohs",
        "synth voices",    "orchestra hit",   "trumpet",   "trombone",  "tuba",      "muted trumpet",
        "frenc horn", "brass section",  "syn brass 1",  "synth brass 2",  "soprano sax",  "alto sax",
        "tenor sax",  "baritone sax",   "oboe",      "english horn",  "bassoon",   "clarinet",
        "piccolo",   "flute",     "recorder",  "pan flute",  "bottle blow",    "shakuhachi",
        "whistle",   "ocarina",   "square wave",   "saw wave",   "calliope lead",  "chiffer lead",
        "charang lead",   "voice lead",   "fifths lead",   "brass lead",  "newage pad",  "warm pad",
        "polysyn pad",   "choir pad",   "bowed pad",  "metallic pad",  "halo pad",   "sweep pad",
        "rain",    "soundtrack",  "crystal",   "atmosphere",  "brightness",  "goblins",
        "echoes",   "sci-fi",  "sitar",     "banjo",     "shamisen",  "koto",
        "kalimba",   "bagpipes",  "fiddle",    "shanai",   "tinkle bell",  "agogo",
        "steel drums", "woodblock", "taiko drum",     "melodoc tom",      "synth drum",    "reverse cymbal",
        "guitar fret noise",   "breath noise",   "seashore",  "bird tweet",    "telephone ring", "helicopter",
        "applause",  "gunshot",

        "picked bass", "mixer", "standard kit", "steel gtr", "dist guitar", "tremolo", "slowstrings",
        "tremolo str", "overdrive gt", "distortion gt", "drum set", "drum kit", "synthesizer", "piano",
        "electronic kit", "lead acoustic"
    };

    override void Parse(string lumpData)
    {
        // is midi
        if (lumpData.Left(4) != "MThd")
            return;

        uint headerSize = ReadInt4Byte(4, lumpData);
        if (headerSize != 6)
            return;

        ////uint formatType = ReadInt2Byte(8, lumpData);
        uint trackCount = ReadInt2Byte(10, lumpData);
        ////uint tpqn = ReadInt2Byte(12, lumpData);

        int wadSize = lumpData.Length();
        int position = 14;
        for (int i = 0; i < trackCount; i++)
        {
            if (lumpData.Mid(position, 4) != "MTrk")
                return;

            position += 4;

            int trackSize = ReadInt4Byte(position, lumpData);
            int trackStartPosition = position + 4;
            while(position < wadSize)
            {
                int cmd = lumpData.ByteAt(position);
                if (cmd == 0xff)
                {
                    int type = lumpData.ByteAt(position + 1);
                    int size = lumpData.ByteAt(position + 2);

                    if (type == 3 && self.Title == "")
                    {
                        String trackTitle = lumpData.Mid(position + 3, size);
                        if (!IsInstrument(trackTitle))
                        {
                            self.Title = trackTitle;
                        }
                    }
                    else if (type == 2)
                    {
                        String copyright = lumpData.Mid(position + 3, size);
                        self.Artist = copyright;
                    }
                }

                // Check for actual end of track.
                if (lumpData.ByteAt(position) == 0xFF && lumpData.ByteAt(position + 1) == 0x2F)
                {
                    break;
                }

                position++;
            }

            position += 3;
        }
    }

    private ui bool IsInstrument(string title)
    {
        title = title.MakeLower();
        title.Replace("copy", "");
        title.StripLeftRight();
        for (int i = 0; i < Instruments.Size(); i++)
        {
            if (Instruments[i] == title)
                return true;
        }

        return false;
    }

    private ui uint ReadInt4Byte(int position, string data)
    {
        return (uint(data.ByteAt(position + 3))) |
            (uint(data.ByteAt(position + 2)) << 8) |
            (uint(data.ByteAt(position + 1)) << 16) |
            (uint(data.ByteAt(position + 0)) << 24);
    }

    private ui uint ReadInt2Byte(int position, string data)
    {
        return (uint(data.ByteAt(position + 1))) |
            (uint(data.ByteAt(position + 0)) << 8);
    }
}