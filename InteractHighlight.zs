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

    override void RenderUnderlay(RenderEvent event)
    {
        super.RenderUnderlay(event);

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
            m_interacts[i].Draw(
                self.Player,
                event.viewPos,
                m_projectionCache.worldToClip,
                m_deltaTime);
        }
    }

    override void WorldTick()
    {
        super.WorldTick();

        for (int i = 0; i < m_interacts.Size(); i++)
        {
            m_interacts[i].Tick(self.Player);
        }
    }
}


class LineInteract
{
    private Line m_line;
    private Vector3 m_interactPosition;
    private Vector3 m_hitPosition;
    private ui TextureId m_highlight;
    private ui Interpolator m_alpha;

    private play bool m_canSee;

    void Initialize(Line line)
    {
        m_line = line;

        Vector2 a = m_line.v1.p;
        Vector2 b = m_line.v2.p;
        Vector2 pos2d = (a + b) / 2;

        m_interactposition.x = pos2d.x;
        m_interactposition.y = pos2d.y;

        // todo: sector heights?
        m_interactposition.z = 0;
    }

    ui void UiInitialize()
    {
        m_highlight = TexMan.CheckForTexture("interact");
        m_alpha = new("Interpolator");
    }

    play void Tick(PlayerInfo player)
    {
        m_interactposition.z = player.viewz;

        m_canSee = CanSee(player);
    }

    play bool CanSee(PlayerInfo player)
    {
        Vector3 startpos = player.mo.pos;
        startPos.z = player.viewz;
        Vector3 dir = Level.Vec3Diff(startpos, m_interactposition);
        float distance = dir.Length();
        dir = dir.Unit();

        if (distance < 25 || distance > 1500)
            return false;

        // Has this sector been seen
        // subsectors have this flag, not sectors? :think:
        /*if (!(m_line.FrontSector.Flags & 2))
        {
            m_alpha.Target = 0;
        }*/

        // can we see the target line
        FLineTraceData tr;
        bool hit = player.mo.LineTrace(
            atan2(dir.y, dir.x),
            distance + 100,
            asin(-dir.z),
            offsetz: player.viewz - player.mo.pos.z,
            data: tr);

        m_hitPosition = tr.HitLocation;

        if (!hit)
            return false;

        if (tr.HitType == TRACE_HitWall && tr.HitLine == m_line)
            return true;

        return false;
    }

    ui void Draw(PlayerInfo player, Vector3 viewPos, YzMatrix4 worldToClip, float deltaTime)
    {
        if (m_line == null)
            return;

        if (m_line.special == 0)
            return;

        if (m_alpha == null)
        {
            self.UiInitialize();
        }

        m_alpha.Target = m_canSee ? 1.0 : 0.0;

        Vector3 ndcPos = worldToClip.multiplyVector3(m_hitPosition);
        float alpha = m_alpha.Update(deltaTime);
        if (abs(ndcPos.x) <= 1.0 && abs(ndcPos.y) <= 1.0 && abs(ndcPos.z) <= 1.0)
        {
            Vector2 screenPos = YzGlobalMaths.NDCToViewport(ndcPos);

            Screen.DrawTexture(
                m_highlight,
                false,
                screenPos.x,
                screenPos.y,
                DTA_Alpha, alpha);
        }
    }
}