from pathlib import Path
from .pipeline import load_beneficiary_data, validate_beneficiary_data, transform_data
root = Path(__file__).parents[1]
df = load_beneficiary_data(root / 'data' / 'beneficiaries.csv')
validate_beneficiary_data(df)
values, _ = transform_data(df)
print(f'validated {len(df)} beneficiaries; transformed shape={values.shape}')
