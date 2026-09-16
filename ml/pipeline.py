from pathlib import Path
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler

BENEFICIARY_COLUMNS = ['beneficiary_id','age','income','location','social_category','education','business_type','loan_purpose','project_cost','required_loan_amount']
SCHEME_COLUMNS = ['scheme_id','scheme_name','min_age','max_age','max_income','social_categories','locations','education_requirements','business_types','loan_purposes','min_loan_amount','max_loan_amount','interest_rate','source_reference']
SCHEME_MASTER_COLUMNS = ['scheme_id','scheme_name','minimum_age','maximum_age','income_max','social_categories','state','education','business_type','supported_purposes','loan_amount_min','loan_amount_max','interest_rate','source_reference']
NUMERIC = ['age','income','project_cost','required_loan_amount']
CATEGORICAL = ['location','social_category','education','business_type','loan_purpose']

def load_beneficiary_data(path): return pd.read_csv(path)
def load_scheme_data(path):
    """Load the canonical schemes_master.csv source and normalize its contract."""
    raw = pd.read_csv(path)
    missing = [c for c in SCHEME_MASTER_COLUMNS if c not in raw.columns]
    if missing: raise ValueError(f'scheme master missing required columns: {missing}')
    normalized = raw.rename(columns={'minimum_age':'min_age','maximum_age':'max_age','income_max':'max_income','state':'locations','education':'education_requirements','business_type':'business_types','supported_purposes':'loan_purposes','loan_amount_min':'min_loan_amount','loan_amount_max':'max_loan_amount'})
    return normalized

def _validate(df, required, name):
    missing = [c for c in required if c not in df.columns]
    if missing: raise ValueError(f'{name} missing required columns: {missing}')
    for c in NUMERIC if name == 'beneficiary' else ['min_age','max_age','max_income','min_loan_amount','max_loan_amount','interest_rate']:
        if c in df and not pd.api.types.is_numeric_dtype(df[c]): raise TypeError(f'{name}.{c} must be numeric')
    if name == 'beneficiary':
        for c in ['age','income','project_cost','required_loan_amount']:
            if c in df and (df[c].dropna() < 0).any(): raise ValueError(f'{name}.{c} cannot be negative')
    else:
        if df['scheme_id'].isna().any() or (df['scheme_id'].astype(str).str.strip() == '').any(): raise ValueError('scheme.scheme_id cannot be empty')
        bad = (df['min_loan_amount'].notna() & df['max_loan_amount'].notna() & (df['min_loan_amount'] > df['max_loan_amount']))
        if bad.any(): raise ValueError('scheme loan range is invalid')
    return True

def validate_beneficiary_data(df): return _validate(df, BENEFICIARY_COLUMNS, 'beneficiary')
def validate_scheme_data(df): return _validate(df, SCHEME_COLUMNS, 'scheme')

def build_preprocessor():
    return ColumnTransformer([('numeric', Pipeline([('impute', SimpleImputer(strategy='median')), ('scale', StandardScaler())]), NUMERIC), ('categorical', Pipeline([('impute', SimpleImputer(strategy='most_frequent')), ('encode', OneHotEncoder(handle_unknown='ignore', sparse_output=False))]), CATEGORICAL)])

def transform_data(df, preprocessor=None, fit=True):
    validate_beneficiary_data(df)
    p = preprocessor or build_preprocessor()
    values = p.fit_transform(df) if fit else p.transform(df)
    return values, p

def transform_with_fitted_preprocessor(df, preprocessor):
    """Transform a later split using a preprocessor fitted on training data."""
    return transform_data(df, preprocessor=preprocessor, fit=False)[0]

def split_data(df, train_ratio=.7, validation_ratio=.15, seed=42):
    if train_ratio <= 0 or validation_ratio < 0 or train_ratio + validation_ratio >= 1: raise ValueError('ratios must leave a positive test split')
    shuffled = df.sample(frac=1, random_state=seed)
    n = len(shuffled); a = int(n * train_ratio); b = a + int(n * validation_ratio)
    return shuffled.iloc[:a].reset_index(drop=True), shuffled.iloc[a:b].reset_index(drop=True), shuffled.iloc[b:].reset_index(drop=True)
