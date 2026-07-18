using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol.Server;
using YafesPars.Application.Abstractions;
using YafesPars.McpServer;

namespace YafesPars.McpServer.Tools;

[McpServerToolType]
public sealed class FinanceLedgerTools
{
    private readonly IReadRepository  _read;
    private readonly IWriteRepository _write;
    private readonly OperatorContext  _ctx;

    public FinanceLedgerTools(IReadRepository read, IWriteRepository write, OperatorContext ctx)
    {
        _read  = read;
        _write = write;
        _ctx   = ctx;
    }

    [McpServerTool, Description(
        "Dubbele boekhoudingpost aanmaken. / Çift girişli muhasebe kaydı oluştur.\n" +
        "Debet en credit rekening moeten in het rekeningplan bestaan.\n" +
        "sourceType: PREMIUM | CLAIM | RESERVE | COMMISSION | CORRECTION | INTEREST | TRANSFER")]
    public async Task<string> PostLedgerEntry(
        [Description("Debet rekeningcode (bijv. '6000')")] string debitAccount,
        [Description("Credit rekeningcode (bijv. '4200')")] string creditAccount,
        [Description("Bedrag in EUR (> 0)")] decimal amountEur,
        [Description("Brontype: PREMIUM | CLAIM | RESERVE | COMMISSION | CORRECTION | INTEREST | TRANSFER")] string sourceType,
        [Description("Boekdatum (ISO: yyyy-MM-dd, leeg = vandaag)")] string? postingDate = null,
        [Description("Valutadatum (ISO: yyyy-MM-dd, leeg = boekdatum)")] string? valueDate = null,
        [Description("Omschrijving")] string? description = null,
        [Description("Sözleşme UUID (isteğe bağlı)")] Guid? contractId = null,
        [Description("Schade UUID (isteğe bağlı)")] Guid? claimId = null,
        [Description("Commissie UUID (isteğe bağlı)")] Guid? commissionId = null,
        CancellationToken ct = default)
    {
        DateOnly? postDate = null;
        if (!string.IsNullOrWhiteSpace(postingDate) && DateOnly.TryParse(postingDate, out var pd))
            postDate = pd;

        DateOnly? valDate = null;
        if (!string.IsNullOrWhiteSpace(valueDate) && DateOnly.TryParse(valueDate, out var vd))
            valDate = vd;

        var rows = await _read.QueryAsync<LedgerEntryRow>(
            "finance.SP_PostLedgerEntry",
            new
            {
                tenant_id           = _ctx.TenantId,
                posting_date        = postDate?.ToDateTime(TimeOnly.MinValue) ?? DateTime.UtcNow.Date,
                value_date          = valDate?.ToDateTime(TimeOnly.MinValue),
                debit_account       = debitAccount,
                credit_account      = creditAccount,
                amount_eur          = amountEur,
                source_type         = sourceType.ToUpperInvariant(),
                description,
                contract_id         = contractId,
                claim_id            = claimId,
                commission_id       = commissionId,
                created_by_user_id  = (Guid?)null
            }, ct);

        return JsonSerializer.Serialize(new
        {
            success    = true,
            journalId  = rows.FirstOrDefault()?.JournalId,
            entries    = rows
        });
    }

