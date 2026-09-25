class YZH_KeyFrameAnimation ui
{
    private Array<YZH_KeyFrame> m_frames;
    private float m_currentTime;
    private int m_currentFrame;
    private bool m_complete;

    void AddKeyFrame(float time, float value)
    {
        YZH_KeyFrame keyFrame = new("YZH_KeyFrame");
        keyFrame.Time = time;
        keyFrame.Value = value;
        m_frames.push(keyFrame);
    }

    void Reset()
    {
        m_currentTime = 0;
        m_currentFrame = 0;
        m_complete = false;
    }

    bool IsComplete()
    {
        return m_complete;
    }

    float Update(float deltaTime)
    {
        m_currentTime += deltaTime;

        // Need at least 2 frames to animate
        if (m_currentFrame >= m_frames.Size() - 1)
            return 0.0;

        if (m_currentTime >= m_frames[m_currentFrame + 1].Time)
        {
            m_currentFrame++;

            if (m_currentFrame >= m_frames.Size() - 1)
            {
                m_complete = true;
                return m_frames[m_currentFrame].Value;
            }
        }

        float fromTime = m_frames[m_currentFrame].Time;
        float fromValue = m_frames[m_currentFrame].Value;
        float toTime = m_frames[m_currentFrame + 1].Time;
        float toValue = m_frames[m_currentFrame + 1].Value;

        float p = YZH_Math.InverseLerp(m_currentTime, fromTime, toTime);
        float v = YZH_Math.Lerp(p, fromValue, toValue);
        return v;
    }
}

class YZH_KeyFrame
{
    float Time;
    float Value;
}