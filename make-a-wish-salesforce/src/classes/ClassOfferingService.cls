/**
 * @description Class Offering Service, centralizes Class Offering business rules.
 * @author Gustavo Mayer, Traction on Demand
 * @date 3/19/2020
 */
public class ClassOfferingService {

    private final static String ROLE_NATIONAL_STAFF = Constant_AC.ROLE_NATIONAL_STAFF;

    /**
     * @description Build Class Offering Chapter Map
     * @param classOfferingNewMap
     * @return Map of Class Offerings by Chapter
     */
    public static Map<String, List<Class_Offering__c>> buildClassOfferingChapterMap(
            Map<Id, Class_Offering__c> classOfferingNewMap) {
        Map<String, List<Class_Offering__c>> classOfferingMap = new Map<String, List<Class_Offering__c>>();
        for (Class_Offering__c classOffering : [
                SELECT Id, Chapter__c, OwnerId, Owner.UserRoleId,
                        Owner.UserRole.Name
                FROM Class_Offering__c
                WHERE Id IN :classOfferingNewMap.keySet()
        ]) {
            if (ROLE_NATIONAL_STAFF.equals(classOffering.Owner.UserRole.Name)) {
                if (!classOfferingMap.containsKey(classOffering.Chapter__c)) {
                    classOfferingMap.put(classOffering.Chapter__c, new List<Class_Offering__c>{
                            classOffering
                    });
                }
                classOfferingMap.get(classOffering.Chapter__c).add(classOffering);
            }
        }
        return classOfferingMap;
    }

    /**
     * @description Build Class Offering Chapter Map
     * @param classOfferingNewMap
     * @param classOfferingOldMap
     * @return Map of Class Offerings by Chapter
     */
    public static Map<String, List<Class_Offering__c>> buildClassOfferingChapterMap(
            Map<Id, Class_Offering__c> classOfferingNewMap,
            Map<Id, Class_Offering__c> classOfferingOldMap) {
        Map<String, List<Class_Offering__c>> classOfferingMap = new Map<String, List<Class_Offering__c>>();
        for (Class_Offering__c classOffering : [
                SELECT Id, Chapter__c, OwnerId, Owner.UserRoleId,
                        Owner.UserRole.Name
                FROM Class_Offering__c
                WHERE Id IN :classOfferingNewMap.keySet()
        ]) {
            if (classOffering.OwnerId != classOfferingOldMap.get(classOffering.Id).OwnerId) {
                if (ROLE_NATIONAL_STAFF.equals(classOffering.Owner.UserRole.Name)) {
                    if (!classOfferingMap.containsKey(classOffering.Chapter__c)) {
                        classOfferingMap.put(classOffering.Chapter__c, new List<Class_Offering__c>{
                                classOffering
                        });
                    }
                    classOfferingMap.get(classOffering.Chapter__c).add(classOffering);
                }
            }
        }
        return classOfferingMap;
    }
}