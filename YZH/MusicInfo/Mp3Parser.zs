class YZH_Mp3Parser : YZH_MusicParserBase
{
    // Thanks to https://github.com/Geetha083/MP3-tag-reader/blob/main/id3_reader.c#L67
    override void Parse(string lumpData)
    {
        String header = lumpData.Mid(0, 10);
        if (header.Left(3) != "ID3")
            return;

        int sectionVersion = header.ByteAt(3);
        uint sectionSize = ReadInt(6, header, 4);

        int position = 10;

        while(position < sectionSize)
        {
            String frameHeader = lumpData.Mid(position, 10);
            position += 10;

            String frameId = frameHeader.Left(4);
            uint frameSize = ReadInt(4, frameHeader, sectionVersion);
            position += frameSize;

            if (frameId.ByteAt(0) == 0)
                continue;

            if (frameId == "TPE1")
            {
                self.Artist = lumpData.Mid(position - frameSize, frameSize);
            }
            else if (frameId == "TIT2")
            {
                self.Title = lumpData.Mid(position - frameSize, frameSize);
            }
            else if (frameId == "TALB")
            {
                self.Album = lumpData.Mid(position - frameSize, frameSize);
            }
        }
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