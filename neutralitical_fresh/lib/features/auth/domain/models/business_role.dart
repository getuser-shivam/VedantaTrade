enum BusinessRole {
  admin,
  medicalRepresentative,
  accountant,
  auditor,
  doctor,
  stockist,
  retailer,
  hospital,
}

extension BusinessRoleX on BusinessRole {
  String get label => switch (this) {
    BusinessRole.admin => 'Admin',
    BusinessRole.medicalRepresentative => 'Medical Representative',
    BusinessRole.accountant => 'Accountant',
    BusinessRole.auditor => 'Auditor',
    BusinessRole.doctor => 'Doctor',
    BusinessRole.stockist => 'Stockist',
    BusinessRole.retailer => 'Retailer',
    BusinessRole.hospital => 'Hospital',
  };

  String get shortLabel => switch (this) {
    BusinessRole.admin => 'Admin',
    BusinessRole.medicalRepresentative => 'MR',
    BusinessRole.accountant => 'Accounts',
    BusinessRole.auditor => 'Audit',
    BusinessRole.doctor => 'Doctor',
    BusinessRole.stockist => 'Stockist',
    BusinessRole.retailer => 'Retailer',
    BusinessRole.hospital => 'Hospital',
  };

  String get description => switch (this) {
    BusinessRole.admin =>
      'Control territories, users, compliance, master data, and executive dashboards.',
    BusinessRole.medicalRepresentative =>
      'Track doctor visits, route plans, samples, retailers, and field productivity.',
    BusinessRole.accountant =>
      'Manage receivables, vouchers, payments, bank flow, and commercial books.',
    BusinessRole.auditor =>
      'Review trail integrity, collections, policy deviations, and audit observations.',
    BusinessRole.doctor =>
      'See visit history, samples, product references, and follow-up commitments.',
    BusinessRole.stockist =>
      'Manage inventory, primary orders, credit, and secondary-sales coordination.',
    BusinessRole.retailer =>
      'Track orders, schemes, supply status, and outstanding balances.',
    BusinessRole.hospital =>
      'Monitor institutional supply, formularies, procurement, and doctor engagement.',
  };

  static BusinessRole fromValue(String? value) {
    return BusinessRole.values.firstWhere(
      (candidate) => candidate.name == value,
      orElse: () => BusinessRole.medicalRepresentative,
    );
  }
}
