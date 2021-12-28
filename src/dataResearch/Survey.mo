import Principal "mo:base/Principal";

actor class PrivateSurvey(n: Text) = this {

    private var _name = n;

    public func getName(): async Text {
        return _name;
    };

    public func setName(name: Text): () {
        _name := name;   
    };

    public func getCanisterId(): async Principal {
        return Principal.fromActor(this);
  };
}