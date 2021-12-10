import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Principal "mo:base/Principal";

actor DataResearch {
    type Bio = {
        givenName: ?Text;
        familyName: ?Text;
        name: ?Text;
        displayName: ?Text;
        location: ?Text;
        about: ?Text;
    };

    type Profile = {
        bio: Bio;
        id: Principal;
        image: ?Text;
    };
    
    type ProfileUpdate = {
        bio: Bio;
        image: ?Text;
    };

    type Error = {
        #NotFound;
        #AlreadyExists;
        #NotAuthorized;
    };

    stable var profiles : Trie.Trie<Principal, Profile> = Trie.empty();

    public shared(msg) func create (profile: ProfileUpdate) : async Result.Result<(), Error> {
        let callerId = msg.caller;

        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let userProfile: Profile = {
            bio = profile.bio;
            image = profile.image;
            id = callerId;
        };

        let (newProfiles, existing) = Trie.put(
            profiles,
            key(callerId),
            Principal.equal,
            userProfile
        );

        switch(existing) {
            case null {
                profiles := newProfiles;
                #ok(());
            };
            case (? v) {
                #err(#AlreadyExists);
            };
        };
    };

    public shared(msg) func read () : async Result.Result<Profile, Error> {
        let callerId = msg.caller;

        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let result = Trie.find(
            profiles,
            key(callerId),
            Principal.equal
        );
        return Result.fromOption(result, #NotFound);
    };

    public shared(msg) func update (profile : ProfileUpdate) : async Result.Result<(), Error> {
        let callerId = msg.caller;

        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let userProfile: Profile = {
            bio = profile.bio;
            image = profile.image;
            id = callerId;
        };

        let result = Trie.find(
            profiles,
            key(callerId),
            Principal.equal
        );

        switch (result){
            case null {
                #err(#NotFound)
            };
            case (? v) {
                profiles := Trie.replace(
                    profiles,
                    key(callerId),
                    Principal.equal,
                    ?userProfile
                ).0;
                #ok(());
            };
        };
    };

    public shared(msg) func delete () : async Result.Result<(), Error> {
        let callerId = msg.caller;

        if(Principal.toText(callerId) == "2vxsx-fae") {
            return #err(#NotAuthorized);
        };

        let result = Trie.find(
            profiles,
            key(callerId),
            Principal.equal
        );

        switch (result){
            case null {
                #err(#NotFound);
            };
            case (? v) {
                profiles := Trie.replace(
                    profiles,
                    key(callerId),
                    Principal.equal,
                    null
                ).0;
                #ok(());
            };
        };
    };

    private func key(x : Principal) : Trie.Key<Principal> {
        return { key = x; hash = Principal.hash(x) }
    };
}
