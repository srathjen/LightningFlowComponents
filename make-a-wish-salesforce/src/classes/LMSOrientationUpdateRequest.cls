public class LMSOrientationUpdateRequest {
    public String user_login;
    public String course_code;
    public String status;

    /**
     * @description
     *
     * @param json
     *
     * @return
     */
    public static LMSOrientationUpdateRequest parse(String json) {
        return (LMSOrientationUpdateRequest) System.JSON.deserialize(json, LMSOrientationUpdateRequest.class);
    }
}