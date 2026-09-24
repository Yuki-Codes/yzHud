class YZH_StatusbarAddOn : YZH_Base
{
    private YZH_StatusBarBase m_statusBar;

    protected YZH_StatusBarBase GetStatusBar()
    {
        return m_statusBar;
    }

    protected PlayerInfo GetPlayer()
    {
        return players[consolePlayer];
    }

    protected PlayerPawn GetPlayerPawn()
    {
        return GetPlayer().mo;
    }

    ui void Initialize(YZH_StatusBarBase statusBar)
    {
        m_statusBar = statusBar;
        self.Init();
    }

    ui virtual void Init()
    {
    }

    ui virtual void Tick()
    {
    }

    ui virtual void Draw(float deltaTime)
    {
    }

    ui Vector2 GetResolution()
    {
        Vector2 scale = m_statusBar.GetHUDScale();
        return (Screen.GetWidth() / scale.y, Screen.GetHeight() / scale.y);
    }

    ui void DrawTexture(
        TextureID texture,
        Vector2 position,
        double alpha = 1.0,
        Vector2 box = (-1, -1),
        Vector2 scale = (1, 1),
        Vector2 anchor = (0, 0),
        Vector2 pivot = (0, 0))
    {
        Vector2 anchorPosition;
        Vector2 resolution = GetResolution();
        anchorPosition.x = anchor.x * resolution.x;
        anchorPosition.y = anchor.y * resolution.y;

        Vector2 pivotPosition;
        Vector2 size = TexMan.GetScaledSize(texture);
        pivotPosition.x = pivot.x * size.x;
        pivotPosition.y = pivot.y * size.y;

        m_statusBar.DrawTexture(
            texture,
            anchorPosition + position - pivotPosition,
            0x80000 | 0x200000,
            alpha: alpha,
            box: box,
            scale: scale
        );
    }

    ui void DrawString(
        HUDFont font,
        String text,
        Vector2 position,
        double alpha = 1.0,
        int wrap = -1,
        Vector2 scale = (1, 1),
        Vector2 anchor = (0, 0),
        Vector2 pivot = (0, 0))
    {
        Vector2 anchorPosition;
        Vector2 resolution = GetResolution();
        anchorPosition.x = anchor.x * resolution.x;
        anchorPosition.y = anchor.y * resolution.y;

        Vector2 pivotPosition;
        pivotPosition.x = pivot.x * font.mFont.StringWidth(text);
        //pivotPosition.y = pivot.y * font.Height();

        m_statusBar.DrawString(
            font,
            text,
            anchorPosition + position - pivotPosition,
            0,
            alpha: alpha,
            wrapWidth: wrap,
            scale: scale
        );
    }
}