/**
 * @description This class will be used to create LMS Orientation Registration Request for the Call out.
 *
 * @author MST
 */
public class LMSOrientationRegistrationRequest {
    public String course_code;  //wish101
    public String user_login;   //user@test.com
    public String status;   //dropped
    public Integer enrollment_id;

    /**
     * @description
     *
     * @param json
     *
     * @return
     */
    public static LMSOrientationRegistrationRequest parse(String json) {
        return (LMSOrientationRegistrationRequest) System.JSON.deserialize(json, LMSOrientationRegistrationRequest.class);
    }
}