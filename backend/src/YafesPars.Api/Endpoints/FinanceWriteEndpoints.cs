using Microsoft.Data.SqlClient;
using YafesPars.Application.Commands;
using YafesPars.Application.Abstractions;

namespace YafesPars.Api.Endpoints;

public static class FinanceWriteEndpoints
{
    public static IEndpointRouteBuilder MapFinanceWriteEndpoints(this IEndpointRouteBuilder app)
    {
        var api = app.MapGroup("/api/finance")
            .WithTags("Finance")
            .RequireAuthorization("TenantUser")
            .RequireRateLimiting("write");

        api.MapPost("/invoices", async (CreateInvoiceCommand cmd, IWriteRepository repo) =>
        {
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "EXEC finance.sp_CreateInvoice @ContractId, @IssueDate, @DueDate, @Amount, @CurrencyCode",
                    new { cmd.ContractId, cmd.IssueDate, cmd.DueDate, cmd.Amount, cmd.CurrencyCode });
                return Results.Created($"/api/finance/invoices/{id}", new { invoiceId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 51700 and <= 51730)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/invoices/{invoiceId:guid}/payments", async (Guid invoiceId, RecordPaymentCommand cmd, IWriteRepository repo) =>
        {
            if (cmd.InvoiceId != invoiceId)
                return Results.BadRequest(new { error = "Route invoiceId must match body InvoiceId." });
            try
            {
                await repo.ExecuteScalarAsync<Guid>(
                    "EXEC finance.sp_RecordPayment @InvoiceId, @PaymentDate, @Amount, @PaymentMethodCode",
                    new { cmd.InvoiceId, cmd.PaymentDate, cmd.Amount, cmd.PaymentMethodCode });
                return Results.NoContent();
            }
            catch (SqlException ex) when (ex.Number is >= 51700 and <= 51730)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/payment-plans", async (CreatePaymentPlanCommand cmd, IWriteRepository repo) =>
        {
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "EXEC finance.sp_CreatePaymentPlan @ContractId, @InstallmentCount, @FirstDueDate, @TotalAmount, @CurrencyCode",
                    new { cmd.ContractId, cmd.InstallmentCount, cmd.FirstDueDate, cmd.TotalAmount, cmd.CurrencyCode });
                return Results.Created($"/api/finance/payment-plans/{id}", new { planId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 51700 and <= 51730)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        return app;
    }
}
