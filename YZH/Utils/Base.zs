class YZH_Base
{
    void LogMessage(String message)
    {
        Console.Printf("[YZH-MSG] %s", message);
    }

    void LogWarning(String message)
    {
        Console.Printf("[YZH-WRN] %s", message);
    }

    void LogError(String message)
    {
        Console.Printf("[YZH-ERR] %s", message);
    }
}