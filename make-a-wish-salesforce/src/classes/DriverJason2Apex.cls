Public class DriverJason2Apex{
    
    public String type_Z {get;set;} 
    public String state {get;set;} 
    public String licenseNum {get;set;} 
    public String expirationDate {get;set;} 
    public String driverName {get;set;} 
    
    public  List<DriverJason2Apex> parse(String driverInfo) {
        return (List<DriverJason2Apex>) System.JSON.deserialize(driverInfo, List<DriverJason2Apex>.class);
    }
}