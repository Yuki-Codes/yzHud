#include "Gutamatics/Include.zsc"

class InteractHighlight : UiAddOn
{
    private Array<LineInteract> m_interacts;
    private ui YzProjectionCache m_projectionCache;

    override void Initialize()
    {
        m_projectionCache = new("YzProjectionCache");
    }

    override void WorldLoaded(WorldEvent event)
    {
        let player = players[consolePlayer];

        int interactableCount = 0;
        for (int i = 0; i < Level.Lines.Size(); i++)
        {
            Line line = Level.Lines[i];
            if (line.activation == SPAC_Use || line.activation == SPAC_UseThrough)
            {
                LineInteract interact = new("LineInteract");
                interact.Initialize(line);
                m_interacts.push(interact);
            }
        }
    }

    override void RenderOverlay(RenderEvent event)
    {
        super.RenderOverlay(event);

        let player = players[consolePlayer];
        double aspect = Screen.GetWidth() / Screen.GetHeight();
        m_projectionCache.CalculateMatrices(
            aspect,
            player.Fov,
            event.ViewPos,
            event.ViewAngle,
            event.ViewPitch,
            event.ViewRoll);

        m_projectionCache.CalculateMatrices(
            Screen.GetAspectRatio(),
            event.camera.player ? event.camera.player.fov : event.camera.cameraFOV,
            event.viewPos,
            event.viewAngle,
            event.viewPitch,
            event.viewRoll);

        for (int i = 0; i < m_interacts.Size(); i++)
        {
            m_interacts[i].Draw(event.viewPos, m_projectionCache.worldToClip);
        }
    }
}


class LineInteract
{
    private Line m_line;
    private ui TextureId m_highlight;

    void Initialize(Line line)
    {
        m_line = line;
    }

    ui void Draw(Vector3 viewPos, YzMatrix4 worldToClip)
    {
        if (m_line.special == 0)
            return;

        if (!m_highlight.IsValid())
            m_highlight = TexMan.CheckForTexture("interact");

        Vector2 a = m_line.v1.p;
        Vector2 b = m_line.v2.p;
        Vector2 pos2d = (a + b) / 2;

        Vector3 pos;
        pos.x = pos2d.x;
        pos.y = pos2d.y;

        // TODO: Center sector height instead of view height.
        pos.z = viewPos.z;

        float distance = (pos - viewPos).Length();

        float alpha = 1;
        if (distance < 100 || distance > 1000)
            alpha = 0;

        pos = worldToClip.multiplyVector3(pos);
        if (abs(pos.x) <= 1.0 && abs(pos.y) <= 1.0 && abs(pos.z) <= 1.0)
        {
            Vector2 screenPos = YzGlobalMaths.NDCToViewport(pos);

            Screen.DrawTexture(
                m_highlight,
                false,
                screenPos.x,
                screenPos.y,
                DTA_Alpha, alpha);
        }
    }
}