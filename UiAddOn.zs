class UiAddOn : StaticEventHandler
{
    PlayerInfo Player;

    protected ui float m_deltaTime;

    private ui bool m_isInitialized;
    private ui int m_canvasWidth;
    private ui int m_canvasHeight;
    private ui int m_canvasScale;
    private ui float m_prevDrawTime;

    ui virtual void Initialize()
    {
    }

    ui virtual void Draw(float deltaTime)
    {
    }

    ui virtual void Tick()
    {
    }

    override void RenderOverlay(RenderEvent event)
    {
        float drawTime = MSTimeF();
        m_deltaTime = (drawTime - m_prevDrawTime) / 1000;
        m_deltaTime = clamp(m_deltaTime, 0, 0.1);
        m_prevDrawTime = drawTime;

        if (!m_isInitialized)
            return;

        self.Draw(m_deltaTime);
    }

    override void UiTick()
    {
        if (self.Player == null)
            return;

        if (!m_isInitialized)
        {
            m_isInitialized = true;

            m_canvasScale = 3;
            m_canvasWidth = Screen.GetWidth() / m_canvasScale;
            m_canvasHeight = Screen.GetHeight() / m_canvasScale;

            self.Initialize();
        }

        self.Tick();
    }

    override void WorldTick()
    {
        self.Player = players[consolePlayer];
    }

    ui int GetWidth()
    {
        return m_canvasWidth;
    }

    ui int GetHeight()
    {
        return m_canvasHeight;
    }

    ui void DrawTexture(
        TextureID texture,
        int x,
        int y,
        int width = 0,
        int height = 0,
        float alpha = 1.0,
        Vector2 anchor = (0.0f, 0.0f),
        float scale = 1.0,
        int clipHeight = 0)
    {
        int textureWidth, textureHeight = TexMan.GetSize(texture);
        Vector2 size = TexMan.GetScaledSize(texture);

        if (width > 0 && height == 0)
        {
            scale = (width / size.X);
        }
        else if (height > 0 && width == 0)
        {
            scale = (height / size.Y);
        }

        if (width == 0)
            width = size.x;

        if (height == 0)
            height = size.y;

        if (scale != 1.0)
        {
            width *= scale;
            height *= scale;
        }

        int clipTop = 0;
        int clipBottom = m_canvasHeight;
        if (clipHeight != 0)
        {
            clipTop = (y - (clipHeight * anchor.y));
            clipBottom = clipTop + clipHeight;
        }

        Screen.DrawTexture(
            texture,
            false,
            x,
            y,
            DTA_ClipTop, clipTop * m_canvasScale,
            DTA_ClipBottom, clipBottom * m_canvasScale,
            DTA_Alpha, alpha,
            width > 0 ? DTA_DestWidth : DTA_Base, width,
            height > 0 ? DTA_DestHeight : DTA_Base, height,
            DTA_HudRules, 1,
            DTA_KeepRatio, true,
            DTA_LeftOffsetF, anchor.X * size.X,
            DTA_TopOffsetF, anchor.Y * size.Y,
            DTA_VirtualWidth, m_canvasWidth,
            DTA_VirtualHeight, m_canvasHeight);
    }

    ui void DrawText(
        Font font,
        String text,
        int x,
        int y,
        int color = Font.CR_WHITE,
        float alpha = 1.0,
        float align = 0.0f)
    {
        x -= font.stringWidth(text) * align;

        Screen.DrawText(
            font,
            color,
            x,
            y,
            text,
            DTA_Alpha, alpha,
            DTA_HudRules, 1,
            DTA_KeepRatio, true,
            DTA_VirtualWidth, m_canvasWidth,
            DTA_VirtualHeight, m_canvasHeight);
    }
}