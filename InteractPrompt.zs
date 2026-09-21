#include "alignments.zs"

class InteractPrompt : UiAddOn
{
    private ui Font m_font;
    private ui PromptDetector m_tracer;
    private ui String m_promptText;
    private ui Interpolator m_alpha;

    override void Initialize()
    {
        m_font = Font.FindFont('SmallFont');
        m_alpha = new("Interpolator");


        let [useKey1, useKey2] = bindings.GetKeysForCommand("+use");
		String keyname = bindings.NameKeys(useKey1, 0);
        m_promptText = String.Format("[%s]",  keyname);
    }

    // Scope: UI
    override void Draw(float deltaTime)
    {
        float alpha = m_alpha.Update(deltaTime);

        if (alpha > 0)
        {
            self.DrawText(
                m_font,
                m_promptText,
                self.GetWidth() / 2,
                (self.GetHeight() / 2) + 32,
                alpha: alpha,
                align: 0.5);

            /*self.DrawTexture(
                TexMan.CheckForTexture("interact"),
                self.GetWidth() / 2,
                (self.GetHeight() / 2) + 16,
                alpha: alpha * 0.75,
                scale: 1.0);*/
        }
    }

    override void Tick()
    {
        if (player == null)
            return;

        let mo = player.mo;

		// Do nothing if this player is a voodoo doll, or is dead:
		if (!mo || mo.health <= 0 || !mo.player || !mo.player.mo || mo.player.mo != mo)
            return;

        if (m_tracer == null)
            m_tracer = new('PromptDetector');

		// Fire from player's screen center:
		Vector3 start = (mo.pos.xy, self.Player.ViewZ);
		Vector3 dir = (Actor.AngleToVector(mo.angle, cos(mo.pitch)), -sin(mo.pitch));
		m_tracer.Trace(
            start,
            mo.curSector,
            dir,
            mo.useRange,
            traceFlags: 0,
            wallMask: 0,
            ignore: mo);

        m_alpha.Target = 0;
		if (m_tracer.results.HitType == TRACE_HitWall)
		{
            let line = m_tracer.results.HitLine;
            if (line.activation == SPAC_Use || line.activation == SPAC_UseThrough)
            {
                m_alpha.Target = 1.0;
            }
        }
    }
}

class PromptDetector : LineTracer
{
	override ETraceStatus TraceCallback()
	{
		switch (results.HitType)
		{
			case TRACE_HitActor:
			case TRACE_HitFloor:
			case TRACE_HitCeiling:
			case TRACE_HitWall:
            {
                if (results.HitLine)
                {
                    if (results.HitLine.activation == SPAC_Use
                        || results.HitLine.activation == SPAC_UseThrough)
                    {
				        return TRACE_Stop;
                    }
                }
            }
		}

		return TRACE_Skip;
	}
}