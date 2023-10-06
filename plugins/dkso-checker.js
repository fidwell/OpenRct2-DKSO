"use strict";

const check = function () {
    const allObjects = objectManager.getAllObjects("small_scenery")
        .concat(objectManager.getAllObjects("large_scenery"))
        .concat(objectManager.getAllObjects("wall"))
        .concat(objectManager.getAllObjects("scenery_group"));
    const v0Objects = allObjects.filter(function (o) { return o.identifier.includes("fidwell.scenery"); });
    const v1Objects = allObjects.filter(function (o) { return o.identifier.includes("fidwell.v"); });

    if (v0Objects.length > 0) {
        park.postMessage("DKSO v0 objects detected!");

        for (var i = 0; i < v0Objects.length; i++) {
            console.log(v0Objects[i].identifier);
        }
    } else if (v1Objects.length > 0) {
        park.postMessage("DKSO v1 objects detected.");
    } else {
        park.postMessage("No DKSO objects detected.");
    }
};

registerPlugin({
    name: "DKSO Checker",
    version: "1.0",
    authors: ["fidwell"],
    type: "local",
    licence: "MIT",
    targetApiVersion: 79,
    main: function () {
        ui.registerMenuItem("DKSO Checker", check);
    }
});