    [McpServerTool, Description(
        "Rekeningensaldi ophalen voor een periode. / Dönem hesap bakiyeleri.\n" +
        "accountType: ASSET | LIABILITY | INCOME | EXPENSE | EQUITY (boş = tümü)")]
    public async Task<string> GetLedgerBalance(
        [Description("Begindatum (ISO: yyyy-MM-dd, leeg = begin)")] string? fromDate = null,
        [Description("Einddatum (ISO: yyyy-MM-dd, leeg = vandaag)")] string? toDate = null,
        [Description("Rekeningtype filter (ASSET | LIABILITY | INCOME | EXPENSE | EQUITY)")] string? accountType = null,
        CancellationToken ct = default)
    {
        DateOnly? from = null;
        if (!string.IsNullOrWhiteSpace(fromDate) && DateOnly.TryParse(fromDate, out var f)) from = f;

        DateOnly? to = null;
        if (!string.IsNullOrWhiteSpace(toDate) && DateOnly.TryParse(toDate, out var t)) to = t;

        var rows = await _read.QueryAsync<LedgerBalanceRow>(
            "finance.SP_GetLedgerBalance",
            new
            {
                tenant_id    = _ctx.TenantId,
                from_date    = from?.ToDateTime(TimeOnly.MinValue),
                to_date      = to?.ToDateTime(TimeOnly.MinValue),
                account_type = string.IsNullOrWhiteSpace(accountType) ? null : accountType.ToUpperInvariant()
            }, ct);

        var totalIncome  = rows.Where(r => r.AccountType == "INCOME").Sum(r => r.BalanceEur);
        var totalExpense = rows.Where(r => r.AccountType == "EXPENSE").Sum(r => r.BalanceEur);

        return JsonSerializer.Serialize(new
        {
            fromDate     = fromDate,
            toDate       = toDate,
            netResultEur = Math.Round(totalIncome - totalExpense, 2),
            accounts     = rows
        });
    }

    [McpServerTool, Description(
        "Ledger regels per contract ophalen. / Sözleşme bazlı muhasebe kayıtları.\n" +
        "Alle boekingen voor dit contract in chronologische volgorde (nieuwste eerst).")]
    public async Task<string> GetLedgerByContract(
        [Description("Sözleşme UUID")] Guid contractId,
        [Description("Maksimum kayıt sayısı (varsayılan: 100)")] int limit = 100,
        CancellationToken ct = default)
    {
        var rows = await _read.QueryAsync<LedgerEntryRow>(
            "finance.SP_GetLedgerByContract",
            new
            {
                tenant_id   = _ctx.TenantId,
                contract_id = contractId,
                limit
            }, ct);

        return JsonSerializer.Serialize(new
        {
            contractId,
            count  = rows.Count,
            entries = rows
        });
    }

    [McpServerTool, Description(
        "Schadekostoverzicht uit het grootboek. / Hasar maliyet özeti.\n" +
        "Betaalde en gereserveerde bedragen per schade op basis van ledger CLAIM/RESERVE regels.")]
    public async Task<string> GetClaimCostSummary(
        [Description("Hasar UUID (boş = tenant'ın tüm hasarları)")] Guid? claimId = null,
        [Description("Başlangıç tarihi (ISO, boş = tüm)")] string? fromDate = null,
        [Description("Bitiş tarihi (ISO, boş = bugün)")] string? toDate = null,
        CancellationToken ct = default)
    {
        DateOnly? from = null;
        if (!string.IsNullOrWhiteSpace(fromDate) && DateOnly.TryParse(fromDate, out var f)) from = f;

        DateOnly? to = null;
        if (!string.IsNullOrWhiteSpace(toDate) && DateOnly.TryParse(toDate, out var t)) to = t;

        var rows = await _read.QueryAsync<ClaimCostRow>(
            "finance.SP_GetClaimCostSummary",
            new
            {
                tenant_id  = _ctx.TenantId,
                claim_id   = claimId,
                from_date  = from?.ToDateTime(TimeOnly.MinValue),
                to_date    = to?.ToDateTime(TimeOnly.MinValue)
            }, ct);

        return JsonSerializer.Serialize(new
        {
            claimId,
            count  = rows.Count,
            claims = rows
        });
    }

    // -------------------------------------------------------------------------
    private sealed record LedgerEntryRow(
        Guid     EntryId,
        Guid     JournalId,
        DateTime PostingDate,
        string   AccountCode,
        string   AccountNameNl,
        string   AccountType,
        decimal  DebitEur,
        decimal  CreditEur,
        string   SourceType);

    private sealed record LedgerBalanceRow(
        string   AccountCode,
        string   AccountNameNl,
        string   AccountType,
        string   NormalBalance,
        decimal  TotalDebitEur,
        decimal  TotalCreditEur,
        decimal  BalanceEur,
        int      EntryCount);

    private sealed record ClaimCostRow(
        Guid?    ClaimId,
        decimal  PaidEur,
        decimal  ReservedEur,
        decimal  NetCostEur,
        int      PostingCount,
        DateTime FirstPosting,
        DateTime LastPosting);
}
