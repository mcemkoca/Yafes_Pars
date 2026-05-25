import type { Person } from './mockData'

// Extended person data with additional fields for detail drawer
export interface PersonDetail extends Person {
  geboorteplaats?: string
  nationaliteit?: string
  burgerlijkeStaat?: string
  taal?: string
  beroep?: string
  telefoonVast?: string
  website?: string
  provincie?: string
  contactPersonen?: { naam: string; functie: string; telefoon: string; email: string }[]
  relaties?: { persoonId: string; naam: string; relatie: string; contractenGedeeld: number }[]
  geschiedenis?: { datum: string; gebruiker: string; actie: string; details: string }[]
  contractCount: number
}

export const personenDetails: PersonDetail[] = [
  {
    id: 'P-2024-0001', type: 'natuurlijk', voornaam: 'Jan', achternaam: 'Peeters',
    rrn: '85.12.31-123.45', geboortedatum: '1985-12-31', geslacht: 'M',
    geboorteplaats: 'Mechelen', nationaliteit: 'Belg', burgerlijkeStaat: 'Gehuwd', taal: 'Nederlands', beroep: 'Accountant',
    email: 'jan.peeters@email.be', telefoon: '0478/12.34.56', telefoonVast: '015/12.34.56',
    adres: 'Kerkstraat 12', postcode: '2800', gemeente: 'Mechelen', provincie: 'Antwerpen', land: 'België',
    status: 'actief', createdAt: '2022-03-15', updatedAt: '2024-12-12',
    contractCount: 3,
    relaties: [
      { persoonId: 'P-2024-0002', naam: 'Peeters, Hilde', relatie: 'Partner', contractenGedeeld: 2 },
      { persoonId: 'P-2024-0003', naam: 'Peeters, Lucas', relatie: 'Familielid', contractenGedeeld: 1 },
    ],
    geschiedenis: [
      { datum: '12/12/2024 14:32', gebruiker: 'Marie Dubois', actie: 'Bewerkt', details: 'Adres gewijzigd' },
      { datum: '15/03/2022 09:15', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Persoon geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0002', type: 'natuurlijk', voornaam: 'Marie', achternaam: 'Dubois',
    rrn: '72.04.15-789.01', geboortedatum: '1972-04-15', geslacht: 'V',
    geboorteplaats: 'Brussel', nationaliteit: 'Belg', burgerlijkeStaat: 'Gehuwd', taal: 'Frans', beroep: 'Advocaat',
    email: 'marie.dubois@email.be', telefoon: '0498/56.78.90',
    adres: 'Rue du Marché 45', postcode: '1000', gemeente: 'Brussel', provincie: 'Brussel-Hoofdstad', land: 'België',
    status: 'actief', createdAt: '2021-06-20', updatedAt: '2024-11-28',
    contractCount: 5,
    relaties: [
      { persoonId: 'P-2024-0001', naam: 'Dubois, Pierre', relatie: 'Partner', contractenGedeeld: 3 },
    ],
    geschiedenis: [
      { datum: '28/11/2024 10:15', gebruiker: 'Pieter Janssens', actie: 'Bewerkt', details: 'Telefoonnummer bijgewerkt' },
      { datum: '20/06/2021 11:00', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Persoon geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0003', type: 'natuurlijk', voornaam: 'Pieter', achternaam: 'Janssens',
    rrn: '90.07.22-456.78', geboortedatum: '1990-07-22', geslacht: 'M',
    geboorteplaats: 'Gent', nationaliteit: 'Belg', burgerlijkeStaat: 'Samenwonend', taal: 'Nederlands', beroep: 'IT Consultant',
    email: 'pieter.janssens@email.be', telefoon: '0475/98.76.54',
    adres: 'Dorpstraat 8', postcode: '9000', gemeente: 'Gent', provincie: 'Oost-Vlaanderen', land: 'België',
    status: 'actief', createdAt: '2023-01-10', updatedAt: '2024-12-10',
    contractCount: 2,
    relaties: [],
    geschiedenis: [
      { datum: '10/12/2024 09:00', gebruiker: 'Systeem', actie: 'Contract verlengd', details: 'Auto verzekering verlengd' },
      { datum: '10/01/2023 14:20', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Persoon geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0004', type: 'natuurlijk', voornaam: 'Anna', achternaam: 'Vermeiren',
    rrn: '68.11.03-234.56', geboortedatum: '1968-11-03', geslacht: 'V',
    geboorteplaats: 'Hasselt', nationaliteit: 'Belg', burgerlijkeStaat: 'Gescheiden', taal: 'Nederlands', beroep: 'Verpleegkundige',
    email: 'anna.vermeiren@email.be', telefoon: '0471/23.45.67',
    adres: 'Stationsplein 3', postcode: '3500', gemeente: 'Hasselt', provincie: 'Limburg', land: 'België',
    status: 'actief', createdAt: '2020-09-05', updatedAt: '2024-11-30',
    contractCount: 4,
    relaties: [
      { persoonId: 'P-2024-0005', naam: 'Vermeiren, Tom', relatie: 'Partner', contractenGedeeld: 1 },
    ],
    geschiedenis: [
      { datum: '30/11/2024 16:45', gebruiker: 'Marie Dubois', actie: 'Contract toegevoegd', details: 'Brandverzekering toegevoegd' },
      { datum: '05/09/2020 10:30', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Persoon geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0005', type: 'natuurlijk', voornaam: 'Sarah', achternaam: 'Michiels',
    rrn: '95.02.18-890.12', geboortedatum: '1995-02-18', geslacht: 'V',
    geboorteplaats: 'Leuven', nationaliteit: 'Belg', burgerlijkeStaat: 'Ongehuwd', taal: 'Nederlands', beroep: 'Marketing Manager',
    email: 'sarah.michiels@email.be', telefoon: '0485/67.89.01',
    adres: 'Koning Albertlaan 28', postcode: '3000', gemeente: 'Leuven', provincie: 'Vlaams-Brabant', land: 'België',
    status: 'inactief', createdAt: '2023-05-12', updatedAt: '2024-10-15',
    contractCount: 0,
    relaties: [],
    geschiedenis: [
      { datum: '15/10/2024 11:20', gebruiker: 'Systeem', actie: 'Gedeactiveerd', details: 'Account gedeactiveerd wegens inactiviteit' },
      { datum: '12/05/2023 09:00', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Persoon geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0006', type: 'rechtspersoon', voornaam: '', achternaam: '', naam: 'De Boer BVBA',
    rrn: 'BE 0475.123.456', geboortedatum: '', geslacht: 'X',
    website: 'www.deboerbvba.be',
    email: 'info@deboerbvba.be', telefoon: '015/34.56.78',
    adres: 'Industrielaan 45', postcode: '2800', gemeente: 'Mechelen', provincie: 'Antwerpen', land: 'België',
    status: 'actief', createdAt: '2019-03-12', updatedAt: '2024-12-05',
    contractCount: 12,
    contactPersonen: [
      { naam: 'Jef De Boer', functie: 'Zaakvoerder', telefoon: '0476/12.34.56', email: 'jef@deboerbvba.be' },
      { naam: 'Linda Peeters', functie: 'Boekhouder', telefoon: '0477/23.45.67', email: 'linda@deboerbvba.be' },
    ],
    geschiedenis: [
      { datum: '05/12/2024 14:00', gebruiker: 'Pieter Janssens', actie: 'Contract toegevoegd', details: 'Vlootverzekering uitgebreid met 2 voertuigen' },
      { datum: '12/03/2019 10:00', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Bedrijf geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0007', type: 'rechtspersoon', voornaam: '', achternaam: '', naam: 'Verzekerd NV',
    rrn: 'BE 0896.234.567', geboortedatum: '', geslacht: 'X',
    website: 'www.verzekerdnv.be',
    email: 'info@verzekerdnv.be', telefoon: '03/234.56.78',
    adres: 'Groenplaats 1', postcode: '2000', gemeente: 'Antwerpen', provincie: 'Antwerpen', land: 'België',
    status: 'actief', createdAt: '2018-07-01', updatedAt: '2024-11-20',
    contractCount: 8,
    contactPersonen: [
      { naam: 'Karel Verzekerd', functie: 'CEO', telefoon: '0499/11.22.33', email: 'karel@verzekerdnv.be' },
    ],
    geschiedenis: [
      { datum: '20/11/2024 09:30', gebruiker: 'Marie Dubois', actie: 'Bewerkt', details: 'Contactgegevens bijgewerkt' },
      { datum: '01/07/2018 08:00', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Bedrijf geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0008', type: 'rechtspersoon', voornaam: '', achternaam: '', naam: 'Solidariteit VZW',
    rrn: 'BE 0412.345.678', geboortedatum: '', geslacht: 'X',
    website: 'www.solidariteitzw.be',
    email: 'info@solidariteitzw.be', telefoon: '059/12.34.56',
    adres: 'Heldenplein 22', postcode: '8400', gemeente: 'Oostende', provincie: 'West-Vlaanderen', land: 'België',
    status: 'actief', createdAt: '2020-01-15', updatedAt: '2024-11-18',
    contractCount: 2,
    contactPersonen: [
      { naam: 'Els De Vriendt', functie: 'Voorzitter', telefoon: '0472/34.56.78', email: 'els@solidariteitzw.be' },
    ],
    geschiedenis: [
      { datum: '18/11/2024 11:00', gebruiker: 'Pieter Janssens', actie: 'Contract verlengd', details: 'Evenementenverzekering verlengd' },
      { datum: '15/01/2020 10:00', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'VZW geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0009', type: 'rechtspersoon', voornaam: '', achternaam: '', naam: 'Peeters & Co Comm.V',
    rrn: 'BE 0567.890.123', geboortedatum: '', geslacht: 'X',
    website: 'www.peetersco.be',
    email: 'info@peetersco.be', telefoon: '02/456.78.90',
    adres: 'Brusselsesteenweg 89', postcode: '1740', gemeente: 'Ternat', provincie: 'Vlaams-Brabant', land: 'België',
    status: 'actief', createdAt: '2021-08-22', updatedAt: '2024-12-01',
    contractCount: 6,
    contactPersonen: [
      { naam: 'Bart Peeters', functie: 'Medezaakvoerder', telefoon: '0473/45.67.89', email: 'bart@peetersco.be' },
      { naam: 'Inge Coppens', functie: 'Secretaresse', telefoon: '0474/56.78.90', email: 'inge@peetersco.be' },
    ],
    geschiedenis: [
      { datum: '01/12/2024 15:30', gebruiker: 'Systeem', actie: 'Contract verlengd', details: 'BA verzekering verlengd' },
      { datum: '22/08/2021 09:00', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Comm.V geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0010', type: 'rechtspersoon', voornaam: '', achternaam: '', naam: 'Tech Solutions BV',
    rrn: 'BE 0734.567.890', geboortedatum: '', geslacht: 'X',
    website: 'www.techsolutions.be',
    email: 'info@techsolutions.be', telefoon: '016/45.67.89',
    adres: 'Wetenschapspark 7', postcode: '3001', gemeente: 'Heverlee', provincie: 'Vlaams-Brabant', land: 'België',
    status: 'inactief', createdAt: '2022-11-05', updatedAt: '2024-09-10',
    contractCount: 0,
    contactPersonen: [
      { naam: 'Steven Jacobs', functie: 'CEO', telefoon: '0475/67.89.01', email: 'steven@techsolutions.be' },
    ],
    geschiedenis: [
      { datum: '10/09/2024 10:00', gebruiker: 'Marie Dubois', actie: 'Gearchiveerd', details: 'Alle contracten beëindigd' },
      { datum: '05/11/2022 11:00', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'BV geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0011', type: 'natuurlijk', voornaam: 'Lucas', achternaam: 'Peeters',
    rrn: '78.06.30-567.89', geboortedatum: '1978-06-30', geslacht: 'M',
    geboorteplaats: 'Leuven', nationaliteit: 'Belg', burgerlijkeStaat: 'Gehuwd', taal: 'Nederlands', beroep: 'Architect',
    email: 'lucas.peeters@email.be', telefoon: '0472/56.78.90', telefoonVast: '016/12.34.56',
    adres: 'Diestsestraat 67', postcode: '3000', gemeente: 'Leuven', provincie: 'Vlaams-Brabant', land: 'België',
    status: 'actief', createdAt: '2021-04-18', updatedAt: '2024-12-08',
    contractCount: 4,
    relaties: [
      { persoonId: 'P-2024-0012', naam: 'Peeters, Sofie', relatie: 'Partner', contractenGedeeld: 3 },
    ],
    geschiedenis: [
      { datum: '08/12/2024 13:20', gebruiker: 'Pieter Janssens', actie: 'Bewerkt', details: 'Nieuwe brandverzekering toegevoegd' },
      { datum: '18/04/2021 09:15', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Persoon geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0012', type: 'natuurlijk', voornaam: 'Emma', achternaam: 'Wouters',
    rrn: '88.03.27-901.23', geboortedatum: '1988-03-27', geslacht: 'V',
    geboorteplaats: 'Gent', nationaliteit: 'Belg', burgerlijkeStaat: 'Ongehuwd', taal: 'Nederlands', beroep: 'Leerkracht',
    email: 'emma.wouters@email.be', telefoon: '0479/89.01.23',
    adres: 'Kortrijksesteenweg 88', postcode: '9000', gemeente: 'Gent', provincie: 'Oost-Vlaanderen', land: 'België',
    status: 'prospect', createdAt: '2024-11-20', updatedAt: '2024-12-12',
    contractCount: 0,
    relaties: [],
    geschiedenis: [
      { datum: '12/12/2024 10:00', gebruiker: 'Systeem', actie: 'Herinnering', details: 'Offerte opvolging verstuurd' },
      { datum: '20/11/2024 14:30', gebruiker: 'Marie Dubois', actie: 'Aangemaakt', details: 'Prospect toegevoegd na beurs' },
    ],
  },
  {
    id: 'P-2024-0013', type: 'natuurlijk', voornaam: 'Koen', achternaam: 'Maes',
    rrn: '80.07.19-012.34', geboortedatum: '1980-07-19', geslacht: 'M',
    geboorteplaats: 'Dilbeek', nationaliteit: 'Belg', burgerlijkeStaat: 'Gehuwd', taal: 'Nederlands', beroep: 'Zelfstandige',
    email: 'koen.maes@email.be', telefoon: '0476/01.23.45',
    adres: 'Steenweg op Brussels 56', postcode: '1700', gemeente: 'Dilbeek', provincie: 'Vlaams-Brabant', land: 'België',
    status: 'actief', createdAt: '2020-06-15', updatedAt: '2024-12-06',
    contractCount: 3,
    relaties: [
      { persoonId: 'P-2024-0014', naam: 'Maes, Karen', relatie: 'Partner', contractenGedeeld: 2 },
    ],
    geschiedenis: [
      { datum: '06/12/2024 09:45', gebruiker: 'Pieter Janssens', actie: 'Bewerkt', details: 'Adres gecorrigeerd' },
      { datum: '15/06/2020 11:30', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Persoon geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0014', type: 'natuurlijk', voornaam: 'Liesbeth', achternaam: 'De Smet',
    rrn: '77.12.03-345.67', geboortedatum: '1977-12-03', geslacht: 'V',
    geboorteplaats: 'Herentals', nationaliteit: 'Belg', burgerlijkeStaat: 'Gescheiden', taal: 'Nederlands', beroep: 'Apotheker',
    email: 'liesbeth.desmet@email.be', telefoon: '0477/12.34.56',
    adres: 'Marktplein 3', postcode: '2200', gemeente: 'Herentals', provincie: 'Antwerpen', land: 'België',
    status: 'actief', createdAt: '2019-11-10', updatedAt: '2024-12-09',
    contractCount: 5,
    relaties: [],
    geschiedenis: [
      { datum: '09/12/2024 16:00', gebruiker: 'Marie Dubois', actie: 'Contract toegevoegd', details: 'Ziekenfonds aanvullende verzekering' },
      { datum: '10/11/2019 10:00', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Persoon geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0015', type: 'natuurlijk', voornaam: 'Bart', achternaam: 'Vandenberghe',
    rrn: '69.05.22-456.78', geboortedatum: '1969-05-22', geslacht: 'M',
    geboorteplaats: 'Mortsel', nationaliteit: 'Belg', burgerlijkeStaat: 'Gehuwd', taal: 'Nederlands', beroep: 'Technicus',
    email: 'bart.vandenberghe@email.be', telefoon: '0478/23.45.67',
    adres: 'Eikenlaan 44', postcode: '2640', gemeente: 'Mortsel', provincie: 'Antwerpen', land: 'België',
    status: 'actief', createdAt: '2018-03-25', updatedAt: '2024-11-18',
    contractCount: 2,
    relaties: [
      { persoonId: 'P-2024-0016', naam: 'Vandenberghe, Ann', relatie: 'Partner', contractenGedeeld: 2 },
    ],
    geschiedenis: [
      { datum: '18/11/2024 11:30', gebruiker: 'Systeem', actie: 'Herinnering verstuurd', details: 'Contract vervalt binnen 30 dagen' },
      { datum: '25/03/2018 09:00', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Persoon geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0016', type: 'natuurlijk', voornaam: 'Sofie', achternaam: 'Claes',
    rrn: '88.10.11-567.89', geboortedatum: '1988-10-11', geslacht: 'V',
    geboorteplaats: 'Hasselt', nationaliteit: 'Belg', burgerlijkeStaat: 'Ongehuwd', taal: 'Nederlands', beroep: 'Onderzoeker',
    email: 'sofie.claes@email.be', telefoon: '0479/34.56.78',
    adres: 'Bosstraat 21', postcode: '3500', gemeente: 'Hasselt', provincie: 'Limburg', land: 'België',
    status: 'actief', createdAt: '2022-08-14', updatedAt: '2024-12-11',
    contractCount: 3,
    relaties: [],
    geschiedenis: [
      { datum: '11/12/2024 14:00', gebruiker: 'Pieter Janssens', actie: 'Bewerkt', details: 'Telefoonnummer gewijzigd' },
      { datum: '14/08/2022 10:30', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Persoon geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0017', type: 'rechtspersoon', voornaam: '', achternaam: '', naam: 'Wonen Plus CVBA',
    rrn: 'BE 0501.234.567', geboortedatum: '', geslacht: 'X',
    website: 'www.wonenplus.be',
    email: 'info@wonenplus.be', telefoon: '09/345.67.89',
    adres: 'Sint-Pietersnieuwstraat 77', postcode: '9000', gemeente: 'Gent', provincie: 'Oost-Vlaanderen', land: 'België',
    status: 'actief', createdAt: '2017-05-20', updatedAt: '2024-11-22',
    contractCount: 7,
    contactPersonen: [
      { naam: 'Pieter De Sutter', functie: 'Voorzitter', telefoon: '0480/12.34.56', email: 'pieter@wonenplus.be' },
    ],
    geschiedenis: [
      { datum: '22/11/2024 10:00', gebruiker: 'Systeem', actie: 'Contract verlengd', details: 'Woningverzekeringen verlengd' },
      { datum: '20/05/2017 09:00', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'CVBA geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0018', type: 'natuurlijk', voornaam: 'Dirk', achternaam: 'Verhoeven',
    rrn: '74.04.02-678.90', geboortedatum: '1974-04-02', geslacht: 'M',
    geboorteplaats: 'Mechelen', nationaliteit: 'Belg', burgerlijkeStaat: 'Gehuwd', taal: 'Nederlands', beroep: 'Ingenieur',
    email: 'dirk.verhoeven@email.be', telefoon: '0470/45.67.89',
    adres: 'Kerkstraat 9', postcode: '2800', gemeente: 'Mechelen', provincie: 'Antwerpen', land: 'België',
    status: 'actief', createdAt: '2021-01-10', updatedAt: '2024-12-01',
    contractCount: 3,
    relaties: [
      { persoonId: 'P-2024-0019', naam: 'Verhoeven, Els', relatie: 'Partner', contractenGedeeld: 2 },
    ],
    geschiedenis: [
      { datum: '01/12/2024 09:30', gebruiker: 'Marie Dubois', actie: 'Bewerkt', details: 'Nieuwe autoverzekering' },
      { datum: '10/01/2021 11:00', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'Persoon geregistreerd' },
    ],
  },
  {
    id: 'P-2024-0019', type: 'natuurlijk', voornaam: 'Nathalie', achternaam: 'Bosmans',
    rrn: '92.08.15-789.01', geboortedatum: '1992-08-15', geslacht: 'V',
    geboorteplaats: 'Mechelen', nationaliteit: 'Belg', burgerlijkeStaat: 'Ongehuwd', taal: 'Nederlands', beroep: 'Grafisch ontwerper',
    email: 'nathalie.bosmans@email.be', telefoon: '0471/56.78.90',
    adres: 'Adegemstraat 31', postcode: '2800', gemeente: 'Mechelen', provincie: 'Antwerpen', land: 'België',
    status: 'prospect', createdAt: '2024-10-05', updatedAt: '2024-12-10',
    contractCount: 0,
    relaties: [],
    geschiedenis: [
      { datum: '10/12/2024 11:00', gebruiker: 'Systeem', actie: 'Herinnering', details: 'Offerte opvolging' },
      { datum: '05/10/2024 14:00', gebruiker: 'Marie Dubois', actie: 'Aangemaakt', details: 'Prospect via website' },
    ],
  },
  {
    id: 'P-2024-0020', type: 'rechtspersoon', voornaam: '', achternaam: '', naam: 'AutoVloot Beheer BV',
    rrn: 'BE 0734.567.891', geboortedatum: '', geslacht: 'X',
    website: 'www.autovloot.be',
    email: 'info@autovloot.be', telefoon: '03/456.78.90',
    adres: 'Noorderlaan 150', postcode: '2030', gemeente: 'Antwerpen', provincie: 'Antwerpen', land: 'België',
    status: 'actief', createdAt: '2020-02-15', updatedAt: '2024-12-04',
    contractCount: 9,
    contactPersonen: [
      { naam: 'Tom Wouters', functie: 'Fleet Manager', telefoon: '0473/78.90.12', email: 'tom@autovloot.be' },
      { naam: 'Sara Janssens', functie: 'Administratief', telefoon: '0474/89.01.23', email: 'sara@autovloot.be' },
    ],
    geschiedenis: [
      { datum: '04/12/2024 15:00', gebruiker: 'Pieter Janssens', actie: 'Contract uitgebreid', details: '3 nieuwe voertuigen toegevoegd' },
      { datum: '15/02/2020 10:00', gebruiker: 'Admin', actie: 'Aangemaakt', details: 'BV geregistreerd' },
    ],
  },
]

// Person contract links
export interface PersonContract {
  id: string
  contractnummer: string
  type: string
  status: string
  vervaldatum: string
  premie: string
  verzekerde: string
  personId: string
}

export const personContracts: PersonContract[] = [
  { id: 'PC-001', contractnummer: '#VC-2024-004892', type: 'Auto Omnium', status: 'actief', vervaldatum: '15/06/2025', premie: '€ 1.240', verzekerde: 'Peeters, Jan', personId: 'P-2024-0001' },
  { id: 'PC-002', contractnummer: '#VC-2024-003721', type: 'Woning', status: 'actief', vervaldatum: '01/03/2025', premie: '€ 890', verzekerde: 'Peeters, Jan', personId: 'P-2024-0001' },
  { id: 'PC-003', contractnummer: '#VC-2023-002156', type: 'BA', status: 'actief', vervaldatum: '22/09/2025', premie: '€ 450', verzekerde: 'Peeters, Jan', personId: 'P-2024-0001' },
  { id: 'PC-004', contractnummer: '#VC-2024-004893', type: 'Auto Omnium', status: 'actief', vervaldatum: '20/08/2025', premie: '€ 1.560', verzekerde: 'Dubois, Marie', personId: 'P-2024-0002' },
  { id: 'PC-005', contractnummer: '#VC-2024-004894', type: 'Woning', status: 'actief', vervaldatum: '10/02/2025', premie: '€ 720', verzekerde: 'Dubois, Marie', personId: 'P-2024-0002' },
  { id: 'PC-006', contractnummer: '#VC-2024-004895', type: 'Leven', status: 'actief', vervaldatum: '15/04/2034', premie: '€ 320', verzekerde: 'Dubois, Marie', personId: 'P-2024-0002' },
  { id: 'PC-007', contractnummer: '#VC-2024-004896', type: 'Hospitalisatie', status: 'actief', vervaldatum: '01/01/2025', premie: '€ 1.850', verzekerde: 'Janssens, Pieter', personId: 'P-2024-0003' },
  { id: 'PC-008', contractnummer: '#VC-2024-004897', type: 'Auto BA', status: 'actief', vervaldatum: '12/11/2025', premie: '€ 580', verzekerde: 'Janssens, Pieter', personId: 'P-2024-0003' },
  { id: 'PC-009', contractnummer: '#VC-2024-005101', type: 'Vlootverzekering', status: 'actief', vervaldatum: '01/06/2025', premie: '€ 8.500', verzekerde: 'De Boer BVBA', personId: 'P-2024-0006' },
  { id: 'PC-010', contractnummer: '#VC-2024-005102', type: 'BA Bedrijf', status: 'actief', vervaldatum: '15/09/2025', premie: '€ 2.400', verzekerde: 'De Boer BVBA', personId: 'P-2024-0006' },
  { id: 'PC-011', contractnummer: '#VC-2024-005103', type: 'Arbeidsongevallen', status: 'actief', vervaldatum: '01/01/2025', premie: '€ 1.800', verzekerde: 'De Boer BVBA', personId: 'P-2024-0006' },
]

// Cities for filter
export const cities = [
  'Mechelen', 'Brussel', 'Gent', 'Hasselt', 'Leuven', 'Antwerpen', 'Brugge',
  'Namen', 'Luik', 'Kortrijk', 'Oostende', 'Ternat', 'Heverlee', 'Dilbeek',
  'Herentals', 'Mortsel', 'Watermaal-Bosvoorde', 'Zaventem',
]

// Stats
export const personenStats = {
  totaal: 2856,
  natuurlijkePersonen: 2312,
  rechtspersonen: 544,
  nieuweDitKwartaal: 132,
}
