/*
 * Class        : Wrapper
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Aug 20, 2013
 * Objective    : Generic Outer Wrapper class that contains specific inner wrapper classes
*/
public with sharing class Wrapper {
    
    //Wrapper for Search Filters
    public class SearchFilterWrapper {
        public List<Selectoption> objFields{get;set;}
        public List<Selectoption> operators{get; set;}
        public List<Selectoption> logicalOps{get; set;}
        public String value{get; set;}
        public String lookupValue{get; set;}
        public String lookupId{get; set;}
        public String lookupType{get; set;}
        public String selectedField{get; set;}
        public String selectedOperator{get; set;}
        public String selectedLogicalOp{get; set;}
        public Boolean freeTextField{
            get{
                if(freeTextField == null)
                    return true;
                return freeTextField;   
            }
            set;
        }
        public List<Selectoption> picklistValues{get; set;}
        public String selectedPicklistValue{get; set;}
        public List<String> selectedMultiPicklistValues{get; set;}
        public String fieldType{get;set;}
        public String errorMsg{get;set;}
        public CustomSearch__c customSearch{
            get{
                if(customSearch == null)
                    customSearch = new CustomSearch__c();
                return customSearch;
            }
            set;
        }
        
        public SearchFilterWrapper(List<Selectoption> objFields, List<Selectoption> operators, String value, List<Selectoption> logicalOps){
            this.objFields = objFields;
            this.operators = operators;
            this.value = value;
            this.logicalOps = logicalOps;
        }
    }
    
    //Wrapper for Projects
    public class ProjectWrapper {
        public Boolean isSelected{get; set;}
        public Project__c project{get;set;}
        
        public ProjectWrapper(Project__c project, Boolean isSelected){
            this.project = project;
            this.isSelected = isSelected;
        }
    }
    
    //Wrapper for ExchangeRates
    public class ExchangeRateWrapper {
        public String convertFrom{get;set;}
        public Date exchangeRateDate{get;set;}
        public Id localCurrency{get;set;}
        public Sobject sObj{get;set;}
        
        public ExchangeRateWrapper(String convertFrom, Id localCurrency, Date exchangeRateDate, SObject sObj){
            this.convertFrom = convertFrom;
            this.localCurrency = localCurrency;
            this.exchangeRateDate = exchangeRateDate;
            this.sObj = sObj;
        }
    }   
}