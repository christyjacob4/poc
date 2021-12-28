import Survey "Survey";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";

module {
    public type Bio = {
        name: Text;
        address: Text;
        phone: Nat; 
    };

    public type PublicSurvey = {
        name: Text;
        canisterId: Principal;
    };

    type PrivateSurvey = Survey.PrivateSurvey;

    public type Profile = {
        id: Principal;
        bio: Bio;
    };

    public type CaniserType = {
        #Private;
        #Community;
    };

    public type Error = {
        #SomeError;
        #NotFound;
        #AlreadyExists;
        #NotAuthorized;
    };
}