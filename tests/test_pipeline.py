import pandas as pd
import pytest
from ml.pipeline import *

def sample(): return pd.DataFrame({'beneficiary_id':['1','2'],'age':[20,30],'income':[1,2],'location':['X','Y'],'social_category':['A','B'],'education':['u',None],'business_type':['b','c'],'loan_purpose':['p','q'],'project_cost':[3,4],'required_loan_amount':[2,3]})
def test_valid_and_missing():
    assert validate_beneficiary_data(sample())
    assert transform_data(sample())[0].shape[0] == 2
def test_invalid_fails():
    x=sample(); x.loc[0,'age']=-1
    with pytest.raises(ValueError): validate_beneficiary_data(x)
def test_deterministic():
    a,_=transform_data(sample()); b,_=transform_data(sample()); assert (a==b).all()
def test_split_deterministic():
    a=split_data(sample()); b=split_data(sample())
    assert all(x.equals(y) for x,y in zip(a,b))

def test_invalid_scheme_range_fails():
    schemes = pd.DataFrame({c: [None] for c in SCHEME_COLUMNS})
    schemes[['scheme_id','scheme_name']] = [['S1','Demo']]
    schemes[['min_loan_amount','max_loan_amount']] = [[100, 50]]
    with pytest.raises(ValueError): validate_scheme_data(schemes)
