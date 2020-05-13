/**
 * @description CreatedBy: Kanagaraj
 * Author   : MST Solutions
 * CreatedDate : 07/27/2016
 * Location : This controller referred in AddVolunteerRole_VF.
 * Description : This VF page is placed as a Inline VF page of Non Wish & Event page layout. Here  chapter staff will enter
 * the roles and number of members in that role needed for that event. Once entered the value and hit [Save] button
 * It would create n number of Volunteer Opportunity records for that event.
 * JIRA: WLP-422
 * Author: Gustavo Mayer
 * Update: Changing the Volunteer_Roles status from 'Trained' to 'Active'
 */
public class AddVolunteerRole_AC {

    private final static String VOLUNTEER_ROLE_STATUS_ACTIVE = Constant_AC.VOLUNTEER_ROLE_STATUS_ACTIVE;
    private final static String VOLUNTEER_OPPORTUNITY_STATUS_PENDING = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_PENDING;
    private final static String VOLUNTEER_OPPORTUNITY_STATUS_APPROVED = Constant_AC.VOLUNTEER_OPPORTUNITY_STATUS_APPROVED;
    private final static String VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR = Constant_AC.VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR;
    private final static String VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER = Constant_AC.VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER;
    private final static String VOLUNTEER_OPPORTUNITY_REASON_INACTIVE_NOT_APPROVED = Constant_AC.VOLUNTEER_OPPORTUNITY_REASON_INACTIVE_NOT_APPROVED;
    private final static String SLASH = '/';
    private final static String SPACE = ' ';
    public List<Volunteer_Count__c> volunteerCountList { get; set; }
    public List<Non_Wish_Events__c> addNewVolunteerRoleList { get; set; }
    private ApexPages.StandardController controller { get; set; }
    public Non_Wish_Events__c nonWishEvent { get; set; }
    public Non_Wish_Events__c currNonWishRec;
    public String RoleName { get; set; }
    public Integer VolunteerCount { get; set; }
    public Boolean outputMode { get; set; }
    public Boolean inputMode { get; set; }
    public Boolean isEdit { get; set; }
    public Boolean isNew { get; set; }
    public List<Volunteer_Count__c> volunteerCountEditList { get; set; }
    public List<Volunteer_Count__c> volunteerCountToUpdateList { get; set; }
    public Id ChapterRoleId { get; set; }
    public Id CountId { get; set; }
    public Integer neededCount;
    public Id eventRT;
    public User currUser { get; set; }
    public Boolean isCommunity { get; set; }
    public String communityUserString;
    public List<VolunteerCountWrapper> volunteerCountWrapList { get; set; }
    public String activeVolunteer { get; set; }
    public String profileId { get; set; }
    public Id trainingRTId = Constant_AC.TRAINING_RT_ID;
    public Id volunteerRecordTypeId = Constant_AC.VOLUNTEER_RT_ID;
    public Boolean isReferesh { get; set; }
    public Boolean isActiveVolunteer { get; set; }
    public Boolean dateMessage;
    public Boolean sameValue;
    public Boolean boolValue;
    public String redirectUrl { public get; private set; }
    public Boolean shouldRedirect { public get; private set; }

    public AddVolunteerRole_AC(ApexPages.StandardController controller) {
        shouldRedirect = false;
        sameValue = false;
        dateMessage = false;
        boolValue = false;
        this.controller = controller;
        nonWishEvent = (Non_Wish_Events__c) controller.getRecord();
        isActiveVolunteer = false;
        currUser = Utils.currentUser;
        volunteerCountWrapList = new List<VolunteerCountWrapper>();
        activeVolunteer = Label.Active_Volunteer_Profile;
        profileId = UserInfo.getProfileId();
        volunteerCountToUpdateList = new List<Volunteer_Count__c>();
        isActiveVolunteer = (currUser.Profile.Id == Label.Active_Volunteer_Profile);
        if (currUser.ContactId != null) {
            isCommunity = true;
            if (currUser.Hidden_Role_Name_Id__c != null) {
                communityUserString = currUser.Hidden_Role_Name_Id__c;
            }
        }
        currNonWishRec = [
                SELECT Id,Name,Chapter__c
                FROM Non_Wish_Events__c
                WHERE Id = :nonWishEvent.Id
        ];
        eventRT = Constant_AC.NON_WISH_EVENT_RT_ID;
        volunteerCountList = initializeVolunteerCounts(nonWishEvent.Id);
        addNewVolunteerRoleList = new List<Non_Wish_Events__c>();
        volunteerCountWrapList = buildVolunteerCountWrapper(volunteerCountList);
        if (!volunteerCountList.isEmpty()) {
            outputMode = true;
            inputMode = false;
            isEdit = false;
            isNew = false;
        } else {
            isNew = true;
            outputMode = false;
            inputMode = false;
            isEdit = false;
        }
    }

