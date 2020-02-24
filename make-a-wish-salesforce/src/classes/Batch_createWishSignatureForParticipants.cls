/**
 * @description Batch Class/Nightly Scheduler to create Wish Required Signature records for Wish Affiliations turning 18.
 * @author Mitali Nahar, Traction on Demand
 * @createdDate 7/23/2019
 */
public with sharing class Batch_createWishSignatureForParticipants implements Database.Batchable<SObject>, Schedulable {

    /**
     * Initiate Batch, find Wish Affiliations
     * @param bc
     * @return
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Get participants turning 18 today on an active Wish
        String APPROVED_PARTICIPANT = Constant_AC.WISH_AFFILIATION_TYPE_APPROVED_PARTICIPANT;
        String WISH_CHILD = Constant_AC.WISH_AFFILIATION_TYPE_WISH_CHILD;
        String query = 'Select Id, Wish__c, Wish__r.ChapterName__c, Contact__r.Email,Wish_Affiliation_Type__c FROM Wish_Affiliation__c' +
                ' WHERE Participant_Turning_18__c = TODAY ' +
                ' AND (Wish_Affiliation_Type__c =: APPROVED_PARTICIPANT OR Wish_Affiliation_Type__c =: WISH_CHILD)' +
                ' AND Wish__c != null' +
                ' AND Wish__r.IsClosed = FALSE' +
                ' AND (Wish__r.Start_Date__c = null OR Wish__r.Start_Date__c >= TODAY )';
        return Database.getQueryLocator(query);
    }

    /**
     * Run Batch
     * @param bc
     * @param scope
     */
    public void execute(Database.BatchableContext bc, List<Wish_Affiliation__c> scope) {
        List<Wish_Required_Signature__c> wrsToInsert = new List<Wish_Required_Signature__c>();
        Set<Id> chapterIds = new Set<Id>();

        Map<Id,Set<Id>> chapterToParticipantForms = new  Map<Id,Set<Id>>();
        Map<Id,Set<Id>> chapterToChildForms = new Map<Id,Set<Id>>();

        Map<Id,Set<Id>> wishAffiliationToFormIdParticipant = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> wishAffiliationToFormIdChild = new Map<Id,Set<Id>>();

        //Get a list of Chapter Ids
        for(Wish_Affiliation__c objWishAff : scope){
            chapterIds.add(objWishAff.Wish__r.ChapterName__c);
       }

        //Get list of Form Ids to send categorized by chapters
        for (Wish_Signature_Chapter_Form__c objForm : [
                SELECT Wish_Signature_Form__c,Chapter_Account__c,Wish_Signature_Form__r.Auto_add_for_Participant__c,Wish_Signature_Form__r.Auto_add_for_Wish_Child__c
                FROM Wish_Signature_Chapter_Form__c
                WHERE Chapter_Account__c IN :chapterIds AND
                (Wish_Signature_Form__r.Auto_add_for_Participant__c = TRUE OR Wish_Signature_Form__r.Auto_add_for_Wish_Child__c = TRUE)
        ]) {
            if (objForm.Wish_Signature_Form__r.Auto_add_for_Participant__c == true) {
                if (!chapterToParticipantForms.containsKey(objForm.Chapter_Account__c)) {
                    chapterToParticipantForms.put(objForm.Chapter_Account__c, new Set<Id>());
                }
                chapterToParticipantForms.get(objForm.Chapter_Account__c).add(objForm.Wish_Signature_Form__c);
            } 
            if(objForm.Wish_Signature_Form__r.Auto_add_for_Wish_Child__c == true){
                if (!chapterToChildForms.containsKey(objForm.Chapter_Account__c)) {
                    chapterToChildForms.put(objForm.Chapter_Account__c, new Set<Id>());
                }
                chapterToChildForms.get(objForm.Chapter_Account__c).add(objForm.Wish_Signature_Form__c);
            }

        }

        //Get existing Wish Affiliations and their Form Ids categorized by Affiliation Type
        for(Wish_Required_Signature__c wrsObj : [SELECT Wish_Affiliation__c,Wish_Affiliation__r.Wish_Affiliation_Type__c,Wish_Signature_Form__c FROM Wish_Required_Signature__c WHERE Wish_Affiliation__c IN : scope]){
            if(wrsObj.Wish_Affiliation__r.Wish_Affiliation_Type__c.equals(Constant_AC.WISH_AFFILIATION_TYPE_APPROVED_PARTICIPANT) ){
                if(!wishAffiliationToFormIdParticipant.containsKey(wrsObj.Wish_Affiliation__c)){
                    wishAffiliationToFormIdParticipant.put(wrsObj.Wish_Affiliation__c, new Set<Id>());
                }
                wishAffiliationToFormIdParticipant.get(wrsObj.Wish_Affiliation__c).add(wrsObj.Wish_Signature_Form__c);
            }
            else if(wrsObj.Wish_Affiliation__r.Wish_Affiliation_Type__c.equals(Constant_AC.WISH_AFFILIATION_TYPE_WISH_CHILD)){
                if(!wishAffiliationToFormIdChild.containsKey(wrsObj.Wish_Affiliation__c)){
                    wishAffiliationToFormIdChild.put(wrsObj.Wish_Affiliation__c, new Set<Id>());
                }
                wishAffiliationToFormIdChild.get(wrsObj.Wish_Affiliation__c).add(wrsObj.Wish_Signature_Form__c);
            }
        }

        //Create a wish Signature for each Affiliation with a Form if it doesn't exists already
        for( Wish_Affiliation__c objWishAff : scope){
            if(objWishAff.Wish_Affiliation_Type__c.equals(Constant_AC.WISH_AFFILIATION_TYPE_APPROVED_PARTICIPANT)){
                if(!chapterToParticipantForms.isEmpty() && chapterToParticipantForms.containsKey(objWishAff.Wish__r.ChapterName__c)){
                    for(Id formId : chapterToParticipantForms.get(objWishAff.Wish__r.ChapterName__c)){
                        if(wishAffiliationToFormIdParticipant.isEmpty() || (!wishAffiliationToFormIdParticipant.isEmpty() && wishAffiliationToFormIdParticipant.containsKey(objWishAff.Id) && !wishAffiliationToFormIdParticipant.get(objWishAff.Id).contains(formId) )){
                            //CREATE WRS
                            wrsToInsert.add(createWishSignature(objWishAff,formId));
                        }
                    }
                }
            }
            else if(objWishAff.Wish_Affiliation_Type__c.equals(Constant_AC.WISH_AFFILIATION_TYPE_WISH_CHILD)){
                if(!chapterToChildForms.isEmpty() && chapterToChildForms.containsKey(objWishAff.Wish__r.ChapterName__c)){
                    for(Id formId : chapterToChildForms.get(objWishAff.Wish__r.ChapterName__c)){
                        if(wishAffiliationToFormIdChild.isEmpty() || (!wishAffiliationToFormIdChild.isEmpty() && wishAffiliationToFormIdChild.containsKey(objWishAff.Id) && !wishAffiliationToFormIdChild.get(objWishAff.Id).contains(formId))){
                            //CREATE WRS
                            wrsToInsert.add(createWishSignature(objWishAff,formId));
                        }
                    }
                }
            }
        }

        if (!wrsToInsert.isEmpty()) {
            insert wrsToInsert;
        }
    }

    /**
     * Build Wish Required Signature
     * @param objWishAff
     * @param formId
     * @return Wish Required Signature
     */
    public Wish_Required_Signature__c createWishSignature(Wish_Affiliation__c objWishAff, Id formId){
        Wish_Required_Signature__c wrs = new Wish_Required_Signature__c();
        wrs.Wish_Case__c = objWishAff.Wish__c;
        wrs.Wish_Signature_Form__c = formId;
        wrs.Status__c = 'Not Sent';
        wrs.Type__c = 'Family';
        wrs.Wish_Affiliation__c = objWishAff.Id;
        wrs.Sent_to_Email_Address__c = objWishAff.Contact__r.Email;
        return wrs;
    }

    public void execute(System.SchedulableContext sc) {
        /*
        Run this in the Developer console once to schedule the job every morning at 02am
        String jobID = System.schedule('To add Wish Signatures for participants turning 18 today', '0 0 02 * * ? *' , new Batch_createWishSignatureForParticipants());
         */
        //Schedule this Batch job
        Database.executeBatch(new Batch_createWishSignatureForParticipants());
    }

    /**
     * Batch Finish
     * @param bc
     */
    public void finish(Database.BatchableContext bc) {
    }
}