class YZH_UiLevelInfo : YZH_UiAddOnBase
{
    private ui Font m_bigFont;
    private ui Font m_smallFont;

    private ui int m_currentLevel;
    private ui YZH_KeyFrameAnimation m_mapNameAnimation;
    private ui YZH_KeyFrameAnimation m_authorAnimation;

    private ui String m_episodeName;

    override void Initialize()
    {
        m_bigFont = Font.FindFont('BigFont');
        m_smallFont = Font.FindFont('SmallFont');

        m_mapNameAnimation = new("YZH_KeyFrameAnimation");
        m_mapNameAnimation.AddKeyFrame(0, 0);
        m_mapNameAnimation.AddKeyFrame(3.0, 0);
        m_mapNameAnimation.AddKeyFrame(6.0, 1.0);
        m_mapNameAnimation.AddKeyFrame(10.0, 1.0);
        m_mapNameAnimation.AddKeyFrame(14.0, 0.0);

        m_authorAnimation = new("YZH_KeyFrameAnimation");
        m_authorAnimation.AddKeyFrame(0, 0);
        m_authorAnimation.AddKeyFrame(4.0, 0);
        m_authorAnimation.AddKeyFrame(7.0, 1.0);
        m_authorAnimation.AddKeyFrame(11.0, 1.0);
        m_authorAnimation.AddKeyFrame(12.0, 0.0);
    }

    override void Draw(float deltaTime)
    {
        if (m_currentLevel != level.LevelNum)
        {
            m_mapNameAnimation.Reset();
            m_authorAnimation.Reset();
            m_currentLevel = level.LevelNum;
        }

        if (m_mapNameAnimation.IsComplete()
            && m_authorAnimation.IsComplete())
            return;

        int y = (GetHeight() / 2) - 100;

        self.DrawText(
            m_bigFont,
            level.LevelName,
            GetWidth() / 2,
            y + m_smallFont.GetHeight(),
            align: 0.5,
            alpha:m_mapNameAnimation.Update(deltaTime),
            color: Font.CR_Red);

        self.DrawText(
            m_smallFont,
            level.AuthorName,
            GetWidth() / 2,
            y + m_smallFont.GetHeight() + m_bigFont.GetHeight(),
            align: 0.5,
            alpha:m_authorAnimation.Update(deltaTime),
            color: Font.CR_White);
    }
}