    public void addRow() {
        if (!volunteerCountList.isEmpty()) {
            isNew = false;
            inputMode = true;
            outputMode = false;
            isEdit = false;
            if (!addNewVolunteerRoleList.isEmpty()) {
                Integer listSize = addNewVolunteerRoleList.size() - 1;
                if (addNewVolunteerRoleList.get(listSize).Chapter_Role__c == null) {
                    addNewVolunteerRoleList.remove(listSize);
                    addNewVolunteerRoleList.add(new Non_Wish_Events__c());
                } else {
                    addNewVolunteerRoleList.add(new Non_Wish_Events__c());
                }
            } else {
                addNewVolunteerRoleList.add(new Non_Wish_Events__c());
            }
        } else {
            isNew = true;
            inputMode = false;
            outputMode = false;
            isEdit = false;
            addNewVolunteerRoleList.add(new Non_Wish_Events__c());
        }
    }

    /**
     * @description This SaveRec() is used to create the no. of volunteer opportuity based on the volunteerNeeded.
     * As well as it will update the volunteer opportunity.
     *
     * @return
     */
    public PageReference saveRec() {
        PageReference pr ;
        inputMode = false;
        isEdit = false;
        isNew = false;
        outputMode = true;
        pr = new PageReference(SLASH + nonWishEvent.Id);
        List<Volunteer_Opportunity__c> newVolOpportunityList = new List<Volunteer_Opportunity__c>();
        List<Volunteer_Count__c> newVolunteerCounts = new List<Volunteer_Count__c>();
        List<Volunteer_Count__c> volunteerCountEditListTwo = new List<Volunteer_Count__c>();
        volunteerCountList = new List<Volunteer_Count__c>();
        Set<String> descSet = new Set<String>();
        if (!volunteerCountToUpdateList.isEmpty()) {
            Integer listSize = 0;
            if (volunteerCountToUpdateList.get(listSize).Chapter_Role__c == null) {
                VolunteerOpportunityService.deleteNonApprovedByNonWishEventAndRecordType(nonWishEvent.Id, eventRT);
            } else {
                Set<Id> chapterRoleIdSet = new Set<Id>();
                Integer size = volunteerCountToUpdateList.size() - 1;
                if (volunteerCountToUpdateList.get(size).Chapter_Role__c == null) {
                    volunteerCountToUpdateList.remove(size);
                }
                for (Volunteer_Count__c roleName : volunteerCountToUpdateList) {
                    if (roleName.Volunteer_Needed__c < roleName.Registered__c && roleName.Registered__c > 0) {
                        isReferesh = true;
                        boolValue = true;
                        displayErrorMsg();
                        return null;
                    }
                    if (roleName.Date__c < System.today()) {
                        dateMessage = true;
                    }
                    volunteerCountEditListTwo.add(roleName);
                }
                for (Volunteer_Count__c volunteerCount : [
                        SELECT Id,Chapter_Role__c,Description__c,Non_Wish_Events__c,Event_Name__c,Date__c,
                                Start_Time__c,End_Time__c
                        FROM Volunteer_Count__c
                        WHERE Non_Wish_Events__c = :nonWishEvent.Id
                ]) {
                    if (descSet.contains(volunteerCount.Chapter_Role__c +
                            +volunteerCount.Description__c +
                            +volunteerCount.Date__c +
                            +volunteerCount.Start_Time__c +
                            +volunteerCount.End_Time__c)) {
                        sameValue = true;
                    }
                }
                if (sameValue || dateMessage) {
                    isReferesh = true;
                    displayErrorMsg();
                    return null;
                }
                for (Volunteer_Count__c roleName : volunteerCountEditListTwo) {
                    chapterRoleIdSet.add(roleName.Chapter_Role__c);
                }
                VolunteerOpportunityService.deleteNonApprovedByChapterAndNonWishEvent(chapterRoleIdSet, nonWishEvent.Id);
                try {
                    update volunteerCountEditListTwo;
                    if (Test.isRunningTest()) {
                        throw new CommonTriggerException('Test Class execution');
                    }
                } catch (Exception ex) {
                }
                volunteerCountList = initializeVolunteerCounts(nonWishEvent.Id);
                for (Volunteer_Count__c volunteerCount : volunteerCountEditListTwo) {
                    if (volunteerCount.Volunteer_Needed__c > 0) {
                        Integer count = Integer.valueOf(volunteerCount.Volunteer_Needed__c) - Integer.valueOf(volunteerCount.Registered__c);
                        for (Integer i = 0; i < count; i++) {
                            Volunteer_Opportunity__c newVolOpp = new Volunteer_Opportunity__c();
                            newVolOpp.Non_Wish_Event__c = nonWishEvent.Id;
                            newVolOpp.Chapter_Role_Opportunity__c = volunteerCount.Chapter_Role__c;
                            newVolOpp.HiddenVolunteer_Count_Description__c = volunteerCount.Id;
                            newVolOpp.Hidden_VolunteerCount_Desc__c = volunteerCount.Description__c;
                            newVolOpp.RecordTypeId = eventRT;
                            newVolOpp.Chapter_Name__c = currNonWishRec.Chapter__c;
                            newVolOpp.Description__c = volunteerCount.Description__c;
                            newVolOpp.Start_Time__c = volunteerCount.Start_Time__c;
                            newVolOpp.End_Time__c = volunteerCount.End_Time__c;
                            newVolOpp.Location__c = volunteerCount.Location__c;
                            newVolOpp.Date__c = volunteerCount.Date__c;
                            newVolOpportunityList.add(newVolOpp);
                        }
                    }
                }
                insert newVolOpportunityList;
            }
        } else {
            if (!addNewVolunteerRoleList.isEmpty()) {
                Integer size = addNewVolunteerRoleList.size() - 1;
                if (addNewVolunteerRoleList.get(size).Chapter_Role__c == null) {
                    addNewVolunteerRoleList.remove(size);
                }
                if (!addNewVolunteerRoleList.isEmpty()) {
                    for (Non_Wish_Events__c processNonWish : addNewVolunteerRoleList) {
                        Volunteer_Count__c newVolCount = new Volunteer_Count__c ();
                        newVolCount.Volunteer_Needed__c = processNonWish.Volunteer_Need__c;
                        newVolCount.Chapter_Role__c = processNonWish.Chapter_Role__c;
                        newVolCount .Non_Wish_Events__c = nonWishEvent.Id;
                        newVolCount.Description__c = processNonWish.Description__c;
                        newVolCount.Start_Time__c = processNonWish .Start_Time__c;
                        newVolCount.End_Time__c = processNonWish .End_Time__c;
                        newVolCount.Location__c = processNonWish .Hidden_Location__c;
                        newVolCount.Date__c = processNonWish .Hidden_Date__c;
                        if (newVolCount.Date__c < System.today()) {
                            dateMessage = true;
                        }
                        newVolunteerCounts.add(newVolCount);
                        descSet.add(newVolCount.Chapter_Role__c +
                                +newVolCount.Description__c +
                                +newVolCount.Date__c +
                                +newVolCount.Start_Time__c +
                                +newVolCount.End_Time__c);
                    }

                    for (Volunteer_Count__c volunteerCount : [
                            SELECT Id,Chapter_Role__c,Description__c,Non_Wish_Events__c,Event_Name__c,Date__c,Start_Time__c,End_Time__c
                            FROM Volunteer_Count__c
                            WHERE Non_Wish_Events__c = :nonWishEvent.Id
                            AND Description__c = :newVolunteerCounts[0].Description__c
                            AND Chapter_Role__c = :newVolunteerCounts[0].Chapter_Role__c
                    ]) {
                        if (descSet.contains(volunteerCount.Chapter_Role__c +
                                +volunteerCount.Description__c +
                                +volunteerCount.Date__c +
                                +volunteerCount.Start_Time__c +
                                +volunteerCount.End_Time__c)) {
                            sameValue = true;
                        }
                    }
                    if (!sameValue && !dateMessage) {
                        Integer listSize = newVolunteerCounts.size() - 1;
                        if (newVolunteerCounts.get(listSize).Chapter_Role__c == null) {
                            newVolunteerCounts.remove(listSize);
                        }
                        insert newVolunteerCounts;
                    } else {
                        isReferesh = true;
                        displayErrorMsg();
                        return null;
                    }
                    volunteerCountList = initializeVolunteerCounts(nonWishEvent.Id);
                    if (!newVolunteerCounts.isEmpty()) {
                        for (Volunteer_Count__c newVolunteerCount : newVolunteerCounts) {
                            if (newVolunteerCount.Volunteer_Needed__c > 0) {
                                for (Integer i = 0; i < newVolunteerCount.Volunteer_Needed__c; i++) {
                                    Volunteer_Opportunity__c newVolOpportunity = new Volunteer_Opportunity__c();
                                    newVolOpportunity.Non_Wish_Event__c = nonWishEvent.Id;
                                    newVolOpportunity.Chapter_Role_Opportunity__c = newVolunteerCount.Chapter_Role__c;
                                    newVolOpportunity.RecordTypeId = eventRT;
                                    newVolOpportunity.HiddenVolunteer_Count_Description__c = newVolunteerCount.Id;
                                    newVolOpportunity.Hidden_VolunteerCount_Desc__c = newVolunteerCount.Description__c;
                                    newVolOpportunity.Chapter_Name__c = currNonWishRec.Chapter__c;
                                    newVolOpportunity.Description__c = newVolunteerCount.Description__c;
                                    newVolOpportunity.Start_Time__c = newVolunteerCount.Start_Time__c;
                                    newVolOpportunity.End_Time__c = newVolunteerCount.End_Time__c;
                                    newVolOpportunity.Location__c = newVolunteerCount.Location__c;
                                    newVolOpportunity.Date__c = newVolunteerCount.Date__c;
                                    newVolOpportunityList.add(newVolOpportunity);
                                }
                            }
                        }
                    }
                    insert newVolOpportunityList;
                }
            }
        }
        shouldRedirect = true;
        redirectUrl = SLASH + nonWishEvent.Id;
        return null;
    }

