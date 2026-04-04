import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String customerCode;
  final String businessName;
  final String businessType; // pharmacy, hospital, clinic, wholesaler, retailer
  final String legalName;
  final String tradeLicenseNumber;
  final String taxRegistrationNumber;
  final String drugLicenseNumber;
  final String contactPerson;
  final String contactEmail;
  final String contactPhone;
  final String alternativeContactPhone;
  final String website;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String region;
  final String territory;
  final List<String> specializations;
  final List<String> productCategories;
  final String customerTier; // platinum, gold, silver, bronze
  final String status; // active, inactive, suspended, blacklisted
  final DateTime registrationDate;
  final DateTime? lastPurchaseDate;
  final DateTime? lastContactDate;
  final double totalPurchases;
  final int totalOrders;
  final double averageOrderValue;
  final double creditLimit;
  final double currentCredit;
  final String paymentTerms;
  final String paymentMethod;
  final List<String> paymentMethods;
  final double outstandingBalance;
  final int overdueDays;
  final String creditRating; // excellent, good, average, poor
  final List<CustomerContact> contacts;
  final List<String> documents;
  final List<CustomerNote> notes;
  final List<String> tags;
  final String assignedSalesRepId;
  final String assignedSalesRepName;
  final Map<String, dynamic> preferences;
  final List<String> preferredProducts;
  final List<String> blacklistedProducts;
  final double discountRate;
  final bool isTaxExempt;
  final String? taxExemptionNumber;
  final String deliveryInstructions;
  final String operatingHours;
  final List<String> certifications;
  final List<String> licenses;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.customerCode,
    required this.businessName,
    required this.businessType,
    required this.legalName,
    required this.tradeLicenseNumber,
    required this.taxRegistrationNumber,
    required this.drugLicenseNumber,
    required this.contactPerson,
    required this.contactEmail,
    required this.contactPhone,
    this.alternativeContactPhone,
    this.website,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.region,
    required this.territory,
    required this.specializations,
    required this.productCategories,
    required this.customerTier,
    required this.status,
    required this.registrationDate,
    this.lastPurchaseDate,
    this.lastContactDate,
    required this.totalPurchases,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.creditLimit,
    required this.currentCredit,
    required this.paymentTerms,
    required this.paymentMethod,
    required this.paymentMethods,
    required this.outstandingBalance,
    required this.overdueDays,
    required this.creditRating,
    required this.contacts,
    required this.documents,
    required this.notes,
    required this.tags,
    required this.assignedSalesRepId,
    required this.assignedSalesRepName,
    required this.preferences,
    required this.preferredProducts,
    required this.blacklistedProducts,
    required this.discountRate,
    required this.isTaxExempt,
    this.taxExemptionNumber,
    required this.deliveryInstructions,
    required this.operatingHours,
    required this.certifications,
    required this.licenses,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      customerCode: json['customerCode'] ?? '',
      businessName: json['businessName'] ?? '',
      businessType: json['businessType'] ?? '',
      legalName: json['legalName'] ?? '',
      tradeLicenseNumber: json['tradeLicenseNumber'] ?? '',
      taxRegistrationNumber: json['taxRegistrationNumber'] ?? '',
      drugLicenseNumber: json['drugLicenseNumber'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      alternativeContactPhone: json['alternativeContactPhone'],
      website: json['website'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      region: json['region'] ?? '',
      territory: json['territory'] ?? '',
      specializations: List<String>.from(json['specializations'] ?? []),
      productCategories: List<String>.from(json['productCategories'] ?? []),
      customerTier: json['customerTier'] ?? 'bronze',
      status: json['status'] ?? 'active',
      registrationDate: DateTime.parse(json['registrationDate'] ?? DateTime.now().toIso8601String()),
      lastPurchaseDate: json['lastPurchaseDate'] != null
          ? DateTime.parse(json['lastPurchaseDate'])
          : null,
      lastContactDate: json['lastContactDate'] != null
          ? DateTime.parse(json['lastContactDate'])
          : null,
      totalPurchases: (json['totalPurchases'] ?? 0.0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      averageOrderValue: (json['averageOrderValue'] ?? 0.0).toDouble(),
      creditLimit: (json['creditLimit'] ?? 0.0).toDouble(),
      currentCredit: (json['currentCredit'] ?? 0.0).toDouble(),
      paymentTerms: json['paymentTerms'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentMethods: List<String>.from(json['paymentMethods'] ?? []),
      outstandingBalance: (json['outstandingBalance'] ?? 0.0).toDouble(),
      overdueDays: json['overdueDays'] ?? 0,
      creditRating: json['creditRating'] ?? 'average',
      contacts: (json['contacts'] as List?)
              ?.map((contact) => CustomerContact.fromJson(contact))
              .toList() ??
          [],
      documents: List<String>.from(json['documents'] ?? []),
      notes: (json['notes'] as List?)
              ?.map((note) => CustomerNote.fromJson(note))
              .toList() ??
          [],
      tags: List<String>.from(json['tags'] ?? []),
      assignedSalesRepId: json['assignedSalesRepId'] ?? '',
      assignedSalesRepName: json['assignedSalesRepName'] ?? '',
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      preferredProducts: List<String>.from(json['preferredProducts'] ?? []),
      blacklistedProducts: List<String>.from(json['blacklistedProducts'] ?? []),
      discountRate: (json['discountRate'] ?? 0.0).toDouble(),
      isTaxExempt: json['isTaxExempt'] ?? false,
      taxExemptionNumber: json['taxExemptionNumber'],
      deliveryInstructions: json['deliveryInstructions'] ?? '',
      operatingHours: json['operatingHours'] ?? '',
      certifications: List<String>.from(json['certifications'] ?? []),
      licenses: List<String>.from(json['licenses'] ?? []),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerCode': customerCode,
      'businessName': businessName,
      'businessType': businessType,
      'legalName': legalName,
      'tradeLicenseNumber': tradeLicenseNumber,
      'taxRegistrationNumber': taxRegistrationNumber,
      'drugLicenseNumber': drugLicenseNumber,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'alternativeContactPhone': alternativeContactPhone,
      'website': website,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'region': region,
      'territory': territory,
      'specializations': specializations,
      'productCategories': productCategories,
      'customerTier': customerTier,
      'status': status,
      'registrationDate': registrationDate.toIso8601String(),
      'lastPurchaseDate': lastPurchaseDate?.toIso8601String(),
      'lastContactDate': lastContactDate?.toIso8601String(),
      'totalPurchases': totalPurchases,
      'totalOrders': totalOrders,
      'averageOrderValue': averageOrderValue,
      'creditLimit': creditLimit,
      'currentCredit': currentCredit,
      'paymentTerms': paymentTerms,
      'paymentMethod': paymentMethod,
      'paymentMethods': paymentMethods,
      'outstandingBalance': outstandingBalance,
      'overdueDays': overdueDays,
      'creditRating': creditRating,
      'contacts': contacts.map((contact) => contact.toJson()).toList(),
      'documents': documents,
      'notes': notes.map((note) => note.toJson()).toList(),
      'tags': tags,
      'assignedSalesRepId': assignedSalesRepId,
      'assignedSalesRepName': assignedSalesRepName,
      'preferences': preferences,
      'preferredProducts': preferredProducts,
      'blacklistedProducts': blacklistedProducts,
      'discountRate': discountRate,
      'isTaxExempt': isTaxExempt,
      'taxExemptionNumber': taxExemptionNumber,
      'deliveryInstructions': deliveryInstructions,
      'operatingHours': operatingHours,
      'certifications': certifications,
      'licenses': licenses,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isSuspended => status == 'suspended';
  bool get isBlacklisted => status == 'blacklisted';
  
  bool get isOverdue => overdueDays > 0;
  bool get hasOutstandingBalance => outstandingBalance > 0;
  bool get isCreditLimitReached => currentCredit >= creditLimit;
  bool get hasAvailableCredit => currentCredit < creditLimit;
  
  double get creditUtilization => creditLimit > 0 ? (currentCredit / creditLimit) * 100 : 0;
  bool get isHighRisk => creditUtilization >= 80 || isOverdue;
  
  bool get isRecentCustomer => DateTime.now().difference(registrationDate).inDays <= 30;
  bool get isRegularCustomer => totalOrders >= 5;
  bool get isVIPCustomer => customerTier == 'platinum' || customerTier == 'gold';
  
  int get daysSinceLastPurchase => lastPurchaseDate != null
      ? DateTime.now().difference(lastPurchaseDate!).inDays
      : -1;
  int get daysSinceLastContact => lastContactDate != null
      ? DateTime.now().difference(lastContactDate!).inDays
      : -1;
  
  bool get needsFollowUp => daysSinceLastContact > 30 || (daysSinceLastPurchase > 90 && isRegularCustomer);

  @override
  List<Object?> get props => [
        id,
        customerCode,
        businessName,
        businessType,
        legalName,
        tradeLicenseNumber,
        taxRegistrationNumber,
        drugLicenseNumber,
        contactPerson,
        contactEmail,
        contactPhone,
        alternativeContactPhone,
        website,
        address,
        city,
        state,
        country,
        postalCode,
        region,
        territory,
        specializations,
        productCategories,
        customerTier,
        status,
        registrationDate,
        lastPurchaseDate,
        lastContactDate,
        totalPurchases,
        totalOrders,
        averageOrderValue,
        creditLimit,
        currentCredit,
        paymentTerms,
        paymentMethod,
        paymentMethods,
        outstandingBalance,
        overdueDays,
        creditRating,
        contacts,
        documents,
        notes,
        tags,
        assignedSalesRepId,
        assignedSalesRepName,
        preferences,
        preferredProducts,
        blacklistedProducts,
        discountRate,
        isTaxExempt,
        taxExemptionNumber,
        deliveryInstructions,
        operatingHours,
        certifications,
        licenses,
        notes,
        createdAt,
        updatedAt,
      ];
}

class CustomerContact extends Equatable {
  final String id;
  final String name;
  final String position;
  final String department;
  final String email;
  final String phone;
  final String mobile;
  final bool isPrimary;
  final bool isDecisionMaker;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerContact({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.email,
    required this.phone,
    this.mobile,
    this.isPrimary = false,
    this.isDecisionMaker = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerContact.fromJson(Map<String, dynamic> json) {
    return CustomerContact(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      department: json['department'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      mobile: json['mobile'],
      isPrimary: json['isPrimary'] ?? false,
      isDecisionMaker: json['isDecisionMaker'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'department': department,
      'email': email,
      'phone': phone,
      'mobile': mobile,
      'isPrimary': isPrimary,
      'isDecisionMaker': isDecisionMaker,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        position,
        department,
        email,
        phone,
        mobile,
        isPrimary,
        isDecisionMaker,
        notes,
        createdAt,
        updatedAt,
      ];
}

class CustomerNote extends Equatable {
  final String id;
  final String customerId;
  final String title;
  final String content;
  final String type; // call, email, meeting, follow_up, complaint, inquiry
  final String priority; // low, medium, high, urgent
  final String createdBy;
  final String createdByName;
  final DateTime noteDate;
  final DateTime? followUpDate;
  final String? followUpAction;
  final bool isCompleted;
  final List<String> attachments;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerNote({
    required this.id,
    required this.customerId,
    required this.title,
    required this.content,
    required this.type,
    required this.priority,
    required this.createdBy,
    required this.createdByName,
    required this.noteDate,
    this.followUpDate,
    this.followUpAction,
    this.isCompleted = false,
    this.attachments = const [],
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerNote.fromJson(Map<String, dynamic> json) {
    return CustomerNote(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      priority: json['priority'] ?? 'medium',
      createdBy: json['createdBy'] ?? '',
      createdByName: json['createdByName'] ?? '',
      noteDate: DateTime.parse(json['noteDate'] ?? DateTime.now().toIso8601String()),
      followUpDate: json['followUpDate'] != null
          ? DateTime.parse(json['followUpDate'])
          : null,
      followUpAction: json['followUpAction'],
      isCompleted: json['isCompleted'] ?? false,
      attachments: List<String>.from(json['attachments'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'title': title,
      'content': content,
      'type': type,
      'priority': priority,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'noteDate': noteDate.toIso8601String(),
      'followUpDate': followUpDate?.toIso8601String(),
      'followUpAction': followUpAction,
      'isCompleted': isCompleted,
      'attachments': attachments,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isOverdue => followUpDate != null && !isCompleted && DateTime.now().isAfter(followUpDate!);
  bool get isUrgent => priority == 'urgent' || priority == 'high';
  bool get needsFollowUp => followUpDate != null && !isCompleted;

  @override
  List<Object?> get props => [
        id,
        customerId,
        title,
        content,
        type,
        priority,
        createdBy,
        createdByName,
        noteDate,
        followUpDate,
        followUpAction,
        isCompleted,
        attachments,
        tags,
        createdAt,
        updatedAt,
      ];
}

class Lead extends Equatable {
  final String id;
  final String leadNumber;
  final String companyName;
  final String contactPerson;
  final String contactEmail;
  final String contactPhone;
  final String businessType;
  final String source; // website, referral, cold_call, trade_show, advertising, social_media
  final String status; // new, contacted, qualified, converted, lost, archived
  final String priority; // low, medium, high, urgent
  final String assignedTo;
  final String assignedToName;
  final String productInterest;
  final List<String> productCategories;
  final double estimatedValue;
  final String budgetRange;
  final String timeline; // immediate, within_1_month, within_3_months, within_6_months, future
  final String decisionMaker;
  final String decisionMakerContact;
  final String requirements;
  final String painPoints;
  final String currentSolution;
  final List<LeadActivity> activities;
  final List<LeadNote> notes;
  final DateTime creationDate;
  final DateTime? lastContactDate;
  final DateTime? followUpDate;
  final DateTime? conversionDate;
  final String? conversionReason;
  final String? lostReason;
  final double conversionProbability;
  final List<String> tags;
  final Map<String, dynamic> customFields;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Lead({
    required this.id,
    required this.leadNumber,
    required this.companyName,
    required this.contactPerson,
    required this.contactEmail,
    required this.contactPhone,
    required this.businessType,
    required this.source,
    required this.status,
    required this.priority,
    required this.assignedTo,
    required this.assignedToName,
    required this.productInterest,
    required this.productCategories,
    required this.estimatedValue,
    required this.budgetRange,
    required this.timeline,
    required this.decisionMaker,
    required this.decisionMakerContact,
    required this.requirements,
    required this.painPoints,
    required this.currentSolution,
    required this.activities,
    required this.notes,
    required this.creationDate,
    this.lastContactDate,
    this.followUpDate,
    this.conversionDate,
    this.conversionReason,
    this.lostReason,
    required this.conversionProbability,
    required this.tags,
    required this.customFields,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] ?? '',
      leadNumber: json['leadNumber'] ?? '',
      companyName: json['companyName'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      businessType: json['businessType'] ?? '',
      source: json['source'] ?? '',
      status: json['status'] ?? 'new',
      priority: json['priority'] ?? 'medium',
      assignedTo: json['assignedTo'] ?? '',
      assignedToName: json['assignedToName'] ?? '',
      productInterest: json['productInterest'] ?? '',
      productCategories: List<String>.from(json['productCategories'] ?? []),
      estimatedValue: (json['estimatedValue'] ?? 0.0).toDouble(),
      budgetRange: json['budgetRange'] ?? '',
      timeline: json['timeline'] ?? '',
      decisionMaker: json['decisionMaker'] ?? '',
      decisionMakerContact: json['decisionMakerContact'] ?? '',
      requirements: json['requirements'] ?? '',
      painPoints: json['painPoints'] ?? '',
      currentSolution: json['currentSolution'] ?? '',
      activities: (json['activities'] as List?)
              ?.map((activity) => LeadActivity.fromJson(activity))
              .toList() ??
          [],
      notes: (json['notes'] as List?)
              ?.map((note) => LeadNote.fromJson(note))
              .toList() ??
          [],
      creationDate: DateTime.parse(json['creationDate'] ?? DateTime.now().toIso8601String()),
      lastContactDate: json['lastContactDate'] != null
          ? DateTime.parse(json['lastContactDate'])
          : null,
      followUpDate: json['followUpDate'] != null
          ? DateTime.parse(json['followUpDate'])
          : null,
      conversionDate: json['conversionDate'] != null
          ? DateTime.parse(json['conversionDate'])
          : null,
      conversionReason: json['conversionReason'],
      lostReason: json['lostReason'],
      conversionProbability: (json['conversionProbability'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leadNumber': leadNumber,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'businessType': businessType,
      'source': source,
      'status': status,
      'priority': priority,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'productInterest': productInterest,
      'productCategories': productCategories,
      'estimatedValue': estimatedValue,
      'budgetRange': budgetRange,
      'timeline': timeline,
      'decisionMaker': decisionMaker,
      'decisionMakerContact': decisionMakerContact,
      'requirements': requirements,
      'painPoints': painPoints,
      'currentSolution': currentSolution,
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'notes': notes.map((note) => note.toJson()).toList(),
      'creationDate': creationDate.toIso8601String(),
      'lastContactDate': lastContactDate?.toIso8601String(),
      'followUpDate': followUpDate?.toIso8601String(),
      'conversionDate': conversionDate?.toIso8601String(),
      'conversionReason': conversionReason,
      'lostReason': lostReason,
      'conversionProbability': conversionProbability,
      'tags': tags,
      'customFields': customFields,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Computed properties
  bool get isNew => status == 'new';
  bool get isContacted => status == 'contacted';
  bool get isQualified => status == 'qualified';
  bool get isConverted => status == 'converted';
  bool get isLost => status == 'lost';
  bool get isArchived => status == 'archived';
  
  bool get isHotLead => priority == 'urgent' || priority == 'high';
  bool get needsFollowUp => followUpDate != null && DateTime.now().isAfter(followUpDate!);
  bool get isStale => lastContactDate != null && 
      DateTime.now().difference(lastContactDate!).inDays > 30;
  
  int get daysSinceCreation => DateTime.now().difference(creationDate).inDays;
  int get daysSinceLastContact => lastContactDate != null
      ? DateTime.now().difference(lastContactDate!).inDays
      : -1;

  @override
  List<Object?> get props => [
        id,
        leadNumber,
        companyName,
        contactPerson,
        contactEmail,
        contactPhone,
        businessType,
        source,
        status,
        priority,
        assignedTo,
        assignedToName,
        productInterest,
        productCategories,
        estimatedValue,
        budgetRange,
        timeline,
        decisionMaker,
        decisionMakerContact,
        requirements,
        painPoints,
        currentSolution,
        activities,
        notes,
        creationDate,
        lastContactDate,
        followUpDate,
        conversionDate,
        conversionReason,
        lostReason,
        conversionProbability,
        tags,
        customFields,
        createdAt,
        updatedAt,
      ];
}

class LeadActivity extends Equatable {
  final String id;
  final String leadId;
  final String type; // call, email, meeting, demo, proposal, follow_up
  final String title;
  final String description;
  final String performedBy;
  final String performedByName;
  final DateTime activityDate;
  final Duration duration;
  final String? outcome;
  final String? nextAction;
  final DateTime? nextActionDate;
  final List<String> attachments;
  final DateTime createdAt;

  const LeadActivity({
    required this.id,
    required this.leadId,
    required this.type,
    required this.title,
    required this.description,
    required this.performedBy,
    required this.performedByName,
    required this.activityDate,
    required this.duration,
    this.outcome,
    this.nextAction,
    this.nextActionDate,
    this.attachments = const [],
    required this.createdAt,
  });

  factory LeadActivity.fromJson(Map<String, dynamic> json) {
    return LeadActivity(
      id: json['id'] ?? '',
      leadId: json['leadId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      performedBy: json['performedBy'] ?? '',
      performedByName: json['performedByName'] ?? '',
      activityDate: DateTime.parse(json['activityDate'] ?? DateTime.now().toIso8601String()),
      duration: Duration(hours: json['durationHours'] ?? 0, minutes: json['durationMinutes'] ?? 0),
      outcome: json['outcome'],
      nextAction: json['nextAction'],
      nextActionDate: json['nextActionDate'] != null
          ? DateTime.parse(json['nextActionDate'])
          : null,
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leadId': leadId,
      'type': type,
      'title': title,
      'description': description,
      'performedBy': performedBy,
      'performedByName': performedByName,
      'activityDate': activityDate.toIso8601String(),
      'durationHours': duration.inHours,
      'durationMinutes': duration.inMinutes % 60,
      'outcome': outcome,
      'nextAction': nextAction,
      'nextActionDate': nextActionDate?.toIso8601String(),
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        leadId,
        type,
        title,
        description,
        performedBy,
        performedByName,
        activityDate,
        duration,
        outcome,
        nextAction,
        nextActionDate,
        attachments,
        createdAt,
      ];
}

class LeadNote extends Equatable {
  final String id;
  final String leadId;
  final String title;
  final String content;
  final String createdBy;
  final String createdByName;
  final DateTime noteDate;
  final bool isPrivate;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LeadNote({
    required this.id,
    required this.leadId,
    required this.title,
    required this.content,
    required this.createdBy,
    required this.createdByName,
    required this.noteDate,
    this.isPrivate = false,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeadNote.fromJson(Map<String, dynamic> json) {
    return LeadNote(
      id: json['id'] ?? '',
      leadId: json['leadId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdByName: json['createdByName'] ?? '',
      noteDate: DateTime.parse(json['noteDate'] ?? DateTime.now().toIso8601String()),
      isPrivate: json['isPrivate'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leadId': leadId,
      'title': title,
      'content': content,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'noteDate': noteDate.toIso8601String(),
      'isPrivate': isPrivate,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        leadId,
        title,
        content,
        createdBy,
        createdByName,
        noteDate,
        isPrivate,
        tags,
        createdAt,
        updatedAt,
      ];
}
