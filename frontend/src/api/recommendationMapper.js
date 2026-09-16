const ML_FIELDS = [
  'age',
  'income',
  'location',
  'social_category',
  'education',
  'business_type',
  'loan_purpose',
  'project_cost',
  'required_loan_amount',
];

const optionalNumber = (value) => {
  if (value === null || value === undefined || value === '') return null;
  const number = Number(value);
  return Number.isFinite(number) ? number : null;
};

/** Convert the persisted AppContext shape to the ML API request contract. */
export function toRecommendationRequest(state) {
  const profile = state?.profile || {};
  const requirement = state?.requirement || {};

  // AppContext explicitly stores monthlyIncome. The ML API names this field
  // only `income` and documents no annualization rule, so preserve the entered
  // numeric value instead of inventing a monthly-to-annual conversion.
  const request = {
    age: optionalNumber(profile.age),
    income: optionalNumber(profile.monthlyIncome),
    location: profile.state || profile.district || null,
    social_category: profile.category || null,
    education: profile.education || null,
    business_type: requirement.businessType || profile.business || null,
    loan_purpose: requirement.purpose || null,
    project_cost: optionalNumber(requirement.projectCost),
    required_loan_amount: optionalNumber(requirement.loanAmount),
  };

  return Object.fromEntries(ML_FIELDS.map((field) => [field, request[field]]));
}

