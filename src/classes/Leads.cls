public class Leads extends fflib_SObjectDomain {
    
    public Leads(List<Lead> sObjectList) {
        // Domain classes are initialised with lists to enforce bulkification throughout
        super(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Leads(sObjectList);
        }
    }
    
    public override void onApplyDefaults() {}
    
    public override void onValidate() {}
    
    public override void onValidate(Map<Id,SObject> existingRecords) {}
    
    public override void onBeforeInsert() {}
    
    public override void onAfterInsert() {}
    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {}
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {}
    
}