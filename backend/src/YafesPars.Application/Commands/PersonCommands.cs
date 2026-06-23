namespace YafesPars.Application.Commands;

public sealed record CreateNaturalPersonCommand(
    string? Dossier,
    string? FirstName,
    string? LastName,
    DateOnly? BirthDate,
    string? LanguageCode,
    string? Nationality,
    string? TitleCode
);

public sealed record CreateLegalPersonCommand(
    string? Dossier,
    string LegalName,
    string? LegalForm,
    string? VatNumber,
    string? LanguageCode
);
