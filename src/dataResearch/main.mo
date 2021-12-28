import Types "Types";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import P "Survey";
import Cycles "mo:base/ExperimentalCycles";

actor DataResearch {

    // Types
    type Profile = Types.Profile;
    type Bio = Types.Bio;
    type CanisterType = Types.CaniserType;
    type PublicSurvey = Types.PublicSurvey;

    // State
    let map = HashMap.HashMap<Principal, Profile>(1, Principal.equal, Principal.hash);
    let publicSurveys = HashMap.HashMap<Principal, Buffer.Buffer<PublicSurvey>>(1, Principal.equal, Principal.hash);
    let privateSurveys = HashMap.HashMap<Principal, Buffer.Buffer<P.PrivateSurvey>>(1, Principal.equal, Principal.hash);

    // API
    public shared(msg) func createProfile(bio: Bio): async ?Profile {
        let callerId = msg.caller;
        let profile = map.get(callerId);

        if (profile != null) {
            return null;
        };

        let userProfile: Profile = {
            id = callerId;
            bio = bio;
            privateSurveys = [];
        };

        map.replace(callerId, userProfile);
    };

    public shared(msg) func getProfile(): async ?Profile {
        let callerId = msg.caller;
        map.get(callerId);
    };

    public shared(msg) func updateProfile(bio: Bio): async ?Profile {
        let callerId = msg.caller;

        let userProfile: Profile = {
            bio = bio;
            id = callerId;
        };

        let result = map.get(callerId);

        if (result == null) {
            return null;
        };

        map.replace(callerId, userProfile);
    };

    public shared(msg) func deleteProfile(): async ?Profile {
        let callerId = msg.caller;
        map.remove(callerId);
    };

    public shared(msg) func createSurvey(_name: Text, canisterType : CanisterType ) {
        let callerId = msg.caller;

        switch (canisterType) {
            case (#Private) {
                let surveys = privateSurveys.get(callerId);
                
                Cycles.add(100_000_000);

                let survey = await P.PrivateSurvey(_name);

                Debug.print(await survey.getName());

                switch (surveys) {
                    case null {
                        let _surveys = Buffer.Buffer<P.PrivateSurvey>(1);
                        _surveys.add(survey);
                        privateSurveys.put(callerId, _surveys);
                    };
                    case (? v) {
                        v.add(survey);
                        privateSurveys.put(callerId, v);
                    }
                };

            };
            case (#Community) {
                let surveys = publicSurveys.get(callerId);
                let survey : PublicSurvey = {
                    name = _name;
                    canisterId = await idQuick();
                };
                switch (surveys) {
                    case null {
                        let _surveys = Buffer.Buffer<PublicSurvey>(1);
                        _surveys.add(survey);
                        publicSurveys.put(callerId, _surveys);
                    };
                    case (? v) {
                        v.add(survey);
                        publicSurveys.put(callerId, v);
                    }
                };
            };
        }
    };

    public shared(msg) func getPublicSurveys(): async [PublicSurvey] {
        let callerId = msg.caller;
        let _publicSurveys = publicSurveys.get(callerId); 
        switch (_publicSurveys) {
            case null {
                return [];
            };
            case (? v) {
                return v.toArray();
            };
        }
    };

    public shared(msg) func getPrivateSurveys(): async [P.PrivateSurvey] {
        let callerId = msg.caller;
        let _privateSurveys = privateSurveys.get(callerId); 
        switch (_privateSurveys) {
            case null {
                Debug.print("Empty Private Surveys");
                return [];
            };
            case (? v) {
                return v.toArray();
            };
        }
    };

    func idQuick() : async Principal { 
       return Principal.fromActor(DataResearch);
    };
}