using System.Security.Claims;
using Microsoft.Data.SqlClient;
using YafesPars.Api.Security;
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

        api.MapPost("/invoices", async (CreateInvoiceCommand cmd, ClaimsPrincipal user, IWriteRepository repo, CancellationToken ct) =>
        {
            var tenantId = TenantClaims.GetRequiredTenantId(user);
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "DECLARE @id UNIQUEIDENTIFIER; " +
                    "EXEC finance.sp_CreateInvoice @tenant_id, @contract_id, @issue_date, @due_date, @amount, @currency_code, @id OUTPUT; " +
                    "SELECT @id;",
                    new { tenant_id = tenantId, contract_id = cmd.ContractId, issue_date = cmd.IssueDate, due_date = cmd.DueDate, amount = cmd.Amount, currency_code = cmd.CurrencyCode },
                    ct);
                return Results.Created($"/api/finance/invoices/{id}", new { invoiceId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 51700 and <= 51730)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/invoices/{invoiceId:guid}/payments", async (Guid invoiceId, RecordPaymentCommand cmd, ClaimsPrincipal user, IWriteRepository repo, CancellationToken ct) =>
        {
            if (cmd.InvoiceId != invoiceId)
                return Results.BadRequest(new { error = "Route invoiceId must match body InvoiceId." });
            var tenantId = TenantClaims.GetRequiredTenantId(user);
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "DECLARE @id UNIQUEIDENTIFIER; " +
                    "EXEC finance.sp_RecordPayment @tenant_id, @invoice_id, @payment_date, @amount, @payment_method_code, @id OUTPUT; " +
                    "SELECT @id;",
                    new { tenant_id = tenantId, invoice_id = cmd.InvoiceId, payment_date = cmd.PaymentDate, amount = cmd.Amount, payment_method_code = cmd.PaymentMethodCode },
                    ct);
                return Results.Created($"/api/finance/invoices/{invoiceId}/payments/{id}", new { paymentId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 51700 and <= 51830)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        api.MapPost("/payment-plans", async (CreatePaymentPlanCommand cmd, ClaimsPrincipal user, IWriteRepository repo, CancellationToken ct) =>
        {
            var tenantId = TenantClaims.GetRequiredTenantId(user);
            try
            {
                var id = await repo.ExecuteScalarAsync<Guid>(
                    "DECLARE @id UNIQUEIDENTIFIER; " +
                    "EXEC finance.sp_CreatePaymentPlan @tenant_id, @contract_id, @installment_count, @first_due_date, @total_amount, @currency_code, @id OUTPUT; " +
                    "SELECT @id;",
                    new { tenant_id = tenantId, contract_id = cmd.ContractId, installment_count = cmd.InstallmentCount, first_due_date = cmd.FirstDueDate, total_amount = cmd.TotalAmount, currency_code = cmd.CurrencyCode },
                    ct);
                return Results.Created($"/api/finance/payment-plans/{id}", new { planId = id });
            }
            catch (SqlException ex) when (ex.Number is >= 51700 and <= 51830)
            {
                return Results.BadRequest(new { error = ex.Message });
            }
        });

        return app;
    }
}
