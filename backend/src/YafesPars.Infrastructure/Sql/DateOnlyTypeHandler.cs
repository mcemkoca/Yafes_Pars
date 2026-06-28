using System.Data;
using Dapper;

namespace YafesPars.Infrastructure.Sql;

/// <summary>
/// Dapper ondersteunt DateOnly/TimeOnly niet automatisch op alle providers.
/// Zonder deze handlers gooien alle schrijfpaden die een DateOnly doorgeven
/// (CreateContract, CreateInvoice, CreateClaim, RegisterVehicle, ...) een
/// NotSupportedException. Geregistreerd in AddInfrastructure.
/// </summary>
public sealed class DateOnlyTypeHandler : SqlMapper.TypeHandler<DateOnly>
{
    public override void SetValue(IDbDataParameter parameter, DateOnly value)
    {
        parameter.DbType = DbType.Date;
        parameter.Value = value.ToDateTime(TimeOnly.MinValue);
    }

    public override DateOnly Parse(object value) => value switch
    {
        DateTime dt => DateOnly.FromDateTime(dt),
        DateOnly d => d,
        _ => DateOnly.FromDateTime(Convert.ToDateTime(value))
    };
}

public sealed class TimeOnlyTypeHandler : SqlMapper.TypeHandler<TimeOnly>
{
    public override void SetValue(IDbDataParameter parameter, TimeOnly value)
    {
        parameter.DbType = DbType.Time;
        parameter.Value = value.ToTimeSpan();
    }

    public override TimeOnly Parse(object value) => value switch
    {
        TimeSpan ts => TimeOnly.FromTimeSpan(ts),
        DateTime dt => TimeOnly.FromDateTime(dt),
        TimeOnly t => t,
        _ => TimeOnly.FromTimeSpan((TimeSpan)value)
    };
}
