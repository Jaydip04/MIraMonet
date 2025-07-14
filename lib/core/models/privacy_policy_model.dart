class PrivacyPolicy {
  bool status;
  List<Policy> policy;
  List<Terms> terms;

  PrivacyPolicy({required this.status, required this.policy, required this.terms});

  factory PrivacyPolicy.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicy(
      status: json['status'],
      policy: (json['policy'] as List).map((e) => Policy.fromJson(e)).toList(),
      terms: (json['terms'] as List).map((e) => Terms.fromJson(e)).toList(),
    );
  }
}

class Policy {
  int privacyPolicyId;
  String heading;
  String role;
  String status;
  String insertedDate;
  String insertedTime;
  List<PolicyPara> policyParas;

  Policy({
    required this.privacyPolicyId,
    required this.heading,
    required this.role,
    required this.status,
    required this.insertedDate,
    required this.insertedTime,
    required this.policyParas,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      privacyPolicyId: json['privacy_policy_id'],
      heading: json['heading'],
      role: json['role'],
      status: json['status'],
      insertedDate: json['inserted_date'],
      insertedTime: json['inserted_time'],
      policyParas: (json['policy_paras'] as List)
          .map((e) => PolicyPara.fromJson(e))
          .toList(),
    );
  }
}

class PolicyPara {
  int privacyPolicyParasId;
  String privacyPolicyId;
  String paragraph;
  String insertedDate;
  String insertedTime;

  PolicyPara({
    required this.privacyPolicyParasId,
    required this.privacyPolicyId,
    required this.paragraph,
    required this.insertedDate,
    required this.insertedTime,
  });

  factory PolicyPara.fromJson(Map<String, dynamic> json) {
    return PolicyPara(
      privacyPolicyParasId: json['privacy_policy_paras_id'],
      privacyPolicyId: json['privacy_policy_id'],
      paragraph: json['paragraph'],
      insertedDate: json['inserted_date'],
      insertedTime: json['inserted_time'],
    );
  }
}

class Terms {
  int termConditionsId;
  String heading;
  String role;
  String status;
  String insertedDate;
  String insertedTime;
  List<TermConditionPara> conditionsParas;

  Terms({
    required this.termConditionsId,
    required this.heading,
    required this.role,
    required this.status,
    required this.insertedDate,
    required this.insertedTime,
    required this.conditionsParas,
  });

  factory Terms.fromJson(Map<String, dynamic> json) {
    return Terms(
      termConditionsId: json['term_conditions_id'],
      heading: json['heading'],
      role: json['role'],
      status: json['status'],
      insertedDate: json['inserted_date'],
      insertedTime: json['inserted_time'],
      conditionsParas: (json['conditions_paras'] as List)
          .map((e) => TermConditionPara.fromJson(e))
          .toList(),
    );
  }
}

class TermConditionPara {
  int termConditionsParasId;
  String termConditionsId;
  String paragraph;
  String insertedDate;
  String insertedTime;

  TermConditionPara({
    required this.termConditionsParasId,
    required this.termConditionsId,
    required this.paragraph,
    required this.insertedDate,
    required this.insertedTime,
  });

  factory TermConditionPara.fromJson(Map<String, dynamic> json) {
    return TermConditionPara(
      termConditionsParasId: json['term_conditions_paras_id'],
      termConditionsId: json['term_conditions_id'],
      paragraph: json['paragraph'],
      insertedDate: json['inserted_date'],
      insertedTime: json['inserted_time'],
    );
  }
}