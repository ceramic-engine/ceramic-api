package;

import tracker.SerializeModel;
import tracker.SaveModel;
import ceramic.Entity;
import ceramic.Color;
import ceramic.InitSettings;
import ceramic.Visual;

class Project extends Entity {

    function new(settings:InitSettings) {

        super();

        settings.antialiasing = 2;
        settings.background = Color.BLACK;
        settings.targetWidth = 640;
        settings.targetHeight = 480;
        settings.scaling = FIT;
        settings.resizable = true;

        app.onceReady(this, ready);

    }

    function ready() {

        #if headless
        ceramic.Tasks.runFromArgs();
        #end

        var model = new TestModel();
        SaveModel.loadFromKey(model, 'mymodel');
        trace('AFTER LOAD: ${model.test1}');
        // model.test1 = BREF(45, 'hello', 55.6);
        // trace('BEFORE SAVE: ${model.test1}');
        // SaveModel.autoSaveAsKey(model, 'mymodel');
        

    }

}