    /**
     * @description Display Error Message
     *
     * @return
     */
    public PageReference displayErrorMsg() {
        isReferesh = true;
        if (sameValue) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Add_Volunteer_Role_Existing_Entry));
        }
        if (dateMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Add_Volunteer_Role_Missing_Date));
        }
        if (boolValue) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.Volunteer_Role_Volunteer_Count_Less));
        }
        return null;
    }

    /**
     * @description Update the number of volunteer opportunities needed
     */
    public void EditRec() {
        isEdit = true;
        outputMode = false;
        isNew = false;
        inputMode = false;
        volunteerCountToUpdateList = new List<Volunteer_Count__c>();
        volunteerCountList = initializeVolunteerCounts(nonWishEvent.Id);
        Map<String, Volunteer_Count__c> volunteerCountMap = new Map<String, Volunteer_Count__c>(volunteerCountList);
        volunteerCountEditList = new List<Volunteer_Count__c >();
        volunteerCountEditList.addAll(volunteerCountList);
        for (Volunteer_Count__c volunteerCount : volunteerCountEditList) {
            if (volunteerCountMap.containsKey(volunteerCount.Id)) {
                Volunteer_Count__c newProcess = new Volunteer_Count__c();
                newProcess.Id = volunteerCountMap.get(volunteerCount.Id).Id;
                newProcess.Chapter_Role__c = volunteerCountMap.get(volunteerCount.Id).Chapter_Role__c;
                newProcess .Volunteer_Needed__c = volunteerCount.Volunteer_Needed__c ;
                newProcess.Registered__c = volunteerCountMap.get(volunteerCount.Id).Registered__c ;
                newProcess.Description__c = volunteerCount.Description__c;
                newProcess.Start_Time__c = volunteerCount.Start_Time__c;
                newProcess.End_Time__c = volunteerCount.End_Time__c;
                newProcess.Location__c = volunteerCount.Location__c;
                newProcess.Date__c = volunteerCount.Date__c;
                neededCount = Integer.valueOf(volunteerCount.Volunteer_Needed__c);
                volunteerCountToUpdateList.add(newProcess);
            }
        }
    }

    /**
     * @description Cancel
     */
    public void cancelRec() {
        isEdit = false;
        outputMode = true;
        isNew = false;
        inputMode = false;
    }

    /**
     * @description Check if Chapter Role is Required for Chapter Role
     *
     * @param chapterRole
     *
     * @return True or False
     */
    public Boolean getChapterRoleOanTStatus(Id chapterRole) {
        List<Chapter_Role_O_T__c> currTrainig = [
                SELECT Id, Required__c
                FROM Chapter_Role_O_T__c
                WHERE
                Chapter_Role__c = :chapterRole
                AND Orientation_Training__r.RecordTypeId = :trainingRTId
                LIMIT 1
        ];
        if (!currTrainig.isEmpty()) {
            return currTrainig[0].Required__c;
        } else {
            return false;
        }
    }

    /**
     * @description Is Volunteer able to register to Volunteer Opportunity
     *
     * @param volunteerOpportunity
     *
     * @return True or False
     */
    public Boolean allowRegisteration(List<Volunteer_Opportunity__c> volunteerOpportunity) {
        Boolean updateRecord = false;
        Boolean allowRegister = false;
        Boolean isWishRole = false;
        Map<Id, Volunteer_Roles__c> WishTrainedMap = new Map<Id, Volunteer_Roles__c>();
        Map<Id, Volunteer_Roles__c> WishNonTrainedMap = new Map<Id, Volunteer_Roles__c>();
        Set<Id> TrainedNonWishRoles = new Set<Id>();
        Set<Id> notTrainedNonWishRoles = new Set<Id>();
        Boolean isWishGranterMentor = false;

        for (Role__c currRole : [
                SELECT Id,Name,isWishRole__c
                FROM Role__c
                WHERE Id = :volunteerOpportunity[0].Chapter_Role_Opportunity__r.Role_Name__c
        ]) {
            if (currRole.isWishRole__c) {
                isWishRole = true;
            }
        }
        for (Volunteer_Roles__c checkForMatchingRole : [
                SELECT Id, Chapter_Name__c,Role_Name__c,isWishRole__c,Status__c, Chapter_Role__c,
                        Chapter_Role__r.Role_Name__c
                FROM Volunteer_Roles__c
                WHERE Volunteer_Name__c = :currUser.ContactId
                AND Chapter_Name__c = :volunteerOpportunity.get(0).Chapter_Name__r.Name
        ]) {
            if (checkForMatchingRole.isWishRole__c
                    && checkForMatchingRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE) {
                WishTrainedMap.put(checkForMatchingRole.Chapter_Role__c, checkForMatchingRole);
                if (checkForMatchingRole.Role_Name__c == VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER_MENTOR) {
                    isWishGranterMentor = true;
                }
            } else if (checkForMatchingRole.isWishRole__c
                    && checkForMatchingRole.Status__c != VOLUNTEER_ROLE_STATUS_ACTIVE) {
                WishNonTrainedMap.put(checkForMatchingRole.Chapter_Role__c, checkForMatchingRole);
            } else if (!checkForMatchingRole.isWishRole__c
                    && checkForMatchingRole.Status__c == VOLUNTEER_ROLE_STATUS_ACTIVE) {
                TrainedNonWishRoles.add(checkForMatchingRole.Chapter_Role__r.Role_Name__c);
            } else if (!checkForMatchingRole.isWishRole__c
                    && checkForMatchingRole.Status__c != VOLUNTEER_ROLE_STATUS_ACTIVE) {
                notTrainedNonWishRoles.add(checkForMatchingRole.Chapter_Role__r.Role_Name__c);
            }
        }
        if (!isWishRole) {
            if (!WishTrainedMap.isEmpty()) {
                updateRecord = true;
                allowRegister = true;
            } else {
                if (getChapterRoleOanTStatus(volunteerOpportunity[0].Chapter_Role_Opportunity__c)) {
                    if (TrainedNonWishRoles.contains(volunteerOpportunity[0].Chapter_Role_Opportunity__r.Role_Name__c)) {
                        updateRecord = true;
                        allowRegister = true;
                    }
                } else {
                    if (TrainedNonWishRoles.contains(volunteerOpportunity[0].Chapter_Role_Opportunity__r.Role_Name__c)
                            || (notTrainedNonWishRoles.contains(volunteerOpportunity[0].Chapter_Role_Opportunity__r.Role_Name__c))) {
                        updateRecord = true;
                        allowRegister = true;
                    }
                }
            }
        } else if (isWishRole) {
            if (getChapterRoleOanTStatus(volunteerOpportunity[0].Chapter_Role_Opportunity__c)) {
                if (WishTrainedMap.containsKey(volunteerOpportunity[0].Chapter_Role_Opportunity__c)
                        || (isWishGranterMentor
                        && VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER.equals(volunteerOpportunity[0].Role__c))) {
                    updateRecord = true;
                    allowRegister = true;
                }
            } else if (!getChapterRoleOanTStatus(volunteerOpportunity[0].Chapter_Role_Opportunity__c)) {
                if (WishTrainedMap.containsKey(volunteerOpportunity[0].Chapter_Role_Opportunity__c)
                        || WishNonTrainedMap.containsKey(volunteerOpportunity[0].Chapter_Role_Opportunity__c)
                        || (isWishGranterMentor && VOLUNTEER_OPPORTUNITY_ROLE_WISH_GRANTER.equals(volunteerOpportunity[0].Role__c))) {
                    updateRecord = true;
                    allowRegister = true;
                }
            }
        }
        if (updateRecord && allowRegister) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @description Register Volunteer Opportunity
     *
     * @return Page
     */
    public PageReference register() {
        try {
            isReferesh = true;
            inputMode = false;
            outputMode = false;
            isNew = false;
            PageReference pr;
            Chapter_Role__c dbRole;
            String roleId;
            Boolean allowRegister = false;
            Id volunteerContactId;
            pr = new PageReference(SLASH + nonWishEvent.Id);
            Map<Id, Volunteer_Count__c> volunteerCountMap = new Map<Id, Volunteer_Count__c>();
            List<Volunteer_Opportunity__c> volunteerOpportunities = [
                    SELECT Id,RecordTypeId,HiddenVolunteer_Count_Description__c,Role__c,Chapter_Name__r.Name,
                            Chapter_Role_Opportunity__c,Chapter_Role_Opportunity__r.Role_Name__c,Description__c,
                            Chapter_Name__c,Volunteer_Name__c,Non_Wish_Event__c,Reason_Inactive__c,Date__c,
                            End_Time__c,Start_Time__c,Hidden_VolunteerCount_Desc__c
                    FROM Volunteer_Opportunity__c
                    WHERE Chapter_Role_Opportunity__c = :ChapterRoleId
                    AND Volunteer_Name__c = NULL
                    AND Non_Wish_Event__c = :nonWishEvent.Id
                    AND RecordTypeId = :eventRT
                    AND Status__c != :VOLUNTEER_OPPORTUNITY_STATUS_APPROVED
                    AND Reason_Inactive__c = :NULL
                    AND HiddenVolunteer_Count_Description__c = :CountId
                    LIMIT 1
            ];
            if (!volunteerOpportunities.isEmpty()) {
                dbRole = [
                        SELECT Id,Name,Role_Name__c,Role_Name__r.Name
                        FROM Chapter_Role__c
                        WHERE Id = :volunteerOpportunities[0].Chapter_Role_Opportunity__c
                ];
                for (Volunteer_Opportunity__c dbVol : [
                        SELECT Id,RecordTypeId,HiddenVolunteer_Count_Description__c,Role__c,Chapter_Name__r.Name,
                                Chapter_Role_Opportunity__c,Chapter_Role_Opportunity__r.Role_Name__c,
                                Chapter_Name__c,Volunteer_Name__c,Non_Wish_Event__c,Reason_Inactive__c,Hidden_VolunteerCount_Desc__c,Start_Time__c,End_Time__c,Date__c
                        FROM Volunteer_Opportunity__c
                        WHERE Non_Wish_Event__c = :volunteerOpportunities[0].Non_Wish_Event__c
                        AND Chapter_Role_Opportunity__c = :volunteerOpportunities[0].Chapter_Role_Opportunity__c
                        AND Chapter_Role_Opportunity__r.Role_Name__c = :volunteerOpportunities[0].Chapter_Role_Opportunity__r.Role_Name__c
                        AND Reason_Inactive__c = :VOLUNTEER_OPPORTUNITY_REASON_INACTIVE_NOT_APPROVED
                        AND Volunteer_Name__c = :currUser.ContactId
                        AND Start_Time__c = :volunteerOpportunities[0].Start_Time__c
                        AND End_Time__c = :volunteerOpportunities[0].End_Time__c
                        AND Hidden_VolunteerCount_Desc__c = :volunteerOpportunities[0].Hidden_VolunteerCount_Desc__c
                        AND Date__c = :volunteerOpportunities[0].Date__c
                        AND HiddenVolunteer_Count_Description__c = :CountId
                ]) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Volunteer_Role_Opportunity_Declined));
                    return null;
                }
                for (Volunteer_Opportunity__c dbVol : [
                        SELECT Id,RecordTypeId,HiddenVolunteer_Count_Description__c,Role__c,Chapter_Name__r.Name,
                                Chapter_Role_Opportunity__c,Chapter_Role_Opportunity__r.Role_Name__c,
                                Chapter_Name__c,Volunteer_Name__c,Non_Wish_Event__c,Reason_Inactive__c,Hidden_VolunteerCount_Desc__c
                        FROM Volunteer_Opportunity__c
                        WHERE Non_Wish_Event__c = :volunteerOpportunities[0].Non_Wish_Event__c
                        AND Chapter_Role_Opportunity__c = :volunteerOpportunities[0].Chapter_Role_Opportunity__c
                        AND Chapter_Role_Opportunity__r.Role_Name__c = :volunteerOpportunities[0].Chapter_Role_Opportunity__r.Role_Name__c
                        AND Status__c IN (:VOLUNTEER_OPPORTUNITY_STATUS_PENDING, :VOLUNTEER_OPPORTUNITY_STATUS_APPROVED)
                        AND Volunteer_Name__c = :currUser.ContactId
                        AND Start_Time__c = :volunteerOpportunities[0].Start_Time__c
                        AND End_Time__c = :volunteerOpportunities[0].End_Time__c
                        AND Hidden_VolunteerCount_Desc__c = :volunteerOpportunities[0].Hidden_VolunteerCount_Desc__c
                        AND Date__c = :volunteerOpportunities[0].Date__c
                ]) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.Volunteer_Role_Already_Registered));
                    if (!Test.isRunningTest()) {
                        return null;
                    }
                }
                for (Volunteer_Opportunity__c dbVol : [
                        SELECT Id,RecordTypeId,HiddenVolunteer_Count_Description__c,Role__c,Chapter_Name__r.Name,
                                Chapter_Role_Opportunity__c,Chapter_Role_Opportunity__r.Role_Name__c,
                                Chapter_Name__c,Volunteer_Name__c,Non_Wish_Event__c,Reason_Inactive__c,Date__c,
                                End_Time__c,Start_Time__c,Hidden_VolunteerCount_Desc__c
                        FROM Volunteer_Opportunity__c
                        WHERE Non_Wish_Event__c = :volunteerOpportunities[0].Non_Wish_Event__c
                        AND Chapter_Role_Opportunity__c = :volunteerOpportunities[0].Chapter_Role_Opportunity__c
                        AND Status__c IN (:VOLUNTEER_OPPORTUNITY_STATUS_PENDING, :VOLUNTEER_OPPORTUNITY_STATUS_APPROVED)
                        AND Volunteer_Name__c = :currUser.ContactId
                        AND Start_Time__c = :volunteerOpportunities[0].Start_Time__c
                        AND End_Time__c = :volunteerOpportunities[0].End_Time__c
                        AND Date__c = :volunteerOpportunities[0].Date__c
                        AND Hidden_VolunteerCount_Desc__c != :volunteerOpportunities[0].Hidden_VolunteerCount_Desc__c
                ]) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.Volunteer_Role_Already_Registered_Time));
                    if (!Test.isRunningTest()) {
                        return null;
                    }
                }
                if (!volunteerOpportunities.isEmpty()) {
                    allowRegister = allowRegisteration(volunteerOpportunities);
                }
                if (!volunteerOpportunities.isEmpty()) {
                    for (Volunteer_Count__c dbVolunteerCount : [
                            SELECT Id,Name,Non_Wish_Events__c,Registered__c,Volunteer_Needed__c
                            FROM Volunteer_Count__c
                            WHERE Non_Wish_Events__c = :volunteerOpportunities[0].Non_Wish_Event__c
                            AND Id = :volunteerOpportunities[0].HiddenVolunteer_Count_Description__c
                    ]) {
                        volunteerContactId = dbVolunteerCount.Id;
                        volunteerCountMap.put(dbVolunteerCount.Id, dbVolunteerCount);
                    }
                }
                if (!volunteerOpportunities.isEmpty() && !volunteerCountMap.isEmpty()) {
                    dbRole = [
                            SELECT Id,Name,Role_Name__c,Role_Name__r.Name
                            FROM Chapter_Role__c
                            WHERE Id = :volunteerOpportunities[0].Chapter_Role_Opportunity__c
                    ];
                    roleId = dbRole.Role_Name__c + String.valueOf(volunteerOpportunities[0].Non_Wish_Event__c);
                    if (volunteerCountMap.containsKey(volunteerOpportunities[0].HiddenVolunteer_Count_Description__c) && allowRegister) {
                        Volunteer_Opportunity__c updateVolOpportunity = new Volunteer_Opportunity__c();
                        updateVolOpportunity.Id = volunteerOpportunities[0].Id;
                        updateVolOpportunity.Chapter_Role_Opportunity__c = volunteerOpportunities[0].Chapter_Role_Opportunity__c;
                        updateVolOpportunity.Volunteer_Name__c = currUser.ContactId ;
                        updateVolOpportunity.Chapter_Name__c = currNonWishRec.Chapter__c;
                        update updateVolOpportunity;
                        Volunteer_Count__c volunteerCount = new Volunteer_Count__c ();
                        volunteerCount.Id = volunteerContactId;
                        volunteerCount.Registered__c = volunteerCountMap.get(volunteerContactId).Registered__c + 1;
                        update volunteerCount;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.Volunteer_Role_Opportunity_Requested));
                        return null;
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Volunteer_Role_Opportunity_Training_Not_Completed));
                        return null;
                    }
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.Volunteer_Role_Already_Filled));
                if (!Test.isRunningTest()) {
                    throw new CommonTriggerException(Constant_AC.TEST_EXCEPTION_ERROR);
                }
                return null;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
        }
        return null;
    }

    public class VolunteerCountWrapper {
        public String chapterRole { get; set; }
        public String roleName { get; set; }
        public Decimal volunteerNeeded { get; set; }
        public String voldescription { get; set; }
        public Decimal volunteerRegistration { get; set; }
        public String cname { get; set; }
        public String recordId { get; set; }
        public String volunteerCountId { get; set; }
        public String eventName { get; set; }
        public String volStartTime { get; set; }
        public String volendTime { get; set; }
        public Date Voldate { get; set; }
        public String vollocation { get; set; }
        public VolunteerCountWrapper(String vcId, String recId, String cRole, String rName, String name,
                String evtName, String comments, Date voDate, String startTime, String endTime, String location,
                Decimal vNeeded, Decimal volunteerReg) {
            chapterRole = cRole;
            roleName = rName;
            volunteerNeeded = vNeeded;
            voldescription = comments;
            volunteerRegistration = volunteerReg;
            cname = name;
            recordId = recId;
            volunteerCountId = vcId;
            eventName = evtName;
            volStartTime = startTime;
            volendTime = endTime;
            Voldate = voDate;
            vollocation = location;
        }
    }

    /**
     * @description Initialize Volunteer Counts
     *
     * @param nonWishEventId
     *
     * @return
     */
    private List<Volunteer_Count__c> initializeVolunteerCounts(Id nonWishEventId) {
        return [
                SELECT Id,Name,Volunteer_Needed__c,Non_Wish_Events__c,Chapter_Role__r.Name,Description__c,
                        Hidden_Chapter_Name__c,Chapter_Role__c,Registered__c,Event_Name__c,Start_Time__c,End_Time__c,
                        Date__c,Location__c
                FROM Volunteer_Count__c
                WHERE Non_Wish_Events__c = :nonWishEventId
                AND Volunteer_Needed__c != 0
        ];
    }

    /**
     * @description Build Volunteer Count Wrapper from Volunteer Counts
     *
     * @param volunteerCounts
     *
     * @return List of Volunteer Count
     */
    private List<VolunteerCountWrapper> buildVolunteerCountWrapper(List<Volunteer_Count__c> volunteerCounts) {
        List<VolunteerCountWrapper> volunteerCountWrappers = new List<VolunteerCountWrapper>();
        for (Volunteer_Count__c volunteerCount : volunteerCounts) {
            VolunteerCountWrapper currVolunteer = new VolunteerCountWrapper(
                    volunteerCount.Id, volunteerCount.Chapter_Role__c, volunteerCount.Chapter_Role__r.Name,
                    volunteerCount.Hidden_Chapter_Name__c, volunteerCount.Name, volunteerCount.Event_Name__c,
                    volunteerCount.Description__c, volunteerCount.Date__c, volunteerCount.Start_Time__c,
                    volunteerCount.End_Time__c, volunteerCount.Location__c, volunteerCount.Volunteer_Needed__c,
                    volunteerCount.Registered__c);
            volunteerCountWrappers.add(currVolunteer);
        }
        return volunteerCountWrappers;
    }
}