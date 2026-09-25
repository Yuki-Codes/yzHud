class YZH_Math
{
    static float Lerp(float p, float from, float to)
    {
        return (1.0f - p) * from + to * p;
    }

    static float InverseLerp(float value, float from, float to)
    {
        return (value - from) / (to - from);
    }
}