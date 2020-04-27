/* Created by : MST
Description : This class will be used to create JSON for LMS User Request Call.
*/
public class LMSUserRequest {
    public String login;
    public String first_name;
    public String last_name;
    public String email;
    public String password;
    public String chapter_id;

    /**
     * @description
     *
     * @param json
     *
     * @return
     */
    public static LMSUserRequest parse(String json) {
        return (LMSUserRequest) System.JSON.deserialize(json, LMSUserRequest.class);
    }
}