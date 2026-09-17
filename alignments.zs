class VerticalAlignment ui
{
    enum Val
    {
        Top = 0x4000 | 0x0000,
        Center = 0x4000 | 0x8000,
        Bottom = 0x4000 | 0x10000,
    }
}

class HorizontalAlignment ui
{
    enum Val
    {
        Left = 0x4000 | 0x0000,
        Center = 0x4000 | 0x20000,
        Right = 0x4000 | 0x40000,
    }
}

class VerticalPivot ui
{
    enum Val
    {
        Top = 0x80000,
        Center = 0x100000,
        Bottom = 0,
    }
}

class HorizontalPivot ui
{
    enum Val
    {
        Left = 0x200000,
        Center = 0,
        Right = 0x400000,
    }
}

class TextAlignment
{
    enum Val
    {
        Left = 0x0000000,
        Center = 0x1000000,
        Right = 0x800000,
    }
}