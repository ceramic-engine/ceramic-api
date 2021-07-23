import tracker.Model;

enum SomeEnum {

    YOUPI;

    BREF(one:Int, ?two:String, three:Float, ?four:Bool);

}

class TestModel extends Model {

    @serialize public var test1:SomeEnum;

}
