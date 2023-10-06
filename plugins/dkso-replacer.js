"use strict";

const replace = function () {
    console.log("Starting replacement...");
    var countReplaced = 0;
    var countCouldntReplace = 0;
    for (var x = 0; x < map.size.x; x += 1) {
        for (var y = 0; y < map.size.y; y += 1) {
            const tile = map.getTile(x, y);
            for (var i = 0; i < tile.elements.length; i += 1) {
                const element = tile.elements[i];
                if (element.type === "small_scenery" ||
                    element.type === "large_scenery" ||
                    element.type === "wall") {
                    const loadedObject = objectManager.getObject(element.type, element.object);
                    if (loadedObject && loadedObject.identifier.indexOf("fidwell.") == 0 && loadedObject.identifier.indexOf("fidwell.v1.") < 0) {
                        var newIdentifier = "fidwell.v1." + loadedObject.identifier.substr(8);
                        const newObject = objectManager.load(newIdentifier);
                        if (newObject !== undefined) {
                            element.object = newObject.index;
                            countReplaced += 1;
                        } else {
                            console.log("Couldn't find object " + newIdentifier);
                            countCouldntReplace += 1;
                        }
                    }
                }
            }
        }
    }
    console.executeLegacy("remove_unused_objects");

    console.log("Removing old scenery groups...");
    const allGroups = objectManager.getAllObjects("scenery_group").filter(function (g) { return g.identifier.indexOf("fidwell.") === 0 && g.identifier.indexOf("fidwell.v1." < 0); });
    for (var g = 0; g < allGroups.length; g++) {
        const newGroup = "fidwell.v1." + allGroups[g].identifier.substr(8);
        objectManager.unload(allGroups[g].identifier);
        const groupObject = objectManager.load(newGroup);
        for (var o = 0; o < groupObject.items.length; o += 1) {
            objectManager.load(groupObject.items[o]);
        }
    }

    if (countCouldntReplace > 0) {
        park.postMessage("Replaced " + countReplaced + " objects. Couldn't replace " + countCouldntReplace + " objects. Replaced " + allGroups.length + " scenery groups.");
    } else {
        park.postMessage("Replaced " + countReplaced + " objects. Replaced " + allGroups.length + " scenery groups. Complete!");
    }
}

registerPlugin({
    name: "DKSO Replacer",
    version: "1.0",
    authors: ["fidwell"],
    type: "local",
    licence: "MIT",
    targetApiVersion: 79,
    main: function () {
        ui.registerMenuItem("DKSO Replacer", replace);
    }
});
