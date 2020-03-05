public class DiagnosisWrapper {
    public String conditionDescription{get;set;}
    public String icdCode { get; set; }
    public String pcdOrIcd { get; set; }
    public String valueSelectedICD { get; set; }
    public String valueSelectedPCD { get; set; }
    public String shortDescription { get; set; }
    public String conditionDescriptionObject { get; set; }
    public Double externalId { get; set; }
    public Boolean isEligible { get; set; }
    public Boolean isGroup1Rec { get; set; }
    public List<MedicalWrapper> medicalWrapperList { get; set; }

    public DiagnosisWrapper(){
        isEligible = false;
        isGroup1Rec = false;
        medicalWrapperList = new List<MedicalWrapper>();
    }

    public class MedicalWrapper{
        public List<SelectOption> pickVals { get; set; }
        public List<SelectOption> epilepsyPickVals { get; set; }
        public Medical_Questions__c medicalQuestion { get; set; }
        public String selectedPickVal { get; set; }
        public String epilepsySelectedPickVal { get; set; }
        public String reasonForNeed { get; set; }
        public Boolean isEligible { get; set; }

        public MedicalWrapper() {
            isEligible = false;
            pickVals = new List<SelectOption>();
            epilepsyPickVals = new List<SelectOption>();
            medicalQuestion = new Medical_Questions__c();
        }
    }
}