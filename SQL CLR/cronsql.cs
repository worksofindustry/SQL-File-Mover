using System;
using System.Collections;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using NCrontab;


namespace NCrontab {
public static class SqlCrontab
{
    [SqlFunction(FillRowMethodName = "FillOccurrenceRow", IsDeterministic = true, IsPrecise = true)]
    public static IEnumerable GetOccurrences(SqlString expression, SqlDateTime start, SqlDateTime end)
    {
        if (expression.IsNull || start.IsNull || end.IsNull)
            return new DateTime[0];

        try
        {
            var schedule = CrontabSchedule.Parse(expression.Value);
            return schedule.GetNextOccurrences(start.Value, end.Value);
        }
        catch (CrontabException)
        {
            return new DateTime[0];
        }
    }

    public static void FillOccurrenceRow(object obj, out SqlDateTime time)
    {
        time = (DateTime) obj;
    }
}

}